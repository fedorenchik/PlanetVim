scriptversion 4

func! planet#planet#ConfigUpdate(conf_var) abort
  if !get(g:, 'PV_initializing', 0)
    call planet#config#SavePreference(a:conf_var, eval(a:conf_var))
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

let s:mode_maps = {
      \ 'b': ':call planet#planet#comma()<CR>', 'B': ':bp<CR>',
      \ 'e': 'g;', 'E': 'g,', 'f': ':call planet#planet#f()<CR>',
      \ 'F': ':call planet#planet#F()<CR>', 'ge': '1gt', 'gE': ':tabl<CR>',
      \ 'h': ':call planet#planet#h()<CR>', 'j': ':call planet#planet#j()<CR>',
      \ 'k': ':call planet#planet#k()<CR>', 'l': ':call planet#planet#l()<CR>',
      \ 't': ':call planet#planet#t()<CR>', 'T': ':call planet#planet#T()<CR>',
      \ 'w': ':call planet#planet#semicolon()<CR>', 'W': ':bn<CR>'}
let s:saved_maps = {}

func! planet#planet#ModeKeys() abort
  return keys(s:mode_maps)
endfunc

func! planet#planet#SetMode(mode) abort
  if index(['e', 's', 'p'], a:mode) < 0
    throw 'PlanetVim: mode must be e, s, or p'
  endif
  " Remove only mappings still owned by the previous mode.
  for [l:key, l:rhs] in items(s:mode_maps)
    if has_key(s:saved_maps, l:key)
      if maparg(l:key, 'n') ==# l:rhs
        execute 'nunmap ' .. l:key
        if !empty(s:saved_maps[l:key])
          call mapset('n', 0, s:saved_maps[l:key])
        endif
      endif
    endif
  endfor
  let s:saved_maps = {}
  let &insertmode = a:mode ==# 'e'
  let &selectmode = a:mode ==# 'e' ? 'mouse,key' : ''
  let &keymodel = a:mode ==# 'e' ? 'startsel,stopsel' : ''
  let &backspace = a:mode ==# 'e' ? 'indent,eol,nostop' : 'start'
  let &selection = a:mode ==# 'e' ? 'exclusive' : 'inclusive'
  if a:mode ==# 'e'
    set guioptions-=c
    set guioptions+=r
  else
    set guioptions+=c
    set guioptions-=r
  endif
  if a:mode ==# 'p'
    for [l:key, l:rhs] in items(s:mode_maps)
      let s:saved_maps[l:key] = maparg(l:key, 'n', 0, 1)
      execute 'nnoremap <silent> ' .. l:key .. ' ' .. l:rhs
    endfor
  endif
  let g:PV_mode = a:mode
  if empty(v:this_session)
    call planet#planet#ConfigUpdate('g:PV_mode')
  endif
endfunc

func! planet#planet#SetEasyMode() abort
  call planet#planet#SetMode('e')
endfunc

func! planet#planet#SetStandardMode() abort
  call planet#planet#SetMode('s')
endfunc

func! planet#planet#SetSuperChargedMode() abort
  call planet#planet#SetMode('p')
endfunc

func! planet#planet#SetGuiDialogs() abort
  set guioptions-=c
endfunc

func! planet#planet#SetTextDialogs() abort
  set guioptions+=c
endfunc

func! planet#planet#IsGuiDialogs() abort
  return stridx(&guioptions, 'c') == -1
endfunc

func! planet#planet#PlanetToggle() abort
  call planet#menu#Group('planet')
endfunc

func! planet#planet#BasicToggle() abort
  call planet#menu#Group('basic')
endfunc

func! planet#planet#EditingToggle() abort
  call planet#menu#Group('editing')
endfunc

func! planet#planet#DevelopmentToggle() abort
  call planet#menu#Group('dev')
endfunc

func! planet#planet#ToolsToggle() abort
  call planet#menu#Group('tools')
endfunc

func! planet#planet#NavigationToggle() abort
  call planet#menu#Group('nav')
endfunc

func! planet#planet#SettingsToggle() abort
  call planet#menu#Group('settings')
endfunc

func! planet#planet#SetPerSessionOptions()
  call planet#session#SetCwdSession()
  silent! rviminfo!
endfunc

func! planet#planet#SaveAll() abort
  try
    confirm wall
  catch
    echohl ErrorMsg
    echom 'PlanetVim: save cancelled or failed: ' .. v:exception
    echohl None
    return v:false
  endtry
  if !empty(getbufinfo({'bufmodified': 1}))
    echohl WarningMsg
    echom 'PlanetVim: unsaved changes remain; keeping the editor open.'
    echohl None
    return v:false
  endif
  return v:true
endfunc

func! planet#planet#SaveExit() abort
  if planet#planet#SaveAll()
    qa
  endif
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
endfunc

func! planet#planet#EditVimVar(var_name) abort
  let l:var_value = inputdialog(a:var_name .. '=', eval(a:var_name), 'CANCELLED')
  if l:var_value == 'CANCELLED'
    return
  end
  execute('let ' .. a:var_name .. '=' .. l:var_value)
endfunc
