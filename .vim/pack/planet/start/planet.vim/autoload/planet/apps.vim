scriptversion 4

func! planet#apps#MenuListGuiWindows() abort
  if !planet#menu#Visible('nav') | return | endif
  silent! aunmenu 🎛️&@.&GUI\ Windows
  if has('win32') || !executable('wmctrl')
    return
  endif
  for l:line in systemlist('wmctrl -l')
    let l:id = matchstr(l:line, '^0x[0-9a-fA-F]\+')
    if !empty(l:id)
      let l:name = substitute(l:line, '^\S\+\s\+\S\+\s\+\S\+\s\+', '', '')
      execute 'PlanetMenu an 860.400 🎛️&@.&GUI\ Windows.' .. planet#menu#MenuifyName(l:id .. ' ' .. l:name)
            \ .. ' <Cmd>call planet#term#RunGuiApp(["wmctrl", "-ia", "' .. l:id .. '"])<CR>'
    endif
  endfor
endfunc

func! planet#apps#WorkspaceListMenu() abort
  if !planet#menu#Visible('nav') | return | endif
  silent! aunmenu 🎛️&@.&Workspaces
  if has('win32') || !executable('wmctrl')
    return
  endif
  for l:line in systemlist('wmctrl -d')
    let l:id = matchstr(l:line, '^\d\+')
    if !empty(l:id)
      execute 'PlanetMenu an 860.600 🎛️&@.&Workspaces.' .. planet#menu#MenuifyName(l:line)
            \ .. ' <Cmd>call planet#term#RunGuiApp(["wmctrl", "-s", "' .. l:id .. '"])<CR>'
    endif
  endfor
endfunc

func! planet#apps#Open(command, prerequisite = '') abort
  if !empty(a:prerequisite) && !executable(a:prerequisite)
    echomsg 'PlanetVim: install ' .. a:prerequisite .. ' to use this app.'
    return 0
  endif
  return planet#term#RunGuiApp(planet#gui#Command()
        \ + ['--cmd', 'let g:startify_disable_at_vimenter = 1', '-c', a:command])
endfunc
