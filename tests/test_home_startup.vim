" Plain GVim must discover the installed loader through its normal home lookup.
let g:PV_test_default_gvim = 1
execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/installed_startup.vim')
