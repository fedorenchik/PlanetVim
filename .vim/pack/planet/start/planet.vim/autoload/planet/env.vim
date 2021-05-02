scriptversion 4

func! planet#env#SetEnvVar(var) abort
  let l:old_value = getenv(a:var)
  if l:old_value == v:null
    let l:old_value = ''
  end
  let l:value = inputdialog(a:var .. '=', l:old_value)
  if l:value != ""
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
  call planet#term#RunCmd('env')
endfunc

func! planet#env#EditEnv() abort
  call planet#env#BufferFromCmd('env')
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
    let l:eq = stridx(line, "=")
    let l:var = strpart(line, 0, l:eq)
    let l:value = strpart(line, l:eq + 1)
    call setenv(l:var, l:value)
  endfor
endfunc
