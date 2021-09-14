scriptversion 4

func! planet#planet#ConfigUpdate(conf_var) abort
  let l:value = eval(a:conf_var)
  if type(l:value) == v:t_string
    let l:value = "'" .. l:value .. "'"
  end
  if empty(v:this_session) && filewritable(expand(g:PV_config))
    silent call system('grep "let ' .. a:conf_var .. ' =" ' .. g:PV_config)
    if ! v:shell_error
      silent call system('sed -i -e "s/^let ' .. a:conf_var .. ' = .*$/let ' .. a:conf_var .. ' = ' .. l:value .. '/" ' .. g:PV_config)
    else
      silent call system('echo "let ' .. a:conf_var .. ' = ' .. l:value .. '" >> ' .. g:PV_config)
    endif
  else
    silent call system('echo "let ' .. a:conf_var .. ' = ' .. l:value .. '" > ' .. g:PV_config)
  endif
endfunc

"TODO: add mod <Alt> - means search regex, e.g. '\.' when press '.'
"TODO:    (can use getcharmod()), and change pattern
"TODO:    '\\V' (very non magic) to '\\v' (very magic)
let g:PV_p = '\.'
func! planet#planet#f()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let g:PV_p = l:c1
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
  normal m9
endfunc

func! planet#planet#F()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let g:PV_p = l:c1
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
  normal m9
endfunc

func! planet#planet#semicolon()
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
  normal m9
endfunc

func! planet#planet#comma()
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
  normal m9
endfunc

let g:PV_pp = '\.\.'
func! planet#planet#t()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let l:c = getchar()
  if l:c == 27
    return
  end
  if l:c != 13
    let l:c2 = nr2char(l:c)
    let g:PV_pp = l:c1 .. l:c2
    silent! exe "keepp keepj normal /\\V" .. g:PV_pp .. "\<CR>"
    normal m0
  else
    let g:PV_p = l:c1
    silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
    normal m9
  end
endfunc

func! planet#planet#T()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let l:c = getchar()
  if l:c == 27
    return
  end
  if l:c != 13
    let l:c2 = nr2char(l:c)
    let g:PV_pp = l:c1 .. l:c2
    silent! exe "keepp keepj normal ?\\V" .. g:PV_pp .. "\<CR>"
    normal m0
  else
    let g:PV_p = l:c1
    silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
    normal m9
  end
endfunc

func! planet#planet#h()
  silent! exe "keepp keepj normal ?\\V" .. g:PV_pp .. "\<CR>"
  normal m0
endfunc

func! planet#planet#l()
  silent! exe "keepp keepj normal /\\V" .. g:PV_pp .. "\<CR>"
  normal m0
endfunc

func! planet#planet#j()
  try
    laf
  catch
    silent! lne
  endtry
endfunc

func! planet#planet#k()
  try
    lbe
  catch
    silent! lp
  endtry
endfunc

func! planet#planet#SetEasyMode() abort
  set im
  set selectmode=mouse,key
  set keymodel=startsel,stopsel
  set guioptions-=c
  set guioptions+=r
  set bs=indent,eol,nostop
  set sel=exclusive
  silent! nun b
  silent! nun B
  silent! nun e
  silent! nun E
  silent! nun f
  silent! nun F
  silent! nun ge
  silent! nun gE
  silent! nun h
  silent! nun j
  silent! nun k
  silent! nun l
  silent! nun t
  silent! nun T
  silent! nun w
  silent! nun W
  let g:PV_mode = 'e'
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PV_mode')
  endif
endfunc

func! planet#planet#SetStandardMode() abort
  set noim
  set selectmode=
  set keymodel=
  set guioptions+=c
  set guioptions-=r
  set bs=start
  set sel=inclusive
  silent! nun b
  silent! nun B
  silent! nun e
  silent! nun E
  silent! nun f
  silent! nun F
  silent! nun ge
  silent! nun gE
  silent! nun h
  silent! nun j
  silent! nun k
  silent! nun l
  silent! nun t
  silent! nun T
  silent! nun w
  silent! nun W
  let g:PV_mode = 's'
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PV_mode')
  endif
endfunc

