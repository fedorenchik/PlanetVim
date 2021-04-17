scriptversion 4

let s:bin_dir = expand('<sfile>:p:h:h:h')->resolve() .. '/bin/'

func! planet#term#RunScript(cmd) abort
  "TODO: reuse existing window
  exe 'botright term ++norestore ++kill=kill ++rows=10 ' .. s:bin_dir .. a:cmd
  set winfixheight winfixwidth
  wincmd p
endfunc

" Run command in existing (if exists) or new [Output] window.
" @cmd[in] command to run
" @this_window[in] if true, run in current window unconditionally
func! planet#term#RunCmd(cmd, this_window = v:false) abort
  if ! a:this_window
    let l:winnr = planet#term#FindOutputWindow()
    if l:winnr == -1
      botright 10new
      set winfixheight winfixwidth
    else
      exe l:winnr .. 'wincmd w'
    end
  end
  let ret = term_start(s:bin_dir .. 'run-command ' .. a:cmd, #{
        \ term_name: '[Output - ' .. a:cmd .. ']',
        \ term_rows: 10,
        \ curwin: v:true,
        \ norestore: v:true,
        \ term_kill: "kill",
        \ })
  if ret == 0
    echohl Error
    echo "Failed to start commad: " .. a:cmd
    echohl None
    return
  end
  if ! a:this_window
    wincmd p
  end
endfunc

" Runs (interactive) command in new Tab
func! planet#term#RunCmdTab(cmd) abort
  tabnew
  call planet#term#RunCmd(cmd, v:true)
endfunc

" Runs command in new GVIM Window
func! planet#term#RunCmdGui(cmd) abort
endfunc

func! planet#term#RunGuiApp(app) abort
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
  let l:out_list = []
  for bufnr in term_list()
    if bufname(bufnr) =~# '^\[Output - '
      call add(l:out_list, bufnr)
    endif
  endfor
  return l:out_list
endfunc

func! planet#term#ListTermWindows() abort
  let l:out_list = []
  for bufnr in term_list()
    if bufname(bufnr) !~# '^\[Output - '
      call add(l:out_list, bufnr)
    endif
  endfor
  return l:out_list
endfunc
