if get(g:, 'loaded_autoload_asyncomplete_sources_emmet')
  finish
endif
let g:loaded_autoload_asyncomplete_sources_emmet = 1
let s:save_cpo = &cpo
set cpo&vim

function! asyncomplete#sources#emmet#get_source_options(opts) abort
  return extend({
        \ 'refresh_pattern': '\%(\k\|\.\)',
        \}, a:opts)
endfunction

function! asyncomplete#sources#emmet#completor(opt, ctx) abort
  let l:col = a:ctx['col']
  let l:typed = a:ctx['typed']

  let l:startcol = emmet#completeTag(1, '')
  if l:startcol < 0
	return
  elseif l:startcol > l:col
	let l:startcol = l:col
  endif
  let l:base = l:typed[l:startcol : l:col]
  let l:matches = emmet#completeTag(0, l:base)
  call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol + 1, l:matches)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
