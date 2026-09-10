vim9script noclear
command! PlanetLspStatus call planet#intelligence#ShowStatus()
command! PlanetLspSetup call planet#intelligence#Register()
command! PlanetDefinition call planet#intelligence#Action('LspDefinition')
command! PlanetReferences call planet#intelligence#Action('LspReferences')
command! PlanetHover call planet#intelligence#Action('LspHover')
command! PlanetRename call planet#intelligence#Action('LspRename')
command! PlanetFormat call planet#intelligence#Action('LspDocumentFormatSync')
command! PlanetDiagnostics call planet#intelligence#Action('LspDocumentDiagnostics')
command! PlanetSemanticScopes call planet#semantic#Show()

augroup PlanetVimIntelligence
  autocmd!
  autocmd VimEnter,BufEnter * call planet#completion#Buffer()
  autocmd TextChanged,TextChangedI,InsertEnter * call planet#lsp_display#Invalidate()
  autocmd CursorHold,InsertLeave,BufEnter * call planet#lsp_display#Hints()
  autocmd User lsp_buffer_enabled call planet#lsp_display#Hints()
  autocmd User lsp_diagnostics_updated call planet#lsp_display#Inline()
  autocmd VimEnter,BufEnter * call planet#lsp_display#Inline()
  autocmd User lsp_setup call planet#intelligence#Register()
  autocmd User asyncomplete_setup call planet#intelligence#CompletionSources()
  autocmd User lsp_buffer_enabled call planet#intelligence#Attach()
  autocmd VimEnter,FileType * call planet#startup#Language()
  autocmd FileType c,cpp,python call planet#intelligence#SetupBuffer()
augroup END
