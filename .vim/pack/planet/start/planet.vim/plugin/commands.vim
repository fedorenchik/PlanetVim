vim9script noclear
command! PlanetDoctor call planet#health#Show()
command! PlanetHelp help planetvim
command! PlanetVersion echo 'PlanetVim ' .. planet#version#Get()
command! PlanetCommandResult call planet#term#Info()
command! PlanetCommandCancel call planet#term#Cancel()
command! PlanetPlainMenus call planet#menu#Plain()
command! -nargs=? PlanetNativeTabs call planet#native_tabs#Configure(<q-args>)
augroup PlanetVimNativeTabsStartup
  autocmd!
  autocmd GUIEnter * call planet#native_tabs#Start()
augroup END
augroup PlanetVimOnboarding
  autocmd!
  autocmd VimEnter * call planet#health#FirstRun()
augroup END
