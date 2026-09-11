let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
let s:root = g:PV_test_dir .. '/fern fixture'
call mkdir(s:root .. '/nested/deeper', 'p')
call writefile(['preview content'], s:root .. '/fern-file.txt')
call writefile(['deep file'], s:root .. '/nested/deeper/deep.txt')
func! s:Wait(expression) abort
  for l:attempt in range(300)
    if eval(a:expression) | return 1 | endif
    sleep 10m
  endfor
  call assert_report('Timed out: ' .. a:expression)
  return 0
endfunc
execute 'Fern ' .. fnameescape(s:root)
call s:Wait('search("fern-file.txt", "nw") > 0')
call search('fern-file.txt', 'w')
let s:fernwin = win_getid()
call assert_equal(1, planet#fern#Action('preview'))
call feedkeys('', 'x')
call s:Wait('!empty(filter(getwininfo(), {_, w -> getwinvar(w.winid, "&previewwindow")}))')
let s:preview = filter(getwininfo(), {_, w -> getwinvar(w.winid, '&previewwindow')})
if !empty(s:preview)
  call assert_equal(['preview content'], getbufline(s:preview[0].bufnr, 1, '$'))
endif
call win_gotoid(s:fernwin)
call search('nested', 'w')
call assert_equal(1, planet#fern#Action('expand-tree:stay'))
call feedkeys('', 'x')
call s:Wait('search("deep.txt", "nw") > 0')
pclose
