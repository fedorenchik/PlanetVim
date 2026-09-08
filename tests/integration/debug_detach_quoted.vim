" Exercise the real DAP disconnect bridge from the copied quoted installation.
let s:original_root = g:PV_root
execute 'source ' .. fnameescape(s:original_root .. '/tests/test_runtime_paths.vim')
let g:PV_debug_test_language = 'python'
execute 'source ' .. fnameescape(s:original_root .. '/tests/helpers/debug_detach.vim')
