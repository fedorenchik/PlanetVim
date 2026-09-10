vim9script
export def MenuListGuiWindows(): any
  var id: any
  var name: any
  if !planet#menu#Visible('nav')
    return 0
  endif
  silent! aunmenu 🎛️&@.&GUI\ Windows
  if has('win32') || !executable('wmctrl')
    return 0
  endif
  for line in systemlist('wmctrl -l')
    id = matchstr(line, '^0x[0-9a-fA-F]\+')
    if !empty(id)
      name = substitute(line, '^\S\+\s\+\S\+\s\+\S\+\s\+', '', '')
      execute 'PlanetMenu an 860.400 🎛️&@.&GUI\ Windows.' .. planet#menu#MenuifyName(id .. ' ' .. name) .. ' <Cmd>call planet#term#RunGuiApp(["wmctrl", "-ia", "' .. id .. '"])<CR>'
    endif
  endfor
  return 0
enddef

export def WorkspaceListMenu(): any
  var id: any
  if !planet#menu#Visible('nav')
    return 0
  endif
  silent! aunmenu 🎛️&@.&Workspaces
  if has('win32') || !executable('wmctrl')
    return 0
  endif
  for line in systemlist('wmctrl -d')
    id = matchstr(line, '^\d\+')
    if !empty(id)
      execute 'PlanetMenu an 860.600 🎛️&@.&Workspaces.' .. planet#menu#MenuifyName(line) .. ' <Cmd>call planet#term#RunGuiApp(["wmctrl", "-s", "' .. id .. '"])<CR>'
    endif
  endfor
  return 0
enddef

export def Open(command: any, prerequisite: any = ''): any
  if !empty(prerequisite) && !executable(prerequisite)
    echomsg 'PlanetVim: install ' .. prerequisite .. ' to use this app.'
    return 0
  endif
  return planet#term#RunGuiApp(planet#gui#Command() + ['--cmd', 'let g:startify_disable_at_vimenter = 1', '-c', command])
enddef
