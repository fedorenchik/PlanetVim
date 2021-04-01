scriptversion 4

let s:bin_dir = expand('<sfile>:p:h:h:h:h')->resolve() .. '/bin/'

func! planet#util#term#run_script_output(cmd) abort
  "TODO: reuse existing window
  exe 'botright term ++kill=kill ++rows=10 ' .. s:bin_dir .. a:cmd
  set winfixheight winfixwidth
  wincmd p
endfunc

func! planet#util#term#run_cmd_output(cmd) abort
  "TODO: reuse existing window
  exe 'botright term ++kill=kill ++rows=10 ' .. a:cmd
  set winfixheight winfixwidth
  wincmd p
endfunc
