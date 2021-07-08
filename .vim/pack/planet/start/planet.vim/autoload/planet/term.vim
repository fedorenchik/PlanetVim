scriptversion 4

let s:bin_dir = expand('<sfile>:p:h:h:h')->resolve() .. '/bin/'

" Run shell command in existing (if exists) or new [Output] window.
" @cmd[in] command to run
" @this_window[in] if true, run in current window unconditionally
" @close_on_exit[in] if true, close current window after cmd terminated
" @start_hidden[in] if true, do not open new window
" @cd if not empty, change command's CWD to this dir
func! planet#term#RunCmd(cmd, this_window = v:false, close_on_exit = v:false, start_hidden = v:false, cd = '') abort
  if ! a:this_window && ! a:start_hidden
    let l:winnr = planet#term#FindOutputWindow()
    if l:winnr == -1
      botright 10new
      set winfixheight winfixwidth
    else
      exe l:winnr .. 'wincmd w'
    end
  end
  let l:term_opts = #{}
  let l:term_opts.term_name = '[Output - ' .. a:cmd .. ']'
  if ! a:this_window
    let l:term_opts.term_rows = 10
  end
  if a:start_hidden
    let l:term_opts.hidden = v:true
  else
    let l:term_opts.curwin = v:true
  end
  let l:term_opts.norestore = v:true
  let l:term_opts.term_kill = "kill"
  if a:close_on_exit == v:true
    let l:term_opts.term_finish = "close"
  end
  let l:cmd_cd = ''
  if ! empty(a:cd)
    let l:cmd_cd = 'cd ' .. a:cd .. ' ; '
  end
  let ret = term_start(s:bin_dir .. 'run-command ' .. l:cmd_cd .. a:cmd, l:term_opts)
  if ret == 0
    echohl Error
    echo "Failed to start commad: " .. a:cmd
    echohl None
    return
  end
  if ! a:this_window && ! a:start_hidden
    wincmd p
  end
endfunc

func! planet#term#RunScript(cmd) abort
  call planet#term#RunCmd(s:bin_dir .. a:cmd)
endfunc

" Runs (interactive) shell command in new Tab
" When command finishes, tab is automatically closed, unless other window was
" opened in the meantime.
func! planet#term#RunCmdTab(cmd, cd = '') abort
  tabnew
  call planet#term#RunCmd(a:cmd, v:true, v:true, v:false, a:cd)
endfunc

" Runs vim command in new GVIM Window
func! planet#term#RunCmdGui(cmd) abort
  exe "silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +'" .. a:cmd .. "' +tabo"
endfunc

" Run gui command
func! planet#term#RunGuiApp(app, cd = '') abort
  let l:cd_cmd = ''
  if ! empty(a:cd)
    let l:cd_cmd = 'cd ' .. a:cd .. ' && '
  end
  exe "silent !" .. l:cd_cmd .. "nohup " .. a:app .. " >/dev/null 2>&1 &"
endfunc

" Run command in background (do not open any windows)
func! planet#term#RunCmdBg(cmd) abort
  call planet#term#RunCmd(a:cmd, v:false, v:false, v:true)
endfunc

" Find @cmd in 'path' setting and run with @cmd_args arguments
" Example
" call planet#term#RunCmdFind('config.status', '--recheck')<CR>
func! planet#term#RunCmdFind(cmd, cmd_args) abort
  let l:cmd_path = findfile(a:cmd)
  if ! empty(l:cmd_path)
    let l:cmd_path = fnamemodify(l:cmd_path, ":p")
    call planet#term#RunCmd(l:cmd_path .. ' ' .. a:cmd_args)
  end
endfunc

" Run @cmd with additional arguments asked from user.
" @cmd           - command to run
" @prompt        - prompt shown to user
" @default_input - prepopulated arguments
func! planet#term#RunCmdAskArgs(cmd, prompt, default_input = '') abort
  let l:cmd_args = inputdialog(a:prompt, a:default_input)
  if ! empty(l:cmd_args)
    call planet#term#RunCmd(a:cmd .. ' ' .. l:cmd_args)
  end
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
  end
endfunc

func! planet#term#ListTermWindows() abort
  let l:out_list = []
  for bufnr in term_list()
    let l:buf_name = bufname(bufnr)
    if l:buf_name !~# '^\[Output - '
      l:out_list->add({bufnr: l:buf_name})
    end
  endfor
  return l:out_list
endfunc

" Finds terminal window in current tab.
" @returns window number or -1
func! planet#term#FindOutputWindow() abort
  for bufnr in term_list()
    if bufname(bufnr) =~# '^\[Output - '
      let l:winnr = bufwinnr(bufnr)
      if l:winnr != -1
        return l:winnr
      end
    end
  endfor
  return -1
endfunc

func! planet#term#CloseOutputWindow() abort
  let l:winnr = planet#term#FindOutputWindow()
  if l:winnr != -1
    exe l:winnr .. 'wincmd w'
    wincmd c
  end
endfunc

func! planet#term#ListOutputWindows() abort
  let l:out_dict = {}
  for bufnr in term_list()
    let l:buf_name = bufname(bufnr)
    if l:buf_name =~# '^\[Output - '
      let l:out_dict[bufnr] = l:buf_name
    end
  endfor
  return l:out_dict
endfunc

func! planet#term#DefineOutputWindowsMenu() abort
  silent! aunmenu ]Outputs
  let l:found_windows = v:false
  for [nr, name] in items(planet#term#ListOutputWindows())
    exe 'an 2.10 ]Outputs.' .. planet#menu#MenuifyName(name) .. ' <Cmd>b '.. nr .. '<CR>'
    let l:found_windows = v:true
  endfor
  if ! l:found_windows
    an 2.10 ]Outputs.No\ Windows <Nop>
    an disable ]Outputs.No\ Windows
  end
endfunc

func! planet#term#PopupOutputsMenu() abort
  call planet#term#DefineOutputWindowsMenu()
  popup ]Outputs
endfunc
