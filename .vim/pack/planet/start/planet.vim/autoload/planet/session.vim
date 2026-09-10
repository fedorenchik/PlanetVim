scriptversion 4

let s:menu_sessions = []

func! planet#session#Save() abort
  if ! empty(v:this_session)
    if fnamemodify(v:this_session, ':p:h') ==# fnamemodify(get(g:, 'startify_session_dir', planet#paths#State('sessions')), ':p:h')
      call startify#session_save(1, fnamemodify(v:this_session, ':t'))
    else
      execute 'mksession! ' .. fnameescape(v:this_session)
    endif
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
  if empty(a:name)
    call startify#session_load(0)
  else
    call startify#session_load(0, a:name)
  endif
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
    call writefile([fnamemodify(v:this_session, ':p')], planet#paths#State() .. '/last-session')
    if planet#menu#Visible('nav')
      exe 'an 840.20  📚&s.Current:\ ' .. planet#menu#MenuifyName(fnamemodify(v:this_session, ':t')) .. ' <Nop>'
    endif
    let g:last_session = fnamemodify(v:this_session, ":t")
  endif
endfunc

func! planet#session#MenuList() abort
  if !planet#menu#Visible('nav') | return | endif
  silent! aun 📚&s.Ope&n\ Session
  let s:menu_sessions = startify#session_list('')
  for l:index in range(len(s:menu_sessions))
    exe 'an 840.125 📚&s.Ope&n\ Session.' .. planet#menu#MenuifyName(s:menu_sessions[l:index])
          \ .. ' <Cmd>call planet#session#LoadByIndex(' .. l:index .. ')<CR>'
  endfor
endfunc

func! planet#session#SetCwdSession() abort
  let l:project = 'projects/' .. sha256(fnamemodify(getcwd(), ':p'))[:15]
  let &undodir = escape(planet#paths#State(l:project .. '/undo'), ',')
  let &viminfofile = planet#paths#State(l:project) .. '/viminfo'
  let &viewdir = planet#paths#State(l:project .. '/views')
endfunc

func! planet#session#SaveVariant(variant, ...) abort
  if index(['relative', 'local', 'all', 'no-globals'], a:variant) < 0
    throw 'PlanetVim: unknown session save variant'
  endif
  let l:path = a:0 ? a:1 : browse(1, 'Save session (' .. a:variant .. ')', getcwd(), 'Session.vim')
  if empty(l:path) | return 0 | endif
  let l:path = fnamemodify(l:path, ':p')
  let l:overwrite = a:0 > 1 ? a:2 : !filereadable(l:path)
        \ || confirm('Replace session ' .. l:path .. '?', "&Replace\n&Cancel", 2) == 1
  if filereadable(l:path) && !l:overwrite | return 0 | endif
  let l:options = &sessionoptions
  let l:cwd = getcwd()
  let l:local = haslocaldir()
  try
    if a:variant ==# 'relative'
      set sessionoptions-=curdir sessionoptions+=sesdir
      execute 'lcd ' .. fnameescape(fnamemodify(l:path, ':h'))
    elseif a:variant ==# 'local'
      set sessionoptions-=options sessionoptions+=localoptions
    elseif a:variant ==# 'all'
      set sessionoptions+=localoptions sessionoptions+=options
    else
      set sessionoptions-=globals
    endif
    execute 'mksession' .. (l:overwrite ? '! ' : ' ') .. fnameescape(l:path)
  finally
    let &sessionoptions = l:options
    execute (l:local == 1 ? 'lcd ' : l:local == 2 ? 'tcd ' : 'cd ') .. fnameescape(l:cwd)
  endtry
  call planet#session#SetCurrent()
  return 1
endfunc

func! planet#session#OpenPath(path) abort
  if !empty(getbufinfo({'bufmodified': 1}))
    throw 'PlanetVim: save or discard modified buffers before opening a session'
  endif
  if !filereadable(a:path)
    throw 'PlanetVim: session file not found: ' .. a:path
  endif
  execute 'source ' .. fnameescape(a:path)
  call planet#session#SetCurrent()
endfunc

" action: 0 - add
"         1 - remove
" where: 0 - application menu; 1 - desktop (XDG/Windows known folders).
func! planet#session#ManageDesktopFile(action, where) abort
  if empty(v:this_session) || !filereadable(v:this_session)
    echom 'PlanetVim: save a session before creating its launcher.'
    return 0
  endif
  return planet#session#DesktopEntry(a:action, a:where, v:this_session)
endfunc

func! s:DesktopDirectory(where) abort
  let l:override = a:where == 0 ? 'PV_applications_dir' : 'PV_desktop_dir'
  if has_key(g:, l:override) | return g:[l:override] | endif
  if has('win32') && executable('powershell.exe')
    let l:folder = a:where == 0 ? 'Programs' : 'Desktop'
    let l:result = systemlist('powershell.exe -NoProfile -NonInteractive -Command "[Environment]::GetFolderPath(''' .. l:folder .. ''')"')
    if v:shell_error == 0 && !empty(l:result) && !empty(l:result[0])
      return l:result[0]
    endif
  endif
  if a:where == 0
    return get(g:, 'PV_applications_dir', has('win32') ? $APPDATA .. '/Microsoft/Windows/Start Menu/Programs'
          \ : (empty($XDG_DATA_HOME) ? expand('~/.local/share') : $XDG_DATA_HOME) .. '/applications')
  endif
  if exists('g:PV_desktop_dir') | return g:PV_desktop_dir | endif
  if has('win32') | return expand('~/Desktop') | endif
  let l:config = (empty($XDG_CONFIG_HOME) ? expand('~/.config') : $XDG_CONFIG_HOME) .. '/user-dirs.dirs'
  if filereadable(l:config)
    for l:line in readfile(l:config)
      let l:directory = matchstr(l:line, '^XDG_DESKTOP_DIR="\zs.*\ze"$')
      if !empty(l:directory)
        return substitute(l:directory, '\$HOME', '\=expand("~")', 'g')
      endif
    endfor
  endif
  return expand('~/Desktop')
endfunc

func! planet#session#DesktopExec(argv) abort
  let l:words = []
  for l:argument in a:argv
    if l:argument =~# '[\r\n]'
      throw 'PlanetVim: launcher arguments cannot contain line breaks'
    endif
    let l:word = escape(l:argument, '\"`$')
    let l:word = substitute(l:word, '\\', '\\\\', 'g')
    let l:word = substitute(l:word, '%', '%%', 'g')
    call add(l:words, '"' .. l:word .. '"')
  endfor
  return join(l:words, ' ')
endfunc

func! planet#session#DesktopEntry(action, where, session) abort
  if index([0, 1], a:action) < 0 || index([0, 1], a:where) < 0
    throw 'PlanetVim: invalid launcher action'
  endif
  let l:session = fnamemodify(a:session, ':p')
  let l:directory = s:DesktopDirectory(a:where)
  let l:file = l:directory .. '/PlanetVim-' .. sha256(l:session)[:19] .. (has('win32') ? '.lnk' : '.desktop')
  if a:action == 1
    if filereadable(l:file) && delete(l:file) != 0
      throw 'PlanetVim: could not remove launcher ' .. l:file
    endif
    return l:file
  endif
  if !filereadable(l:session) | throw 'PlanetVim: session file not found' | endif
  call mkdir(l:directory, 'p')
  let l:argv = planet#gui#Command() + ['--cmd', 'let g:startify_disable_at_vimenter = 1',
        \ '-c', 'call planet#session#OpenPath(' .. string(l:session) .. ')']
  if has('win32')
    if !executable('powershell.exe')
      throw 'PlanetVim: Windows PowerShell is required to create a session shortcut'
    endif
    let l:request = planet#paths#Cache('launchers') .. '/' .. sha256(l:file)[:19] .. '.json'
    call writefile([json_encode({'path': l:file, 'argv': l:argv, 'cwd': fnamemodify(l:session, ':h')})], l:request)
    call planet#term#RunGuiApp(['powershell.exe', '-NoProfile', '-NonInteractive', '-File',
          \ planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/session-shortcut.ps1', l:request])
  else
    let l:name = substitute(fnamemodify(l:session, ':t'), '[\r\n]', ' ', 'g')
    call writefile(['[Desktop Entry]', 'Version=1.0', 'Type=Application',
          \ 'Name=PlanetVim - ' .. l:name, 'Comment=Open this PlanetVim session',
          \ 'Exec=' .. planet#session#DesktopExec(l:argv), 'Terminal=false',
          \ 'Icon=gvim', 'Categories=Development;TextEditor;', 'StartupNotify=true'], l:file)
    call setfperm(l:file, 'rwx------')
  endif
  return l:file
endfunc

func! planet#session#LoadLast() abort
  let l:file = planet#paths#State() .. '/last-session'
  let l:last = filereadable(l:file) ? get(readfile(l:file), 0, '') : ''
  if empty(l:last)
    echomsg 'PlanetVim: no previous session is available.'
    return
  endif
  if filereadable(l:last)
    call planet#session#OpenPath(l:last)
  else
    " Read the earlier format, which stored only a Startify session name.
    call planet#session#Load(l:last)
  endif
endfunc
