scriptversion 4

let s:bin_dir = expand('<sfile>:p:h:h:h')->resolve() .. '/bin/'

func! s:WindowsArgument(argument) abort
  " Quote for CommandLineToArgvW/the C runtime, including a zero-length arg.
  let l:quoted = '"'
  let l:slashes = 0
  for l:char in split(a:argument, '\zs')
    if l:char ==# '\'
      let l:slashes += 1
    elseif l:char ==# '"'
      let l:quoted ..= repeat('\', 2 * l:slashes + 1) .. '"'
      let l:slashes = 0
    else
      let l:quoted ..= repeat('\', l:slashes) .. l:char
      let l:slashes = 0
    endif
  endfor
  return l:quoted .. repeat('\', 2 * l:slashes) .. '"'
endfunc

func! s:NativeCommand(argv) abort
  if !has('win32') || index(a:argv, '') < 0
    return a:argv
  endif
  " Vim's win32_escape_arg() drops empty List items. A String here is the
  " native CreateProcess command line, with no shell involved. Serialize only
  " this affected case ourselves and retain the original argv in the result.
  return join(map(copy(a:argv), {_, arg -> s:WindowsArgument(arg)}), ' ')
endfunc

" A List is native argv; a String is an intentional script for the configured
" shell. Never split/rejoin a script: doing so loses quotes and argument bounds.
func! s:ShellCommand(script) abort
  let l:words = []
  let l:word = ''
  let l:quote = ''
  let l:escape = v:false
  for l:char in split(&shell, '\zs')
    if l:escape
      let l:word ..= l:char
      let l:escape = v:false
    elseif l:char == '\' && ! has('win32') && l:quote != "'"
      let l:escape = v:true
    elseif ! empty(l:quote)
      if l:char == l:quote
        let l:quote = ''
      else
        let l:word ..= l:char
      endif
    elseif l:char == '"' || l:char == "'"
      let l:quote = l:char
    elseif l:char =~# '\s'
      if ! empty(l:word)
        call add(l:words, l:word)
        let l:word = ''
      endif
    else
      let l:word ..= l:char
    endif
  endfor
  if l:escape || ! empty(l:quote)
    throw 'PlanetVim: unmatched quote or escape in shell option'
  endif
  if ! empty(l:word)
    call add(l:words, l:word)
  endif
  if empty(l:words) || empty(&shellcmdflag)
    throw 'PlanetVim: shell and shellcmdflag must be configured'
  endif
  let l:command = #{argv: l:words + split(&shellcmdflag), script_file: ''}
  if has('win32') && fnamemodify(l:words[0], ':t') =~? '^cmd\%(\.exe\)\?$'
    " Vim quotes List arguments for the Windows C runtime. cmd.exe does not
    " understand those backslash-escaped quotes, so pass quoted shell text in
    " a batch file instead. `call` keeps /c from stripping the path's quotes.
    let l:command.script_file = tempname() .. '.cmd'
    call writefile(split(a:script, "\n", 1), l:command.script_file)
    let l:command.argv += ['call', l:command.script_file]
  else
    let l:command.argv += [a:script]
  endif
  return l:command
endfunc

func! s:DeleteScript(command, ...) abort
  if ! empty(a:command.script_file)
    call delete(a:command.script_file)
  endif
endfunc

func! s:Label(cmd) abort
  let l:text = type(a:cmd) == v:t_list ? string(a:cmd) : a:cmd
  return substitute(l:text, '[\r\n]', ' ', 'g')
endfunc

func! s:Error(message) abort
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. a:message
  echohl None
  return 0
endfunc

" A snapshot suitable for dependent actions. Only status == 'success' permits
" a success-only next step; exit_code stays v:null until the child exits.
func! planet#term#Result(bufnr) abort
  return deepcopy(getbufvar(a:bufnr, 'planet_result', {}))
endfunc

func! planet#term#Statusline(bufnr) abort
  let l:result = planet#term#Result(a:bufnr)
  if empty(l:result)
    return ''
  endif
  let l:status = l:result.status
  if l:result.exit_code isnot v:null
    let l:status ..= ' (' .. l:result.exit_code .. ')'
  endif
  return '[' .. l:status .. '] ' .. l:result.command .. ' | ' .. l:result.cwd
endfunc

func! planet#term#Info(bufnr = bufnr('%')) abort
  let l:result = planet#term#Result(a:bufnr)
  if empty(l:result)
    return s:Error('this buffer has no PlanetVim command result')
  endif
  echomsg 'Output ' .. a:bufnr .. ': ' .. planet#term#Statusline(a:bufnr)
  return l:result
endfunc

func! s:UseStatusline() abort
  if ! exists('w:planet_previous_statusline')
    let w:planet_previous_statusline = &l:statusline
  endif
  let &l:statusline = '%{planet#term#Statusline(bufnr())}'
endfunc

func! s:RestoreStatusline() abort
  if exists('w:planet_previous_statusline')
    let &l:statusline = w:planet_previous_statusline
    unlet w:planet_previous_statusline
  endif
endfunc

augroup PlanetVimOutputStatusline
  autocmd!
  autocmd BufWinEnter * if exists('b:planet_result') | call s:UseStatusline() | endif
  autocmd BufWinLeave * if exists('b:planet_result') | call s:RestoreStatusline() | endif
augroup END

" Close successful interactive commands only after the terminal has drained.
" Failed/cancelled commands keep their terminal output and colours for review.
func! s:Finish(context, timer) abort
  let l:bufnr = a:context.buffer
  if ! bufexists(l:bufnr)
    return
  endif
  if term_getstatus(l:bufnr) !~# 'finished'
    call timer_start(20, function('s:Finish', [a:context]))
    return
  endif
  if a:context.close_on_exit && a:context.result.status ==# 'success'
    for l:winid in win_findbuf(l:bufnr)
      try
        call win_execute(l:winid, 'hide close')
      catch /^Vim\%((\a\+)\)\=:E444/
        " A command in the last editor window must leave that window open.
      endtry
    endfor
  endif
endfunc

func! s:Exited(context, job, status) abort
  if a:context.buffer == 0
    call timer_start(0, {timer -> s:Exited(a:context, a:job, a:status)})
    return
  endif
  let l:result = a:context.result
  if l:result.exit_code isnot v:null
    return
  endif
  let l:result.exit_code = a:status
  let l:result.signal = get(job_info(a:job), 'termsig', '')
  let l:result.status = a:context.cancel_requested ? 'cancelled'
        \ : a:status == 0 && empty(l:result.signal) ? 'success' : 'failed'
  if bufexists(a:context.buffer)
    call setbufvar(a:context.buffer, 'planet_result', l:result)
  endif
  echomsg 'Output ' .. a:context.buffer .. ': ' .. l:result.status
        \ .. ', exit status ' .. a:status .. ', cwd=' .. l:result.cwd
        \ .. ', command=' .. l:result.command
  if a:context.close_on_exit && l:result.status ==# 'success'
    call timer_start(0, function('s:Finish', [a:context]))
  endif
  call s:DeleteScript(a:context)
  if type(a:context.on_exit) == v:t_func
    try
      call call(a:context.on_exit, [deepcopy(l:result), a:context.buffer])
    catch
      let l:result.callback_error = v:exception
      call s:Error('command completion callback failed: ' .. v:exception)
    endtry
  endif
  redrawstatus
endfunc

func! planet#term#Cancel(bufnr = bufnr('%')) abort
  let l:context = getbufvar(a:bufnr, 'planet_command', {})
  if empty(l:context) || job_status(l:context.job) !=# 'run'
    return 0
  endif
  let l:context.cancel_requested = v:true
  if ! job_stop(l:context.job, 'term')
    let l:context.cancel_requested = v:false
    return 0
  endif
  return 1
endfunc

" Run native argv or a shell script in an existing idle/new [Output] window.
" @cmd[in] List of literal arguments, or String containing shell syntax
" @this_window[in] if true, run in current window unconditionally
" @close_on_exit[in] if true, close current window after successful completion
" @start_hidden[in] if true, do not open new window
" @cd if not empty, change command's CWD to this dir
" @on_exit optional Funcref(result, bufnr); result.status must be checked before
"          starting success-only followups. Callback errors do not change the
"          original process status.
func! planet#term#RunCmd(cmd, this_window = v:false, close_on_exit = v:false, start_hidden = v:false, cd = '', on_exit = v:null, input_file = '') abort
  if index([v:t_string, v:t_list], type(a:cmd)) < 0 || empty(a:cmd)
    return s:Error('command must be a nonempty String or argv List')
  endif
  if type(a:cmd) == v:t_list && (empty(a:cmd[0])
        \ || ! empty(filter(copy(a:cmd), {_, value -> type(value) != v:t_string})))
    return s:Error('argv must contain Strings and a nonempty executable')
  endif
  if a:on_exit isnot v:null && type(a:on_exit) != v:t_func
    return s:Error('on_exit must be a Funcref or v:null')
  endif
  let l:cwd = empty(a:cd) ? getcwd() : fnamemodify(a:cd, ':p')
  if ! isdirectory(l:cwd)
    return s:Error('working directory does not exist: ' .. l:cwd)
  endif
  if !empty(a:input_file) && !filereadable(a:input_file)
    return s:Error('input file is not readable: ' .. a:input_file)
  endif
  try
    let l:command = type(a:cmd) == v:t_list
          \ ? #{argv: copy(a:cmd), script_file: ''} : s:ShellCommand(a:cmd)
  catch
    return s:Error(v:exception)
  endtry
  let l:origin = win_getid()
  if ! a:this_window && ! a:start_hidden
    let l:winnr = planet#term#FindOutputWindow(v:true)
    if l:winnr == -1
      botright 10new
      set winfixheight winfixwidth
    else
      exe l:winnr .. 'wincmd w'
    endif
  endif
  let l:context = #{buffer: 0, cancel_requested: v:false,
        \ close_on_exit: a:close_on_exit,
        \ script_file: l:command.script_file,
        \ on_exit: a:on_exit,
        \ result: #{status: 'running', exit_code: v:null, signal: '',
        \ cwd: l:cwd, command: s:Label(a:cmd), argv: copy(l:command.argv)}}
  " Omitting term_finish retains the terminal on all supported Vim 9.1 builds;
  " early 9.1 rejects the later explicit 'noclose' option value.
  let l:term_opts = #{cwd: l:cwd,
        \ exit_cb: function('s:Exited', [l:context])}
  if !empty(a:input_file)
    let l:term_opts.in_io = 'file'
    let l:term_opts.in_name = fnamemodify(a:input_file, ':p')
  endif
  let l:term_opts.term_name = '[Output - ' .. s:Label(a:cmd) .. ']'
  if ! a:this_window
    let l:term_opts.term_rows = 10
  endif
  if a:start_hidden
    let l:term_opts.hidden = v:true
  else
    let l:term_opts.curwin = v:true
  endif
  let l:term_opts.norestore = v:true
  let l:term_opts.term_kill = ''
  try
    let l:ret = term_start(s:NativeCommand(l:command.argv), l:term_opts)
  catch
    call s:DeleteScript(l:command)
    call win_gotoid(l:origin)
    return s:Error('failed to start command: ' .. v:exception)
  endtry
  if l:ret == 0
    call s:DeleteScript(l:command)
    call win_gotoid(l:origin)
    return s:Error('failed to start command: ' .. s:Label(a:cmd))
  endif
  let l:context.buffer = l:ret
  let l:context.job = term_getjob(l:ret)
  call setbufvar(l:ret, 'planet_command', l:context)
  call setbufvar(l:ret, 'planet_job', l:context.job)
  call setbufvar(l:ret, 'planet_result', l:context.result)
  call setbufvar(l:ret, '&bufhidden', 'hide')
  if ! a:start_hidden
    call s:UseStatusline()
  endif
  if job_status(l:context.job) ==# 'fail'
    call s:Exited(l:context, l:context.job, -1)
  endif
  echomsg 'Output ' .. l:ret .. ': cwd=' .. l:cwd .. ', command=' .. s:Label(a:cmd)
  if ! a:this_window && ! a:start_hidden
    call win_gotoid(l:origin)
  endif
  return l:ret
