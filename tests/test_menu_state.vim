" Indicators preserve canonical paths, ordering, mappings, and live option scope.
aunmenu *
silent! tlunmenu *
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
set noinsertmode
call planet#menu#Refresh()
call planet#menu_state#Refresh()
call assert_equal(0, planet#menu_state#Stats().errors, 'every available state reader must evaluate')
let s:settings = planet#menu#RootPath('⚙️&\\')
let s:planet = planet#menu#RootPath('🌐&P')
let s:wrap = s:settings .. ".Toggle 'wrap'"
let s:before = menu_info(s:settings).submenus
let s:mapping = menu_info(s:wrap, 'i')
let s:normal = menu_info(s:wrap, 'n')
let s:tip = menu_info(s:wrap, 't').rhs
setlocal nowrap
call planet#menu_state#Refresh()
call assert_match('^☐ ', menu_info(s:wrap).display)
setlocal wrap
call planet#menu_state#Refresh()
call assert_match('^☑ ', menu_info(s:wrap).display)
call assert_equal(s:mapping.rhs, menu_info(s:wrap, 'i').rhs)
call assert_equal(s:normal.rhs, menu_info(s:wrap, 'n').rhs)
call assert_equal(s:normal.accel, menu_info(s:wrap).accel)
call assert_equal(s:tip, menu_info(s:wrap, 't').rhs)
call assert_equal(map(copy(s:before), {_, v -> substitute(v, '^[☑☐●○] ', '', '')}), map(menu_info(s:settings).submenus, {_, v -> substitute(v, '^[☑☐●○] ', '', '')}))
let s:stats = planet#menu_state#Stats()
call planet#menu_state#Refresh()
call assert_equal(s:stats, planet#menu_state#Stats(), 'unchanged state must not rebuild menus')
call assert_true(s:stats.entries > 70)

" WinEnter must display the destination window's local values.
let s:first = win_getid()
split
setlocal nowrap
call planet#menu_state#Refresh()
call assert_match('^☐ ', menu_info(s:wrap).display)
call win_gotoid(s:first)
call assert_match('^☑ ', menu_info(s:wrap).display)

" Real menu actions and direct :set both update the same indicator.
execute 'emenu ' .. escape(s:wrap, ' ')
call planet#menu_state#Refresh()
call assert_false(&wrap)
call assert_match('^☐ ', menu_info(s:wrap).display)
setlocal wrap
call planet#menu_state#Refresh()
call assert_match('^☑ ', menu_info(s:wrap).display)

" Global flags and radio presets reflect actual values, not last menu clicked.
set wildoptions+=pum
call planet#menu_state#Refresh()
call assert_match('^☑ ', menu_info(s:settings .. '.Command-line Completion.Toggle Popup').display)
set wildoptions-=pum
call planet#menu_state#Refresh()
call assert_match('^☐ ', menu_info(s:settings .. '.Command-line Completion.Toggle Popup').display)
setlocal expandtab tabstop=4 shiftwidth=4
call planet#menu_state#Refresh()
call assert_match('^● ', menu_info(s:settings .. '.Tabs: 4').display)
call assert_match('^○ ', menu_info(s:settings .. '.Tabs: 2').display)
setlocal shiftwidth=3
call planet#menu_state#Refresh()
call assert_match('^○ ', menu_info(s:settings .. '.Tabs: 4').display)

" Separate branches with identical leaf names must not share translations.
let s:environment = planet#menu#RootPath('🎚️&{')
EditorConfigEnable
set nospell
call planet#menu_state#Refresh()
call assert_match('^● ', menu_info(s:environment .. '.EditorConfig.Enable').display)
call assert_match('^○ ', menu_info(planet#menu#RootPath('🔠&-') .. '.Enable').display)
EditorConfigDisable
call planet#menu_state#Refresh()
call assert_match('^○ ', menu_info(s:environment .. '.EditorConfig.Enable').display)
call assert_match('^● ', menu_info(s:environment .. '.EditorConfig.Disable').display)
call planet#search#Case('smart')
call planet#menu_state#Refresh()
call assert_match('^● ', menu_info(planet#menu#RootPath('🔎&/') .. '.Case.smart').display)
let b:lsp_diagnostics_enabled = 0
call planet#menu_state#Refresh()
call assert_match('^● ', menu_info(planet#menu#RootPath('❇️&[') .. '.Status.Disable Diagnostics').display)
syntax off
call planet#menu_state#Refresh()
call assert_match('^☐ ', menu_info(planet#menu#RootPath('⌨️&\|') .. '.Syntax.Toggle').display)

" Finder labels and canonical paths remain usable after the checked state flips.
let s:action = filter(planet#actions#Search('wrap'), {_, v -> v.label =~# "Toggle 'wrap'$"})[0]
call assert_notmatch('[☑☐●○]', s:action.label)
setlocal nowrap
call planet#menu_state#Refresh()
call assert_false(empty(menu_info(s:action.path)))
setlocal wrap

" Labels, aliases and state survive root translation and hidden groups.
call planet#menu#Style('plain')
call assert_match('^● ', menu_info('[P].Menu Style: Plain').display)
call assert_match('^○ ', menu_info('[P].Menu Style: Emoji (default)').display)
call planet#menu#Style('descriptive')
call planet#menu#Group('settings')
call assert_match('^● ', menu_info('PlanetVim.Settings Menus').display)
call assert_match('^○ ', menu_info('PlanetVim.Basic Menus').display)
set number!
call planet#menu_state#Refresh()
call assert_equal({}, menu_info('File'))
call assert_match('^☑ ', menu_info("Settings.Toggle 'wrap'").display)
call planet#menu#Style('emoji')
call assert_equal(0, planet#menu_state#Stats().errors)

" Custom mode mappings, script IDs, disabled entries and tips survive updates.
func! s:StateCallback() abort
  let g:PV_state_callback = 1
endfunc
call planet#menu_state#Begin()
menutrans clear
execute planet#menu_help#Entry('anoremenu <silent> 100.10 ', 'StateProbe.Before', '<Nop>')
execute planet#menu_help#Entry('anoremenu <silent> 100.10 ', 'StateProbe.Wrap', '<Cmd>setlocal wrap!<CR>')
execute planet#menu_help#Entry('inoremenu <silent> 100.10 ', 'StateProbe.Wrap', '<Cmd>call <SID>StateCallback()<CR>')
execute planet#menu_help#Entry('anoremenu 100.10 ', 'StateProbe.After', '<Nop>')
inoremenu disable StateProbe.Wrap
let s:insert = menu_info('StateProbe.Wrap', 'i')
setlocal nowrap
call planet#menu_state#Refresh()
call assert_equal(['Before', '☐ Wrap', 'After'], menu_info('StateProbe').submenus)
call assert_equal(s:insert.rhs, menu_info('StateProbe.Wrap', 'i').rhs)
call assert_false(menu_info('StateProbe.Wrap', 'i').enabled)
call assert_match('<SNR>', s:insert.rhs)
let s:aliases = planet#menu_state#Stats().aliases
setlocal wrap
call planet#menu_state#Refresh()
setlocal nowrap
call planet#menu_state#Refresh()
call assert_equal(s:aliases, planet#menu_state#Stats().aliases, 'translations must be reused')

" Escaped dots, spaces and literal ampersands are valid canonical leaf names.
execute planet#menu_help#Entry('anoremenu 100.20 ', 'StateProbe.Dot\.\ &&\ space', '<Cmd>setlocal number!<CR>')
setlocal nonumber
call planet#menu_state#Refresh()
call assert_equal('☐ Dot. & space', menu_info('StateProbe.Dot\. & space').display)
setlocal number
call planet#menu_state#Refresh()
call assert_equal('☑ Dot. & space', menu_info('StateProbe.Dot\. & space').display)
nnoremenu StateProbe.☑\ Literal <Cmd>echo 'literal label'<CR>
call assert_equal(1, len(filter(planet#action_index#Build('StateProbe', 'StateProbe', 'basic'), {_, v -> v.path ==# 'StateProbe.☑\ Literal'})))
aunmenu StateProbe
setlocal wrap
call planet#menu_state#Refresh()
call assert_equal({}, menu_info('StateProbe'), 'updates must not resurrect removed menus')
