" Native popup contexts must preserve the clicked buffer, mode and selection.
aunmenu *
silent! tlunmenu *
let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call assert_equal([], filter(getscriptinfo(), 'v:val.name =~# "/autoload/planet/popup.vim$"'), 'popup builder stays unloaded until used')
set noinsertmode nospell hidden
enew
execute 'file ' .. fnameescape(g:PV_test_dir .. '/file with spaces.py')
setfiletype python
call setline(1, ['first word', 'second line', 'first word'])
call cursor(1, 2)
doautocmd MenuPopup n
call assert_false(empty(menu_info('PopUp.Undo', 'n')))
call assert_false(empty(menu_info('PopUp.Toggle Line Comment', 'n')))
call assert_equal({}, menu_info('PopUp.Rename Symbol', 'n'), 'no inactive LSP actions')
call assert_equal({}, menu_info('PopUp.Copy', 'n'), 'copy line is explicit when nothing is selected')
emenu PopUp.File.Copy Path
call assert_equal(expand('%:p'), getreg('+'))
emenu PopUp.Toggle Line Comment
call assert_equal('# first word', getline(1))
emenu PopUp.Toggle Line Comment
call assert_equal('first word', getline(1))

" Rebuild without affecting clipboard, view, live selection, or its direction.
function! s:SelectionMenu() abort
  let l:before = [mode(), getpos('v'), getpos('.'), winsaveview(), getreg('+')]
  call planet#popup#Build(mode() =~# '^[sS\x13]' ? 's' : 'v')
  call assert_equal(l:before, [mode(), getpos('v'), getpos('.'), winsaveview(), getreg('+')])
endfunction
xnoremap <F11> <Cmd>call <SID>SelectionMenu()<CR><Cmd>emenu PopUp.Copy<CR>
call feedkeys("gg0v4l\<F11>\<Esc>", 'xt')
call assert_equal('first', getreg('+'))
xnoremap <F11> <Cmd>call <SID>SelectionMenu()<CR><Cmd>emenu PopUp.Transform.Uppercase<CR>
call feedkeys("gg0v4l\<F11>\<Esc>", 'xt')
call assert_equal('FIRST word', getline(1))
call assert_equal('u', menu_info('PopUp.Transform.Lowercase', 'x').accel)
call assert_notmatch(':undo', execute('tmenu PopUpv.Transform.Lowercase'))
snoremap <F11> <Cmd>call <SID>SelectionMenu()<CR><Cmd>emenu s PopUp.Copy<CR>
call feedkeys("gg0v4l\<C-G>\<F11>\<Esc>", 'xt')
call assert_equal('FIRST', getreg('+'), 'Select-mode copy must not insert its key sequence')
call assert_equal('FIRST word', getline(1))
xnoremap <F11> <Cmd>call <SID>SelectionMenu()<CR><Cmd>emenu PopUp.Paste<CR>
call setreg('+', 'other')
call feedkeys("gg0v4l\<F11>\<Esc>", 'xt')
call assert_equal('other word', getline(1))
call assert_equal('other', getreg('+'), 'paste must preserve clipboard')
xnoremap <F11> <Cmd>call <SID>SelectionMenu()<CR><Cmd>emenu PopUp.Search\ for\ Selection<CR>
call feedkeys("3G0v4l\<F11>\<Esc>", 'xt')
call assert_equal('\Vfirst', @/)
xunmap <F11>
sunmap <F11>

" Insert and command-line menus execute without leaking normal-mode keys.
call planet#popup#Build('i')
execute 'inoremap <F11> ' .. menu_info('PopUp.Paste', 'i').rhs
call setreg('+', 'clip')
call feedkeys("gg0i\<F11>\<Esc>", 'xt')
call assert_equal('clipother word', getline(1))
call assert_match('clipboard literally', execute('tmenu PopUpi.Paste'))
call assert_match(':undo', execute('tmenu PopUpi.Undo'))
iunmap <F11>
call planet#popup#Build('c')
execute 'cnoremap <F11> ' .. menu_info('PopUp.Copy', 'c').rhs
call feedkeys(":echo 'context'\<F11>\<Esc>", 'xt')
call assert_equal("echo 'context'", getreg('+'))
cunmap <F11>
call planet#popup#Build('o')
call assert_equal('iw', menu_info('PopUp.Word', 'o').rhs)

