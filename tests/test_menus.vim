execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
packloadall
set nomore noautowrite noautowriteall
let s:groups = [
      \ ['planet', 'planet', '🌐P'], ['basic', 'basic', '📁f'],
      \ ['editing', 'edit', '📜z'], ['dev', 'dev', '🔨b'],
      \ ['tools', 'tools', '🔧o'], ['nav', 'nav', '🗂️t'],
      \ ['settings', 'settings', '⚙️\\']]
for [s:variable, s:module, s:root] in s:groups
  let g:['PlanetVim_menus_' .. s:variable] = 0
  call call('planet#menu#' .. s:module .. '#Update', [])
  call assert_equal({}, menu_info(s:root), s:module .. ' menu removed')
  let g:['PlanetVim_menus_' .. s:variable] = 1
  call call('planet#menu#' .. s:module .. '#Update', [])
  call assert_false(empty(menu_info(s:root)), s:module .. ' menu restored')
endfor
let s:nav = g:PlanetVim_menus_nav
emenu 🌐P.Settings\ Menus
call assert_equal(s:nav, g:PlanetVim_menus_nav)
call assert_equal(0, g:PlanetVim_menus_settings)
emenu 🌐P.Settings\ Menus
call assert_equal(1, g:PlanetVim_menus_settings)
for s:label in ['QF/LL', 'Terminal', 'Output']
  call assert_match('^<Cmd>call planet#winbar#Preset', get(menu_info('⌨️|.WinBar.Set for ' .. s:label, 'n'), 'rhs', ''))
endfor
new
call setline(1, ['Hello hex', 'second line'])
let s:text = getline(1, '$')
call assert_true(planet#tools#XxdToHex())
call assert_equal('xxd', &filetype)
call assert_true(planet#tools#XxdFromHex())
call assert_equal(s:text, getline(1, '$'))
call assert_true(&modified)
let g:xxdprogram = 'missing-planetvim-xxd'
call assert_equal(0, planet#tools#XxdToHex())
call assert_equal(s:text, getline(1, '$'))
unlet g:xxdprogram
set nomodified
execute 'file ' .. fnameescape(g:PV_test_dir .. '/original.txt')
let s:number = bufnr()
call planet#buffer#AddBuffers()
execute 'file ' .. fnameescape(g:PV_test_dir .. '/renamed.txt')
call planet#buffer#AddBuffers()
let s:list = string(menu_info('📖u.Buffer List', 'n'))
call assert_match('renamed', s:list)
call assert_notmatch('original', s:list)
bdelete
call planet#buffer#AddBuffers()
call assert_notmatch('renamed', string(menu_info('📖u.Buffer List', 'n')))
call assert_equal(0, planet#workflow#ProjectDirectory(''))
call assert_equal(0, planet#workflow#ProjectDirectory(g:PV_test_dir .. '/missing'))
set nomore

call planet#menu#Plain()
call assert_false(empty(menu_info('[f]')), 'plain file menu is available')
set nomore
