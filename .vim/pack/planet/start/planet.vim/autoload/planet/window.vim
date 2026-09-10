vim9script
# direction can be 'v' or 'h'
export def SplitBind(direction: any): any
  set noscrollbind
  if direction == 'v'
    vsplit
  else
    split
  endif
  wincmd w
  normal z+
  set scrollbind
  wincmd W
  set scrollbind
  if direction == 'v'
    wincmd l
  else
    wincmd j
  endif
  wincmd =
  return 0
enddef

export def Maximize(): any
  g:PV_win_restore_cmd = winrestcmd()
  wincmd _
  wincmd |

  return 0
enddef

export def Restore(): any
  if exists('g:PV_win_restore_cmd')
    exe g:PV_win_restore_cmd
    #FIXME: Remove second exe call after vim bug #7988 is fixed
    exe g:PV_win_restore_cmd
  endif
  return 0
enddef

export def Focus(direction: any): any
  var win_width: any
  var number_of_windows: any
  var other_win_widh: any
  var owmw: any
  var owiw: any
  exe 'wincmd ' .. direction
  if empty(&buftype) || &buftype == 'nowrite' || &buftype == 'acwrite' || &buftype == 'help'
    win_width = 80
    if &textwidth > 0
      win_width = &textwidth
    elseif str2nr(&colorcolumn) > 0
      win_width = str2nr(&colorcolumn)
    endif
    win_width += &foldcolumn
    if &number || &relativenumber
      win_width += &numberwidth
    endif
    if &signcolumn == 'yes' || &signcolumn == 'auto'
      win_width += 2
    endif
    echo 'win_width=' .. win_width
    number_of_windows = tabpagewinnr(tabpagenr(), '$')
    other_win_widh = (&columns - win_width) / number_of_windows
    if other_win_widh <= 0
      other_win_widh = 1
    endif
    owmw = &wmw
    owiw = &wiw
    exe "set wiw=" .. other_win_widh .. " wmw=" .. other_win_widh
    if win_width > winwidth(0)
      exe ':' .. win_width .. 'wincmd |'
    endif
    normal zH
    &wmw = owmw
    &wiw = owiw
  endif
  return 0
enddef
