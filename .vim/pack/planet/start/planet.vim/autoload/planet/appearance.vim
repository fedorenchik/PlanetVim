scriptversion 4

func! planet#appearance#NativeFullscreen() abort
  return has('gui_running') && (has('gui_gtk') || has('gui_gtk3') || has('gui_gtk4')) && has('patch-9.2.0534')
endfunc

func! planet#appearance#ExitFullscreen() abort
  if planet#appearance#NativeFullscreen()
    set guioptions-=s
    return 1
  endif
  if executable('wmctrl')
    call planet#term#RunGuiApp(['wmctrl', '-ir', string(v:windowid), '-b', 'remove,fullscreen'])
    return 1
  endif
  return planet#prompt#Unavailable('fullscreen window-manager control (wmctrl)', 'gui-fullscreen')
endfunc

func! planet#appearance#Font(change) abort
  if !exists('s:font') | let s:font = &guifont | endif
  if a:change == 0 | return planet#preferences#Set('guifont', s:font) | endif
  let l:match = matchlist(&guifont, '^\(.* \)\(\d\+\%([.]\d\+\)\?\)$')
  if empty(l:match)
    echomsg 'PlanetVim: choose a GTK font with a point size first (Settings → Font)'
    return 0
  endif
  let l:size = str2float(l:match[2]) + a:change
  if l:size < 1 || l:size > 200 | return 0 | endif
  return planet#preferences#Set('guifont', l:match[1] .. printf('%g', l:size))
endfunc

func! planet#appearance#Theme(theme, save = 1) abort
  if index(['light', 'dark', 'system'], a:theme) < 0 | throw 'PlanetVim: invalid appearance preference' | endif
  if a:theme ==# 'dark' | set guioptions+=d | else | set guioptions-=d | endif
  if a:theme !=# 'system'
    call planet#preferences#Set('background', a:theme, 0, a:save)
    if &background !=# a:theme
      colorscheme default
      call planet#preferences#Set('background', a:theme, 0, a:save)
      echomsg 'PlanetVim: using the default colorscheme because the previous scheme fixes its background'
    endif
  endif
  let g:PV_gui_theme = a:theme
  if a:save | call planet#config#SavePreference('PV_gui_theme', a:theme) | endif
  return 1
endfunc

func! planet#appearance#Ligatures() abort
  if !exists('+guiligatures') | return planet#prompt#Unavailable('GUI ligatures', "'guiligatures'") | endif
  return planet#preferences#Set('guiligatures', empty(&guiligatures) ? '!"#$%&()*+-./:<=>?@[]^_{|~' : '')
endfunc

func! planet#appearance#Menus() abort
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Font\ Larger <Cmd>call planet#appearance#Font(1)<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Font\ Smaller <Cmd>call planet#appearance#Font(-1)<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Reset\ Font\ Size <Cmd>call planet#appearance#Font(0)<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Toggle\ Ligatures <Cmd>call planet#appearance#Ligatures()<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Dark\ Colors\ and\ Widgets <Cmd>call planet#appearance#Theme('dark')<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Light\ Colors\ and\ Widgets <Cmd>call planet#appearance#Theme('light')<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Desktop\ Widget\ Theme <Cmd>call planet#appearance#Theme('system')<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Toggle\ Fullscreen <Cmd>call planet#gui#Window('fullscreen')<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Exit\ Fullscreen <Cmd>call planet#appearance#ExitFullscreen()<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Current\ Values <Cmd>set guifont? background? guioptions?<CR>
  PlanetMenu an 900.57 ⚙️&\\.Appearance.Help <Cmd>help gui<CR>
endfunc
