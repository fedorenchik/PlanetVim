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
    if getbufvar(buf, "&buftype") ==# 'terminal'
      m = '!' .. m
    end
    if getbufvar(buf, "&buftype") !=# 'terminal' && getbufvar(buf, "&modified") && ! set_mod
      m ..= '+'
      set_mod = true
    end
    buf += 1
  endwhile
  var main_part = ''
  if ! empty(v:this_session)
    main_part = fnamemodify(v:this_session, ':t')
  else
    main_part = fnamemodify(getcwd(-1), ":~")
  end
  return m .. ' ' .. main_part .. ' - ' .. v:servername
enddef
