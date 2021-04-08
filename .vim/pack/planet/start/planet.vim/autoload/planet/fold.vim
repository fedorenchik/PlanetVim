scriptversion 4

func! planet#fold#EnableAuto() abort
  set foldclose=all
  set foldopen=all
  set foldlevel=0
  set foldlevelstart=0
endfunc

func! planet#fold#DisableAuto() abort
  set foldclose=
  set foldopen=quickfix,tag,undo
  set foldlevel=20
  set foldlevelstart=20
endfunc