endfunc

func! planet#term#RunInput(argv, input_file, cd = '') abort
  return planet#term#RunCmd(a:argv, v:false, v:false, v:false, a:cd, v:null, a:input_file)
endfunc

func! planet#term#RunArgv(argv, ...) abort
  if type(a:argv) != v:t_list
    return s:Error('RunArgv requires a List of literal arguments')
  endif
  return call('planet#term#RunCmd', [a:argv] + a:000)
endfunc

func! planet#term#RunShell(script, ...) abort
  if type(a:script) != v:t_string
    return s:Error('RunShell requires a String containing shell syntax')
  endif
  return call('planet#term#RunCmd', [a:script] + a:000)
endfunc

func! planet#term#RunScript(cmd) abort
  if empty(a:cmd)
    return s:Error('no helper script specified')
  endif
  if ! executable('bash')
    return s:Error('this helper is a Bash script; install Bash to run it')
  endif
  if type(a:cmd) == v:t_list
    return planet#term#RunArgv(['bash', s:bin_dir .. a:cmd[0]] + a:cmd[1:])
  endif
  " Legacy callers supply a script basename followed by intentional shell args.
  let l:name = matchstr(a:cmd, '^\S\+')
  let l:args = strpart(a:cmd, strlen(l:name))
  let l:path = "'" .. join(split(s:bin_dir .. l:name, "'", 1), "'\"'\"'") .. "'"
  return planet#term#RunArgv(['bash', '-c', l:path .. l:args])
