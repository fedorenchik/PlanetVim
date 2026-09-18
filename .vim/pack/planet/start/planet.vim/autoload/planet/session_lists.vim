vim9script

# Keep data in the atomic native session snapshot. Buffer/window/list IDs and
# callback closures belong to one Vim process and must not be persisted.
def Literal(value: any, depth: number = 0): string
  if depth > 20
    return 'v:null'
  endif
  if type(value) == v:t_dict
    return '{' .. join(mapnew(items(value), (_, pair) => Literal(pair[0]) .. ': ' .. Literal(pair[1], depth + 1)), ', ') .. '}'
  elseif type(value) == v:t_list
    return '[' .. join(mapnew(value, (_, item) => Literal(item, depth + 1)), ', ') .. ']'
  elseif type(value) == v:t_string
    # string() leaves literal newlines inside quotes, invalid in sourced files.
    return '"' .. substitute(escape(value, '\"'), '[[:cntrl:]]', '\=printf("\\x%02x", char2nr(submatch(0)))', 'g') .. '"'
  elseif type(value) == v:t_bool
    return value ? 'v:true' : 'v:false'
  elseif type(value) == v:t_none
    return string(value) =~# 'none$' ? 'v:none' : 'v:null'
  elseif type(value) == v:t_float
    return 'str2float(' .. string(string(value)) .. ')'
  elseif index([v:t_number, v:t_blob], type(value)) >= 0
    return string(value)
  endif
  return 'v:null'
enddef

def Get(window: number, what: dict<any>): dict<any>
  return window == 0 ? getqflist(what) : getloclist(window, what)
enddef

def Stack(window: number): dict<any>
  var lists: list<dict<any>> = []
  for nr in range(1, get(Get(window, {nr: '$'}), 'nr', 0))
    var info = Get(window, {nr: nr, items: 0, title: 0, idx: 0, context: 0})
    remove(info, 'nr')
    for item in info.items
      var name = bufname(item.bufnr)
      if item.bufnr > 0 && !empty(name)
        item.filename = fnamemodify(name, ':p')
      else
        item.valid = 0
      endif
      remove(item, 'bufnr')
    endfor
    add(lists, info)
  endfor
  return {lists: lists, current: get(Get(window, {nr: 0}), 'nr', 0)}
enddef

def SavedWindow(window: dict<any>, options: list<string>): bool
  var kind = getbufvar(window.bufnr, '&buftype')
  if kind ==# 'terminal'
    return index(options, 'terminal') >= 0 && term_getstatus(window.bufnr) =~# 'running'
  elseif kind ==# 'help'
    return index(options, 'help') >= 0
  elseif empty(bufname(window.bufnr)) || index(['nofile', 'acwrite', 'prompt', 'popup'], kind) >= 0
    return index(options, 'blank') >= 0
  endif
  return true
enddef

