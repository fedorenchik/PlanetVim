scriptversion 4

aug AugPv_MenuBuffers
au!
au BufCreate,BufFilePost * call planet#buffer#AddBufferAu()
au BufDelete,BufFilePre * call planet#buffer#RemoveBufferAu()
aug END

aug AugPv_Session
au!
au SessionLoadPost * call planet#session#SetCurrent()
au VimEnter * call planet#session#MenuList()
aug END

if ! exists("g:PlanetVim_menus_planet")
  let g:PlanetVim_menus_planet = 1
endif
call planet#menu#planet#update()

if ! exists("g:PlanetVim_menus_basic")
  let g:PlanetVim_menus_basic = 1
endif
call planet#menu#basic#update()

if ! exists("g:PlanetVim_menus_editing")
  let g:PlanetVim_menus_editing = 1
endif
call planet#menu#edit#update()

if ! exists("g:PlanetVim_menus_dev")
  let g:PlanetVim_menus_dev = 1
endif
call planet#menu#dev#update()

if ! exists("g:PlanetVim_menus_tools")
  let g:PlanetVim_menus_tools = 1
endif
call planet#menu#tools#update()

if ! exists("g:PlanetVim_menus_nav")
  let g:PlanetVim_menus_nav = 1
endif
call planet#menu#nav#update()

if ! exists("g:PlanetVim_menus_settings")
  let g:PlanetVim_menus_settings = 1
endif
call planet#menu#settings#update()

