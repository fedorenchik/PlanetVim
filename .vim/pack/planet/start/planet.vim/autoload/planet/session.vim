vim9script

var script_menu_sessions: list<string> = []
var active_file = ''
var active_root = ''
var active_options = ''
var startup_root = ''
var loading = false
var timer = -1
var last_error = ''

def Canonical(path: string): string
  var result = substitute(resolve(fnamemodify(path, ':p')), '[/\\]\+$', '', '')
  return empty(result) ? '/' : result
enddef

export def Directory(): string
  var base = empty($XDG_DATA_HOME) ? expand('~/.local/share') : $XDG_DATA_HOME
  var path = get(g:, 'PV_sessions_dir', get(g:, 'startify_session_dir',
    empty($PLANETVIM_SESSIONS_DIR) ? base .. '/planetvim/.vim/sessions' : $PLANETVIM_SESSIONS_DIR))
  return fnamemodify(path, ':p')->substitute('[/\\]\+$', '', '')
enddef

export def PathForDirectory(directory: string): string
  var root = Canonical(directory)
  var name = substitute(fnamemodify(root, ':t'), '[^[:alnum:]_-]', '_', 'g')
  return Directory() .. '/' .. name .. '-' .. sha256(root)[: 15] .. '.session/session.vim'
enddef

# A chosen name denotes a container. Keep the snapshot name uniform so native
# gvim -S and :source still work without a separate project/session format.
export def PathForFile(path: string): string
  var file = fnamemodify(path, ':p')->substitute('[/\\]\+$', '', '')
  if file =~# '\.session/session\.vim$'
    return file
  elseif file =~# '\.session$'
    return file .. '/session.vim'
  endif
  return substitute(file, '\.vim$', '', '') .. '.session/session.vim'
enddef

def Prepare(path: string)
  var directory = fnamemodify(path, ':h')
  if !isdirectory(fnamemodify(directory, ':h'))
    throw 'PlanetVim: session parent directory does not exist: ' .. fnamemodify(directory, ':h')
  endif
  planet#session_state#Prepare(path)
enddef

def Name(path: string): string
  return path =~# '\.session/session\.vim$'
    ? substitute(fnamemodify(path, ':h:t'), '\.session$', '', '') : fnamemodify(path, ':t')
enddef

def StorageOption(line: string): bool
  return line =~# '^set\%(global\)\= \%(directory\|backupdir\|undodir\|viewdir\|viminfofile\)='
enddef

