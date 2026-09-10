aunmenu *
silent! tlunmenu *
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call planet#planet#SetStandardMode()
set noinsertmode selection=inclusive
call setline(1, ['prefix "é猫 words" suffix', 'value = {one two};'])
call cursor(1, 13)
emenu 🖍️i.Inside.Double\ quotes
call feedkeys('y', 'xt')
call assert_equal('é猫 words', getreg('"'))
call cursor(2, 11)
execute 'onoremap <F11> ' .. menu_info('🖍️i.Inside.Braces', 'o').rhs
call feedkeys("d\<F11>", 'xt')
call assert_equal('value = {};', getline(2))
ounmap <F11>
call setline(2, 'alpha beta')
call cursor(2, 1)
xnoremap <F11> <Cmd>emenu v 🖍️i.Around.Word<CR>
call feedkeys("v\<F11>y", 'xt')
call assert_equal('alpha ', getreg('"'))
xunmap <F11>
call setline(1, ['one', 'two', 'é猫'])
call cursor(1, 1)
xnoremap <F11> <Cmd>call planet#objects#Block('insert')<CR>
call feedkeys("\<C-v>jj\<F11>X\<Esc>", 'xt')
call assert_equal(['Xone', 'Xtwo', 'Xé猫'], getline(1, 3))
xunmap <F11>
call assert_equal(0, planet#objects#Block('insert'))
call setline(1, ['0x0f -2', '1', '1', '1'])
call cursor(1, 1)
call assert_equal(1, planet#objects#Number('increment', 2))
call assert_equal('0x11 -2', getline(1))
call cursor(1, 6)
call planet#objects#Number('decrement', 3)
call assert_equal('0x11 -5', getline(1))
call cursor(2, 1)
xnoremap <F11> <Cmd>call planet#objects#Number('increase each', 2)<CR>
call feedkeys("Vjj\<F11>", 'xt')
call assert_equal(['3', '5', '7'], getline(2, 4))
xunmap <F11>
call assert_equal(0, planet#objects#Number('increment', ''))
call assert_equal(0, planet#objects#Number('increment', 0))
