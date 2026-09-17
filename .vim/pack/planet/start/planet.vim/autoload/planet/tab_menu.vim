vim9script

const root = ']PVTab'
var menu_id = ''
var menu_window = 0
var menu_buffer = 0
var menu_mode = 'n'

def Add(order: number, label: string, action: string, command: string = '', enabled: bool = true)
  var path = root .. '.' .. planet#menu#MenuifyName(label)
  if !empty(command) | path ..= '<Tab>' .. escape(command, ' |') | endif
  var rhs = action == '' ? '<Nop>' : '<Cmd>call planet#tab_menu#Action('
    .. string(menu_id) .. ', ' .. string(action) .. ', ' .. menu_window .. ', ' .. menu_buffer .. ')<CR>'
  execute planet#menu_help#Entry(menu_mode .. 'noremenu <silent> 1.' .. order .. ' ', path, rhs)
  if !enabled | execute menu_mode .. 'menu disable ' .. path | endif
enddef

export def Build(id: string): bool
  var tab = planet#tab#Find(id)
  if tab == 0 | return false | endif
  var previous_error = v:errmsg
  silent! aunmenu ]PVTab
  silent! tlunmenu ]PVTab
  v:errmsg = previous_error
  planet#menu_help#ForgetPopup(root)
  menu_id = id
  menu_window = win_getid(tabpagewinnr(tab), tab)
  menu_buffer = winbufnr(menu_window)
  var m = mode()
  menu_mode = m ==# 't' ? 'tl' : m =~# '^[vV\x16]' ? 'x' : m =~# '^[sS\x13]' ? 's' : m ==# 'i' ? 'i' : 'n'
  var count = tabpagenr('$')
  Add(10, 'Tab ' .. tab .. ' — ' .. (tab == tabpagenr() ? 'Current' : 'Inactive'), '', '', false)
  Add(20, 'Activate Tab', 'activate', ':tabnext', tab != tabpagenr())
  Add(20, 'New Tab', 'new', ':tabnew')
  Add(20, 'Open File in New Tab…', 'open', ':browse tabnew')
  Add(20, 'Duplicate Tab Layout', 'duplicate')
  Add(20, 'Reopen Closed Tab', 'reopen', '', planet#tab#CanReopen())
  Add(25, '-close-', '')
  Add(30, 'Close Tab', 'close', ':tabclose', count > 1)
  Add(30, 'Close Other Tabs', 'others', ':tabonly', count > 1)
  Add(30, 'Close Tabs to the Left', 'close-left', '', tab > 1)
  Add(30, 'Close Tabs to the Right', 'close-right', '', tab < count)
  Add(35, '-move-', '')
  Add(40, 'Move Tab Left', 'left', ':tabmove -1', tab > 1)
  Add(40, 'Move Tab Right', 'right', ':tabmove +1', tab < count)
  Add(40, 'Move Tab First', 'first', ':0tabmove', tab > 1)
  Add(40, 'Move Tab Last', 'last', ':tabmove', tab < count)
  Add(45, '-layout-', '')
  Add(50, 'Save Tab Layout…', 'save-layout')
  Add(50, 'Open Tab Layout…', 'open-layout')
  if getbufvar(menu_buffer, '&buftype') == ''
    Add(55, '-file-', '')
    Add(60, 'Save File', 'save', ':write', getbufvar(menu_buffer, '&modifiable'))
    Add(60, 'Save File As…', 'save-as', ':browse saveas', getbufvar(menu_buffer, '&modifiable'))
    if !empty(bufname(menu_buffer))
      Add(60, 'Copy File Path', 'path')
      Add(60, 'Copy Relative File Path', 'relative')
      Add(60, 'Reveal File in Tree', 'reveal')
      Add(60, 'Open Terminal Here', 'terminal')
    endif
  endif
  return true
enddef

export def Show(id: string)
  if Build(id)
    popup! ]PVTab
  endif
enddef

def Select(id: string): bool
  var tab = planet#tab#Find(id)
  if tab == 0 | return false | endif
  execute 'tabnext ' .. tab
  return true
enddef

def CloseSet(id: string, action: string)
  var target = planet#tab#Find(id)
  var ids: list<string> = []
  for tab in gettabinfo()
    if (action ==# 'close' && tab.tabnr == target)
        || (action ==# 'others' && tab.tabnr != target)
        || (action ==# 'close-left' && tab.tabnr < target)
        || (action ==# 'close-right' && tab.tabnr > target)
      add(ids, planet#tab#Id(tab.tabnr))
    endif
  endfor
  for closing in ids
    if tabpagenr('$') <= 1 | break | endif
    if !Select(closing) | continue | endif
    planet#tab#Close()
    # A cancelled save/discard prompt must stop the entire batch.
    if planet#tab#Find(closing) != 0 | break | endif
  endfor
enddef

export def Action(id: string, action: string, window: number = 0, buffer: number = 0)
  if planet#tab#Find(id) == 0 | return | endif
  if index(['save', 'save-as', 'path', 'relative', 'reveal', 'terminal'], action) >= 0
    if win_id2tabwin(window)[0] != planet#tab#Find(id) || winbufnr(window) != buffer
      echo 'PlanetVim: the clicked file changed; open the tab menu again'
      return
    endif
    if action ==# 'path' || action ==# 'relative'
      win_execute(window, 'call setreg("+", expand("' .. (action ==# 'path' ? '%:p' : '%:.') .. '"))')
      return
    elseif action ==# 'save' || action ==# 'save-as'
      win_execute(window, (action ==# 'save-as' || empty(bufname(buffer))) ? 'browse confirm saveas' : 'confirm write')
      return
    endif
  endif
  var origin = win_getid()
  var restore = index(['close', 'others', 'close-left', 'close-right', 'left', 'right', 'first', 'last', 'save-layout'], action) >= 0
  # Layout changes deliberately leave Visual/Select mode; merely opening the
  # menu and copying paths preserve it, and terminal actions never inject text.
  if mode() =~# '^[vVsS\x16\x13]' | execute "normal! \<Esc>" | endif
  try
    if index(['close', 'others', 'close-left', 'close-right'], action) >= 0
      CloseSet(id, action)
      return
    endif
    if !Select(id) | return | endif
    if action ==# 'activate'
      return
    elseif action ==# 'new'
      tabnew
    elseif action ==# 'open'
      browse tabnew
    elseif action ==# 'reopen'
      planet#tab#Reopen()
    elseif action ==# 'duplicate'
      var path = tempname() .. '.tab.vim'
      try
        planet#tab#SaveTo(path)
        planet#tab#OpenFrom(path)
      finally
        delete(path)
      endtry
    elseif action ==# 'left' && tabpagenr() > 1
      tabmove -1
    elseif action ==# 'right' && tabpagenr() < tabpagenr('$')
      tabmove +1
    elseif action ==# 'first'
      execute ':0tabmove'
    elseif action ==# 'last'
      tabmove
    elseif action ==# 'save-layout'
      planet#tab#Save()
    elseif action ==# 'open-layout'
      planet#tab#Open()
    elseif action ==# 'reveal'
      win_gotoid(window)
      execute 'Fern ' .. fnameescape(expand('%:p:h')) .. ' -reveal=' .. fnameescape(expand('%:p'))
    elseif action ==# 'terminal'
      win_gotoid(window)
      planet#term#RunCmd([&shell], false, false, false, expand('%:p:h'))
    endif
  finally
    if restore && win_id2tabwin(origin)[0] != 0 | win_gotoid(origin) | endif
  endtry
enddef
