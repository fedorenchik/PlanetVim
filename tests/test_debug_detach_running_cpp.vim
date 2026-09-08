let g:PV_debug_test_language = 'cpp'
let g:PV_debug_test_running = v:true
execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/debug_detach.vim')
