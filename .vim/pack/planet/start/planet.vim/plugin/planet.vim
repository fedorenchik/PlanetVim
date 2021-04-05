scriptversion 4

aug AugPv_MenuBuffers
au!
au BufCreate,BufFilePost * call planet#buffer#AddBufferAu()
au BufDelete,BufFilePre * call planet#buffer#RemoveBufferAu()
aug END
