vim9script
export def UpdateFolds(): any
  set foldmethod=expr foldexpr=lsp#ui#vim#folding#foldexpr() foldtext=lsp#ui#vim#folding#foldtext()
  execute 'LspDocumentFold'
  return 0
enddef
