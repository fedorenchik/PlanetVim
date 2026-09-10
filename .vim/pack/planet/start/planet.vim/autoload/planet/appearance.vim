vim9script

var script_state: dict<any> = {}

export def NativeFullscreen(): any
  return has('gui_running') && (has('gui_gtk') || has('gui_gtk3') || has('gui_gtk4')) && has('patch-9.2.0534')
enddef

export def ExitFullscreen(): any
  if planet#appearance#NativeFullscreen()
    set guioptions-=s
    return 1
  endif
  if executable('wmctrl')
    planet#term#RunGuiApp(['wmctrl', '-ir', string(v:windowid), '-b', 'remove,fullscreen'])
    return 1
  endif
  return planet#prompt#Unavailable('fullscreen window-manager control (wmctrl)', 'gui-fullscreen')
enddef

export def Font(change: any): any
  var size: any
  if !has_key(script_state, 'font')
    script_state.font = &guifont
  endif
  if change == 0
    return planet#preferences#Set('guifont', script_state.font)
  endif
  var match: any = matchlist(&guifont, '^\(.* \)\(\d\+\%([.]\d\+\)\?\)$')
  if empty(match)
    echomsg 'PlanetVim: choose a GTK font with a point size first (Settings → Font)'
    return 0
  endif
  size = str2float(match[2]) + change
  if size < 1 || size > 200
    return 0
  endif
  return planet#preferences#Set('guifont', match[1] .. printf('%g', size))
enddef

export def Theme(theme: any, save: any = 1): any
  if index(['light', 'dark', 'system'], theme) < 0
    throw 'PlanetVim: invalid appearance preference'
  endif
  if theme ==# 'dark'
    set guioptions+=d
  else
    set guioptions-=d
  endif
  if theme !=# 'system'
    planet#preferences#Set('background', theme, 0, save)
    if &background !=# theme
      colorscheme default
      planet#preferences#Set('background', theme, 0, save)
      echomsg 'PlanetVim: using the default colorscheme because the previous scheme fixes its background'
    endif
  endif
  g:PV_gui_theme = theme
  if save
    planet#config#SavePreference('PV_gui_theme', theme)
  endif
  return 1
enddef

export def Ligatures(): any
  if !exists('+guiligatures')
    return planet#prompt#Unavailable('GUI ligatures', "'guiligatures'")
  endif
  return planet#preferences#Set('guiligatures', empty(&guiligatures) ? '!"#$%&()*+-./:<=>?@[]^_{|~' : '')
enddef

export def Menus(): any
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
  return 0
enddef
