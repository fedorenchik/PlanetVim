vim9script
var script_servers: any

export def VimServerStart(): any
  if !exists('*remote_startserver')
    echom 'PlanetVim: install GVim with +clientserver to start a Vim server.'
    return 0
  endif
  if empty(v:servername)
    remote_startserver('VIM')
    echo 'Started as ' .. v:servername
  else
    echo 'Already started as ' .. v:servername
  endif
  return 1
enddef

export def Command(): any
  return [v:progpath, '-g', '-u', planet#paths#Root() .. '/scripts/planetvim.vim']
enddef

export def OpenUrl(url: any): any
  var argv: any = has('win32') ? ['rundll32.exe', 'url.dll,FileProtocolHandler', url] : ['xdg-open', url]
  if !executable(argv[0])
    echom 'PlanetVim: install ' .. argv[0] .. ' or open this address in your browser: ' .. url
    return 0
  endif
  return planet#term#RunGuiApp(argv)
enddef

export def TransferSnapshot(): any
  if !empty(&buftype)
    throw 'PlanetVim: only ordinary editing buffers can be copied to another GUI window'
  endif
  return {'path': expand('%:p'), 'lines': getline(1, '$'), 'view': winsaveview(), 'filetype': &filetype,
       'fileformat': &fileformat, 'fileencoding': &fileencoding, 'endofline': &endofline, 'binary': &binary,
       'modified': &modified, 'cwd': getcwd()}
enddef

export def RestoreTransfer(path: any): any
  var data: any
  try
    data = json_decode(join(readfile(path), "\n"))
    if empty(data.path)
      enew
    else
      execute 'noswapfile edit ' .. fnameescape(data.path)
    endif
    setline(1, data.lines)
    if line('$') > len(data.lines)
      deletebufline(bufnr(), len(data.lines) + 1, '$')
    endif
    &l:filetype = data.filetype
    &l:binary = data.binary
    &l:fileformat = data.fileformat
    &l:fileencoding = data.fileencoding
    &l:endofline = data.endofline
    &l:modified = data.modified
    setlocal noswapfile
    execute 'lcd ' .. fnameescape(data.cwd)
    winrestview(data.view)
    writefile(['ready'], path .. '.ready')
    return 1
  catch
    writefile([v:exception], path .. '.error')
    return 0
  endtry
enddef

export def Transfer(move: any = v:false): any
  var data: any = planet#gui#TransferSnapshot()
  var directory: any = planet#paths#Cache('transfers/' .. sha256(tempname())[ : 19])
  var path: any = directory .. '/buffer.json'
  writefile([json_encode(data)], path)
  var context: any = {'path': path, 'directory': directory, 'buffer': bufnr(), 'window': win_getid(),
       'tick': b:changedtick, 'move': move, 'attempts': 0, 'status': 'running'}
  var argv: any = planet#gui#Command() + ['-f', '-n', '--cmd', 'let g:startify_disable_at_vimenter = 1',
       '-c', 'call planet#gui#RestoreTransfer(' .. string(path) .. ')']
  context.job = planet#term#RunGuiApp(argv, data.cwd)
  if type(context.job) != v:t_job || job_status(context.job) ==# 'fail'
    delete(directory, 'rf')
    echom 'PlanetVim: could not start the new GVim window; the source is unchanged.'
    return 0
  endif
  timer_start(100, function(LocalTransferReady, [context]), {'repeat': -1})
  return context
enddef

def LocalTransferReady(context: any, timer: any): any
  context.attempts += 1
  if filereadable(context.path .. '.ready')
    timer_stop(timer)
    context.status = 'success'
    if context.move && win_id2tabwin(context.window) !=# [0, 0] && winbufnr(context.window) == context.buffer && getbufvar(context.buffer,
         'changedtick') == context.tick
      # Keep the source buffer hidden as recovery; close only its original view.
      win_execute(context.window, "if winnr('$') > 1 | hide close | else | hide enew | endif")
    endif
    delete(context.directory, 'rf')
  elseif filereadable(context.path .. '.error') || job_status(context.job) !=# 'run'
    timer_stop(timer)
    context.status = 'failed'
    context.error = filereadable(context.path .. '.error') ? join(readfile(context.path .. '.error'), ' ') :  'GVim exited before restoring the snapshot'
    echom 'PlanetVim: the new window could not restore the buffer; the source is unchanged.'
    delete(context.directory, 'rf')
  elseif context.attempts >= 300
    timer_stop(timer)
    context.status = 'timed out'
    # A slow child may still load the snapshot; preserve it for recovery.
    echom 'PlanetVim: waiting for the new window timed out; the source is unchanged. Snapshot: ' .. context.path
  endif
  return 0
enddef

export def MenuListVimServers(): any
  if !planet#menu#Visible('nav')
    return 0
  endif
  silent! aunmenu 🗄️&x.&Vim\ Servers
  if !exists('*serverlist')
    return 0
  endif
  script_servers = split(serverlist(), "\n")
  for index in range(len(script_servers))
    execute 'PlanetMenu an 850.200 🗄️&x.&Vim\ Servers.' .. planet#menu#MenuifyName(script_servers[index]) .. ' <Cmd>call planet#gui#ActivateServer(' .. index .. ')<CR>'
  endfor
  return 0
enddef

export def ActivateServer(index: any): any
  if index >= 0 && index < len(script_servers)
    remote_foreground(script_servers[index])
  endif
  return 0
enddef

export def Window(action: any): any
  var flags: any
  if index(['maximize', 'fullscreen'], action) < 0
    throw 'PlanetVim: unsupported GUI window action'
  endif
  if action ==# 'fullscreen' && planet#appearance#NativeFullscreen()
    if &guioptions =~# 's'
      set guioptions-=s
    else
      set guioptions+=s
    endif
    return 1
  endif
  if has('win32')
    if !executable('powershell.exe')
      echom 'PlanetVim: Windows PowerShell is required for the GUI window controls.'
      return 0
    endif
    planet#term#RunGuiApp(['powershell.exe', '-NoProfile', '-NonInteractive', '-File',  planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/gui-window.ps1',  string(v:windowid), action])
    return 0
  endif
  if !has('win32') && executable('wmctrl')
    flags = action ==# 'maximize' ? 'maximized_vert,maximized_horz' : 'fullscreen'
    planet#term#RunGuiApp(['wmctrl', '-ir', string(v:windowid), '-b', 'toggle,' .. flags])
  else
    echomsg 'PlanetVim: use your window manager controls; wmctrl is required on X11.'
  endif
  return 0
enddef
