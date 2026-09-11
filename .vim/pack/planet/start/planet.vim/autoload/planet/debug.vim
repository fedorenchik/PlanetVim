vim9script

var script_state: dict<any> = {}

def LocalWarn(message: any): any
  echohl WarningMsg
  echom 'PlanetVim debugger: ' .. message
  echohl None
  return 0
enddef

export def Init(): any
  if get(script_state, 'ready', v:false)
    return 1
  endif
  if !has('python3')
    return LocalWarn('GVim needs +python3 support and its matching Python runtime.')
  endif
  if !py3eval("__import__('sys').version_info >= (3, 10)")
    return LocalWarn('Vimspector needs the GVim embedded Python runtime to be version 3.10 or newer.')
  endif
  var path: any = planet#paths#Root() .. '/.vim/pack/apps/opt/vimspector'
  if !filereadable(path .. '/plugin/vimspector.vim')
    return LocalWarn('bundled Vimspector is missing.')
  endif
  g:vimspector_base_dir = get(g:, 'vimspector_base_dir', planet#paths#State('debugger'))
  var log: any = planet#paths#State('debugger') .. '/vimspector.log'
  &runtimepath = planet#paths#Runtime(path) .. ',' .. &runtimepath
  try
    # Pinned and current upstream open ~/.vimspector.log in write mode on
    # import, with no path setting. Redirect exactly that constructor once;
    # never change HOME or leave a logging constructor installed globally.
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
            importlib.import_module('vimspector.session_manager')
    finally:
        logging.FileHandler = original_handler
        sys.dont_write_bytecode = original_bytecode
        sys.path[:] = original_path
    utils.LOG_FILE = state_log
EOF
    try
      execute 'py3 _pv_import_utils(' .. json_encode(log) .. ', ' .. json_encode(path) .. ')'
    finally
      py3 del _pv_import_utils
    endtry
    execute 'source ' .. fnameescape(path .. '/plugin/vimspector.vim')
    script_state.ready = v:true
    return 1
  catch
    return LocalWarn('cannot load Vimspector: ' .. v:exception)
  endtry
enddef

def LocalPython(): any
  return executable('python3') ? 'python3' : 'python'
enddef

# A read-only capability probe, using argv and bounded job execution.
def LocalProbe(argv: any): any
  var job: any
  if empty(argv) || !executable(argv[0])
    return 0
  endif
  var output: any = tempname()
  try
    job = job_start(argv, {out_io: 'file', out_name: output, err_io: 'out'})
    for i in range(300)
      if job_status(job) !=# 'run'
        return job_status(job) ==# 'dead' && get(job_info(job), 'exitval', -1) == 0
      endif
      sleep 10m
    endfor
    job_stop(job, 'kill')
    return 0
  finally
    delete(output)
  endtry
  return 0
enddef

export def Configuration(language: any, program: any = ''): any
  var command: any
  if language ==# 'python'
    command = get(g:, 'PV_debugpy_command', [LocalPython(), '-m', 'debugpy.adapter'])
    return {adapters: {'planet-debugpy': {command: command}}, configurations: {'Python': {adapter: 'planet-debugpy',
         configuration: {request: 'launch', type: 'python', program: empty(program) ? '${file}' : program,
         cwd: '${workspaceRoot}', console: 'integratedTerminal', stopOnEntry: v:false}, breakpoints: {exception: {raised: 'N',
         uncaught: '', userUnhandled: ''}}}}}
  elseif index(['cpp', 'c', 'c++'], language) >= 0
    command = get(g:, 'PV_gdb_command', ['gdb', '--quiet', '--nx', '--interpreter=dap'])
    return {adapters: {'planet-gdb': {command: command}}, configurations: {'C++': {adapter: 'planet-gdb',
         configuration: {request: 'launch', type: 'gdb', program: empty(program) ? '${workspaceRoot}/build/app' : program,
         cwd: '${workspaceRoot}', stopAtBeginningOfMainSubprogram: v:true},
         breakpoints: {exception: {assert: 'N', exception: 'N', throw: 'N', rethrow: 'N', catch: 'N'}}}}}
  endif
  LocalWarn('setup supports python or cpp.')
  return {}
enddef

export def Setup(language: any, program: any = ''): any
  var config: any = planet#debug#Configuration(language, program)
  if empty(config)
    return 0
  endif
  var path: any = planet#run#Project().root .. '/.vimspector.json'
  if filereadable(path) || getftype(path) !=# ''
    return LocalWarn('.vimspector.json already exists; edit it to add another configuration.')
  endif
  try
    writefile([json_encode(config)], path)
    execute 'edit ' .. fnameescape(path)
    echom 'PlanetVim debugger: configuration created. Review the program and adapter command before launch.'
    return 1
  catch
    return LocalWarn('cannot create configuration: ' .. v:exception)
  endtry
enddef

def LocalCheck(config: any, configuration: any): any
  var selected: any
  var command: any
  # Check PlanetVim's examples. Custom upstream adapter configurations retain
  # Vimspector's own validation and support (TCP, gadgets, remote adapters).
  for [name, adapter] in items(get(config, 'adapters', {}))
    selected = get(get(config, 'configurations', {}), configuration, {})
    if !empty(configuration) && get(selected, 'adapter', '') !=# name
      continue
    endif
    if index(['planet-debugpy', 'planet-gdb'], name) < 0
      continue
    endif
    command = get(adapter, 'command', [])
    if type(command) != v:t_list || empty(command) || !executable(command[0])
      return LocalWarn(name .. ' executable is missing; edit the adapter command in .vimspector.json.')
    endif
    if name ==# 'planet-debugpy' && len(command) == 3 && command[1 : ] ==# ['-m', 'debugpy.adapter']
      if !LocalProbe([command[0], '-c', 'import debugpy.adapter'])
        return LocalWarn('install debugpy into ' .. command[0] .. ' (python -m pip install debugpy), or set g:PV_debugpy_command before setup.')
      endif
    elseif name ==# 'planet-gdb' && !LocalProbe([command[0], '--nx', '--quiet', '--batch', '-ex', 'python import gdb.dap'])
      return LocalWarn('GDB needs its Python DAP module (GDB 14+); install a DAP-capable GDB or configure another adapter.')
    endif
  endfor
  return 1
enddef

export def Action(action: any, configuration: any = ''): any
  var path: any
  var config: any
  var selection: any
  var names: any
  var choice: any
  var actions: any = {'continue': 'Continue', 'breakpoint': 'ToggleBreakpoint', 'step-over': 'StepOver',
       'step-into': 'StepInto', 'step-out': 'StepOut', 'restart': 'Restart', 'pause': 'Pause', 'stop': 'Stop',
       'disassembly': 'ShowDisassembly', 'instruction-over': 'StepIOver', 'instruction-into': 'StepIInto',
       'instruction-out': 'StepIOut', 'data-breakpoint': 'AddDataBreakpoint',
       'exception-breakpoints': 'ResetExceptionBreakpoints'}
  if action ==# 'detach'
    return planet#debug#Detach()
  elseif action !=# 'launch' && action !=# 'reset' && !has_key(actions, action)
    return LocalWarn('unknown action: ' .. action)
  endif
  if action ==# 'launch'
    path = planet#run#Project().root .. '/.vimspector.json'
    if !filereadable(path)
      return LocalWarn('create .vimspector.json first with :PlanetDebugSetup python or :PlanetDebugSetup cpp.')
    endif
    try
      config = json_decode(join(readfile(path), "\n"))
      selection = configuration
      names = sort(keys(get(config, 'configurations', {})))
      if empty(names)
        return LocalWarn('no configurations are defined in .vimspector.json.')
      endif
      if empty(selection)
        if len(names) == 1
          selection = names[0]
        else
          choice = inputlist(['Debug configuration:'] + map(copy(names), (choice_index, choice_name) => (choice_index + 1) .. '. ' .. choice_name))
          if choice < 1 || choice > len(names)
            return 0
          endif
          selection = names[choice - 1]
        endif
      elseif index(names, selection) < 0
        return LocalWarn('configuration not found: ' .. selection)
      endif
      if !LocalCheck(config, selection)
        return 0
      endif
    catch
      return LocalWarn('invalid .vimspector.json: ' .. v:exception)
    endtry
  endif
  if !planet#debug#Init()
    return 0
  endif
  try
    if action ==# 'launch'
      vimspector#LaunchWithSettings({configuration:  selection})
    elseif action ==# 'reset'
      vimspector#Reset({interactive:  v:false})
    else
      call('vimspector#' .. actions[action], [])
    endif
    return 1
  catch
    return LocalWarn(v:exception)
  endtry
enddef

export def Detach(): any
  if !planet#debug#Init()
    return 0
  endif
  var bridge_path: any = planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/python3'
  try
    py3 << EOF
EOF
    execute 'py3 _pv_bridge_path = ' .. json_encode(bridge_path)
    py3 << EOF
_pv_detach_bytecode = sys.dont_write_bytecode
_pv_detach_path = sys.path[:]
try:
    sys.dont_write_bytecode = True
    sys.path.insert(0, _pv_bridge_path)
    import planetvim_debug
finally:
    sys.dont_write_bytecode = _pv_detach_bytecode
    sys.path[:] = _pv_detach_path
    del _pv_detach_bytecode, _pv_detach_path, _pv_bridge_path
def _pv_detach_report(result):
    vim.vars['PV_debug_detach_result'] = result
    if result['status'] == 'failed':
        vim.command("echohl WarningMsg | echom 'PlanetVim detach: ' . g:PV_debug_detach_result.error | echohl None")
_pv_detach_started = planetvim_debug.detach(
    globals().get('_vimspector_session'),
    lambda kind, session_id: vim.eval('vimspector#internal#{}#StopDebugSession({})'.format(kind, int(session_id))),
    _pv_detach_report)
EOF
    return py3eval('_pv_detach_started') ? 1 : 0
  catch
    return LocalWarn(v:exception)
  endtry
enddef

# Session names are passed as values, including spaces; never execute them.
export def Session(action: string, supplied: any = v:null): number
  if index(['new', 'switch', 'rename', 'close'], action) < 0
    return LocalWarn('unknown session action: ' .. action)
  endif
  if !planet#debug#Init()
    return 0
  endif
  var name = supplied
  if name == v:null
    if action ==# 'switch'
      var names = split(vimspector#CompleteSessionName('', '', 0), "\n")
      var choice = inputlist(['Debug session:'] + map(copy(names), (i, value) => (i + 1) .. '. ' .. value))
      if choice < 1 || choice > len(names)
        return 0
      endif
      name = names[choice - 1]
    elseif action ==# 'close'
      name = vimspector#GetSessionName()
    else
      name = input('Session name: ', action ==# 'rename' ? vimspector#GetSessionName() : '')
    endif
  endif
  if empty(name)
    return 0
  endif
  var methods = {new: 'NewSession', switch: 'SwitchToSession', rename: 'RenameSession', close: 'DestroySession'}
  try
    call('vimspector#' .. methods[action], [name])
    return 1
  catch
    return LocalWarn(v:exception)
  endtry
enddef
