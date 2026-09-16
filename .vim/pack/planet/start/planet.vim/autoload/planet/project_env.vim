vim9script

export def Set(values: dict<any>): number
  var state = planet#run#Project()
  var context = planet#project#Context()
  state.environments = get(state, 'environments', {})
  var previous = deepcopy(get(state.environments, context.configuration, {}))
  state.environments[context.configuration] = planet#project#Merge(previous, values)
  if !planet#run#Save(state)
    state.environments[context.configuration] = previous
    return 0
  endif
  planet#intelligence#Refresh()
  return 1
enddef

export def Values(context: dict<any>): dict<any>
  if has_key(context, 'env_snapshot')
    return copy(context.env_snapshot)
  endif
  var environment = environ()
  for [key, value] in items(get(context, 'environment', {}))
    if value == null
      if has_key(environment, key)
        remove(environment, key)
      endif
    else
      var expanded = substitute(value, '${root}', (_) => context.root, 'g')
      expanded = substitute(expanded, '${env:\(\h\w*\)}', (m) => get(environ(), m[1], ''), 'g')
      environment[key] = expanded
    endif
  endfor
  return environment
enddef

export def Find(name: string, context: dict<any>, cwd: string = ''): string
  var directory = empty(cwd) ? context.root : cwd
  if name =~# '[/\\]'
    var path = name =~# '^/\|^\a:' ? name : directory .. '/' .. name
    return executable(path) ? path : ''
  endif
  for entry in split(get(Values(context), 'PATH', ''), has('win32') ? ';' : ':', 1)
    var path = (empty(entry) ? directory : entry =~# '^/' ? entry : directory .. '/' .. entry) .. '/' .. name
    if executable(path)
      return path
    endif
    if has('win32') && executable(path .. '.exe')
      return path .. '.exe'
    endif
  endfor
  return ''
enddef

export def Command(argv: list<any>, context: dict<any>, cwd: string = ''): list<any>
  var override = get(get(context, 'tools', {}), argv[0], argv[0])
  var result = (type(override) == v:t_list ? copy(override) : [override]) + argv[1 :]
  if empty(result) || !empty(filter(copy(result), (_, value) => type(value) != v:t_string)) || empty(result[0])
    throw 'PlanetVim: tool command must be a nonempty String array'
  endif
  var found = Find(result[0], context, cwd)
  if !empty(found)
    result[0] = found
  endif
  return result
enddef

export def Native(argv: list<any>, context: dict<any>, cwd: string = ''): list<any>
  var command = Command(argv, context, cwd)
  if has('unix')
    var environment = Values(context)
    var unset = filter(keys(environ()), (_, key) => !has_key(environment, key))
    if !empty(unset)
      var prefix = [exepath('env')]
      for key in unset
        prefix += ['-u', key]
      endfor
      return prefix + ['--'] + command
    endif
  endif
  return command
enddef
