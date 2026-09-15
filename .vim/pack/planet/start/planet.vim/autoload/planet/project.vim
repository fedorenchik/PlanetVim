vim9script

var settings_cache: dict<any> = {}

export def CopyFile(file: any): any
  return planet#generate#CopyFile(file)
enddef

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
  return private ? planet#paths#Config('projects') .. '/' .. sha256(root) .. '.vim' : root .. '/.planetvim.vim'
enddef

def TrustFile(root: string): string
  return planet#paths#State('project-trust') .. '/' .. sha256(root) .. '.sha256'
enddef

def Digest(path: string): string
  return sha256(join(readfile(path, 'b'), "\n"))
enddef

def Read(path: string, root: string, private: bool): dict<any>
  if has_key(settings_cache, path)
    var cached = settings_cache[path]
    if has_key(cached, 'error')
      throw cached.error
    endif
    return deepcopy(cached.config)
  endif
  if !filereadable(path)
    return {}
  endif
  # Cache failures too: buffer events must not repeatedly execute a broken file.
  settings_cache[path] = {error: 'PlanetVim: recursive project settings load: ' .. path}
  try
    if !private
      var trust = TrustFile(root)
      if !filereadable(trust) || readfile(trust) != [Digest(path)]
        throw 'Shared settings need approval; review ' .. path .. ' then run :PlanetProjectReload!'
      endif
    endif
    execute 'source ' .. fnameescape(path)
    var scripts = getscriptinfo({name: '^\V' .. escape(fnamemodify(path, ':p'), '\') .. '\m$'})
    if empty(scripts)
      throw 'Could not inspect settings script'
    endif
    var script = scripts[-1]
    var info = getscriptinfo({sid: script.sourced > 0 ? script.sourced : script.sid})[0]
    var data = get(info.variables, 'config', null)
    if info.version != 999999 || type(data) != v:t_dict
      throw 'Expected vim9script with export var config: dict<any>'
    endif
    settings_cache[path] = {config: deepcopy(data)}
  catch
    var message = 'PlanetVim: cannot load project settings ' .. path .. ': ' .. v:exception
    settings_cache[path] = {error: message}
    throw message
  endtry
  return deepcopy(settings_cache[path].config)
enddef

export def Settings(root: string = Root()): dict<any>
  return Merge(Read(File(false, root), root, false), Read(File(true, root), root, true))
enddef

export def Reload(trust: bool = false): dict<any>
  var root = Root()
  var shared = File(false, root)
  if trust && filereadable(shared)
    var record = TrustFile(root)
    writefile([Digest(shared)], record)
    setfperm(record, 'rw-------')
  endif
  for path in [shared, File(true, root)]
    if has_key(settings_cache, path)
      remove(settings_cache, path)
    endif
  endfor
  var context = Context()
  planet#intelligence#Refresh()
  return context
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
      throw 'PlanetVim: project ' .. key .. ' must be a Dictionary'
    endif
  endfor
  for key in ['args', 'python', 'configure_args']
    var value = get(config, key, [])
    if type(value) != v:t_list || !empty(filter(copy(value), (_, item) => type(item) != v:t_string))
      throw 'PlanetVim: project ' .. key .. ' must be a List of Strings'
    endif
  endfor
  for [key, value] in items(get(config, 'environment', {}))
    if key !~# '^\h\w*$' || (value != null && type(value) != v:t_string)
      throw 'PlanetVim: environment values must be Strings or null'
    endif
  endfor
  config.tools = Merge(get(g:, 'PV_integration_tools', {}), get(config, 'tools', {}))
  config.root = state.root
  config.configuration = selected
  config.source_dir = planet#run#Path(get(config, 'source_dir', '.'), state.root)
  config.build_dir = get(get(state, 'build_dirs', {}), selected, get(config, 'build_dir', empty(selected) ? state.build_dir : ''))
  if !empty(config.build_dir)
    config.build_dir = planet#run#Path(config.build_dir, state.root)
  endif
  config.cwd = planet#run#Path(get(config, 'cwd', '.'), state.root)
  config.target = get(get(state, 'targets', {}), selected, get(config, 'target', ''))
  config.preset = get(get(state, 'presets', {}), selected, get(config, 'preset', ''))
  config.build_type = get(get(state, 'build_types', {}), selected, get(config, 'build_type', ''))
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
    setline(1, ['vim9script', '', 'export var config: dict<any> = {', '  defaults: {},', '  configurations: {},', '}'])
  endif
  setlocal filetype=vim
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
