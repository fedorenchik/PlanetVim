call setline(1, 'café')
let s:path = g:PV_test_dir .. '/encoding.txt'
execute 'file ' .. fnameescape(s:path)
call assert_equal(1, planet#buffer_options#Encoding('save', 'latin1'))
write
call assert_equal([99,97,102,233,10], blob2list(readblob(s:path)))
call assert_equal(1, planet#buffer_options#Encoding('reopen', 'latin1'))
call assert_equal('café', getline(1))
call assert_equal(1, planet#buffer_options#Encoding('save', 'utf-16le'))
setlocal bomb
write
call assert_equal([255,254,99,0,97,0,102,0,233,0,10,0], blob2list(readblob(s:path)))
call assert_equal(1, planet#buffer_options#Encoding('save', 'utf-8'))
setlocal nobomb
write
call assert_equal([99,97,102,195,169,10], blob2list(readblob(s:path)))
let s:before = getline(1, '$')
call assert_equal(0, planet#buffer_options#Encoding('reopen', ''))
call assert_equal(s:before, getline(1, '$'))
call assert_equal(0, planet#buffer_options#Encoding('save', 'no-such-encoding'))
let s:buffer = bufnr()
let s:tabstop = &l:tabstop
new
call planet#buffer_options#Indent('tabstop', 3)
call planet#preferences#Toggle('expandtab', 1)
call assert_equal(3, &l:tabstop)
call assert_equal(s:tabstop, getbufvar(s:buffer, '&tabstop'))
call assert_equal(1, planet#buffer_options#Filetype('python'))
call assert_equal('python', &l:filetype)
call assert_equal(0, planet#buffer_options#Indent('tabstop', 0))
call assert_equal(0, planet#input#Insert('unicode', 'D800'))
call assert_equal(0, planet#input#Insert('unicode', '110000'))
call assert_equal(0, planet#input#Insert('unicode', ''))
inoremap <F11> <Cmd>call planet#input#Insert('unicode', '1F600', 'i')<CR>
call feedkeys("i\<F11>\<Esc>", 'xt')
call assert_equal('😀', getline(1))
iunmap <F11>
inoremap <F11> <Cmd>call planet#input#Insert('digraph', 'e:', 'i')<CR>
call feedkeys("A\<F11>\<Esc>", 'xt')
call assert_equal('😀ë', getline(1))
iunmap <F11>
inoremap <F11> <Cmd>call planet#input#Insert('expression', '6 * 7', 'i')<CR>
call feedkeys("A\<F11>\<Esc>", 'xt')
call assert_equal('😀ë42', getline(1))
iunmap <F11>
call assert_equal(1, planet#input#Keymap(''))
call assert_equal(0, &l:iminsert)
call assert_equal(0, planet#input#Keymap('not-an-installed-keymap'))
if !empty(planet#input#Keymaps())
  let s:map = planet#input#Keymaps()[0]
  call assert_equal(1, planet#input#Keymap(s:map))
  call assert_equal(s:map, &l:keymap)
  call assert_equal(1, &l:iminsert)
endif
call planet#input#Keymap('')
if index(planet#input#SpellLanguages(), 'en') >= 0
  call assert_equal(1, planet#input#SpellLanguage('en'))
  call assert_true(&l:spell)
endif
call assert_equal(0, planet#input#SpellLanguage('not-installed'))
