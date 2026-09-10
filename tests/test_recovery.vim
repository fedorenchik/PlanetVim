set hidden
let s:original = g:PV_test_dir .. '/crashed.txt'
call writefile(['on disk'], s:original)
let s:ready = g:PV_test_dir .. '/swap-ready'
let s:script = g:PV_test_dir .. '/swap-owner.vim'
call writefile(['set nocompatible viminfofile=NONE', 'let &directory = ' .. string(g:PV_test_dir .. '//'),
      \ 'set updatecount=1 swapfile', 'execute "edit " .. fnameescape(' .. string(s:original) .. ')',
      \ "call setline(1, ['recovered edit', 'extra line'])", 'preserve',
      \ 'call writefile([swapname("%")], ' .. string(s:ready) .. ')', 'while 1', 'sleep 100m', 'endwhile'], s:script)
let s:job = job_start([g:PV_test_gvim, '-v', '-es', '-Nu', 'NONE', '-U', 'NONE', '-i', 'NONE', '-S', s:script], #{stoponexit: 'kill'})
try
  let s:tries = 0
  while !filereadable(s:ready) && s:tries < 100
    sleep 20m
    let s:tries += 1
  endwhile
  call assert_true(filereadable(s:ready), 'swap owner wrote its checkpoint')
  let s:swap = readfile(s:ready)[0]
  let &directory = g:PV_test_dir .. '//'
  call assert_false(empty(planet#recovery#List()))
  call assert_equal(0, planet#recovery#Recover(s:swap), 'live owner is protected')
  call job_stop(s:job, 'kill')
  let s:tries = 0
  while job_status(s:job) ==# 'run' && s:tries < 100
    sleep 20m
    let s:tries += 1
  endwhile
  call setline(1, 'unrelated unsaved work')
  let s:source = bufnr()
  call assert_equal(1, planet#recovery#Recover(s:swap))
  call assert_equal(['recovered edit', 'extra line'], getline(1, '$'))
  call assert_equal(['unrelated unsaved work'], getbufline(s:source, 1, '$'))
  call assert_true(&readonly)
  call assert_equal(1, planet#recovery#Compare())
  call assert_equal(['recovered edit', 'extra line'], getline(1, '$'))
  call assert_equal(0, planet#recovery#SaveCopy(s:original))
  call assert_equal(1, planet#recovery#SaveCopy(s:original .. '.recovered'))
  call assert_equal(['recovered edit', 'extra line'], readfile(s:original .. '.recovered'))
  call assert_equal(['on disk'], readfile(s:original))
  call assert_true(filereadable(s:swap), 'recovery retains its swap backup')
  call assert_equal(0, planet#recovery#SaveCopy(''))
finally
  if job_status(s:job) ==# 'run' | call job_stop(s:job, 'kill') | endif
endtry
