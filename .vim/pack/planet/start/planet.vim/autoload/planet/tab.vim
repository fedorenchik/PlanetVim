vim9script

var script_directory = ''
var script_sequence = 0
var script_order = []
var script_snapshots = {}
var script_closed = ''
var script_restoring = v:false
var script_closing = v:false

def LocalDirectory(): any
  if empty(script_directory)
    script_directory = planet#paths#State('tabs') .. '/' .. getpid() .. '-' .. sha256(tempname())[ : 15]
    mkdir(script_directory, 'p')
  endif
  return script_directory
enddef

export def Track(): any
  var id: any
  if script_restoring
    return 0
  endif
  script_order = []
  for tab in range(1, tabpagenr('$'))
    id = gettabvar(tab, 'PV_tab_id', '')
    if empty(id)
      script_sequence += 1
      id = string(script_sequence)
      settabvar(tab, 'PV_tab_id', id)
    endif
    add(script_order, id)
  endfor
  return 0
enddef

# Save only this tab, without changing the active full-session identity/options.
export def SaveTo(path: any, overwrite: any = v:false): any
  var lines: any
  if empty(path)
    return 0
  endif
  var ssop: any = &sessionoptions
  var session: any = v:this_session
  try
    &sessionoptions = join(filter(split(ssop, ','),  (_, lambda_option) => index(['tabpages', 'winpos', 'globals', 'options', 'buffers'], lambda_option) < 0), ',')
    execute (overwrite ? 'mksession! ' : 'mksession ') .. fnameescape(path)
    # A restored tab must not change the working directory of other tabs.
    lines = readfile(path)
    map(lines, (_, lambda_line) => substitute(lambda_line, '^cd ', 'tcd ', ''))
    if writefile(lines, path) != 0
      throw 'PlanetVim: could not save the tab'
    endif
  finally
    &sessionoptions = ssop
    v:this_session = session
  endtry
  return 1
enddef

export def Save(): any
  var path: any = browse(v:true, 'Save current tab', getcwd(), fnamemodify(bufname(), ':t:r') .. '.tab.vim')
  if empty(path)
    return 0
  endif
  var overwrite: any = getftype(path) !=# ''
  if overwrite && confirm('Overwrite ' .. path .. '?', "&Overwrite\n&Cancel", 2) != 1
    return 0
  endif
  return planet#tab#SaveTo(path, overwrite)
enddef

export def Open(): any
  var path: any = browse(v:false, 'Open saved tab', getcwd(), '')
  return empty(path) ? 0 : planet#tab#OpenFrom(path)
enddef

export def SaveTmp(): any
  var path: any
  if script_restoring || script_closing
    return 0
  endif
  planet#tab#Track()
  var id: any = gettabvar(tabpagenr(), 'PV_tab_id')
  try
    path = LocalDirectory() .. '/' .. id .. '.tab.vim'
    planet#tab#SaveTo(path, v:true)
    script_snapshots[id] = path
  catch
    # Snapshot failure must not prevent switching or closing a tab.
    echohl WarningMsg
    echom 'PlanetVim: could not save closed-tab recovery: ' .. v:exception
    echohl None
  endtry
  return 0
enddef

export def BeforeClose(): any
  if script_restoring
    return 0
  endif
  # A TabLeave event is too late: tabclose may already have removed splits.
  script_closing = v:false
  planet#tab#SaveTmp()
  script_closing = v:true
  return 0
enddef

# The wrappers provide pre-close capture on Vim builds without TabClosedPre.
export def Close(): any
  planet#tab#BeforeClose()
  try
    confirm tabclose
  finally
    script_closing = v:false
  endtry
  return 0
enddef

export def CloseOthers(): any
  planet#tab#BeforeClose()
  try
    confirm tabonly
  finally
    script_closing = v:false
  endtry
  return 0
enddef

export def Closed(): any
  if script_restoring
    return 0
  endif
  # Vim's TabClosed does not identify the removed tab. Compare stable IDs,
  # which also handles closing a non-current tab and tab-number renumbering.
  var remaining: any = map(gettabinfo(), (_, lambda_tab) => gettabvar(lambda_tab.tabnr, 'PV_tab_id', ''))
  for id in filter(copy(script_order), (_, lambda_id) => index(remaining, lambda_id) < 0)
    if has_key(script_snapshots, id)
      if !empty(script_closed) && script_closed !=# script_snapshots[id]
        delete(script_closed)
      endif
      script_closed = remove(script_snapshots, id)
    endif
  endfor
  script_order = remaining
  script_closing = v:false
  return 0
enddef

# Restore global cwd without losing the restored tab's per-window directories.
def LocalRestoreCwd(global: any): any
  var tabdir: any = getcwd(-1, 0)
  var locals: any = []
  for win in gettabinfo(tabpagenr())[0].windows
    if haslocaldir(win_id2win(win)) == 1
      add(locals, [win, getcwd(win_id2win(win))])
    endif
  endfor
  execute 'noautocmd cd ' .. fnameescape(global)
  execute 'noautocmd tcd ' .. fnameescape(tabdir)
  for item in locals
    win_execute(item[0], 'noautocmd lcd ' .. fnameescape(item[1]))
  endfor
  return 0
enddef

export def OpenFrom(arg_path: any): any
  var error: any
  if !filereadable(arg_path)
    throw 'PlanetVim: saved tab does not exist: ' .. arg_path
  endif
  var path: any = fnamemodify(arg_path, ':p')
  var ssop: any = &sessionoptions
  var session: any = v:this_session
  var events: any = &eventignore
  var old_window: any = win_getid()
  var cwd: any = getcwd(-1)
  var new_window: any = 0
  script_restoring = v:true
  try
    set eventignore+=SessionLoadPost
    tabnew
    new_window = win_getid()
    execute 'source ' .. fnameescape(path)
    LocalRestoreCwd(cwd)
  catch
    error = v:exception
    if new_window != 0 && win_id2tabwin(new_window)[0] != 0
      execute 'noautocmd tabclose! ' .. win_id2tabwin(new_window)[0]
    endif
    win_gotoid(old_window)
    if getcwd(-1) !=# cwd
      LocalRestoreCwd(cwd)
    endif
    throw 'PlanetVim: could not restore tab: ' .. error
  finally
    &sessionoptions = ssop
    v:this_session = session
    &eventignore = events
    script_restoring = v:false
    planet#tab#Track()
  endtry
  return 1
enddef

export def Reopen(): any
  if empty(script_closed) || !filereadable(script_closed)
    echo 'PlanetVim: no closed tab to reopen'
    return 0
  endif
  # The closed snapshot is distinct from every still-open tab's snapshot.
  return planet#tab#OpenFrom(script_closed)
enddef

export def Cleanup(): any
  if !empty(script_directory)
    delete(script_directory, 'rf')
  endif
  script_directory = ''
  script_snapshots = {}
  script_closed = ''
  script_closing = v:false
  return 0
enddef
