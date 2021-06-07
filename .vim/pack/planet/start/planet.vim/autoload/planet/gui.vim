scriptversion 4

func! planet#gui#VimServerStart() abort
  if empty(v:servername) && exists('*remote_startserver')
    call remote_startserver('VIM')
    echo 'Started as ' .. v:servername
  else
    echo 'Already started as ' .. v:servername
  end
endfunc

func! planet#gui#MenuListVimServers() abort
  for vs_id in systemlist('vim --serverlist')
    exe 'an 860.200 🎛️&@.&Vim\ Servers.&' .. planet#menu#MenuifyName(vs_id) .. ' <Cmd>TODO<CR>'
  endfor
endfunc

func! planet#gui#MenuListGuiWindows() abort
  for win_name in systemlist("wmctrl -l | tr -s ' ' | cut -d' ' -f4-")
    exe 'an 860.400 🎛️&@.&GUI\ Windows.&' .. planet#menu#MenuifyName(win_name) .. ' <Cmd>!wmctrl -a ' .. fnameescape(win_name) .. '<CR>'
  endfor
endfunc

func! planet#gui#WorkspaceListMenu() abort
  let l:ws_names = systemlist("wmctrl -d | tr -s ' ' | cut -d' ' -f10-")
  for ws_id in systemlist("wmctrl -d | tr -s ' ' | cut -d' ' -f1")
    let l:menu_name = '&' .. planet#menu#MenuifyName(l:ws_names[str2nr(ws_id)])
    exe 'an 860.600 🎛️&@.' .. l:menu_name .. ' <Cmd>!wmctrl -s ' .. ws_id .. '<CR>'
  endfor
endfunc
