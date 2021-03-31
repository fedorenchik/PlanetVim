" func! GuiTabLabel() abort
"   let l = '[' .. v:lnum .. ']'
"   let bufnrlist = tabpagebuflist(v:lnum)
" 
"   "TODO: add '!' if has terminal window in tab page
"   let m = ' '
"   for bufnr in bufnrlist
"     if getbufvar(bufnr, "&modified")
"       let m = '+'
"       break
"     endif
"   endfor
"   let l ..= m
"   let l ..= ' '
" 
"   let f = fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), ':t')
"   if empty(f)
"     let f = '[No Name]'
"   endif
"   return l .. f
" endfunc

vim9script

export def! g:GuiTabLabel(): string
  var l = '[' .. v:lnum .. ']'
  var bufnrlist = tabpagebuflist(v:lnum)

  #TODO: add '!' if has terminal window in tab page
  var m = ' '
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
      m = '+'
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
