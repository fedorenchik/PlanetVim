vim9script

var runs: dict<any> = {}
var next_id = 0

def Definitions(context: dict<any>): dict<any>
  var tasks = {configure: {builtin: 'configure'}, build: {builtin: 'build', depends: ['configure']},
    'test-build': {builtin: 'build', all_targets: true, depends: ['configure']},
    run: {builtin: 'run'}, test: {builtin: 'test'}, debug: {builtin: 'debug'},
    'build-run': {depends: ['build', 'run']}, 'build-test': {depends: ['test-build', 'test']},
    'build-debug': {depends: ['build', 'debug']}}
  return extend(tasks, deepcopy(get(context, 'tasks', {})), 'force')
enddef

def Visit(name: string, definitions: dict<any>, visiting: list<string>, ordered: list<any>, seen: dict<bool>)
  if index(visiting, name) >= 0
    throw 'PlanetVim: task dependency cycle: ' .. join(visiting + [name], ' -> ')
  endif
  if has_key(seen, name)
    return
  endif
  if !has_key(definitions, name) || type(definitions[name]) != v:t_dict
    throw 'PlanetVim: unknown task: ' .. name
  endif
  var task = deepcopy(definitions[name])
  var deps = get(task, 'depends', [])
  if type(deps) != v:t_list || !empty(filter(copy(deps), (_, value) => type(value) != v:t_string))
    throw 'PlanetVim: task dependencies must be task names'
  endif
  if has_key(task, 'argv') && has_key(task, 'command')
    throw 'PlanetVim: a task must choose argv or command'
  endif
  if has_key(task, 'argv') && (type(task.argv) != v:t_list || empty(task.argv) || !empty(filter(copy(task.argv), (_, v) => type(v) != v:t_string)))
    throw 'PlanetVim: task argv must be a nonempty String array'
  endif
  for key in ['command', 'cwd', 'parser']
    if has_key(task, key) && type(task[key]) != v:t_string
      throw 'PlanetVim: task ' .. key .. ' must be a String'
    endif
  endfor
  var seconds = get(task, 'timeout', 0)
  if type(seconds) != v:t_number || seconds < 0
    throw 'PlanetVim: task timeout must be nonnegative seconds'
  endif
  for dependency in deps
    Visit(dependency, definitions, visiting + [name], ordered, seen)
  endfor
  if has_key(task, 'argv') || has_key(task, 'command') || has_key(task, 'builtin')
    task.name = name
    add(ordered, task)
  elseif empty(deps)
    throw 'PlanetVim: task has no command or dependencies: ' .. name
  endif
  seen[name] = true
enddef

