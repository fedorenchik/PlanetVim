" libview.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Aug 12, 2008
"   Version: 1a	NOT RELEASED
" ---------------------------------------------------------------------

" Syntax Clearing: {{{1
if version < 600
 syntax clear
elseif exists("b:current_syntax")
 finish
endif

" Archive/Object Listing Banner
syn match libviewBanner		'^".*$'
syn match libviewBanner		'^\s*\S\+\ze:'
syn match libviewCategory	'\%(Global Func\)\|\%(Internal Func\)\|\%(Global Var\)'
syn match libviewFoldMarker	'{{{\d'

" ---------------------------------------------------------------------
" Highlighting Links: {{{1
if !exists("did_drchip_libview_syntax")
 let did_drchip_libview_syntax= 1
 hi default link libviewBanner		Comment
 hi default link libviewCategory	Function
 hi default link libviewFoldMarker	Ignore
endif

" Current Syntax: {{{1
let b:current_syntax = "libview"
" vim: ts=4 fdm=marker
