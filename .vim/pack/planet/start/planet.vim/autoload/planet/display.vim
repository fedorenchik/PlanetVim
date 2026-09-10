vim9script
export def Popup(key: any, value: any): any
  if !exists('+pumopt')
    return planet#prompt#Unavailable('completion popup appearance', "'pumopt'")
  endif
  if index(['border', 'opacity'], key) < 0
    throw 'PlanetVim: invalid popup setting'
  endif
  var flags: any = filter(split(eval('&pumopt'), ','), (_, lambda_value) => stridx(lambda_value, key .. ':') != 0)
  if !empty(value)
    add(flags, key .. ':' .. value)
  endif
  return planet#preferences#Set('pumopt', join(flags, ','))
enddef

export def Padding(): any
  if !exists('+scrolloffpad')
    return planet#prompt#Unavailable('cursor padding at file boundaries', "'scrolloffpad'")
  endif
  planet#preferences#Set('scrolloffpad', eval('&scrolloffpad') > 0 ? 0 :  1, 1)
  if eval('&scrolloffpad') > 0 && &scrolloff == 0
    setlocal scrolloff=2
  endif
  return 0
enddef

export def Click(info: any): any
  if get(info, 'button', '') ==# 'l' && win_gotoid(get(info, 'winid', 0))
    planet#actions#Open()
  endif
  return 0
enddef

export def Status(kind: any): any
  if kind ==# 'restore'
    if exists('w:PV_display_status')
      &l:statusline = w:PV_display_status.line
      if exists('+statuslineopt')
        execute '&l:statuslineopt = ' .. string(w:PV_display_status.options)
      endif
      unlet w:PV_display_status
    endif
    return 1
  endif
  if index(['multiline', 'clickable'], kind) < 0
    throw 'PlanetVim: invalid status-line preset'
  endif
  if kind ==# 'multiline' && !exists('+statuslineopt')
    return planet#prompt#Unavailable('multiline status lines', "'statuslineopt'")
  endif
  if kind ==# 'clickable' && !has('statusline_click')
    return planet#prompt#Unavailable('clickable status lines', 'stl-%[FuncName]')
  endif
  if !exists('w:PV_display_status')
    w:PV_display_status = {line:  &l:statusline, options:  exists('+statuslineopt') ? eval('&l:statuslineopt') :  ''}
  endif
  &l:statusline = '%f %h%m%r%=%l:%c %P'
  if kind ==# 'multiline'
    execute '&l:statuslineopt = ' .. string('maxheight:2')
    &l:statusline ..= '%@%y %{&fileencoding} %{&fileformat}'
  else
    if exists('+statuslineopt')
      execute '&l:statuslineopt = ' .. string('maxheight:1')
    endif
    &l:statusline = '%[planet#display#Click] Find Menu Action %[] ' .. &l:statusline
  endif
  return 1
enddef

export def Menus(group: any): any
  if group ==# 'basic'
    PlanetMenu an 170.18 📺&v.Image\ Preview.Open\ Local\ Image <Cmd>call planet#image#Open()<CR>
    PlanetMenu an 170.18 📺&v.Image\ Preview.Close <Cmd>call planet#image#Close()<CR>
    PlanetMenu an 170.18 📺&v.Image\ Preview.Help <Cmd>call planet#learn#Help(planet#image#Supported() ? 'popup-image' : 'popup')<CR>
  else
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.Rounded\ Border <Cmd>call planet#display#Popup('border', 'round')<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.No\ Border <Cmd>call planet#display#Popup('border', '')<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.Opacity\ 85% <Cmd>call planet#display#Popup('opacity', '85')<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.Opaque <Cmd>call planet#display#Popup('opacity', '100')<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Toggle\ Cursor\ Padding <Cmd>call planet#display#Padding()<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Two\ Lines\ (this\ window) <Cmd>call planet#display#Status('multiline')<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Clickable\ Actions\ (this\ window) <Cmd>call planet#display#Status('clickable')<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Restore <Cmd>call planet#display#Status('restore')<CR>
    PlanetMenu an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Help <Cmd>help status-line<CR>
  endif
  return 0
enddef
