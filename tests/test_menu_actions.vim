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
