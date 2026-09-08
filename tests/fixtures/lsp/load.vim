" Load only the pinned language client and its completion sources.
for s:dependency in ['vim-lsp', 'asyncomplete.vim', 'asyncomplete-lsp.vim', 'asyncomplete-buffer.vim', 'asyncomplete-file.vim']
  let &runtimepath ..= ',' .. g:PV_root .. '/.vim/pack/lsp/start/' .. s:dependency
endfor
let g:lsp_use_lua = 0
let g:lsp_auto_enable = 0
let g:lsp_async_completion = 1
let g:lsp_format_sync_timeout = 10000
let g:lsp_show_workspace_edits = 0
let g:lsp_fold_enabled = 0
let g:lsp_signature_help_enabled = 0
let g:lsp_diagnostics_echo_cursor = 0
let g:lsp_diagnostics_float_cursor = 0
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect
filetype plugin on
runtime plugin/lsp.vim
runtime plugin/asyncomplete.vim
runtime plugin/asyncomplete-lsp.vim
runtime plugin/intelligence.vim
call lsp#enable()
call asyncomplete#enable_for_buffer()
set hidden
