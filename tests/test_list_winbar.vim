execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
packloadall
set nomore hidden
call setqflist([#{filename:g:PV_test_dir .. '/q1.txt', lnum:1, text:'q1'}], ' ')
call setqflist([#{filename:g:PV_test_dir .. '/q2.txt', lnum:1, text:'q2'}], ' ')
call setloclist(0, [#{filename:g:PV_test_dir .. '/l1.txt', lnum:1, text:'keep'}], ' ')
call setloclist(0, [#{filename:g:PV_test_dir .. '/l2.txt', lnum:1, text:'drop'}], ' ')
lopen
let s:qf = getqflist(#{nr: 0}).nr
let s:ll = getloclist(0, #{nr: 0}).nr
emenu WinBar.⏪
call assert_equal(s:qf, getqflist(#{nr: 0}).nr, 'location bar does not mutate quickfix history')
call assert_equal(s:ll - 1, getloclist(0, #{nr: 0}).nr)
emenu WinBar.⏩
call assert_equal(s:ll, getloclist(0, #{nr: 0}).nr)
call assert_equal(0, planet#winbar#Filter(0, ''))
call assert_equal(1, planet#winbar#Filter(1, 'drop'))
call assert_equal([], getloclist(0))
call assert_equal(s:qf, getqflist(#{nr: 0}).nr)
lclose
copen
emenu WinBar.⏪
call assert_equal(s:qf - 1, getqflist(#{nr: 0}).nr)
call assert_match('q1', getqflist()[0].text)
