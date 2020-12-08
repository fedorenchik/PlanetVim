" libviewPlugin.vim
"   Author: Charles E. Campbell
"   Date:   Apr 22, 2008
"   Version: 1l	NOT RELEASED
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_libviewPlugin") || !executable("nm")
 finish
endif
let g:loaded_libviewPlugin = "v1l"
let s:keepcpo              = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Public Interface: {{{1
augroup AuCmdLibFile
 au!
 au BufReadCmd   *.a		call libview#ABrowse(expand("<amatch>"))
 au BufReadCmd   *.o		call libview#OBrowse(expand("<amatch>"))
 au BufReadCmd   *.so		call libview#SOBrowse(expand("<amatch>"))
augroup END

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
