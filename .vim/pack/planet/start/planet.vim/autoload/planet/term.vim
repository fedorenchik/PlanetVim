vim9script

var script_bin_dir = expand('<script>:p:h:h:h')->resolve() .. '/bin/'

def LocalWindowsArgument(argument: any): any
  # Quote for CommandLineToArgvW/the C runtime, including a zero-length arg.
  var quoted: any = '"'
  var slashes: any = 0
  for char in split(argument, '\zs')
    if char ==# '\'
      slashes += 1
    elseif char ==# '"'
      quoted ..= repeat('\', 2 * slashes + 1) .. '"'
      slashes = 0
    else
      quoted ..= repeat('\', slashes) .. char
      slashes = 0
    endif
  endfor
  return quoted .. repeat('\', 2 * slashes) .. '"'
enddef

def LocalNativeCommand(argv: any): any
  if !has('win32') || index(argv, '') < 0
    return argv
  endif
  # Vim's win32_escape_arg() drops empty List items. A String here is the
  # native CreateProcess command line, with no shell involved. Serialize only
  # this affected case ourselves and retain the original argv in the result.
  return join(map(copy(argv), (_, lambda_arg) => LocalWindowsArgument(lambda_arg)), ' ')
enddef

# A List is native argv; a String is an intentional script for the configured
# shell. Never split/rejoin a script: doing so loses quotes and argument bounds.
def LocalShellCommand(script: any): any
  var words: any = []
  var word: any = ''
  var quote: any = ''
  var escape: any = v:false
  for char in split(&shell, '\zs')
    if escape
      word ..= char
      escape = v:false
    elseif char == '\' && ! has('win32') && quote != "'"
      escape = v:true
    elseif ! empty(quote)
      if char == quote
        quote = ''
      else
        word ..= char
      endif
    elseif char == '"' || char == "'"
      quote = char
    elseif char =~# '\s'
      if ! empty(word)
        add(words, word)
        word = ''
      endif
    else
      word ..= char
    endif
  endfor
  if escape || ! empty(quote)
    throw 'PlanetVim: unmatched quote or escape in shell option'
  endif
  if ! empty(word)
    add(words, word)
  endif
  if empty(words) || empty(&shellcmdflag)
    throw 'PlanetVim: shell and shellcmdflag must be configured'
  endif
  var command: any = {argv: words + split(&shellcmdflag), script_file: ''}
  if has('win32') && fnamemodify(words[0], ':t') =~? '^cmd\%(\.exe\)\?$'
    # Vim quotes List arguments for the Windows C runtime. cmd.exe does not
    # understand those backslash-escaped quotes, so pass quoted shell text in
    # a batch file instead. `call` keeps /c from stripping the path's quotes.
    command.script_file = tempname() .. '.cmd'
    writefile(split(script, "\n", 1), command.script_file)
    command.argv += ['call', command.script_file]
  else
    command.argv += [script]
  endif
  return command
enddef

def LocalDeleteScript(command: any, ...args: list<any>): any
  if ! empty(command.script_file)
    delete(command.script_file)
  endif
  return 0
enddef

def LocalLabel(cmd: any): any
  var text: any = type(cmd) == v:t_list ? string(cmd) : cmd
  return substitute(text, '[\r\n]', ' ', 'g')
enddef

def LocalError(message: any): any
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. message
  echohl None
  return 0
enddef

# A snapshot suitable for dependent actions. Only status == 'success' permits
# a success-only next step; exit_code stays v:null until the child exits.
export def Result(bufnr: any): any
  return deepcopy(getbufvar(bufnr, 'planet_result', {}))
enddef

export def Statusline(bufnr: any): any
  var result: any = planet#term#Result(bufnr)
  if empty(result)
    return ''
  endif
  var status: any = result.status
  if result.exit_code != null
    status ..= ' (' .. result.exit_code .. ')'
  endif
  return '[' .. status .. '] ' .. result.command .. ' | ' .. result.cwd
enddef

export def Info(bufnr: any = bufnr('%')): any
  var result: any = planet#term#Result(bufnr)
  if empty(result)
    return LocalError('this buffer has no PlanetVim command result')
  endif
  echomsg 'Output ' .. bufnr .. ': ' .. planet#term#Statusline(bufnr)
  return result
enddef

def LocalUseStatusline(): any
  if ! exists('w:planet_previous_statusline')
    w:planet_previous_statusline = &l:statusline
  endif
  &l:statusline = '%{planet#term#Statusline(bufnr())}'
  return 0
enddef

def LocalRestoreStatusline(): any
  if exists('w:planet_previous_statusline')
    &l:statusline = w:planet_previous_statusline
    unlet w:planet_previous_statusline
  endif
  return 0
enddef

augroup PlanetVimOutputStatusline
  autocmd!
  autocmd BufWinEnter * if exists('b:planet_result') | call LocalUseStatusline() | endif
  autocmd BufWinLeave * if exists('b:planet_result') | call LocalRestoreStatusline() | endif
augroup END

# Close successful interactive commands only after the terminal has drained.
# Failed/cancelled commands keep their terminal output and colours for review.
def LocalFinish(context: any, timer: any): any
  var bufnr: any = context.buffer
  if ! bufexists(bufnr)
    return 0
  endif
  if term_getstatus(bufnr) !~# 'finished'
    timer_start(20, function(LocalFinish, [context]))
    return 0
  endif
  if context.close_on_exit && context.result.status ==# 'success'
    for winid in win_findbuf(bufnr)
      try
        win_execute(winid, 'hide close')
      catch /^Vim\%((\a\+)\)\=:E444/
        # A command in the last editor window must leave that window open.
      endtry
    endfor
  endif
  return 0
enddef

def LocalExited(context: any, job: any, status: any): any
  if context.buffer == 0
    timer_start(0, (lambda_timer) => LocalExited(context, job, status))
    return 0
  endif
  var result: any = context.result
  if result.exit_code != null
    return 0
  endif
  result.exit_code = status
  result.signal = get(job_info(job), 'termsig', '')
  result.status = context.cancel_requested ? 'cancelled'  :  status == 0 && empty(result.signal) ? 'success' :  'failed'
  if bufexists(context.buffer)
    setbufvar(context.buffer, 'planet_result', result)
  endif
  echomsg 'Output ' .. context.buffer .. ': ' .. result.status  .. ', exit status ' .. status .. ', cwd=' .. result.cwd  .. ', command=' .. result.command
  if context.close_on_exit && result.status ==# 'success'
    timer_start(0, function(LocalFinish, [context]))
  endif
  LocalDeleteScript(context)
  if type(context.on_exit) == v:t_func
    try
      call(context.on_exit, [deepcopy(result), context.buffer])
    catch
      result.callback_error = v:exception
      LocalError('command completion callback failed: ' .. v:exception)
    endtry
  endif
  redrawstatus
  return 0
enddef

export def Cancel(bufnr: any = bufnr('%')): any
  var context: any = getbufvar(bufnr, 'planet_command', {})
  if empty(context) || job_status(context.job) !=# 'run'
    return 0
  endif
  context.cancel_requested = v:true
  if ! job_stop(context.job, 'term')
    context.cancel_requested = v:false
    return 0
  endif
  return 1
enddef

# Run native argv or a shell script in an existing idle/new [Output] window.
# @cmd[in] List of literal arguments, or String containing shell syntax
# @this_window[in] if true, run in current window unconditionally
# @close_on_exit[in] if true, close current window after successful completion
# @start_hidden[in] if true, do not open new window
# @cd if not empty, change command's CWD to this dir
# @on_exit optional Funcref(result, bufnr); result.status must be checked before
#          starting success-only followups. Callback errors do not change the
#          original process status.
export def RunCmd(cmd: any, this_window: any = v:false, close_on_exit: any = v:false, start_hidden: any = v:false, cd: any = '', on_exit: any = v:null, input_file: any = ''): any
  var command: any
  var winnr: any
  var ret: any
  if index([v:t_string, v:t_list], type(cmd)) < 0 || empty(cmd)
    return LocalError('command must be a nonempty String or argv List')
  endif
  if type(cmd) == v:t_list && (empty(cmd[0]) || ! empty(filter(copy(cmd), (_, lambda_value) => type(lambda_value) != v:t_string)))
    return LocalError('argv must contain Strings and a nonempty executable')
  endif
  if on_exit != null && type(on_exit) != v:t_func
    return LocalError('on_exit must be a Funcref or v:null')
  endif
  var cwd: any = empty(cd) ? getcwd() : fnamemodify(cd, ':p')
  if ! isdirectory(cwd)
    return LocalError('working directory does not exist: ' .. cwd)
  endif
  if !empty(input_file) && !filereadable(input_file)
    return LocalError('input file is not readable: ' .. input_file)
  endif
  try
    command = type(cmd) == v:t_list ? {argv: copy(cmd), script_file: ''} : LocalShellCommand(cmd)
  catch
    return LocalError(v:exception)
  endtry
  var origin: any = win_getid()
  if ! this_window && ! start_hidden
    winnr = planet#term#FindOutputWindow(v:true)
    if winnr == -1
      botright :10new
      set winfixheight winfixwidth
    else
      exe ':' .. winnr .. 'wincmd w'
    endif
  endif
  var context: any = {buffer: 0, cancel_requested: v:false, close_on_exit: close_on_exit, script_file: command.script_file,
       on_exit: on_exit, result: {status: 'running', exit_code: v:null, signal: '', cwd: cwd, command: LocalLabel(cmd),
       argv: copy(command.argv)}}
  # Omitting term_finish retains the terminal on all supported Vim 9.1 builds;
  # early 9.1 rejects the later explicit 'noclose' option value.
  var term_opts: any = {cwd: cwd, exit_cb: function(LocalExited, [context])}
  if !empty(input_file)
    term_opts.in_io = 'file'
    term_opts.in_name = fnamemodify(input_file, ':p')
  endif
  term_opts.term_name = '[Output - ' .. LocalLabel(cmd) .. ']'
  if ! this_window
    term_opts.term_rows = 10
  endif
  if start_hidden
    term_opts.hidden = v:true
  else
    term_opts.curwin = v:true
  endif
  term_opts.norestore = v:true
  term_opts.term_kill = ''
  try
    ret = term_start(LocalNativeCommand(command.argv), term_opts)
  catch
    LocalDeleteScript(command)
    win_gotoid(origin)
    return LocalError('failed to start command: ' .. v:exception)
  endtry
  if ret == 0
    LocalDeleteScript(command)
    win_gotoid(origin)
    return LocalError('failed to start command: ' .. LocalLabel(cmd))
  endif
  context.buffer = ret
  context.job = term_getjob(ret)
  setbufvar(ret, 'planet_command', context)
  setbufvar(ret, 'planet_job', context.job)
  setbufvar(ret, 'planet_result', context.result)
  setbufvar(ret, '&bufhidden', 'hide')
  if ! start_hidden
    LocalUseStatusline()
  endif
  if job_status(context.job) ==# 'fail'
    LocalExited(context, context.job, -1)
  endif
  echomsg 'Output ' .. ret .. ': cwd=' .. cwd .. ', command=' .. LocalLabel(cmd)
  if ! this_window && ! start_hidden
    win_gotoid(origin)
  endif
  return ret
enddef

export def RunInput(argv: any, input_file: any, cd: any = ''): any
  return planet#term#RunCmd(argv, v:false, v:false, v:false, cd, v:null, input_file)
enddef

export def RunArgv(argv: any, ...args: list<any>): any
  if type(argv) != v:t_list
    return LocalError('RunArgv requires a List of literal arguments')
  endif
  return call('planet#term#RunCmd', [argv] + args)
enddef

export def RunShell(script: any, ...args: list<any>): any
  if type(script) != v:t_string
    return LocalError('RunShell requires a String containing shell syntax')
  endif
  return call('planet#term#RunCmd', [script] + args)
enddef

export def RunScript(cmd: any): any
  if empty(cmd)
    return LocalError('no helper script specified')
  endif
  if ! executable('bash')
    return LocalError('this helper is a Bash script; install Bash to run it')
  endif
  if type(cmd) == v:t_list
    return planet#term#RunArgv(['bash', script_bin_dir .. cmd[0]] + cmd[1 : ])
  endif
  # Legacy callers supply a script basename followed by intentional shell args.
  var name: any = matchstr(cmd, '^\S\+')
  var args: any = strpart(cmd, strlen(name))
  var path: any = "'" .. join(split(script_bin_dir .. name, "'", 1), "'\"'\"'") .. "'"
  return planet#term#RunArgv(['bash', '-c', path .. args])
enddef

# Runs (interactive) shell command in new Tab
# When command finishes, tab is automatically closed, unless other window was
# opened in the meantime.
export def RunCmdTab(cmd: any, cd: any = ''): any
  tabnew
  var ret: any = planet#term#RunCmd(cmd, v:true, v:true, v:false, cd)
  if ret == 0
    tabclose
  endif
  return ret
enddef

# Runs vim command in new GVIM Window
export def RunCmdGui(cmd: any): any
  return planet#term#RunGuiApp([v:progpath, '--cmd', 'let g:startify_disable_at_vimenter = 1', '+' .. cmd, '+tabo'])
enddef

# Run gui command
export def RunGuiApp(app: any, cd: any = ''): any
  var command: any
  var job: any
  var cwd: any = empty(cd) ? getcwd() : fnamemodify(cd, ':p')
  if ! isdirectory(cwd)
    return LocalError('working directory does not exist: ' .. cwd)
  endif
  try
    command = type(app) == v:t_list ? {argv: app, script_file: ''} : LocalShellCommand(app)
    job = job_start(command.argv, {cwd: cwd, stoponexit: '', in_io: 'null', out_io: 'null', err_io: 'null', exit_cb: function(LocalDeleteScript, [command])})
    if job_status(job) ==# 'fail'
      LocalDeleteScript(command)
    endif
    return job
  catch
    if type(command) == v:t_dict
      LocalDeleteScript(command)
    endif
    return LocalError('failed to start GUI application: ' .. v:exception)
  endtry
enddef

# Run command in background (do not open any windows)
export def RunCmdBg(cmd: any): any
  return planet#term#RunCmd(cmd, v:false, v:false, v:true)
enddef

# Find @cmd in 'path' setting and run with @cmd_args arguments.
# Can be used to find programs/scripts under current directory.
# Example
# call planet#term#RunCmdFind('config.status', '--recheck')<CR>
export def RunCmdFind(cmd: any, cmd_args: any): any
  var cmd_path: any = findfile(cmd)
  if ! empty(cmd_path)
    cmd_path = fnamemodify(cmd_path, ":p")
    if type(cmd_args) == v:t_list
      return planet#term#RunArgv([cmd_path] + cmd_args)
    endif
    return planet#term#RunShell(shellescape(cmd_path) .. ' ' .. cmd_args)
  endif
  return 0
enddef

# Run @cmd with additional arguments asked from user.
# @cmd           - command to run
# @prompt        - prompt shown to user
# @default_input - prepopulated arguments
export def RunCmdAskArgs(cmd: any, prompt: any, default_input: any = ''): any
  var cmd_args: any = inputdialog(prompt, default_input)
  if ! empty(cmd_args)
    planet#term#RunCmd(cmd .. ' ' .. cmd_args)
  endif
  return 0
enddef

# Ask user whole command (with arguments) to run.
# @prompt        - prompt shown for user (to give an idea what command to
#                  input
# @default_input - prepopulated input (to help user to type expected command
#                  and arguments
export def RunCmdAsk(prompt: any, default_input: any = ''): any
  var cmd_with_args: any = inputdialog(prompt, default_input)
  if ! empty(cmd_with_args)
    planet#term#RunCmd(cmd_with_args)
  endif
  return 0
enddef

export def ListTermWindows(): any
  var buf_name: any
  var out_list: any = []
  for bufnr in term_list()
    buf_name = bufname(bufnr)
    if buf_name !~# '^\[Output - '
      out_list->add({bufnr:  buf_name})
    endif
  endfor
  return out_list
enddef

# Finds terminal window in current tab.
# @returns window number or -1
export def FindOutputWindow(idle_only: any = v:false): any
  var winnr: any
  for bufnr in term_list()
    if bufname(bufnr) =~# '^\[Output - '
      if idle_only && term_getstatus(bufnr) !~# 'finished'
        continue
      endif
      winnr = bufwinnr(bufnr)
      if winnr != -1
        return winnr
      endif
    endif
  endfor
  return -1
enddef

export def CloseOutputWindow(): any
  var winnr: any = planet#term#FindOutputWindow()
  if winnr != -1
    exe ':' .. winnr .. 'wincmd w'
    planet#term#Cancel(bufnr('%'))
    hide close
  endif
  return 0
enddef

export def ListOutputWindows(): any
  var buf_name: any
  var out_dict: any = {}
  for bufnr in term_list()
    buf_name = bufname(bufnr)
    if buf_name =~# '^\[Output - '
      out_dict[bufnr] = buf_name
    endif
  endfor
  return out_dict
enddef

export def DefineOutputWindowsMenu(): any
  silent! aunmenu ]Outputs
  var found_windows: any = v:false
  for [nr, name] in items(planet#term#ListOutputWindows())
    exe 'PlanetMenu an 2.10 ]Outputs.' .. planet#menu#MenuifyName('[' .. nr .. '] ' .. name) .. ' <Cmd>buffer ' .. nr .. '<CR>'
    found_windows = v:true
  endfor
  if ! found_windows
    PlanetMenu an 2.10 ]Outputs.No\ Windows <Nop>
    an disable ]Outputs.No\ Windows
  endif
  return 0
enddef

export def PopupOutputsMenu(): any
  planet#term#DefineOutputWindowsMenu()
  popup ]Outputs
  return 0
enddef

# Finds Terminal/Output/QF/LL window
#   - LL windows should be ignored always (but not QF)
# New Output window:
#   - if have Output window, reuse it
#   - if have other bottow window: vsplit
#   - otherwise open at bottom
# Terminal:
#   - if have terminal (job is running (not finished)): vsplit
#   - if terminal job finished: reuse
#   - if output: vsplit or reuse
#   - if QF: vsplit
#   - otherwise opet at bottom
# QF:
#   - if have QF, reuse
#   - if have bottom: vsplit
#   - otherwise open bottom
# Return:
#   List of numbers:
#     1 - terminal running
#     2 - terminal finished
#     3 - output running
#     4 - output finished
#     5 - QF
#
# ----------
#  any special window at bottom ?
#    vsplit
export def CheckBottomWindow(): any

  return 0
enddef
