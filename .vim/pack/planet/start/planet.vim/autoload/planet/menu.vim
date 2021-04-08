scriptversion 4

func! planet#menu#MenuifyName(name) abort
  let menu_name = a:name
  if empty(menu_name)
    let menu_name = "[No Name]"
  endif
  let menu_name = escape(menu_name, "\\. \t|")
  let menu_name = substitute(menu_name, "&", "&&", "g")
  let menu_name = substitute(menu_name, "\n", "^@", "g")
  return menu_name
endfunc

func! planet#menu#AddMenuItem(priority, text, command, tooltip) abort
    an 110.10  &File.&New                                   :confirm enew<CR>
    an a:priority a:text a:command
    tln 110.10  &File.&New                                  :confirm enew<CR>
    no <A-f>n :confirm enew<CR>
    no a:map a:command
    ln <A-f>n :confirm enew<CR>
    tno <A-f>n :confirm enew<CR>
endfunc

"TODO: add session support
func! planet#menu#PlanetToggle() abort
  if g:PlanetVim_menus_planet
    let g:PlanetVim_menus_planet = 0
  else
    let g:PlanetVim_menus_planet = 1
  endif
  call planet#menu#planet#update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_planet')
  endif
endfunc

func! planet#menu#BasicToggle() abort
  if g:PlanetVim_menus_basic
    let g:PlanetVim_menus_basic = 0
  else
    let g:PlanetVim_menus_basic = 1
  endif
  call planet#menu#basic#update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_basic')
  endif
endfunc

func! planet#menu#EditingToggle() abort
  if g:PlanetVim_menus_editing
    let g:PlanetVim_menus_editing = 0
  else
    let g:PlanetVim_menus_editing = 1
  endif
  call planet#menu#edit#update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_editing')
  endif
endfunc

func! planet#menu#DevelopmentToggle() abort
  if g:PlanetVim_menus_dev
    let g:PlanetVim_menus_dev = 0
  else
    let g:PlanetVim_menus_dev = 1
  endif
  call planet#menu#dev#update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_dev')
  endif
endfunc

func! planet#menu#ToolsToggle() abort
  if g:PlanetVim_menus_tools
    let g:PlanetVim_menus_tools = 0
  else
    let g:PlanetVim_menus_tools = 1
  endif
  call planet#menu#tools#update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_tools')
  endif
endfunc

func! planet#menu#NavigationToggle() abort
  if g:PlanetVim_menus_nav
    let g:PlanetVim_menus_nav = 0
  else
    let g:PlanetVim_menus_nav = 1
  endif
  call planet#menu#nav#update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_nav')
  endif
endfunc

func! planet#menu#SettingsToggle() abort
  if g:PlanetVim_menus_settings
    let g:PlanetVim_menus_settings = 0
  else
    let g:PlanetVim_menus_settings = 1
  endif
  call planet#menu#settings#update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_settings')
  endif
endfunc

