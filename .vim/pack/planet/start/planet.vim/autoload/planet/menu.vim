scriptversion 4

func! planet#menu#MenuifyName(name) abort
  let menu_name = a:name
  if empty(menu_name)
    let menu_name = "[No Name]"
  endif
  let menu_name = escape(menu_name, "\\. \t|")
  let menu_name = substitute(menu_name, "&", "&&", "g")
  let menu_name = substitute(menu_name, "\n", "^@", "g")
  return menu_name
endfunc

let s:roots = [
      \ ['planet', '🌐&P', 'PlanetVim'],
      \ ['basic', '📁&f', 'File'], ['basic', '📝&e', 'Edit'], ['basic', '✏️&m', 'Modify'],
      \ ['basic', '🔎&/', 'Search'], ['basic', '🖍️&i', 'Selection'], ['basic', '📺&v', 'View'],
      \ ['basic', '↕️&,', 'Go'], ['basic', '🧭&n', 'Navigation'],
      \ ['editing', '📋&"', 'Registers'], ['editing', "🔖&'", 'Marks'], ['editing', '🏷️&=', 'Markers'],
      \ ['editing', '🖌️&h', 'Highlights'], ['editing', '📎&k', 'Bookmarks'], ['editing', '📜&z', 'Folds'],
      \ ['editing', '&QF', 'Quickfix'], ['editing', '&LL', 'Location List'],
      \ ['dev', '❇️&[', 'LSP'], ['dev', '🪧&]', 'Tags'], ['dev', '🎚️&{', 'Environments'],
      \ ['dev', '📐&}', 'Generators'], ['dev', '🔨&b', 'Build'], ['dev', '▶️&r', 'Run'],
      \ ['dev', '🐞&d', 'Debug'], ['dev', '🧪&j', 'Test'], ['dev', '🔬&y', 'Analyze'], ['dev', '💻&c', 'Terminal'],
      \ ['tools', '🔀&g', 'Git'], ['tools', '⛏️&;', 'Diff/Patch'], ['tools', '🔤&\.', 'Writing'],
      \ ['tools', '🔠&-', 'Spelling'], ['tools', '🔧&o', 'Tools'],
      \ ['nav', '📖&u', 'Buffers'], ['nav', '🗃️&a', 'Arguments'], ['nav', '🪟&w', 'Windows'],
      \ ['nav', '🗂️&t', 'Tabs'], ['nav', '📚&s', 'Sessions'], ['nav', '🗄️&x', 'GUI'], ['nav', '🎛️&@', 'Apps'],
      \ ['settings', '⚙️&\\', 'Settings'], ['settings', '⌨️&\|', 'Maps'], ['settings', '❔&?', 'Help']]
let s:groups = ['basic', 'editing', 'dev', 'tools', 'nav', 'settings']

func! planet#menu#Roots() abort
  return deepcopy(s:roots)
endfunc

func! planet#menu#Visible(group) abort
  if a:group ==# 'planet' || get(s:, 'indexing', 0) | return 1 | endif
  if get(g:, 'PV_menu_style', 'emoji') ==# 'descriptive'
    return a:group ==# get(g:, 'PV_menu_group', 'basic')
  endif
  return get(g:, 'PlanetVim_menus_' .. a:group, 1)
endfunc

func! planet#menu#Style(style) abort
  if index(['emoji', 'plain', 'descriptive'], a:style) < 0
    throw 'PlanetVim: invalid menu style'
  endif
  let g:PV_menu_style = a:style
  call planet#config#SavePreference('PV_menu_style', a:style)
  call planet#menu#Refresh()
endfunc

func! planet#menu#Plain() abort
  call planet#menu#Style('plain')
endfunc

func! planet#menu#Group(group) abort
  if a:group ==# 'planet'
    call planet#menu#Refresh()
    return
  endif
  if index(s:groups, a:group) < 0 | throw 'PlanetVim: invalid menu group' | endif
  if get(g:, 'PV_menu_style', 'emoji') ==# 'descriptive'
    let g:PV_menu_group = a:group
    call planet#config#SavePreference('PV_menu_group', a:group)
  else
    let l:key = 'PlanetVim_menus_' .. a:group
    let g:[l:key] = !get(g:, l:key, 1)
    call planet#config#SavePreference(l:key, g:[l:key])
  endif
  call planet#menu#Refresh()
endfunc

func! planet#menu#RootPath(root) abort
  let l:style = get(g:, 'PV_menu_style', 'emoji')
  for [l:group, l:root, l:name] in s:roots
    if l:root !=# a:root | continue | endif
    if l:style ==# 'descriptive' | return escape(l:name, '\. |') | endif
    return substitute(l:style ==# 'plain' ? '[' .. matchstr(l:root, '&.*$') .. ']' : l:root, '&', '', 'g')
  endfor
  throw 'PlanetVim: unknown menu root'
endfunc

func! planet#menu#Refresh() abort
  " Remove using the old translations before replacing them. Dynamic menus use
  " these same canonical root names and inherit the current translation.
  for [l:group, l:root, l:name] in s:roots
    execute 'silent! aunmenu ' .. l:root
  endfor
  menutrans clear
  let l:style = get(g:, 'PV_menu_style', 'emoji')
  if l:style !=# 'emoji'
    for [l:group, l:root, l:name] in s:roots
      let l:target = l:style ==# 'plain' ? '[' .. matchstr(l:root, '&.*$') .. ']' : escape(l:name, ' .|')
      execute 'menutrans ' .. l:root .. ' ' .. l:target
    endfor
  endif
  let s:indexing = 1
  try
  for l:module in ['planet', 'basic', 'edit', 'dev', 'tools', 'nav', 'settings']
    call call('planet#menu#' .. l:module .. '#Update', [])
  endfor
  if planet#menu#Visible('nav')
    call planet#buffer#AddBuffers()
    if exists('g:startify_session_dir') | call planet#session#MenuList() | endif
    call planet#gui#MenuListVimServers()
    call planet#apps#MenuListGuiWindows()
    call planet#apps#WorkspaceListMenu()
  endif
  call planet#run#UpdateRunMenu()
  call planet#actions#Index()
  finally
    let s:indexing = 0
  endtry
  for [l:group, l:root, l:name] in s:roots
    if !planet#menu#Visible(l:group) | execute 'silent! aunmenu ' .. l:root | endif
  endfor
endfunc
