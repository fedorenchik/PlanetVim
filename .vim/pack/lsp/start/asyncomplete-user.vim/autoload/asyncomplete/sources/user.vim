if get(g:, 'loaded_autoload_asyncomplete_sources_user')
  finish
endif
let g:loaded_autoload_asyncomplete_sources_user = 1
let s:save_cpo = &cpo
set cpo&vim

function! asyncomplete#sources#user#get_source_options(opts) abort
  return extend({
        \ 'refresh_pattern': '\%(\k\|\.\)',
        \}, a:opts)
endfunction

function! asyncomplete#sources#user#completor(opt, ctx) abort
  try
    let l:col = a:ctx['col']
    let l:typed = a:ctx['typed']

    let l:startcol = s:safe_completefunc(1, '')
    if l:startcol < 0
      return
    elseif l:startcol > l:col
      let l:startcol = l:col
    endif
    let l:base = l:typed[l:startcol : l:col]
    let l:matches = s:safe_completefunc(0, l:base)
    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol + 1, l:matches)
  catch
    call asyncomplete#log('user', 'error', v:exception)
  endtry
endfunction


function! s:safe_completefunc(...) abort
  let cursor = getpos('.')
  try
    return call(&completefunc, a:000)
  finally
    call setpos('.', cursor)
  endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
