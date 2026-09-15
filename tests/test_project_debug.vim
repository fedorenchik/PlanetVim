runtime plugin/development.vim
execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/debug_prerequisites.vim')
if !PlanetDebugTestAvailable('cpp') || !PlanetDebugTestAvailable('python')
  finish
endif
set hidden
func! s:Wait(expression, label) abort
  for l:i in range(1800)
    if eval(a:expression) | return 1 | endif
    sleep 10m
  endfor
  let l:log = planet#paths#State('debugger') .. '/vimspector.log'
  call assert_report(a:label .. (filereadable(l:log) ? join(readfile(l:log)[-15:], "\n") : '') .. execute('messages'))
  return 0
endfunc
func! s:Connected() abort
  return py3eval("'_vimspector_session' in globals() and _vimspector_session is not None and _vimspector_session._connection is not None")
endfunc
func! s:Frame() abort
  return py3eval("bool(_vimspector_session._stackTraceView and _vimspector_session._stackTraceView.GetCurrentFrame())")
endfunc
let s:root = g:PV_test_dir .. '/selected debugger 工作'
call mkdir(s:root, 'p')
execute 'tcd ' .. fnameescape(s:root)
call writefile(['cmake_minimum_required(VERSION 3.20)', 'project(DebugTarget C)',
      \ 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/custom bin")', 'add_executable(selected main.c)'], s:root .. '/CMakeLists.txt')
call writefile(['#include <stdio.h>', '#include <stdlib.h>', 'int main(int argc, char **argv) {',
      \ 'FILE *f = fopen(argv[1], "w");', 'if (!f) return 2;',
      \ 'fprintf(f, "%s\n%s\n", getenv("PV_DEBUG_ENV"), argv[2]);', 'return fclose(f);', '}'], s:root .. '/main.c')
call writefile(['# preserved custom debugger settings'], s:root .. '/.vimspector.json')
let s:settings = {'defaults': {'hidden': v:true, 'build_type': 'Debug', 'environment': {'PV_DEBUG_ENV': 'selected'},
      \ 'args': [s:root .. '/cpp.txt', 'literal argument 工作']}}
call writefile([json_encode(s:settings)], planet#project#File())
execute 'edit ' .. fnameescape(s:root .. '/main.c')
try
  let s:id = planet#task#Start('build-debug')
  call s:Wait('planet#task#Status(s:id).status !=# "running"', 'debug build timed out')
  call assert_equal('success', planet#task#Status(s:id).status, string(get(planet#task#Status(s:id), 'error', '')))
  if s:Wait('s:Frame()', 'selected CMake program did not stop at main')
    call assert_equal(1, planet#debug#Action('continue'))
    call s:Wait('filereadable(s:root .. "/cpp.txt")', 'selected program did not run')
    call assert_equal(['selected', 'literal argument 工作'], readfile(s:root .. '/cpp.txt'))
  endif
  call planet#debug#Action('reset')
  call s:Wait('!s:Connected()', 'C++ debugger did not reset')
  let s:source = s:root .. '/python app.py'
  call writefile(['import os, pathlib, sys', 'pathlib.Path(sys.argv[1]).write_text(os.environ["PV_DEBUG_ENV"] + "\n" + sys.executable)'], s:source)
  let s:settings.defaults.program = s:source
  let s:settings.defaults.python = get(g:, 'PV_python', [exepath('python3')])
  let s:settings.defaults.args = [s:root .. '/python.txt']
  call writefile([json_encode(s:settings)], planet#project#File())
  execute 'edit ' .. fnameescape(s:source)
  let s:id = planet#task#Start('debug')
  call s:Wait('planet#task#Status(s:id).status !=# "running"', 'Python launch timed out')
  call assert_equal('success', planet#task#Status(s:id).status, string(get(planet#task#Status(s:id), 'error', '')))
  call s:Wait('filereadable(s:root .. "/python.txt")', 'project Python interpreter did not run')
  call assert_equal(['selected', s:settings.defaults.python[0]], readfile(s:root .. '/python.txt'))
  call assert_equal(['# preserved custom debugger settings'], readfile(s:root .. '/.vimspector.json'))
finally
  call planet#debug#Action('reset')
  call s:Wait('!s:Connected()', 'debugger did not reset')
endtry
