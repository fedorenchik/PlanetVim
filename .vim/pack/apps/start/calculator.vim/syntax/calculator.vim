" Vim syntax file
" Language:	calculator
" Maintainer:	Leonid V. Fedorenchik <leonid@fedorenchik.com>
" Last Change:	2018 Dec 7


" quit when a syntax file was already loaded.
if exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

syn match calculatorComment "#.*$"

syn keyword calculatorConstant _ e pi phi

syn keyword calculatorFunction abs acos asin atan atan2 ceil choose cos cosh deg
syn keyword calculatorFunction exp floor hypot inv ldexp lg ln log log10 max min
syn keyword calculatorFunction nrt perms pow rad rand round sin sinh sqrt tan
syn keyword calculatorFunction tanh
syn keyword calculatorFunction hex oct bin dec int float status vars

syn keyword calculatorQuit exit quit

hi def link calculatorComment Comment
hi def link calculatorConstant Constant
hi def link calculatorFunction Function
hi def link calculatorQuit Keyword

let b:current_syntax = "calculator"

let &cpo = s:cpo_save
unlet s:cpo_save
