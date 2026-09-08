" Source with a clean GVim and the first-party plugin on 'runtimepath'.
let s:base = get(g:, 'PV_test_dir', tempname()) .. '/commands'
call mkdir(s:base, 'p')
let s:cwd = s:base .. '/build space 工作'
call mkdir(s:cwd, 'p')
let s:buffers = []
let s:old_shell = &shell
let s:old_shellcmdflag = &shellcmdflag

func! s:Wait(bufnr) abort
  for l:i in range(200)
    call term_wait(a:bufnr, 50)
    if get(planet#term#Result(a:bufnr), 'status', '') !=# 'running'
      call term_wait(a:bufnr, 20)
      return
    endif
  endfor
  call assert_report('command timed out: ' .. string(planet#term#Result(a:bufnr)))
  call planet#term#Cancel(a:bufnr)
endfunc

func! s:Fixture(name, arguments, status, ...) abort
  let l:script = s:base .. '/' .. a:name .. '.vim'
  let l:result = s:base .. '/' .. a:name .. '.json'
  call writefile([
        \ 'call writefile([json_encode({"argv": argv(), "cwd": getcwd()})], ' .. string(l:result) .. ')',
        \ "echomsg 'planet-command-output'",
        \ a:status < 0 ? 'sleep 10' : 'cquit ' .. a:status,
        \ 'qa!'], l:script)
  let l:argv = [v:progpath, '-Nu', 'NONE', '-U', 'NONE', '-i', 'NONE', '-n',
        \ '-es', '-V1', '-S', l:script, '--'] + a:arguments
  let l:buffer = planet#term#RunArgv(l:argv, v:false,
        \ get(a:000, 0, v:false), get(a:000, 1, v:true), s:cwd)
  call assert_true(l:buffer > 0, 'native command starts')
  call add(s:buffers, l:buffer)
  return [l:buffer, l:result, l:argv]
endfunc

func! s:Completed(result, bufnr) abort
  call assert_equal(a:result, planet#term#Result(a:bufnr))
  call add(s:callbacks, [a:result.status, a:result.exit_code, a:bufnr])
endfunc

func! s:BrokenCallback(result, bufnr) abort
  throw 'intentional callback test failure'
endfunc

try
  " The editor process itself is the portable argv/cwd fixture executable.
  let s:arguments = ['two words', "apostrophe's", 'a"quote', 'semi;colon',
        \ '$literal', '$(literal)', '工作', '-leading-dash', '']
  let [s:buffer, s:json, s:argv] = s:Fixture('literal', s:arguments, 0)
  let s:job = term_getjob(s:buffer)
  let s:success_argv = copy(s:argv)
  call s:Wait(s:buffer)
  call assert_equal(s:argv, job_info(s:job).cmd)
  call assert_equal('success', planet#term#Result(s:buffer).status)
  let s:record = json_decode(readfile(s:json)[0])
  call assert_equal(s:arguments, s:record.argv)
  call assert_equal(fnamemodify(s:cwd, ':p'), fnamemodify(s:record.cwd, ':p'))

  " Failed jobs retain their real status and a terminal transcript even when
  " the caller requested close-on-exit.
  let [s:failed, s:json, s:argv] = s:Fixture('failure', [], 7, v:true, v:false)
  let s:failure_argv = copy(s:argv)
  let s:failed_job = term_getjob(s:failed)
  call s:Wait(s:failed)
  call assert_equal(7, job_info(s:failed_job).exitval)
  call assert_equal(7, planet#term#Result(s:failed).exit_code)
  call assert_equal('failed', planet#term#Result(s:failed).status)
  call assert_equal('terminal', getbufvar(s:failed, '&buftype'))
  call assert_false(empty(win_findbuf(s:failed)), 'failed command window remains open')
  call assert_match('planet-command-output', join(getbufline(s:failed, 1, '$'), "\n"))
  call assert_match('failed (7)', planet#term#Statusline(s:failed))
  call assert_match('build space', planet#term#Statusline(s:failed))

  let s:callbacks = []
  for s:argv in [s:success_argv, s:failure_argv]
    let s:buffer = planet#term#RunArgv(s:argv, v:false, v:false, v:true,
          \ s:cwd, function('s:Completed'))
    call add(s:buffers, s:buffer)
    call s:Wait(s:buffer)
  endfor
  call assert_equal(['success', 'failed'], map(copy(s:callbacks), {_, item -> item[0]}))
  call assert_equal([0, 7], map(copy(s:callbacks), {_, item -> item[1]}))
  let s:buffer = planet#term#RunArgv(s:success_argv, v:false, v:false, v:true,
        \ s:cwd, function('s:BrokenCallback'))
  call add(s:buffers, s:buffer)
  call s:Wait(s:buffer)
  call assert_equal('success', planet#term#Result(s:buffer).status)
  call assert_match('intentional callback', planet#term#Result(s:buffer).callback_error)

  " Missing cwd rejects the operation before it changes windows or starts jobs.
  let s:windows = winnr('$')
  let s:terminals = len(term_list())
  call assert_equal(0, planet#term#RunArgv(s:argv, v:false, v:false,
        \ v:false, s:base .. '/missing'))
  call assert_equal(s:windows, winnr('$'))
  call assert_equal(s:terminals, len(term_list()))
  call assert_equal(0, planet#term#RunArgv([]))
  call assert_equal(0, planet#term#RunArgv(['echo', 1]))

  let s:missing = planet#term#RunArgv(['planetvim-command-that-does-not-exist'],
        \ v:false, v:false, v:true, s:cwd)
  call add(s:buffers, s:missing)
  call s:Wait(s:missing)
  call assert_equal('failed', planet#term#Result(s:missing).status)
  call assert_notequal(0, planet#term#Result(s:missing).exit_code)

  " Shell text is one untouched argument, using the user's shell command flags.
  let s:shell_file = s:base .. '/shell-output.txt'
  if has('win32')
    let &shell = 'cmd.exe'
    let &shellcmdflag = '/d /c'
    let s:script = 'echo two words|findstr words > "' .. s:shell_file .. '" & exit /b 7'
  else
    let &shell = '/bin/sh'
    let &shellcmdflag = '-c'
    let s:script = "printf '%s' 'two words' | cat > " .. shellescape(s:shell_file) .. '; exit 7'
  endif
  let s:shell_buffer = planet#term#RunShell(s:script, v:false, v:false, v:true, s:cwd)
  call add(s:buffers, s:shell_buffer)
  let s:shell_job = term_getjob(s:shell_buffer)
  let s:shell_argv = job_info(s:shell_job).cmd
  if has('win32')
    call assert_equal([&shell] + split(&shellcmdflag) + ['call'], s:shell_argv[:-2])
    call assert_equal(s:script, planet#term#Result(s:shell_buffer).command)
  else
    call assert_equal([&shell] + split(&shellcmdflag) + [s:script], s:shell_argv)
  endif
  call s:Wait(s:shell_buffer)
  if has('win32')
    call assert_false(filereadable(s:shell_argv[-1]), 'temporary shell script is removed')
  endif
  call assert_equal(7, job_info(s:shell_job).exitval)
  call assert_equal(['two words'], map(readfile(s:shell_file), {_, line -> trim(line)}))

  " Unix shell option arguments and quoted paths are parsed independently of
  " the shell script itself.
  if ! has('win32')
    let &shell = '"/bin/sh" -e'
    let s:buffer = planet#term#RunShell('exit 0', v:false, v:false, v:true)
    call add(s:buffers, s:buffer)
    let s:job = term_getjob(s:buffer)
    call s:Wait(s:buffer)
    call assert_equal(['/bin/sh', '-e', '-c', 'exit 0'], job_info(s:job).cmd)
  endif

  let [s:cancelled, s:json, s:argv] = s:Fixture('cancelled', [], -1)
  for s:i in range(100)
    call term_wait(s:cancelled, 20)
    if filereadable(s:json)
      break
    endif
  endfor
  call assert_equal(1, planet#term#Cancel(s:cancelled))
  call s:Wait(s:cancelled)
  call assert_equal('cancelled', planet#term#Result(s:cancelled).status)
  call assert_notequal(v:null, planet#term#Result(s:cancelled).exit_code)
  call assert_equal(0, planet#term#Cancel(s:cancelled))

  " Choosing an output selects the real buffer, including after completion.
  let s:output_name = bufname(s:failed)
  let s:previous_statusline = &l:statusline
  call planet#term#DefineOutputWindowsMenu()
  execute 'emenu ]Outputs.' .. planet#menu#MenuifyName('[' .. s:failed .. '] ' .. s:output_name)
  call assert_equal(s:failed, bufnr('%'))
  call assert_equal('terminal', &buftype)
  call assert_match('planet#term#Statusline', &l:statusline)
  hide enew
  call assert_equal(s:previous_statusline, &l:statusline)
  call assert_true(bufexists(s:failed), 'failed output survives leaving its window')

  let s:tabs = tabpagenr('$')
  let s:tab_buffer = planet#term#RunCmdTab(s:success_argv, s:cwd)
  call add(s:buffers, s:tab_buffer)
  call s:Wait(s:tab_buffer)
  call assert_equal(s:tabs, tabpagenr('$'), 'successful command tab closes')
  let s:tab_buffer = planet#term#RunCmdTab(s:failure_argv, s:cwd)
  call add(s:buffers, s:tab_buffer)
  call s:Wait(s:tab_buffer)
  call assert_equal(s:tabs + 1, tabpagenr('$'), 'failed command tab remains')
  hide tabclose

  " The standalone Unix helper preserves native argv and returns real status.
  if ! has('win32') && executable('bash')
    let s:plugin = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
          \ .. '/.vim/pack/planet/start/planet.vim'
    let s:helper = planet#term#RunArgv(['bash', s:plugin .. '/bin/run-command',
          \ '--cwd', s:cwd, '--', '/bin/sh', '-c', 'exit 7'],
          \ v:false, v:false, v:true)
    call add(s:buffers, s:helper)
    let s:helper_job = term_getjob(s:helper)
    call s:Wait(s:helper)
    call assert_equal(7, job_info(s:helper_job).exitval)
    call assert_match('Exit status: 7', join(getbufline(s:helper, 1, '$'), "\n"))
  endif
finally
  let &shell = s:old_shell
  let &shellcmdflag = s:old_shellcmdflag
  for s:buffer in s:buffers
    if bufexists(s:buffer)
      call planet#term#Cancel(s:buffer)
      execute 'silent! bwipeout! ' .. s:buffer
    endif
  endfor
endtry
