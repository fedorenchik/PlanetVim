" GVim entry point used by source checkouts and installed launchers.
set nocompatible
if has('mac') || has('macunix')
  echoerr 'PlanetVim supports Linux and Windows GVim; macOS is not supported.'
  finish
endif
if !has('gui') || !has('patch-9.1.0016')
  echoerr 'PlanetVim requires GVim 9.1.0016 or newer.'
  finish
endif
" Keep the feature check readable by older Vim before it encounters Vim9.
" Everything after that bootstrap is a compiled Vim9 function.
def! s:Configure()
  g:PV_root = empty($PLANETVIM_ROOT)
      ? fnamemodify(resolve(expand('<script>:p')), ':h:h')
      : fnamemodify($PLANETVIM_ROOT, ':p')
  # Vim 9.1's package loader adds raw paths back to runtimepath. Register
  # escaped entries first so spaces, apostrophes and commas remain literal.
  var runtime = g:PV_root .. '/.vim'
  var planet = runtime .. '/pack/planet/start/planet.vim'
  var packages: list<string> = []
  for collection in sort(readdir(runtime .. '/pack'))
    var start = runtime .. '/pack/' .. collection .. '/start'
    if !isdirectory(start)
      continue
    endif
    for name in sort(readdir(start))
      if isdirectory(start .. '/' .. name)
        if name ==# 'vim-markdown-preview'
          # The main Markdown action uses PlanetVim's Pandoc integration.
          # Keep the old public preview functions available on first use.
          g:PV_markdown_preview_package = start .. '/' .. name
          continue
        endif
        add(packages, start .. '/' .. name)
      endif
    endfor
  endfor
  var entries = [planet, runtime]
      + filter(copy(packages), (_, package) => package !=# planet) + [$VIMRUNTIME]
  for path in packages + [runtime]
    if isdirectory(path .. '/after')
      add(entries, path .. '/after')
    endif
  endfor
  var path_escapes = has('win32') ? ',' : ",'"
  &runtimepath = join(map(entries, (_, path) => escape(path, path_escapes)), ',')
  # Built-in optional packages remain available through :packadd.
  &packpath = escape($VIMRUNTIME, path_escapes)
  g:PV_config = planet#paths#Config() .. '/planetvimrc.vim'
  execute 'source ' .. fnameescape(g:PV_root .. '/.vimrc')
  if !executable(get(g:, 'w3m#command', 'w3m'))
    g:loaded_w3m = 1
  endif
  augroup PlanetDeferredPreview
    autocmd!
    autocmd FuncUndefined Vim_Markdown_Preview,Vim_Markdown_Preview_Local call planet#startup#MarkdownPreview()
  augroup END
enddef
call s:Configure()
