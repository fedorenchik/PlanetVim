vim9script
export def Panel(key: any, arg_value: any = v:null): any
  if !exists('+showtabpanel') || !exists('+tabpanelopt')
    return planet#prompt#Unavailable('native tab panel', 'tabpanel')
  endif
  if key ==# 'show'
    return planet#preferences#Set('showtabpanel', arg_value)
  endif
  var value: any = arg_value
  if key ==# 'columns'
    if value == null
      value = planet#prompt#Ask('Tab panel width in columns: ', '20')
    endif
    if value == null || empty(value)
      return 0
    endif
    if string(value) !~# "^'\\?\\d\\+'\\?$" || str2nr(value) < 1
      echomsg 'PlanetVim: enter a positive panel width'
      return 0
    endif
  elseif key !=# 'align' || index(['left', 'right'], value) < 0
    throw 'PlanetVim: invalid tab panel setting'
  endif
  var parts: any = filter(split(eval('&tabpanelopt'), ','), (_, lambda_v) => stridx(lambda_v, key .. ':') != 0)
  add(parts, key .. ':' .. value)
  return planet#preferences#Set('tabpanelopt', join(parts, ','))
enddef

export def Menus(group: any): any
  if group ==# 'basic'
    PlanetMenu an 150.50 📺&v.Scrolling.Toggle\ Smooth\ Wrapped-line\ Scrolling <Cmd>call planet#preferences#Toggle('smoothscroll', 1)<CR>
    PlanetMenu an 150.50 📺&v.Scrolling.Scroll\ Up\ One\ Line<Tab>CTRL-E <C-e>
    PlanetMenu an 150.50 📺&v.Scrolling.Scroll\ Down\ One\ Line<Tab>CTRL-Y <C-y>
    PlanetMenu an 150.50 📺&v.Scrolling.Cursor\ Line\ at\ Top<Tab>zt zt
    PlanetMenu an 150.50 📺&v.Scrolling.Cursor\ Line\ at\ Center<Tab>zz zz
    PlanetMenu an 150.50 📺&v.Scrolling.Cursor\ Line\ at\ Bottom<Tab>zb zb
    PlanetMenu an 150.50 📺&v.Scrolling.Help <Cmd>help 'smoothscroll'<CR>
    PlanetMenu an 150.51 📺&v.Tab\ Panel.Show <Cmd>call planet#view#Panel('show', 2)<CR>
    PlanetMenu an 150.51 📺&v.Tab\ Panel.Hide <Cmd>call planet#view#Panel('show', 0)<CR>
    PlanetMenu an 150.51 📺&v.Tab\ Panel.Left <Cmd>call planet#view#Panel('align', 'left')<CR>
    PlanetMenu an 150.51 📺&v.Tab\ Panel.Right <Cmd>call planet#view#Panel('align', 'right')<CR>
    PlanetMenu an 150.51 📺&v.Tab\ Panel.Width <Cmd>call planet#view#Panel('columns')<CR>
    PlanetMenu an 150.51 📺&v.Tab\ Panel.Toggle\ Scrollbar <Cmd>call planet#preferences#Flag('tabpanelopt', 'scrollbar')<CR>
    PlanetMenu an 150.51 📺&v.Tab\ Panel.Help <Cmd>help tabpanel<CR>
    PlanetMenu an 170.50 🧭&n.Toggle\ Jump-list\ Stack <Cmd>call planet#preferences#Flag('jumpoptions', 'stack')<CR>
  elseif group ==# 'nav'
    for value in ['cursor', 'screen', 'topline']
      execute 'PlanetMenu anoremenu 820.55 🪟&w.Split\ Behavior.Keep\ ' .. value .. " <Cmd>call planet#preferences#Set('splitkeep', '" .. value .. "')<CR>"
    endfor
    PlanetMenu an 820.55 🪟&w.Release\ Fixed\ Size <Cmd>setlocal nowinfixheight nowinfixwidth<CR>
    PlanetMenu an 820.56 🪟&w.Pin\ Buffer <Cmd>call planet#preferences#Set('winfixbuf', 1, 1)<CR>
    PlanetMenu an 820.56 🪟&w.Unpin\ Buffer <Cmd>call planet#preferences#Set('winfixbuf', 0, 1)<CR>
    PlanetMenu an 820.56 🪟&w.Current\ Pin\ and\ Split\ State <Cmd>call planet#view#WindowState()<CR>
  endif
  return 0
enddef

export def WindowState(): any
  echomsg 'PlanetVim: splitkeep=' .. &splitkeep .. ', fixed height=' .. &l:winfixheight .. ', fixed width=' .. &l:winfixwidth .. ', pinned buffer=' .. (exists('+winfixbuf') ? eval('&l:winfixbuf') :  'unavailable in this Vim')
  return 0
enddef
