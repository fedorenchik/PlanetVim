scriptversion 4


func! planet#session#Save() abort
  if ! empty(v:this_session)
    exe 'SSave! ' .. fnamemodify(v:this_session, ":t")
  else
    exe 'SSave ' .. fnamemodify(getcwd(-1), ":t")
  end
endfunc

func! planet#session#SetCurrent() abort
  if exists('g:last_session')
    exe 'aun 📚&s.Current:\ ' .. g:last_session
    unlet g:last_session
  endif
  if ! empty(v:this_session)
    exe 'an 840.20  📚&s.Current:\ ' .. fnamemodify(v:this_session, ":t") .. ' <Nop>'
    let g:last_session = fnamemodify(v:this_session, ":t")
  endif
endfunc

func! planet#session#MenuList() abort
  for session in startify#session_list('')
    exe 'an 840.125 📚&s.Ope&n\ Session.' .. session .. ' :SLoad ' .. session .. '<CR>'
  endfor
endfunc

" TODO: support for sessions in project dir
func! planet#session#SetCwdSession() abort
  set undodir=./.planetvim/undo
  set viminfofile=./.planetvim/viminfo
  set viewdir=./.planetvim/view
  "TODO: planetvim config file
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
  call planet#term#RunScript('manage-desktop-file ' .. a:action .. ' ' .. a:where .. ' ' .. l:session_name)
endfunc
