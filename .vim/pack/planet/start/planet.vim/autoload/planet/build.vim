scriptversion 4

func! planet#build#BuildDirs() abort
  let l:basename = getcwd()->fnamemodify(':t')
  let l:dirs = systemlist('ls -d1 build*/ ../build*' .. l:basename .. '*/ 2>/dev/null')
  return l:dirs
endfunc

func! planet#build#SelectBuildDir() abort
  let l:dirs = [ 'Select Build Directory:' ]
  let l:dirs = extend(l:dirs, planet#build#BuildDirs())
  let l:dirs = map(l:dirs, {key, val -> (key ? "[" .. key .. "] " : "") .. val})
  let l:dirs->add( '[' .. len(l:dirs) ..'] Create New Build Directory')
  let l:dir_num = inputlist(l:dirs)
  if l:dir_num == (len(l:dirs) - 1)
    let l:build_dir = input("New Build Directory Name: ", "build", "dir")
  elseif l:dir_num > 0
    let l:build_dir = split(l:dirs[l:dir_num])[1]
  else
    echo 'Cancelled'
    return
  end
  call planet#build#NewBuildDir(l:build_dir)
endfunc

func! planet#build#NewInTreeBuildDir() abort
  call planet#build#NewBuildDir('build')
endfunc

func! planet#build#NewOOTBuildDir() abort
  let l:basename = getcwd()->fnamemodify(':t')
  call planet#build#NewBuildDir('../build-' .. l:basename)
endfunc

func! planet#build#NewBuildDir(build_dir) abort
  let g:PV_build_dir = fnamemodify(a:build_dir, ":p")
  call mkdir(g:PV_build_dir, "p")
  echo "Build Directory: " .. g:PV_build_dir
endfunc
