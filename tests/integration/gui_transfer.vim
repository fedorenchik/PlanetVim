if !has('gui_running')
  throw 'The window transfer integration test requires --gui'
endif
set hidden
let s:path = g:PV_test_dir .. '/unsaved transfer.txt'
call writefile(['original disk contents'], s:path)
execute 'edit ' .. fnameescape(s:path)
call setline(1, ['unsaved α text', 'second line'])
call cursor(2, 3)
let s:source = bufnr()
let s:copy = planet#gui#Transfer(v:false)
call assert_equal(v:t_dict, type(s:copy))
for s:attempt in range(400)
  if s:copy.status !=# 'running' | break | endif
  sleep 50m
endfor
call assert_equal('success', s:copy.status)
call assert_equal(s:source, bufnr())
call assert_true(&modified)
call assert_equal(['original disk contents'], readfile(s:path))
call job_stop(s:copy.job)

let s:move = planet#gui#Transfer(v:true)
for s:attempt in range(400)
  if s:move.status !=# 'running' | break | endif
  sleep 50m
endfor
call assert_equal('success', s:move.status, get(s:move, 'error', ''))
call assert_notequal(s:source, bufnr(), 'Move must close the source view after the receiving window acknowledges')
call assert_equal(['unsaved α text', 'second line'], getbufline(s:source, 1, '$'))
call assert_true(getbufvar(s:source, '&modified'), 'Keep the hidden source as recovery')
call assert_equal(['original disk contents'], readfile(s:path))
call job_stop(s:move.job)
