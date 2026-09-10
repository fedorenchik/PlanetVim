vim9script
export def Print(selected: any = 0, path: any = ''): any
  var selection: any
  if !has('printer')
    return planet#prompt#Unavailable('printing in this GVim build', 'printing')
  endif
  var range: any = '%'
  if selected
    selection = planet#selection#Current()
    range = min([selection.start[1], selection.end[1]]) .. ',' .. max([selection.start[1], selection.end[1]])
    execute "normal! \<Esc>"
  endif
  if !empty(path) && getftype(path) !=# ''
    echomsg 'PlanetVim: choose a new PostScript output file'
    return 0
  endif
  execute ':' .. range .. 'hardcopy' .. (empty(path) ? '' : ' >' .. fnameescape(path))
  return 1
enddef

export def PrintSetting(name: any): any
  if index(['printoptions', 'printdevice', 'printfont'], name) < 0
    throw 'PlanetVim: invalid print setting'
  endif
  if !exists('+' .. name)
    return planet#prompt#Unavailable('printing', 'printing')
  endif
  var value: any = planet#prompt#Ask(name .. ': ', eval('&' .. name))
  return value == null ? 0 : planet#preferences#Set(name, value)
enddef

export def Crypt(action: any): any
  if !has('cryptv')
    return planet#prompt#Unavailable('Vim file encryption', 'encryption')
  endif
  if action ==# 'set'
    # Native protected input: never put a secret in a menu command or JSON.
    execute 'X'
    echomsg 'PlanetVim: encryption applies on the next write; the file uses Vim encryption format (:help encryption)'
  elseif action ==# 'remove'
    setlocal key=
    echomsg 'PlanetVim: the next write will save plaintext; the file has not been written yet'
  elseif action ==# 'status'
    echomsg 'PlanetVim: key ' .. (empty(&l:key) ? 'not set' :  'set') .. ', cryptmethod=' .. &l:cryptmethod
  else
    throw 'PlanetVim: invalid encryption action'
  endif
  return 1
enddef

export def CryptMethod(method: any): any
  if method ==# 'xchacha20v2' && !has('sodium')
    return planet#prompt#Unavailable('libsodium encryption support in this GVim build', 'encryption')
  endif
  return planet#preferences#Set('cryptmethod', method, 1)
enddef

export def RemoteProvider(): any
  if exists('*netrw#NetRead')
    return 1
  endif
  # Load only the built-in transfer library. Keep Fern's directory browsing
  # and mappings; netrw's local FileExplorer plugin remains disabled.
  if empty(globpath(&runtimepath, 'autoload/netrw.vim'))
    silent! packadd! netrw
  endif
  if empty(globpath(&runtimepath, 'autoload/netrw.vim'))
    return planet#prompt#Unavailable('the installed Vim netrw runtime', 'netrw')
  endif
  unlet! g:loaded_netrw
  return 1
enddef

export def ReadRemote(url: any): any
  if !planet#fileextras#RemoteProvider()
    return 0
  endif
  netrw#NetRead(2, url)
  if url =~# '^https\?://'
    setlocal readonly
  endif
  filetype detect
  return 1
enddef

export def WriteRemote(url: any): any
  if !planet#fileextras#RemoteProvider()
    return 0
  endif
  execute ':%call netrw#NetWrite(' .. string(url) .. ')'
  return 0
enddef

export def Remote(arg_url: any = v:null): any
  var url: any = arg_url == null ? planet#prompt#Ask('Remote file URL (sftp://host/path, scp://host/path, or HTTPS): ', 'sftp://') : arg_url
  if url == null || empty(url)
    return 0
  endif
  if url !~# '^\%(sftp\|scp\|https\?\)://[^/[:space:]]\+/[^\r\n]*$'
    echomsg 'PlanetVim: enter an sftp://, scp://, http:// or https:// file URL'
    return 0
  endif
  if !planet#fileextras#RemoteProvider()
    return 0
  endif
  execute 'confirm edit ' .. fnameescape(url)
  return 1
enddef

export def Menus(): any
  PlanetMenu an 110.187 📁&f.Print.File <Cmd>call planet#fileextras#Print()<CR>
  PlanetMenu an 110.187 📁&f.Print.Selected\ Lines V<Cmd>call planet#fileextras#Print(1)<CR>
  PlanetMenu vnoremenu 110.187 📁&f.Print.Selected\ Lines <Cmd>call planet#fileextras#Print(1)<CR>
  PlanetMenu snoremenu 110.187 📁&f.Print.Selected\ Lines <Cmd>call planet#fileextras#Print(1)<CR>
  for name in ['printoptions', 'printdevice', 'printfont']
    execute 'PlanetMenu anoremenu 110.187 📁&f.Print.Settings.' .. name .. " <Cmd>call planet#fileextras#PrintSetting('" .. name .. "')<CR>"
  endfor
  PlanetMenu an 110.187 📁&f.Print.Help <Cmd>help printing<CR>
  PlanetMenu an 110.188 📁&f.Open\ Remote\ File <Cmd>call planet#fileextras#Remote()<CR>
  PlanetMenu an 110.188 📁&f.Remote\ File\ Help <Cmd>help netrw-start<CR>
  PlanetMenu an 110.189 📁&f.Encryption.Set\ Key <Cmd>call planet#fileextras#Crypt('set')<CR>
  PlanetMenu an 110.189 📁&f.Encryption.Remove\ Key <Cmd>call planet#fileextras#Crypt('remove')<CR>
  PlanetMenu an 110.189 📁&f.Encryption.Status <Cmd>call planet#fileextras#Crypt('status')<CR>
  PlanetMenu an 110.189 📁&f.Encryption.Method.Blowfish2 <Cmd>call planet#fileextras#CryptMethod('blowfish2')<CR>
  PlanetMenu an 110.189 📁&f.Encryption.Method.XChaCha20v2\ (sodium) <Cmd>call planet#fileextras#CryptMethod('xchacha20v2')<CR>
  PlanetMenu an 110.189 📁&f.Encryption.Help <Cmd>help encryption<CR>
  return 0
enddef

augroup PlanetVimRemoteFiles
  autocmd!
  autocmd BufReadCmd sftp://*,scp://*,http://*,https://* call planet#fileextras#ReadRemote(expand('<amatch>'))
  autocmd BufWriteCmd sftp://*,scp://* call planet#fileextras#WriteRemote(expand('<amatch>'))
  autocmd BufWriteCmd http://*,https://* echoerr 'HTTP buffers are read-only; write to a local filename instead'
augroup END
