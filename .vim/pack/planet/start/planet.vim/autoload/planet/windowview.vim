vim9script
export def Save(slot: any = 0): any
  if empty(expand('%:p')) || !empty(&buftype)
    return 0
  endif
  execute 'mkview! ' .. (slot != 0 ? slot : '')
  return 1
enddef

export def Load(slot: any = 0): any
  if empty(expand('%:p')) || !empty(&buftype)
    return 0
  endif
  execute 'silent! loadview ' .. (slot != 0 ? slot : '')
  return 1
enddef

export def ToggleLocalOptions(): any
  var options: any = split(&viewoptions, ',')
  if index(options, 'localoptions') >= 0
    filter(options, (_, option) => option !=# 'localoptions')
  else
    add(options, 'localoptions')
  endif
  &viewoptions = join(options, ',')
  echo 'View local options: ' .. (index(options, 'localoptions') >= 0 ? 'on' :  'off')
  return 0
enddef

export def ToggleAutoSave(): any
  if exists('g:PV_view_autosave')
    g:PV_view_autosave = ! g:PV_view_autosave
  else
    g:PV_view_autosave = v:true
  endif
  if g:PV_view_autosave
    aug AugPv_View_AutoSave
    au!
    au BufWinLeave * call planet#windowview#Save(9)
    au BufWinEnter * call planet#windowview#Load(9)
    aug END
    echo "AutoSave Views"
  else
    aug AugPv_View_AutoSave
    au!
    aug END
    echo "Do not AutoSave Views"
  endif
  return 0
enddef
