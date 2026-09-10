vim9script
def LocalError(message: any): any
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. message
  echohl None
  return 0
enddef

export def BuildDirs(): any
  var name: any
  var root: any = planet#run#Project().root
  var basename: any = fnamemodify(root, ':t')
  var parent: any = fnamemodify(root, ':h')
  var dirs: any = []
  for item_name in readdir(root)
    name = item_name
    if stridx(name, 'build') == 0 && isdirectory(root .. '/' .. name)
      add(dirs, root .. '/' .. name)
    endif
  endfor
  for item_name in readdir(parent)
    name = item_name
    if stridx(name, 'build') == 0 && stridx(name, basename) >= 0 && isdirectory(parent .. '/' .. name)
      add(dirs, parent .. '/' .. name)
    endif
  endfor
  return uniq(sort(dirs))
enddef

# Optional explicit selections make the same validation usable without UI.
export def SelectBuildDir(arg_selection: any = v:null, new_name: any = v:null): any
  var name: any
  var dirs: any = planet#build#BuildDirs()
  var labels: any = ['Select Build Directory:']
  for index in range(len(dirs))
    add(labels, '[' .. (index + 1) .. '] ' .. dirs[index])
  endfor
  add(labels, '[' .. (len(dirs) + 1) .. '] Create New Build Directory')
  var selection: any = arg_selection == null ? inputlist(labels) : arg_selection
  if type(selection) != v:t_number || selection <= 0 || selection > len(dirs) + 1
    return 0
  endif
  if selection == len(dirs) + 1
    name = new_name == null ? input('New Build Directory Name: ', 'build', 'dir') : new_name
    return planet#build#NewBuildDir(name)
  endif
  return planet#build#NewBuildDir(dirs[selection - 1])
enddef

export def NewInTreeBuildDir(): any
  return planet#build#NewBuildDir('build')
enddef

export def NewOOTBuildDir(): any
  return planet#build#NewBuildDir('../build-' .. fnamemodify(planet#run#Project().root, ':t'))
enddef

export def NewBuildDir(build_dir: any): any
  if type(build_dir) != v:t_string || empty(build_dir)
    return 0
  endif
  var project: any = planet#run#Project()
  var directory: any = planet#run#Path(build_dir, project.root)
  try
    if ! isdirectory(directory)
      mkdir(directory, 'p')
    endif
    if ! isdirectory(directory)
      throw 'directory was not created'
    endif
  catch
    return LocalError('cannot use build directory: ' .. v:exception)
  endtry
  var previous: any = project.build_dir
  project.build_dir = directory
  if ! planet#run#Save()
    project.build_dir = previous
    g:PV_build_dir = previous
    return 0
  endif
  echo 'Build Directory: ' .. directory
  return 1
enddef

export def GetBuildDir(create_default: any = v:false): any
  var project: any = planet#run#Project()
  if empty(project.build_dir) && create_default
    if ! planet#build#NewInTreeBuildDir()
      return ''
    endif
  endif
  return project.build_dir
enddef

export def Configure(export_compile_commands: any = v:false, on_exit: any = v:null): any
  var directory: any = planet#build#GetBuildDir(v:true)
  if empty(directory)
    return 0
  endif
  var project: any = planet#run#Project()
  var argv: any = ['cmake', '-S', project.root, '-B', directory]
  if export_compile_commands
    add(argv, '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON')
  endif
  return planet#term#RunArgv(argv, v:false, v:false, v:false, directory, on_exit)
enddef

export def Build(target: any = '', on_exit: any = v:null): any
  var directory: any = planet#build#GetBuildDir()
  if empty(directory)
    return LocalError('configure or select this project build directory first')
  endif
  var argv: any = ['cmake', '--build', directory]
  if ! empty(target)
    argv += ['--target', target]
  endif
  return planet#term#RunArgv(argv, v:false, v:false, v:false, directory, on_exit)
enddef

export def Rebuild(): any
  var directory: any = planet#build#GetBuildDir()
  if empty(directory)
    return LocalError('configure or select this project build directory first')
  endif
  return planet#term#RunArgv(['cmake', '--build', directory, '--clean-first'], v:false, v:false, v:false, directory)
enddef

export def Browse(): any
  var directory: any = planet#build#GetBuildDir()
  if empty(directory) || ! isdirectory(directory)
    return LocalError('select an existing build directory first')
  endif
  execute 'Fern ' .. fnameescape(directory)
  return 0
enddef

export def ConfigureTui(): any
  var directory: any = planet#build#GetBuildDir(v:true)
  if ! empty(directory)
    return planet#term#RunCmdTab(['ccmake', '-S', planet#run#Project().root, '-B', directory], directory)
  endif
  return 0
enddef

export def ConfigureGui(): any
  var directory: any = planet#build#GetBuildDir(v:true)
  if ! empty(directory)
    return planet#term#RunGuiApp(['cmake-gui', '-S', planet#run#Project().root, '-B', directory], directory)
  endif
  return 0
enddef
