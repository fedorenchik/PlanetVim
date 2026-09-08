if !executable('gdb') || !executable('ctest') || !executable('cmake')
  throw 'Debugger/test integration requires gdb, ctest and cmake'
endif
set hidden
let s:init = g:PV_test_dir .. '/debugger init.gdb'
call writefile(['echo planet-debug-setup-loaded\n'], s:init)

func! s:Wait(buffer, status) abort
  for l:attempt in range(1000)
    if get(planet#term#Result(a:buffer), 'status', '') !=# 'running' | break | endif
    sleep 10m
  endfor
  call assert_equal(a:status, get(planet#term#Result(a:buffer), 'status', ''))
endfunc

for s:id in ['gdb-dashboard', 'gdb-unreal', 'gdb-pretty-printers']
  let s:buffer = planet#debugtools#Run(s:id, {'cwd': g:PV_test_dir, 'init': s:init, 'args': ['--batch', '-ex', 'quit']})
  call s:Wait(s:buffer, 'success')
  call assert_match('planet-debug-setup-loaded', join(getbufline(s:buffer, 1, '$'), "\n"))
endfor

let s:directory = g:PV_test_dir .. '/CTest build'
call mkdir(s:directory, 'p')
call writefile(['add_test(pass "' .. exepath('cmake') .. '" "-E" "true")'], s:directory .. '/CTestTestfile.cmake')
let s:buffer = planet#testtools#Run('ctest', {'cwd': g:PV_test_dir, 'build': s:directory})
call s:Wait(s:buffer, 'success')
call writefile(['add_test(fail "' .. exepath('cmake') .. '" "-E" "false")'], s:directory .. '/CTestTestfile.cmake')
let s:buffer = planet#testtools#Run('ctest', {'cwd': g:PV_test_dir, 'build': s:directory})
call s:Wait(s:buffer, 'failed')
call assert_match('fail', join(getbufline(s:buffer, 1, '$'), "\n"))
