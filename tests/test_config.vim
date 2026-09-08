let s:custom = ["let g:PV_mode = 'e'", 'set tabstop=3 shiftwidth=3',
      \ 'set selection=inclusive', 'nnoremap f :let g:custom_map = 1<CR>',
      \ 'let g:custom_loads = get(g:, "custom_loads", 0) + 1']
call writefile(s:custom, g:PV_config)
call planet#config#Initialize()
call assert_equal('e', g:PV_mode)
call assert_true(&insertmode)
call assert_equal('mouse,key', &selectmode)
call assert_equal('inclusive', &selection)
call assert_equal(3, &tabstop)
call assert_match('custom_map', maparg('f', 'n'))
runtime plugin/settings.vim
call planet#config#Initialize()
call assert_equal(1, g:custom_loads)
call assert_equal(3, &tabstop)
for s:mode in ['p', 's', 'e', 'p', 'e', 's', 'p', 'p', 's']
  call planet#planet#SetMode(s:mode)
  call assert_equal(s:mode ==# 'e', &insertmode)
  if s:mode ==# 'p'
    call assert_match('planet#planet#f', maparg('f', 'n'))
  else
    call assert_match('custom_map', maparg('f', 'n'))
  endif
endfor
call assert_equal(s:custom, readfile(g:PV_config))
let s:preferences = planet#paths#Config() .. '/preferences.json'
call assert_equal('s', json_decode(readfile(s:preferences)[0]).PV_mode)
call assert_true(planet#config#SavePreference('g:PlanetVim_menus_basic', 0))
let s:before = readfile(s:preferences)
call assert_false(planet#config#SavePreference('g:PV_mode', 'invalid'))
call assert_equal(s:before, readfile(s:preferences))
call writefile(['invalid JSON'], s:preferences)
call assert_false(planet#config#SavePreference('g:PV_mode', 'e'))
call assert_equal(['invalid JSON'], readfile(s:preferences))
call delete(s:preferences)
call delete(g:PV_config)
unlet g:PV_config_loaded
call planet#config#Initialize()
call assert_equal('s', g:PV_mode)
call writefile(['throw "bad custom config"'], g:PV_config)
unlet g:PV_config_loaded
try
  call planet#config#Initialize()
  call assert_report('invalid custom config must be reported')
catch /bad custom config/
  call assert_equal(0, g:PV_initializing)
endtry
call assert_equal(0, get(g:, 'PV_config_loaded', 0))
set nomore noinsertmode
