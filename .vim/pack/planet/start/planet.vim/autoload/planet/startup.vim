vim9script

export def DeferLanguage()
  if !exists('g:lsp_auto_enable')
    g:lsp_auto_enable = 0
    g:PV_lsp_deferred = true
  endif
enddef

export def Language()
  if !get(g:, 'PV_lsp_deferred', false) || empty(&filetype) || &buftype !=# ''
    return
  endif
  g:PV_lsp_deferred = false
  lsp#enable()
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