" Read-only/scratch contexts have copying and navigation, without edits/save.
setlocal readonly
call planet#popup#Build('n')
call assert_equal({}, menu_info('PopUp.Paste', 'n'))
call assert_equal({}, menu_info('PopUp.File.Save', 'n'))
call assert_false(empty(menu_info('PopUp.Copy Line', 'n')))
setlocal noreadonly
new
setlocal buftype=nofile nomodifiable
call planet#popup#Build('n')
call assert_equal({}, menu_info('PopUp.File', 'n'))
call assert_equal({}, menu_info('PopUp.Cut Line', 'n'))
close
help help
call planet#popup#Build('n')
call assert_false(empty(menu_info('PopUp.Follow Help Tag', 'n')))
call assert_equal({}, menu_info('PopUp.Undo', 'n'))
close

" Location-list history must not change the independent quickfix history.
let s:entry = {'bufnr': bufnr(), 'lnum': 1, 'text': 'one'}
call setqflist([], ' ', {'items': [s:entry], 'title': 'qf-one'})
call setqflist([], ' ', {'items': [s:entry], 'title': 'qf-two'})
call setloclist(0, [], ' ', {'items': [s:entry], 'title': 'loc-one'})
call setloclist(0, [], ' ', {'items': [s:entry], 'title': 'loc-two'})
lopen
call planet#popup#Build('n')
emenu PopUp.Older\ List
call assert_equal('loc-one', getloclist(0, {'title': 0}).title)
call assert_equal('qf-two', getqflist({'title': 0}).title)
close
copen
call planet#popup#Build('n')
emenu PopUp.Older\ List
call assert_equal('qf-one', getqflist({'title': 0}).title)
close

" File type and diff actions are rebuilt rather than leaking from another file.
new
call setline(1, ['https://example.org/path', 'plainword'])
call cursor(1, 10)
call planet#popup#Build('n')
call assert_false(empty(menu_info('PopUp.Open Link', 'n')))
call cursor(2, 1)
diffthis
call planet#popup#Build('n')
call assert_equal({}, menu_info('PopUp.Open Link', 'n'))
call assert_false(empty(menu_info('PopUp.Diff.Get Change', 'n')))
diffoff
call planet#popup#Build('n')
call assert_equal({}, menu_info('PopUp.Diff', 'n'))

" No forced job termination just from showing or dismissing a terminal menu.
let s:terminal = term_start(['/bin/sh', '-c', 'sleep 30'], {'term_finish': 'open'})
call planet#popup#Build('tl')
call assert_equal('run', job_status(term_getjob(s:terminal)))
call assert_false(empty(menu_info('PopUp.Paste', 'tl')))
call assert_equal('<Cmd>confirm bdelete<CR>', menu_info('PopUp.Stop Job', 'tl').rhs)
call assert_equal({}, menu_info('PopUp.File', 'tl'))
call assert_match('planet#popup#TerminalMouse', maparg('<RightMouse>', 't'))
call assert_equal('<RightMouse>', maparg('<S-RightMouse>', 't'))
let s:terminal_window = win_getid()
call planet#popup#HideTerminal()
call assert_equal(0, win_id2win(s:terminal_window))
call assert_equal('run', job_status(term_getjob(s:terminal)), 'hiding must keep the job alive')
only
execute 'buffer ' .. s:terminal
call planet#popup#HideTerminal()
call assert_notequal(s:terminal, bufnr(), 'hide also works in the only window')
call assert_equal('run', job_status(term_getjob(s:terminal)))
execute 'buffer ' .. s:terminal
call job_stop(term_getjob(s:terminal), 'kill')
call term_wait(s:terminal, 100)
call planet#popup#Build('n')
call assert_equal({}, menu_info('PopUp.Stop Job', 'n'))
call assert_false(empty(menu_info('PopUp.Close Finished Terminal', 'n')))
execute 'bwipeout! ' .. s:terminal

" Multiple rebuilds keep hints/tips valid after changing root presentation.
call planet#menu#Style('descriptive')
call planet#popup#Build('n')
call assert_match(':undo', execute('tmenu PopUpn.Undo'))
call assert_equal(1, count(execute('autocmd PlanetVimContextMenu'), 'planet#popup#Build'))
