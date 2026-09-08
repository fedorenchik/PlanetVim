scriptversion 4

let s:directory = ''
let s:sequence = 0
let s:order = []
let s:snapshots = {}
let s:closed = ''
let s:restoring = v:false
let s:closing = v:false

func! s:Directory() abort
  if empty(s:directory)
    let s:directory = planet#paths#State('tabs') .. '/' .. getpid() .. '-' .. sha256(tempname())[:15]
    call mkdir(s:directory, 'p')
  endif
  return s:directory
endfunc

func! planet#tab#Track() abort
  if s:restoring
    return
  endif
  let s:order = []
  for l:tab in range(1, tabpagenr('$'))
    let l:id = gettabvar(l:tab, 'PV_tab_id', '')
    if empty(l:id)
      let s:sequence += 1
      let l:id = string(s:sequence)
      call settabvar(l:tab, 'PV_tab_id', l:id)
    endif
    call add(s:order, l:id)
  endfor
endfunc

" Save only this tab, without changing the active full-session identity/options.
func! planet#tab#SaveTo(path, overwrite = v:false) abort
  if empty(a:path)
    return 0
  endif
  let l:ssop = &sessionoptions
  let l:session = v:this_session
  try
    let &sessionoptions = join(filter(split(l:ssop, ','),
          \ {_, option -> index(['tabpages', 'winpos', 'globals', 'options', 'buffers'], option) < 0}), ',')
    execute (a:overwrite ? 'mksession! ' : 'mksession ') .. fnameescape(a:path)
    " A restored tab must not change the working directory of other tabs.
    let l:lines = readfile(a:path)
    call map(l:lines, {_, line -> substitute(line, '^cd ', 'tcd ', '')})
    if writefile(l:lines, a:path) != 0
      throw 'PlanetVim: could not save the tab'
    endif
  finally
    let &sessionoptions = l:ssop
    let v:this_session = l:session
  endtry
  return 1
endfunc

func! planet#tab#Save() abort
  let l:path = browse(v:true, 'Save current tab', getcwd(), fnamemodify(bufname(), ':t:r') .. '.tab.vim')
  if empty(l:path)
    return 0
  endif
  let l:overwrite = getftype(l:path) !=# ''
  if l:overwrite && confirm('Overwrite ' .. l:path .. '?', "&Overwrite\n&Cancel", 2) != 1
    return 0
  endif
  return planet#tab#SaveTo(l:path, l:overwrite)
endfunc

func! planet#tab#Open() abort
  let l:path = browse(v:false, 'Open saved tab', getcwd(), '')
  return empty(l:path) ? 0 : planet#tab#OpenFrom(l:path)
endfunc

func! planet#tab#SaveTmp() abort
  if s:restoring || s:closing
    return
  endif
  call planet#tab#Track()
  let l:id = gettabvar(tabpagenr(), 'PV_tab_id')
  try
    let l:path = s:Directory() .. '/' .. l:id .. '.tab.vim'
    call planet#tab#SaveTo(l:path, v:true)
    let s:snapshots[l:id] = l:path
  catch
    " Snapshot failure must not prevent switching or closing a tab.
    echohl WarningMsg
    echom 'PlanetVim: could not save closed-tab recovery: ' .. v:exception
    echohl None
  endtry
endfunc

func! planet#tab#BeforeClose() abort
  if s:restoring
    return
  endif
  " A TabLeave event is too late: tabclose may already have removed splits.
  let s:closing = v:false
  call planet#tab#SaveTmp()
  let s:closing = v:true
endfunc

" The wrappers provide pre-close capture on Vim builds without TabClosedPre.
func! planet#tab#Close() abort
  call planet#tab#BeforeClose()
  try
    confirm tabclose
  finally
    let s:closing = v:false
  endtry
endfunc

func! planet#tab#CloseOthers() abort
  call planet#tab#BeforeClose()
  try
    confirm tabonly
  finally
    let s:closing = v:false
  endtry
endfunc

func! planet#tab#Closed() abort
  if s:restoring
    return
  endif
  " Vim's TabClosed does not identify the removed tab. Compare stable IDs,
  " which also handles closing a non-current tab and tab-number renumbering.
  let l:remaining = map(gettabinfo(), {_, tab -> gettabvar(tab.tabnr, 'PV_tab_id', '')})
  for l:id in filter(copy(s:order), {_, id -> index(l:remaining, id) < 0})
    if has_key(s:snapshots, l:id)
      if !empty(s:closed) && s:closed !=# s:snapshots[l:id]
        call delete(s:closed)
      endif
      let s:closed = remove(s:snapshots, l:id)
    endif
  endfor
  let s:order = l:remaining
  let s:closing = v:false
endfunc

" Restore global cwd without losing the restored tab's per-window directories.
func! s:RestoreCwd(global) abort
  let l:tabdir = getcwd(-1, 0)
  let l:locals = []
  for l:win in gettabinfo(tabpagenr())[0].windows
    if haslocaldir(win_id2win(l:win)) == 1
      call add(l:locals, [l:win, getcwd(win_id2win(l:win))])
    endif
  endfor
  execute 'noautocmd cd ' .. fnameescape(a:global)
  execute 'noautocmd tcd ' .. fnameescape(l:tabdir)
  for l:item in l:locals
    call win_execute(l:item[0], 'noautocmd lcd ' .. fnameescape(l:item[1]))
  endfor
endfunc

func! planet#tab#OpenFrom(path) abort
  if !filereadable(a:path)
    throw 'PlanetVim: saved tab does not exist: ' .. a:path
  endif
  let l:path = fnamemodify(a:path, ':p')
  let l:ssop = &sessionoptions
  let l:session = v:this_session
  let l:events = &eventignore
  let l:old_window = win_getid()
  let l:cwd = getcwd(-1)
  let l:new_window = 0
  let s:restoring = v:true
  try
    set eventignore+=SessionLoadPost
    tabnew
    let l:new_window = win_getid()
    execute 'source ' .. fnameescape(l:path)
    call s:RestoreCwd(l:cwd)
  catch
    let l:error = v:exception
    if l:new_window != 0 && win_id2tabwin(l:new_window)[0] != 0
      execute 'noautocmd tabclose! ' .. win_id2tabwin(l:new_window)[0]
    endif
    call win_gotoid(l:old_window)
    if getcwd(-1) !=# l:cwd
      call s:RestoreCwd(l:cwd)
    endif
    throw 'PlanetVim: could not restore tab: ' .. l:error
  finally
    let &sessionoptions = l:ssop
    let v:this_session = l:session
    let &eventignore = l:events
    let s:restoring = v:false
    call planet#tab#Track()
  endtry
  return 1
endfunc

func! planet#tab#Reopen() abort
  if empty(s:closed) || !filereadable(s:closed)
    echo 'PlanetVim: no closed tab to reopen'
    return 0
  endif
  " The closed snapshot is distinct from every still-open tab's snapshot.
  return planet#tab#OpenFrom(s:closed)
endfunc

func! planet#tab#Cleanup() abort
  if !empty(s:directory)
    call delete(s:directory, 'rf')
  endif
  let s:directory = ''
  let s:snapshots = {}
  let s:closed = ''
  let s:closing = v:false
endfunc
