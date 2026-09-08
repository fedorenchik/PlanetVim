scriptversion 4

func! s:Warn(message) abort
  echohl WarningMsg
  echom 'PlanetVim tools: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#systemtools#Run(argv, cwd = getcwd()) abort
  if type(a:argv) != v:t_list || empty(a:argv)
        \ || !empty(filter(copy(a:argv), {_, v -> type(v) != v:t_string}))
    return s:Warn('command arguments must be a nonempty list of strings.')
  endif
  if !executable(a:argv[0])
    return s:Warn('install ' .. a:argv[0] .. ' and put it on PATH.')
  endif
  return planet#term#RunArgv(a:argv, v:false, v:false, v:false, a:cwd)
endfunc

func! s:Input(prompt, default = '') abort
  return inputdialog(a:prompt, a:default, "\x01")
endfunc

func! planet#systemtools#Port(value = v:null) abort
  let l:value = a:value is v:null ? s:Input('Server port (1–65535):', string(get(g:, 'PV_server_port', 8000))) : a:value
  let l:text = type(l:value) == v:t_number ? string(l:value) : l:value
  if l:text ==# "\x01" || empty(l:text)
    return 0
  endif
  if l:text !~# '^\d\+$' || str2nr(l:text) < 1 || str2nr(l:text) > 65535
    return s:Warn('port must be an integer from 1 through 65535.')
  endif
  let g:PV_server_port = str2nr(l:text)
  return g:PV_server_port
endfunc

func! planet#systemtools#Http() abort
  let l:port = planet#systemtools#Port(get(g:, 'PV_server_port', 8000))
  if !l:port
    return 0
  endif
  return planet#systemtools#Run([executable('python3') ? 'python3' : 'python', '-m', 'http.server', string(l:port), '--bind', '127.0.0.1'])
endfunc

func! planet#systemtools#Ngrok() abort
  let l:port = planet#systemtools#Port(get(g:, 'PV_server_port', 8000))
  return l:port ? planet#systemtools#Run(['ngrok', 'http', string(l:port)]) : 0
endfunc

func! s:TokenFinished(job, status) abort
  echom a:status == 0 ? 'PlanetVim: ngrok authentication token saved.' : 'PlanetVim: ngrok token configuration failed (exit ' .. a:status .. ').'
endfunc

func! planet#systemtools#NgrokToken() abort
  if !executable('ngrok')
    return s:Warn('install ngrok and put it on PATH.')
  endif
  let l:token = inputsecret('ngrok authentication token (empty cancels): ')
  if empty(l:token)
    return 0
  endif
  " Credentials never enter output labels, command history, or :messages.
  let l:job = job_start(['ngrok', 'config', 'add-authtoken', l:token],
        \ #{in_io: 'null', out_io: 'null', err_io: 'null', exit_cb: function('s:TokenFinished')})
  return job_status(l:job) !=# 'fail'
endfunc

func! planet#systemtools#Nmap(target = v:null) abort
  let l:target = a:target is v:null ? s:Input('Host or network CIDR to discover:', '127.0.0.1') : a:target
  if empty(l:target) || l:target ==# "\x01"
    return 0
  endif
  if l:target =~# '^-' || l:target =~# '\s'
    return s:Warn('enter one host or network CIDR, without command options.')
  endif
  return planet#systemtools#Run(['nmap', '-sn', l:target])
endfunc

func! planet#systemtools#Serial(port = v:null, baud = v:null) abort
  let l:port = a:port is v:null ? s:Input('Serial port:', has('win32') ? 'COM3' : '/dev/ttyUSB0') : a:port
  if empty(l:port) || l:port ==# "\x01"
    return 0
  endif
  let l:baud = a:baud is v:null ? s:Input('Baud rate:', '115200') : (type(a:baud) == v:t_number ? string(a:baud) : a:baud)
  if l:baud ==# "\x01" || empty(l:baud)
    return 0
  endif
  if l:baud !~# '^\d\+$' || str2nr(l:baud) <= 0 || l:port =~# '^-'
    return s:Warn('provide a serial port and positive integer baud rate.')
  endif
  if has('win32')
    return planet#gittools#Gui(['putty', '-serial', l:port, '-sercfg', l:baud .. ',8,n,1,N'])
  endif
  return planet#systemtools#Run(['picocom', '--baud', l:baud, l:port])
endfunc

func! planet#systemtools#Socat(first = v:null, second = v:null) abort
  let l:first = a:first is v:null ? s:Input('socat first address:', 'STDIO') : a:first
  if empty(l:first) || l:first ==# "\x01"
    return 0
  endif
  let l:second = a:second is v:null ? s:Input('socat second address:', 'TCP:127.0.0.1:8000') : a:second
  if empty(l:second) || l:second ==# "\x01"
    return 0
  endif
  return planet#systemtools#Run(['socat', l:first, l:second])
endfunc

func! planet#systemtools#Websocat(url = v:null) abort
  let l:url = a:url is v:null ? s:Input('WebSocket URL:', 'ws://127.0.0.1:8000') : a:url
  if empty(l:url) || l:url ==# "\x01"
    return 0
  endif
  if l:url !~# '^wss\?://'
    return s:Warn('WebSocket URL must begin with ws:// or wss://.')
  endif
  return planet#systemtools#Run(['websocat', l:url])
endfunc

func! planet#systemtools#DdProgress(pid = v:null) abort
  if has('win32')
    return s:Warn('Windows dd ports have no standard USR1 progress signal; start your dd port with its documented progress option.')
  endif
  let l:pid = a:pid is v:null ? s:Input('PID of a GNU dd process (sends USR1 to print progress):') : (type(a:pid) == v:t_number ? string(a:pid) : a:pid)
  if empty(l:pid) || l:pid ==# "\x01"
    return 0
  endif
  if l:pid !~# '^\d\+$' || str2nr(l:pid) <= 1
    return s:Warn('enter one positive dd process ID greater than 1.')
  endif
  " Avoid signaling an unrelated program if the typed PID is wrong/reused.
  let l:comm = '/proc/' .. l:pid .. '/comm'
  if !filereadable(l:comm) || get(readfile(l:comm), 0, '') !=# 'dd'
    return s:Warn('that PID is not a running dd process.')
  endif
  return planet#systemtools#Run(['/bin/kill', '-USR1', l:pid])
endfunc

func! planet#systemtools#Program(option) abort
  if index(['equalprg', 'formatprg', 'keywordprg', 'makeprg', 'grepprg'], a:option) < 0
    return s:Warn('unknown program option.')
  endif
  let l:value = s:Input('Set ' .. a:option .. ':', eval('&' .. a:option))
  if l:value ==# "\x01"
    return 0
  endif
  execute 'let &l:' .. a:option .. ' = l:value'
  return 1
endfunc
