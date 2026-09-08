" Exercise the enabled menu against real native tags and preview windows.
runtime plugin/planet.vim
let g:PlanetVim_menus_dev = 1
call planet#menu#dev#Update()
let s:directory = g:PV_test_dir .. '/tag preview'
call mkdir(s:directory, 'p')
call writefile(['int alpha() {', '  return 1;', '}', 'int beta() {', '  return 2;', '}'], s:directory .. '/definitions.cpp')
call writefile(["alpha\tdefinitions.cpp\t1;\"\tf", "beta\tdefinitions.cpp\t4;\"\tf"], s:directory .. '/tags')
let &tags = escape(substitute(s:directory .. '/tags', '\\', '/', 'g'), ' ,')
set tagrelative
new
call setline(1, ['alpha();', 'beta();', 'missing_tag();'])
let s:source = bufnr()
let s:window = win_getid()
let s:source_lines = getline(1, '$')
let s:modified = &modified
let s:tagstack = gettagstack(s:window)
call cursor(1, 1)
unlet! g:PV_tags_auto_preview

func! s:Preview() abort
  return map(filter(getwininfo(), {_, window -> getwinvar(window.winid, '&previewwindow')}),
        \ {_, window -> extend(window, #{lnum:getcurpos(window.winid)[1]})})
endfunc
emenu 🪧].Toggle\ AutoPreview\ Tags
call assert_true(g:PV_tags_auto_preview)
call assert_equal(1, len(autocmd_get(#{group:'AUG_PV_TagsPreview', event:'CursorHold'})))
doautocmd <nomodeline> AUG_PV_TagsPreview CursorHold
let s:preview = s:Preview()
call assert_equal(1, len(s:preview))
call assert_equal('int alpha() {', getbufline(s:preview[0].bufnr, s:preview[0].lnum)[0])
call assert_equal(s:window, win_getid(), 'automatic preview preserves source focus')

emenu 🪧].Toggle\ AutoPreview\ Tags
call assert_false(g:PV_tags_auto_preview)
call assert_equal([], autocmd_get(#{group:'AUG_PV_TagsPreview', event:'CursorHold'}))
call cursor(2, 1)
doautocmd <nomodeline> AUG_PV_TagsPreview CursorHold
let s:preview = s:Preview()
call assert_equal('int alpha() {', getbufline(s:preview[0].bufnr, s:preview[0].lnum)[0], 'disabled preview does not follow the cursor')

emenu 🪧].Toggle\ AutoPreview\ Tags
call assert_true(g:PV_tags_auto_preview)
call assert_equal(1, len(autocmd_get(#{group:'AUG_PV_TagsPreview', event:'CursorHold'})))
doautocmd <nomodeline> AUG_PV_TagsPreview CursorHold
let s:preview = s:Preview()
call assert_equal(1, len(s:preview), 'reenabling reuses the preview window')
call assert_equal('int beta() {', getbufline(s:preview[0].bufnr, s:preview[0].lnum)[0])
call cursor(3, 1)
doautocmd <nomodeline> AUG_PV_TagsPreview CursorHold
call assert_equal(s:window, win_getid(), 'missing tags leave source focus unchanged')
call assert_equal(s:source_lines, getbufline(s:source, 1, '$'))
call assert_equal(s:modified, getbufvar(s:source, '&modified'))
call assert_equal(s:tagstack, gettagstack(s:window))
emenu 🪧].Toggle\ AutoPreview\ Tags
pclose
