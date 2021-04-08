scriptversion 4

func! planet#edit#SelectAll()
  exe "norm! gg" . (&slm == "" ? "VG" : "gH\<C-O>G")
endfunc
