scriptversion 4

func! s:Warn(message) abort
  echohl WarningMsg
  echom 'PlanetVim debugger: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#debug#Init() abort
  if get(s:, 'ready', v:false)
    return 1
  endif
  if !has('python3')
    return s:Warn('GVim needs +python3 support and its matching Python runtime.')
  endif
  let l:path = planet#paths#Root() .. '/.vim/pack/apps/opt/vimspector'
  if !filereadable(l:path .. '/plugin/vimspector.vim')
    return s:Warn('bundled Vimspector is missing.')
  endif
  let g:vimspector_base_dir = get(g:, 'vimspector_base_dir', planet#paths#State('debugger'))
  let l:log = planet#paths#State('debugger') .. '/vimspector.log'
  let &runtimepath = planet#paths#Runtime(l:path) .. ',' .. &runtimepath
  try
    " Pinned and current upstream open ~/.vimspector.log in write mode on
    " import, with no path setting. Redirect exactly that constructor once;
    " never change HOME or leave a logging constructor installed globally.
    py3 << EOF
import importlib, logging, os, sys, vim, warnings
def _pv_import_utils(state_log, module_path):
    original_handler = logging.FileHandler
    original_bytecode = sys.dont_write_bytecode
    original_path = sys.path[:]
    default_log = os.path.abspath(os.path.expanduser('~/.vimspector.log'))
    def log_handler(filename, *args, **kwargs):
        if os.path.abspath(os.fspath(filename)) == default_log:
            filename = state_log
        return original_handler(filename, *args, **kwargs)
    try:
        logging.FileHandler = log_handler
        sys.dont_write_bytecode = True
        # Vim's Python importer does not decode escaped runtimepath entries.
        # Use the native directory only while importing the bundled packages.
        sys.path.insert(0, os.path.join(module_path, 'python3'))
        with warnings.catch_warnings():
            # Python 3.12 warns about the pinned json_minify regex literals.
            # Early Vim 9.1 treats Python stderr as a failed import. Limit the
            # warning filter to these imports; never change the user's filters.
            warnings.simplefilter('ignore', SyntaxWarning)
            utils = importlib.import_module('vimspector.utils')
            importlib.import_module('vimspector.debug_session')
    finally:
        logging.FileHandler = original_handler
        sys.dont_write_bytecode = original_bytecode
        sys.path[:] = original_path
    utils.LOG_FILE = state_log
try:
    _pv_import_utils(vim.eval('l:log'), vim.eval('l:path'))
finally:
    del _pv_import_utils
EOF
    execute 'source ' .. fnameescape(l:path .. '/plugin/vimspector.vim')
    let s:ready = v:true
    return 1
  catch
    return s:Warn('cannot load Vimspector: ' .. v:exception)
  endtry
endfunc

func! s:Python() abort
  return executable('python3') ? 'python3' : 'python'
endfunc

" A read-only capability probe, using argv and bounded job execution.
func! s:Probe(argv) abort
  if empty(a:argv) || !executable(a:argv[0])
    return 0
  endif
  let l:output = tempname()
  try
    let l:job = job_start(a:argv, #{out_io: 'file', out_name: l:output, err_io: 'out'})
    for l:i in range(300)
      if job_status(l:job) !=# 'run'
        return job_status(l:job) ==# 'dead' && get(job_info(l:job), 'exitval', -1) == 0
      endif
      sleep 10m
    endfor
    call job_stop(l:job, 'kill')
    return 0
  finally
    call delete(l:output)
  endtry
endfunc

func! planet#debug#Configuration(language, program = '') abort
  if a:language ==# 'python'
    let l:command = get(g:, 'PV_debugpy_command', [s:Python(), '-m', 'debugpy.adapter'])
    return #{adapters: {'planet-debugpy': #{command: l:command}},
          \ configurations: {'Python': #{adapter: 'planet-debugpy',
          \ configuration: #{request: 'launch', type: 'python', program: empty(a:program) ? '${file}' : a:program,
          \ cwd: '${workspaceRoot}', console: 'integratedTerminal', stopOnEntry: v:false},
          \ breakpoints: #{exception: #{raised: 'N', uncaught: '', userUnhandled: ''}}}}}
  elseif index(['cpp', 'c', 'c++'], a:language) >= 0
    let l:command = get(g:, 'PV_gdb_command', ['gdb', '--quiet', '--nx', '--interpreter=dap'])
    return #{adapters: {'planet-gdb': #{command: l:command}},
          \ configurations: {'C++': #{adapter: 'planet-gdb',
          \ configuration: #{request: 'launch', type: 'gdb', program: empty(a:program) ? '${workspaceRoot}/build/app' : a:program,
          \ cwd: '${workspaceRoot}', stopAtBeginningOfMainSubprogram: v:true}}}}
  endif
  call s:Warn('setup supports python or cpp.')
  return {}
endfunc

