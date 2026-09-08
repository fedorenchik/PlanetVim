func! s:Wait(buffer) abort
  call assert_true(a:buffer > 0)
  for l:attempt in range(200)
    call term_wait(a:buffer, 20)
    sleep 10m
    let l:result = planet#term#Result(a:buffer)
    if l:result.status !=# 'running'
      call assert_equal('success', l:result.status)
      execute 'bwipeout! ' .. a:buffer
      return
    endif
  endfor
  call planet#term#Cancel(a:buffer)
  call assert_report('scaffold timed out')
endfunc
let s:destination = g:PV_test_dir .. "/model ' 工作.qmodel"
let s:options = #{hidden: v:true, open: v:false}
call s:Wait(planet#scaffold#New('qt-model', s:destination, s:options))
call assert_true(filereadable(s:destination))
call assert_notmatch('%{UUID', join(readfile(s:destination)))
call s:Wait(planet#scaffold#New('qt-form-class', g:PV_test_dir .. '/Qt form', s:options))
call assert_true(filereadable(g:PV_test_dir .. '/Qt form/mainwindow.ui'))
call assert_true(filereadable(g:PV_test_dir .. '/Qt form/MainWindow.hpp'))
call assert_equal(0, planet#scaffold#New('qt-model', s:destination, s:options))
call assert_equal(0, planet#scaffold#New('qt-model', '', s:options))
call assert_equal(0, planet#scaffold#New('unknown-template', '', s:options))
