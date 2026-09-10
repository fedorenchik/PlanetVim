scriptversion 4

func! planet#gui#VimServerStart() abort
  if !exists('*remote_startserver')
    echom 'PlanetVim: install GVim with +clientserver to start a Vim server.'
    return 0
  endif
  if empty(v:servername)
    call remote_startserver('VIM')
    echo 'Started as ' .. v:servername
  else
    echo 'Already started as ' .. v:servername
  end
  return 1
endfunc

func! planet#gui#Command() abort
  return [v:progpath, '-g', '-u', planet#paths#Root() .. '/scripts/planetvim.vim']
endfunc

func! planet#gui#OpenUrl(url) abort
  let l:argv = has('win32') ? ['rundll32.exe', 'url.dll,FileProtocolHandler', a:url] : ['xdg-open', a:url]
  if !executable(l:argv[0])
    echom 'PlanetVim: install ' .. l:argv[0] .. ' or open this address in your browser: ' .. a:url
    return 0
  endif
  return planet#term#RunGuiApp(l:argv)
endfunc

func! planet#gui#TransferSnapshot() abort
  if !empty(&buftype)
    throw 'PlanetVim: only ordinary editing buffers can be copied to another GUI window'
  endif
  return {'path': expand('%:p'), 'lines': getline(1, '$'), 'view': winsaveview(),
        \ 'filetype': &filetype, 'fileformat': &fileformat, 'fileencoding': &fileencoding,
        \ 'endofline': &endofline, 'binary': &binary, 'modified': &modified, 'cwd': getcwd()}
endfunc

func! planet#gui#RestoreTransfer(path) abort
  try
    let l:data = json_decode(join(readfile(a:path), "\n"))
    if empty(l:data.path)
      enew
    else
      execute 'noswapfile edit ' .. fnameescape(l:data.path)
    endif
    call setline(1, l:data.lines)
    if line('$') > len(l:data.lines)
      call deletebufline(bufnr(), len(l:data.lines) + 1, '$')
    endif
    let &l:filetype = l:data.filetype
    let &l:binary = l:data.binary
    let &l:fileformat = l:data.fileformat
    let &l:fileencoding = l:data.fileencoding
    let &l:endofline = l:data.endofline
    let &l:modified = l:data.modified
    setlocal noswapfile
    execute 'lcd ' .. fnameescape(l:data.cwd)
    call winrestview(l:data.view)
    call writefile(['ready'], a:path .. '.ready')
    return 1
  catch
    call writefile([v:exception], a:path .. '.error')
    return 0
  endtry
endfunc

func! planet#gui#Transfer(move = v:false) abort
  let l:data = planet#gui#TransferSnapshot()
  let l:directory = planet#paths#Cache('transfers/' .. sha256(tempname())[:19])
  let l:path = l:directory .. '/buffer.json'
  call writefile([json_encode(l:data)], l:path)
  let l:context = {'path': l:path, 'directory': l:directory, 'buffer': bufnr(),
        \ 'window': win_getid(), 'tick': b:changedtick, 'move': a:move, 'attempts': 0, 'status': 'running'}
  let l:argv = planet#gui#Command() + ['-f', '-n', '--cmd', 'let g:startify_disable_at_vimenter = 1',
        \ '-c', 'call planet#gui#RestoreTransfer(' .. string(l:path) .. ')']
  let l:context.job = planet#term#RunGuiApp(l:argv, l:data.cwd)
  if type(l:context.job) != v:t_job || job_status(l:context.job) ==# 'fail'
    call delete(l:directory, 'rf')
    echom 'PlanetVim: could not start the new GVim window; the source is unchanged.'
    return 0
  endif
  call timer_start(100, function('s:TransferReady', [l:context]), {'repeat': -1})
  return l:context
endfunc

func! s:TransferReady(context, timer) abort
  let a:context.attempts += 1
  if filereadable(a:context.path .. '.ready')
    call timer_stop(a:timer)
    let a:context.status = 'success'
    if a:context.move && win_id2tabwin(a:context.window) !=# [0, 0]
          \ && winbufnr(a:context.window) == a:context.buffer
          \ && getbufvar(a:context.buffer, 'changedtick') == a:context.tick
      " Keep the source buffer hidden as recovery; close only its original view.
      call win_execute(a:context.window, "if winnr('$') > 1 | hide close | else | hide enew | endif")
    endif
    call delete(a:context.directory, 'rf')
  elseif filereadable(a:context.path .. '.error') || job_status(a:context.job) !=# 'run'
    call timer_stop(a:timer)
    let a:context.status = 'failed'
    let a:context.error = filereadable(a:context.path .. '.error') ? join(readfile(a:context.path .. '.error'), ' ') : 'GVim exited before restoring the snapshot'
    echom 'PlanetVim: the new window could not restore the buffer; the source is unchanged.'
    call delete(a:context.directory, 'rf')
  elseif a:context.attempts >= 300
    call timer_stop(a:timer)
    let a:context.status = 'timed out'
    " A slow child may still load the snapshot; preserve it for recovery.
    echom 'PlanetVim: waiting for the new window timed out; the source is unchanged. Snapshot: ' .. a:context.path
  endif
endfunc

func! planet#gui#MenuListVimServers() abort
  if !planet#menu#Visible('nav') | return | endif
  silent! aunmenu 🗄️&x.&Vim\ Servers
  if !exists('*serverlist')
    return
  endif
  let s:servers = split(serverlist(), "\n")
  for l:index in range(len(s:servers))
    execute 'PlanetMenu an 850.200 🗄️&x.&Vim\ Servers.' .. planet#menu#MenuifyName(s:servers[l:index])
          \ .. ' <Cmd>call planet#gui#ActivateServer(' .. l:index .. ')<CR>'
  endfor
endfunc

func! planet#gui#ActivateServer(index) abort
  if a:index >= 0 && a:index < len(s:servers)
    call remote_foreground(s:servers[a:index])
  endif
endfunc

func! planet#gui#Window(action) abort
  if index(['maximize', 'fullscreen'], a:action) < 0
    throw 'PlanetVim: unsupported GUI window action'
  endif
  if a:action ==# 'fullscreen' && planet#appearance#NativeFullscreen()
    if &guioptions =~# 's' | set guioptions-=s | else | set guioptions+=s | endif
    return 1
  endif
  if has('win32')
    if !executable('powershell.exe')
      echom 'PlanetVim: Windows PowerShell is required for the GUI window controls.'
      return 0
    endif
    call planet#term#RunGuiApp(['powershell.exe', '-NoProfile', '-NonInteractive', '-File',
          \ planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/gui-window.ps1',
          \ string(v:windowid), a:action])
    return
  endif
  if !has('win32') && executable('wmctrl')
    let l:flags = a:action ==# 'maximize' ? 'maximized_vert,maximized_horz' : 'fullscreen'
    call planet#term#RunGuiApp(['wmctrl', '-ir', string(v:windowid), '-b', 'toggle,' .. l:flags])
  else
    echomsg 'PlanetVim: use your window manager controls; wmctrl is required on X11.'
  endif
endfunc
