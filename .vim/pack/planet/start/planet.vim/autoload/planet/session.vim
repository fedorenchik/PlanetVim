scriptversion 4

let s:menu_sessions = []

func! planet#session#Save() abort
  if ! empty(v:this_session)
    call startify#session_save(1, fnamemodify(v:this_session, ':t'))
  else
    call startify#session_save(0, fnamemodify(getcwd(-1), ':t'))
  end
  call planet#session#SetCurrent()
  call planet#session#MenuList()
endfunc

func! planet#session#Load(name) abort
  if !empty(getbufinfo({'bufmodified': 1}))
    throw 'PlanetVim: save or discard modified buffers before opening a session'
  endif
  call startify#session_load(0, a:name)
  call planet#session#SetCurrent()
endfunc

func! planet#session#LoadByIndex(index) abort
  if a:index >= 0 && a:index < len(s:menu_sessions)
    call planet#session#Load(s:menu_sessions[a:index])
  endif
endfunc

func! planet#session#SetCurrent() abort
  if exists('g:last_session')
    exe 'silent! aun 📚&s.Current:\ ' .. planet#menu#MenuifyName(g:last_session)
    unlet g:last_session
  endif
  if ! empty(v:this_session)
    exe 'an 840.20  📚&s.Current:\ ' .. planet#menu#MenuifyName(fnamemodify(v:this_session, ':t')) .. ' <Nop>'
    let g:last_session = fnamemodify(v:this_session, ":t")
  endif
endfunc

func! planet#session#MenuList() abort
  silent! aun 📚&s.Ope&n\ Session
  let s:menu_sessions = startify#session_list('')
  for l:index in range(len(s:menu_sessions))
    exe 'an 840.125 📚&s.Ope&n\ Session.' .. planet#menu#MenuifyName(s:menu_sessions[l:index])
          \ .. ' <Cmd>call planet#session#LoadByIndex(' .. l:index .. ')<CR>'
  endfor
endfunc

" TODO: support for sessions in project dir
func! planet#session#SetCwdSession() abort
  let l:project = 'projects/' .. sha256(fnamemodify(getcwd(), ':p'))[:15]
  let &undodir = escape(planet#paths#State(l:project .. '/undo'), ',')
  let &viminfofile = planet#paths#State(l:project) .. '/viminfo'
  let &viewdir = planet#paths#State(l:project .. '/views')
endfunc

" action: 0 - add
"         1 - remove
" where: 0 - add to .local/share/applications
"        1 - add to $(grep XDG_DESKTOP_DIR $HOME/.config/user-dirs.dirs | cut -d'=' -f2-)
func! planet#session#ManageDesktopFile(action, where) abort
  if empty(v:this_session)
    echohl Error
    echo "No session loaded"
    echohl None
    return
  endif
  let l:session_name = fnamemodify(v:this_session, ":t")
  call planet#term#RunScript(['manage-desktop-file', string(a:action), string(a:where), l:session_name])
endfunc
