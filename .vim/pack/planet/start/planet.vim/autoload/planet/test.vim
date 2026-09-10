vim9script
var script_last_buffer: any

def LocalWarn(message: any): any
  echohl WarningMsg
  echom 'PlanetVim tests: ' .. message
  echohl None
  return 0
enddef

export def Init(): any
  var path: any
  if !exists('g:loaded_test')
    path = planet#paths#Root() .. '/.vim/pack/basic/start/vim-test'
    if !filereadable(path .. '/plugin/test.vim')
      return LocalWarn('bundled vim-test is missing.')
    endif
    &runtimepath = planet#paths#Runtime(path) .. ',' .. &runtimepath
    execute 'source ' .. fnameescape(path .. '/plugin/test.vim')
  endif
  g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
  g:test#custom_strategies.planet = function('planet#test#Strategy')
  return 1
enddef

def LocalHistory(): any
  if !exists('t:PV_test_history')
    t:PV_test_history = {}
  endif
  var root: any = planet#run#Project().root
  if !has_key(t:PV_test_history, root)
    t:PV_test_history[root] = {}
  endif
  return t:PV_test_history[root]
enddef

def LocalFinished(result: any, buffer: any): any
  if result.exit_code == 127 || result.exit_code == 9009
    LocalWarn('test runner was not found. Install the runner or configure its vim-test executable; see retained output.')
  endif
  return 0
enddef

# vim-test deliberately supplies a shell program; retain it byte-for-byte.
export def Strategy(command: any): any
  var history: any = LocalHistory()
  history.command = command
  history.cwd = planet#run#Project().root
  if exists('g:test#last_position')
    history.position = deepcopy(g:test#last_position)
    history.position.file = fnamemodify(history.position.file, ':p')
  endif
  var buffer: any = planet#term#RunShell(command, v:false, v:false, v:false, history.cwd, function(LocalFinished))
  if buffer > 0
    t:PV_test_history = {[history.cwd]:  history}
  endif
  script_last_buffer = buffer
  return buffer
enddef

export def Test(action: any): any
  var buffer: any
  var cwd: any
  var name: any
  if index(['nearest', 'file', 'class', 'suite', 'last', 'visit'], action) < 0
    return LocalWarn('use nearest, file, class, suite, last, or visit.')
  endif
  if !planet#test#Init()
    return 0
  endif
  var history: any = LocalHistory()
  if action ==# 'visit'
    if !has_key(history, 'position')
      return LocalWarn('no test has run in this project tab.')
    endif
    execute 'edit ' .. fnameescape(history.position.file)
    cursor(history.position.line, history.position.col)
    return 1
  endif
  if action ==# 'last'
    if !has_key(history, 'command')
      return LocalWarn('no test has run in this project tab.')
    endif
    buffer = planet#term#RunShell(history.command, v:false, v:false, v:false, history.cwd, function(LocalFinished))
    if buffer > 0
      t:PV_test_history = {[history.cwd]:  history}
    endif
    return buffer
  endif
  if &buftype ==# '' && &modified
    try
      update
    catch
      return LocalWarn('cannot save the test buffer: ' .. v:exception)
    endtry
  endif
  # Isolate vim-test's global history and cwd handling from other project tabs.
  var saved: any = {}
  for item_name in ['test#last_position', 'test#project_root', 'test#strategy']
    name = item_name
    if has_key(g:, name)
      saved[name] = g:[name]
      unlet g:[name]
    endif
  endfor
  cwd = getcwd()
  var origin: any = win_getid()
  var scope: any = haslocaldir()
  var autowrite: any = &autowrite
  var autowriteall: any = &autowriteall
  script_last_buffer = 0
  try
    set noautowrite noautowriteall
    execute 'lcd ' .. fnameescape(planet#run#Project().root)
    if has_key(history, 'position')
      g:test#last_position = deepcopy(history.position)
    endif
    g:test#strategy = 'planet'
    test#run(action, [])
  catch
    LocalWarn(v:exception)
  finally
    for item_name in ['test#last_position', 'test#project_root', 'test#strategy']
      name = item_name
      if has_key(g:, name)
        unlet g:[name]
      endif
      if has_key(saved, name)
        g:[name] = saved[name]
      endif
    endfor
    &autowrite = autowrite
    &autowriteall = autowriteall
    # RunShell creates a new tab; restore the original window's local cwd.
    # The new output tab already has the explicit project cwd in its job.
    if origin > 0
      win_execute(origin, (scope == 1 ? 'lcd ' : scope == 2 ? 'tcd ' : 'cd ') .. fnameescape(cwd))
    endif
  endtry
  return script_last_buffer
enddef
