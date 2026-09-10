vim9script

export def ConfigUpdate(conf_var: any): any
  if !get(g:, 'PV_initializing', 0)
    planet#config#SavePreference(conf_var, eval(conf_var))
  endif
  return 0
enddef

#TODO: add mod <Alt> - means search regex, e.g. '\.' when press '.'
#TODO:    (can use getcharmod()), and change pattern
#TODO:    '\\V' (very non magic) to '\\v' (very magic)
g:PV_p = '\.'
legacy def! planet#planet#f(): any
  var c: any = getchar()
  if c == 27
    return 0
  endif
  var c1: any = nr2char(c)
  g:PV_p = c1
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
  normal m9
  return 0
enddef

export def F(): any
  var c: any = getchar()
  if c == 27
    return 0
  endif
  var c1: any = nr2char(c)
  g:PV_p = c1
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
  normal m9
  return 0
enddef

legacy def! planet#planet#semicolon(): any
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
  normal m9
  return 0
enddef

legacy def! planet#planet#comma(): any
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
  normal m9
  return 0
enddef

g:PV_pp = '\.\.'
legacy def! planet#planet#t(): any
  var c2: any
  var c: any = getchar()
  if c == 27
    return 0
  endif
  var c1: any = nr2char(c)
  c = getchar()
  if c == 27
    return 0
  endif
  if c != 13
    c2 = nr2char(c)
    g:PV_pp = c1 .. c2
    silent! exe "keepp keepj normal /\\V" .. g:PV_pp .. "\<CR>"
    normal m0
  else
    g:PV_p = c1
    silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
    normal m9
  endif
  return 0
enddef

export def T(): any
  var c2: any
  var c: any = getchar()
  if c == 27
    return 0
  endif
  var c1: any = nr2char(c)
  c = getchar()
  if c == 27
    return 0
  endif
  if c != 13
    c2 = nr2char(c)
    g:PV_pp = c1 .. c2
    silent! exe "keepp keepj normal ?\\V" .. g:PV_pp .. "\<CR>"
    normal m0
  else
    g:PV_p = c1
    silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
    normal m9
  endif
  return 0
enddef

legacy def! planet#planet#h(): any
  silent! exe "keepp keepj normal ?\\V" .. g:PV_pp .. "\<CR>"
  normal m0
  return 0
enddef

legacy def! planet#planet#l(): any
  silent! exe "keepp keepj normal /\\V" .. g:PV_pp .. "\<CR>"
  normal m0
  return 0
enddef

legacy def! planet#planet#j(): any
  try
    laf
  catch
    silent! lne
  endtry
  return 0
enddef

legacy def! planet#planet#k(): any
  try
    lbe
  catch
    silent! lp
  endtry
  return 0
enddef

var script_mode_maps = { 'b': ':call planet#planet#comma()<CR>', 'B': ':bp<CR>', 'e': 'g;', 'E': 'g,',
     'f': ':call planet#planet#f()<CR>', 'F': ':call planet#planet#F()<CR>', 'ge': '1gt', 'gE': ':tabl<CR>',
     'h': ':call planet#planet#h()<CR>', 'j': ':call planet#planet#j()<CR>', 'k': ':call planet#planet#k()<CR>',
     'l': ':call planet#planet#l()<CR>', 't': ':call planet#planet#t()<CR>', 'T': ':call planet#planet#T()<CR>',
     'w': ':call planet#planet#semicolon()<CR>', 'W': ':bn<CR>'}
var script_saved_maps = {}

export def ModeKeys(): any
  return keys(script_mode_maps)
enddef

