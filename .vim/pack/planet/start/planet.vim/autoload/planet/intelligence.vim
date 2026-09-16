vim9script

var script_servers = { 'clangd': {'types': ['c', 'cpp'], 'default': ['clangd', '--background-index'],
     'help': 'Install clangd and put it on PATH, or set g:PV_clangd_argv to its executable and arguments. Generate compile_commands.json for project include paths.'},
     'pylsp': {'types': ['python'], 'default': ['pylsp'], 'help': 'Install python-lsp-server[all] in your Python environment and set g:PV_pylsp_argv to its pylsp executable. The all extras provide diagnostics and autopep8 formatting.'}}

def LocalArgv(name: any, context: any = planet#project#Context()): any
  var fallback = name ==# 'pylsp' && !empty(get(context, 'python', []))
    ? context.python + ['-m', 'pylsp'] : get(g:, 'PV_' .. name .. '_argv', script_servers[name].default)
  var argv = get(get(context, 'lsp', {}), name, fallback)
  if name ==# 'clangd' && type(argv) == v:t_list && !empty(argv) && !empty(context.build_dir)
        && filereadable(context.build_dir .. '/compile_commands.json')
        && empty(filter(copy(argv), (_, arg) => type(arg) == v:t_string && stridx(arg, '--compile-commands-dir') == 0))
    argv = argv + ['--compile-commands-dir=' .. context.build_dir]
  endif
  return argv
enddef

export def Refresh()
  if exists('*lsp#get_server_names')
    try
      Register()
      if !empty(LocalName()) | lsp#activate() | endif
    catch
      echom 'PlanetVim language setup: ' .. v:exception
    endtry
  endif
enddef

def LocalValid(argv: any): any
  return type(argv) == v:t_list && !empty(argv) && empty(filter(copy(argv), (_, value) => type(value) != v:t_string || value =~# '[\r\n]')) && !empty(argv[0])
enddef

def LocalName(): any
  for [name, server] in items(script_servers)
    if index(server.types, &filetype) >= 0
      return name
    endif
  endfor
  return ''
enddef

export def Root(name: any, ...args: list<any>): any
  return lsp#utils#path_to_uri(planet#project#Context().source_dir)
enddef

export def Register(): any
  # Failed settings cannot leave a previous environment active.
  for name in keys(script_servers)
    var previous = lsp#get_server_info('planet-' .. name)
    if !empty(previous) | previous.allowlist = [] | endif
  endfor
  var context = planet#project#Context()
  for [name, server] in items(script_servers)
    var id = 'planet-' .. name
    var argv = LocalArgv(name, context)
    var enabled = get(g:, 'PV_intelligence_enabled', 1) && LocalValid(argv)
      && !empty(planet#project_env#Find(argv[0], context))
    var settings = {root: context.source_dir,
      cmd: enabled ? planet#project_env#Native(argv, context) : [],
      env: context.env_snapshot, enabled: enabled,
      workspace: name ==# 'pylsp' ? get(context, 'pylsp_settings', get(g:, 'PV_pylsp_settings', {})) : {}}
    var previous = lsp#get_server_info(id)
    if empty(previous) && !enabled | continue | endif
    if get(previous, 'planet_settings', {}) ==# settings
      previous.allowlist = enabled ? copy(server.types) : []
      continue
    endif
    if index(['starting', 'running'], lsp#get_server_status(id)) >= 0
      # A fixed registration must outlive its old process's exit callback.
      # This runs only on explicit setup/configuration changes, never tab entry.
      lsp#stop_server(id)
      for attempt in range(100)
        if lsp#get_server_status(id) ==# 'exited' | break | endif
        sleep 10m
      endfor
      if lsp#get_server_status(id) !=# 'exited'
        throw 'PlanetVim: language server is still stopping; retry :PlanetLspSetup'
      endif
    endif
    var info = {name: id, cmd: settings.cmd, env: settings.env,
      allowlist: enabled ? copy(server.types) : [], planet_settings: deepcopy(settings),
      root_uri: (server_info) => lsp#utils#path_to_uri(server_info.planet_settings.root)}
    if name ==# 'pylsp' | info.workspace_config = {pylsp: settings.workspace} | endif
    lsp#register_server(info)
  endfor
  return 0
enddef

export def Status(): any
  var argv: any
  var status: any
  var result: any = {}
  var context = planet#project#Context()
  for [name, server] in items(script_servers)
    argv = LocalArgv(name, context)
    status = !get(g:, 'PV_intelligence_enabled', 1) || (type(argv) == v:t_list && empty(argv)) ? 'disabled' : !LocalValid(argv) ? 'invalid command (expected an argv List)' : empty(planet#project_env#Find(argv[0], context)) ? 'executable missing' : lsp#get_server_status('planet-' .. name)
    result[name] = {'status':  status, 'command':  argv, 'help':  server.help}
  endfor
  return result
enddef

export def ShowStatus(): any
  for [name, info] in items(planet#intelligence#Status())
    echom 'PlanetVim ' .. name .. ': ' .. info.status .. ' ' .. string(info.command)
    if info.status !=# 'running' && info.status !=# 'disabled'
      echom info.help
    endif
  endfor
  return 0
enddef

export def Action(command: any): any
  if index(['LspDefinition', 'LspReferences', 'LspHover', 'LspRename', 'LspDocumentFormatSync', 'LspDocumentDiagnostics',
       'LspImplementation', 'LspTypeDefinition', 'LspNextDiagnostic', 'LspPreviousDiagnostic'], command) < 0
    throw 'PlanetVim: unsupported language action'
  endif
  var name: any = LocalName()
  if empty(name)
    echom 'PlanetVim: language actions currently support C, C++ and Python. Use :PlanetLspStatus for setup.'
    return 0
  endif
  var info: any = planet#intelligence#Status()[name]
  if info.status !=# 'running'
    echom 'PlanetVim ' .. name .. ': ' .. info.status .. '. ' .. info.help
    return 0
  endif
  execute command
  return 1
enddef

export def CompletionSources(): any
  if !get(g:, 'PV_intelligence_enabled', 1)
    return 0
  endif
  if index(asyncomplete#get_source_names(), 'planet-buffer') < 0
    asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({  'name':  'planet-buffer', 'allowlist':  ['*'], 'priority':  5,  'completor':  function('asyncomplete#sources#buffer#completor'),  'config':  {'max_buffer_size':  5000000}}))
  endif
  if index(asyncomplete#get_source_names(), 'planet-file') < 0
    asyncomplete#register_source(asyncomplete#sources#file#get_source_options({  'name':  'planet-file', 'allowlist':  ['*'], 'priority':  10,  'completor':  function('asyncomplete#sources#file#completor')}))
  endif
  # asyncomplete-lsp registers one source for each initialized LSP server.
  # An additional omnifunc source would duplicate those suggestions.
  return 0
enddef

def LocalMap(lhs: any, command: any): any
  var previous: any = maparg(lhs, 'n', 0, 1)
  add(b:PV_intelligence_maps, {'lhs': lhs, 'previous': get(previous, 'buffer', 0) ? previous : {}})
  execute 'nnoremap <silent> <buffer> ' .. lhs .. ' <Cmd>call planet#intelligence#Action(' .. string(command) .. ')<CR>'
  return 0
enddef

export def Undo(): any
  for item in get(b:, 'PV_intelligence_maps', [])
    execute 'silent! nunmap <buffer> ' .. item.lhs
    if !empty(item.previous)
      mapset('n', 0, item.previous)
    endif
  endfor
  for [option, value] in items(get(b:, 'PV_intelligence_options', {}))
    execute '&l:' .. option .. ' = ' .. string(value)
  endfor
  if exists('b:PV_intelligence_undo')
    b:undo_ftplugin = b:PV_intelligence_undo
  endif
  unlet! b:PV_intelligence_maps b:PV_intelligence_options b:PV_intelligence_undo
  return 0
enddef

export def SetupBuffer(): any
  if !get(g:, 'PV_intelligence_enabled', 1) || exists('b:PV_intelligence_maps') || empty(LocalName())
    return 0
  endif
  b:PV_intelligence_maps = []
  b:PV_intelligence_options = {}
  b:PV_intelligence_undo = get(b:, 'undo_ftplugin', '')
  b:undo_ftplugin = 'call planet#intelligence#Undo()'  .. (empty(b:PV_intelligence_undo) ? '' :  ' | ' .. b:PV_intelligence_undo)
  for [key, command] in items({'gd': 'LspDefinition', 'gr': 'LspReferences', 'gi': 'LspImplementation', 'gy': 'LspTypeDefinition', 'K': 'LspHover', '<leader>rn': 'LspRename', '<leader>f': 'LspDocumentFormatSync', '[d': 'LspPreviousDiagnostic', ']d': 'LspNextDiagnostic'})
    LocalMap(key, command)
  endfor
  return 0
enddef

export def Attach(): any
  planet#intelligence#SetupBuffer()
  if !exists('b:PV_intelligence_options')
    return 0
  endif
  for [option, value] in items({'omnifunc': 'lsp#complete', 'tagfunc': 'lsp#tagfunc'})
    if !has_key(b:PV_intelligence_options, option)
      b:PV_intelligence_options[option] = eval('&l:' .. option)
    endif
    execute '&l:' .. option .. ' = ' .. string(value)
  endfor
  return 0
enddef
