vim9script

def! g:GuiTabLabel(): string
  var l = v:lnum .. ' |'
  var bufnrlist = tabpagebuflist(v:lnum)

  if haslocaldir(-1) == 2
    l ..= '^'
  end

  var m = ''
  var set_mod = false
  var set_lcd = false
  var winnr = 1
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&buftype") ==# 'terminal'
      m = '!' .. m
    end
    if getbufvar(bufnr, "&buftype") !=# 'terminal' && getbufvar(bufnr, "&modified") && ! set_mod
      m ..= '+'
      set_mod = true
    end
    if haslocaldir(winnr) == 1 && ! set_lcd
      m ..= '-'
      set_lcd = true
    end
    winnr += 1
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
