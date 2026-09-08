" GVim entry point used by source checkouts and installed launchers.
set nocompatible
if has('mac') || has('macunix')
  echoerr 'PlanetVim supports Linux and Windows GVim; macOS is not supported.'
  finish
endif
if !has('gui') || !has('patch-9.1.0000')
  echoerr 'PlanetVim requires GVim 9.1 or newer.'
  finish
endif
let g:PV_root = empty($PLANETVIM_ROOT)
      \ ? fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
      \ : fnamemodify($PLANETVIM_ROOT, ':p')
" Vim 9.1's package loader adds raw paths back to runtimepath. An apostrophe
" then invokes shell wildcard expansion (and fish rejects unmatched patterns).
" Enumerate bundled packages without globbing and register escaped entries
" before loading any configuration. Vim still loads their plugin/after files.
let s:runtime = g:PV_root .. '/.vim'
let s:planet = s:runtime .. '/pack/planet/start/planet.vim'
let s:packages = []
for s:collection in sort(readdir(s:runtime .. '/pack'))
  let s:start = s:runtime .. '/pack/' .. s:collection .. '/start'
  if !isdirectory(s:start) | continue | endif
  for s:name in sort(readdir(s:start))
    if isdirectory(s:start .. '/' .. s:name)
      call add(s:packages, s:start .. '/' .. s:name)
    endif
  endfor
endfor
" First-party autoload is available to vimrc; retain every bundled package.
let s:entries = [s:planet, s:runtime] + filter(copy(s:packages), 'v:val !=# s:planet') + [$VIMRUNTIME]
for s:path in s:packages + [s:runtime]
  if isdirectory(s:path .. '/after')
    call add(s:entries, s:path .. '/after')
  endif
endfor
let &runtimepath = join(map(s:entries, 'escape(v:val, ",''")'), ',')
" Built-in optional packages remain available through :packadd. Bundled
" optional Vimspector uses planet#debug#Init(), which escapes its entry too.
let &packpath = escape($VIMRUNTIME, ",'")
let g:PV_config = planet#paths#Config() .. '/planetvimrc.vim'
execute 'source ' .. fnameescape(g:PV_root .. '/.vimrc')

" Optional browser integration must not make a clean machine fail startup.
if !executable(get(g:, 'w3m#command', 'w3m'))
  let g:loaded_w3m = 1
endif
