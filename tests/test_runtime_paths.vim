" Real plugin/autoload/spell lookups under a copied installation with quotes.
" Reproduce the former Windows override for the isolated autoload check:
" default isfname alone misses the escaped-apostrophe interpretation bug.
set isfname+=39,128-255
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
      \ 'planet/start/planet.vim': ['autoload', 'plugin', 'data', 'python3'],
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
call s:CopyTree(s:root .. '/tests/helpers', s:quoted .. '/tests/helpers')
let s:entry = planet#paths#Runtime(s:quoted .. '/.vim/pack/planet/start/planet.vim')
let &runtimepath = s:entry .. ',' .. planet#paths#Runtime($VIMRUNTIME)
let &packpath = planet#paths#Runtime($VIMRUNTIME)
let g:PV_root = s:quoted
let g:PV_config_dir = g:PV_test_dir .. "/config, 'quoted' 工作"
let g:PV_state_dir = g:PV_test_dir .. "/state, 'quoted' 工作"
let g:PV_cache_dir = g:PV_test_dir .. "/cache, 'quoted' 工作"
call assert_true(isdirectory(planet#paths#Config()))
call assert_true(isdirectory(planet#paths#State()))
" Force the former Windows setting just for an autoload lookup, then restore
" native Windows rules before exercising fnameescape() source/edit commands.
call planet#writing#SetSpellFile('', v:false)
if has('win32') | set isfname-=39 | endif
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
  py3 import builtins
  py3 _pv_runtime_test_bytecode = sys.dont_write_bytecode
  py3 _pv_runtime_test_import = builtins.__import__
  py3 << EOF
def _pv_runtime_failed_bridge(name, *args, **kwargs):
    if name == 'planetvim_debug':
        raise ImportError('isolated quoted-path bridge fixture failure')
    return _pv_runtime_test_import(name, *args, **kwargs)
builtins.__import__ = _pv_runtime_failed_bridge
EOF
  try
    call assert_equal(0, planet#debug#Detach(), 'failed bridge import is reported')
  finally
    py3 builtins.__import__ = _pv_runtime_test_import
    py3 del _pv_runtime_failed_bridge, _pv_runtime_test_import
  endtry
  call assert_true(py3eval('sys.path == _pv_runtime_test_path and sys.dont_write_bytecode == _pv_runtime_test_bytecode'), 'failed bridge import restores Python settings')
  call assert_equal(0, planet#debug#Detach(), 'bridge rejects detach without an active session')
  call assert_equal(substitute(s:quoted .. '/.vim/pack/planet/start/planet.vim/python3/planetvim_debug.py', '\\', '/', 'g'),
        \ substitute(py3eval('planetvim_debug.__file__'), '\\', '/', 'g'), 'first-party detach bridge loads from the copied quoted installation')
  call assert_true(py3eval('sys.path == _pv_runtime_test_path and sys.dont_write_bytecode == _pv_runtime_test_bytecode'), 'successful bridge import restores Python settings')
  py3 del _pv_runtime_test_path, _pv_runtime_test_bytecode
endif
" A literal launch site visible only by scanning the copied autoload tree.
call writefile(["call planet#term#RunArgv(['planetvim-inventory-fixture'])"],
      \ s:quoted .. '/.vim/pack/planet/start/planet.vim/autoload/planet/inventory_fixture.vim')
let s:checks = planet#health#Check()
let s:names = map(copy(s:checks), {_, item -> item.name})
call assert_true(index(s:names, 'Tool: planetvim-inventory-fixture') >= 0, 'Doctor finds command launch sites below a quoted runtime')
