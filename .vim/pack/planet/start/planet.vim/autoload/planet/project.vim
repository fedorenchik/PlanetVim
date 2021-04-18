scriptversion 4

let s:templates_dir = expand('<sfile>:p:h:h:h')->resolve() .. '/templates/'

func! planet#project#CopyFile(file) abort
endfunc

func! planet#project#CopyDir(dir) abort
endfunc
