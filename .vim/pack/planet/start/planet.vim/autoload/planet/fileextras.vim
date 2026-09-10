scriptversion 4

func! planet#fileextras#Print(selected = 0, path = '') abort
  if !has('printer') | return planet#prompt#Unavailable('printing in this GVim build', 'printing') | endif
  let l:range = '%'
  if a:selected
    let l:selection = planet#selection#Current()
    let l:range = min([l:selection.start[1], l:selection.end[1]]) .. ',' .. max([l:selection.start[1], l:selection.end[1]])
    execute "normal! \<Esc>"
  endif
  if !empty(a:path) && getftype(a:path) !=# '' | echomsg 'PlanetVim: choose a new PostScript output file' | return 0 | endif
  execute l:range .. 'hardcopy' .. (empty(a:path) ? '' : ' >' .. fnameescape(a:path))
  return 1
endfunc

func! planet#fileextras#PrintSetting(name) abort
  if index(['printoptions', 'printdevice', 'printfont'], a:name) < 0 | throw 'PlanetVim: invalid print setting' | endif
  if !exists('+' .. a:name) | return planet#prompt#Unavailable('printing', 'printing') | endif
  let l:value = planet#prompt#Ask(a:name .. ': ', eval('&' .. a:name))
  return l:value is v:null ? 0 : planet#preferences#Set(a:name, l:value)
endfunc

func! planet#fileextras#Crypt(action) abort
  if !has('cryptv') | return planet#prompt#Unavailable('Vim file encryption', 'encryption') | endif
  if a:action ==# 'set'
    " Native protected input: never put a secret in a menu command or JSON.
    X
    echomsg 'PlanetVim: encryption applies on the next write; the file uses Vim encryption format (:help encryption)'
  elseif a:action ==# 'remove'
    setlocal key=
    echomsg 'PlanetVim: the next write will save plaintext; the file has not been written yet'
  elseif a:action ==# 'status'
    echomsg 'PlanetVim: key ' .. (empty(&l:key) ? 'not set' : 'set') .. ', cryptmethod=' .. &l:cryptmethod
  else
    throw 'PlanetVim: invalid encryption action'
  endif
  return 1
endfunc

func! planet#fileextras#CryptMethod(method) abort
  if a:method ==# 'xchacha20v2' && !has('sodium')
    return planet#prompt#Unavailable('libsodium encryption support in this GVim build', 'encryption')
  endif
  return planet#preferences#Set('cryptmethod', a:method, 1)
endfunc

func! planet#fileextras#RemoteProvider() abort
  if exists('*netrw#NetRead') | return 1 | endif
  " Load only the built-in transfer library. Keep Fern's directory browsing
  " and mappings; netrw's local FileExplorer plugin remains disabled.
  if empty(globpath(&runtimepath, 'autoload/netrw.vim'))
    silent! packadd! netrw
  endif
  if empty(globpath(&runtimepath, 'autoload/netrw.vim'))
    return planet#prompt#Unavailable('the installed Vim netrw runtime', 'netrw')
  endif
  unlet! g:loaded_netrw
  return 1
endfunc

func! planet#fileextras#ReadRemote(url) abort
  if !planet#fileextras#RemoteProvider() | return 0 | endif
  call netrw#NetRead(2, a:url)
  if a:url =~# '^https\?://' | setlocal readonly | endif
  filetype detect
  return 1
endfunc

func! planet#fileextras#WriteRemote(url) abort
  if !planet#fileextras#RemoteProvider() | return 0 | endif
  %call netrw#NetWrite(a:url)
endfunc

func! planet#fileextras#Remote(url = v:null) abort
  let l:url = a:url is v:null ? planet#prompt#Ask('Remote file URL (sftp://host/path, scp://host/path, or HTTPS): ', 'sftp://') : a:url
  if l:url is v:null || empty(l:url) | return 0 | endif
  if l:url !~# '^\%(sftp\|scp\|https\?\)://[^/[:space:]]\+/[^\r\n]*$'
    echomsg 'PlanetVim: enter an sftp://, scp://, http:// or https:// file URL'
    return 0
  endif
  if !planet#fileextras#RemoteProvider() | return 0 | endif
  execute 'confirm edit ' .. fnameescape(l:url)
  return 1
endfunc

func! planet#fileextras#Menus() abort
  PlanetMenu an 110.187 📁&f.Print.File <Cmd>call planet#fileextras#Print()<CR>
  PlanetMenu an 110.187 📁&f.Print.Selected\ Lines V<Cmd>call planet#fileextras#Print(1)<CR>
  PlanetMenu vnoremenu 110.187 📁&f.Print.Selected\ Lines <Cmd>call planet#fileextras#Print(1)<CR>
  PlanetMenu snoremenu 110.187 📁&f.Print.Selected\ Lines <Cmd>call planet#fileextras#Print(1)<CR>
  for l:name in ['printoptions', 'printdevice', 'printfont']
    execute 'PlanetMenu anoremenu 110.187 📁&f.Print.Settings.' .. l:name .. " <Cmd>call planet#fileextras#PrintSetting('" .. l:name .. "')<CR>"
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
endfunc

augroup PlanetVimRemoteFiles
  autocmd!
  autocmd BufReadCmd sftp://*,scp://*,http://*,https://* call planet#fileextras#ReadRemote(expand('<amatch>'))
  autocmd BufWriteCmd sftp://*,scp://* call planet#fileextras#WriteRemote(expand('<amatch>'))
  autocmd BufWriteCmd http://*,https://* echoerr 'HTTP buffers are read-only; write to a local filename instead'
augroup END
