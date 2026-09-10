vim9script noclear
command! PlanetDoctor call planet#health#Show()
command! PlanetHelp help planetvim
command! PlanetVersion echo 'PlanetVim ' .. planet#version#Get()
command! PlanetCommandResult call planet#term#Info()
command! PlanetCommandCancel call planet#term#Cancel()
command! PlanetPlainMenus call planet#menu#Plain()
augroup PlanetVimOnboarding
  autocmd!
  autocmd VimEnter * call planet#health#FirstRun()
augroup END
