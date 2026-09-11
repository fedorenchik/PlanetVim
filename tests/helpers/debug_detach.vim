runtime plugin/development.vim
execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/debug_prerequisites.vim')
if !PlanetDebugTestAvailable(g:PV_debug_test_language)
  finish
endif
let s:root = g:PV_test_dir .. '/debug detach'
call mkdir(s:root, 'p')
execute 'tcd ' .. fnameescape(s:root)
let s:python = g:PV_debug_test_language ==# 'python'
let s:source = s:root .. '/detached.' .. (s:python ? 'py' : 'cpp')
let s:marker = s:root .. '/continued.txt'
if s:python
  call writefile(['from pathlib import Path', 'import time', 'time.sleep(0.2)', 'Path(__file__).with_name("continued.txt").write_text("continued after detach", encoding="utf-8")'], s:source)
else
  call writefile(['#include <fstream>', '#include <thread>', '#include <chrono>', 'int main() {', '  std::this_thread::sleep_for(std::chrono::milliseconds(1000));', '  std::ofstream("continued.txt") << "continued after detach";', '  return 0;', '}'], s:source)
endif
let s:breakline = s:python ? 3 : 5

func! s:Wait(condition, message) abort
  for l:i in range(1200)
    if eval(a:condition)
      return 1
    endif
    sleep 10m
  endfor
  let l:log = planet#paths#State('debugger') .. '/vimspector.log'
  call assert_report(a:message .. "\n" .. execute('messages') .. (filereadable(l:log) ? "\n" .. join(readfile(l:log)[-35:], "\n") : ''))
  return 0
endfunc

func! s:Stopped() abort
  return py3eval("(_vimspector_session._stackTraceView.GetCurrentFrame() or {}).get('line', 0) if '_vimspector_session' in globals() and _vimspector_session and _vimspector_session._stackTraceView else 0") == s:breakline
endfunc

func! s:Disconnected() abort
  return py3eval("'_vimspector_session' in globals() and _vimspector_session and _vimspector_session._connection is None")
endfunc

func! s:Running() abort
  return py3eval("any(thread.State() == 'running' for state in _vimspector_session._stackTraceView._sessions if state.session is _vimspector_session for thread in state.threads)")
endfunc

try
  if !s:python
    let s:executable = s:root .. '/detached-app'
    let s:compile = planet#term#RunArgv(['g++', '-g', '-O0', s:source, '-o', s:executable], v:false, v:false, v:true, s:root)
    call s:Wait("planet#term#Result(s:compile).status !=# 'running'", 'detach fixture compilation timed out')
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
  call cursor(s:breakline, 1)
  call assert_equal(1, planet#debug#Action('breakpoint'))
  call assert_equal(1, planet#debug#Action('launch', s:name))
  if s:Wait('s:Stopped()', 'debug fixture did not stop before its marker write')
    call assert_false(filereadable(s:marker), 'breakpoint must prevent marker write before detach')
    if get(g:, 'PV_debug_test_running', v:false)
      call assert_equal(1, planet#debug#Action('continue'))
      call s:Wait('s:Running()', 'GDB fixture did not resume before detach')
      call assert_false(filereadable(s:marker), 'running fixture must still be alive before detach')
    endif
    call assert_equal(1, planet#debug#Action('detach'))
    call s:Wait("get(get(g:, 'PV_debug_detach_result', {}), 'status', '') ==# 'success'", 'disconnect was not acknowledged: ' .. string(get(g:, 'PV_debug_detach_result', {})))
    call s:Wait('s:Disconnected()', 'adapter did not disconnect after acknowledgement')
    if s:Wait('filereadable(s:marker)', 'debuggee was terminated instead of continuing after detach')
      call assert_equal(['continued after detach'], readfile(s:marker))
    endif
  endif
finally
  if exists('g:loaded_vimpector')
    call planet#debug#Action('reset')
    call s:Wait('s:Disconnected()', 'detach fixture cleanup did not finish')
  endif
endtry
