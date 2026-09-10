vim9script

var script_menu_sessions = []

export def Save(): any
  if ! empty(v:this_session)
    if fnamemodify(v:this_session, ':p:h') ==# fnamemodify(get(g:, 'startify_session_dir', planet#paths#State('sessions')), ':p:h')
      startify#session_save(1, fnamemodify(v:this_session, ':t'))
    else
      execute 'mksession! ' .. fnameescape(v:this_session)
    endif
  else
    startify#session_save(0, fnamemodify(getcwd(-1), ':t'))
  endif
  planet#session#SetCurrent()
  planet#session#MenuList()
  return 0
enddef

export def Load(name: any): any
  if !empty(getbufinfo({'bufmodified': 1}))
    throw 'PlanetVim: save or discard modified buffers before opening a session'
  endif
  if empty(name)
    startify#session_load(0)
  else
    startify#session_load(0, name)
  endif
  planet#session#SetCurrent()
  return 0
enddef

export def LoadByIndex(index: any): any
  if index >= 0 && index < len(script_menu_sessions)
    planet#session#Load(script_menu_sessions[index])
  endif
  return 0
enddef

export def SetCurrent(): any
  if exists('g:last_session')
    exe 'silent! aun 📚&s.Current:\ ' .. planet#menu#MenuifyName(g:last_session)
    unlet g:last_session
  endif
  if ! empty(v:this_session)
    writefile([fnamemodify(v:this_session, ':p')], planet#paths#State() .. '/last-session')
    if planet#menu#Visible('nav')
      exe 'PlanetMenu an 840.20  📚&s.Current:\ ' .. planet#menu#MenuifyName(fnamemodify(v:this_session, ':t')) .. ' <Nop>'
    endif
    g:last_session = fnamemodify(v:this_session, ":t")
  endif
  return 0
enddef

export def MenuList(): any
  if !planet#menu#Visible('nav')
    return 0
  endif
  silent! aun 📚&s.Ope&n\ Session
  script_menu_sessions = startify#session_list('')
  for index in range(len(script_menu_sessions))
    exe 'PlanetMenu an 840.125 📚&s.Ope&n\ Session.' .. planet#menu#MenuifyName(script_menu_sessions[index]) .. ' <Cmd>call planet#session#LoadByIndex(' .. index .. ')<CR>'
  endfor
  return 0
enddef

export def SetCwdSession(): any
  var project: any = 'projects/' .. sha256(fnamemodify(getcwd(), ':p'))[ : 15]
  &undodir = escape(planet#paths#State(project .. '/undo'), ',')
  &viminfofile = planet#paths#State(project) .. '/viminfo'
  &viewdir = planet#paths#State(project .. '/views')
  return 0
enddef

export def SaveVariant(variant: any, ...args: list<any>): any
  var local: any
  if index(['relative', 'local', 'all', 'no-globals'], variant) < 0
    throw 'PlanetVim: unknown session save variant'
  endif
  var path: any = !empty(args) ? args[0] : browse(1, 'Save session (' .. variant .. ')', getcwd(), 'Session.vim')
  if empty(path)
    return 0
  endif
  path = fnamemodify(path, ':p')
  var overwrite: any = len(args) > 1 ? args[1] : !filereadable(path) || confirm('Replace session ' .. path .. '?', "&Replace\n&Cancel", 2) == 1
  if filereadable(path) && !overwrite
    return 0
  endif
  var options: any = &sessionoptions
  var cwd: any = getcwd()
  local = haslocaldir()
  try
    if variant ==# 'relative'
      set sessionoptions-=curdir sessionoptions+=sesdir
      execute 'lcd ' .. fnameescape(fnamemodify(path, ':h'))
    elseif variant ==# 'local'
      set sessionoptions-=options sessionoptions+=localoptions
    elseif variant ==# 'all'
      set sessionoptions+=localoptions sessionoptions+=options
    else
      set sessionoptions-=globals
    endif
    execute 'mksession' .. (overwrite ? '! ' : ' ') .. fnameescape(path)
  finally
    &sessionoptions = options
    execute (local == 1 ? 'lcd ' : local == 2 ? 'tcd ' : 'cd ') .. fnameescape(cwd)
  endtry
  planet#session#SetCurrent()
  return 1
enddef

export def OpenPath(path: any): any
  if !empty(getbufinfo({'bufmodified': 1}))
    throw 'PlanetVim: save or discard modified buffers before opening a session'
  endif
  if !filereadable(path)
    throw 'PlanetVim: session file not found: ' .. path
  endif
  execute 'source ' .. fnameescape(path)
  planet#session#SetCurrent()
  return 0
enddef

# action: 0 - add
#         1 - remove
# where: 0 - application menu; 1 - desktop (XDG/Windows known folders).
export def ManageDesktopFile(action: any, where: any): any
  if empty(v:this_session) || !filereadable(v:this_session)
    echom 'PlanetVim: save a session before creating its launcher.'
    return 0
  endif
  return planet#session#DesktopEntry(action, where, v:this_session)
enddef

def LocalDesktopDirectory(where: any): any
  var folder: any
  var result: any
  var directory: any
  var override: any = where == 0 ? 'PV_applications_dir' : 'PV_desktop_dir'
  if has_key(g:, override)
    return g:[override]
  endif
  if has('win32') && executable('powershell.exe')
    folder = where == 0 ? 'Programs' : 'Desktop'
    result = systemlist('powershell.exe -NoProfile -NonInteractive -Command "[Environment]::GetFolderPath(''' .. folder .. ''')"')
    if v:shell_error == 0 && !empty(result) && !empty(result[0])
      return result[0]
    endif
  endif
  if where == 0
    return get(g:, 'PV_applications_dir', has('win32') ? $APPDATA .. '/Microsoft/Windows/Start Menu/Programs' : (empty($XDG_DATA_HOME) ? expand('~/.local/share') : $XDG_DATA_HOME) .. '/applications')
  endif
  if exists('g:PV_desktop_dir')
    return g:PV_desktop_dir
  endif
  if has('win32')
    return expand('~/Desktop')
  endif
  var config: any = (empty($XDG_CONFIG_HOME) ? expand('~/.config') : $XDG_CONFIG_HOME) .. '/user-dirs.dirs'
  if filereadable(config)
    for line in readfile(config)
      directory = matchstr(line, '^XDG_DESKTOP_DIR="\zs.*\ze"$')
      if !empty(directory)
        return substitute(directory, '\$HOME', '\=expand("~")', 'g')
      endif
    endfor
  endif
  return expand('~/Desktop')
enddef

export def DesktopExec(argv: any): any
  var word: any
  var words: any = []
  for argument in argv
    if argument =~# '[\r\n]'
      throw 'PlanetVim: launcher arguments cannot contain line breaks'
    endif
    word = escape(argument, '\"`$')
    word = substitute(word, '\\', '\\\\', 'g')
    word = substitute(word, '%', '%%', 'g')
    add(words, '"' .. word .. '"')
  endfor
  return join(words, ' ')
enddef

export def DesktopEntry(action: any, where: any, arg_session: any): any
  var request: any
  var name: any
  if index([0, 1], action) < 0 || index([0, 1], where) < 0
    throw 'PlanetVim: invalid launcher action'
  endif
  var session: any = fnamemodify(arg_session, ':p')
  var directory: any = LocalDesktopDirectory(where)
  var file: any = directory .. '/PlanetVim-' .. sha256(session)[ : 19] .. (has('win32') ? '.lnk' : '.desktop')
  if action == 1
    if filereadable(file) && delete(file) != 0
      throw 'PlanetVim: could not remove launcher ' .. file
    endif
    return file
  endif
  if !filereadable(session)
    throw 'PlanetVim: session file not found'
  endif
  mkdir(directory, 'p')
  var argv: any = planet#gui#Command() + ['--cmd', 'let g:startify_disable_at_vimenter = 1', '-c', 'call planet#session#OpenPath(' .. string(session) .. ')']
  if has('win32')
    if !executable('powershell.exe')
      throw 'PlanetVim: Windows PowerShell is required to create a session shortcut'
    endif
    request = planet#paths#Cache('launchers') .. '/' .. sha256(file)[ : 19] .. '.json'
    writefile([json_encode({'path': file, 'argv': argv, 'cwd': fnamemodify(session, ':h')})], request)
    planet#term#RunGuiApp(['powershell.exe', '-NoProfile', '-NonInteractive', '-File',  planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/session-shortcut.ps1', request])
  else
    name = substitute(fnamemodify(session, ':t'), '[\r\n]', ' ', 'g')
    writefile(['[Desktop Entry]', 'Version=1.0', 'Type=Application', 'Name=PlanetVim - ' .. name, 'Comment=Open this PlanetVim session',
         'Exec=' .. planet#session#DesktopExec(argv), 'Terminal=false', 'Icon=gvim', 'Categories=Development;TextEditor;',
         'StartupNotify=true'], file)
    setfperm(file, 'rwx------')
  endif
  return file
enddef

export def LoadLast(): any
  var last: any
  var file: any = planet#paths#State() .. '/last-session'
  last = filereadable(file) ? get(readfile(file), 0, '') : ''
  if empty(last)
    echomsg 'PlanetVim: no previous session is available.'
    return 0
  endif
  if filereadable(last)
    planet#session#OpenPath(last)
  else
    # Read the earlier format, which stored only a Startify session name.
    planet#session#Load(last)
  endif
  return 0
enddef
