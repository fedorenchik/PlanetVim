vim9script

def! g:GuiTabLabel(): string
  var l = v:lnum .. ' |'
  var bufnrlist = tabpagebuflist(v:lnum)

  if haslocaldir(-1) == 2
    l ..= '^'
  endif

  var m = ''
  var set_term = false
  var set_mod = false
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&buftype") ==# 'terminal'
      m = '!' .. m
      set_term = true
    endif
    if getbufvar(bufnr, "&buftype") !=# 'terminal' && getbufvar(bufnr, "&modified") && !set_mod
      m ..= '*'
      set_mod = true
    endif
    if set_term && set_mod
      break
    endif
  endfor
  l ..= m
  l ..= ' '

  var f = fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), ':t')
  if empty(f)
    f = '[No Name]'
  endif
  return l .. f
enddef