endfunc

" Runs (interactive) shell command in new Tab
" When command finishes, tab is automatically closed, unless other window was
" opened in the meantime.
func! planet#term#RunCmdTab(cmd, cd = '') abort
  tabnew
  let l:ret = planet#term#RunCmd(a:cmd, v:true, v:true, v:false, a:cd)
  if l:ret == 0
    tabclose
  endif
  return l:ret
endfunc

" Runs vim command in new GVIM Window
func! planet#term#RunCmdGui(cmd) abort
  return planet#term#RunGuiApp([v:progpath, '--cmd',
        \ 'let g:startify_disable_at_vimenter = 1', '+' .. a:cmd, '+tabo'])
endfunc

" Run gui command
func! planet#term#RunGuiApp(app, cd = '') abort
  let l:cwd = empty(a:cd) ? getcwd() : fnamemodify(a:cd, ':p')
  if ! isdirectory(l:cwd)
    return s:Error('working directory does not exist: ' .. l:cwd)
  endif
  try
    let l:command = type(a:app) == v:t_list
          \ ? #{argv: a:app, script_file: ''} : s:ShellCommand(a:app)
    let l:job = job_start(l:command.argv, #{cwd: l:cwd, stoponexit: '',
          \ in_io: 'null', out_io: 'null', err_io: 'null',
          \ exit_cb: function('s:DeleteScript', [l:command])})
    if job_status(l:job) ==# 'fail'
      call s:DeleteScript(l:command)
    endif
    return l:job
  catch
    if exists('l:command')
      call s:DeleteScript(l:command)
    endif
    return s:Error('failed to start GUI application: ' .. v:exception)
  endtry
