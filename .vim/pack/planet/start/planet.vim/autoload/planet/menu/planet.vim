scriptversion 4

"TODO: add setting to run commands in terminal buffer: open window (++noclose),
"TODO:    do not open TODO: (++close), close when finish (++close), open after
"TODO:    finish (++open)
"TODO: change icon based on IP (Americas: 🌎, Europe, Africa, Middle-East: 🌍,
"TODO:    SEA, Pacific: 🌏, ISS: 🛰️, Interplanetary: 🪐) or use country flag
function! planet#menu#planet#Update() abort
  if g:PlanetVim_menus_planet
    an 100.10  🌐&P.PlanetVim <Nop>
    an disable 🌐&P.PlanetVim
    an 100.10  🌐&P.New\ &PlanetVim                         :silent !gvim<CR>
    an 100.10  🌐&P.--1-- <Nop>
    an 100.10  🌐&P.Set\ E&asy\ Mode                        :call planet#planet#SetEasyMode()<CR>
    an 100.10  🌐&P.Set\ Standa&rd\ Mode                    :call planet#planet#SetStandardMode()<CR>
    an 100.10  🌐&P.Set\ S&uper-Charged\ Mode               :call planet#planet#SetSuperChargedMode()<CR>
    an 100.10  🌐&P.--2-- <Nop>
    an 100.10  🌐&P.Set\ GUI\ Dialogs                       :call planet#planet#SetGuiDialogs()<CR>
    an 100.10  🌐&P.Set\ Text\ Dialogs                      :call planet#planet#SetTextDialogs()<CR>
    an 100.20  🌐&P.--3-- <Nop>
    an 100.30  🌐&P.&Basic\ Menus                           :call planet#planet#BasicToggle()<CR>
    an 100.40  🌐&P.&Editing\ Menus                         :call planet#planet#EditingToggle()<CR>
    an 100.50  🌐&P.&Development\ Menus                     :call planet#planet#DevelopmentToggle()<CR>
    an 100.60  🌐&P.&Tools\ Menus                           :call planet#planet#ToolsToggle()<CR>
    an 100.70  🌐&P.&Navigation\ Menus                      :call planet#planet#NavigationToggle()<CR>
    an 100.70  🌐&P.&Settings\ Menus                        :call planet#planet#NavigationToggle()<CR>
    an 100.80  🌐&P.--4-- <Nop>
    an 100.90  🌐&P.Ed&it\ Settings                         :tabedit ~/.vim/planetvimrc.vim<CR>
    an 100.100 🌐&P.--5-- <Nop>
    an 100.110 🌐&P.&Close\ Everything                      :cd<CR>:SClose<CR>
    an 100.120 🌐&P.--6-- <Nop>
    an 100.130 🌐&P.Save\ &&\ E&xit\ PlanetVim              :call planet#planet#SaveExit()<CR>
  else
    silent! aunmenu 🌐&P
  endif
endfunction
