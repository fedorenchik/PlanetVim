set hidden
let g:PlanetVim_menus_dev = 1
let g:PlanetVim_menus_basic = 1
call planet#menu#dev#Update()
call planet#menu#basic#Update()
call assert_equal(0, planet#arduino#Baud('9600'))
command! -nargs=1 ArduinoSetBaud let g:PV_test_baud = <q-args>
let g:PV_test_baud = 'untouched'
call assert_equal(0, planet#arduino#Baud(''))
call assert_equal(0, planet#arduino#Baud('\CANCEL'))
call assert_equal(0, planet#arduino#Baud('9600 | quit'))
call assert_equal('untouched', g:PV_test_baud)
call assert_equal(1, planet#arduino#Baud('09600'))
call assert_equal('9600', g:PV_test_baud)
delcommand ArduinoSetBaud
new
call setline(1,['old selection','ignore this','current selection','é猫 tail'])
call cursor(1,1)
execute "normal! viw\<Esc>"
call cursor(3,1)
command! -range LspDocumentRangeFormat let g:PV_test_range = [line("'<"), col("'<"), line("'>"), col("'>"), <line1>, <line2>]
xnoremap <F11> <Cmd>emenu v ❇️[.Format\ Document\ Selection<CR>
call feedkeys("viw\<F11>", 'xt')
call assert_equal([3,1,3,7,3,3], g:PV_test_range)
delcommand LspDocumentRangeFormat
xunmap <F11>
let s:register = getreginfo('"')
let s:source = bufnr()
let s:source_lines = getline(1,'$')
let s:source_modified = &modified
let g:html_no_progress = 1
let g:html_number_lines = 0
let g:html_use_css = 0
let g:html_no_pre = 0
xnoremap <F12> <Cmd>emenu v 📁f.Export\ (Selected)\ as\ HTML<CR>
snoremap <F12> <Cmd>emenu s 📁f.Export\ (Selected)\ as\ HTML<CR>
for s:shape in ['char','line','block','unicode-exclusive','select']
  execute 'buffer ' .. s:source
  set selection=inclusive
  call cursor(3,1)
  if s:shape ==# 'char'
    let s:keys = 'viw'
  elseif s:shape ==# 'line'
    let s:keys = 'V'
  elseif s:shape ==# 'block'
    call cursor(1,1)
    let s:keys = "\<C-v>jj2l"
  elseif s:shape ==# 'unicode-exclusive'
    set selection=exclusive
    call cursor(4,1)
    let s:keys = 'vll'
  else
    let s:keys = "viw\<C-G>"
  endif
  call feedkeys(s:keys .. "\<F12>", 'xt')
  call assert_equal('html', &filetype)
  call assert_equal('', bufname(), 'selected HTML can be saved outside its private temporary folder')
  let s:html = join(getline(1,'$'),"\n")
  if s:shape ==# 'char' || s:shape ==# 'select'
    call assert_match('current', s:html)
    call assert_notmatch('selection', substitute(s:html,'<title>.*</title>','',''))
    call assert_notmatch('old selection\|ignore this', s:html)
  elseif s:shape ==# 'line'
    call assert_match('current selection', s:html)
    call assert_notmatch('old selection\|ignore this', s:html)
  elseif s:shape ==# 'block'
    call assert_match('old', s:html)
    call assert_match('ign', s:html)
    call assert_match('cur', s:html)
    call assert_notmatch('ignore this\|current selection', s:html)
  else
    call assert_match('é猫', s:html)
    call assert_notmatch('tail\|old selection\|ignore this', s:html)
  endif
  call assert_equal(s:source_lines,getbufline(s:source,1,'$'))
  call assert_equal(s:source_modified,getbufvar(s:source,'&modified'))
  call assert_equal(s:register,getreginfo('"'))
  bwipeout!
endfor
xunmap <F12>
sunmap <F12>
set selection=inclusive
execute 'buffer ' .. s:source
emenu n 📁f.Export\ (Selected)\ as\ HTML
call assert_equal('html', &filetype)
let s:html = join(getline(1,'$'),"\n")
call assert_match('old selection', s:html)
call assert_match('current selection', s:html)
call assert_match('é猫 tail', s:html)
call assert_equal(s:source_lines,getbufline(s:source,1,'$'))
call assert_equal(s:source_modified,getbufvar(s:source,'&modified'))
