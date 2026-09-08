scriptversion 4

func! planet#workflow#ProjectDirectory(directory = v:null) abort
  let l:directory = a:directory is v:null ? inputdialog('Project directory: ', getcwd(-1, 0)) : a:directory
  if empty(l:directory)
    return 0
  endif
  if !isdirectory(l:directory)
    echomsg 'PlanetVim: project directory does not exist: ' .. l:directory
    return 0
  endif
  execute 'tcd ' .. fnameescape(l:directory)
  return 1
endfunc

func! planet#workflow#CTest() abort
  let l:directory = planet#build#GetBuildDir()
  if empty(l:directory)
    echomsg 'PlanetVim: configure this CMake project before running CTest.'
    return 0
  endif
  return planet#term#RunArgv(['ctest', '--output-on-failure'], v:false, v:false, v:false, l:directory)
endfunc

func! planet#workflow#Git(arguments) abort
  let l:root = planet#git#Repository(empty(expand('%:p')) ? getcwd() : expand('%:p:h'))
  if empty(l:root)
    if a:arguments ==# ['init']
      let l:root = getcwd(-1, 0)
    else
      echomsg 'PlanetVim: open a Git project first.'
      return 0
    endif
  endif
  return planet#term#RunArgv(['git'] + a:arguments, v:false, v:false, v:false, l:root)
endfunc
