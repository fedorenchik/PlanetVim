scriptversion 4

let s:bin_dir = expand('<sfile>:p:h:h:h:h')->resolve() .. '/bin/'

func! planet#util#term#run_script_output(cmd) abort
  "TODO: reuse existing window
  exe 'botright term ++norestore ++kill=kill ++rows=10 ' .. s:bin_dir .. a:cmd
  set winfixheight winfixwidth
  wincmd p
endfunc

func! planet#util#term#run_cmd_output(cmd) abort
  let l:found_window = v:false
  for bufnr in tabpagebuflist()
    if getbufvar(bufnr, '&buftype') == 'terminal' && bufname(bufnr) =~# '^\[Output - '
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
  let ret = term_start(a:cmd, #{
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
