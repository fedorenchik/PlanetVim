vim9script

var package = expand('<script>:p:h:h:h')->resolve()

# CMake validates presets; the helper resolves binaryDir before placing the query.
export def Preset(context: dict<any>, name: string = ''): dict<any>
  var input = tempname()
  var output = tempname()
  var errors = tempname()
  var python = planet#generate#Python()
  if empty(python) | throw 'PlanetVim: CMake presets require Python 3' | endif
  writefile([json_encode({source_dir: context.source_dir, preset: name,
    cmake: planet#project_env#Command(['cmake'], context)})], input)
  setfperm(input, 'rw-------')
  for path in [output, errors]
    writefile([], path)
    setfperm(path, 'rw-------')
  endfor
  var job = job_start(planet#project_env#Native(python + [package .. '/bin/cmake-presets.py', input], context),
    {cwd: context.source_dir, env: context.env_snapshot, in_io: 'null', out_io: 'file', out_name: output,
     err_io: 'file', err_name: errors})
  try
    var start = reltime()
    while job_status(job) ==# 'run' && reltimefloat(reltime(start)) < 12
      sleep 10m
    endwhile
    if job_status(job) ==# 'run'
      job_stop(job, 'kill')
      throw 'PlanetVim: CMake preset discovery timed out'
    endif
    var result = json_decode(join(readfile(output), "\n"))
    if has_key(result, 'error') | throw 'PlanetVim: ' .. result.error | endif
    if job_info(job).exitval != 0 | throw 'PlanetVim: CMake preset discovery failed' | endif
    return result
  finally
    delete(input)
    delete(output)
    delete(errors)
  endtry
  return {}
enddef

export def Prepare(context: dict<any>, query: bool = true)
  if !empty(get(context, 'preset', '')) && !has_key(context, 'preset_environment')
    var preset = Preset(context, context.preset)
    if empty(context.build_dir) | context.build_dir = preset.build_dir | endif
    context.preset_environment = preset.environment
  endif
  if empty(context.build_dir) | context.build_dir = context.root .. '/build' | endif
  if query
    var directory = context.build_dir .. '/.cmake/api/v1/query/client-planetvim'
    mkdir(directory, 'p')
    writefile([json_encode({requests: [{kind: 'codemodel', version: 2}, {kind: 'toolchains', version: 1}]})], directory .. '/query.json')
  endif
enddef

def Read(path: string): dict<any>
  return json_decode(join(readfile(path), "\n"))
enddef

export def Model(context: dict<any>): dict<any>
  var directory = context.build_dir .. '/.cmake/api/v1/reply/'
  if empty(context.build_dir) || !isdirectory(directory)
    throw 'PlanetVim: configure with Build > CMake > Configure before selecting a target'
  endif
  var indices = sort(readdir(directory, (name) => name =~# '^index-.*\.json$'))
  if empty(indices) | throw 'PlanetVim: no CMake File API reply; configure this project first' | endif
  var index = Read(directory .. indices[-1])
  var client = get(get(index, 'reply', {}), 'client-planetvim', {})
  var responses = get(get(client, 'query.json', {}), 'responses', [])
  var models = filter(copy(responses), (_, value) => get(value, 'kind', '') ==# 'codemodel' && has_key(value, 'jsonFile'))
  if empty(models) | throw 'PlanetVim: CMake did not return a codemodel; configure with CMake 3.20 or newer' | endif
  var model = Read(directory .. models[0].jsonFile)
  var selected = get(context, 'build_type', '')
  var configurations = model.configurations
  var matches = filter(copy(configurations), (_, value) => value.name ==# selected)
  if empty(matches) && !empty(selected)
    throw 'PlanetVim: CMake configuration is unavailable: ' .. selected .. '; configure or select another configuration'
  endif
  var configuration = empty(matches) ? configurations[0] : matches[0]
  var targets: list<any> = []
  for item in get(configuration, 'targets', [])
    var target = Read(directory .. item.jsonFile)
    add(targets, {name: target.name, type: target.type,
      artifacts: map(get(target, 'artifacts', []), (_, artifact) => planet#run#Path(artifact.path, model.paths.build))})
  endfor
  return {build_dir: model.paths.build, source_dir: model.paths.source, configuration: configuration.name,
    configurations: map(copy(configurations), (_, value) => value.name), targets: targets}
enddef

export def Program(context: dict<any>): string
  var targets = Model(context).targets
  if !empty(context.target)
    targets = filter(targets, (_, target) => target.name ==# context.target)
  else
    targets = filter(targets, (_, target) => target.type ==# 'EXECUTABLE')
  endif
  if len(targets) != 1 || targets[0].type !=# 'EXECUTABLE' || empty(targets[0].artifacts)
    throw 'PlanetVim: choose one executable with :PlanetCmakeTarget, or set program in project settings'
  endif
  return targets[0].artifacts[0]
enddef

# Use the originating state, never the tab selected when CMake finishes.
export def Configured(context: dict<any>, state: dict<any>)
  var model = Model(context)
  context.build_dir = model.build_dir
  if empty(get(context, 'build_type', '')) | context.build_type = model.configuration | endif
  state.build_dirs = get(state, 'build_dirs', {})
  state.build_dirs[context.configuration] = model.build_dir
  if empty(context.configuration) | state.build_dir = model.build_dir | endif
  if !planet#run#Save(state) | throw 'PlanetVim: could not save configured build directory' | endif
  if has_key(context, 'preset_environment') | context.env_snapshot = context.preset_environment | endif
  if planet#project#Root() ==# context.root | planet#intelligence#Refresh() | endif
enddef

export def Select(kind: string, name: string = ''): number
  var context = planet#project#Context()
  var model: dict<any> = {}
  var names: list<string>
  if kind ==# 'preset'
    names = Preset(context).names
  else
    model = Model(context)
    names = kind ==# 'target' ? map(copy(model.targets), (_, target) => target.name) : model.configurations
  endif
  var selected = name
  if empty(selected)
    var choice = inputlist(['CMake ' .. kind .. ':'] + map(copy(names), (i, item) => (i + 1) .. '. ' .. (empty(item) ? '(default)' : item)))
    if choice < 1 || choice > len(names) | return 0 | endif
    selected = names[choice - 1]
  endif
  if index(names, selected) < 0 | throw 'PlanetVim: unknown CMake ' .. kind .. ': ' .. selected | endif
  var state = planet#run#Project()
  var previous = deepcopy(state)
  var key = kind ==# 'preset' ? 'presets' : kind ==# 'target' ? 'targets' : 'build_types'
  state[key] = get(state, key, {})
  state[key][context.configuration] = selected
  if kind ==# 'preset'
    # A preset selection chooses its binaryDir rather than the previous preset's.
    state.build_dirs = get(state, 'build_dirs', {})
    state.build_dirs[context.configuration] = Preset(context, selected).build_dir
    if empty(context.configuration) | state.build_dir = state.build_dirs[context.configuration] | endif
    for field in ['targets', 'build_types']
      if has_key(get(state, field, {}), context.configuration) | remove(state[field], context.configuration) | endif
    endfor
  endif
  if !planet#run#Save(state)
    extend(state, previous, 'force')
    return 0
  endif
  planet#intelligence#Refresh()
  return 1
enddef

export def Show()
  var model = Model(planet#project#Context())
  planet#health#Scratch('PlanetVim CMake', ['Source: ' .. model.source_dir, 'Build: ' .. model.build_dir,
    'Configuration: ' .. model.configuration, ''] + map(model.targets,
    (_, target) => target.name .. ' [' .. target.type .. '] ' .. join(target.artifacts, ', ')))
enddef
