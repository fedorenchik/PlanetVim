vim9script

var script_runtime = expand('<script>:p:h:h:h')
var script_specs = json_decode(join(readfile(script_runtime .. '/data/integrations.json'), "\n"))
var script_display_jobs = {}
var script_environment_stack = []
var script_initial_display = $DISPLAY

def LocalError(message: any): any
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. message
  echohl None
  return 0
enddef

export def Specs(): any
  return deepcopy(script_specs)
enddef

def LocalContext(): any
  var root: any = planet#run#Project().root
  var build: any = planet#build#GetBuildDir()
  return {root: root, build: empty(build) ? root .. '/build' : build, file: expand('%:p'), stem: expand('%:p:r'), cwd: getcwd(), display: $DISPLAY}
enddef

def LocalExpand(value: any, context: any): any
  if type(value) == v:t_list
    return map(copy(value), (_, lambda_item) => LocalExpand(lambda_item, context))
  endif
  return substitute(value, '%\(root\|build\|file\|stem\|cwd\|display\)%', (lambda_m) => get(context, lambda_m[1], ''), 'g')
enddef

# Executable overrides are argv Lists; Qt SDK tools are found through QTDIR
# before system installations. No shell parses filenames or entered arguments.
export def Tool(name: any, qt: any = v:false): any
  var sdk: any
  var found: any
  var override: any = get(get(g:, 'PV_integration_tools', {}), name, name)
  var argv: any = type(override) == v:t_list ? copy(override) : [override]
  if empty(argv) || ! empty(filter(copy(argv), (_, lambda_v) => type(lambda_v) != v:t_string))
    throw 'invalid executable override for ' .. name
  endif
  var candidates: any = []
  if argv[0] ==# name
    candidates += [planet#run#Project().root .. '/node_modules/.bin/' .. argv[0]]
  endif
  if qt && ! empty($QTDIR)
    candidates += [$QTDIR .. '/bin/' .. argv[0], $QTDIR .. '/libexec/' .. argv[0]]
  endif
  add(candidates, argv[0])
  if index(['sdkmanager', 'avdmanager'], name) >= 0
    sdk = ! empty($ANDROID_HOME) ? $ANDROID_HOME : $ANDROID_SDK_ROOT
    if ! empty(sdk)
      candidates += [sdk .. '/cmdline-tools/latest/bin/' .. name]
    endif
  endif
  if qt && ! has('win32')
    candidates += ['/usr/lib/qt6/bin/' .. argv[0], '/usr/lib/qt6/' .. argv[0],  '/usr/lib/qt6/libexec/' .. argv[0]]
  endif
  for entry in candidates
    found = exepath(entry)
    if ! empty(found)
      argv[0] = found
      if has('win32') && found =~? '\.\%(cmd\|bat\)$'
        return LocalHelper() + ['native'] + argv
      endif
      return argv
    endif
  endfor
  throw 'required tool ' .. name .. ' is missing. Install its SDK/CLI and add it to PATH'  .. (qt ? ' or set QTDIR to its Qt prefix' :  '')  .. '; g:PV_integration_tools[' .. string(name) .. '] may select an executable/argv List.'
enddef

def LocalValues(spec: any, supplied: any, context: any): any
  var default: any
  var value: any
  var values: any = {}
  for field in spec.fields
    default = LocalExpand(field.default, context)
    if has_key(supplied, field.name)
      value = supplied[field.name]
    else
      default = type(default) == v:t_list ? json_encode(default) : default
      value = inputdialog(field.label .. ': ', default, "\x01")
    endif
    if value == null || (type(value) == v:t_string && (value ==# "\x01" || empty(value)))
      throw 'cancelled'
    endif
    if field.kind =~# 'args$'
      value = type(value) == v:t_list ? value : json_decode(value)
      if type(value) != v:t_list || ! empty(filter(copy(value), (_, lambda_item) => type(lambda_item) != v:t_string))
        throw field.label .. ' must be a JSON array of Strings'
      endif
      if field.kind ==# 'required_args' && empty(value)
        throw field.label .. ' must include at least one argument'
      endif
    elseif type(value) != v:t_string || value =~# '[\r\n]'
      throw field.label .. ' must be a single-line String'
    elseif field.kind ==# 'pid' && (value !~# '^\d\+$' || str2nr(value) <= 0)
      throw field.label .. ' must be a positive integer'
    elseif index(['file', 'dir', 'output'], field.kind) >= 0
      value = planet#run#Path(value, context.root)
      if field.kind ==# 'file' && ! filereadable(value)
        throw 'input file does not exist: ' .. value
      elseif field.kind ==# 'dir' && ! isdirectory(value)
        throw 'directory does not exist: ' .. value
      endif
    endif
    values[field.name] = value
  endfor
  return values
enddef

# Plan resolves literal arguments and inputs, without starting a command.
export def Plan(id: any, arg_values: any = {}): any
  var part: any
  var key: any
  if ! has_key(script_specs, id)
    throw 'unknown integration: ' .. id
  endif
  var spec: any = script_specs[id]
  if get(spec, 'linux', v:false) && has('win32')
    throw id .. ' requires a Linux host and its native toolchain'
  endif
  var context: any = LocalContext()
  var values: any = LocalValues(spec, arg_values, context)
  var argv: any = []
  for item_part in spec.argv
    part = item_part
    part = LocalExpand(part, context)
    key = matchstr(part, '^{\zs[^}]*\ze}$')
    if has_key(values, key) && type(values[key]) == v:t_list
      argv += values[key]
    else
      add(argv, substitute(part, '{\([^}]*\)}', (lambda_m) => get(values, lambda_m[1], lambda_m[0]), 'g'))
    endif
  endfor
  argv = planet#integrations#Tool(argv[0], get(spec, 'qt', v:false)) + argv[1 : ]
  return {argv: argv, cwd: context.root, values: values, note: get(spec, 'note', ''), then_build: get(spec, 'then_build', v:false)}
enddef

def LocalConfigured(plan: any, options: any, result: any, buffer: any): any
  if result.status ==# 'success'
    planet#term#RunArgv(planet#integrations#Tool('cmake') + ['--build', plan.values.directory],  v:false, v:false, get(options, 'hidden', v:false), plan.cwd,  get(options, 'on_exit', v:null))
  elseif type(get(options, 'on_exit', v:null)) == v:t_func
    call(options.on_exit, [result, buffer])
  endif
  return 0
enddef

export def Run(id: any, values: any = {}, options: any = {}): any
  var plan: any
  var Callback: any
  try
    plan = planet#integrations#Plan(id, values)
    if ! empty(plan.note)
      echomsg 'PlanetVim: ' .. plan.note
    endif
    Callback = plan.then_build ? function(LocalConfigured, [plan, options]) : get(options, 'on_exit', v:null)
    if id ==# 'xvfb-view'
      planet#integrations#Tool('vncviewer')
      plan.argv = LocalHelper() + ['view-display', plan.values.display,  plan.values.password, plan.values.port, script_initial_display]
    endif
    return planet#term#RunArgv(plan.argv, v:false, v:false, get(options, 'hidden', v:false), plan.cwd, Callback)
  catch
    return v:exception ==# 'cancelled' ? 0 : LocalError(v:exception)
  endtry
enddef

export def Command(arg_argv: any, options: any = {}): any
  var argv: any
  try
    if empty(arg_argv)
      return LocalError('a command must include an executable')
    endif
    argv = planet#integrations#Tool(arg_argv[0], get(options, 'qt', v:false)) + arg_argv[1 : ]
    return planet#term#RunArgv(argv, v:false, v:false, get(options, 'hidden', v:false), get(options, 'cwd',
         planet#run#Project().root), get(options, 'on_exit', v:null))
  catch
    return LocalError(v:exception)
  endtry
enddef

export def Ask(argv: any, label: any, default: any = []): any
  var args: any
  try
    args = inputdialog(label .. ' (JSON array): ', json_encode(default), '')
    if empty(args)
      return 0
    endif
    args = json_decode(args)
    if type(args) != v:t_list || ! empty(filter(copy(args), (_, lambda_item) => type(lambda_item) != v:t_string))
      return LocalError('arguments must be a JSON array of Strings')
    endif
    if empty(args)
      return 0
    endif
    return planet#integrations#Command(argv + args)
  catch
    return LocalError(v:exception)
  endtry
enddef

export def Set(name: any, arg_value: any = v:null, global: any = v:false): any
  var previous: any = global ? get(g:, name, '') : getenv(name)
  var value: any = arg_value == null ? inputdialog(name .. ': ', previous == null ? '' : string(previous)->substitute("^'\|'$", '', 'g'), "\x01") : arg_value
  if value ==# "\x01" || empty(value)
    return 0
  endif
  if global
    g:[name] = value
  else
    setenv(name, value)
  endif
  echomsg name .. '=' .. value
  return 1
enddef

export def Compiler(name: any, arg_prefix: any = v:null): any
  var prefix: any
  var cc: any
  var cxx: any
  var pair: any = get({gcc: ['gcc', 'g++'], clang: ['clang', 'clang++'], emcc: ['emcc', 'em++']}, name, [])
  var defaults: any = {raspberry: 'aarch64-linux-gnu-', esp32: 'xtensa-esp32-elf-', arduino: 'avr-', jetson: 'aarch64-linux-gnu-',
       beaglebone: 'arm-linux-gnueabihf-', coral: 'aarch64-linux-gnu-', hikey: 'aarch64-linux-gnu-', mingw: 'x86_64-w64-mingw32-',
       arm: 'arm-none-eabi-', aarch64: 'aarch64-linux-gnu-', avr: 'avr-'}
  if empty(pair)
    prefix = arg_prefix == null ? inputdialog('Cross compiler prefix (including path if needed): ', get(defaults, name, ''), '') : arg_prefix
    if empty(prefix)
      return 0
    endif
    pair = [prefix .. 'gcc', prefix .. 'g++']
  endif
  try
    cc = planet#integrations#Tool(pair[0])
    cxx = planet#integrations#Tool(pair[1])
    if len(cc) != 1 || len(cxx) != 1
      return LocalError('compiler environment values must be single executable paths')
    endif
    $CC = cc[0]
    $CXX = cxx[0]
    if !empty(prefix)
      $CROSS_COMPILE = prefix
    endif
    echomsg 'Compiler selected for new build configurations: CC=' .. $CC .. ', CXX=' .. $CXX
    return 1
  catch
    return LocalError(v:exception)
  endtry
enddef

export def Write(kind: any, filename: any = v:null, value: any = v:null): any
  var prefix: any
  var lines: any
  var root: any = planet#run#Project().root
  var default: any = root .. '/' .. (kind ==# 'qt-conf' ? 'qt.conf' : 'autogen.sh')
  var file: any = filename == null ? inputdialog('New configuration file: ', default, '') : filename
  if empty(file)
    return 0
  endif
  file = planet#run#Path(file, root)
  if getftype(file) !=# ''
    return LocalError('file already exists; open it to edit: ' .. file)
  endif
  if kind ==# 'qt-conf'
    prefix = value == null ? inputdialog('Qt installation prefix (relative to executable or absolute): ', $QTDIR, '') : value
    if empty(prefix)
      return 0
    endif
    lines = ['[Paths]', 'Prefix=' .. prefix]
  elseif kind ==# 'autogen'
    lines = ['#!/bin/sh', 'set -eu', 'cd -- "$(dirname -- "$0")"', 'exec autoreconf --force --install "$@"']
  else
    return LocalError('unknown configuration kind: ' .. kind)
  endif
  writefile(lines, file)
  if kind ==# 'autogen' && ! has('win32')
    setfperm(file, 'rwxr-xr-x')
  endif
  execute 'edit ' .. fnameescape(file)
  return 1
enddef

export def Browse(arg_path: any): any
  var pid: any
  var path: any = arg_path
  if arg_path ==# '/proc/PID'
    pid = inputdialog('Process ID: ', '', '')
    if pid !~# '^\d\+$'
      return 0
    endif
    path = '/proc/' .. pid
  endif
  if ! isdirectory(path)
    return LocalError('directory unavailable: ' .. path)
  endif
  execute 'Fern ' .. fnameescape(path)
  return 1
enddef

export def XDisplay(action: any, value: any = v:null): any
  var buffer: any
  if has('win32')
    return LocalError('Xvfb actions require a Linux X server host')
  endif
  var display: any = value == null ? inputdialog('X display: ', empty($DISPLAY) ? ':80' : $DISPLAY, '') : value
  if display !~# '^:\d\+\%(\.\d\+\)\?$'
    return empty(display) ? 0 : LocalError('use a local display such as :80')
  endif
  if action ==# 'set'
    $DISPLAY = display
    return 1
  elseif action ==# 'stop'
    if ! has_key(script_display_jobs, display)
      return LocalError('no PlanetVim-owned Xvfb job for ' .. display)
    endif
    return planet#term#Cancel(script_display_jobs[display])
  elseif action ==# 'start'
    if has_key(script_display_jobs, display) && get(planet#term#Result(script_display_jobs[display]), 'status', '') ==# 'running'
      return LocalError('PlanetVim already started ' .. display)
    endif
    buffer = planet#integrations#Command(['Xvfb', display, '-screen', '0', '1280x900x24', '-nolisten', 'tcp'], {hidden: v:true, on_exit: function(LocalDisplayExited, [display])})
    if buffer > 0
      script_display_jobs[display] = buffer
    endif
    return buffer
  endif
  return LocalError('unknown X display action')
enddef

def LocalDisplayExited(display: any, result: any, buffer: any): any
  if get(script_display_jobs, display, 0) == buffer
    remove(script_display_jobs, display)
  endif
  return 0
enddef

def LocalHelper(): any
  return planet#generate#Python() + [script_runtime .. '/bin/integration-tool.py']
enddef

def LocalEnvironmentReady(filename: any, result: any, buffer: any): any
  var new: any
  var previous: any
  var applied: any
  var value: any
  try
    if result.status !=# 'success' || ! filereadable(filename)
      return 0
    endif
    new = json_decode(join(readfile(filename), "\n"))
    previous = {}
    applied = {}
    for key in uniq(sort(keys(environ()) + keys(new)))
      value = get(new, key, v:null)
      if key =~# '^\h\w*$' && (type(value) == v:t_string || value == null) && index(['HOME', 'CODEX_HOME',
           'USERPROFILE', 'PWD', 'OLDPWD', 'SHLVL', '_'], key) < 0 && getenv(key) !=# value
        previous[key] = getenv(key)
        applied[key] = value
        setenv(key, value)
      endif
    endfor
    add(script_environment_stack, {previous: previous, applied: applied})
    echomsg 'PlanetVim: SDK environment applied to this GVim and subsequent tool jobs.'
  finally
    delete(filename)
  endtry
  return 0
enddef

export def RestoreEnvironment(): any
  if empty(script_environment_stack)
    return LocalError('no SDK environment activated by PlanetVim in this GVim')
  endif
  var entry: any = remove(script_environment_stack, -1)
  for [key, previous] in items(entry.previous)
    # Keep values the user changed after activation.
    if getenv(key) ==# entry.applied[key]
      setenv(key, previous)
    endif
  endfor
  return 1
enddef

export def Environment(kind: any, filename: any = v:null, arguments: any = [], options: any = {}): any
  var defaults: any = {ros2: planet#run#Project().root .. '/install/setup.' .. (has('win32') ? 'bat' : 'bash'),
       yocto: planet#run#Project().root .. '/oe-init-build-env', emsdk: $EMSDK .. '/emsdk_env.' .. (has('win32') ? 'bat' : 'sh'),
       platformio: expand('~/.platformio/penv/') .. (has('win32') ? 'Scripts/activate.bat' : 'bin/activate')}
  var file: any = filename == null ? inputdialog('SDK setup script to execute: ', get(defaults, kind, ''), '') : filename
  if empty(file)
    return 0
  endif
  if ! filereadable(file)
    return LocalError('SDK setup script not found: ' .. file .. '. Install/select the SDK first.')
  endif
  var result: any = tempname() .. '.json'
  return planet#term#RunArgv(LocalHelper() + ['source-env', result, fnamemodify(file, ':p')] + arguments,
       v:false, v:false, get(options, 'hidden', v:false), planet#run#Project().root, function(LocalEnvironmentReady,
       [result]))
enddef

export def Conda(arg_name: any = v:null): any
  var conda: any
  var result: any
  var name: any = arg_name == null ? inputdialog('Conda environment name: ', 'base', '') : arg_name
  if empty(name)
    return 0
  endif
  try
    conda = planet#integrations#Tool('conda')
    if len(conda) != 1
      return LocalError('Conda activation requires a single native conda executable')
    endif
    result = tempname() .. '.json'
    return planet#term#RunArgv(LocalHelper() + ['conda-env', result, conda[0], name], v:false, v:false,
         v:false, planet#run#Project().root, function(LocalEnvironmentReady, [result]))
  catch
    return LocalError(v:exception)
  endtry
enddef

export def ExportRequirements(dev: any = v:false, filename: any = v:null): any
  var command: any
  var default: any = planet#run#Project().root .. '/' .. (dev ? 'dev-requirements.txt' : 'requirements.txt')
  var file: any = filename == null ? inputdialog('New requirements file: ', default, '') : filename
  if empty(file)
    return 0
  endif
  try
    command = planet#integrations#Tool('pipenv') + ['requirements'] + (dev ? ['--dev-only'] : [])
    return planet#term#RunArgv(LocalHelper() + ['capture', file] + command, v:false, v:false, v:false, planet#run#Project().root)
  catch
    return LocalError(v:exception)
  endtry
enddef

export def ConfigureValue(name: any, arg_value: any = v:null): any
  var values: any = get(t:, 'PV_configure_values', {})
  var value: any = arg_value == null ? inputdialog('Configure ' .. name .. ': ', get(values, name, ''), '') : arg_value
  if empty(value)
    return 0
  endif
  if name ==# 'sysroot' && ! isdirectory(value)
    return LocalError('sysroot directory does not exist')
  endif
  values[name] = value
  t:PV_configure_values = values
  if name ==# 'sysroot'
    $SYSROOT = fnamemodify(value, ':p')
  endif
  echomsg 'PlanetVim: saved for this project configure action: ' .. name .. '=' .. value
  return 1
enddef

export def Configure(arguments: any = v:null): any
  var flag: any
  var args: any = copy(arguments == null ? get(t:, 'PV_configure_arguments', []) : arguments)
  var values: any = get(t:, 'PV_configure_values', {})
  for key in ['build', 'host', 'target']
    if has_key(values, key)
      args += ['--' .. key .. '=' .. values[key]]
    endif
  endfor
  if has_key(values, 'sysroot')
    flag = shellescape('--sysroot=' .. values.sysroot)
    args += ['CFLAGS=' .. $CFLAGS .. ' ' .. flag, 'CXXFLAGS=' .. $CXXFLAGS .. ' ' .. flag]
  endif
  return planet#integrations#Command([planet#run#Project().root .. '/configure'] + args)
enddef

export def CmakeConfigure(export_compile_commands: any = v:false): any
  var build: any
  var sysroot: any = get(get(t:, 'PV_configure_values', {}), 'sysroot', '')
  if empty(sysroot)
    return planet#build#Configure(export_compile_commands)
  endif
  build = planet#build#GetBuildDir(v:true)
  if empty(build)
    return 0
  endif
  var argv: any = ['cmake', '-S', planet#run#Project().root, '-B', build, '-DCMAKE_SYSROOT=' .. sysroot]
  if export_compile_commands
    add(argv, '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON')
  endif
  return planet#integrations#Command(argv)
enddef

export def ConfigureOptions(arg_value: any = v:null): any
  var args: any
  var value: any = arg_value == null ? inputdialog('Configure arguments (JSON array): ', json_encode(get(t:, 'PV_configure_arguments', [])), '') : arg_value
  if empty(value)
    return 0
  endif
  try
    args = type(value) == v:t_list ? value : json_decode(value)
    if type(args) != v:t_list || ! empty(filter(copy(args), (_, lambda_arg) => type(lambda_arg) != v:t_string))
      return LocalError('configure arguments must be a JSON array of Strings')
    endif
    t:PV_configure_arguments = args
    return 1
  catch
    return LocalError(v:exception)
  endtry
enddef

export def Flutter(kind: any, arg_value: any = v:null): any
  var value: any = arg_value == null ? inputdialog(kind ==# 'sdk' ? 'Android SDK directory: ' : 'New Flutter project directory: ', '', '') : arg_value
  if empty(value)
    return 0
  endif
  var path: any = planet#run#Path(value, planet#run#Project().root)
  if kind ==# 'sdk' && ! isdirectory(path)
    return LocalError('Android SDK directory does not exist: ' .. path)
  elseif kind ==# 'create' && getftype(path) !=# ''
    return LocalError('choose a new Flutter project directory')
  endif
  return planet#integrations#Command(kind ==# 'sdk' ? ['flutter', 'config', '--android-sdk', path] : ['flutter', 'create', path])
enddef

export def Emsdk(action: any, directory: any = v:null, arg_version: any = v:null): any
  var dir: any = directory == null ? inputdialog('Existing emsdk checkout directory: ', $EMSDK, '') : directory
  if empty(dir)
    return 0
  endif
  var script: any = dir .. '/emsdk.py'
  if ! filereadable(script)
    return LocalError('emsdk.py was not found; clone https://github.com/emscripten-core/emsdk and select its directory')
  endif
  if action ==# 'update'
    return planet#integrations#Command(['git', '-C', dir, 'pull', '--ff-only'])
  endif
  var version: any = arg_version == null ? inputdialog('Emscripten SDK version: ', 'latest', '') : arg_version
  if empty(version)
    return 0
  endif
  var Callback: any = action ==# 'activate' ? function(LocalEmsdkActivated, [dir]) : v:null
  return planet#term#RunArgv(planet#generate#Python() + [script, action, version], v:false, v:false, v:false, dir, Callback)
enddef

def LocalEmsdkActivated(directory: any, result: any, buffer: any): any
  if result.status ==# 'success'
    planet#integrations#Environment('emsdk', directory .. '/emsdk_env.' .. (has('win32') ? 'bat' :  'sh'))
  endif
  return 0
enddef

export def Trace(): any
  echomsg 'PlanetVim: choose Open trace file in Perfetto to view a local Chrome Trace JSON file.'
  return planet#gui#OpenUrl('https://ui.perfetto.dev/')
enddef

export def Tags(kind: any, filename: any = v:null): any
  var file: any
  var fields: any
  var root: any = planet#run#Project().root
  var tags: any = root .. '/tags'
  if ! filereadable(tags)
    return LocalError('build the project tags file first')
  endif
  file = filename == null ? inputdialog('New syntax file: ', root .. '/' .. kind .. '.vim', '') : filename
  if empty(file)
    return 0
  endif
  if getftype(file) !=# ''
    return LocalError('syntax file already exists: ' .. file)
  endif
  var words: any = []
  for line in readfile(tags)
    fields = split(line, "\t")
    if len(fields) < 2 || fields[0] !~# '^\h\w*$'
      continue
    endif
    if kind ==# 'types' && empty(filter(copy(fields[3 : ]), (_, lambda_v) => lambda_v =~# '^\%(kind:\)\?\%(c\|g\|s\|t\|u\|class\|enum\|struct\|typedef\|union\)$'))
      continue
    endif
    add(words, fields[0])
  endfor
  words = uniq(sort(words))
  var lines: any = ['" Generated from the project tags file by PlanetVim.']
  while ! empty(words)
    add(lines, 'syntax keyword ' .. (kind ==# 'types' ? 'Type ' : 'Tag ') .. join(remove(words, 0, min([49, len(words) - 1])), ' '))
  endwhile
  writefile(lines, file)
  execute 'edit ' .. fnameescape(file)
  return 1
enddef

export def QtInstall(target: any, modules: any = v:false): any
  var version: any = inputdialog('Qt version: ', '6.2.3', '')
  if empty(version)
    return 0
  endif
  var host: any = has('win32') ? 'windows' : 'linux'
  var architecture: any = inputdialog('Qt architecture: ', target ==# 'android' ? 'android_arm64_v8a' : target ==# 'wasm' ? 'wasm_32' : has('win32') ? 'win64_msvc2019_64' : 'gcc_64',
       '')
  if empty(architecture)
    return 0
  endif
  var directory: any = inputdialog('Qt installation directory: ', empty($QTDIR) ? expand('~/Qt') : fnamemodify($QTDIR, ':h:h'), '')
  if empty(directory)
    return 0
  endif
  var argv: any = ['aqt', 'install-qt', host, target ==# 'android' ? 'android' : 'desktop', version, architecture, '--outputdir', directory]
  if modules
    argv += ['--modules', 'all']
  endif
  return planet#integrations#Command(argv)
enddef

export def QmakeDestdir(arg_value: any = v:null): any
  var value: any = arg_value == null ? inputdialog('QMake DESTDIR: ', planet#run#Project().root .. '/bin', '') : arg_value
  if empty(value)
    return 0
  endif
  return planet#integrations#Command(['qmake', 'DESTDIR=' .. planet#run#Path(value, planet#run#Project().root)], {qt: v:true})
enddef

export def AndroidCmake(abi: any, arg_ndk: any = v:null, arg_api: any = v:null): any
  var build: any
  var ndk: any = arg_ndk == null ? inputdialog('Android NDK directory: ', empty($ANDROID_NDK_HOME) ? $ANDROID_NDK : $ANDROID_NDK_HOME, '') : arg_ndk
  if empty(ndk)
    return 0
  endif
  var toolchain: any = ndk .. '/build/cmake/android.toolchain.cmake'
  if ! filereadable(toolchain)
    return LocalError('NDK toolchain was not found: ' .. toolchain)
  endif
  var api: any = arg_api == null ? inputdialog('Android API level: ', '23', '') : arg_api
  if api !~# '^\d\+$'
    return empty(api) ? 0 : LocalError('API level must be numeric')
  endif
  build = planet#build#GetBuildDir(v:true)
  if empty(build)
    return 0
  endif
  return planet#integrations#Command(['cmake', '-S', planet#run#Project().root, '-B', build, '-DCMAKE_TOOLCHAIN_FILE=' .. toolchain,
       '-DANDROID_ABI=' .. abi, '-DANDROID_PLATFORM=android-' .. api, '-DCMAKE_BUILD_TYPE=Release'])
enddef

export def AutotoolsStatus(): any
  var lines: any = ['Autotools executables available to this GVim:']
  for name in ['autoconf', 'automake', 'autoreconf', 'autoheader', 'libtool', 'libtoolize']
    add(lines, name .. ': ' .. (executable(name) ? exepath(name) : 'missing; install the corresponding Autotools package'))
  endfor
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  setline(1, lines)
  setlocal nomodifiable
  return 1
enddef
