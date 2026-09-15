vim9script
export def CopyFile(file: any): any
  return planet#generate#CopyFile(file)
enddef

# Project files contain data only. Opening a project never executes a task.
export def Root(): string
  return fnamemodify(resolve(getcwd(-1, 0)), ':p:h')
enddef

export def Merge(base: dict<any>, extra: dict<any>): dict<any>
  var result = deepcopy(base)
  for [key, value] in items(extra)
    result[key] = type(value) == v:t_dict && type(get(result, key, 0)) == v:t_dict
      ? Merge(result[key], value) : deepcopy(value)
  endfor
  return result
enddef

export def File(private: bool = false, root: string = Root()): string
  return private ? planet#paths#Config('projects') .. '/' .. sha256(root) .. '.json' : root .. '/.planetvim.json'
enddef

def Read(path: string): dict<any>
  if !filereadable(path)
    return {}
  endif
  var data = json_decode(join(readfile(path), "\n"))
  if type(data) != v:t_dict || get(data, 'version', 1) != 1
    throw 'PlanetVim: invalid project settings: ' .. path
  endif
  return data
enddef

export def Settings(root: string = Root()): dict<any>
  return Merge(Read(File(false, root)), Read(File(true, root)))
enddef

export def Context(): dict<any>
  var state = planet#run#Project()
  var settings = Settings(state.root)
  var selected = get(state, 'configuration', get(settings, 'default', ''))
  var configurations = get(settings, 'configurations', {})
  if type(configurations) != v:t_dict || (!empty(selected) && !has_key(configurations, selected))
    throw 'PlanetVim: unknown project configuration: ' .. string(selected)
  endif
  var config = Merge(get(settings, 'defaults', {}), get(configurations, selected, {}))
  for key in ['source_dir', 'build_dir', 'cwd', 'program', 'build_type', 'target', 'preset']
    if type(get(config, key, '')) != v:t_string
      throw 'PlanetVim: project ' .. key .. ' must be a String'
    endif
  endfor
  for key in ['environment', 'tools', 'lsp', 'tasks']
    if type(get(config, key, {})) != v:t_dict
      throw 'PlanetVim: project ' .. key .. ' must be an Object'
    endif
  endfor
  for key in ['args', 'python', 'configure_args']
    var value = get(config, key, [])
    if type(value) != v:t_list || !empty(filter(copy(value), (_, item) => type(item) != v:t_string))
      throw 'PlanetVim: project ' .. key .. ' must be a String array'
    endif
  endfor
  for [key, value] in items(get(config, 'environment', {}))
    if key !~# '^\h\w*$' || (value != null && type(value) != v:t_string)
      throw 'PlanetVim: environment values must be Strings or null'
    endif
  endfor
  config.root = state.root
  config.configuration = selected
  config.source_dir = planet#run#Path(get(config, 'source_dir', '.'), state.root)
  config.build_dir = get(get(state, 'build_dirs', {}), selected, get(config, 'build_dir', empty(selected) ? state.build_dir : ''))
  if !empty(config.build_dir)
    config.build_dir = planet#run#Path(config.build_dir, state.root)
  endif
  config.cwd = planet#run#Path(get(config, 'cwd', '.'), state.root)
  config.target = get(get(state, 'targets', {}), selected, get(config, 'target', ''))
  config.environment = Merge(get(config, 'environment', {}), get(get(state, 'environments', {}), selected, {}))
  config.env_snapshot = planet#project_env#Values(config)
  return config
enddef

export def Select(name: string = ''): number
  var settings = Settings()
  var names = sort(keys(get(settings, 'configurations', {})))
  var selected = name
  if empty(selected)
    var choice = inputlist(['Project configuration:'] + map(copy(names), (i, value) => (i + 1) .. '. ' .. value))
    if choice < 1 || choice > len(names)
      return 0
    endif
    selected = names[choice - 1]
  endif
  if index(names, selected) < 0
    throw 'PlanetVim: unknown configuration: ' .. selected
  endif
  var state = planet#run#Project()
  state.configuration = selected
  return planet#run#Save()
enddef

export def Edit(private: bool = false)
  var path = File(private)
  execute 'edit ' .. fnameescape(path)
  if !filereadable(path) && line('$') == 1 && getline(1) == ''
    setline(1, ['{', '  "version": 1,', '  "defaults": {},', '  "configurations": {}', '}'])
  endif
  setlocal filetype=json
enddef

export def Show()
  var context = Context()
  planet#health#Scratch('PlanetVim Project', ['Project: ' .. context.root,
    'Configuration: ' .. context.configuration, 'Source: ' .. context.source_dir,
    'Build: ' .. context.build_dir, 'Target: ' .. context.target,
    'Run directory: ' .. context.cwd, 'Program: ' .. get(context, 'program', ''),
    'Environment variable names: ' .. join(sort(keys(context.environment)), ', '),
    'Shared settings: ' .. File(), 'Private settings: ' .. File(true)])
enddef

export def CopyDir(dir: any): any
  return planet#generate#CopyDir(dir)
enddef
