vim9script

def! g:GuiTabLabel(): string
  var l = v:lnum .. ' |'
  var bufnrlist = tabpagebuflist(v:lnum)

  if haslocaldir(-1) == 2
    l ..= '^'
  end

  var m = ''
  var set_term = false
  var set_mod = false
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&buftype") ==# 'terminal'
      m = '!' .. m
      set_term = true
    end
    if getbufvar(bufnr, "&buftype") !=# 'terminal' && getbufvar(bufnr, "&modified") && !set_mod
      m ..= '+'
      set_mod = true
    end
    if set_term && set_mod
      break
    end
  endfor
  l ..= m
  l ..= ' '

  var bufnr: number = bufnrlist[tabpagewinnr(v:lnum) - 1]
  var f = fnamemodify(bufname(bufnr), ':t')
  if empty(f)
    f = '[No Name]'
  end
  if getbufvar(bufnr, "&buftype") !=# 'terminal' && getbufvar(bufnr, "&modified")
    f ..= '*'
  end
  return l .. f
enddef
