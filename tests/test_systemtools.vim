let s:root = g:PV_test_dir .. '/system tools'
call mkdir(s:root, 'p')
execute 'tcd ' .. fnameescape(s:root)
let s:python = executable('python3') ? 'python3' : 'python'
call assert_equal(0, planet#systemtools#Run(['planetvim_missing_system_tool']))
call assert_equal(0, planet#systemtools#Port('9000; invalid'))
call assert_equal(0, planet#systemtools#Port(65536))
call assert_equal(9000, planet#systemtools#Port(9000))
call assert_equal(0, planet#systemtools#Nmap(''))
call assert_equal(0, planet#systemtools#Nmap('--script=unsafe'))
call assert_equal(0, planet#systemtools#Serial('', 115200))
call assert_equal(0, planet#systemtools#Serial('/dev/ttyUSB0', -1))
call assert_equal(0, planet#systemtools#Socat('', ''))
call assert_equal(0, planet#systemtools#Websocat(''))
call assert_equal(0, planet#systemtools#Websocat('http://127.0.0.1'))
call assert_equal(0, planet#systemtools#DdProgress(1))
let s:input = s:root .. '/stdin 工作.txt'
let s:output = s:root .. '/stdout 工作.txt'
call writefile(['exact $input; "quoted"', 'second line'], s:input)
let s:buffer = planet#term#RunInput([s:python, '-c', 'import pathlib,sys; pathlib.Path(sys.argv[1]).write_bytes(sys.stdin.buffer.read()); sys.exit(9)', s:output], s:input, s:root)
try
  call assert_true(s:buffer > 0)
  for s:i in range(500)
    call term_wait(s:buffer, 10)
    sleep 10m
    if planet#term#Result(s:buffer).status !=# 'running'
      break
    endif
  endfor
  call assert_equal(9, planet#term#Result(s:buffer).exit_code)
  call assert_equal(readblob(s:input), readblob(s:output))
  call assert_equal(0, planet#term#RunInput([s:python], s:root .. '/missing'))
finally
  if bufexists(s:buffer)
    call planet#term#Cancel(s:buffer)
    execute 'bwipeout! ' .. s:buffer
  endif
endtry

" External-tool argv fixtures never contact networks or serial hardware.
if !has('win32')
  let s:bin = s:root .. '/bin'
  call mkdir(s:bin, 'p')
  let s:real_python = exepath(s:python)
  let s:old_path = $PATH
  let s:old_capture = getenv('PLANETVIM_TOOL_CAPTURE')
  let $PLANETVIM_TOOL_CAPTURE = s:root .. '/tool arguments.json'
  for s:tool in ['nmap', 'picocom', 'socat', 'websocat', 'ngrok', 'python3']
    call writefile(['#!' .. s:real_python, 'import json, os, sys',
          \ 'with open(os.environ["PLANETVIM_TOOL_CAPTURE"], "w") as output:',
          \ '    json.dump(sys.argv[1:], output)'], s:bin .. '/' .. s:tool)
    call setfperm(s:bin .. '/' .. s:tool, 'rwx------')
  endfor
  let $PATH = s:bin .. ':' .. s:old_path
  try
    for s:case in [
          \ [function('planet#systemtools#Nmap'), ['127.0.0.1'], ['-sn', '127.0.0.1']],
          \ [function('planet#systemtools#Serial'), ['/tmp/serial device;literal', 115200], ['--baud', '115200', '/tmp/serial device;literal']],
          \ [function('planet#systemtools#Socat'), ['STDIO', 'TCP:127.0.0.1:4321'], ['STDIO', 'TCP:127.0.0.1:4321']],
          \ [function('planet#systemtools#Websocat'), ['ws://127.0.0.1/a;literal'], ['ws://127.0.0.1/a;literal']],
          \ [function('planet#systemtools#Http'), [], ['-m', 'http.server', '9000', '--bind', '127.0.0.1']],
          \ [function('planet#systemtools#Ngrok'), [], ['http', '9000']]]
      let s:buffer = call(s:case[0], s:case[1])
      call assert_true(s:buffer > 0)
      for s:i in range(300)
        call term_wait(s:buffer, 10)
        sleep 10m
        if planet#term#Result(s:buffer).status !=# 'running'
          break
        endif
      endfor
      call assert_equal('success', planet#term#Result(s:buffer).status)
      call assert_equal(s:case[2], json_decode(join(readfile($PLANETVIM_TOOL_CAPTURE), "\n")))
      execute 'bwipeout! ' .. s:buffer
    endfor
  finally
    let $PATH = s:old_path
    call setenv('PLANETVIM_TOOL_CAPTURE', s:old_capture)
  endtry
endif
