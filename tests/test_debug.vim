runtime plugin/development.vim
let s:root = g:PV_test_dir .. '/debug config project'
call mkdir(s:root, 'p')
execute 'tcd ' .. fnameescape(s:root)
call assert_equal(2, exists(':PlanetDebug'))
call assert_equal(2, exists(':PlanetDebugSetup'))
call assert_equal(0, planet#debug#Action('not-an-action'))
call assert_equal(0, planet#debug#Action('launch'))
call assert_equal(0, planet#debug#Action('detach'))
call assert_equal({}, planet#debug#Configuration('unknown'))
call assert_equal(1, planet#debug#Setup('python'))
let s:config = json_decode(join(readfile(s:root .. '/.vimspector.json'), "\n"))
call assert_equal('launch', s:config.configurations.Python.configuration.request)
call assert_equal('${file}', s:config.configurations.Python.configuration.program)
call assert_equal(0, planet#debug#Setup('cpp'), 'never overwrite project debug configurations')
call assert_equal(s:config, json_decode(join(readfile(s:root .. '/.vimspector.json'), "\n")))
let s:cpp = planet#debug#Configuration('cpp', s:root .. '/build/app')
call assert_equal(['gdb', '--quiet', '--nx', '--interpreter=dap'], s:cpp.adapters['planet-gdb'].command)
call assert_equal(s:root .. '/build/app', s:cpp.configurations['C++'].configuration.program)
let s:config.adapters['planet-debugpy'].command = ['planetvim_missing_debug_adapter']
call writefile([json_encode(s:config)], s:root .. '/.vimspector.json')
call assert_equal(0, planet#debug#Action('launch'), 'missing tool rejected before opening debug UI')
call writefile(['invalid json'], s:root .. '/.vimspector.json')
call assert_equal(0, planet#debug#Action('launch'))

if has('python3')
  py3 import logging, os, hashlib, importlib
  py3 _pv_test_constructor = logging.FileHandler
  py3 _pv_test_log = os.path.expanduser('~/.vimspector.log')
  py3 _pv_test_before = (os.stat(_pv_test_log).st_mtime_ns, hashlib.sha256(open(_pv_test_log, 'rb').read()).hexdigest()) if os.path.exists(_pv_test_log) else None
  let s:home = $HOME
  " A failed import must restore the constructor just as a successful one does.
  py3 _pv_test_import = importlib.import_module
  py3 << EOF
def _pv_test_failed_import(name, *args, **kwargs):
    if name == 'vimspector.utils':
        raise ImportError('isolated fixture failure')
    return _pv_test_import(name, *args, **kwargs)
importlib.import_module = _pv_test_failed_import
EOF
  try
    call assert_equal(0, planet#debug#Init())
  finally
    py3 importlib.import_module = _pv_test_import
    py3 del _pv_test_failed_import, _pv_test_import
  endtry
  call assert_true(py3eval('logging.FileHandler is _pv_test_constructor'))
  call assert_true(py3eval("'_pv_import_utils' not in globals()"))
  call assert_equal(1, planet#debug#Init())
  call assert_equal(s:home, $HOME)
  call assert_true(py3eval('logging.FileHandler is _pv_test_constructor'))
  call assert_true(py3eval("'_pv_import_utils' not in globals()"))
  call assert_equal(planet#paths#State('debugger') .. '/vimspector.log', py3eval("__import__('vimspector.utils', fromlist=['']).LOG_FILE"))
  call assert_equal(planet#paths#State('debugger') .. '/vimspector.log', py3eval("__import__('vimspector.utils', fromlist=[''])._log_handler.baseFilename"))
  py3 _pv_test_after = (os.stat(_pv_test_log).st_mtime_ns, hashlib.sha256(open(_pv_test_log, 'rb').read()).hexdigest()) if os.path.exists(_pv_test_log) else None
  call assert_true(py3eval('_pv_test_before == _pv_test_after'), 'user log must not be created or truncated')
  call assert_equal(1, planet#debug#Init(), 'repeated initialization is safe')
endif
