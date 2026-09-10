vim9script
export def SetEnvVar(arg_var: any): any
  var old_value: any = getenv(arg_var)
  if old_value == v:null
    old_value = ''
  endif
  var value: any = inputdialog(arg_var .. '=', old_value, '\CANCEL')
  if value !=# '\CANCEL'
    setenv(arg_var, value)
  endif
  echo arg_var .. '=' .. value
  return 0
enddef

export def PrintEnvVar(arg_var: any): any
  var value: any = getenv(arg_var)
  if value != v:null
    echo arg_var .. '=' .. value
  else
    echo arg_var .. ' is not defined'
  endif
  return 0
enddef

export def PrintEnv(): any
  planet#health#Scratch('PlanetVim Environment', map(sort(keys(environ())), (_, lambda_key) => lambda_key .. '=' .. getenv(lambda_key)))
  return 0
enddef

export def EditEnv(): any
  tabnew
  setlocal buftype=nofile bufhidden=wipe noswapfile filetype=sh
  setline(1, map(sort(keys(environ())), (_, lambda_key) => lambda_key .. '=' .. getenv(lambda_key)))
  autocmd BufUnload <buffer> if !v:exiting | call planet#env#SetBufEnv(expand('<abuf>')) | endif
  return 0
enddef

export def BufferFromCmd(cmd: any): any
  tabnew
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal syn=bash
  au BufUnload <buffer> if ! v:exiting | call planet#env#SetBufEnv(expand("<abuf>")) end
  append(0, systemlist(cmd))
  deletebufline("", "$")
  return 0
enddef

export def SetBufEnv(bufnr_str: any): any
  var bufnr: any = str2nr(bufnr_str)
  var l: any = getbufline(bufnr, 1, "$")
  for line in l
    planet#env#SetEnvVarValue(line)
  endfor
  return 0
enddef

export def SetEnvVarValue(var_value: any): any
  var value: any
  var eq: any = stridx(var_value, "=")
  if eq <= 0 || strpart(var_value, 0, eq) !~# '^\h\w*$'
    if !empty(var_value)
      echomsg 'PlanetVim: enter NAME=value with a valid variable name.'
    endif
    return 0
  endif
  var var: any = strpart(var_value, 0, eq)
  value = strpart(var_value, eq + 1)
  setenv(var, value)
  return 0
enddef

export def NewEnvVar(): any
  var var_value: any = inputdialog("Please input variable & value with following format: VAR=value\nEnv Var: ")
  planet#env#SetEnvVarValue(var_value)
  return 0
enddef
