scriptversion 4

func! s:Warn(message) abort
  echohl WarningMsg
  echom 'PlanetVim tests: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#test#Init() abort
  if !exists('g:loaded_test')
    let l:path = planet#paths#Root() .. '/.vim/pack/basic/start/vim-test'
    if !filereadable(l:path .. '/plugin/test.vim')
      return s:Warn('bundled vim-test is missing.')
    endif
    let &runtimepath = escape(l:path, ',') .. ',' .. &runtimepath
    execute 'source ' .. fnameescape(l:path .. '/plugin/test.vim')
  endif
  let g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
  let g:test#custom_strategies.planet = function('planet#test#Strategy')
  return 1
endfunc

func! s:History() abort
  if !exists('t:PV_test_history')
    let t:PV_test_history = {}
  endif
  let l:root = planet#run#Project().root
  if !has_key(t:PV_test_history, l:root)
    let t:PV_test_history[l:root] = {}
  endif
  return t:PV_test_history[l:root]
endfunc

func! s:Finished(result, buffer) abort
  if a:result.exit_code == 127 || a:result.exit_code == 9009
    call s:Warn('test runner was not found. Install the runner or configure its vim-test executable; see retained output.')
  endif
endfunc

" vim-test deliberately supplies a shell program; retain it byte-for-byte.
func! planet#test#Strategy(command) abort
  let l:history = s:History()
  let l:history.command = a:command
  let l:history.cwd = planet#run#Project().root
  if exists('g:test#last_position')
    let l:history.position = deepcopy(g:test#last_position)
    let l:history.position.file = fnamemodify(l:history.position.file, ':p')
  endif
  let l:buffer = planet#term#RunShell(a:command, v:false, v:false, v:false,
        \ l:history.cwd, function('s:Finished'))
  if l:buffer > 0
    let t:PV_test_history = {l:history.cwd: l:history}
  endif
  let s:last_buffer = l:buffer
  return l:buffer
endfunc

func! planet#test#Test(action) abort
  if index(['nearest', 'file', 'class', 'suite', 'last', 'visit'], a:action) < 0
    return s:Warn('use nearest, file, class, suite, last, or visit.')
  endif
  if !planet#test#Init()
    return 0
  endif
  let l:history = s:History()
  if a:action ==# 'visit'
    if !has_key(l:history, 'position')
      return s:Warn('no test has run in this project tab.')
    endif
    execute 'edit ' .. fnameescape(l:history.position.file)
    call cursor(l:history.position.line, l:history.position.col)
    return 1
  endif
  if a:action ==# 'last'
    if !has_key(l:history, 'command')
      return s:Warn('no test has run in this project tab.')
    endif
    let l:buffer = planet#term#RunShell(l:history.command, v:false, v:false, v:false,
          \ l:history.cwd, function('s:Finished'))
    if l:buffer > 0
      let t:PV_test_history = {l:history.cwd: l:history}
    endif
    return l:buffer
  endif
  if &buftype ==# '' && &modified
    try
      update
    catch
      return s:Warn('cannot save the test buffer: ' .. v:exception)
    endtry
  endif
  " Isolate vim-test's global history and cwd handling from other project tabs.
  let l:saved = {}
  for l:name in ['test#last_position', 'test#project_root', 'test#strategy']
    if has_key(g:, l:name)
      let l:saved[l:name] = g:[l:name]
      unlet g:[l:name]
    endif
  endfor
  let l:cwd = getcwd()
  let l:origin = win_getid()
  let l:scope = haslocaldir()
  let l:autowrite = &autowrite
  let l:autowriteall = &autowriteall
  let s:last_buffer = 0
  try
    set noautowrite noautowriteall
    execute 'lcd ' .. fnameescape(planet#run#Project().root)
    if has_key(l:history, 'position')
      let g:test#last_position = deepcopy(l:history.position)
    endif
    let g:test#strategy = 'planet'
    call test#run(a:action, [])
  catch
    call s:Warn(v:exception)
  finally
    for l:name in ['test#last_position', 'test#project_root', 'test#strategy']
      if has_key(g:, l:name)
        unlet g:[l:name]
      endif
      if has_key(l:saved, l:name)
        let g:[l:name] = l:saved[l:name]
      endif
    endfor
    let &autowrite = l:autowrite
    let &autowriteall = l:autowriteall
    " RunShell creates a new tab; restore the original window's local cwd.
    " The new output tab already has the explicit project cwd in its job.
    if exists('l:origin')
      call win_execute(l:origin, (l:scope == 1 ? 'lcd ' : l:scope == 2 ? 'tcd ' : 'cd ') .. fnameescape(l:cwd))
    endif
  endtry
  return s:last_buffer
endfunc
