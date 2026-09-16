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

def LocalFinished(result: any, buffer: any): any
  if result.exit_code == 127 || result.exit_code == 9009
    LocalWarn('test runner was not found. Install the runner or configure its vim-test executable; see retained output.')
  endif
  return 0
enddef

# vim-test deliberately supplies a shell program; retain it byte-for-byte.
export def Strategy(command: any): any
  if exists('g:test#last_position')
    g:test#last_position.file = fnamemodify(g:test#last_position.file, ':p')
  endif
  var buffer: any = planet#term#RunShell(command, v:false, v:false, v:false, planet#project#Root(), function(LocalFinished))
  script_last_buffer = buffer
  return buffer
enddef

export def Test(action: any): any
  var cwd: any
  var name: any
  if index(['nearest', 'file', 'class', 'suite', 'last', 'visit'], action) < 0
    return LocalWarn('use nearest, file, class, suite, last, or visit.')
  endif
  if !planet#test#Init()
    return 0
  endif
  if action ==# 'visit'
    if !exists('g:test#last_position')
      return LocalWarn('no test has run in this instance.')
    endif
    execute 'edit ' .. fnameescape(g:test#last_position.file)
    cursor(g:test#last_position.line, g:test#last_position.col)
    return 1
  endif
  if action ==# 'last' && !exists('g:test#last_command')
    return LocalWarn('no test has run in this instance.')
  endif
  if &buftype ==# '' && &modified
    try
      update
    catch
      return LocalWarn('cannot save the test buffer: ' .. v:exception)
    endtry
  endif
  # Run from the instance project, preserving the source window's navigation.
  var saved: any = {}
  for item_name in ['test#project_root', 'test#strategy']
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
    g:test#strategy = 'planet'
    g:test#project_root = planet#project#Root()
    if action ==# 'last'
      g:test#last_strategy = 'planet'
      test#run_last([])
    else
      test#run(action, [])
    endif
  catch
    LocalWarn(v:exception)
  finally
    for item_name in ['test#project_root', 'test#strategy']
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
