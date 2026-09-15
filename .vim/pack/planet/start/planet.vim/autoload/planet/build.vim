vim9script

export def Plan(action: string, context: dict<any>): dict<any>
  planet#cmake#Prepare(context, action ==# 'configure')
  var directory = context.build_dir
  var argv = ['cmake']
  if action ==# 'configure'
    if !empty(get(context, 'preset', ''))
      argv += ['--preset', context.preset]
    endif
    argv += ['-S', context.source_dir, '-B', directory, '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON']
    if !empty(get(context, 'build_type', ''))
      add(argv, '-DCMAKE_BUILD_TYPE=' .. context.build_type)
    endif
    argv += get(context, 'configure_args', [])
  else
    if has_key(context, 'preset_environment') | context.env_snapshot = context.preset_environment | endif
    argv += ['--build', directory]
    if !empty(context.target)
      argv += ['--target', context.target]
    endif
    if !empty(get(context, 'build_type', ''))
      argv += ['--config', context.build_type]
    endif
    var jobs = get(context, 'jobs', 2)
    if type(jobs) != v:t_number || jobs < 1
      throw 'PlanetVim: jobs must be a positive integer'
    endif
    argv += ['--parallel', string(jobs)]
  endif
  return {argv: argv, cwd: context.source_dir, parser: 'compiler'}
enddef
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
  var previous_dirs = deepcopy(get(project, 'build_dirs', {}))
  var selected = planet#project#Context().configuration
  if !empty(selected)
    project.build_dirs = get(project, 'build_dirs', {})
    project.build_dirs[selected] = directory
  endif
  project.build_dir = directory
  if ! planet#run#Save()
    project.build_dir = previous
    project.build_dirs = previous_dirs
    g:PV_build_dir = previous
    return 0
  endif
  echo 'Build Directory: ' .. directory
  return 1
enddef

export def GetBuildDir(create_default: any = v:false): any
  var project: any = planet#project#Context()
  if empty(project.build_dir) && create_default
    if ! planet#build#NewInTreeBuildDir()
      return ''
    endif
    project = planet#project#Context()
  endif
  return project.build_dir
enddef

def Configured(context: dict<any>, state: dict<any>, Callback: any, result: dict<any>, buffer: number)
  if result.status ==# 'success'
    try
      planet#cmake#Configured(context, state)
    catch
      result.status = 'failed'
      result.error = v:exception
      echom result.error
    endtry
  endif
  if type(Callback) == v:t_func | call(Callback, [result, buffer]) | endif
enddef

export def Configure(export_compile_commands: any = v:false, on_exit: any = v:null): any
  try
    var context = planet#project#Context()
    var command = Plan('configure', context)
    var sysroot = get(get(t:, 'PV_configure_values', {}), 'sysroot', '')
    if !empty(sysroot) | add(command.argv, '-DCMAKE_SYSROOT=' .. sysroot) | endif
    return planet#term#RunCmd(command.argv, false, false, get(context, 'hidden', false), command.cwd,
      function(Configured, [context, planet#run#Project(), on_exit]), '', {context: context, parser: 'compiler'})
  catch
    return LocalError(v:exception)
  endtry
enddef

export def Build(target: any = '', on_exit: any = v:null): any
  try
    var context = planet#project#Context()
    if empty(context.build_dir) && empty(context.preset)
      return LocalError('configure or select this project build directory first')
    endif
    if !empty(target) | context.target = target | endif
    var command = Plan('build', context)
    return planet#term#RunCmd(command.argv, false, false, get(context, 'hidden', false), command.cwd,
      on_exit, '', {context: context, parser: 'compiler'})
  catch
    return LocalError(v:exception)
  endtry
enddef

export def Rebuild(): any
  var context = planet#project#Context()
  if empty(context.build_dir) && empty(context.preset)
    return LocalError('configure or select this project build directory first')
  endif
  var command = Plan('build', context)
  return planet#term#RunCmd(command.argv + ['--clean-first'], false, false, get(context, 'hidden', false),
    command.cwd, null, '', {context: context, parser: 'compiler'})
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
