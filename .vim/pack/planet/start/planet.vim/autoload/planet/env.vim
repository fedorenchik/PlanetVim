scriptversion 4

func! planet#env#SetEnvVar(var) abort
  let l:old_value = getenv(a:var)
  if l:old_value == v:null
    let l:old_value = ''
  end
  let l:value = inputdialog(a:var .. '=', l:old_value, '\CANCEL')
  if l:value !=# '\CANCEL'
    call setenv(a:var, l:value)
  end
  echo a:var .. '=' .. l:value
endfunc

func! planet#env#PrintEnvVar(var) abort
  let l:value = getenv(a:var)
  if l:value != v:null
    echo a:var .. '=' .. l:value
  else
    echo a:var .. ' is not defined'
  end
endfunc

func! planet#env#PrintEnv() abort
  call planet#health#Scratch('PlanetVim Environment', map(sort(keys(environ())), {_, key -> key .. '=' .. getenv(key)}))
endfunc

func! planet#env#EditEnv() abort
  tabnew
  setlocal buftype=nofile bufhidden=wipe noswapfile filetype=sh
  call setline(1, map(sort(keys(environ())), {_, key -> key .. '=' .. getenv(key)}))
  autocmd BufUnload <buffer> if !v:exiting | call planet#env#SetBufEnv(expand('<abuf>')) | endif
endfunc

func! planet#env#BufferFromCmd(cmd) abort
  tabnew
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal syn=bash
  au BufUnload <buffer> if ! v:exiting | call planet#env#SetBufEnv(expand("<abuf>")) end
  call append(0, systemlist(a:cmd))
  call deletebufline("", "$")
endfunc

func! planet#env#SetBufEnv(bufnr_str) abort
  let l:bufnr = str2nr(a:bufnr_str)
  let l:l = getbufline(l:bufnr, 1, "$")
  for line in l:l
    call planet#env#SetEnvVarValue(line)
  endfor
endfunc

func! planet#env#SetEnvVarValue(var_value) abort
  let l:eq = stridx(a:var_value, "=")
  if l:eq <= 0 || strpart(a:var_value, 0, l:eq) !~# '^\h\w*$'
    if !empty(a:var_value)
      echomsg 'PlanetVim: enter NAME=value with a valid variable name.'
    endif
    return 0
  endif
  let l:var = strpart(a:var_value, 0, l:eq)
  let l:value = strpart(a:var_value, l:eq + 1)
  call setenv(l:var, l:value)
endfunc

func! planet#env#NewEnvVar() abort
  let l:var_value = inputdialog("Please input variable & value with following format: VAR=value\nEnv Var: ")
  call planet#env#SetEnvVarValue(l:var_value)
endfunc
