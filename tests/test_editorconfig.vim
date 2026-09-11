let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim

" The only provider must be Vim's own optional package.
call assert_false(isdirectory(g:PV_root .. '/.vim/pack/basic/start/editorconfig-vim'))
let s:provider = resolve($VIMRUNTIME .. '/pack/dist/opt/editorconfig/plugin/editorconfig.vim')
let s:loaded = filter(map(getscriptinfo(), {_, item -> resolve(item.name)}), {_, name -> name =~# '/plugin/editorconfig\.vim$'})
call assert_equal([s:provider], s:loaded)
for s:command in ['EditorConfigReload', 'EditorConfigEnable', 'EditorConfigDisable']
  call assert_equal(2, exists(':' .. s:command))
endfor
call assert_equal(['fugitive://.*', 'scp://.*'], g:EditorConfig_exclude_patterns)

let s:project = g:PV_test_dir .. '/editorconfig project'
call mkdir(s:project, 'p')
let s:config = s:project .. '/.editorconfig'
let s:rules = ['root = true', '[*.txt]', 'indent_style = space', 'indent_size = 3',
      \ 'tab_width = 6', 'end_of_line = lf', 'insert_final_newline = true',
      \ 'trim_trailing_whitespace = true']
call writefile(s:rules, s:config)
let s:file = s:project .. '/existing text.txt'
call writefile(['one', 'two'], s:file)
execute 'edit ' .. fnameescape(s:file)
call assert_equal([1, 3, 6, 'unix'], [&l:expandtab, &l:shiftwidth, &l:tabstop, &l:fileformat])
call setline(1, ['one  ', "two\t"])
write
call assert_equal(['one', 'two', ''], readfile(s:file, 'b'))

" Existing menu commands still reload rules and control automatic application.
let s:rules[3] = 'indent_size = 2'
call writefile(s:rules, s:config)
emenu 🎚️{.EditorConfig.Reload
call assert_equal(2, &l:shiftwidth)
emenu 🎚️{.EditorConfig.Disable\ for\ buffer
setlocal shiftwidth=7
EditorConfigReload
call assert_equal(7, &l:shiftwidth)
unlet b:EditorConfig_disable
EditorConfigReload
call assert_equal(2, &l:shiftwidth)

emenu 🎚️{.EditorConfig.Disable
" Sleuth independently reads EditorConfig; isolate this provider's toggle.
let g:sleuth_automatic = 0
set shiftwidth=7 tabstop=8 noexpandtab
enew
execute 'edit ' .. fnameescape(s:project .. '/new file.txt')
call assert_equal(7, &l:shiftwidth)
emenu 🎚️{.EditorConfig.Enable
doautocmd BufNewFile
call assert_equal([1, 2, 6], [&l:expandtab, &l:shiftwidth, &l:tabstop])
