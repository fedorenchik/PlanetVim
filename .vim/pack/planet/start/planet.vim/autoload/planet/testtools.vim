scriptversion 4

let s:last_error = ''

func! planet#testtools#LastError() abort
  return s:last_error
endfunc

func! s:Tool(name, options) abort
  let l:options = copy(a:options)
  if !has_key(l:options, 'tool')
    let l:options.tool = get(get(g:, 'PV_test_tools', {}), a:name, [a:name])
  endif
  return planet#debugtools#Tool(a:name, l:options)
endfunc

func! s:Capture(id, options) abort
  let l:extension = a:id ==# 'screenshot' ? 'png' : a:id ==# 'record-gif' ? 'gif' : 'mp4'
  let l:output = has_key(a:options, 'output') ? a:options.output
        \ : browse(1, 'Save ' .. a:id, getcwd(), 'report.' .. l:extension)
  if empty(l:output) | throw 'PlanetVim: capture cancelled' | endif
  let l:argv = s:Tool('ffmpeg', a:options) + ['-hide_banner', get(a:options, 'overwrite', 0) ? '-y' : '-n']
  if has('win32')
    let l:argv += ['-f', 'gdigrab', '-framerate', '15', '-i', 'desktop']
  else
    let l:display = get(a:options, 'display', $DISPLAY)
    if empty(l:display) | throw 'PlanetVim: screen capture needs an X11 display; use a portal-enabled recorder on Wayland' | endif
    let l:argv += ['-f', 'x11grab', '-framerate', '15', '-i', l:display]
  endif
  if a:id ==# 'screenshot'
    let l:argv += ['-frames:v', '1']
  else
    let l:duration = planet#debugtools#Value(a:options, 'duration', 'Recording duration in seconds:', '10')
    if l:duration !~# '^\d\+$' || str2nr(l:duration) < 1
      throw 'PlanetVim: recording duration must be a positive number of seconds'
    endif
    " Bound the input as well: GIF palette generation waits for input EOF.
    let l:input = index(l:argv, '-i')
    let l:argv = l:argv[:l:input - 1] + ['-t', l:duration] + l:argv[l:input:]
    if a:id ==# 'record-gif'
      let l:argv += ['-vf', 'fps=10,scale=960:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse']
    else
      let l:argv += ['-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2']
    endif
  endif
  return l:argv + [fnamemodify(l:output, ':p')]
endfunc

func! planet#testtools#Run(id, options = {}) abort
  let s:last_error = ''
  try
    let l:root = get(a:options, 'cwd', planet#run#Project().root)
    if !isdirectory(l:root) | throw 'PlanetVim: test working directory does not exist' | endif
    if index(['qt', 'google', 'boost', 'catch2'], a:id) >= 0
      let l:program = planet#debugtools#Value(a:options, 'program', 'Built ' .. a:id .. ' test executable:')
      let l:argv = s:Tool(l:program, a:options)
      let l:report = get(a:options, 'report', planet#paths#State('test-reports') .. '/' .. a:id .. '-' .. sha256(tempname())[:15] .. '.xml')
      if a:id ==# 'qt'
        let l:argv += ['-o', '-,txt', '-o', l:report .. ',junitxml']
      elseif a:id ==# 'google'
        let l:argv += ['--gtest_output=xml:' .. l:report]
      elseif a:id ==# 'boost'
        let l:argv += ['--report_format=XML', '--report_sink=' .. l:report, '--report_level=detailed']
      else
        let l:argv += ['--reporter', 'junit', '--out', l:report]
      endif
    elseif index(['ctest', 'cdash'], a:id) >= 0
      let l:build = get(a:options, 'build', planet#build#GetBuildDir())
      if empty(l:build) || !isdirectory(l:build)
        let l:build = planet#debugtools#Value(a:options, 'build', 'Configured CMake build directory:', l:root .. '/build')
      endif
      if !isdirectory(l:build) | throw 'PlanetVim: configure the CMake build directory first' | endif
      let l:root = l:build
      let l:argv = s:Tool('ctest', a:options) + ['--output-on-failure']
      if a:id ==# 'cdash'
        if !filereadable(l:build .. '/DartConfiguration.tcl')
          throw 'PlanetVim: enable include(CTest), configure CTestConfig.cmake with the CDash destination, then configure the project'
        endif
        " Explicitly selected stages avoid an implicit source-control update.
        let l:argv += ['-D', 'ExperimentalStart', '-D', 'ExperimentalTest', '-D', 'ExperimentalSubmit']
      endif
    elseif index(['screenshot', 'record-gif', 'record-screen'], a:id) >= 0
      let l:argv = s:Capture(a:id, a:options)
    elseif a:id ==# 'kunit'
      let l:script = l:root .. '/tools/testing/kunit/kunit.py'
      if !filereadable(l:script) | throw 'PlanetVim: select a Linux kernel source checkout containing tools/testing/kunit/kunit.py' | endif
      let l:python = executable('python3') ? 'python3' : 'python'
      let l:argv = s:Tool(l:python, a:options) + [l:script, 'run',
            \ '--build_dir=' .. get(a:options, 'build', l:root .. '/.kunit'), '--timeout=60']
      if has_key(a:options, 'filter') && !empty(a:options.filter) | call add(l:argv, a:options.filter) | endif
    elseif a:id ==# 'kselftest'
      if !filereadable(l:root .. '/tools/testing/selftests/Makefile')
        throw 'PlanetVim: select a Linux kernel checkout containing tools/testing/selftests/Makefile'
      endif
      let l:targets = planet#debugtools#Value(a:options, 'targets', 'Kernel selftest target directories (space separated):', 'timers')
      if l:targets !~# '^[-a-zA-Z0-9_/ ]\+$' | throw 'PlanetVim: invalid selftest target list' | endif
      let l:argv = s:Tool('make', a:options) + ['-C', l:root .. '/tools/testing/selftests', 'TARGETS=' .. l:targets, 'run_tests']
    else
      throw 'PlanetVim: unknown test tool ' .. a:id
    endif
    let l:extra = get(a:options, 'args', [])
    if type(l:extra) != v:t_list || !empty(filter(copy(l:extra), 'type(v:val) != v:t_string'))
      throw 'PlanetVim: additional test arguments must be an argv list'
    endif
    let l:buffer = planet#term#RunArgv(l:argv + l:extra, v:false, v:false, v:false, l:root)
    if l:buffer > 0 && exists('l:report')
      call setbufvar(l:buffer, 'PV_test_report', l:report)
      echom 'PlanetVim: test report: ' .. l:report
    endif
    return l:buffer
  catch
    let s:last_error = v:exception
    echom s:last_error
    return 0
  endtry
endfunc
