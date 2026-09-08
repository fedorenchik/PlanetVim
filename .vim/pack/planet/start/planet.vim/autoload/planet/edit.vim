scriptversion 4

func! planet#edit#SelectAll() abort
  exe "norm! gg" .. (&slm == "" ? "VG" : "gH\<C-O>G")
endfunc
