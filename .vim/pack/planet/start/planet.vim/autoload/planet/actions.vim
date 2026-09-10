scriptversion 4
let s:entries = []
let s:query = ''
let s:matches = []

func! planet#actions#Index(visible_only = 0) abort
  if !a:visible_only | let s:entries = [] | endif
  for [l:group, l:root, l:label] in planet#menu#Roots()
    let l:path = planet#menu#RootPath(l:root)
    if a:visible_only
      if empty(menu_info(l:path)) && empty(menu_info(l:path, 'i')) | continue | endif
      call filter(s:entries, {_, item -> stridx(item.path, l:path .. '.') != 0})
    endif
    call extend(s:entries, planet#action_index#Build(l:path, l:label, l:group))
  endfor
endfunc

func! planet#actions#Search(query, mode = 'n') abort
  let l:result = []
  for l:item in s:entries
    if !has_key(l:item.modes, a:mode) | continue | endif
    let l:found = 1
    for l:word in split(tolower(a:query))
      if stridx(l:item.search, l:word) < 0 | let l:found = 0 | break | endif
    endfor
    if l:found | call add(l:result, deepcopy(l:item)) | endif
  endfor
  return l:result
endfunc

func! planet#actions#Keys(rhs) abort
  return substitute(a:rhs, '<[^<>]\+>', {m -> eval('"\' .. escape(m[0], '\"') .. '"')}, 'g')
endfunc

func! planet#actions#Execute(item, context) abort
  if !win_gotoid(a:context.window) || bufnr() != a:context.buffer
    echomsg 'PlanetVim: the original editing window is no longer available'
    return 0
  endif
  if !planet#menu#Visible(a:item.group) | call planet#menu#Group(a:item.group) | endif
  if has_key(a:context, 'selection')
    call planet#selection#Restore(a:context.selection)
    if a:context.mode ==# 's' | execute "normal! \<C-g>" | endif
  else
    call setpos('.', a:context.cursor)
  endif
  let l:mapping = a:item.modes[a:context.mode]
  let l:keys = planet#actions#Keys(l:mapping.rhs)
  if a:context.mode ==# 'i' && mode() !~# '^[iR]'
    let l:keys = (a:context.cursor[2] > strlen(getline('.')) && !empty(getline('.')) ? 'a' : 'i') .. l:keys
  endif
  " :emenu inside a script uses exec_normal_cmd(), even for an Insert menu.
  " Queue the actual mapping in the restored mode, as a GUI menu click does.
  call feedkeys(l:keys, get(l:mapping, 'noremenu', 0) ? 'in' : 'im')
  return 1
endfunc

func! s:Chosen(id, result) abort
  if a:result > 0 && a:result <= len(s:matches)
    call planet#actions#Execute(s:matches[a:result - 1], s:context)
  endif
endfunc

func! planet#actions#Help(item, mode = 'n') abort
  let l:rhs = get(get(a:item.modes, a:mode, {}), 'rhs', '')
  let l:topic = matchstr(l:rhs, '\<help\s\+\zs[^< ]*')
  if empty(l:topic)
    let l:option = matchstr(l:rhs, "preferences#\\%(Set\\|Toggle\\|Flag\\)('\\zs[^']*")
    if !empty(l:option) | let l:topic = "'" .. l:option .. "'" | endif
  endif
  if empty(l:topic) && index(getcompletion(l:rhs, 'help'), l:rhs) >= 0 | let l:topic = l:rhs | endif
  if empty(l:topic)
    let l:topic = get({'basic': 'usr_02.txt', 'editing': 'change.txt', 'dev': 'usr_29.txt', 'tools': 'usr_30.txt', 'nav': 'windows.txt', 'settings': 'options.txt', 'planet': 'planetvim'}, a:item.group, 'index')
  endif
  call planet#learn#Help(l:topic)
  call popup_create([a:item.label, 'Mode: ' .. a:mode, 'Menu mapping: ' .. l:rhs, 'Help: ' .. l:topic, 'Press Escape or click outside to close this note.'],
        \ #{title: ' Menu Action Help ', pos: 'topleft', line: 2, col: 2, maxwidth: max([30, &columns - 6]), maxheight: 8, padding: [1, 1, 1, 1], close: 'click', filter: 'popup_filter_yesno', mapping: 0})
endfunc

func! s:Filter(id, key) abort
  if a:key ==# "\<F1>"
    let l:index = getcurpos(a:id)[1] - 1
    if l:index >= 0 && l:index < len(s:matches)
      let l:item = s:matches[l:index]
      call popup_close(a:id, -1)
      call planet#actions#Help(l:item, s:context.mode)
    endif
    return 1
  endif
  if a:key ==# "\<BS>" || a:key ==# "\<C-h>"
    let s:query = strcharpart(s:query, 0, max([0, strchars(s:query) - 1]))
  elseif strchars(a:key) == 1 && char2nr(a:key) >= 32 && a:key !=# "\<Del>"
    let s:query ..= a:key
  else
    return popup_filter_menu(a:id, a:key)
  endif
  let s:matches = planet#actions#Search(s:query, s:context.mode)
  call popup_settext(a:id, empty(s:matches) ? ['No matching actions'] : map(copy(s:matches), {_, item -> item.label}))
  call popup_setoptions(a:id, #{title: ' Find Menu Action: ' .. s:query .. ' '})
  call win_execute(a:id, 'normal! gg')
  return 1
endfunc

func! planet#actions#Open() abort
  " Refresh changing buffer/session/run entries, retaining hidden groups.
  call planet#actions#Index(1)
  let l:mode = mode()
  let l:kind = l:mode =~# '^[iR]' ? 'i' : index(['v', 'V', "\<C-v>"], l:mode) >= 0 ? 'x' : index(['s', 'S', "\<C-s>"], l:mode) >= 0 ? 's' : 'n'
  let s:context = #{mode: l:kind, window: win_getid(), buffer: bufnr(), cursor: getpos('.')}
  if index(['x', 's'], l:kind) >= 0 | let s:context.selection = planet#selection#Current() | endif
  let s:query = ''
  let s:matches = planet#actions#Search('', l:kind)
  return popup_menu(map(copy(s:matches), {_, item -> item.label}),
        \ #{title: ' Find Menu Action: type to filter; Enter runs; F1 help; Esc cancels ',
        \ maxheight: 20, maxwidth: max([30, &columns - 8]), mapping: 0,
        \ filter: function('s:Filter'), callback: function('s:Chosen')})
endfunc
