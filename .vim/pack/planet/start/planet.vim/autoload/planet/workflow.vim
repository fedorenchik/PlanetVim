vim9script
export def ProjectDirectory(arg_directory: any = v:null): any
  var directory: any = arg_directory == null ? inputdialog('Project directory: ', getcwd(-1, 0)) : arg_directory
  if empty(directory)
    return 0
  endif
  if !isdirectory(directory)
    echomsg 'PlanetVim: project directory does not exist: ' .. directory
    return 0
  endif
  execute 'tcd ' .. fnameescape(directory)
  return 1
enddef

export def CTest(): any
  var directory: any = planet#build#GetBuildDir()
  if empty(directory)
    echomsg 'PlanetVim: configure this CMake project before running CTest.'
    return 0
  endif
  return planet#term#RunArgv(['ctest', '--output-on-failure'], v:false, v:false, v:false, directory)
enddef

export def Git(arguments: any): any
  var root: any = planet#git#Repository(empty(expand('%:p')) ? getcwd() : expand('%:p:h'))
  if empty(root)
    if arguments ==# ['init']
      root = getcwd(-1, 0)
    else
      echomsg 'PlanetVim: open a Git project first.'
      return 0
    endif
  endif
  return planet#term#RunArgv(['git'] + arguments, v:false, v:false, v:false, root)
enddef
