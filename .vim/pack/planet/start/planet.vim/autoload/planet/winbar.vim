vim9script
export def Preset(kind: any): any
  silent! aunmenu WinBar
  if kind ==# 'terminal'
    g:PlanetVim_WinBarTerminalInit()
  else
    g:PlanetVim_WinBarQfInit()
    if get(getwininfo(win_getid()), 0, {}).loclist
      PlanetMenu nnoremenu WinBar.⏪ <Cmd>lolder<CR>
      PlanetMenu nnoremenu WinBar.📙 <Cmd>lhistory<CR>
      PlanetMenu nnoremenu WinBar.⏩ <Cmd>lnewer<CR>
    endif
  endif
  return 0
enddef

export def Filter(exclude: any, arg_pattern: any = v:null): any
  var items: any
  var pattern: any = arg_pattern == null ? inputdialog('Filter list (Vim pattern): ', expand('<cword>')) : arg_pattern
  if empty(pattern)
    return 0
  endif
  var local: any = get(getwininfo(win_getid()), 0, {}).loclist
  var details: any = local ? getloclist(0, {items: 0, title: 0}) : getqflist({items: 0, title: 0})
  items = filter(copy(details.items), (_, lambda_item) => exclude ? lambda_item.text !~# pattern : lambda_item.text =~# pattern)
  var next: any = {items: items, title: details.title .. ' | ' .. (exclude ? 'exclude ' : 'keep ') .. pattern}
  if local
    setloclist(0, [], ' ', next)
  else
    setqflist([], ' ', next)
  endif
  return 1
enddef

export def Refresh(): any
  var name: any
  silent! aunmenu WinBar
  w:PV_winbar_buffers = filter(get(w:, 'PV_winbar_buffers', []), (_, lambda_number) => bufexists(lambda_number))
  for number in w:PV_winbar_buffers
    name = '[' .. number .. '] ' .. (empty(bufname(number)) ? '[No Name]' : fnamemodify(bufname(number), ':t'))
    execute 'PlanetMenu anoremenu WinBar.' .. planet#menu#MenuifyName(name) .. ' <Cmd>confirm buffer ' .. number .. '<CR>'
  endfor
  return 0
enddef

export def Change(action: any): any
  var buffers: any = get(w:, 'PV_winbar_buffers', [])
  if action ==# 'add'
    if index(buffers, bufnr()) < 0
      add(buffers, bufnr())
    endif
  elseif action ==# 'remove'
    filter(buffers, (_, lambda_number) => lambda_number != bufnr())
  elseif action ==# 'others'
    buffers = index(buffers, bufnr()) < 0 ? [] : [bufnr()]
  elseif action ==# 'clear'
    buffers = []
  else
    throw 'PlanetVim: unknown window bar action'
  endif
  w:PV_winbar_buffers = buffers
  planet#winbar#Refresh()
  return 0
enddef

export def Terminal(direction: any): any
  var terminals: any = sort(term_list(), 'n')
  if empty(terminals)
    return 0
  endif
  var index: any = index(terminals, bufnr())
  var next: any = (index + direction + len(terminals)) % len(terminals)
  execute 'confirm buffer ' .. terminals[next]
  return bufnr()
enddef
