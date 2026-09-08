set hidden
let s:directory = g:PV_test_dir .. "/HEX space's 工作"
call mkdir(s:directory, 'p')
let s:counter = 0

func! s:Roundtrip(bytes, flags) abort
  let s:counter += 1
  let l:source = s:directory .. '/input-' .. s:counter
  call writefile(a:bytes, l:source)
  execute 'edit ' .. a:flags .. ' ' .. fnameescape(l:source)
  let l:options = [&binary, &fileencoding, &fileformat, &bomb, &endofline, &fixendofline]
  let l:original = getline(1, '$')
  let l:register = getreginfo('"')
  let l:window = win_getid()
  let l:windows = winnr('$')
  let l:tabs = tabpagenr('$')
  call assert_equal(1, planet#tools#XxdToHex(), 'encode fixture ' .. s:counter)
  call assert_equal('xxd', &filetype)
  call assert_equal(l:window, win_getid())
  call assert_equal(l:windows, winnr('$'))
  call assert_equal(l:tabs, tabpagenr('$'))
  call assert_equal(1, planet#tools#XxdFromHex(), 'decode fixture ' .. s:counter)
  call assert_equal(l:original, getline(1, '$'))
  call assert_equal(l:options, [&binary, &fileencoding, &fileformat, &bomb, &endofline, &fixendofline])
  call assert_equal(l:register, getreginfo('"'))
  call assert_equal(l:tabs, tabpagenr('$'))
  call assert_false(exists('b:PV_hex_state'))
  setlocal nofixendofline
  let l:saved = s:directory .. '/saved-' .. s:counter
  execute 'write! ' .. fnameescape(l:saved)
  call assert_equal(a:bytes, readblob(l:saved), 'byte-for-byte fixture ' .. s:counter)
  call assert_equal(a:bytes, readblob(l:source), 'source file remains untouched')
  setlocal nomodified
endfunc

call s:Roundtrip(0z48656C6C6F0A, '++enc=utf-8 ++ff=unix')
call s:Roundtrip(0z4100420AFF000D7F, '++bin ++enc=latin1 ++ff=unix')
call s:Roundtrip(0zC3A920E5B7A5E4BD9C0A, '++enc=utf-8 ++ff=unix')
call s:Roundtrip(0z410D0A420D0A, '++nobin ++enc=utf-8 ++ff=dos')
call s:Roundtrip(0z410D420D, '++nobin ++enc=utf-8 ++ff=mac')
call s:Roundtrip(0zFFFE41000D000A004200, '++nobin ++enc=utf-16le ++ff=dos')
call s:Roundtrip(0z, '++bin')

new
call setline(1, ['ordinary source code', 'second line'])
let s:lines = getline(1, '$')
let s:view = winsaveview()
let s:modified = &modified
call assert_equal(0, planet#tools#XxdFromHex())
call assert_equal(s:lines, getline(1, '$'))
call assert_equal(s:view, winsaveview())
call assert_equal(s:modified, &modified)
call assert_equal(1, planet#tools#XxdToHex())
let s:valid = getline(1, '$')
for s:bad in [s:valid + ['bad row'], ['bad row'] + s:valid,
      \ [substitute(s:valid[0], ': ', ': gg', '')] + s:valid[1:],
      \ [s:valid[0], s:valid[0]],
      \ [substitute(s:valid[0], '^00000000', 'ffffffff', '')]]
  call setline(1, s:bad)
  if line('$') > len(s:bad) | call deletebufline(bufnr(), len(s:bad)+1, '$') | endif
  let s:before = getline(1, '$')
  let s:view = winsaveview()
  let s:modified = &modified
  let s:state = deepcopy(b:PV_hex_state)
  call assert_equal(0, planet#tools#XxdFromHex(), string(s:bad))
  call assert_equal(s:before, getline(1, '$'))
  call assert_equal(s:view, winsaveview())
  call assert_equal(s:modified, &modified)
  call assert_equal(s:state, b:PV_hex_state)
endfor
" Edit bytes, leaving the display-only ASCII gutter unchanged.
call setline(1, s:valid)
if line('$') > len(s:valid) | call deletebufline(bufnr(), len(s:valid)+1, '$') | endif
call setline(1, substitute(getline(1), ': 6f72', ': 4f52', ''))
call assert_equal(1, planet#tools#XxdFromHex())
call assert_equal('ORdinary source code', getline(1))
" A failing external process preserves source and metadata.
let s:before = getline(1, '$')
let g:xxdprogram = 'missing-planetvim-xxd'
call assert_equal(0, planet#tools#XxdToHex())
call assert_equal(s:before, getline(1, '$'))
unlet g:xxdprogram
let s:python = planet#generate#Python()
if !empty(s:python)
  " Python is an existing executable that rejects this source as a program.
  let g:xxdprogram = s:python[0]
  let s:view = winsaveview()
  let s:modified = &modified
  call assert_equal(0, planet#tools#XxdToHex())
  call assert_equal(s:before, getline(1, '$'))
  call assert_equal(s:view, winsaveview())
  call assert_equal(s:modified, &modified)
  unlet g:xxdprogram
endif
