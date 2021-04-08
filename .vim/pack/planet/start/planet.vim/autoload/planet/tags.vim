scriptversion 4

func! planet#tags#ToggleAutoPreview() abort
  if exists('g:PV_tags_auto_preview')
    let g:PV_tags_auto_preview = ! g:PV_tags_auto_preview
  else
    let g:PV_tags_auto_preview = v:true
  endif
  if g:PV_tags_auto_preview
    aug AUG_PV_TagsPreview
      au!
      au! CursorHold * ++nested call PreviewWord()
    aug END
    echo "AutoPreview Tags"
  else
    aug AUG_PV_TagsPreview
      au!
    aug END
    echo "Do not AutoPreview Tags"
  endif
endfunc
