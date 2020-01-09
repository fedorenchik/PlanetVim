" Plugin: coc.nvim {{{
call coc#config('languageserver', {
			\ 'ccls': {
			\   "command": "ccls",
			\   "trace.server": "verbose",
			\   "filetypes": ["c", "cpp", "objc", "objcpp"]
			\ }
			\})
" }}}
