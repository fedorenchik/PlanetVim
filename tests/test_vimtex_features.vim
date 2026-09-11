let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
let s:file = g:PV_test_dir .. '/sample.tex'
let s:lines = ['\documentclass{article}', '\begin{document}', '\section{Sample}', '\begin{itemize}', '\item first', '\end{itemize}', '\begin{equation}', 'x = 1', '\end{equation}', '\end{document}']
call writefile(s:lines, s:file)
execute 'edit ' .. fnameescape(s:file)
call assert_equal('tex', &filetype)
call assert_true(exists('b:vimtex'))
call cursor(5, 8)
call assert_equal(1, planet#writing#Tex('environment'))
call assert_equal('\begin{enumerate}', getline(4))
call assert_equal('\end{enumerate}', getline(6))
call planet#writing#Tex('environment')
call assert_equal(s:lines, getline(1, '$'))
call cursor(8, 2)
call assert_equal(1, planet#writing#Tex('star'))
call assert_equal('\begin{equation*}', getline(7))
call assert_equal('\end{equation*}', getline(9))
call planet#writing#Tex('star')
call assert_equal(1, planet#writing#Tex('break'))
call assert_equal('x = 1 \\', getline(8))
call planet#writing#Tex('break')
call assert_equal(s:lines, getline(1, '$'))
call assert_equal(2, exists(':VimtexCompileSS'))
call assert_equal(2, exists(':VimtexCompileSelected'))
call assert_equal(1, planet#writing#Tex('toc'))
for s:attempt in range(100)
  if !empty(filter(getbufinfo(), {_, b -> getbufvar(b.bufnr, '&filetype') ==# 'vimtex-toc'})) | break | endif
  sleep 10m
endfor
call assert_true(!empty(filter(getbufinfo(), {_, b -> getbufvar(b.bufnr, '&filetype') ==# 'vimtex-toc'})))
bwipeout!
enew!
call assert_equal(0, planet#writing#Tex('environment'))
call assert_match('Open a TeX document', planet#writing#LastError())
