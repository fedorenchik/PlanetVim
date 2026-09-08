scriptversion 4

func! planet#winbar#Preset(kind) abort
  if a:kind ==# 'terminal'
    call PlanetVim_WinBarTerminalInit()
  elseif get(getwininfo(win_getid()), 0, {}).loclist
    nnoremenu WinBar.⏪ <Cmd>lolder<CR>
    nnoremenu WinBar.📙 <Cmd>lhistory<CR>
    nnoremenu WinBar.⏩ <Cmd>lnewer<CR>
    nnoremenu WinBar.❌ <Cmd>close<CR>
  else
    call PlanetVim_WinBarQfInit()
  endif
endfunc

func! planet#winbar#Refresh() abort
  silent! aunmenu WinBar
  let w:PV_winbar_buffers = filter(get(w:, 'PV_winbar_buffers', []), {_, number -> bufexists(number)})
  for l:number in w:PV_winbar_buffers
    let l:name = '[' .. l:number .. '] ' .. (empty(bufname(l:number)) ? '[No Name]' : fnamemodify(bufname(l:number), ':t'))
    execute 'anoremenu WinBar.' .. planet#menu#MenuifyName(l:name) .. ' <Cmd>confirm buffer ' .. l:number .. '<CR>'
  endfor
endfunc

func! planet#winbar#Change(action) abort
  let l:buffers = get(w:, 'PV_winbar_buffers', [])
  if a:action ==# 'add'
    if index(l:buffers, bufnr()) < 0
      call add(l:buffers, bufnr())
    endif
  elseif a:action ==# 'remove'
    call filter(l:buffers, {_, number -> number != bufnr()})
  elseif a:action ==# 'others'
    let l:buffers = index(l:buffers, bufnr()) < 0 ? [] : [bufnr()]
  elseif a:action ==# 'clear'
    let l:buffers = []
  else
    throw 'PlanetVim: unknown window bar action'
  endif
  let w:PV_winbar_buffers = l:buffers
  call planet#winbar#Refresh()
endfunc

func! planet#winbar#Terminal(direction) abort
  let l:terminals = sort(term_list(), 'n')
  if empty(l:terminals)
    return 0
  endif
  let l:index = index(l:terminals, bufnr())
  let l:next = (l:index + a:direction + len(l:terminals)) % len(l:terminals)
  execute 'confirm buffer ' .. l:terminals[l:next]
  return bufnr()
endfunc