func! planet#planet#SetSuperChargedMode() abort
  set noim
  set selectmode=
  set keymodel=
  set guioptions+=c
  set guioptions-=r
  set bs=start
  set sel=inclusive
  nn <silent> b :call planet#planet#comma()<CR>
  nn <silent> B :bp<CR>
  nn <silent> e g;
  nn <silent> E g,
  nn <silent> f :call planet#planet#f()<CR>
  nn <silent> F :call planet#planet#F()<CR>
  nn <silent> ge 1gt
  nn <silent> gE :tabl<CR>
  nn <silent> h :call planet#planet#h()<CR>
  nn <silent> j :call planet#planet#j()<CR>
  nn <silent> k :call planet#planet#k()<CR>
  nn <silent> l :call planet#planet#l()<CR>
  nn <silent> t :call planet#planet#t()<CR>
  nn <silent> T :call planet#planet#T()<CR>
  nn <silent> w :call planet#planet#semicolon()<CR>
  nn <silent> W :bn<CR>
  let g:PV_mode = 'p'
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PV_mode')
  endif
endfunc

func! planet#planet#SetGuiDialogs() abort
  set guioptions-=c
endfunc

func! planet#planet#SetTextDialogs() abort
  set guioptions+=c
endfunc

func! planet#planet#PlanetToggle() abort
  if g:PlanetVim_menus_planet
    let g:PlanetVim_menus_planet = 0
  else
    let g:PlanetVim_menus_planet = 1
  endif
  call planet#menu#planet#Update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_planet')
  endif
endfunc

func! planet#planet#BasicToggle() abort
  if g:PlanetVim_menus_basic
    let g:PlanetVim_menus_basic = 0
  else
    let g:PlanetVim_menus_basic = 1
  endif
  call planet#menu#basic#Update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_basic')
  endif
endfunc

func! planet#planet#EditingToggle() abort
  if g:PlanetVim_menus_editing
    let g:PlanetVim_menus_editing = 0
  else
    let g:PlanetVim_menus_editing = 1
  endif
  call planet#menu#edit#Update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_editing')
  endif
endfunc

func! planet#planet#DevelopmentToggle() abort
  if g:PlanetVim_menus_dev
    let g:PlanetVim_menus_dev = 0
  else
    let g:PlanetVim_menus_dev = 1
  endif
  call planet#menu#dev#Update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_dev')
  endif
endfunc

func! planet#planet#ToolsToggle() abort
  if g:PlanetVim_menus_tools
    let g:PlanetVim_menus_tools = 0
  else
    let g:PlanetVim_menus_tools = 1
  endif
  call planet#menu#tools#Update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_tools')
  endif
endfunc

func! planet#planet#NavigationToggle() abort
  if g:PlanetVim_menus_nav
    let g:PlanetVim_menus_nav = 0
  else
    let g:PlanetVim_menus_nav = 1
  endif
  call planet#menu#nav#Update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_nav')
  endif
endfunc

func! planet#planet#SettingsToggle() abort
  if g:PlanetVim_menus_settings
    let g:PlanetVim_menus_settings = 0
  else
    let g:PlanetVim_menus_settings = 1
  endif
  call planet#menu#settings#Update()
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PlanetVim_menus_settings')
  endif
endfunc

func! planet#planet#SetPerSessionOptions()
  "TODO: undofile, undodir, spellfile, viminfo, viewdir
  exe "set viminfofile=~/.vim/viminfo/" .. fnamemodify(v:this_session, ":t") .. ".viminfo"
  silent! rviminfo!
endfunc

func! planet#planet#SaveExit() abort
  confirm wall
  qa!
endfunc

func! planet#planet#EmergencyExit() abort
  set noautowrite
  set noautowriteall
  cquit!
endfunc

func! planet#planet#CheckExitSaveSession() abort
  if empty(v:this_session) || v:exiting != 0
    return
  end
  "TODO: auto-save and auto-load quickfix/loclist files (up to 10 of each, loclists: for each window)
  exe 'SSave! ' .. fnamemodify(v:this_session, ":t")
  "TODO: auto close all terminals / jobs
  for job in job_info()
    call job_stop(job)
  endfor
endfunc

func! planet#planet#EditVimVar(var_name) abort
  let l:var_value = inputdialog(a:var_name .. '=', eval(a:var_name), 'CANCELLED')
  if l:var_value == 'CANCELLED'
    return
  end
  execute('let ' .. a:var_name .. '=' .. l:var_value)
endfunc
