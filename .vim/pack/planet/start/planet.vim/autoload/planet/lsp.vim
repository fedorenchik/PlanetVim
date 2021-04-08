scriptversion 4

func! planet#lsp#UpdateFolds() abort
  set foldmethod=expr foldexpr=lsp#ui#vim#folding#foldexpr() foldtext=lsp#ui#vim#folding#foldtext()
  LspDocumentFold
endfunc
