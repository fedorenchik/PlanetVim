vim9script

def! g:GuiTabLabel(): string
  var l = '[' .. v:lnum .. ']'
  var bufnrlist = tabpagebuflist(v:lnum)

  var m = ' '
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&buftype") == 'terminal'
      m = ' !'
      break
    elseif getbufvar(bufnr, "&modified")
      m = '+'
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
