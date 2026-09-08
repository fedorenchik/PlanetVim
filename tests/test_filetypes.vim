filetype plugin indent on
set hidden
runtime plugin/filetypes.vim
nnoremap <A-t> :let g:PV_outline = 'code'<CR>
let g:PV_outline = ''
let s:base_columns = &colorcolumn
let s:buffer_sequence = 0

func! s:Type(type, keys) abort
  enew!
  let s:buffer_sequence += 1
  execute 'file ' .. fnameescape(g:PV_test_dir .. '/buffer-' .. s:buffer_sequence .. '.' .. a:type)
  execute 'setfiletype ' .. a:type
  if !empty(a:keys)
    call feedkeys('i' .. a:keys .. "\<Esc>", 'xt')
  endif
  return bufnr()
endfunc

let s:cpp = s:Type('cpp', ';s ')
call assert_equal('std::string ', getline(1))
call assert_equal(1, maparg(';;', 'i', 0, 1).buffer)
call assert_equal(1, maparg(';s', 'i', 1, 1).buffer)
call assert_equal('120', &colorcolumn)
let s:python = s:Type('python', ';s ;; ')
call assert_equal(';s ;; ', getline(1))
call assert_equal({}, maparg(';;', 'i', 0, 1))
call assert_equal({}, maparg(';s', 'i', 1, 1))
let s:markdown = s:Type('markdown', '')
call assert_equal(1, maparg('<A-t>', 'n', 0, 1).buffer)
call assert_match('toc', maparg('<A-t>', 'n'))
let s:text = s:Type('text', ';s ;; ')
call assert_equal(';s ;; ', getline(1))
call assert_equal(0, maparg('<A-t>', 'n', 0, 1).buffer)
call assert_match("PV_outline = 'code'", maparg('<A-t>', 'n'))
execute 'buffer! ' .. s:cpp
call assert_equal(1, maparg(';s', 'i', 1, 1).buffer)
call assert_equal('120', &colorcolumn)
setfiletype python
" :setfiletype intentionally does not change an existing type; :setfiletype
" above is followed by :set to exercise the actual ftplugin undo lifecycle.
setlocal filetype=python
call assert_equal({}, maparg(';;', 'i', 0, 1))
call assert_equal({}, maparg(';s', 'i', 1, 1))
call assert_equal(s:base_columns, &colorcolumn)
execute 'bwipeout! ' .. s:markdown
execute 'buffer! ' .. s:text
call assert_equal(0, maparg('<A-t>', 'n', 0, 1).buffer)
let s:c = s:Type('c', '#i ')
call assert_equal('#include ', getline(1))
call assert_equal({}, maparg(';s', 'i', 1, 1))
let s:plain = s:Type('text', '#i ')
call assert_equal('#i ', getline(1))
" Reapplying a FileType must not accumulate duplicate undo commands.
let s:undo = b:undo_ftplugin
doautocmd FileType text
call assert_equal(s:undo, b:undo_ftplugin)
" An existing buffer-local user mapping returns when PlanetVim is undone.
inoremap <buffer> ;; user mapping
setlocal filetype=cpp
call planet#filetype#Undo()
call assert_equal('user mapping', maparg(';;', 'i'))
