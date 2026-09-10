aunmenu *
silent! tlunmenu *
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call planet#planet#SetStandardMode()
set noinsertmode
call assert_true(len(planet#actions#Search('')) > 1000)
call assert_false(empty(planet#actions#Search('compare')))
call planet#menu#Style('descriptive')
call planet#menu#Group('settings')
call assert_false(empty(planet#actions#Search('compare')), 'hidden groups remain searchable')
let s:actions = planet#actions#Search('file new split')
call assert_false(empty(s:actions))
let s:context = #{window: win_getid(), buffer: bufnr(), cursor: getpos('.'), mode: 'n'}
let s:action = filter(s:actions, {_, item -> item.label =~# 'New Split$'})[0]
let s:before = winnr('$')
call planet#actions#Execute(s:action, s:context)
call feedkeys('', 'xt')
call assert_equal(s:before + 1, winnr('$'))
call assert_equal('basic', g:PV_menu_group)
call assert_false(empty(menu_info('PlanetVim')))
let s:popup = planet#actions#Open()
call assert_true(s:popup > 0)
call popup_close(s:popup, -1)
vnoremenu Modify.Selection\ Probe gU
call planet#actions#Index()
call setline(1, ['first selection', 'second word'])
let g:PV_action_probe = planet#actions#Search('selection probe', 'x')[0]
func! PVActionProbe() abort
  let l:context = #{window: win_getid(), buffer: bufnr(), cursor: getpos('.'), mode: 'x', selection: planet#selection#Current()}
  execute "normal! \<Esc>"
  call planet#actions#Execute(g:PV_action_probe, l:context)
endfunc
xnoremap <F11> <Cmd>call PVActionProbe()<CR>
call cursor(2, 1)
call feedkeys("viw\<F11>", 'xt')
call assert_equal('SECOND word', getline(2))
call assert_equal('first selection', getline(1))
xunmap <F11>
delfunc PVActionProbe
inoremenu Modify.Insert\ Probe INSERTED
call planet#actions#Index()
inoremap <F12> <Cmd>call planet#actions#Open()<CR>
call cursor(1, 1)
call feedkeys("i\<F12>insert probe\<CR>\<Esc>", 'xt')
call assert_equal('INSERTEDfirst selection', getline(1))
iunmap <F12>
nnoremenu Modify.Dynamic\ Probe <Cmd>let g:PV_dynamic_probe = 1<CR>
let s:popup = planet#actions#Open()
call assert_equal(1, len(planet#actions#Search('dynamic probe')))
call popup_close(s:popup, -1)
let s:before = getline(1, '$')
call planet#menu#Refresh()
nnoremap <F12> <Cmd>call planet#actions#Open()<CR>
call feedkeys("\<F12>help user manual\<F1>\<Esc>", 'xt')
call assert_equal('help', &buftype)
call assert_match('usr_toc', expand('%:t'))
call popup_clear()
close
call assert_equal(s:before, getline(1, '$'))
nunmap <F12>
" A Select mapping expects Select mode, not the Visual mode used internally
" to restore the range. Otherwise CTRL-G flips the wrong way and edits text.
call planet#menu#Group('basic')
call setline(1, 'select this word')
call cursor(1, 9)
snoremap <F12> <Cmd>call planet#actions#Open()<CR>
call feedkeys("gh\<F12>selection inside word\<CR>y", 'xt')
call assert_equal('this', getreg('"'))
call assert_equal('select this word', getline(1))
sunmap <F12>
