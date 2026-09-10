set hidden
call setline(1, ['a.b', 'axb', 'keep 10', 'keep 2', 'drop'])
let @/ = 'previous'
call assert_equal(0, planet#search#Find(1, ''))
call assert_equal('previous', @/)
call cursor(2, 1)
call assert_equal(1, planet#search#Find(1, 'a.b'))
call assert_equal('\Va.b', @/)
call assert_equal(1, line('.'))
call planet#search#Case('smart')
call assert_true(&ignorecase && &smartcase)
call assert_equal(1, planet#search#Substitute('buffer', 'keep', 'item', 0))
call assert_equal(['item 10', 'item 2'], getline(3, 4))
let s:before = getline(1, '$')
call assert_equal(0, planet#search#Global(0, 'buffer', '', 'delete', 0))
call assert_equal(s:before, getline(1, '$'))
call assert_equal(1, planet#search#Global(1, 'buffer', '^item', 'delete', 0))
call assert_equal(['item 10', 'item 2'], getline(1, '$'))
call assert_equal(1, planet#search#Sort('numeric'))
call assert_equal(['item 2', 'item 10'], getline(1, '$'))
call setline(1, ['same', 'other', 'same'])
call planet#search#Sort('unique')
call assert_equal(['other', 'same'], getline(1, '$'))
call setline(1, ['left foo right', 'foo outside'])
call cursor(1, 6)
xnoremap <F11> <Cmd>call planet#search#Substitute('selection', 'foo', 'bar', 0)<CR>
call feedkeys("viw\<F11>", 'xt')
call assert_equal(['left bar right', 'foo outside'], getline(1, '$'))
xunmap <F11>
args one one two
argdedupe
call assert_equal(['one', 'two'], argv())
