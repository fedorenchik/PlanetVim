scriptversion 4

func! planet#windowview#Save(slot = 0) abort
  if empty(expand('%:p')) || !empty(&buftype)
    return 0
  endif
  execute 'mkview! ' .. (a:slot ? a:slot : '')
  return 1
endfunc

func! planet#windowview#Load(slot = 0) abort
  if empty(expand('%:p')) || !empty(&buftype)
    return 0
  endif
  execute 'silent! loadview ' .. (a:slot ? a:slot : '')
  return 1
endfunc

func! planet#windowview#ToggleLocalOptions() abort
  let l:options = split(&viewoptions, ',')
  if index(l:options, 'localoptions') >= 0
    call filter(l:options, 'v:val !=# "localoptions"')
  else
    call add(l:options, 'localoptions')
  endif
  let &viewoptions = join(l:options, ',')
  echo 'View local options: ' .. (index(l:options, 'localoptions') >= 0 ? 'on' : 'off')
endfunc

func! planet#windowview#ToggleAutoSave() abort
  if exists('g:PV_view_autosave')
    let g:PV_view_autosave = ! g:PV_view_autosave
  else
    let g:PV_view_autosave = v:true
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
endfunc
