vim9script

var script_state: dict<any> = {}

export def MenuifyName(name: string): string
  var menu_name: any = name
  if empty(menu_name)
    menu_name = "[No Name]"
  endif
  menu_name = escape(menu_name, "\\. \t|")
  menu_name = substitute(menu_name, "&", "&&", "g")
  menu_name = substitute(menu_name, "\n", "^@", "g")
  return menu_name
enddef

var script_roots = [ ['planet', '🌐&P', 'PlanetVim'], ['basic', '📁&f', 'File'], ['basic', '📝&e', 'Edit'], ['basic', '✏️&m', 'Modify'], ['basic', '🔎&/', 'Search'], ['basic', '🖍️&i', 'Selection'], ['basic', '📺&v', 'View'], ['basic', '↕️&,', 'Go'], ['basic', '🧭&n', 'Navigation'], ['editing', '📋&"', 'Registers'], ['editing', "🔖&'", 'Marks'], ['editing', '🏷️&=', 'Markers'], ['editing', '🖌️&h', 'Highlights'], ['editing', '📎&k', 'Bookmarks'], ['editing', '📜&z', 'Folds'], ['editing', '&QF', 'Quickfix'], ['editing', '&LL', 'Location List'], ['dev', '❇️&[', 'LSP'], ['dev', '🪧&]', 'Tags'], ['dev', '🎚️&{', 'Environments'], ['dev', '📐&}', 'Generators'], ['dev', '🔨&b', 'Build'], ['dev', '▶️&r', 'Run'], ['dev', '🐞&d', 'Debug'], ['dev', '🧪&j', 'Test'], ['dev', '🔬&y', 'Analyze'], ['dev', '💻&c', 'Terminal'], ['tools', '🔀&g', 'Git'], ['tools', '⛏️&;', 'Diff/Patch'], ['tools', '🔤&\.', 'Writing'], ['tools', '🔠&-', 'Spelling'], ['tools', '🔧&o', 'Tools'], ['nav', '📖&u', 'Buffers'], ['nav', '🗃️&a', 'Arguments'], ['nav', '🪟&w', 'Windows'], ['nav', '🗂️&t', 'Tabs'], ['nav', '📚&s', 'Sessions'], ['nav', '🗄️&x', 'GUI'], ['nav', '🎛️&@', 'Apps'], ['settings', '⚙️&\\', 'Settings'], ['settings', '⌨️&\|', 'Maps'], ['settings', '❔&?', 'Help']]
var script_groups = ['basic', 'editing', 'dev', 'tools', 'nav', 'settings']

export def Roots(): list<list<string>>
  return deepcopy(script_roots)
enddef

export def Visible(group: string): any
  if group ==# 'planet' || get(script_state, 'indexing', 0)
    return 1
  endif
  if get(g:, 'PV_menu_style', 'emoji') ==# 'descriptive'
    return group ==# get(g:, 'PV_menu_group', 'basic')
  endif
  return get(g:, 'PlanetVim_menus_' .. group, 1)
enddef

export def Style(style: string): number
  if index(['emoji', 'plain', 'descriptive'], style) < 0
    throw 'PlanetVim: invalid menu style'
  endif
  g:PV_menu_style = style
  planet#config#SavePreference('PV_menu_style', style)
  planet#menu#Refresh()
  return 0
enddef

export def Plain(): number
  planet#menu#Style('plain')
  return 0
enddef

export def Group(group: string): number
  var key: any
  if group ==# 'planet'
    planet#menu#Refresh()
    return 0
  endif
  if index(script_groups, group) < 0
    throw 'PlanetVim: invalid menu group'
  endif
  if get(g:, 'PV_menu_style', 'emoji') ==# 'descriptive'
    g:PV_menu_group = group
    planet#config#SavePreference('PV_menu_group', group)
  else
    key = 'PlanetVim_menus_' .. group
    g:[key] = get(g:, key, 1) ? 0 : 1
    planet#config#SavePreference(key, g:[key])
  endif
  planet#menu#Refresh()
  return 0
enddef

export def RootPath(arg_root: string): string
  var root: any
  var style: any = get(g:, 'PV_menu_style', 'emoji')
  for [group, item_root, name] in script_roots
    root = item_root
    if root !=# arg_root
      continue
    endif
    if style ==# 'descriptive'
      return escape(name, '\. |')
    endif
    return substitute(style ==# 'plain' ? '[' .. matchstr(root, '&.*$') .. ']' : root, '&', '', 'g')
  endfor
  throw 'PlanetVim: unknown menu root'
enddef

export def Refresh(index_actions: bool = false): number
  var target: any
  var root: any
  var group: any
  var name: any
  planet#menu_help#Begin()
  # Remove using the old translations before replacing them. Dynamic menus use
  # these same canonical root names and inherit the current translation.
  for [item_group, item_root, item_name] in script_roots
    root = item_root
    group = item_group
    name = item_name
    execute 'silent! aunmenu ' .. root
  endfor
  menutrans clear
  var style: any = get(g:, 'PV_menu_style', 'emoji')
  if style !=# 'emoji'
    for [item_group, item_root, item_name] in script_roots
      root = item_root
      group = item_group
      name = item_name
      target = style ==# 'plain' ? '[' .. matchstr(root, '&.*$') .. ']' : escape(name, ' .|')
      execute 'menutrans ' .. root .. ' ' .. target
    endfor
  endif
  script_state.indexing = index_actions
  try
    for module in ['planet', 'basic', 'edit', 'dev', 'tools', 'nav', 'settings']
      call('planet#menu#' .. module .. '#Update', [])
    endfor
    if planet#menu#Visible('nav')
      planet#buffer#AddBuffers()
      if exists('g:startify_session_dir')
        planet#session#MenuList()
      endif
      planet#gui#MenuListVimServers()
      planet#apps#MenuListGuiWindows()
      planet#apps#WorkspaceListMenu()
    endif
    planet#run#UpdateRunMenu()
    if index_actions
      planet#actions#Index()
    else
      planet#actions#Invalidate()
    endif
  finally
    script_state.indexing = 0
  endtry
  for [item_group, item_root, item_name] in script_roots
    root = item_root
    group = item_group
    name = item_name
    if !planet#menu#Visible(group)
      execute 'silent! aunmenu ' .. root
    endif
  endfor
  return 0
enddef
