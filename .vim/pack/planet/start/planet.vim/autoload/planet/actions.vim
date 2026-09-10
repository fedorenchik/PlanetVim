vim9script
var script_context: any
var script_entries = []
var script_query = ''
var script_matches = []
var index_dirty = true

export def Invalidate()
  index_dirty = true
enddef

def EnsureIndex()
  if !index_dirty
    return
  endif
  # Build hidden groups only when the finder needs them. Refresh removes them
  # again after indexing, preserving the selected menubar style and group.
  if !empty(filter(planet#menu#Roots(), (_, root) => !planet#menu#Visible(root[0])))
    planet#menu#Refresh(true)
  else
    Index()
  endif
enddef

export def Index(visible_only: any = 0): any
  var path: any
  if !visible_only
    script_entries = []
  endif
  for [group, root, label] in planet#menu#Roots()
    path = planet#menu#RootPath(root)
    if visible_only
      if empty(menu_info(path)) && empty(menu_info(path, 'i'))
        continue
      endif
      filter(script_entries, (_, lambda_item) => stridx(lambda_item.path, path .. '.') != 0)
    endif
    extend(script_entries, planet#action_index#Build(path, label, group))
  endfor
  index_dirty = false
  return 0
enddef

export def Search(query: any, mode: any = 'n'): any
  EnsureIndex()
  var found: any
  var result: any = []
  for item in script_entries
    if !has_key(item.modes, mode)
      continue
    endif
    found = 1
    for word in split(tolower(query))
      if stridx(item.search, word) < 0
        found = 0
        break
      endif
    endfor
    if found
      add(result, deepcopy(item))
    endif
  endfor
  return result
enddef

export def Keys(rhs: any): any
  return substitute(rhs, '<[^<>]\+>', (lambda_m) => eval('"\' .. escape(lambda_m[0], '\"') .. '"'), 'g')
enddef

export def Execute(item: any, context: any): any
  if !win_gotoid(context.window) || bufnr() != context.buffer
    echomsg 'PlanetVim: the original editing window is no longer available'
    return 0
  endif
  if !planet#menu#Visible(item.group)
    planet#menu#Group(item.group)
  endif
  if has_key(context, 'selection')
    planet#selection#Restore(context.selection)
    if context.mode ==# 's'
      execute "normal! \<C-g>"
    endif
  else
    setpos('.', context.cursor)
  endif
  var mapping: any = item.modes[context.mode]
  var keys: any = planet#actions#Keys(mapping.rhs)
  if context.mode ==# 'i' && mode() !~# '^[iR]'
    keys = (context.cursor[2] > strlen(getline('.')) && !empty(getline('.')) ? 'a' : 'i') .. keys
  endif
  # :emenu inside a script uses exec_normal_cmd(), even for an Insert menu.
  # Queue the actual mapping in the restored mode, as a GUI menu click does.
  feedkeys(keys, get(mapping, 'noremenu', 0) ? 'in' : 'im')
  return 1
enddef

def LocalChosen(id: any, result: any): any
  if result > 0 && result <= len(script_matches)
    planet#actions#Execute(script_matches[result - 1], script_context)
  endif
  return 0
enddef

export def Help(item: any, mode: any = 'n'): any
  var option: any
  var rhs: any = get(get(item.modes, mode, {}), 'rhs', '')
  var topic: any = matchstr(rhs, '\<help\s\+\zs[^< ]*')
  if empty(topic)
    option = matchstr(rhs, "preferences#\\%(Set\\|Toggle\\|Flag\\)('\\zs[^']*")
    if !empty(option)
      topic = "'" .. option .. "'"
    endif
  endif
  if empty(topic) && index(getcompletion(rhs, 'help'), rhs) >= 0
    topic = rhs
  endif
  if empty(topic)
    topic = get({'basic': 'usr_02.txt', 'editing': 'change.txt', 'dev': 'usr_29.txt', 'tools': 'usr_30.txt', 'nav': 'windows.txt', 'settings': 'options.txt', 'planet': 'planetvim'}, item.group, 'index')
  endif
  planet#learn#Help(topic)
  popup_create([item.label, 'Mode: ' .. mode, 'Menu mapping: ' .. rhs, 'Help: ' .. topic, 'Press Escape or click outside to close this note.'],
       {title: ' Menu Action Help ', pos: 'topleft', line: 2, col: 2, maxwidth: max([30, &columns - 6]),
       maxheight: 8, padding: [1, 1, 1, 1], close: 'click', filter: 'popup_filter_yesno', mapping: 0})
  return 0
enddef

def LocalFilter(id: any, key: any): any
  var index: any
  var item: any
  if key ==# "\<F1>"
    index = getcurpos(id)[1] - 1
    if index >= 0 && index < len(script_matches)
      item = script_matches[index]
      popup_close(id, -1)
      planet#actions#Help(item, script_context.mode)
    endif
    return 1
  endif
  if key ==# "\<BS>" || key ==# "\<C-h>"
    script_query = strcharpart(script_query, 0, max([0, strchars(script_query) - 1]))
  elseif strchars(key) == 1 && char2nr(key) >= 32 && key !=# "\<Del>"
    script_query ..= key
  else
    return popup_filter_menu(id, key)
  endif
  script_matches = planet#actions#Search(script_query, script_context.mode)
  popup_settext(id, empty(script_matches) ? ['No matching actions'] : map(copy(script_matches), (_, lambda_item) => lambda_item.label))
  popup_setoptions(id, {title: ' Find Menu Action: ' .. script_query .. ' '})
  win_execute(id, 'normal! gg')
  return 1
enddef

export def Open(): any
  # Refresh changing buffer/session/run entries, retaining hidden groups.
  if index_dirty
    EnsureIndex()
  else
    planet#actions#Index(1)
  endif
  var mode: any = mode()
  var kind: any = mode =~# '^[iR]' ? 'i' : index(['v', 'V', "\<C-v>"], mode) >= 0 ? 'x' : index(['s', 'S', "\<C-s>"], mode) >= 0 ? 's' : 'n'
  script_context = {mode: kind, window: win_getid(), buffer: bufnr(), cursor: getpos('.')}
  if index(['x', 's'], kind) >= 0
    script_context.selection = planet#selection#Current()
  endif
  script_query = ''
  script_matches = planet#actions#Search('', kind)
  return popup_menu(map(copy(script_matches), (_, lambda_item) => lambda_item.label), {title: ' Find Menu Action: type to filter; Enter runs; F1 help; Esc cancels ',
       maxheight: 20, maxwidth: max([30, &columns - 8]), mapping: 0, filter: function(LocalFilter), callback: function(LocalChosen)})
enddef
