" Keep the caller's script ID for menu mappings containing <SID>.
if exists('g:loaded_planet_menu_help') | finish | endif
let g:loaded_planet_menu_help = 1
command! -nargs=+ -keepscript PlanetMenu execute planet#menu_help#Definition(<q-args>)

augroup PlanetMenuHelp
  autocmd!
  autocmd VimEnter * call planet#menu_help#RefreshTips()
augroup END
