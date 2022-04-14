vim9script

def! g:GuiTabLabel(): string
  var l = v:lnum .. ' |'
  if tabpagenr() == tabpagenr('#')
    l = '#' .. l
  endif
  var bufnrlist = tabpagebuflist(v:lnum)

  if haslocaldir(-1) == 2
    l ..= '^'
  endif

  var m = ''
  var set_mod = false
  var set_lcd = false
  var winnr = 1
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&buftype") ==# 'terminal'
      m = '!' .. m
    endif
    if getbufvar(bufnr, "&buftype") !=# 'terminal' && getbufvar(bufnr, "&modified") && ! set_mod
      m ..= '+'
      set_mod = true
    endif
    if haslocaldir(winnr) == 1 && ! set_lcd
      m ..= '-'
      set_lcd = true
    endif
    winnr += 1
  endfor
  l ..= m
  l ..= ' '

  var bufnr: number = bufnrlist[tabpagewinnr(v:lnum) - 1]
  var f = fnamemodify(bufname(bufnr), ':t')
  if empty(f)
    f = '[No Name]'
  endif
  if getbufvar(bufnr, "&buftype") !=# 'terminal' && getbufvar(bufnr, "&modified")
    f ..= '*'
  endif
  return l .. f
enddef
