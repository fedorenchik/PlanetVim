vim9script
def LocalWarn(message: any): any
  echohl WarningMsg
  echom 'PlanetVim tools: ' .. message
  echohl None
  return 0
enddef

export def Run(argv: any, cwd: any = getcwd()): any
  if type(argv) != v:t_list || empty(argv) || !empty(filter(copy(argv), (_, lambda_v) => type(lambda_v) != v:t_string))
    return LocalWarn('command arguments must be a nonempty list of strings.')
  endif
  if !executable(argv[0])
    return LocalWarn('install ' .. argv[0] .. ' and put it on PATH.')
  endif
  return planet#term#RunArgv(argv, v:false, v:false, v:false, cwd)
enddef

def LocalInput(prompt: any, default: any = ''): any
  return inputdialog(prompt, default, "\x01")
enddef

export def Port(arg_value: any = v:null): any
  var value: any = arg_value == null ? LocalInput('Server port (1–65535):', string(get(g:, 'PV_server_port', 8000))) : arg_value
  var text: any = type(value) == v:t_number ? string(value) : value
  if text ==# "\x01" || empty(text)
    return 0
  endif
  if text !~# '^\d\+$' || str2nr(text) < 1 || str2nr(text) > 65535
    return LocalWarn('port must be an integer from 1 through 65535.')
  endif
  g:PV_server_port = str2nr(text)
  return g:PV_server_port
enddef

export def Http(): any
  var port: any = planet#systemtools#Port(get(g:, 'PV_server_port', 8000))
  if !port
    return 0
  endif
  return planet#systemtools#Run([executable('python3') ? 'python3' : 'python', '-m', 'http.server', string(port), '--bind', '127.0.0.1'])
enddef

export def Ngrok(): any
  var port: any = planet#systemtools#Port(get(g:, 'PV_server_port', 8000))
  return port != 0 ? planet#systemtools#Run(['ngrok', 'http', string(port)]) : 0
enddef

def LocalTokenFinished(job: any, status: any): any
  echom status == 0 ? 'PlanetVim: ngrok authentication token saved.' :  'PlanetVim: ngrok token configuration failed (exit ' .. status .. ').'
  return 0
enddef

export def NgrokToken(): any
  if !executable('ngrok')
    return LocalWarn('install ngrok and put it on PATH.')
  endif
  var token: any = inputsecret('ngrok authentication token (empty cancels): ')
  if empty(token)
    return 0
  endif
  # Credentials never enter output labels, command history, or :messages.
  var job: any = job_start(['ngrok', 'config', 'add-authtoken', token], {in_io: 'null', out_io: 'null', err_io: 'null', exit_cb: function(LocalTokenFinished)})
  return job_status(job) !=# 'fail'
enddef

export def Nmap(arg_target: any = v:null): any
  var target: any = arg_target == null ? LocalInput('Host or network CIDR to discover:', '127.0.0.1') : arg_target
  if empty(target) || target ==# "\x01"
    return 0
  endif
  if target =~# '^-' || target =~# '\s'
    return LocalWarn('enter one host or network CIDR, without command options.')
  endif
  return planet#systemtools#Run(['nmap', '-sn', target])
enddef

export def Serial(arg_port: any = v:null, arg_baud: any = v:null): any
  var port: any = arg_port == null ? LocalInput('Serial port:', has('win32') ? 'COM3' : '/dev/ttyUSB0') : arg_port
  if empty(port) || port ==# "\x01"
    return 0
  endif
  var baud: any = arg_baud == null ? LocalInput('Baud rate:', '115200') : (type(arg_baud) == v:t_number ? string(arg_baud) : arg_baud)
  if baud ==# "\x01" || empty(baud)
    return 0
  endif
  if baud !~# '^\d\+$' || str2nr(baud) <= 0 || port =~# '^-'
    return LocalWarn('provide a serial port and positive integer baud rate.')
  endif
  if has('win32')
    return planet#gittools#Gui(['putty', '-serial', port, '-sercfg', baud .. ',8,n,1,N'])
  endif
  return planet#systemtools#Run(['picocom', '--baud', baud, port])
enddef

export def Socat(arg_first: any = v:null, arg_second: any = v:null): any
  var first: any = arg_first == null ? LocalInput('socat first address:', 'STDIO') : arg_first
  if empty(first) || first ==# "\x01"
    return 0
  endif
  var second: any = arg_second == null ? LocalInput('socat second address:', 'TCP:127.0.0.1:8000') : arg_second
  if empty(second) || second ==# "\x01"
    return 0
  endif
  return planet#systemtools#Run(['socat', first, second])
enddef

export def Websocat(arg_url: any = v:null): any
  var url: any = arg_url == null ? LocalInput('WebSocket URL:', 'ws://127.0.0.1:8000') : arg_url
  if empty(url) || url ==# "\x01"
    return 0
  endif
  if url !~# '^wss\?://'
    return LocalWarn('WebSocket URL must begin with ws:// or wss://.')
  endif
  return planet#systemtools#Run(['websocat', url])
enddef

export def DdProgress(arg_pid: any = v:null): any
  if has('win32')
    return LocalWarn('Windows dd ports have no standard USR1 progress signal; start your dd port with its documented progress option.')
  endif
  var pid: any = arg_pid == null ? LocalInput('PID of a GNU dd process (sends USR1 to print progress):') : (type(arg_pid) == v:t_number ? string(arg_pid) : arg_pid)
  if empty(pid) || pid ==# "\x01"
    return 0
  endif
  if pid !~# '^\d\+$' || str2nr(pid) <= 1
    return LocalWarn('enter one positive dd process ID greater than 1.')
  endif
  # Avoid signaling an unrelated program if the typed PID is wrong/reused.
  var comm: any = '/proc/' .. pid .. '/comm'
  if !filereadable(comm) || get(readfile(comm), 0, '') !=# 'dd'
    return LocalWarn('that PID is not a running dd process.')
  endif
  return planet#systemtools#Run(['/bin/kill', '-USR1', pid])
enddef

export def Program(option: any): any
  if index(['equalprg', 'formatprg', 'keywordprg', 'makeprg', 'grepprg'], option) < 0
    return LocalWarn('unknown program option.')
  endif
  var value: any = LocalInput('Set ' .. option .. ':', eval('&' .. option))
  if value ==# "\x01"
    return 0
  endif
  execute '&l:' .. option .. ' = ' .. string(value)
  return 1
enddef
