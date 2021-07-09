scriptversion 4

func! planet#apps#MenuListGuiWindows() abort
  for win_name in systemlist("wmctrl -l | tr -s ' ' | cut -d' ' -f4-")
    exe 'an 860.400 🎛️&@.&GUI\ Windows.&' .. planet#menu#MenuifyName(win_name) .. ' <Cmd>!wmctrl -a ' .. fnameescape(win_name) .. '<CR>'
  endfor
endfunc

func! planet#apps#WorkspaceListMenu() abort
  let l:ws_names = systemlist("wmctrl -d | tr -s ' ' | cut -d' ' -f10-")
  for ws_id in systemlist("wmctrl -d | tr -s ' ' | cut -d' ' -f1")
    let l:menu_name = '&' .. planet#menu#MenuifyName(l:ws_names[str2nr(ws_id)])
    exe 'an 860.600 🎛️&@.' .. l:menu_name .. ' <Cmd>!wmctrl -s ' .. ws_id .. '<CR>'
  endfor
endfunc