endfunc

" Run command in background (do not open any windows)
func! planet#term#RunCmdBg(cmd) abort
  return planet#term#RunCmd(a:cmd, v:false, v:false, v:true)
endfunc

" Find @cmd in 'path' setting and run with @cmd_args arguments.
" Can be used to find programs/scripts under current directory.
" Example
" call planet#term#RunCmdFind('config.status', '--recheck')<CR>
func! planet#term#RunCmdFind(cmd, cmd_args) abort
  let l:cmd_path = findfile(a:cmd)
  if ! empty(l:cmd_path)
    let l:cmd_path = fnamemodify(l:cmd_path, ":p")
    if type(a:cmd_args) == v:t_list
      return planet#term#RunArgv([l:cmd_path] + a:cmd_args)
    endif
    return planet#term#RunShell(shellescape(l:cmd_path) .. ' ' .. a:cmd_args)
  endif
endfunc

" Run @cmd with additional arguments asked from user.
" @cmd           - command to run
" @prompt        - prompt shown to user
" @default_input - prepopulated arguments
func! planet#term#RunCmdAskArgs(cmd, prompt, default_input = '') abort
  let l:cmd_args = inputdialog(a:prompt, a:default_input)
  if ! empty(l:cmd_args)
    call planet#term#RunCmd(a:cmd .. ' ' .. l:cmd_args)
  endif
