set hidden
let s:python = executable('python3') ? exepath('python3') : exepath('python')
let s:fixture = g:PV_root .. '/tests/fixtures/tool_actions.py'
let s:record = g:PV_test_dir .. '/argv.json'
let s:tool = [s:python, s:fixture, s:record, '0']
let s:root = g:PV_test_dir .. '/SDK project'
call mkdir(s:root .. '/tools/testing/kunit', 'p')
call mkdir(s:root .. '/tools/testing/selftests', 'p')
call mkdir(s:root .. '/build', 'p')
call writefile(['# fixture'], s:root .. '/tools/testing/kunit/kunit.py')
call writefile(['# fixture'], s:root .. '/tools/testing/selftests/Makefile')
call writefile(['# fixture'], s:root .. '/build/DartConfiguration.tcl')
let s:program = s:root .. '/test program'
let s:init = s:root .. '/pretty printer.py'
call writefile(['fixture'], s:program)
call writefile(['# fixture'], s:init)

func! s:Wait(buffer, status = 'success') abort
  call assert_true(a:buffer > 0)
  for l:attempt in range(300)
    let l:result = planet#term#Result(a:buffer)
    if get(l:result, 'status', '') !=# 'running' | break | endif
    sleep 10m
  endfor
  call assert_equal(a:status, get(l:result, 'status', ''))
  return json_decode(join(readfile(s:record), ''))
endfunc

for s:id in ['gdb-dashboard', 'gdb-unreal', 'gdb-pretty-printers', 'lldb', 'rr', 'live-recorder', 'radare2', 'gdb-kernel', 'kgdb', 'kdb']
  let s:options = {'cwd': s:root, 'tool': s:tool, 'program': s:program, 'init': s:init,
        \ 'vmlinux': s:program, 'target': 'localhost:1234', 'device': '/tmp/fake-serial-device', 'baud': '115200',
        \ 'args': ['literal value; $(not-a-command)']}
  let s:buffer = planet#debugtools#Run(s:id, s:options)
  let s:args = s:Wait(s:buffer)
  call assert_equal('literal value; $(not-a-command)', s:args[-1])
  if s:id ==# 'rr' | call assert_equal('record', s:args[0]) | endif
  if s:id ==# 'kgdb' | call assert_true(index(s:args, 'target remote localhost:1234') >= 0) | endif
endfor
let s:job = planet#debugtools#Run('cutter', {'cwd': s:root, 'tool': s:tool, 'program': s:program})
for s:attempt in range(300)
  if job_status(s:job) !=# 'run' | break | endif
  sleep 10m
endfor
call assert_equal(0, job_info(s:job).exitval)
call assert_equal([s:program], json_decode(join(readfile(s:record), '')))
let s:kernel_init = planet#debugtools#Run('gdb-kernel-setup', {'cwd': s:root, 'vmlinux': s:program, 'helper': s:init})
call assert_match('^file "', readfile(s:kernel_init)[0])
call assert_match('^source "', readfile(s:kernel_init)[1])
call assert_equal(0, planet#debugtools#Run('kgdb', {'cwd': s:root, 'tool': s:tool, 'vmlinux': s:program, 'target': ':1234 | shell bad'}))
call assert_match('invalid GDB remote endpoint', planet#debugtools#LastError())
call assert_equal(0, planet#debugtools#Run('rr', {'cwd': s:root, 'program': s:program, 'tool': ['/missing/rr']}))
call assert_match('install rr', planet#debugtools#LastError())

for s:id in ['qt', 'google', 'boost', 'catch2', 'ctest', 'cdash', 'screenshot', 'record-gif', 'record-screen', 'kunit', 'kselftest']
  let s:options = {'cwd': s:root, 'tool': s:tool, 'program': s:program, 'report': s:root .. '/report.xml',
        \ 'build': s:root .. '/build', 'output': s:root .. '/capture.' .. (s:id ==# 'record-gif' ? 'gif' : s:id ==# 'screenshot' ? 'png' : 'mp4'),
        \ 'display': ':test', 'duration': '2', 'targets': 'timers memfd', 'filter': 'example*'}
  let s:args = s:Wait(planet#testtools#Run(s:id, s:options))
  if s:id ==# 'qt' | call assert_true(index(s:args, s:options.report .. ',junitxml') >= 0) | endif
  if s:id ==# 'google' | call assert_true(index(s:args, '--gtest_output=xml:' .. s:options.report) >= 0) | endif
  if s:id ==# 'boost' | call assert_true(index(s:args, '--report_sink=' .. s:options.report) >= 0) | endif
  if s:id ==# 'catch2' | call assert_equal(['--reporter', 'junit', '--out', s:options.report], s:args) | endif
  if s:id ==# 'cdash'
    call assert_true(index(s:args, 'ExperimentalSubmit') >= 0)
    call assert_equal(-1, index(s:args, 'ExperimentalUpdate'))
  endif
  if s:id ==# 'kunit' | call assert_equal(s:root .. '/tools/testing/kunit/kunit.py', s:args[0]) | endif
  if s:id ==# 'kselftest' | call assert_true(index(s:args, 'TARGETS=timers memfd') >= 0) | endif
endfor
let s:failed = s:Wait(planet#testtools#Run('ctest', {'cwd': s:root, 'build': s:root .. '/build',
      \ 'tool': [s:python, s:fixture, s:record, '7']}), 'failed')
call assert_equal(0, planet#testtools#Run('kunit', {'cwd': g:PV_test_dir}))
call assert_match('kernel source checkout', planet#testtools#LastError())
