" Exact export/move behavior is tested without prompting or changing user files.
func! s:Selection(type, first, last, exclusive = v:false) abort
  return {'type': a:type, 'start': [0] + a:first + [0],
        \ 'end': [0] + a:last + [0], 'exclusive': a:exclusive, 'buffer': bufnr()}
endfunc

func! s:Buffer(lines) abort
  enew!
  setlocal noswapfile noundofile modifiable
  call setline(1, a:lines)
endfunc

call s:Buffer(['prefix selected suffix', 'second line'])
let s:registers = {'0': getreginfo('0'), 'z': getreginfo('z'), '"': getreginfo('"')}
call setreg('0', 'keep zero', 'v')
call setreg('z', ['keep scratch'], 'V')
call setreg('"', {'points_to': '0'})
let s:before = {'0': getreginfo('0'), 'z': getreginfo('z'), '"': getreginfo('"')}
let s:options = [&selection, &clipboard, &virtualedit]
let s:file = g:PV_test_dir .. '/selection with spaces.txt'
call assert_equal(1, planet#selection#Export(s:file, s:Selection('v', [1, 8], [1, 15]), v:true))
call assert_equal(['selected'], readfile(s:file, 'b'))
call assert_equal(['prefix  suffix', 'second line'], getline(1, '$'))
call assert_equal(s:options, [&selection, &clipboard, &virtualedit])
for s:reg in ['0', 'z', '"']
  call assert_equal(s:before[s:reg], getreginfo(s:reg))
endfor

call s:Buffer(['A猫犬Z'])
call planet#selection#Export(g:PV_test_dir .. '/unicode.txt', s:Selection('v', [1, 2], [1, 5]), v:true)
call assert_equal(['猫犬'], readfile(g:PV_test_dir .. '/unicode.txt', 'b'))
call assert_equal('AZ', getline(1))

call s:Buffer(['abcd'])
call planet#selection#Export(g:PV_test_dir .. '/exclusive.txt', s:Selection('v', [1, 2], [1, 4], v:true), v:true)
call assert_equal(['bc'], readfile(g:PV_test_dir .. '/exclusive.txt', 'b'))
call assert_equal('ad', getline(1))

call s:Buffer(['one ABC', 'DEF two'])
call planet#selection#Export(g:PV_test_dir .. '/multiline.txt', s:Selection('v', [1, 5], [2, 3]), v:true)
call assert_equal(['ABC', 'DEF'], readfile(g:PV_test_dir .. '/multiline.txt', 'b'))
call assert_equal(['one  two'], getline(1, '$'))

call s:Buffer(['first', 'second', 'third'])
call planet#selection#Export(g:PV_test_dir .. '/line.txt', s:Selection('V', [1, 1], [2, 1]), v:true)
call assert_equal(['first', 'second', ''], readfile(g:PV_test_dir .. '/line.txt', 'b'))
call assert_equal(['third'], getline(1, '$'))

call s:Buffer(['abXXcd', '12YY34'])
call planet#selection#Export(g:PV_test_dir .. '/block.txt', s:Selection("\<C-v>", [1, 3], [2, 4]), v:true)
call assert_equal(['XX', 'YY'], readfile(g:PV_test_dir .. '/block.txt'))
call assert_equal(['abcd', '1234'], getline(1, '$'))

call s:Buffer(["a\tZ", "b\tY"])
setlocal tabstop=4
let s:block = {'type': "\<C-v>", 'start': [0, 1, 2, 1], 'end': [0, 2, 2, 2], 'exclusive': v:false}
call planet#selection#Export(g:PV_test_dir .. '/tab-block.txt', s:block, v:true)
call assert_equal(['  ', '  '], readfile(g:PV_test_dir .. '/tab-block.txt'))
call assert_equal(['a Z', 'b Y'], getline(1, '$'))

call s:Buffer(['new'])
let s:shape = s:Selection('v', [1, 1], [1, 3])
call writefile(['old'], g:PV_test_dir .. '/append.txt', 'b')
call planet#selection#Export(g:PV_test_dir .. '/append.txt', s:shape, v:false, 'a')
call assert_equal(['oldnew'], readfile(g:PV_test_dir .. '/append.txt', 'b'))
call assert_equal(0, planet#selection#Export('', s:shape, v:true))
call assert_equal(['new'], getline(1, '$'))
try
  call planet#selection#Export(g:PV_test_dir .. '/append.txt', s:shape, v:true)
  call assert_report('Overwriting an existing file requires explicit consent')
catch /destination already exists/
endtry
call assert_equal(['oldnew'], readfile(g:PV_test_dir .. '/append.txt', 'b'))
call assert_equal(['new'], getline(1, '$'))
call planet#selection#Export(g:PV_test_dir .. '/append.txt', s:shape, v:false, '', v:true)
call assert_equal(['new'], readfile(g:PV_test_dir .. '/append.txt', 'b'))

call writefile(['block parent creation'], g:PV_test_dir .. '/not-a-directory')
try
  call planet#selection#Export(g:PV_test_dir .. '/not-a-directory/child.txt', s:shape, v:true)
  call assert_report('A failed write should throw')
catch
endtry
call assert_equal(['new'], getline(1, '$'))
call assert_equal(s:options, [&selection, &clipboard, &virtualedit])
for s:reg in ['0', 'z', '"']
  call assert_equal(s:before[s:reg], getreginfo(s:reg))
endfor
for s:reg in ['0', 'z', '"']
  call setreg(s:reg, s:registers[s:reg])
endfor

" Select All must execute from the real menu in both Normal and Insert mode.
let g:PlanetVim_menus_basic = 1
call planet#menu#basic#Update()
func! s:CaptureAll() abort
  let g:PV_selected_all = [mode(), line('v'), line('.')]
endfunc
nnoremap <F12> <Cmd>emenu n 🖍️i.Select\ All<CR>
" Dispatch the actual Insert menu keys without wrapping them in another
" Insert-mode <Cmd>, whose context would itself restore Insert mode.
execute 'inoremap <F12> ' .. menu_info('🖍️i.Select All', 'i').rhs
noremap <F11> <Cmd>call <SID>CaptureAll()<CR>
snoremap <F11> <Cmd>call <SID>CaptureAll()<CR>
inoremap <F11> <Cmd>call <SID>CaptureAll()<CR>
let s:selectmode = &selectmode
for s:selection_mode in ['', 'mouse,key,cmd']
  let &selectmode = s:selection_mode
  for s:entry_mode in ['', 'i']
    call s:Buffer(['first', 'middle', 'last'])
    call cursor(2, 2)
    call feedkeys(s:entry_mode .. "\<F12>\<F11>\<Esc>", 'xt')
    let s:expected_mode = empty(s:selection_mode) ? 'V' : 'S'
    call assert_equal([s:expected_mode, 1, 3], g:PV_selected_all)
    call assert_equal(['first', 'middle', 'last'], getline(1, '$'))
  endfor
endfor
let &selectmode = s:selectmode
nunmap <F12>
iunmap <F12>
unmap <F11>
iunmap <F11>
