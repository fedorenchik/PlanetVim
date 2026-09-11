call lsp_settings#register_server({
    \ 'name': 'moon-lsp',
    \ 'cmd': {server_info->lsp_settings#get('moon-lsp', 'cmd', [lsp_settings#exec_path('moon-lsp')]+lsp_settings#get('moon-lsp', 'args', []))},
    \ 'root_uri':{server_info->lsp_settings#get('moon-lsp', 'root_uri', lsp_settings#root_uri('moon-lsp'))},
    \ 'initialization_options': lsp_settings#get('moon-lsp', 'initialization_options', v:null),
    \ 'allowlist': lsp_settings#get('moon-lsp', 'allowlist', ['moonbit']),
    \ 'blocklist': lsp_settings#get('moon-lsp', 'blocklist', []),
    \ 'config': lsp_settings#get('moon-lsp', 'config', lsp_settings#server_config('moon-lsp')),
    \ 'workspace_config': lsp_settings#get('moon-lsp', 'workspace_config', {}),
    \ 'semantic_highlight': lsp_settings#get('moon-lsp', 'semantic_highlight', {}),
    \ })
