runtime plugin/globals.vim
call planet#menu#edit#Update()
highlight Todo ctermfg=Yellow guifg=Yellow
highlight Search ctermfg=Red guifg=Red
highlight Comment ctermfg=Blue guifg=Blue
new
let s:source_window = win_getid()
call setline(1, ['a界b', '  second', '', 'last'])
setlocal nomodified
let s:text = getline(1, '$')
let s:type = planet#textprop#Type('add', 'Note', 'Todo')
call assert_equal([s:type], planet#textprop#Types())
call assert_equal('Todo', prop_type_get(s:type, {'bufnr': bufnr()}).highlight)
call cursor(1, 2)
let s:id = planet#textprop#Add('character', 'Note')
call assert_equal([2, 3], [prop_list(1)[0].col, prop_list(1)[0].length])
call planet#textprop#Type('change', 'Note', 'Search')
call assert_equal('Search', prop_type_get(s:type, {'bufnr': bufnr()}).highlight)
call assert_equal(1, planet#textprop#Remove(s:id))

function! s:Selection(kind, start, end, exclusive = v:false) abort
  return {'type': a:kind, 'start': [0] + a:start + [0], 'end': [0] + a:end + [0],
        \ 'exclusive': a:exclusive, 'buffer': bufnr()}
endfunction

" Reversed/multiline/exclusive selections are byte accurate without yanking.
call setreg('z', 'keep register')
let s:register = getreginfo('z')
let s:id = planet#textprop#Add('selection', 'Note', s:Selection('v', [2, 4], [1, 2]))
call assert_equal([2, 5, 1, 0], map(['col', 'length', 'start', 'end'], 'prop_list(1)[0][v:val]'))
call assert_equal([1, 4, 0, 1], map(['col', 'length', 'start', 'end'], 'prop_list(2)[0][v:val]'))
call planet#textprop#Remove(s:id)
let s:id = planet#textprop#Add('selection', 'Note', s:Selection('v', [1, 2], [1, 5], v:true))
call assert_equal(3, prop_list(1)[0].length)
call planet#textprop#Remove(s:id)
call planet#textprop#Add('selection', 'Note', s:Selection('V', [2, 1], [3, 1]))
call assert_equal(1, prop_list(3)[0].end)
call planet#textprop#Clear()
call assert_equal(s:register, getreginfo('z'))
call assert_equal(s:text, getline(1, '$'))
call assert_false(&modified)

" All virtual-text placements are annotations, never file contents.
for s:align in ['inline', 'after', 'right', 'above', 'below']
  call cursor(2, 2)
  let s:virtual = planet#textprop#Note(s:align, 'annotation 界', 'Note')
  call assert_true(s:virtual < 0)
  call assert_equal(1, len(planet#textprop#Items()))
  call assert_equal(s:text, getline(1, '$'))
  call assert_false(&modified)
  call assert_equal(1, planet#textprop#Remove(s:virtual))
endfor
call assert_equal(0, planet#textprop#Note('after', '', 'Note'))
" Removing one of two identical annotations preserves the other after edits.
let s:note1 = planet#textprop#Note('after', 'same note', 'Note')
let s:note2 = planet#textprop#Note('after', 'same note', 'Note')
call append(0, 'inserted before notes')
call assert_equal([3, 3], map(planet#textprop#Items(), 'v:val.lnum'))
call assert_equal(1, planet#textprop#Remove(s:note1))
call assert_equal([s:note2], map(planet#textprop#Items(), 'v:val.id'))
call planet#textprop#Remove(s:note2)
1delete _
setlocal nomodified
call cursor(3, 1)
let s:empty = planet#textprop#Add('character', 'Note')
call assert_equal(0, prop_list(3)[0].length)
call planet#textprop#Remove(s:empty)

" Manual clearing/deleting types never removes plugin-owned properties/types.
call prop_type_add('PluginHint', {'highlight': 'Comment'})
let s:hint = prop_add(1, 0, {'type': 'PluginHint', 'text': 'plugin hint'})
call assert_equal([], planet#textprop#Items(), 'a reused virtual ID does not make a plugin hint manual')
call planet#textprop#Clear()
call assert_equal(1, len(prop_list(1)))
call prop_remove({'id': s:hint, 'type': 'PluginHint', 'both': v:true, 'all': v:true})
call prop_add(1, 1, {'type': 'PluginHint', 'id': 88, 'length': 1})
call cursor(2, 1)
call planet#textprop#Add('line', 'Note')
call assert_equal(1, len(planet#textprop#Items()))
call assert_equal(2, len(planet#textprop#Items(v:false)))
emenu n 🖌️h.TextProp.List\ Manual\ Properties
call assert_equal(1, len(getloclist(0)))
lclose
call win_gotoid(s:source_window)
emenu n 🖌️h.TextProp.Inspect\ All\ Properties
call assert_equal(2, len(getloclist(0)))
lclose
call win_gotoid(s:source_window)
call cursor(1, 1)
emenu n 🖌️h.TextProp.Next\ Manual\ Property
call assert_equal(2, line('.'))
call cursor(3, 1)
emenu n 🖌️h.TextProp.Previous\ Manual\ Property
call assert_equal(2, line('.'))
call planet#textprop#Clear()
call assert_equal('PluginHint', prop_list(1)[0].type)
call assert_equal(0, planet#textprop#Jump(v:true))
call cursor(2, 1)
call planet#textprop#Add('line', 'Note')
call planet#textprop#Type('delete', 'Note')
call assert_equal([], planet#textprop#Types())
call assert_equal([], prop_list(2))
call assert_equal('PluginHint', prop_list(1)[0].type)
call assert_false(empty(prop_type_get('PluginHint')))

" Buffer-local types and properties cannot leak into another buffer.
let s:buffer = bufnr()
call planet#textprop#Type('add', 'Note', 'Todo')
new
call assert_equal([], planet#textprop#Types())
call planet#textprop#Type('add', 'Note', 'Comment')
call assert_equal('Comment', prop_type_get(s:type, {'bufnr': bufnr()}).highlight)
close!
call assert_equal('Todo', prop_type_get(s:type, {'bufnr': bufnr()}).highlight)

" Block properties honor byte boundaries, short lines, tabs and wide text.
call prop_clear(1, line('$'))
call setline(1, ['ab界cd', '123456', 'x', "a\tZ"])
setlocal tabstop=4
let s:id = planet#textprop#Add('selection', 'Note', s:Selection("\<C-v>", [1, 3], [3, 4]))
call assert_equal([3, 3], [prop_list(1)[0].col, prop_list(1)[0].length])
call assert_equal([3, 2], [prop_list(2)[0].col, prop_list(2)[0].length])
call assert_equal([], prop_list(3))
call planet#textprop#Remove(s:id)
call planet#textprop#Add('selection', 'Note', s:Selection("\<C-v>", [2, 3], [4, 2]))
call assert_equal([2, 1], [prop_list(4)[0].col, prop_list(4)[0].length])
call planet#textprop#Clear()

" The menu's live-selection path preserves Unicode and registers in Visual mode.
execute 'vnoremap <F11> <Cmd>call planet#textprop#Add(''selection'', ''Note'')<CR>'
call cursor(1, 3)
call feedkeys("v\<F11>\<Esc>", 'xt')
call assert_equal([3, 3], [prop_list(1)[0].col, prop_list(1)[0].length])
call planet#textprop#Clear()
vunmap <F11>

" Menu tips expose the actual callable function; dialogs can cancel safely.
call assert_match(':call planet#textprop#Add', execute('tmenu 🖌️h.TextProp.Add\ at\ Cursor'))
call assert_match(':help text-properties', execute('tmenu 🖌️h.TextProp.Help'))
call timer_start(20, {-> feedkeys("0\<CR>", 't')})
call planet#textprop#Add('character')
call assert_equal([], planet#textprop#Items())
call timer_start(20, {-> feedkeys("1\<CR>", 't')})
call planet#textprop#Add('character')
call assert_equal(1, len(planet#textprop#Items()))
call timer_start(20, {-> feedkeys("1\<CR>", 't')})
call planet#textprop#Remove()
call assert_equal([], planet#textprop#Items())
setlocal nomodified
