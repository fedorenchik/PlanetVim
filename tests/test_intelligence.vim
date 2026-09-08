let g:PV_clangd_argv = [g:PV_test_dir .. '/missing-clangd']
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')
call assert_equal([], lsp#get_server_names())
call assert_equal('executable missing', planet#intelligence#Status().clangd.status)
call assert_equal('disabled', planet#intelligence#Status().pylsp.status)
let g:PV_clangd_argv = 'clangd --background-index'
call assert_match('invalid command', planet#intelligence#Status().clangd.status)
call planet#intelligence#Register()
call assert_equal([], lsp#get_server_names())
call planet#intelligence#CompletionSources()
call planet#intelligence#CompletionSources()
call assert_equal(['planet-buffer', 'planet-file'], sort(asyncomplete#get_source_names()))

execute 'edit ' .. fnameescape(g:PV_test_dir .. '/sample.cpp')
setfiletype cpp
call assert_match('LspDefinition', maparg('gd', 'n'))
call assert_equal(1, maparg('gd', 'n', 0, 1).buffer)
call assert_equal(0, planet#intelligence#Action('LspDefinition'))
let s:before = len(b:PV_intelligence_maps)
call planet#intelligence#SetupBuffer()
call assert_equal(s:before, len(b:PV_intelligence_maps))
let s:omnifunc = &l:omnifunc
call planet#intelligence#Attach()
call assert_equal('lsp#complete', &l:omnifunc)
call planet#intelligence#Undo()
call assert_equal(s:omnifunc, &l:omnifunc)
call assert_equal('', maparg('gd', 'n'))
nnoremap <buffer> gd :let b:custom_definition = 1<CR>
call planet#intelligence#SetupBuffer()
call planet#intelligence#Undo()
call assert_match('custom_definition', maparg('gd', 'n'))

let s:project = g:PV_test_dir .. '/language project'
call mkdir(s:project .. '/src', 'p')
call writefile(['-std=c++17'], s:project .. '/compile_flags.txt')
call assert_equal(lsp#utils#path_to_uri(s:project), planet#intelligence#Root('clangd', s:project .. '/src/one.cpp'))
call writefile(['[project]', 'name = "fixture"'], g:PV_test_dir .. '/pyproject.toml')
call assert_equal(lsp#utils#path_to_uri(g:PV_test_dir), planet#intelligence#Root('pylsp', g:PV_test_dir .. '/single.py'))
