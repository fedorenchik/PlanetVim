scriptversion 4

"TODO: add setting to run commands in terminal buffer: open window (++noclose),
"TODO:    do not open TODO: (++close), close when finish (++close), open after
"TODO:    finish (++open)
"TODO: change icon based on IP (Americas: 🌎, Europe, Africa, Middle-East: 🌍,
"TODO:    SEA, Pacific: 🌏, ISS: 🛰️, Interplanetary: 🪐) or use country flag
function! planet#menu#planet#Update() abort
  if planet#menu#Visible('planet')
    an 100.15 🌐&P.Find\ Menu\ Action <Cmd>call planet#actions#Open()<CR>
    vnoremenu 100.15 🌐&P.Find\ Menu\ Action <Cmd>call planet#actions#Open()<CR>
    inoremenu 100.15 🌐&P.Find\ Menu\ Action <Cmd>call planet#actions#Open()<CR>
    an 100.10  🌐&P.PlanetVim <Nop>
    an disable 🌐&P.PlanetVim
    an 100.10  🌐&P.&Open\ Welcome\ Screen                  <Cmd>tabnew<CR><Cmd>Startify<CR>
    an 100.10  🌐&P.New\ &PlanetVim                         <Cmd>call planet#term#RunGuiApp(planet#gui#Command())<CR>
    an 100.10  🌐&P.--1-- <Nop>
    an 100.10  🌐&P.Set\ E&asy\ Mode                        <Cmd>call planet#planet#SetEasyMode()<CR>
    an 100.10  🌐&P.Set\ Standa&rd\ Mode                    <Cmd>call planet#planet#SetStandardMode()<CR>
    an 100.10  🌐&P.Set\ S&uper-Charged\ Mode               <Cmd>call planet#planet#SetSuperChargedMode()<CR>
    an 100.10  🌐&P.--2-- <Nop>
    an 100.20 🌐&P.Menu\ Style.Emoji\ (default) <Cmd>call planet#menu#Style('emoji')<CR>
    an 100.20 🌐&P.Menu\ Style.Plain <Cmd>call planet#menu#Style('plain')<CR>
    an 100.20 🌐&P.Menu\ Style.Descriptive\ (one\ group) <Cmd>call planet#menu#Style('descriptive')<CR>
    an 100.20  🌐&P.--3-- <Nop>
    an 100.30  🌐&P.&Basic\ Menus                           <Cmd>call planet#planet#BasicToggle()<CR>
    an 100.40  🌐&P.&Editing\ Menus                         <Cmd>call planet#planet#EditingToggle()<CR>
    an 100.50  🌐&P.&Development\ Menus                     <Cmd>call planet#planet#DevelopmentToggle()<CR>
    an 100.60  🌐&P.&Tools\ Menus                           <Cmd>call planet#planet#ToolsToggle()<CR>
    an 100.70  🌐&P.&Navigation\ Menus                      <Cmd>call planet#planet#NavigationToggle()<CR>
    an 100.70  🌐&P.&Settings\ Menus                        <Cmd>call planet#planet#SettingsToggle()<CR>
    an 100.80  🌐&P.--4-- <Nop>
    an 100.90  🌐&P.Ed&it\ Settings                         <Cmd>execute 'tabedit ' .. fnameescape(g:PV_config)<CR>
    an 100.100 🌐&P.--5-- <Nop>
    an 100.110 🌐&P.&Close\ Everything                      <Cmd>cd<CR><Cmd>SClose<CR>
    an 100.120 🌐&P.--6-- <Nop>
    an 100.130 🌐&P.Save\ &&\ E&xit\ PlanetVim              <Cmd>call planet#planet#SaveExit()<CR>
  else
    silent! aunmenu 🌐&P
  endif
endfunction