export def Capture(options: string): string
  var flags = split(options, ',')
  var windows: list<dict<any>> = []
  var numbers: dict<number> = {}
  var positions: dict<number> = {}
  var list_owners: dict<number> = {}
  var owners: list<number> = []
  var list_ids: list<number> = []
  for window in getwininfo()
    if window.tabnr == 0 || (index(flags, 'tabpages') < 0 && window.tabnr != tabpagenr())
        || !SavedWindow(window, flags)
      continue
    endif
    var tab = index(flags, 'tabpages') < 0 ? 1 : window.tabnr
    numbers[string(tab)] = get(numbers, string(tab), 0) + 1
    positions[string(window.winid)] = len(windows)
    var kind = window.loclist ? 'location' : window.quickfix ? 'quickfix' : 'file'
    add(windows, {tab: tab, nr: numbers[string(tab)], kind: kind,
      stack: Stack(window.winid)})
    var id = getloclist(window.winid, {id: 0}).id
    add(list_ids, id)
    if kind !=# 'location' && id > 0
      list_owners[string(id)] = len(windows) - 1
    endif
    add(owners, kind ==# 'location' ? getloclist(window.winid, {filewinid: 0}).filewinid : 0)
  endfor
  for index in range(len(windows))
    windows[index].owner = get(positions, string(owners[index]), -1)
    if windows[index].kind ==# 'location' && windows[index].owner < 0
      windows[index].owner = get(list_owners, string(list_ids[index]), -1)
    endif
    if windows[index].kind ==# 'location' && windows[index].owner >= 0
      windows[index].stack = {}
    endif
  endfor
  return Literal({quickfix: Stack(0), windows: windows})
enddef

export def Clear()
  setqflist([], 'f')
  for window in getwininfo()
    if window.tabnr > 0 && !window.loclist
      setloclist(window.winid, [], 'f')
    endif
  endfor
enddef

export def HasLists(): bool
  if getqflist({nr: '$'}).nr > 0
    return true
  endif
  for window in getwininfo()
    if window.tabnr > 0 && getloclist(window.winid, {nr: '$'}).nr > 0
      return true
    endif
  endfor
  return false
enddef

def Put(window: number, stack: dict<any>)
  for info in stack.lists
    if window == 0
      setqflist([], ' ', info)
    else
      setloclist(window, [], ' ', info)
    endif
  endfor
  var older = len(stack.lists) - stack.current
  if older > 0 && stack.current > 0
    if window == 0
      execute 'silent colder ' .. older
    else
      win_execute(window, 'silent lolder ' .. older)
    endif
  endif
enddef

export def Restore(state: dict<any>)
  if empty(v:this_session)
    return
  endif
  Clear()
  Put(0, state.quickfix)
  # Native mksession restores quickfix/location windows as empty placeholders.
  # Record their IDs before opening panels changes the window numbering.
  var ids = mapnew(state.windows, (_, window) => win_getid(window.nr, window.tab))
  var current = win_getid()
  var sizes: dict<string> = {}
  for index in range(len(state.windows))
    var window = state.windows[index]
    if ids[index] > 0 && window.kind ==# 'file'
      Put(ids[index], window.stack)
    elseif ids[index] > 0
      # "All options" marks both placeholders as quickfix buffers, but neither
      # has a real list association yet. Do not let :copen reuse the wrong one.
      setbufvar(winbufnr(ids[index]), '&buftype', '')
    endif
  endfor
  try
    # A quickfix window can itself own a location list. Recreate it first.
    var panels = filter(range(len(state.windows)), (_, i) => state.windows[i].kind ==# 'quickfix')
      + filter(range(len(state.windows)), (_, i) => state.windows[i].kind ==# 'location')
    for index in panels
      var window = state.windows[index]
      var placeholder = ids[index]
      if placeholder == 0 || window.kind ==# 'file'
        continue
      endif
      win_gotoid(placeholder)
      var tab = string(tabpagenr())
      if !has_key(sizes, tab)
        sizes[tab] = winrestcmd()
      endif
      var owner = window.owner >= 0 ? ids[window.owner] : 0
      if window.kind ==# 'location'
        if owner == 0
          # A location panel may outlive its file window.
          owner = placeholder
          Put(owner, window.stack)
        endif
        win_gotoid(owner)
        if getloclist(owner, {nr: 0}).nr == 0
          setloclist(owner, [], ' ', {title: ''})
        endif
        lopen
      else
        copen
      endif
      var panel = win_getid()
      if window.kind ==# 'quickfix'
        Put(panel, window.stack)
      endif
      if panel != placeholder
        win_splitmove(panel, placeholder, {vertical: false, rightbelow: false})
        win_execute(placeholder, 'close')
        ids[index] = panel
        if current == placeholder
          current = panel
        endif
      endif
    endfor
    for [tab, command] in items(sizes)
      execute 'noautocmd tabnext ' .. tab
      execute command
    endfor
  finally
    win_gotoid(current)
  endtry
enddef