func! planet#debug#Setup(language, program = '') abort
  let l:config = planet#debug#Configuration(a:language, a:program)
  if empty(l:config)
    return 0
  endif
  let l:path = planet#run#Project().root .. '/.vimspector.json'
  if filereadable(l:path) || getftype(l:path) !=# ''
    return s:Warn('.vimspector.json already exists; edit it to add another configuration.')
  endif
  try
    call writefile([json_encode(l:config)], l:path)
    execute 'edit ' .. fnameescape(l:path)
    echom 'PlanetVim debugger: configuration created. Review the program and adapter command before launch.'
    return 1
  catch
    return s:Warn('cannot create configuration: ' .. v:exception)
  endtry
endfunc

func! s:Check(config, configuration) abort
  " Check PlanetVim's examples. Custom upstream adapter configurations retain
  " Vimspector's own validation and support (TCP, gadgets, remote adapters).
  for [l:name, l:adapter] in items(get(a:config, 'adapters', {}))
    let l:selected = get(get(a:config, 'configurations', {}), a:configuration, {})
    if !empty(a:configuration) && get(l:selected, 'adapter', '') !=# l:name
      continue
    endif
    if index(['planet-debugpy', 'planet-gdb'], l:name) < 0
      continue
    endif
    let l:command = get(l:adapter, 'command', [])
    if type(l:command) != v:t_list || empty(l:command) || !executable(l:command[0])
      return s:Warn(l:name .. ' executable is missing; edit the adapter command in .vimspector.json.')
    endif
    if l:name ==# 'planet-debugpy' && len(l:command) == 3 && l:command[1:] ==# ['-m', 'debugpy.adapter']
      if !s:Probe([l:command[0], '-c', 'import debugpy.adapter'])
        return s:Warn('install debugpy into ' .. l:command[0] .. ' (python -m pip install debugpy), or set g:PV_debugpy_command before setup.')
      endif
    elseif l:name ==# 'planet-gdb' && !s:Probe([l:command[0], '--nx', '--quiet', '--batch', '-ex', 'python import gdb.dap'])
      return s:Warn('GDB needs its Python DAP module (GDB 14+); install a DAP-capable GDB or configure another adapter.')
    endif
  endfor
  return 1
endfunc

func! planet#debug#Action(action, configuration = '') abort
  let l:actions = {'continue': 'Continue', 'breakpoint': 'ToggleBreakpoint', 'step-over': 'StepOver',
        \ 'step-into': 'StepInto', 'step-out': 'StepOut', 'restart': 'Restart', 'pause': 'Pause', 'stop': 'Stop'}
  if a:action ==# 'detach'
    return planet#debug#Detach()
  elseif a:action !=# 'launch' && a:action !=# 'reset' && !has_key(l:actions, a:action)
    return s:Warn('unknown action: ' .. a:action)
  endif
  if a:action ==# 'launch'
    let l:path = planet#run#Project().root .. '/.vimspector.json'
    if !filereadable(l:path)
      return s:Warn('create .vimspector.json first with :PlanetDebugSetup python or :PlanetDebugSetup cpp.')
    endif
    try
      let l:config = json_decode(join(readfile(l:path), "\n"))
      let l:selection = a:configuration
      let l:names = sort(keys(get(l:config, 'configurations', {})))
      if empty(l:names)
        return s:Warn('no configurations are defined in .vimspector.json.')
      endif
      if empty(l:selection)
        if len(l:names) == 1
          let l:selection = l:names[0]
        else
          let l:choice = inputlist(['Debug configuration:'] + map(copy(l:names), '(v:key + 1) .. ". " .. v:val'))
          if l:choice < 1 || l:choice > len(l:names)
            return 0
          endif
          let l:selection = l:names[l:choice - 1]
        endif
      elseif index(l:names, l:selection) < 0
        return s:Warn('configuration not found: ' .. l:selection)
      endif
      if !s:Check(l:config, l:selection)
        return 0
      endif
    catch
      return s:Warn('invalid .vimspector.json: ' .. v:exception)
    endtry
  endif
  if !planet#debug#Init()
    return 0
  endif
  try
    if a:action ==# 'launch'
      call vimspector#LaunchWithSettings(#{configuration: l:selection})
    elseif a:action ==# 'reset'
      call vimspector#Reset(#{interactive: v:false})
    else
      call call('vimspector#' .. l:actions[a:action], [])
    endif
    return 1
  catch
    return s:Warn(v:exception)
  endtry
endfunc

func! planet#debug#Detach() abort
  if !planet#debug#Init()
    return 0
  endif
  try
    py3 << EOF
_pv_detach_bytecode = sys.dont_write_bytecode
try:
    sys.dont_write_bytecode = True
    import planetvim_debug
finally:
    sys.dont_write_bytecode = _pv_detach_bytecode
    del _pv_detach_bytecode
def _pv_detach_report(result):
    vim.vars['PV_debug_detach_result'] = result
    if result['status'] == 'failed':
        vim.command("echohl WarningMsg | echom 'PlanetVim detach: ' . g:PV_debug_detach_result.error | echohl None")
_pv_detach_started = planetvim_debug.detach(
    globals().get('_vimspector_session'),
    lambda kind: vim.eval('vimspector#internal#{}#StopDebugSession()'.format(kind)),
    _pv_detach_report)
EOF
    return py3eval('_pv_detach_started') ? 1 : 0
  catch
    return s:Warn(v:exception)
  endtry
endfunc