export def Plan(name: string, context: dict<any> = planet#project#Context()): list<any>
  var ordered: list<any> = []
  Visit(name, Definitions(context), [], ordered, {})
  return ordered
enddef

def Token(name: string, context: dict<any>): string
  if name ==# 'program' | return Program(context) | endif
  if name ==# 'build'
    if empty(context.build_dir) | planet#cmake#Prepare(context, false) | endif
    return context.build_dir
  endif
  return get(context, name, '')
enddef

export def Expand(value: any, context: dict<any>): any
  if type(value) == v:t_list
    return map(copy(value), (_, item) => Expand(item, context))
  endif
  # Resolve paths before entering substitute(): autoloading from its expression
  # callback can invalidate Vim's active substitution state.
  var replacements: dict<string> = {}
  for name in ['root', 'build', 'program', 'file']
    if stridx(value, '${' .. name .. '}') >= 0
      replacements[name] = Token(name, context)
    endif
  endfor
  return substitute(value, '${\(root\|build\|program\|file\)}', (m) => replacements[m[1]], 'g')
enddef

export def Program(context: dict<any>): string
  var program = get(context, 'program', '')
  if empty(program)
    return planet#cmake#Program(context)
  endif
  return program =~# '^/' ? program : context.root .. '/' .. program
enddef

def Command(task: dict<any>, context: dict<any>): dict<any>
  var builtin = get(task, 'builtin', '')
  if index(['configure', 'build'], builtin) >= 0
    if get(task, 'all_targets', false)
      var complete = deepcopy(context)
      complete.target = ''
      return planet#build#Plan(builtin, complete)
    endif
    return planet#build#Plan(builtin, context)
  elseif builtin ==# 'test'
    return {argv: ['ctest', '--output-on-failure'] + (empty(get(context, 'build_type', '')) ? [] : ['-C', context.build_type]), cwd: context.build_dir}
  elseif builtin ==# 'run'
    var program = Program(context)
    return {argv: (program =~# '\.py$' ? get(context, 'python', ['python3']) : []) + [program] + get(context, 'args', []), cwd: context.cwd}
  endif
  var result = deepcopy(task)
  result.cwd = planet#run#Path(Expand(get(task, 'cwd', '${root}'), context), context.root)
  if has_key(result, 'argv')
    result.argv = Expand(result.argv, context)
  endif
  # Shell scripts retain their original bytes; interpolation belongs to argv.
  return result
enddef

def Finished(run: dict<any>, result: dict<any>, buffer: number)
  run.pending = false
  if get(run, 'timer', -1) >= 0
    timer_stop(run.timer)
    run.timer = -1
  endif
  add(run.results, {task: run.steps[run.index].name, buffer: buffer, result: result})
  if run.status !=# 'running'
    return
  endif
  if result.status !=# 'success'
    run.status = result.status
    return
  endif
  if get(run.steps[run.index], 'builtin', '') ==# 'configure'
    try
      planet#cmake#Configured(run.context, run.project)
    catch
      run.status = 'failed'
      run.error = v:exception
      return
    endtry
  endif
  run.index += 1
  timer_start(0, (_) => Next(run))
enddef

def Timeout(run: dict<any>)
  if run.status ==# 'running'
    run.status = 'timed-out'
    planet#term#Cancel(run.buffer)
  endif
enddef

def Next(run: dict<any>)
  if run.status !=# 'running'
    return
  endif
  if run.index >= len(run.steps)
    run.status = 'success'
    echom 'PlanetVim task completed: ' .. run.name
    return
  endif
  var task = run.steps[run.index]
  try
    if get(task, 'builtin', '') ==# 'debug'
      if !win_gotoid(run.window)
        throw 'the original source window was closed'
      endif
      if !planet#debug#Project(run.context)
        throw 'debugger launch failed'
      endif
      Finished(run, {status: 'success', exit_code: 0}, 0)
      return
    endif
    var command = Command(task, run.context)
    run.pending = true
    run.buffer = planet#term#RunCmd(get(command, 'argv', get(command, 'command', '')), false, false,
      get(run.context, 'hidden', false), command.cwd, function(Finished, [run]), '',
      {context: run.context, parser: get(command, 'parser', ''), task_id: run.id})
    if run.buffer <= 0
      run.pending = false
      throw 'command could not start'
    endif
    var seconds = get(task, 'timeout', get(run.context, 'timeout', 0))
    if seconds > 0
      run.timer = timer_start(seconds * 1000, (_) => Timeout(run))
    endif
  catch
    run.pending = false
    run.status = 'failed'
    run.error = v:exception
    echom 'PlanetVim task failed: ' .. v:exception
  endtry
enddef

export def Start(name: string, supplied: dict<any> = {}): number
  var context = empty(supplied) ? planet#project#Context() : deepcopy(supplied)
  context.file = get(context, 'file', expand('%:p'))
  context.filetype = &filetype
  var steps = Plan(name, context)
  if type(get(context, 'timeout', 0)) != v:t_number || get(context, 'timeout', 0) < 0
    throw 'PlanetVim: timeout must be nonnegative seconds'
  endif
  for run in values(runs)
    if run.status ==# 'running' || get(run, 'pending', false)
      throw 'PlanetVim: this instance already has a running task; cancel it or wait'
    endif
  endfor
  # Save all modified source buffers in this project before any prerequisite.
  if get(context, 'save', true)
    var original = bufnr()
    var view = winsaveview()
    try
      for buffer in getbufinfo({'bufmodified': 1})
        if stridx(buffer.name, context.root .. '/') == 0 && empty(getbufvar(buffer.bufnr, '&buftype'))
          execute 'silent noautocmd keepalt keepjumps buffer ' .. buffer.bufnr
          update
        endif
      endfor
    finally
      execute 'silent noautocmd keepalt keepjumps buffer ' .. original
      winrestview(view)
    endtry
  endif
  next_id += 1
  var run = {id: next_id, name: name, context: context, steps: steps, index: 0,
    project: planet#run#Project(), window: win_getid(), status: 'running', results: [], buffer: 0, timer: -1}
  runs[string(next_id)] = run
  Next(run)
  return next_id
enddef

export def Status(id: number): dict<any>
  return deepcopy(get(runs, string(id), {}))
enddef

export def Cancel(id: number = 0): number
  for run in values(runs)
    if (id == run.id || id == 0) && run.status ==# 'running'
      run.status = 'cancelled'
      if run.timer >= 0 | timer_stop(run.timer) | endif
      planet#term#Cancel(run.buffer)
      return 1
    endif
  endfor
  return 0
enddef

export def Choose(): number
  var names = sort(keys(Definitions(planet#project#Context())))
  var choice = inputlist(['Run task:'] + map(copy(names), (i, value) => (i + 1) .. '. ' .. value))
  return choice > 0 && choice <= len(names) ? Start(names[choice - 1]) : 0
enddef

export def Rerun(): number
  var matching = values(runs)
  if empty(matching)
    throw 'PlanetVim: no task to rerun in this instance'
  endif
  sort(matching, (a, b) => b.id - a.id)
  var context = planet#project#Context()
  context.file = matching[0].context.file
  return Start(matching[0].name, context)
enddef

export def Show()
  var lines = ['Project tasks: ' .. planet#project#Root(), '']
  for run in values(runs)
    add(lines, printf('%d  %s  %s', run.id, run.status, run.name))
    if has_key(run, 'error') | add(lines, '  ' .. run.error) | endif
    for entry in run.results
      add(lines, printf('  %s: %s (output buffer %d)', entry.task, entry.result.status, entry.buffer))
    endfor
  endfor
  planet#health#Scratch('PlanetVim Tasks', lines)
enddef
