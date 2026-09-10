vim9script
export def List(): any
  var info: any
  var items: any = []
  for path in swapfilelist()
    info = swapinfo(path)
    info.path = fnamemodify(path, ':p')
    info.live = get(info, 'host', '') ==# strpart(hostname(), 0, 39) && isdirectory('/proc/' .. get(info, 'pid', 0))
    add(items, info)
  endfor
  return items
enddef

export def Recover(arg_path: any = v:null): any
  var items: any
  var index: any
  var error: any
  var path: any = arg_path
  if path == null
    items = planet#recovery#List()
    if empty(items)
      echomsg 'PlanetVim: no swap files found in the configured directory option'
      return 0
    endif
    index = planet#prompt#Choose('Choose a swap file to recover into a new tab:', map(copy(items), (_, lambda_item) => get(lambda_item, 'fname', lambda_item.path) .. (lambda_item.live ? ' [LIVE — close its owner first]' : '') .. ' — ' .. lambda_item.path))
    if index < 0
      return 0
    endif
    path = items[index].path
  endif
  if path == null || empty(path)
    return 0
  endif
  var info: any = swapinfo(path)
  if has_key(info, 'error')
    echomsg 'PlanetVim: ' .. info.error
    return 0
  endif
  if get(info, 'host', '') ==# strpart(hostname(), 0, 39) && isdirectory('/proc/' .. get(info, 'pid', 0))
    echomsg 'PlanetVim: this swap file belongs to a running Vim process; close that editor first'
    return 0
  endif
  if get(info, 'host', '') !=# strpart(hostname(), 0, 39)
    if confirm('The swap belongs to host ' .. get(info, 'host', '?') .. '. Its owner cannot be checked here. Recover a separate copy?',
         "&Recover copy\n&Cancel", 2) != 1
      return 0
    endif
  endif
  var origin: any = win_getid()
  tabnew
  setlocal noswapfile
  try
    execute 'silent recover ' .. fnameescape(path)
    b:PV_recovered_swap = path
    b:PV_recovery_original = get(info, 'fname', '')
    setlocal readonly bufhidden=hide
    echomsg 'PlanetVim: recovered into a new tab. Compare with Disk, then Save Recovered Copy. The swap file was retained.'
    return 1
  catch
    error = v:exception
    # Leave any partial recovered text available for inspection.
    if empty(getline(1, '$')) || getline(1, '$') ==# ['']
      bwipeout!
      win_gotoid(origin)
    endif
    echomsg 'PlanetVim recovery: ' .. error
    return 0
  endtry
enddef

export def Browse(): any
  var path: any = planet#prompt#Ask('Swap file to recover: ', '', 'file')
  if path == null || empty(path)
    return 0
  endif
  return planet#recovery#Recover(path)
enddef

export def Compare(): any
  var error: any
  var path: any = get(b:, 'PV_recovery_original', expand('%:p'))
  if !filereadable(path)
    echomsg 'PlanetVim: there is no readable on-disk file to compare'
    return 0
  endif
  var origin: any = win_getid()
  vertical new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  try
    execute 'silent :0read ++edit ' .. fnameescape(path)
    silent :$delete _
    setlocal nomodifiable readonly nomodified
    diffthis
    win_gotoid(origin)
    diffthis
    return 1
  catch
    error = v:exception
    bwipeout!
    win_gotoid(origin)
    echomsg 'PlanetVim compare: ' .. error
    return 0
  endtry
enddef

export def SaveCopy(arg_path: any = v:null): any
  var path: any = arg_path == null ? planet#prompt#Ask('Save a separate copy as: ', expand('%:p') .. '.recovered', 'file') : arg_path
  if path == null || empty(path)
    return 0
  endif
  if getftype(path) !=# ''
    echomsg 'PlanetVim: choose a new filename for the recovered copy'
    return 0
  endif
  execute 'write ' .. fnameescape(path)
  return 1
enddef

export def Reload(encoding: any = ''): any
  if empty(expand('%:p')) || !filereadable(expand('%:p'))
    echomsg 'PlanetVim: the buffer has no readable file on disk'
    return 0
  endif
  if !empty(encoding) && encoding !~# '^[-a-zA-Z0-9_]\+$'
    return 0
  endif
  execute 'confirm edit ' .. (empty(encoding) ? '' : '++enc=' .. encoding)
  return 1
enddef

export def Menus(): any
  PlanetMenu an 110.185 📁&f.Recovery.Find\ Recoverable\ Files <Cmd>call planet#recovery#Recover()<CR>
  PlanetMenu an 110.185 📁&f.Recovery.Recover\ Swap\ File <Cmd>call planet#recovery#Browse()<CR>
  PlanetMenu an 110.185 📁&f.Recovery.Compare\ with\ Disk <Cmd>call planet#recovery#Compare()<CR>
  PlanetMenu an 110.185 📁&f.Recovery.Save\ Recovered\ Copy <Cmd>call planet#recovery#SaveCopy()<CR>
  PlanetMenu an 110.185 📁&f.Recovery.Help <Cmd>help recovery<CR>
  PlanetMenu an 110.185 📁&f.Reload\ from\ Disk <Cmd>call planet#recovery#Reload()<CR>
  return 0
enddef
