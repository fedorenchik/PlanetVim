vim9script

export def LoadStatusline()
  if fnamemodify(&shell, ':t') !=# 'fish' || exists('*crystalline#InitStatusline')
    return
  endif
  # Crystalline sources its optimized module with an unescaped filename.
  # Vim expands apostrophes through a POSIX shell function, invalid in Fish.
  # Preload only that module with a compatible shell; keep user shell settings.
  var saved = [&shell, &shellcmdflag, &shellquote, &shellxquote]
  try
    set shell=/bin/sh shellcmdflag=-c shellquote= shellxquote=
    runtime autoload/crystalline.vim
  finally
    [&shell, &shellcmdflag, &shellquote, &shellxquote] = saved
  endtry
enddef

export def DeferLanguage()
  if !exists('g:lsp_auto_enable')
    g:lsp_auto_enable = 0
    g:PV_lsp_deferred = true
  endif
enddef

export def Language()
  if empty(&filetype) || &buftype !=# ''
    return
  endif
  if get(g:, 'PV_lsp_deferred', false)
    g:PV_lsp_deferred = false
    lsp#enable()
  elseif exists('#lsp#BufReadPost')
    # vim-lsp now handles FileType only for unnamed buffers. A named file
    # whose type is set after BufRead still needs its eligible servers attached.
    lsp#ensure_flush_all(bufnr(), lsp#get_allowed_servers())
  endif
enddef

export def ConfigureShell()
  # :terminal starts &shell without &shellcmdflag, retaining interactive Fish
  # configuration. Honor explicit flags and allow opting out in planetvimrc.
  if has('linux') && get(g:, 'PV_fast_shell', 1)
      && fnamemodify(&shell, ':t') ==# 'fish' && &shellcmdflag ==# '-c'
    &shellcmdflag = '--no-config -c'
  endif
enddef

export def NearestSymbol()
  if &buftype !=# '' || empty(&filetype) || empty(expand('%:p'))
      || exists('#VistaMOF') || !exists(':Vista')
    return
  endif
  if get(g:, 'vista_default_executive', 'ctags') ==# 'ctags'
      && !executable(get(g:, 'vista_ctags_cmd', 'ctags'))
    return
  endif
  vista#RunForNearestMethodOrFunction()
enddef

export def MarkdownPreview()
  var package = get(g:, 'PV_markdown_preview_package', '')
  if empty(package) || exists('*Vim_Markdown_Preview')
    return
  endif
  execute 'source ' .. fnameescape(package .. '/plugin/vim-markdown-preview.vim')
enddef
