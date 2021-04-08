scriptversion 4

func! planet#windowview#ToggleAutoSave() abort
  if exists('g:PV_view_autosave')
    let g:PV_view_autosave = ! g:PV_view_autosave
  else
    let g:PV_view_autosave = v:true
  endif
  if g:PV_view_autosave
    aug AugPv_View_AutoSave
      au!
      au BufWinLeave * mkview 9
      au BufWinEnter * silent loadview 9
    aug END
    echo "AutoSave Views"
  else
    aug AugPv_View_AutoSave
      au!
    aug END
    echo "Do not AutoSave Views"
  endif
endfunc
