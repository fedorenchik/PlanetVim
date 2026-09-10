let s:result = g:PV_test_dir .. '/tutor-result'
let s:command = planet#learn#TutorCommand() + ['-c', 'call writefile([string(has("gui_running")), maparg("f", "n"), &buftype, string(line("$"))], ' .. string(s:result) .. ')', '-c', 'qa!']
let s:job = job_start(s:command, #{stoponexit: 'kill', out_io: 'null', err_io: 'null'})
try
  for s:attempt in range(200)
    if job_status(s:job) !=# 'run' | break | endif
    sleep 20m
  endfor
  call assert_true(filereadable(s:result))
  let s:lines = readfile(s:result)
  call assert_equal('1', s:lines[0], 'the tutor is a real GUI')
  call assert_equal('', s:lines[1], 'the tutor has standard Vim f')
  call assert_true(index(['nofile', 'nowrite'], s:lines[2]) >= 0)
  call assert_true(str2nr(s:lines[3]) > 100)
finally
  if job_status(s:job) ==# 'run' | call job_stop(s:job, 'kill') | endif
endtry
call setline(1, 'unsaved user file')
let s:buffer = bufnr()
call planet#learn#Vim9()
call assert_equal(1, planet#learn#RunVim9())
call assert_equal(['unsaved user file'], getbufline(s:buffer, 1, '$'))
call assert_equal(0, planet#learn#Help(''))
