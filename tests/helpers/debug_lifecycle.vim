" Runs only in the real GUI suite. Both adapters must be installed separately.
runtime plugin/development.vim
execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/debug_prerequisites.vim')
if !PlanetDebugTestAvailable(g:PV_debug_test_language)
  finish
endif
let s:root = g:PV_test_dir .. '/debug lifecycle'
call mkdir(s:root, 'p')
execute 'tcd ' .. fnameescape(s:root)
let s:python = g:PV_debug_test_language ==# 'python'
let s:source = s:root .. '/debug_sample.' .. (s:python ? 'py' : 'cpp')
call writefile(readfile(g:PV_root .. '/tests/fixtures/development/debug_sample.' .. (s:python ? 'py' : 'cpp')), s:source)

func! s:Wait(condition, message) abort
  for l:i in range(1200)
    if eval(a:condition)
      return 1
    endif
    sleep 10m
  endfor
  let l:log = planet#paths#State('debugger') .. '/vimspector.log'
  call assert_report(a:message .. (filereadable(l:log) ? "\n" .. join(readfile(l:log)[-30:], "\n") : '') .. "\n" .. execute('messages'))
  return 0
endfunc

func! s:FrameLine() abort
  return py3eval("(_vimspector_session._stackTraceView.GetCurrentFrame() or {}).get('line', 0) if '_vimspector_session' in globals() and _vimspector_session and _vimspector_session._stackTraceView else 0")
endfunc

func! s:Connected() abort
  return py3eval("'_vimspector_session' in globals() and _vimspector_session is not None and _vimspector_session._connection is not None")
endfunc

func! s:Exited() abort
  let l:log = planet#paths#State('debugger') .. '/vimspector.log'
  return filereadable(l:log) && match(readfile(l:log), "'event': 'exited'.*'exitCode': 0") >= 0
endfunc

try
  if !s:python
    call assert_true(executable('g++'), 'C++ fixture requires g++')
    let s:executable = s:root .. '/debug app'
    let s:compile = planet#term#RunArgv(['g++', '-g', '-O0', s:source, '-o', s:executable], v:false, v:false, v:false, s:root)
    call s:Wait("planet#term#Result(s:compile).status !=# 'running'", 'fixture compilation timed out')
    call assert_equal('success', planet#term#Result(s:compile).status)
    execute 'bwipeout! ' .. s:compile
  endif
  let s:config = planet#debug#Configuration(g:PV_debug_test_language, s:python ? s:source : s:executable)
  let s:name = s:python ? 'Python' : 'C++'
  if s:python
    let s:config.configurations.Python.configuration.console = 'internalConsole'
  else
    let s:config.configurations['C++'].configuration.stopAtBeginningOfMainSubprogram = v:false
  endif
  call writefile([json_encode(s:config)], s:root .. '/.vimspector.json')
  execute 'edit ' .. fnameescape(s:source)
  let s:original_window = win_getid()
  let s:breakline = s:python ? 2 : 5
  call cursor(s:breakline, 1)
  call assert_equal(1, planet#debug#Action('breakpoint'))
  call assert_equal(1, planet#debug#Action('launch', s:name))
  if s:Wait('s:FrameLine() == s:breakline', 'initial launch did not reach breakpoint')
    if get(g:, 'PV_debug_test_disassembly', 0)
      call assert_equal(1, planet#debug#Action('disassembly'))
      call s:Wait('py3eval("bool(_vimspector_session._disassemblyView and _vimspector_session._disassemblyView.current_instructions)")', 'GDB did not return disassembly')
      let s:pc = py3eval('_vimspector_session._stackTraceView.GetCurrentFrame()["instructionPointerReference"]')
      call assert_equal(1, planet#debug#Action('instruction-into'))
      call s:Wait('py3eval("(_vimspector_session._stackTraceView.GetCurrentFrame() or {}).get(''instructionPointerReference'', '''')") !=# s:pc && !empty(py3eval("_vimspector_session._stackTraceView.GetCurrentFrame()"))', 'instruction step did not advance the program counter')
      call assert_equal(1, planet#debug#Action('restart'))
      call s:Wait('s:FrameLine() == s:breakline', 'restart after instruction step did not reach breakpoint')
    endif
    call assert_equal(1, planet#debug#Action('step-over'))
    call s:Wait('s:FrameLine() == s:breakline + 1', 'step-over did not advance one source line')
    call assert_equal(1, planet#debug#Action('restart'))
    call s:Wait('s:FrameLine() == s:breakline', 'restart did not reach existing breakpoint')
    call assert_equal(1, planet#debug#Action('stop'))
    call s:Wait('!s:Connected()', 'stop did not disconnect')
    call assert_equal(1, planet#debug#Action('reset'))
    call s:Wait("!py3eval('_vimspector_session.HasUI()')", 'reset did not close debugger UI')
    call win_gotoid(s:original_window)
    call assert_equal(1, planet#debug#Action('launch', s:name))
    call s:Wait('s:FrameLine() == s:breakline', 'second launch did not retain breakpoint')
    call assert_equal(1, planet#debug#Action('continue'))
    call s:Wait('s:Exited()', 'continue did not finish the fixture with status zero')
  endif
finally
  if exists('g:loaded_vimpector')
    call planet#debug#Action('reset')
    call s:Wait('!s:Connected()', 'final cleanup failed')
  endif
endtry
