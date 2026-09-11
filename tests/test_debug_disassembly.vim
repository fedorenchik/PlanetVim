let g:PV_debug_test_language = 'cpp'
let g:PV_debug_test_disassembly = 1
execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/debug_lifecycle.vim')