endfunc

" Ask user whole command (with arguments) to run.
" @prompt        - prompt shown for user (to give an idea what command to
"                  input
" @default_input - prepopulated input (to help user to type expected command
"                  and arguments
func! planet#term#RunCmdAsk(prompt, default_input = '') abort
  let l:cmd_with_args = inputdialog(a:prompt, a:default_input)
  if ! empty(l:cmd_with_args)
    call planet#term#RunCmd(l:cmd_with_args)
  endif
endfunc

func! planet#term#ListTermWindows() abort
  let l:out_list = []
  for bufnr in term_list()
    let l:buf_name = bufname(bufnr)
    if l:buf_name !~# '^\[Output - '
      l:out_list->add({bufnr: l:buf_name})
    endif
  endfor
  return l:out_list
endfunc

" Finds terminal window in current tab.
" @returns window number or -1
func! planet#term#FindOutputWindow(idle_only = v:false) abort
  for bufnr in term_list()
    if bufname(bufnr) =~# '^\[Output - '
      if a:idle_only && term_getstatus(bufnr) !~# 'finished'
        continue
      endif
      let l:winnr = bufwinnr(bufnr)
      if l:winnr != -1
        return l:winnr
      endif
    endif
  endfor
  return -1
endfunc

func! planet#term#CloseOutputWindow() abort
  let l:winnr = planet#term#FindOutputWindow()
  if l:winnr != -1
    exe l:winnr .. 'wincmd w'
    call planet#term#Cancel(bufnr('%'))
    hide close
  endif
endfunc

func! planet#term#ListOutputWindows() abort
  let l:out_dict = {}
  for bufnr in term_list()
    let l:buf_name = bufname(bufnr)
    if l:buf_name =~# '^\[Output - '
      let l:out_dict[bufnr] = l:buf_name
    endif
  endfor
  return l:out_dict
endfunc

func! planet#term#DefineOutputWindowsMenu() abort
  silent! aunmenu ]Outputs
  let l:found_windows = v:false
  for [nr, name] in items(planet#term#ListOutputWindows())
    exe 'an 2.10 ]Outputs.' .. planet#menu#MenuifyName('[' .. nr .. '] ' .. name)
          \ .. ' <Cmd>buffer '.. nr .. '<CR>'
    let l:found_windows = v:true
  endfor
  if ! l:found_windows
    an 2.10 ]Outputs.No\ Windows <Nop>
    an disable ]Outputs.No\ Windows
  endif
endfunc

func! planet#term#PopupOutputsMenu() abort
  call planet#term#DefineOutputWindowsMenu()
  popup ]Outputs
endfunc

" Finds Terminal/Output/QF/LL window
"   - LL windows should be ignored always (but not QF)
" New Output window:
"   - if have Output window, reuse it
"   - if have other bottow window: vsplit
"   - otherwise open at bottom
" Terminal:
"   - if have terminal (job is running (not finished)): vsplit
"   - if terminal job finished: reuse
"   - if output: vsplit or reuse
"   - if QF: vsplit
"   - otherwise opet at bottom
" QF:
"   - if have QF, reuse
"   - if have bottom: vsplit
"   - otherwise open bottom
" Return:
"   List of numbers:
"     1 - terminal running
"     2 - terminal finished
"     3 - output running
"     4 - output finished
"     5 - QF
"
" ----------
"  any special window at bottom ?
"    vsplit
func! planet#term#CheckBottomWindow() abort

endfunc
