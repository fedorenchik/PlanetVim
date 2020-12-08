" =============================================================================
" Filename: autoload/calendar/view/month_1x1.vim
" Author: itchyny
" License: MIT License
" Last Change: 2015/03/29 06:33:26.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! calendar#view#month_1x1#new(source) abort
  return s:constructor.new(a:source)
endfunction

let s:self = {}
let s:self.x_months = 1
let s:self.y_months = 1

let s:constructor = calendar#constructor#view_months#new(s:self)

let &cpo = s:save_cpo
unlet s:save_cpo
