scriptversion 4

let s:runtime = expand('<sfile>:p:h:h:h')
let s:specs = json_decode(join(readfile(s:runtime .. '/data/integrations.json'), "\n"))
let s:display_jobs = {}
let s:environment_stack = []
let s:initial_display = $DISPLAY

func! s:Error(message) abort
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#integrations#Specs() abort
  return deepcopy(s:specs)
endfunc

func! s:Context() abort
  let l:root = planet#run#Project().root
  let l:build = planet#build#GetBuildDir()
  return #{root: l:root, build: empty(l:build) ? l:root .. '/build' : l:build,
        \ file: expand('%:p'), stem: expand('%:p:r'), cwd: getcwd(), display: $DISPLAY}
endfunc

func! s:Expand(value, context) abort
  if type(a:value) == v:t_list
    return map(copy(a:value), {_, item -> s:Expand(item, a:context)})
  endif
  return substitute(a:value, '%\(root\|build\|file\|stem\|cwd\|display\)%',
        \ {m -> get(a:context, m[1], '')}, 'g')
endfunc

" Executable overrides are argv Lists; Qt SDK tools are found through QTDIR
" before system installations. No shell parses filenames or entered arguments.
func! planet#integrations#Tool(name, qt = v:false) abort
  let l:override = get(get(g:, 'PV_integration_tools', {}), a:name, a:name)
  let l:argv = type(l:override) == v:t_list ? copy(l:override) : [l:override]
  if empty(l:argv) || ! empty(filter(copy(l:argv), {_, v -> type(v) != v:t_string}))
    throw 'invalid executable override for ' .. a:name
  endif
  let l:candidates = []
  if l:argv[0] ==# a:name
    let l:candidates += [planet#run#Project().root .. '/node_modules/.bin/' .. l:argv[0]]
  endif
  if a:qt && ! empty($QTDIR)
    let l:candidates += [$QTDIR .. '/bin/' .. l:argv[0], $QTDIR .. '/libexec/' .. l:argv[0]]
  endif
  call add(l:candidates, l:argv[0])
  if index(['sdkmanager', 'avdmanager'], a:name) >= 0
    let l:sdk = ! empty($ANDROID_HOME) ? $ANDROID_HOME : $ANDROID_SDK_ROOT
    if ! empty(l:sdk)
      let l:candidates += [l:sdk .. '/cmdline-tools/latest/bin/' .. a:name]
    endif
  endif
  if a:qt && ! has('win32')
    let l:candidates += ['/usr/lib/qt6/bin/' .. l:argv[0], '/usr/lib/qt6/' .. l:argv[0],
          \ '/usr/lib/qt6/libexec/' .. l:argv[0]]
  endif
  for l:entry in l:candidates
    let l:found = exepath(l:entry)
    if ! empty(l:found)
      let l:argv[0] = l:found
      if has('win32') && l:found =~? '\.\%(cmd\|bat\)$'
        return s:Helper() + ['native'] + l:argv
      endif
      return l:argv
    endif
  endfor
  throw 'required tool ' .. a:name .. ' is missing. Install its SDK/CLI and add it to PATH'
        \ .. (a:qt ? ' or set QTDIR to its Qt prefix' : '')
        \ .. '; g:PV_integration_tools[' .. string(a:name) .. '] may select an executable/argv List.'
endfunc

func! s:Values(spec, supplied, context) abort
  let l:values = {}
  for l:field in a:spec.fields
    let l:default = s:Expand(l:field.default, a:context)
    if has_key(a:supplied, l:field.name)
      let l:value = a:supplied[l:field.name]
    else
      let l:default = type(l:default) == v:t_list ? json_encode(l:default) : l:default
      let l:value = inputdialog(l:field.label .. ': ', l:default, "\x01")
    endif
    if l:value is v:null || (type(l:value) == v:t_string && (l:value ==# "\x01" || empty(l:value)))
      throw 'cancelled'
    endif
    if l:field.kind =~# 'args$'
      let l:value = type(l:value) == v:t_list ? l:value : json_decode(l:value)
      if type(l:value) != v:t_list || ! empty(filter(copy(l:value), {_, item -> type(item) != v:t_string}))
        throw l:field.label .. ' must be a JSON array of Strings'
      endif
      if l:field.kind ==# 'required_args' && empty(l:value)
        throw l:field.label .. ' must include at least one argument'
      endif
    elseif type(l:value) != v:t_string || l:value =~# '[\r\n]'
      throw l:field.label .. ' must be a single-line String'
    elseif l:field.kind ==# 'pid' && (l:value !~# '^\d\+$' || str2nr(l:value) <= 0)
      throw l:field.label .. ' must be a positive integer'
    elseif index(['file', 'dir', 'output'], l:field.kind) >= 0
      let l:value = planet#run#Path(l:value, a:context.root)
      if l:field.kind ==# 'file' && ! filereadable(l:value)
        throw 'input file does not exist: ' .. l:value
      elseif l:field.kind ==# 'dir' && ! isdirectory(l:value)
        throw 'directory does not exist: ' .. l:value
      endif
    endif
    let l:values[l:field.name] = l:value
  endfor
  return l:values
endfunc

" Plan resolves literal arguments and inputs, without starting a command.
func! planet#integrations#Plan(id, values = {}) abort
  if ! has_key(s:specs, a:id)
    throw 'unknown integration: ' .. a:id
  endif
  let l:spec = s:specs[a:id]
  if get(l:spec, 'linux', v:false) && has('win32')
    throw a:id .. ' requires a Linux host and its native toolchain'
  endif
  let l:context = s:Context()
  let l:values = s:Values(l:spec, a:values, l:context)
  let l:argv = []
  for l:part in l:spec.argv
    let l:part = s:Expand(l:part, l:context)
    let l:key = matchstr(l:part, '^{\zs[^}]*\ze}$')
    if has_key(l:values, l:key) && type(l:values[l:key]) == v:t_list
      let l:argv += l:values[l:key]
    else
      call add(l:argv, substitute(l:part, '{\([^}]*\)}', {m -> get(l:values, m[1], m[0])}, 'g'))
    endif
  endfor
  let l:argv = planet#integrations#Tool(l:argv[0], get(l:spec, 'qt', v:false)) + l:argv[1:]
  return #{argv: l:argv, cwd: l:context.root, values: l:values,
        \ note: get(l:spec, 'note', ''), then_build: get(l:spec, 'then_build', v:false)}
endfunc

func! s:Configured(plan, options, result, buffer) abort
  if a:result.status ==# 'success'
    call planet#term#RunArgv(planet#integrations#Tool('cmake') + ['--build', a:plan.values.directory],
          \ v:false, v:false, get(a:options, 'hidden', v:false), a:plan.cwd,
          \ get(a:options, 'on_exit', v:null))
  elseif type(get(a:options, 'on_exit', v:null)) == v:t_func
    call call(a:options.on_exit, [a:result, a:buffer])
  endif
endfunc

func! planet#integrations#Run(id, values = {}, options = {}) abort
  try
    let l:plan = planet#integrations#Plan(a:id, a:values)
    if ! empty(l:plan.note)
      echomsg 'PlanetVim: ' .. l:plan.note
    endif
    let l:Callback = l:plan.then_build ? function('s:Configured', [l:plan, a:options])
          \ : get(a:options, 'on_exit', v:null)
    if a:id ==# 'xvfb-view'
      call planet#integrations#Tool('vncviewer')
      let l:plan.argv = s:Helper() + ['view-display', l:plan.values.display,
            \ l:plan.values.password, l:plan.values.port, s:initial_display]
    endif
    return planet#term#RunArgv(l:plan.argv, v:false, v:false, get(a:options, 'hidden', v:false), l:plan.cwd, l:Callback)
  catch
    return v:exception ==# 'cancelled' ? 0 : s:Error(v:exception)
  endtry
endfunc

func! planet#integrations#Command(argv, options = {}) abort
  try
    if empty(a:argv)
      return s:Error('a command must include an executable')
    endif
    let l:argv = planet#integrations#Tool(a:argv[0], get(a:options, 'qt', v:false)) + a:argv[1:]
    return planet#term#RunArgv(l:argv, v:false, v:false, get(a:options, 'hidden', v:false),
          \ get(a:options, 'cwd', planet#run#Project().root), get(a:options, 'on_exit', v:null))
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! planet#integrations#Ask(argv, label, default = []) abort
  try
    let l:args = inputdialog(a:label .. ' (JSON array): ', json_encode(a:default), '')
    if empty(l:args)
      return 0
    endif
    let l:args = json_decode(l:args)
    if type(l:args) != v:t_list || ! empty(filter(copy(l:args), {_, item -> type(item) != v:t_string}))
      return s:Error('arguments must be a JSON array of Strings')
    endif
    if empty(l:args)
      return 0
    endif
    return planet#integrations#Command(a:argv + l:args)
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! planet#integrations#Set(name, value = v:null, global = v:false) abort
  let l:previous = a:global ? get(g:, a:name, '') : getenv(a:name)
  let l:value = a:value is v:null ? inputdialog(a:name .. ': ', l:previous is v:null ? '' : string(l:previous)->substitute("^'\|'$", '', 'g'), "\x01") : a:value
  if l:value ==# "\x01" || empty(l:value)
    return 0
  endif
  if a:global
    let g:[a:name] = l:value
  else
    call setenv(a:name, l:value)
  endif
  echomsg a:name .. '=' .. l:value
  return 1
endfunc

func! planet#integrations#Compiler(name, prefix = v:null) abort
  let l:pair = get(#{gcc: ['gcc', 'g++'], clang: ['clang', 'clang++'], emcc: ['emcc', 'em++']}, a:name, [])
  let l:defaults = #{raspberry: 'aarch64-linux-gnu-', esp32: 'xtensa-esp32-elf-', arduino: 'avr-',
        \ jetson: 'aarch64-linux-gnu-', beaglebone: 'arm-linux-gnueabihf-', coral: 'aarch64-linux-gnu-',
        \ hikey: 'aarch64-linux-gnu-', mingw: 'x86_64-w64-mingw32-', arm: 'arm-none-eabi-',
        \ aarch64: 'aarch64-linux-gnu-', avr: 'avr-'}
  if empty(l:pair)
    let l:prefix = a:prefix is v:null ? inputdialog('Cross compiler prefix (including path if needed): ', get(l:defaults, a:name, ''), '') : a:prefix
    if empty(l:prefix)
      return 0
    endif
    let l:pair = [l:prefix .. 'gcc', l:prefix .. 'g++']
  endif
  try
    let l:cc = planet#integrations#Tool(l:pair[0])
    let l:cxx = planet#integrations#Tool(l:pair[1])
    if len(l:cc) != 1 || len(l:cxx) != 1
      return s:Error('compiler environment values must be single executable paths')
    endif
    let $CC = l:cc[0]
    let $CXX = l:cxx[0]
    if exists('l:prefix')
      let $CROSS_COMPILE = l:prefix
    endif
    echomsg 'Compiler selected for new build configurations: CC=' .. $CC .. ', CXX=' .. $CXX
    return 1
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! planet#integrations#Write(kind, filename = v:null, value = v:null) abort
  let l:root = planet#run#Project().root
  let l:default = l:root .. '/' .. (a:kind ==# 'qt-conf' ? 'qt.conf' : 'autogen.sh')
  let l:file = a:filename is v:null ? inputdialog('New configuration file: ', l:default, '') : a:filename
  if empty(l:file)
    return 0
  endif
  let l:file = planet#run#Path(l:file, l:root)
  if getftype(l:file) !=# ''
    return s:Error('file already exists; open it to edit: ' .. l:file)
  endif
  if a:kind ==# 'qt-conf'
    let l:prefix = a:value is v:null ? inputdialog('Qt installation prefix (relative to executable or absolute): ', $QTDIR, '') : a:value
    if empty(l:prefix)
      return 0
    endif
    let l:lines = ['[Paths]', 'Prefix=' .. l:prefix]
  elseif a:kind ==# 'autogen'
    let l:lines = ['#!/bin/sh', 'set -eu', 'cd -- "$(dirname -- "$0")"', 'exec autoreconf --force --install "$@"']
  else
    return s:Error('unknown configuration kind: ' .. a:kind)
  endif
  call writefile(l:lines, l:file)
  if a:kind ==# 'autogen' && ! has('win32')
    call setfperm(l:file, 'rwxr-xr-x')
  endif
  execute 'edit ' .. fnameescape(l:file)
  return 1
endfunc

func! planet#integrations#Browse(path) abort
  let l:path = a:path
  if a:path ==# '/proc/PID'
    let l:pid = inputdialog('Process ID: ', '', '')
    if l:pid !~# '^\d\+$'
      return 0
    endif
    let l:path = '/proc/' .. l:pid
  endif
  if ! isdirectory(l:path)
    return s:Error('directory unavailable: ' .. l:path)
  endif
  execute 'Fern ' .. fnameescape(l:path)
  return 1
endfunc

func! planet#integrations#XDisplay(action, value = v:null) abort
  if has('win32')
    return s:Error('Xvfb actions require a Linux X server host')
  endif
  let l:display = a:value is v:null ? inputdialog('X display: ', empty($DISPLAY) ? ':80' : $DISPLAY, '') : a:value
  if l:display !~# '^:\d\+\%(\.\d\+\)\?$'
    return empty(l:display) ? 0 : s:Error('use a local display such as :80')
  endif
  if a:action ==# 'set'
    let $DISPLAY = l:display
    return 1
  elseif a:action ==# 'stop'
    if ! has_key(s:display_jobs, l:display)
      return s:Error('no PlanetVim-owned Xvfb job for ' .. l:display)
    endif
    return planet#term#Cancel(s:display_jobs[l:display])
  elseif a:action ==# 'start'
    if has_key(s:display_jobs, l:display) && get(planet#term#Result(s:display_jobs[l:display]), 'status', '') ==# 'running'
      return s:Error('PlanetVim already started ' .. l:display)
    endif
    let l:buffer = planet#integrations#Command(['Xvfb', l:display, '-screen', '0', '1280x900x24', '-nolisten', 'tcp'],
          \ #{hidden: v:true, on_exit: function('s:DisplayExited', [l:display])})
    if l:buffer > 0
      let s:display_jobs[l:display] = l:buffer
    endif
    return l:buffer
  endif
  return s:Error('unknown X display action')
endfunc

func! s:DisplayExited(display, result, buffer) abort
  if get(s:display_jobs, a:display, 0) == a:buffer
    call remove(s:display_jobs, a:display)
  endif
endfunc

func! s:Helper() abort
  return planet#generate#Python() + [s:runtime .. '/bin/integration-tool.py']
endfunc

func! s:EnvironmentReady(filename, result, buffer) abort
  try
    if a:result.status !=# 'success' || ! filereadable(a:filename)
      return
    endif
    let l:new = json_decode(join(readfile(a:filename), "\n"))
    let l:previous = {}
    let l:applied = {}
    for l:key in uniq(sort(keys(environ()) + keys(l:new)))
      let l:value = get(l:new, l:key, v:null)
      if l:key =~# '^\h\w*$' && (type(l:value) == v:t_string || l:value is v:null)
            \ && index(['HOME', 'CODEX_HOME', 'USERPROFILE', 'PWD', 'OLDPWD', 'SHLVL', '_'], l:key) < 0
            \ && getenv(l:key) !=# l:value
        let l:previous[l:key] = getenv(l:key)
        let l:applied[l:key] = l:value
        call setenv(l:key, l:value)
      endif
    endfor
    call add(s:environment_stack, #{previous: l:previous, applied: l:applied})
    echomsg 'PlanetVim: SDK environment applied to this GVim and subsequent tool jobs.'
  finally
    call delete(a:filename)
  endtry
endfunc

func! planet#integrations#RestoreEnvironment() abort
  if empty(s:environment_stack)
    return s:Error('no SDK environment activated by PlanetVim in this GVim')
  endif
  let l:entry = remove(s:environment_stack, -1)
  for [l:key, l:previous] in items(l:entry.previous)
    " Keep values the user changed after activation.
    if getenv(l:key) ==# l:entry.applied[l:key]
      call setenv(l:key, l:previous)
    endif
  endfor
  return 1
endfunc

func! planet#integrations#Environment(kind, filename = v:null, arguments = [], options = {}) abort
  let l:defaults = #{ros2: planet#run#Project().root .. '/install/setup.' .. (has('win32') ? 'bat' : 'bash'),
        \ yocto: planet#run#Project().root .. '/oe-init-build-env',
        \ emsdk: $EMSDK .. '/emsdk_env.' .. (has('win32') ? 'bat' : 'sh'),
        \ platformio: expand('~/.platformio/penv/') .. (has('win32') ? 'Scripts/activate.bat' : 'bin/activate')}
  let l:file = a:filename is v:null ? inputdialog('SDK setup script to execute: ', get(l:defaults, a:kind, ''), '') : a:filename
  if empty(l:file)
    return 0
  endif
  if ! filereadable(l:file)
    return s:Error('SDK setup script not found: ' .. l:file .. '. Install/select the SDK first.')
  endif
  let l:result = tempname() .. '.json'
  return planet#term#RunArgv(s:Helper() + ['source-env', l:result, fnamemodify(l:file, ':p')] + a:arguments,
        \ v:false, v:false, get(a:options, 'hidden', v:false), planet#run#Project().root,
        \ function('s:EnvironmentReady', [l:result]))
endfunc

func! planet#integrations#Conda(name = v:null) abort
  let l:name = a:name is v:null ? inputdialog('Conda environment name: ', 'base', '') : a:name
  if empty(l:name)
    return 0
  endif
  try
    let l:conda = planet#integrations#Tool('conda')
    if len(l:conda) != 1
      return s:Error('Conda activation requires a single native conda executable')
    endif
    let l:result = tempname() .. '.json'
    return planet#term#RunArgv(s:Helper() + ['conda-env', l:result, l:conda[0], l:name],
          \ v:false, v:false, v:false, planet#run#Project().root,
          \ function('s:EnvironmentReady', [l:result]))
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! planet#integrations#ExportRequirements(dev = v:false, filename = v:null) abort
  let l:default = planet#run#Project().root .. '/' .. (a:dev ? 'dev-requirements.txt' : 'requirements.txt')
  let l:file = a:filename is v:null ? inputdialog('New requirements file: ', l:default, '') : a:filename
  if empty(l:file)
    return 0
  endif
  try
    let l:command = planet#integrations#Tool('pipenv') + ['requirements'] + (a:dev ? ['--dev-only'] : [])
    return planet#term#RunArgv(s:Helper() + ['capture', l:file] + l:command,
          \ v:false, v:false, v:false, planet#run#Project().root)
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! planet#integrations#ConfigureValue(name, value = v:null) abort
  let l:values = get(t:, 'PV_configure_values', {})
  let l:value = a:value is v:null ? inputdialog('Configure ' .. a:name .. ': ', get(l:values, a:name, ''), '') : a:value
  if empty(l:value)
    return 0
  endif
  if a:name ==# 'sysroot' && ! isdirectory(l:value)
    return s:Error('sysroot directory does not exist')
  endif
  let l:values[a:name] = l:value
  let t:PV_configure_values = l:values
  if a:name ==# 'sysroot'
    let $SYSROOT = fnamemodify(l:value, ':p')
  endif
  echomsg 'PlanetVim: saved for this project configure action: ' .. a:name .. '=' .. l:value
  return 1
endfunc

func! planet#integrations#Configure(arguments = v:null) abort
  let l:args = copy(a:arguments is v:null ? get(t:, 'PV_configure_arguments', []) : a:arguments)
  let l:values = get(t:, 'PV_configure_values', {})
  for l:key in ['build', 'host', 'target']
    if has_key(l:values, l:key)
      let l:args += ['--' .. l:key .. '=' .. l:values[l:key]]
    endif
  endfor
  if has_key(l:values, 'sysroot')
    let l:flag = shellescape('--sysroot=' .. l:values.sysroot)
    let l:args += ['CFLAGS=' .. $CFLAGS .. ' ' .. l:flag, 'CXXFLAGS=' .. $CXXFLAGS .. ' ' .. l:flag]
  endif
  return planet#integrations#Command([planet#run#Project().root .. '/configure'] + l:args)
endfunc

func! planet#integrations#CmakeConfigure(export_compile_commands = v:false) abort
  let l:sysroot = get(get(t:, 'PV_configure_values', {}), 'sysroot', '')
  if empty(l:sysroot)
    return planet#build#Configure(a:export_compile_commands)
  endif
  let l:build = planet#build#GetBuildDir(v:true)
  if empty(l:build) | return 0 | endif
  let l:argv = ['cmake', '-S', planet#run#Project().root, '-B', l:build, '-DCMAKE_SYSROOT=' .. l:sysroot]
  if a:export_compile_commands | call add(l:argv, '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON') | endif
  return planet#integrations#Command(l:argv)
endfunc

func! planet#integrations#ConfigureOptions(value = v:null) abort
  let l:value = a:value is v:null ? inputdialog('Configure arguments (JSON array): ', json_encode(get(t:, 'PV_configure_arguments', [])), '') : a:value
  if empty(l:value)
    return 0
  endif
  try
    let l:args = type(l:value) == v:t_list ? l:value : json_decode(l:value)
    if type(l:args) != v:t_list || ! empty(filter(copy(l:args), {_, arg -> type(arg) != v:t_string}))
      return s:Error('configure arguments must be a JSON array of Strings')
    endif
    let t:PV_configure_arguments = l:args
    return 1
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! planet#integrations#Flutter(kind, value = v:null) abort
  let l:value = a:value is v:null ? inputdialog(a:kind ==# 'sdk' ? 'Android SDK directory: ' : 'New Flutter project directory: ', '', '') : a:value
  if empty(l:value)
    return 0
  endif
  let l:path = planet#run#Path(l:value, planet#run#Project().root)
  if a:kind ==# 'sdk' && ! isdirectory(l:path)
    return s:Error('Android SDK directory does not exist: ' .. l:path)
  elseif a:kind ==# 'create' && getftype(l:path) !=# ''
    return s:Error('choose a new Flutter project directory')
  endif
  return planet#integrations#Command(a:kind ==# 'sdk' ? ['flutter', 'config', '--android-sdk', l:path] : ['flutter', 'create', l:path])
endfunc

func! planet#integrations#Emsdk(action, directory = v:null, version = v:null) abort
  let l:dir = a:directory is v:null ? inputdialog('Existing emsdk checkout directory: ', $EMSDK, '') : a:directory
  if empty(l:dir)
    return 0
  endif
  let l:script = l:dir .. '/emsdk.py'
  if ! filereadable(l:script)
    return s:Error('emsdk.py was not found; clone https://github.com/emscripten-core/emsdk and select its directory')
  endif
  if a:action ==# 'update'
    return planet#integrations#Command(['git', '-C', l:dir, 'pull', '--ff-only'])
  endif
  let l:version = a:version is v:null ? inputdialog('Emscripten SDK version: ', 'latest', '') : a:version
  if empty(l:version)
    return 0
  endif
  let l:Callback = a:action ==# 'activate' ? function('s:EmsdkActivated', [l:dir]) : v:null
  return planet#term#RunArgv(planet#generate#Python() + [l:script, a:action, l:version],
        \ v:false, v:false, v:false, l:dir, l:Callback)
endfunc

func! s:EmsdkActivated(directory, result, buffer) abort
  if a:result.status ==# 'success'
    call planet#integrations#Environment('emsdk', a:directory .. '/emsdk_env.' .. (has('win32') ? 'bat' : 'sh'))
  endif
endfunc

func! planet#integrations#Trace() abort
  echomsg 'PlanetVim: choose Open trace file in Perfetto to view a local Chrome Trace JSON file.'
  return planet#gui#OpenUrl('https://ui.perfetto.dev/')
endfunc

func! planet#integrations#Tags(kind, filename = v:null) abort
  let l:root = planet#run#Project().root
  let l:tags = l:root .. '/tags'
  if ! filereadable(l:tags)
    return s:Error('build the project tags file first')
  endif
  let l:file = a:filename is v:null ? inputdialog('New syntax file: ', l:root .. '/' .. a:kind .. '.vim', '') : a:filename
  if empty(l:file) | return 0 | endif
  if getftype(l:file) !=# '' | return s:Error('syntax file already exists: ' .. l:file) | endif
  let l:words = []
  for l:line in readfile(l:tags)
    let l:fields = split(l:line, "\t")
    if len(l:fields) < 2 || l:fields[0] !~# '^\h\w*$' | continue | endif
    if a:kind ==# 'types' && empty(filter(copy(l:fields[3:]), {_, v -> v =~# '^\%(kind:\)\?\%(c\|g\|s\|t\|u\|class\|enum\|struct\|typedef\|union\)$'}))
      continue
    endif
    call add(l:words, l:fields[0])
  endfor
  let l:words = uniq(sort(l:words))
  let l:lines = ['" Generated from the project tags file by PlanetVim.']
  while ! empty(l:words)
    call add(l:lines, 'syntax keyword ' .. (a:kind ==# 'types' ? 'Type ' : 'Tag ') .. join(remove(l:words, 0, min([49, len(l:words) - 1])), ' '))
  endwhile
  call writefile(l:lines, l:file)
  execute 'edit ' .. fnameescape(l:file)
  return 1
endfunc

func! planet#integrations#QtInstall(target, modules = v:false) abort
  let l:version = inputdialog('Qt version: ', '6.2.3', '')
  if empty(l:version) | return 0 | endif
  let l:host = has('win32') ? 'windows' : 'linux'
  let l:architecture = inputdialog('Qt architecture: ', a:target ==# 'android' ? 'android_arm64_v8a'
        \ : a:target ==# 'wasm' ? 'wasm_32' : has('win32') ? 'win64_msvc2019_64' : 'gcc_64', '')
  if empty(l:architecture) | return 0 | endif
  let l:directory = inputdialog('Qt installation directory: ', empty($QTDIR) ? expand('~/Qt') : fnamemodify($QTDIR, ':h:h'), '')
  if empty(l:directory) | return 0 | endif
  let l:argv = ['aqt', 'install-qt', l:host, a:target ==# 'android' ? 'android' : 'desktop',
        \ l:version, l:architecture, '--outputdir', l:directory]
  if a:modules | let l:argv += ['--modules', 'all'] | endif
  return planet#integrations#Command(l:argv)
endfunc

func! planet#integrations#QmakeDestdir(value = v:null) abort
  let l:value = a:value is v:null ? inputdialog('QMake DESTDIR: ', planet#run#Project().root .. '/bin', '') : a:value
  if empty(l:value) | return 0 | endif
  return planet#integrations#Command(['qmake', 'DESTDIR=' .. planet#run#Path(l:value, planet#run#Project().root)], #{qt:v:true})
endfunc

func! planet#integrations#AndroidCmake(abi, ndk = v:null, api = v:null) abort
  let l:ndk = a:ndk is v:null ? inputdialog('Android NDK directory: ', empty($ANDROID_NDK_HOME) ? $ANDROID_NDK : $ANDROID_NDK_HOME, '') : a:ndk
  if empty(l:ndk) | return 0 | endif
  let l:toolchain = l:ndk .. '/build/cmake/android.toolchain.cmake'
  if ! filereadable(l:toolchain) | return s:Error('NDK toolchain was not found: ' .. l:toolchain) | endif
  let l:api = a:api is v:null ? inputdialog('Android API level: ', '23', '') : a:api
  if l:api !~# '^\d\+$' | return empty(l:api) ? 0 : s:Error('API level must be numeric') | endif
  let l:build = planet#build#GetBuildDir(v:true)
  if empty(l:build) | return 0 | endif
  return planet#integrations#Command(['cmake', '-S', planet#run#Project().root, '-B', l:build,
        \ '-DCMAKE_TOOLCHAIN_FILE=' .. l:toolchain, '-DANDROID_ABI=' .. a:abi,
        \ '-DANDROID_PLATFORM=android-' .. l:api, '-DCMAKE_BUILD_TYPE=Release'])
endfunc

func! planet#integrations#AutotoolsStatus() abort
  let l:lines = ['Autotools executables available to this GVim:']
  for l:name in ['autoconf', 'automake', 'autoreconf', 'autoheader', 'libtool', 'libtoolize']
    call add(l:lines, l:name .. ': ' .. (executable(l:name) ? exepath(l:name) : 'missing; install the corresponding Autotools package'))
  endfor
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, l:lines)
  setlocal nomodifiable
  return 1
endfunc