def Source(file: string)
  var lines = readfile(file)
  var filtered = filter(copy(lines), (_, line) => !StorageOption(line))
  if filtered == lines
    execute 'source ' .. fnameescape(file)
    return
  endif
  # Old "all options" snapshots can select global recovery paths. Remove those
  # assignments before any buffers open, retaining native relative/extra-script
  # paths while sourcing a temporary copy beside the original.
  for modifier in [':p:h', ':p:r', ':p']
    var expression = 'expand("<sfile>' .. modifier .. '")'
    var replacement = string(fnamemodify(file, modifier))
    map(filtered, (_, line) => substitute(line, '\V' .. escape(expression, '\'), '\=replacement', 'g'))
  endfor
  var temporary = fnamemodify(file, ':h') .. '/.planetvim-session-' .. getpid() .. '.tmp.vim'
  try
    writefile(filtered, temporary)
    setfperm(temporary, 'rw-------')
    execute 'source ' .. fnameescape(temporary)
  finally
    delete(temporary)
  endtry
enddef

def Forward(old: string, destination: string)
  if old ==# destination || !filereadable(old)
    return
  endif
  var backup = fnamemodify(destination, ':h') .. '/previous-session.vim'
  if !filereadable(backup)
    writefile(readfile(old, 'b'), backup, 'b')
    setfperm(backup, 'rw-------')
  endif
  var extra = fnamemodify(old, ':r') .. 'x.vim'
  var companion = fnamemodify(destination, ':r') .. 'x.vim'
  if filereadable(extra) && !filereadable(companion)
    # Keep custom configuration's original <sfile> directory semantics.
    writefile(["execute 'source ' .. fnameescape(" .. string(extra) .. ')'], companion)
    setfperm(companion, 'rw-------')
  endif
  var temporary = old .. '.' .. getpid() .. '.tmp'
  try
    writefile(['" PlanetVim session directory',
      "execute 'source ' .. fnameescape(" .. string(destination) .. ')'], temporary)
    setfperm(temporary, 'rw-------')
    if rename(temporary, old) != 0
      throw 'PlanetVim: could not update session launcher ' .. old
    endif
  finally
    delete(temporary)
  endtry
enddef

def HistoryFile(): string
  return planet#paths#State() .. '/sessions.vim'
enddef

export def Recent(): list<dict<string>>
  var path = HistoryFile()
  var history: list<dict<string>> = []
  if filereadable(path)
    try
      # This private index contains only generated Vim9 data, never project code.
      execute 'source ' .. fnameescape(path)
      history = get(g:, 'PV_session_history', [])
    finally
      unlet! g:PV_session_history
    endtry
  endif
  return filter(history, (_, item) => filereadable(get(item, 'file', '')))
enddef

def Remember()
  if empty(active_file) || !filereadable(active_file)
    return
  endif
  var history = filter(Recent(), (_, item) => PathForFile(item.file) !=# active_file)
  insert(history, {file: active_file, root: active_root, options: active_options})
  var path = HistoryFile()
  var temporary = path .. '.' .. getpid() .. '.tmp'
  try
    writefile(['vim9script', 'g:PV_session_history = ' .. string(history)], temporary)
    setfperm(temporary, 'rw-------')
    if rename(temporary, path) != 0
      throw 'PlanetVim: could not update recent sessions'
    endif
  finally
    delete(temporary)
  endtry
enddef

def Label(item: dict<string>): string
  var directory = fnamemodify(item.root, ':~')
  return item.file ==# PathForDirectory(item.root) ? directory
    : Name(item.file) .. ' — ' .. directory
enddef

export def StartifyList(): list<dict<string>>
  return map(Recent()[: 9], (_, item) => ({
    line: Label(item),
    cmd: 'call planet#session#OpenPath(' .. string(item.file) .. ')'}))
enddef

def CurrentMenu()
  if exists('g:last_session')
    execute 'silent! aun 📚&s.Current:\ ' .. planet#menu#MenuifyName(g:last_session)
    unlet g:last_session
  endif
  if !empty(v:this_session) && planet#menu#Visible('nav')
    g:last_session = Name(v:this_session)
    execute 'PlanetMenu an 840.20 📚&s.Current:\ ' .. planet#menu#MenuifyName(g:last_session) .. ' <Nop>'
  endif
enddef

export def SetCurrent(): number
  if loading || empty(v:this_session)
    return 0
  endif
  var file = fnamemodify(v:this_session, ':p')
  if file !=# PathForFile(file)
    Write(file, &sessionoptions)
    file = v:this_session
  else
    planet#session_state#Use(file)
  endif
  if file !=# active_file
    active_file = file
    active_root = Canonical(getcwd(-1))
    active_options = &sessionoptions
    for item in Recent()
      if item.file ==# file
        active_root = item.root
        active_options = item.options
        break
      endif
    endfor
  endif
  Remember()
  CurrentMenu()
  return 0
enddef

export def MenuList(): number
  if !planet#menu#Visible('nav')
    return 0
  endif
  CurrentMenu()
  silent! aun 📚&s.Ope&n\ Session
  script_menu_sessions = mapnew(Recent(), (_, item) => item.file)
  for index in range(len(script_menu_sessions))
    var path = script_menu_sessions[index]
    var label = Name(path) .. ' — ' .. fnamemodify(fnamemodify(path, ':h:h'), ':~')
    execute 'PlanetMenu an 840.125 📚&s.Ope&n\ Session.' .. planet#menu#MenuifyName(label)
      .. ' <Cmd>call planet#session#LoadByIndex(' .. index .. ')<CR>'
  endfor
  return 0
enddef

export def LoadByIndex(index: number): number
  if index >= 0 && index < len(script_menu_sessions)
    OpenPath(script_menu_sessions[index])
  endif
  return 0
enddef

# mksession writes to the same directory, then rename replaces the old snapshot.
# v:this_session and the previous snapshot survive a failed write.
def Write(requested: string, options: string)
  var path = PathForFile(requested)
  Prepare(path)
  if get(g:, 'PV_session_state_dir', '') !=# fnamemodify(path, ':h')
    planet#session_state#Flush()
  endif
  var previous = v:this_session
  var original_options = &sessionoptions
  var temporary = fnamemodify(path, ':h') .. '/.' .. fnamemodify(path, ':t') .. '.' .. getpid() .. '.tmp.vim'
  try
    &sessionoptions = options
    execute 'mksession! ' .. fnameescape(temporary)
    var lines = readfile(temporary)
    # "All options" must not put persistence back in the previous session.
    filter(lines, (_, line) => !StorageOption(line))
    var header = get(lines, 0, '') ==# 'vim9script' ? [remove(lines, 0), '# PlanetVim session directory']
      : ['" PlanetVim session directory']
    writefile(header + ["if exists('g:PV_root')",
      '  call planet#session#BeforeSource(expand("<sfile>:p"))', 'endif'] + lines, temporary)
    setfperm(temporary, 'rw-------')
    if rename(temporary, path) != 0
      throw 'PlanetVim: could not replace session ' .. path
    endif
    v:this_session = path
  catch
    v:this_session = previous
    throw 'PlanetVim: ' .. v:exception
  finally
    &sessionoptions = original_options
    delete(temporary)
  endtry
  if active_file !=# path
    active_root = Canonical(getcwd(-1))
  endif
  active_file = path
  active_options = options
  planet#session_state#Use(path, true)
  planet#session_state#Flush()
  Forward(requested, path)
  Remember()
enddef

export def Save(): number
  var path = empty(v:this_session) ? PathForDirectory(getcwd(-1)) : fnamemodify(v:this_session, ':p')
  if empty(v:this_session)
    mkdir(Directory(), 'p', 0o700)
  endif
  var options = path ==# active_file ? active_options : &sessionoptions
  Write(path, options)
  MenuList()
  return 1
enddef

export def SaveAs(path: string = '', overwrite: bool = false): number
  var destination = empty(path) ? browse(1, 'Save session as', getcwd(-1), 'Session.vim') : path
  if empty(destination)
    return 0
  endif
  var requested = fnamemodify(destination, ':p')
  destination = PathForFile(requested)
  if (filereadable(destination) || filereadable(requested)) && !overwrite
      && confirm('Replace session ' .. destination .. '?', "&Replace\n&Cancel", 2) != 1
    return 0
  endif
  Write(requested, &sessionoptions)
  MenuList()
  return 1
enddef

export def AutoSave(): number
  if loading || exists('g:SessionLoad') || empty(v:this_session)
    return 0
  endif
  # A welcome screen alone must not replace an editing layout. An intentionally
  # emptied existing session can still be saved.
  if (&filetype ==# 'startify' || !filereadable(v:this_session))
      && empty(filter(getbufinfo({'buflisted': 1}), (_, b) => !empty(b.name) && getbufvar(b.bufnr, '&buftype') ==# ''))
    return 0
  endif
  try
    var refresh = !filereadable(v:this_session) || fnamemodify(v:this_session, ':p') !=# active_file
    if fnamemodify(v:this_session, ':p') !=# active_file
      SetCurrent()
    endif
    Write(active_file, active_options)
    if refresh
      MenuList()
    endif
    last_error = ''
    return 1
  catch
    if last_error !=# v:exception
      last_error = v:exception
      echohl WarningMsg
      echomsg 'PlanetVim: session autosave failed: ' .. last_error
      echohl None
    endif
  endtry
  return 0
enddef

export def OnExit()
  if v:exiting == 0
    AutoSave()
  endif
enddef

export def Init()
  startup_root = Canonical(getcwd(-1))
  augroup PlanetAutoSession
    autocmd!
    autocmd VimEnter * ++nested call planet#session#Startup()
    autocmd VimLeavePre * call planet#session#OnExit()
  augroup END
enddef

def AutomaticPath(): string
  for item in Recent()
    if item.root ==# startup_root
      return item.file
    endif
  endfor
  var path = PathForDirectory(startup_root)
  var old = substitute(path, '\.session/session\.vim$', '.vim', '')
  return !filereadable(path) && filereadable(old) ? old : path
enddef

# settings.vim calls this before Vim's initial viminfo read and buffer loading.
export def PrepareStartup()
  if empty(startup_root)
    return
  endif
  var path = ''
  for index in range(len(v:argv))
    if v:argv[index] ==# '-S'
      var candidate = get(v:argv, index + 1, 'Session.vim')
      if filereadable(candidate)
          && join(readfile(candidate, '', 6), "\n") =~# 'SessionLoad\|PlanetVim session directory'
        path = fnamemodify(candidate, ':p')
        if path !=# PathForFile(path)
          # Native -S must import old option-capturing snapshots before they
          # can open buffers using the previous global undo/swap directories.
          augroup PlanetStartupSession
            autocmd!
            execute 'autocmd SourceCmd ' .. escape(path, ' ,*?[]{}|\\')
              .. ' ++once ++nested call planet#session#OpenPath(expand("<afile>:p"))'
          augroup END
        endif
      endif
      break
    endif
  endfor
  if empty(path) && startup_root !=# Canonical(expand('~')) && argc() == 0 && !&diff
      && !get(g:, 'startify_disable_at_vimenter', 0) && get(g:, 'PV_session_auto', 1)
    path = AutomaticPath()
  endif
  if !empty(path)
    planet#session_state#Use(PathForFile(path), false, true)
  endif
enddef

export def BeforeSource(path: string)
  if !loading && get(g:, 'PV_session_state_dir', '') !=# fnamemodify(path, ':p:h')
    if !empty(getbufinfo({'bufmodified': 1}))
      throw 'PlanetVim: save or discard modified buffers before opening a session'
    endif
    planet#session_state#Flush()
    silent :%bwipeout
  endif
  planet#session_state#Use(path)
enddef

export def Startup()
  if timer != -1
    timer_stop(timer)
  endif
  timer = timer_start(get(g:, 'PV_session_interval', 30000), (_) => AutoSave(), {repeat: -1})
  if !empty(v:this_session)
    SetCurrent()
    g:startify_disable_at_vimenter = 1
    return
  endif
  if empty(startup_root)
    startup_root = Canonical(getcwd(-1))
  endif
  if startup_root ==# Canonical(expand('~')) || argc() != 0 || &diff
      || get(g:, 'startify_disable_at_vimenter', 0) || get(g:, 'PV_session_auto', 1) == 0
      || !empty(expand('%')) || &modified || line('$') != 1 || getline(1) !=# ''
    planet#session_state#Use('')
    return
  endif
  var path = AutomaticPath()
  if filereadable(path)
    # A broken session must neither open Startify nor be overwritten on exit.
    g:startify_disable_at_vimenter = 1
    try
      OpenPath(path)
    catch
      echohl WarningMsg
      echomsg 'PlanetVim: could not restore session: ' .. v:exception
      echohl None
    endtry
  else
    mkdir(Directory(), 'p', 0o700)
    planet#session_state#Use(path)
    v:this_session = path
    active_file = path
    active_root = startup_root
    active_options = &sessionoptions
  endif
enddef

export def Load(name: string = ''): number
  var path = empty(name) ? browse(0, 'Open session', Directory(), '') : name
  if empty(path)
    return 0
  endif
  if !filereadable(path) && !filereadable(PathForFile(path))
    path = Directory() .. '/' .. path
  endif
  return OpenPath(path)
enddef

export def OpenPath(path: string): number
  if !empty(getbufinfo({'bufmodified': 1}))
    throw 'PlanetVim: save or discard modified buffers before opening a session'
  endif
  var file = fnamemodify(path, ':p')
  if filereadable(PathForFile(file))
    file = PathForFile(file)
  endif
  if !filereadable(file)
    throw 'PlanetVim: session file not found: ' .. file
  endif
  if file !=# active_file && !empty(v:this_session) && !empty(active_file)
    if AutoSave() == 0 && last_error !=# ''
      throw 'PlanetVim: could not save the current session; keeping it open'
    endif
  endif
  loading = true
  try
    Prepare(PathForFile(file))
    planet#session_state#Flush()
    # Replace the instance's buffer list as well as its layout.
    silent :%bwipeout
    planet#session_state#Use(PathForFile(file), false, false, true)
    Source(file)
    v:this_session = file
    if file !=# PathForFile(file)
      Write(file, &sessionoptions)
    endif
  catch
    v:this_session = ''
    active_file = ''
    unlet! g:SessionLoad
    silent! :%bwipeout!
    planet#session_state#Use('')
    throw 'PlanetVim: ' .. v:exception
  finally
    loading = false
  endtry
  SetCurrent()
  MenuList()
  return 1
enddef

export def Close(to_home: bool = false): number
  if !empty(getbufinfo({'bufmodified': 1}))
    throw 'PlanetVim: save or discard modified buffers before closing a session'
  endif
  if !empty(v:this_session)
    Save()
  endif
  v:this_session = ''
  active_file = ''
  active_root = ''
  active_options = ''
  silent :%bwipeout
  planet#session_state#Use('')
  if to_home
    cd
  endif
  MenuList()
  if exists(':Startify') == 2
    execute 'Startify'
  endif
  return 1
enddef

export def Delete(): number
  var history = Recent()
  var choice = inputlist(['Delete saved session:'] + mapnew(history, (i, item) => (i + 1) .. '. ' .. item.file))
  if choice < 1 || choice > len(history)
    return 0
  endif
  var path = history[choice - 1].file
  if confirm('Delete session ' .. path .. '?', "&Delete\n&Cancel", 2) != 1
    return 0
  endif
  if fnamemodify(v:this_session, ':p') ==# path
    Close()
  endif
  if delete(path) != 0
    throw 'PlanetVim: could not delete session ' .. path
  endif
  MenuList()
  return 1
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
  var requested = fnamemodify(path, ':p')
  path = PathForFile(requested)
  var exists = filereadable(path) || filereadable(requested)
  var overwrite: any = len(args) > 1 ? args[1] : !exists || confirm('Replace session ' .. path .. '?', "&Replace\n&Cancel", 2) == 1
  if exists && !overwrite
    return 0
  endif
  Prepare(path)
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
    Write(requested, &sessionoptions)
  finally
    &sessionoptions = options
    execute (local == 1 ? 'lcd ' : local == 2 ? 'tcd ' : 'cd ') .. fnameescape(cwd)
  endtry
  MenuList()
  return 1
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
    name = substitute(Name(session), '[\r\n]', ' ', 'g')
    writefile(['[Desktop Entry]', 'Version=1.0', 'Type=Application', 'Name=PlanetVim - ' .. name, 'Comment=Open this PlanetVim session',
         'Exec=' .. planet#session#DesktopExec(argv), 'Terminal=false', 'Icon=gvim', 'Categories=Development;TextEditor;',
         'StartupNotify=true'], file)
    setfperm(file, 'rwx------')
  endif
  return file
enddef

export def LoadLast(): any
  var recent = Recent()
  if empty(recent)
    echomsg 'PlanetVim: no previous session is available.'
    return 0
  endif
  return OpenPath(recent[0].file)
enddef
