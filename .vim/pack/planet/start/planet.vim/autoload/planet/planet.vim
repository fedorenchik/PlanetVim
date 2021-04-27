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
endfunc

func! planet#planet#F()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let g:PV_p = l:c1
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
endfunc

func! planet#planet#semicolon()
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
endfunc

func! planet#planet#comma()
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
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
  else
    let g:PV_p = l:c1
    silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
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
  else
    let g:PV_p = l:c1
    silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
  end
endfunc

func! planet#planet#h()
  silent! exe "keepp keepj normal ?\\V" .. g:PV_pp .. "\<CR>"
endfunc

func! planet#planet#l()
  silent! exe "keepp keepj normal /\\V" .. g:PV_pp .. "\<CR>"
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
endfunc
