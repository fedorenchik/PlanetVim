scriptversion 4

func! planet#view#Panel(key, value = v:null) abort
  if !exists('+showtabpanel') || !exists('+tabpanelopt')
    return planet#prompt#Unavailable('native tab panel', 'tabpanel')
  endif
  if a:key ==# 'show' | return planet#preferences#Set('showtabpanel', a:value) | endif
  let l:value = a:value
  if a:key ==# 'columns'
    if l:value is v:null | let l:value = planet#prompt#Ask('Tab panel width in columns: ', '20') | endif
    if l:value is v:null || empty(l:value) | return 0 | endif
    if string(l:value) !~# "^'\\?\\d\\+'\\?$" || str2nr(l:value) < 1
      echomsg 'PlanetVim: enter a positive panel width'
      return 0
    endif
  elseif a:key !=# 'align' || index(['left', 'right'], l:value) < 0
    throw 'PlanetVim: invalid tab panel setting'
  endif
  let l:parts = filter(split(&tabpanelopt, ','), {_, v -> stridx(v, a:key .. ':') != 0})
  call add(l:parts, a:key .. ':' .. l:value)
  return planet#preferences#Set('tabpanelopt', join(l:parts, ','))
endfunc

func! planet#view#Menus(group) abort
  if a:group ==# 'basic'
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
  elseif a:group ==# 'nav'
    for l:value in ['cursor', 'screen', 'topline']
      execute 'PlanetMenu anoremenu 820.55 🪟&w.Split\ Behavior.Keep\ ' .. l:value .. " <Cmd>call planet#preferences#Set('splitkeep', '" .. l:value .. "')<CR>"
    endfor
    PlanetMenu an 820.55 🪟&w.Release\ Fixed\ Size <Cmd>setlocal nowinfixheight nowinfixwidth<CR>
    PlanetMenu an 820.56 🪟&w.Pin\ Buffer <Cmd>call planet#preferences#Set('winfixbuf', 1, 1)<CR>
    PlanetMenu an 820.56 🪟&w.Unpin\ Buffer <Cmd>call planet#preferences#Set('winfixbuf', 0, 1)<CR>
    PlanetMenu an 820.56 🪟&w.Current\ Pin\ and\ Split\ State <Cmd>call planet#view#WindowState()<CR>
  endif
endfunc

func! planet#view#WindowState() abort
  echomsg 'PlanetVim: splitkeep=' .. &splitkeep .. ', fixed height=' .. &l:winfixheight .. ', fixed width=' .. &l:winfixwidth .. ', pinned buffer=' .. (exists('+winfixbuf') ? &l:winfixbuf : 'unavailable in this Vim')
endfunc