export def SetMode(mode: any): any
  var key: any
  var rhs: any
  if index(['e', 's', 'p'], mode) < 0
    throw 'PlanetVim: mode must be e, s, or p'
  endif
  # Remove only mappings still owned by the previous mode.
  for [item_key, item_rhs] in items(script_mode_maps)
    key = item_key
    rhs = item_rhs
    if has_key(script_saved_maps, key)
      if maparg(key, 'n') ==# rhs
        execute 'nunmap ' .. key
        if !empty(script_saved_maps[key])
          mapset('n', 0, script_saved_maps[key])
        endif
      endif
    endif
  endfor
  script_saved_maps = {}
  &insertmode = mode ==# 'e'
  &selectmode = mode ==# 'e' ? 'mouse,key' :  ''
  &keymodel = mode ==# 'e' ? 'startsel,stopsel' :  ''
  &backspace = mode ==# 'e' ? 'indent,eol,nostop' :  'start'
  &selection = mode ==# 'e' ? 'exclusive' :  'inclusive'
  if mode ==# 'e'
    set guioptions-=c
    set guioptions+=r
  else
    set guioptions+=c
    set guioptions-=r
  endif
  if mode ==# 'p'
    for [item_key, item_rhs] in items(script_mode_maps)
      key = item_key
      rhs = item_rhs
      script_saved_maps[key] = maparg(key, 'n', 0, 1)
      execute 'nnoremap <silent> ' .. key .. ' ' .. rhs
    endfor
  endif
  g:PV_mode = mode
  if empty(v:this_session)
    planet#planet#ConfigUpdate('g:PV_mode')
  endif
  return 0
enddef

export def SetEasyMode(): any
  planet#planet#SetMode('e')
  return 0
enddef

export def SetStandardMode(): any
  planet#planet#SetMode('s')
  return 0
enddef

export def SetSuperChargedMode(): any
  planet#planet#SetMode('p')
  return 0
enddef

export def SetGuiDialogs(): any
  set guioptions-=c
  return 0
enddef

export def SetTextDialogs(): any
  set guioptions+=c
  return 0
enddef

export def IsGuiDialogs(): any
  return stridx(&guioptions, 'c') == -1
enddef

export def PlanetToggle(): any
  planet#menu#Group('planet')
  return 0
enddef

export def BasicToggle(): any
  planet#menu#Group('basic')
  return 0
enddef

export def EditingToggle(): any
  planet#menu#Group('editing')
  return 0
enddef

export def DevelopmentToggle(): any
  planet#menu#Group('dev')
  return 0
enddef

export def ToolsToggle(): any
  planet#menu#Group('tools')
  return 0
enddef

export def NavigationToggle(): any
  planet#menu#Group('nav')
  return 0
enddef

export def SettingsToggle(): any
  planet#menu#Group('settings')
  return 0
enddef

export def SetPerSessionOptions(): any
  planet#session#SetCwdSession()
  silent! rviminfo!
  return 0
enddef

export def SaveAll(): any
  try
    confirm wall
  catch
    echohl ErrorMsg
    echom 'PlanetVim: save cancelled or failed: ' .. v:exception
    echohl None
    return v:false
  endtry
  if !empty(getbufinfo({'bufmodified': 1}))
    echohl WarningMsg
    echom 'PlanetVim: unsaved changes remain; keeping the editor open.'
    echohl None
    return v:false
  endif
  return v:true
enddef

export def SaveExit(): any
  if planet#planet#SaveAll()
    qa
  endif
  return 0
enddef

export def EmergencyExit(): any
  set noautowrite
  set noautowriteall
  cquit!
  return 0
enddef

export def CheckExitSaveSession(): any
  if empty(v:this_session) || v:exiting != 0
    return 0
  endif
  #TODO: auto-save and auto-load quickfix/loclist files (up to 10 of each, loclists: for each window)
  exe 'SSave! ' .. fnamemodify(v:this_session, ":t")
  return 0
enddef

export def EditVimVar(var_name: any): any
  var var_value: any = inputdialog(var_name .. '=', eval(var_name), 'CANCELLED')
  if var_value == 'CANCELLED'
    return 0
  endif
  execute var_name .. ' = ' .. var_value
  return 0
enddef
