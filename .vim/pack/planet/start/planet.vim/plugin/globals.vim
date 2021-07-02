scriptversion 4

if exists('g:loaded_planet_vim_globals')
  finish
endif
let g:loaded_planet_vim_globals = 1


let g:PV_config = "$HOME/.vim/planetvimrc.vim"


if ! exists("g:PlanetVim_menus_planet")
  let g:PlanetVim_menus_planet = 1
endif

if ! exists("g:PlanetVim_menus_basic")
  let g:PlanetVim_menus_basic = 1
endif

if ! exists("g:PlanetVim_menus_editing")
  let g:PlanetVim_menus_editing = 1
endif

if ! exists("g:PlanetVim_menus_dev")
  let g:PlanetVim_menus_dev = 1
endif

if ! exists("g:PlanetVim_menus_tools")
  let g:PlanetVim_menus_tools = 1
endif

if ! exists("g:PlanetVim_menus_nav")
  let g:PlanetVim_menus_nav = 1
endif

if ! exists("g:PlanetVim_menus_settings")
  let g:PlanetVim_menus_settings = 1
endif


if ! exists("g:PV_mode")
  let g:PV_mode = 's'
end


if ! exists('g:PV_build_dir')
  let g:PV_build_dir = ''
end

if ! exists('g:PV_run_configurations')
  let g:PV_run_configurations = ''
end

if ! exists('g:PV_server_port')
  let g:PV_server_port = 8080
end
