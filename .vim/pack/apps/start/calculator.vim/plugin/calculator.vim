" calculator.vim - Calculator inside Vim
" Maintainer:   Leonid V. Fedorenchik <leonid@fedorenchik.com>
" Version:      1.0

if has('vimscript-3')
  scriptversion 3
else
  echomsg 'Calculator: Requires Vim Script version >= 3'
  finish
endif

if v:version < 801
  echomsg 'Calculator: Requires Vim version >= 8.1'
  finish
endif

if &cp
  echomsg 'Calculator: nocompatible must be set'
  finish
endif

if exists('g:loaded_calculator') || &cp || v:version < 801
  echomsg 'Calculator: Already loaded'
  finish
endif
let g:loaded_calculator = 1

if !exists("g:calculator_prompt")
    let g:calculator_prompt = "> "
endif

command -nargs=0 Calculator call calculator#CalculatorOpen()
