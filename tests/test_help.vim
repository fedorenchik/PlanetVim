execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
packloadall
set nomore
call assert_equal(2, exists(':PlanetVersion'))
call assert_equal(readfile(g:PV_root .. '/VERSION')[0], planet#version#Get())
PlanetHelp
call assert_equal('help', &filetype)
call assert_equal('planetvim.txt', expand('%:t'))
help planetvim-debug
call assert_match('DEBUGGING', getline('.'))
