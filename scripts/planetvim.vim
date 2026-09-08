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
let &runtimepath = escape(g:PV_root .. '/.vim', ',') .. ',' .. $VIMRUNTIME
      \ .. ',' .. escape(g:PV_root .. '/.vim/after', ',')
let &packpath = &runtimepath
" Make PlanetVim's autoload API available before package initialization.
let &runtimepath = escape(g:PV_root .. '/.vim/pack/planet/start/planet.vim', ',') .. ',' .. &runtimepath
let g:PV_config = planet#paths#Config() .. '/planetvimrc.vim'
execute 'source ' .. fnameescape(g:PV_root .. '/.vimrc')

" Optional browser integration must not make a clean machine fail startup.
if !executable(get(g:, 'w3m#command', 'w3m'))
  let g:loaded_w3m = 1
endif
