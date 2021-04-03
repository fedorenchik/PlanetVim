scriptversion 4

" direction can be 'v' or 'h'
func! planet#util#window#SplitBind(direction) abort
  set noscrollbind
  if a:direction == 'v'
    vsplit
  else
    split
  endif
  wincmd w
  normal z+
  set scrollbind
  wincmd W
  set scrollbind
endfunc

func! planet#util#window#Maximize() abort
  let g:PV_win_restore_cmd = winrestcmd()
  wincmd _
  wincmd |
endfunc

func! planet#util#window#Restore() abort
  if exists('g:PV_win_restore_cmd')
    exe g:PV_win_restore_cmd
    "FIXME: Remove second exe call after vim bug #7988 is fixed
    exe g:PV_win_restore_cmd
  endif
endfunc

func! planet#util#window#Focus(direction)
  exe 'wincmd ' .. a:direction
  if empty(&buftype) || &buftype == 'nowrite' || &buftype == 'acwrite'
    let win_width = 80
    if &textwidth > 0
      let win_width = &textwidth
    elseif str2nr(&colorcolumn) > 0
      let win_width = str2nr(&colorcolumn)
    endif
    let win_width += &foldcolumn
    if &number || &relativenumber
      let win_width += &numberwidth
    endif
    if &signcolumn == 'yes' || &signcolumn == 'auto'
      let win_width += 2
    endif
    echo 'win_width=' .. win_width
    let number_of_windows = tabpagewinnr(tabpagenr(), '$')
    let other_win_widh = (&columns - win_width) / number_of_windows
    if other_win_widh <= 0
      let other_win_widh = 1
    endif
    let owmw = &wmw
    let owiw = &wiw
    exe "set wiw=" .. other_win_widh .. " wmw=" .. other_win_widh
    if win_width > winwidth(0)
      exe win_width .. 'wincmd |'
    endif
    let &wmw = owmw
    let &wiw = owiw
  endif
endfunc
