set hidden
call setline(1, ['do not print', 'selected print line', 'do not print either'])
let s:print = g:PV_test_dir .. '/selected.ps'
if has('printer')
  let g:PV_print_path = s:print
  call cursor(2, 1)
  xnoremap <F11> <Cmd>call planet#fileextras#Print(1, g:PV_print_path)<CR>
  call feedkeys("V\<F11>", 'xt')
  call assert_true(filereadable(s:print))
  call assert_match('%!PS', readfile(s:print)[0])
  call assert_match('selected print line', join(readfile(s:print), "\n"))
  call assert_notmatch('do not print either', join(readfile(s:print), "\n"))
  xunmap <F11>
endif
if has('cryptv')
  new
  call setline(1, 'encrypted fixture text')
  execute 'file ' .. fnameescape(g:PV_test_dir .. '/encrypted.txt')
  setlocal cryptmethod=blowfish2
  call feedkeys(":call planet#fileextras#Crypt('set')\<CR>fixture-only-key\<CR>fixture-only-key\<CR>", 'xt')
  call assert_false(empty(&l:key))
  write
  call assert_match('VimCrypt', readfile(expand('%:p'), 'b')[0])
  edit!
  call assert_equal('encrypted fixture text', getline(1))
  call planet#fileextras#Crypt('remove')
  call assert_true(empty(&l:key))
  write
  call assert_equal(['encrypted fixture text'], readfile(expand('%:p')))
endif
call assert_equal(0, planet#fileextras#Remote(''))
call assert_equal(0, planet#fileextras#Remote('not a URL'))
let s:port = g:PV_test_dir .. '/http-port'
call writefile(['remote fixture contents'], g:PV_test_dir .. '/remote.txt')
let s:job = job_start([exepath('python3'), g:PV_root .. '/tests/helpers/http_fixture.py', g:PV_test_dir, s:port], #{stoponexit: 'kill', out_io: 'null', err_io: 'null'})
try
  for s:attempt in range(100)
    if filereadable(s:port) | break | endif
    sleep 20m
  endfor
  let s:url = 'http://127.0.0.1:' .. readfile(s:port)[0] .. '/remote.txt'
  call assert_equal(1, planet#fileextras#Remote(s:url))
  call assert_equal(['remote fixture contents'], getline(1, '$'))
  call assert_true(&readonly)
finally
  call job_stop(s:job, 'kill')
endtry
" Verify that the adapter sends the entire buffer, even with the cursor in its
" middle. Transport itself remains netrw's implementation.
let s:adapter = g:PV_test_dir .. '/autoload/netrw.vim'
call mkdir(fnamemodify(s:adapter, ':h'), 'p')
call writefile(['func! netrw#NetWrite(...) range', 'let g:PV_remote_range = [a:firstline, a:lastline]', 'endfunc'], s:adapter)
execute 'source ' .. fnameescape(s:adapter)
enew
call setline(1, ['first', 'middle', 'last'])
call cursor(2, 1)
call planet#fileextras#WriteRemote('scp://fixture/file')
call assert_equal([1, 3], g:PV_remote_range)
