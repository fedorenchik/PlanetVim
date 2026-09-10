aunmenu *
silent! tlunmenu *
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
set noinsertmode
call planet#menu#Style('descriptive')
call assert_false(empty(menu_info('PlanetVim')))
call assert_false(empty(menu_info('File')))
call assert_equal({}, menu_info('Buffers'))
emenu PlanetVim.Navigation\ Menus
call assert_false(empty(menu_info('Buffers')))
call assert_equal({}, menu_info('File'))
call assert_equal('nav', g:PV_menu_group)
new
file style-buffer.txt
call planet#buffer#AddBuffers()
call assert_match('style-buffer', string(menu_info('Buffers.Buffer List')))
emenu PlanetVim.Editing\ Menus
call planet#buffer#AddBuffers()
call planet#gui#MenuListVimServers()
call planet#session#MenuList()
call assert_equal({}, menu_info('Buffers'))
call assert_equal({}, menu_info('GUI'))
call assert_equal({}, menu_info('Sessions'))
call assert_false(empty(menu_info('Registers')))
call planet#planet#PlanetToggle()
call assert_false(empty(menu_info('PlanetVim')))
call planet#menu#Style('plain')
call assert_false(empty(menu_info('[f]')))
call assert_false(empty(menu_info('[;]')), 'diff is translated too')
call assert_false(empty(menu_info('[]]')), 'tags are translated too')
call planet#menu#Style('emoji')
call assert_false(empty(menu_info('📁f')))
call assert_equal({}, menu_info('File'))
call assert_equal({}, menu_info('[f]'))
call planet#menu#Style('descriptive')
call assert_equal('editing', g:PV_menu_group)
call assert_false(empty(menu_info('Registers')))
let s:saved = json_decode(readfile(planet#paths#Config() .. '/preferences.json')[0])
call assert_equal('descriptive', s:saved.PV_menu_style)
call assert_equal('editing', s:saved.PV_menu_group)
for s:group in ['basic', 'editing', 'dev', 'tools', 'nav', 'settings']
  call planet#menu#Group(s:group)
  call planet#run#UpdateRunMenu()
  for [s:owner, s:root, s:label] in planet#menu#Roots()
    call assert_equal(s:owner ==# 'planet' || s:owner ==# s:group,
          \ !empty(menu_info(escape(s:label, '\.'), 'n')), s:group .. ': ' .. s:label)
  endfor
endfor
