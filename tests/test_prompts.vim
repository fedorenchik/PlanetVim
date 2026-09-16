" Empty completion must omit input()'s third argument, which rejects ''.
set guioptions+=c
call timer_start(20, {-> feedkeys("\<C-u>new name\<CR>", 't')})
call assert_equal('new name', planet#prompt#Ask('Name: ', 'default'))
call timer_start(20, {-> feedkeys("\<CR>", 't')})
call assert_equal('default', planet#prompt#Ask('Name: ', 'default'))
call timer_start(20, {-> feedkeys("\<Esc>", 't')})
call assert_equal('', planet#prompt#Ask('Name: '))
highlight Todo ctermfg=Yellow guifg=Yellow
call timer_start(20, {-> feedkeys("\<CR>", 't')})
call assert_equal('Todo', planet#prompt#Ask('Highlight: ', 'Todo', 'highlight'))
