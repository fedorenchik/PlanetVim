" Real plugin/autoload/spell lookups under a copied installation with quotes.
func! s:CopyTree(source, target) abort
  call mkdir(a:target, 'p')
  for l:name in readdir(a:source)
    let l:source = a:source .. '/' .. l:name
    let l:target = a:target .. '/' .. l:name
    if isdirectory(l:source)
      if l:name !=# '__pycache__' | call s:CopyTree(l:source, l:target) | endif
    elseif getftype(l:source) ==# 'file'
      call writefile(readblob(l:source), l:target)
    endif
  endfor
endfunc
let s:root = g:PV_root
let s:quoted = g:PV_test_dir .. "/installed prefix, 'quoted' 工作"
let s:packages = {
      \ 'planet/start/planet.vim': ['autoload', 'plugin', 'data'],
      \ 'writing/start/vim-autocorrect': ['plugin'],
      \ 'writing/start/vim-wordy': ['autoload', 'plugin', 'data'],
      \ 'basic/start/vim-test': ['autoload', 'plugin'],
      \ 'apps/opt/vimspector': ['autoload', 'plugin', 'python3'],
      \ }
for [s:package, s:directories] in items(s:packages)
  for s:directory in s:directories
    let s:relative = '/.vim/pack/' .. s:package .. '/' .. s:directory
    call s:CopyTree(s:root .. s:relative, s:quoted .. s:relative)
  endfor
endfor
let s:entry = planet#paths#Runtime(s:quoted .. '/.vim/pack/planet/start/planet.vim')
let &runtimepath = s:entry .. ',' .. planet#paths#Runtime($VIMRUNTIME)
let &packpath = planet#paths#Runtime($VIMRUNTIME)
let g:PV_root = s:quoted
let g:PV_config_dir = g:PV_test_dir .. "/config, 'quoted' 工作"
let g:PV_state_dir = g:PV_test_dir .. "/state, 'quoted' 工作"
let g:PV_cache_dir = g:PV_test_dir .. "/cache, 'quoted' 工作"
call assert_true(isdirectory(planet#paths#Config()))
call assert_true(isdirectory(planet#paths#State()))
call assert_equal(1, planet#prose#AutoCorrect())
call assert_equal('the', maparg('teh', 'i', 1))
call assert_equal(['', ''], spellbadword('very'))
call assert_equal(1, planet#prose#Proofread('weak'))
call assert_true(filereadable(g:wordy_spell_dir .. '/spell/weak.utf-8.spl'))
call assert_equal(['very', 'bad'], spellbadword('very'), 'proofreading cache is actually loaded')
call assert_equal(1, planet#prose#Proofread('off'))
let s:runtime = &runtimepath
call assert_equal(1, planet#prose#Proofread('weak'))
call assert_equal(s:runtime, &runtimepath, 'repeated loading does not duplicate escaped entries')
call assert_equal(1, planet#prose#Proofread('off'))
call assert_equal(1, planet#test#Init())
call assert_true(exists(':TestFile') == 2)
call assert_true(test#base#file_exists(s:quoted .. '/.vim/pack/basic/start/vim-test/plugin/test.vim'))
if has('python3')
  py3 import sys
  py3 _pv_runtime_test_path = sys.path[:]
  let s:debug_ready = planet#debug#Init()
  call assert_equal(1, s:debug_ready, execute('messages'))
  call assert_true(exists(':VimspectorReset') == 2)
  call assert_true(py3eval('sys.path == _pv_runtime_test_path'), 'debug initialization restores Python import paths')
  py3 del _pv_runtime_test_path
endif
" A literal launch site visible only by scanning the copied autoload tree.
call writefile(["call planet#term#RunArgv(['planetvim-inventory-fixture'])"],
      \ s:quoted .. '/.vim/pack/planet/start/planet.vim/autoload/planet/inventory_fixture.vim')
let s:checks = planet#health#Check()
let s:names = map(copy(s:checks), {_, item -> item.name})
call assert_true(index(s:names, 'Tool: planetvim-inventory-fixture') >= 0, 'Doctor finds command launch sites below a quoted runtime')
