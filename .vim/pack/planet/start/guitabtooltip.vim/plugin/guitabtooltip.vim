vim9script

def! g:GuiTabTooltip(): string
  var tooltip = '[' .. v:lnum .. '/' .. tabpagenr('$') .. ']'
  tooltip ..= '[#:' .. tabpagewinnr(v:lnum, '$') .. ']'
  if haslocaldir(-1) == 2
    tooltip ..= ' tcd: ' .. fnamemodify(getcwd(-1, 0), ":~")
  endif

  var bufnrlist = tabpagebuflist(v:lnum)
  for bufnr in bufnrlist
    tooltip ..= "\n"
    # Prefix
    if getbufvar(bufnr, "&modified")
      tooltip ..= '+ '
    endif
    # Buffer Name
    var cur_win = false
    if bufnr == bufnrlist[tabpagewinnr(v:lnum) - 1]
      cur_win = true
    endif
    if cur_win
      tooltip ..= '**'
    endif
    var cur_buf_name = bufname(bufnr)
    if empty(cur_buf_name)
      cur_buf_name = "[No Name]"
    endif
    tooltip ..= cur_buf_name
    if cur_win
      tooltip ..= '**'
    endif
    # Suffix
    var cur_filetype = getbufvar(bufnr, "&filetype")
    if cur_filetype != ''
      tooltip ..= ' [' .. cur_filetype .. ']'
    endif
    var cur_buftype = getbufvar(bufnr, "&buftype")
    if cur_buftype != ''
      tooltip ..= ' [' .. cur_buftype .. ']'
    endif
    if haslocaldir(bufwinnr(bufnr)) == 1
      tooltip ..= ' [lcd: ' .. fnamemodify(getcwd(), ":~") .. ']'
    endif
  endfor

  return tooltip
enddef
