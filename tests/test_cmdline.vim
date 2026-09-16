" Exercise deferred expressions through real command-line keystrokes.
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call planet#planet#SetStandardMode()
set noinsertmode wildmode=full wildoptions=

function! s:Capture() abort
  let g:PV_cmdline_capture = [getcmdtype(), getcmdline()]
  return ''
endfunction
cnoremap <expr> <F11> <SID>Capture()

function! s:Check(keys, expected) abort
  let g:PV_cmdline_capture = []
  let v:errmsg = ''
  try
    call feedkeys(a:keys .. "\<F11>\<C-c>", 'xt')
    call assert_equal('', v:errmsg, string(a:keys))
    call assert_equal(a:expected, g:PV_cmdline_capture, string(a:keys))
  catch
    call assert_report(v:exception .. ' for ' .. string(a:keys))
  endtry
endfunction

call s:Check(":com\<Tab>", [':', getcompletion('com', 'command')[0]])
call s:Check(":set ignorec\<Tab>", [':', 'set ignorecase'])
call s:Check(":echo 'discard this'\<C-u>", [':', ''])
call s:Check(':f ', [':', 'find '])
call s:Check(':echo f ', [':', 'echo f '])
call s:Check('/f ', ['/', 'f '])
call s:Check("/discard\<C-u>", ['/', ''])

" Tab and Ctrl-U cancel an empty ':' prompt without leaving a broken mapping.
for s:key in ["\<Tab>", "\<C-u>"]
  let v:errmsg = ''
  try
    call feedkeys(':' .. s:key, 'xt')
    call assert_equal('', v:errmsg)
    call assert_equal('n', mode())
  catch
    call assert_report(v:exception)
  endtry
endfor
cunmap <F11>
