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

aug AugPv_TabPages
au!
" Save Alternate Tab
au TabLeave * let g:PV_alternate_tab = tabpagenr('#') | let g:PV_current_tab = tabpagenr()
au TabClosed * if g:PV_alternate_tab == 0 | let g:PV_alternate_tab = tabpagenr('$') | endif
au TabClosed * if g:PV_current_tab <= g:PV_alternate_tab | let g:PV_new_tab = g:PV_alternate_tab - 1 | else | let g:PV_new_tab = g:PV_alternate_tab | endif
au TabClosed * if g:PV_new_tab < 1 | let g:PV_new_tab = 1 | endif
au TabClosed * exe 'tabnext ' .. g:PV_new_tab
" Save Closed Tab, Add Menu Entry to Reopen Closed Tab
au TabLeave * call planet#tab#SaveTmp()
aug END
