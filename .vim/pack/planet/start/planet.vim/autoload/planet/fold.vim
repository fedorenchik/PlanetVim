vim9script
export def EnableAuto(): any
  set foldclose=all
  set foldopen=all
  set foldlevel=0
  set foldlevelstart=0
  return 0
enddef

export def DisableAuto(): any
  set foldclose=
  set foldopen=quickfix,tag,undo
  set foldlevel=20
  set foldlevelstart=20
  return 0
enddef
