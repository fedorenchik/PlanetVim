scriptversion 4

let s:bin_dir = expand('<sfile>:p:h:h:h')->resolve() .. '/bin/'

func! planet#term#run_script_output(cmd) abort
  "TODO: reuse existing window
  exe 'botright term ++norestore ++kill=kill ++rows=10 ' .. s:bin_dir .. a:cmd
  set winfixheight winfixwidth
  wincmd p
endfunc

func! planet#term#run_cmd_output(cmd) abort
  let l:found_window = v:false
  for bufnr in term_list()
    if bufname(bufnr) =~# '^\[Output - '
      let l:winnr = bufwinnr(bufnr)
      if l:winnr != -1
        exe l:winnr .. 'wincmd w'
        let l:found_window = v:true
      endif
    endif
  endfor
  if ! l:found_window
    botright 10new
  endif
  let ret = term_start(s:bin_dir .. 'run-command ' .. a:cmd, #{
        \ term_name: '[Output - ' .. a:cmd .. ']',
        \ term_rows: 10,
        \ curwin: v:true,
        \ norestore: v:true,
        \ term_kill: "kill",
        \ })
  set winfixheight winfixwidth
  if ret == 0
    echohl Error
    echo "Failed to start commad: " .. a:cmd
    echohl None
    return
  endif
  wincmd p
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
