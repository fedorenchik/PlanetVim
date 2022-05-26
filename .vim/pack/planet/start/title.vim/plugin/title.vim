vim9script

def! g:TitleString(): string
  var m = ''
  var set_mod = false
  var buf = 1
  while buf <= bufnr('$')
    if !bufexists(buf)
      buf += 1
      continue
    endif
    if !buflisted(buf) && !bufloaded(buf)
      buf += 1
      continue
    endif
    if getbufvar(buf, "&buftype") !=# 'terminal' && getbufvar(buf, "&modified") && ! set_mod
      m = '+' .. m
      set_mod = true
    endif
    #TODO: only show running (not finished) commands/terminals
    if getbufvar(buf, "&buftype") ==# 'terminal'
      m ..= '!'
    endif
    buf += 1
  endwhile
  var session_name = ''
  if ! empty(v:this_session)
    session_name = fnamemodify(v:this_session, ':t') .. ' - '
  endif
  var global_cwd = fnamemodify(getcwd(-1), ":~")
  return m .. ' ' .. session_name .. global_cwd .. ' - ' .. v:servername
enddef
