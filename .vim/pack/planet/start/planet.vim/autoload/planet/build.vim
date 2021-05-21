scriptversion 4

func! planet#build#BuildDirs() abort
  let l:basename = getcwd()->fnamemodify(':t')
  let l:dirs = systemlist('ls -d1 build*/ ../build*' .. l:basename .. '*/ 2>/dev/null')
  return l:dirs
endfunc

func! planet#build#SelectBuildDir() abort
  let l:dirs = [ 'Select Build Directory:', 'Create New Build Directory' ]
  let l:dirs = extend(l:dirs, planet#build#BuildDirs())
  let l:dirs = map(l:dirs, {key, val -> (key ? "[" .. key .. "] " : "") .. val})
  let l:dir_num = inputlist(l:dirs)
  if l:dir_num > 1
    let l:build_dir = split(l:dirs[l:dir_num])[1]
  elseif l:dir_num == 1
    let l:build_dir = input("New Build Directory Name: ", "build", "dir")
  end
  let g:PV_build_dir = fnamemodify(l:build_dir, ":p")
  call mkdir(g:PV_build_dir, "p")
endfunc
