runtime plugin/editing.vim
new
let &l:commentstring = '# %s'
call setline(1, ['  alpha', 'beta'])
call assert_equal(1, planet#editing#ToggleComment(1, 2))
call assert_equal(['  # alpha', '# beta'], getline(1, 2))
call planet#editing#ToggleComment(1, 2)
call assert_equal(['  alpha', 'beta'], getline(1, 2))
let &l:commentstring = '/* %s */'
call planet#editing#ToggleComment(1, 1)
call assert_equal('  /* alpha */', getline(1))
call planet#editing#ToggleComment(1, 1)
call assert_equal('  alpha', getline(1))
let &l:commentstring = ''
call assert_equal(0, planet#editing#ToggleComment(1, 1))
call assert_equal('  alpha', getline(1))
let &l:commentstring = '// %s'
call feedkeys('gggcc', 'xt')
call assert_equal('  // alpha', getline(1))
call feedkeys('gcc', 'xt')
call assert_equal('  alpha', getline(1))
