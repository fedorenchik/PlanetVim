au BufRead,BufNewFile log\.* set filetype=yoctolog
autocmd BufRead * call s:YoctoLog()
function! s:YoctoLog()
  if !empty(&filetype)
    return
  endif

  let line = getline(1)
  if line =~ "log\..*"
    setfiletype yoctolog
  endif
endfunction
