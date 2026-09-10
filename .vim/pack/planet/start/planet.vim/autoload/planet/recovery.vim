scriptversion 4

func! planet#recovery#List() abort
  let l:items = []
  for l:path in swapfilelist()
    let l:info = swapinfo(l:path)
    let l:info.path = fnamemodify(l:path, ':p')
    let l:info.live = get(l:info, 'host', '') ==# strpart(hostname(), 0, 39) && isdirectory('/proc/' .. get(l:info, 'pid', 0))
    call add(l:items, l:info)
  endfor
  return l:items
endfunc

func! planet#recovery#Recover(path = v:null) abort
  let l:path = a:path
  if l:path is v:null
    let l:items = planet#recovery#List()
    if empty(l:items) | echomsg 'PlanetVim: no swap files found in the configured directory option' | return 0 | endif
    let l:index = planet#prompt#Choose('Choose a swap file to recover into a new tab:', map(copy(l:items), {_, item -> get(item, 'fname', item.path) .. (item.live ? ' [LIVE — close its owner first]' : '') .. ' — ' .. item.path}))
    if l:index < 0 | return 0 | endif
    let l:path = l:items[l:index].path
  endif
  if l:path is v:null || empty(l:path) | return 0 | endif
  let l:info = swapinfo(l:path)
  if has_key(l:info, 'error') | echomsg 'PlanetVim: ' .. l:info.error | return 0 | endif
  if get(l:info, 'host', '') ==# strpart(hostname(), 0, 39) && isdirectory('/proc/' .. get(l:info, 'pid', 0))
    echomsg 'PlanetVim: this swap file belongs to a running Vim process; close that editor first'
    return 0
  endif
  if get(l:info, 'host', '') !=# strpart(hostname(), 0, 39)
    if confirm('The swap belongs to host ' .. get(l:info, 'host', '?') .. '. Its owner cannot be checked here. Recover a separate copy?', "&Recover copy\n&Cancel", 2) != 1 | return 0 | endif
  endif
  let l:origin = win_getid()
  tabnew
  setlocal noswapfile
  try
    execute 'silent recover ' .. fnameescape(l:path)
    let b:PV_recovered_swap = l:path
    let b:PV_recovery_original = get(l:info, 'fname', '')
    setlocal readonly bufhidden=hide
    echomsg 'PlanetVim: recovered into a new tab. Compare with Disk, then Save Recovered Copy. The swap file was retained.'
    return 1
  catch
    let l:error = v:exception
    " Leave any partial recovered text available for inspection.
    if empty(getline(1, '$')) || getline(1, '$') ==# ['']
      bwipeout!
      call win_gotoid(l:origin)
    endif
    echomsg 'PlanetVim recovery: ' .. l:error
    return 0
  endtry
endfunc

func! planet#recovery#Browse() abort
  let l:path = planet#prompt#Ask('Swap file to recover: ', '', 'file')
  if l:path is v:null || empty(l:path) | return 0 | endif
  return planet#recovery#Recover(l:path)
endfunc

func! planet#recovery#Compare() abort
  let l:path = get(b:, 'PV_recovery_original', expand('%:p'))
  if !filereadable(l:path) | echomsg 'PlanetVim: there is no readable on-disk file to compare' | return 0 | endif
  let l:origin = win_getid()
  vertical new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  try
    execute 'silent 0read ++edit ' .. fnameescape(l:path)
    silent $delete _
    setlocal nomodifiable readonly nomodified
    diffthis
    call win_gotoid(l:origin)
    diffthis
    return 1
  catch
    let l:error = v:exception
    bwipeout!
    call win_gotoid(l:origin)
    echomsg 'PlanetVim compare: ' .. l:error
    return 0
  endtry
endfunc

func! planet#recovery#SaveCopy(path = v:null) abort
  let l:path = a:path is v:null ? planet#prompt#Ask('Save a separate copy as: ', expand('%:p') .. '.recovered', 'file') : a:path
  if l:path is v:null || empty(l:path) | return 0 | endif
  if getftype(l:path) !=# ''
    echomsg 'PlanetVim: choose a new filename for the recovered copy'
    return 0
  endif
  execute 'write ' .. fnameescape(l:path)
  return 1
endfunc

func! planet#recovery#Reload(encoding = '') abort
  if empty(expand('%:p')) || !filereadable(expand('%:p'))
    echomsg 'PlanetVim: the buffer has no readable file on disk'
    return 0
  endif
  if !empty(a:encoding) && a:encoding !~# '^[-a-zA-Z0-9_]\+$' | return 0 | endif
  execute 'confirm edit ' .. (empty(a:encoding) ? '' : '++enc=' .. a:encoding)
  return 1
endfunc

func! planet#recovery#Menus() abort
  an 110.185 📁&f.Recovery.Find\ Recoverable\ Files <Cmd>call planet#recovery#Recover()<CR>
  an 110.185 📁&f.Recovery.Recover\ Swap\ File <Cmd>call planet#recovery#Browse()<CR>
  an 110.185 📁&f.Recovery.Compare\ with\ Disk <Cmd>call planet#recovery#Compare()<CR>
  an 110.185 📁&f.Recovery.Save\ Recovered\ Copy <Cmd>call planet#recovery#SaveCopy()<CR>
  an 110.185 📁&f.Recovery.Help <Cmd>help recovery<CR>
  an 110.185 📁&f.Reload\ from\ Disk <Cmd>call planet#recovery#Reload()<CR>
endfunc
