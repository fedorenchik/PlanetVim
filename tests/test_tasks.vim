execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/project_settings.vim')
set hidden
let s:root = g:PV_test_dir .. '/tasks 工作'
call mkdir(s:root, 'p')
execute 'cd ' .. fnameescape(s:root)
let s:python = exepath('python3')
let s:record = s:root .. '/order.txt'
let s:script = s:root .. '/step.py'
call writefile(['import pathlib,sys,time', 'time.sleep(float(sys.argv[3]))',
      \ 'with pathlib.Path(sys.argv[1]).open("a") as f: f.write(sys.argv[2]+"\n")', 'sys.exit(int(sys.argv[4]))'], s:script)
let s:tasks = {
      \ 'first': {'argv': [s:python, s:script, s:record, 'first', '0.1', '0']},
      \ 'second': {'depends': ['first'], 'argv': [s:python, s:script, s:record, 'second', '0', '0']},
      \ 'bad': {'argv': [s:python, s:script, s:record, 'failed', '0', '7']},
      \ 'blocked': {'depends': ['bad'], 'argv': [s:python, s:script, s:record, 'must not run', '0', '0']},
      \ 'slow': {'timeout': 1, 'argv': [s:python, s:script, s:record, 'late', '10', '0']},
      \ 'cycle': {'depends': ['cycle']}}
call PlanetTestProjectSettings({'defaults': {'tasks': s:tasks, 'hidden': v:true}})
func! s:Wait(id) abort
  for l:i in range(600)
    if planet#task#Status(a:id).status !=# 'running' | return planet#task#Status(a:id) | endif
    sleep 10m
  endfor
  call planet#task#Cancel(a:id)
  call assert_report('task timed out')
  return planet#task#Status(a:id)
endfunc
let s:id = planet#task#Start('second')
" Changing tabs after dispatch cannot redirect a prerequisite's successor.
tabnew
execute 'tcd ' .. fnameescape(g:PV_test_dir)
call assert_equal('success', s:Wait(s:id).status)
call assert_equal(['first', 'second'], readfile(s:record))
tabclose
call assert_equal('failed', s:Wait(planet#task#Start('blocked')).status)
call assert_equal(['first', 'second', 'failed'], readfile(s:record))
try
  call planet#task#Start('cycle')
  call assert_report('cycle accepted')
catch /dependency cycle/
endtry
let s:id = planet#task#Start('slow')
call assert_equal('timed-out', s:Wait(s:id).status)
for s:i in range(400)
  if !get(planet#task#Status(s:id), 'pending', 0) | break | endif
  sleep 10m
endfor
let s:id = planet#task#Start('slow')
call assert_equal(1, planet#task#Cancel(s:id))
try
  call planet#task#Start('first')
  call assert_report('second task started before cancellation finished')
catch /already has a running task/
endtry
call assert_equal('cancelled', planet#task#Status(s:id).status)
call assert_equal(['first', 'second', 'failed'], readfile(s:record))
for s:i in range(400)
  if !get(planet#task#Status(s:id), 'pending', 0) | break | endif
  sleep 10m
endfor
call assert_false(get(planet#task#Status(s:id), 'pending', 0))

let s:context = planet#project#Context()
let s:context.program = 'script with spaces.py'
call assert_equal([s:root .. '/script with spaces.py', s:root .. '/build'], planet#task#Expand(['${program}', '${build}'], s:context))
