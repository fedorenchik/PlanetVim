execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call assert_true(exists('g:loaded_planet_vim_globals'))
call assert_equal('s', g:PV_mode)
call assert_false(&insertmode)
call assert_equal(g:PV_config_dir .. '/planetvimrc.vim', g:PV_config)
call assert_match(escape(g:PV_root, '\'), &runtimepath)
set nomore
