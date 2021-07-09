scriptversion 4

aug AugPv_MenuBuffers
au!
au BufCreate,BufFilePost * call planet#buffer#AddBufferAu()
au BufDelete,BufFilePre * call planet#buffer#RemoveBufferAu()
aug END

aug AugPv_Session
au!
au SessionLoadPost * call planet#session#SetCurrent()
au VimEnter * call planet#session#MenuList()
au VimEnter * call planet#gui#MenuListVimServers()
au VimEnter * call planet#apps#WorkspaceListMenu()
au VimEnter * call planet#apps#MenuListGuiWindows()
au SessionLoadPost * call planet#run#InitRunConfigurations()
aug END
