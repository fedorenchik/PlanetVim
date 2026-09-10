vim9script noclear
if exists('g:loaded_planet_vim_globals')
  finish
endif
g:loaded_planet_vim_globals = 1


g:PV_config = get(g:, 'PV_config', planet#paths#Config() .. '/planetvimrc.vim')


if ! exists("g:PlanetVim_menus_planet")
  g:PlanetVim_menus_planet = 1
endif

if ! exists("g:PlanetVim_menus_basic")
  g:PlanetVim_menus_basic = 1
endif

if ! exists("g:PlanetVim_menus_editing")
  g:PlanetVim_menus_editing = 1
endif

if ! exists("g:PlanetVim_menus_dev")
  g:PlanetVim_menus_dev = 1
endif

if ! exists("g:PlanetVim_menus_tools")
  g:PlanetVim_menus_tools = 1
endif

if ! exists("g:PlanetVim_menus_nav")
  g:PlanetVim_menus_nav = 1
endif

if ! exists("g:PlanetVim_menus_settings")
  g:PlanetVim_menus_settings = 1
endif


if ! exists("g:PV_mode")
  g:PV_mode = 's'
endif


if ! exists('g:PV_build_dir')
  g:PV_build_dir = ''
endif

if ! exists('g:PV_run_configurations')
  g:PV_run_configurations = ''
endif

if ! exists('g:PV_server_port')
  g:PV_server_port = 8080
endif

# Autocommands
if ! exists('g:PV_alternate_tab')
  g:PV_alternate_tab = tabpagenr('#')
endif
if ! exists('g:PV_current_tab')
  g:PV_current_tab = tabpagenr()
endif
if ! exists('g:PV_new_tab')
  g:PV_new_tab = 1
endif
