scriptversion 4
let s:entries = []
let s:query = ''
let s:matches = []

func! s:Walk(path, label, group) abort
  let l:children = []
  for l:mode in ['', 'i', 't']
    for l:child in get(menu_info(a:path, l:mode), 'submenus', [])
      if index(l:children, l:child) < 0 | call add(l:children, l:child) | endif
    endfor
  endfor
  if !empty(l:children)
    for l:child in l:children
      call s:Walk(a:path .. '.' .. escape(l:child, '\. |'), a:label .. ' → ' .. l:child, a:group)
    endfor
    return
  endif
  let l:modes = {}
  for l:mode in ['n', 'i', 'x', 's', 'o', 'c', 't']
    let l:item = menu_info(a:path, l:mode)
    if get(l:item, 'enabled', 0) && get(l:item, 'rhs', '<Nop>') !=# '<Nop>'
      let l:modes[l:mode] = l:item
    endif
  endfor
  if empty(l:modes) | return | endif
  let l:search = tolower(substitute(a:label, '\(\l\)\(\u\)', '\1 \2', 'g'))
  for [l:pattern, l:words] in items({'diff': ' compare merge', 'inside': ' inner text object', 'recover': ' recovery swap rescue', 'filename': ' file path', 'complete': ' completion autocomplete', 'register': ' clipboard macro'})
    if l:search =~# l:pattern | let l:search ..= l:words | endif
  endfor
  call add(s:entries, #{path: a:path, label: a:label, group: a:group, modes: l:modes, search: l:search})
endfunc

func! planet#actions#Index() abort
  let s:entries = []
  for [l:group, l:root, l:label] in planet#menu#Roots()
    call s:Walk(planet#menu#RootPath(l:root), l:label, l:group)
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

func! s:Filter(id, key) abort
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
  let l:mode = mode()
  let l:kind = l:mode =~# '^[iR]' ? 'i' : index(['v', 'V', "\<C-v>"], l:mode) >= 0 ? 'x' : index(['s', 'S', "\<C-s>"], l:mode) >= 0 ? 's' : 'n'
  let s:context = #{mode: l:kind, window: win_getid(), buffer: bufnr(), cursor: getpos('.')}
  if index(['x', 's'], l:kind) >= 0 | let s:context.selection = planet#selection#Current() | endif
  let s:query = ''
  let s:matches = planet#actions#Search('', l:kind)
  return popup_menu(map(copy(s:matches), {_, item -> item.label}),
        \ #{title: ' Find Menu Action: type to filter; Enter runs; Esc cancels ',
        \ maxheight: 20, maxwidth: max([30, &columns - 8]), mapping: 0,
        \ filter: function('s:Filter'), callback: function('s:Chosen')})
endfunc
