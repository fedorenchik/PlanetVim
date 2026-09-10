vim9script

var script_last_error = ''

export def LastError(): any
  return script_last_error
enddef

def LocalTool(name: any, arg_options: any): any
  var options: any = copy(arg_options)
  if !has_key(options, 'tool')
    options.tool = get(get(g:, 'PV_test_tools', {}), name, [name])
  endif
  return planet#debugtools#Tool(name, options)
enddef

def LocalCapture(id: any, options: any): any
  var display: any
  var duration: any
  var input: any
  var extension: any = id ==# 'screenshot' ? 'png' : id ==# 'record-gif' ? 'gif' : 'mp4'
  var output: any = has_key(options, 'output') ? options.output : browse(1, 'Save ' .. id, getcwd(), 'report.' .. extension)
  if empty(output)
    throw 'PlanetVim: capture cancelled'
  endif
  var argv: any = LocalTool('ffmpeg', options) + ['-hide_banner', get(options, 'overwrite', 0) ? '-y' : '-n']
  if has('win32')
    argv += ['-f', 'gdigrab', '-framerate', '15', '-i', 'desktop']
  else
    display = get(options, 'display', $DISPLAY)
    if empty(display)
      throw 'PlanetVim: screen capture needs an X11 display; use a portal-enabled recorder on Wayland'
    endif
    argv += ['-f', 'x11grab', '-framerate', '15', '-i', display]
  endif
  if id ==# 'screenshot'
    argv += ['-frames:v', '1']
  else
    duration = planet#debugtools#Value(options, 'duration', 'Recording duration in seconds:', '10')
    if duration !~# '^\d\+$' || str2nr(duration) < 1
      throw 'PlanetVim: recording duration must be a positive number of seconds'
    endif
    # Bound the input as well: GIF palette generation waits for input EOF.
    input = index(argv, '-i')
    argv = argv[ : input - 1] + ['-t', duration] + argv[input : ]
    if id ==# 'record-gif'
      argv += ['-vf', 'fps=10,scale=960:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse']
    else
      argv += ['-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2']
    endif
  endif
  return argv + [fnamemodify(output, ':p')]
enddef

export def Run(id: any, options: any = {}): any
  var root: any
  var program: any
  var argv: any
  var report: any
  var build: any
  var script: any
  var python: any
  var targets: any
  var extra: any
  var buffer: any
  script_last_error = ''
  try
    root = get(options, 'cwd', planet#run#Project().root)
    if !isdirectory(root)
      throw 'PlanetVim: test working directory does not exist'
    endif
    if index(['qt', 'google', 'boost', 'catch2'], id) >= 0
      program = planet#debugtools#Value(options, 'program', 'Built ' .. id .. ' test executable:')
      argv = LocalTool(program, options)
      report = get(options, 'report', planet#paths#State('test-reports') .. '/' .. id .. '-' .. sha256(tempname())[ : 15] .. '.xml')
      if id ==# 'qt'
        argv += ['-o', '-,txt', '-o', report .. ',junitxml']
      elseif id ==# 'google'
        argv += ['--gtest_output=xml:' .. report]
      elseif id ==# 'boost'
        argv += ['--report_format=XML', '--report_sink=' .. report, '--report_level=detailed']
      else
        argv += ['--reporter', 'junit', '--out', report]
      endif
    elseif index(['ctest', 'cdash'], id) >= 0
      build = get(options, 'build', planet#build#GetBuildDir())
      if empty(build) || !isdirectory(build)
        build = planet#debugtools#Value(options, 'build', 'Configured CMake build directory:', root .. '/build')
      endif
      if !isdirectory(build)
        throw 'PlanetVim: configure the CMake build directory first'
      endif
      root = build
      argv = LocalTool('ctest', options) + ['--output-on-failure']
      if id ==# 'cdash'
        if !filereadable(build .. '/DartConfiguration.tcl')
          throw 'PlanetVim: enable include(CTest), configure CTestConfig.cmake with the CDash destination, then configure the project'
        endif
        # Explicitly selected stages avoid an implicit source-control update.
        argv += ['-D', 'ExperimentalStart', '-D', 'ExperimentalTest', '-D', 'ExperimentalSubmit']
      endif
    elseif index(['screenshot', 'record-gif', 'record-screen'], id) >= 0
      argv = LocalCapture(id, options)
    elseif id ==# 'kunit'
      script = root .. '/tools/testing/kunit/kunit.py'
      if !filereadable(script)
        throw 'PlanetVim: select a Linux kernel source checkout containing tools/testing/kunit/kunit.py'
      endif
      python = executable('python3') ? 'python3' : 'python'
      argv = LocalTool(python, options) + [script, 'run', '--build_dir=' .. get(options, 'build', root .. '/.kunit'), '--timeout=60']
      if has_key(options, 'filter') && !empty(options.filter)
        add(argv, options.filter)
      endif
    elseif id ==# 'kselftest'
      if !filereadable(root .. '/tools/testing/selftests/Makefile')
        throw 'PlanetVim: select a Linux kernel checkout containing tools/testing/selftests/Makefile'
      endif
      targets = planet#debugtools#Value(options, 'targets', 'Kernel selftest target directories (space separated):', 'timers')
      if targets !~# '^[-a-zA-Z0-9_/ ]\+$'
        throw 'PlanetVim: invalid selftest target list'
      endif
      argv = LocalTool('make', options) + ['-C', root .. '/tools/testing/selftests', 'TARGETS=' .. targets, 'run_tests']
    else
      throw 'PlanetVim: unknown test tool ' .. id
    endif
    extra = get(options, 'args', [])
    if type(extra) != v:t_list || !empty(filter(copy(extra), (_, value) => type(value) != v:t_string))
      throw 'PlanetVim: additional test arguments must be an argv list'
    endif
    buffer = planet#term#RunArgv(argv + extra, v:false, v:false, v:false, root)
    if buffer > 0 && !empty(report)
      setbufvar(buffer, 'PV_test_report', report)
      echom 'PlanetVim: test report: ' .. report
    endif
    return buffer
  catch
    script_last_error = v:exception
    echom script_last_error
    return 0
  endtry
enddef
