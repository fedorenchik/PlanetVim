vim9script
export def SelectAll(): any
  exe "norm! gg" .. (&slm == "" ? "VG" : "gH\<C-O>G")
  return 0
enddef
