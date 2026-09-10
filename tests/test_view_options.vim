let g:PlanetVim_menus_basic = 1
let g:PlanetVim_menus_nav = 1
call planet#menu#basic#Update()
call planet#menu#nav#Update()
call setline(1, repeat(['a long wrapped line ' .. repeat('text ', 50)], 20))
setlocal wrap nosmoothscroll
let s:window = win_getid()
split
call planet#preferences#Toggle('smoothscroll', 1)
call assert_true(&l:smoothscroll)
call assert_false(getwinvar(s:window, '&smoothscroll'))
for s:value in ['cursor', 'screen', 'topline']
  call assert_equal(1, planet#preferences#Set('splitkeep', s:value))
  call assert_equal(s:value, &splitkeep)
endfor
setlocal winfixheight winfixwidth
emenu 🪟w.Release\ Fixed\ Size
call assert_false(&l:winfixheight)
call assert_false(&l:winfixwidth)
if exists('+winfixbuf')
  emenu 🪟w.Pin\ Buffer
  call assert_true(&l:winfixbuf)
  call assert_fails('enew', 'E1513:')
  emenu 🪟w.Unpin\ Buffer
  call assert_false(&l:winfixbuf)
else
  call assert_equal(0, planet#preferences#Set('winfixbuf', 1, 1))
endif
if exists('+showtabpanel')
  call assert_equal(1, planet#view#Panel('columns', '18'))
  call assert_equal(1, planet#view#Panel('align', 'right'))
  call assert_match('columns:18', &tabpanelopt)
  call assert_match('align:right', &tabpanelopt)
  call assert_equal(1, planet#view#Panel('show', 2))
  call assert_equal(2, &showtabpanel)
  tabnew
  file renamed-tab.txt
  call assert_equal(2, &showtabpanel)
  tabclose
  call assert_equal(1, planet#view#Panel('show', 0))
  call assert_equal(0, &showtabpanel)
else
  call assert_equal(0, planet#view#Panel('show', 2))
endif
let &guifont = 'Monospace 10'
call assert_equal(1, planet#appearance#Font(1))
call assert_match('11\%([.]0\)\?$', &guifont)
call assert_equal(1, planet#appearance#Font(-1))
call assert_match('10\%([.]0\)\?$', &guifont)
call planet#appearance#Font(0)
call assert_equal('Monospace 10', &guifont)
if planet#appearance#NativeFullscreen()
  call planet#gui#Window('fullscreen')
  call assert_match('s', &guioptions)
  call planet#appearance#ExitFullscreen()
  call assert_notmatch('s', &guioptions)
endif
call planet#appearance#Theme('dark')
call assert_match('d', &guioptions)
call planet#appearance#Theme('system')
call assert_notmatch('d', &guioptions)
