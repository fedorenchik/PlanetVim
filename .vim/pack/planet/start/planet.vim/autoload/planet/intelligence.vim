scriptversion 4

let s:servers = {
      \ 'clangd': {'types': ['c', 'cpp'], 'default': ['clangd', '--background-index'],
      \   'markers': ['compile_commands.json', 'compile_flags.txt', '.clangd', 'CMakeLists.txt', '.git/'],
      \   'help': 'Install clangd and put it on PATH, or set g:PV_clangd_argv to its executable and arguments. Generate compile_commands.json for project include paths.'},
      \ 'pylsp': {'types': ['python'], 'default': ['pylsp'],
      \   'markers': ['pyproject.toml', 'setup.cfg', 'setup.py', 'requirements.txt', '.git/'],
      \   'help': 'Install python-lsp-server[all] in your Python environment and set g:PV_pylsp_argv to its pylsp executable. The all extras provide diagnostics and autopep8 formatting.'}}

func! s:Argv(name) abort
  return get(g:, 'PV_' .. a:name .. '_argv', s:servers[a:name].default)
endfunc

func! s:Valid(argv) abort
  return type(a:argv) == v:t_list && !empty(a:argv)
        \ && empty(filter(copy(a:argv), 'type(v:val) != v:t_string || v:val =~# "[\\r\\n]"'))
        \ && !empty(a:argv[0])
endfunc

func! s:Name() abort
  for [l:name, l:server] in items(s:servers)
    if index(l:server.types, &filetype) >= 0
      return l:name
    endif
  endfor
  return ''
endfunc

func! planet#intelligence#Root(name, ...) abort
  let l:path = a:0 ? a:1 : expand('%:p')
  let l:start = fnamemodify(l:path, ':p:h')
  let l:directory = l:start
  " Walk literal paths: findfile() treats commas/spaces as path separators.
  while !empty(l:directory)
    for l:marker in s:servers[a:name].markers
      let l:candidate = l:directory .. '/' .. l:marker
      if filereadable(l:candidate) || isdirectory(l:candidate)
        return lsp#utils#path_to_uri(l:directory)
      endif
    endfor
    let l:parent = fnamemodify(l:directory, ':h')
    if l:parent ==# l:directory | break | endif
    let l:directory = l:parent
  endwhile
  return lsp#utils#path_to_uri(l:start)
endfunc

func! planet#intelligence#Register() abort
  if !get(g:, 'PV_intelligence_enabled', 1)
    return
  endif
  for [l:name, l:server] in items(s:servers)
    let l:argv = s:Argv(l:name)
    if !s:Valid(l:argv) || !executable(l:argv[0]) || index(lsp#get_server_names(), 'planet-' .. l:name) >= 0
      continue
    endif
    let l:info = {'name': 'planet-' .. l:name, 'cmd': copy(l:argv),
          \ 'allowlist': copy(l:server.types),
          \ 'root_uri': function('s:Root', [l:name])}
    if l:name ==# 'pylsp'
      let l:info.workspace_config = {'pylsp': get(g:, 'PV_pylsp_settings', {})}
    endif
    call lsp#register_server(l:info)
  endfor
endfunc

func! s:Root(name, server) abort
  return planet#intelligence#Root(a:name)
endfunc

func! planet#intelligence#Status() abort
  let l:result = {}
  for [l:name, l:server] in items(s:servers)
    let l:argv = s:Argv(l:name)
    let l:status = !get(g:, 'PV_intelligence_enabled', 1) || (type(l:argv) == v:t_list && empty(l:argv)) ? 'disabled'
          \ : !s:Valid(l:argv) ? 'invalid command (expected an argv List)'
          \ : !executable(l:argv[0]) ? 'executable missing'
          \ : lsp#get_server_status('planet-' .. l:name)
    let l:result[l:name] = {'status': l:status, 'command': l:argv, 'help': l:server.help}
  endfor
  return l:result
endfunc

func! planet#intelligence#ShowStatus() abort
  for [l:name, l:info] in items(planet#intelligence#Status())
    echom 'PlanetVim ' .. l:name .. ': ' .. l:info.status .. ' ' .. string(l:info.command)
    if l:info.status !=# 'running' && l:info.status !=# 'disabled'
      echom l:info.help
    endif
  endfor
endfunc

func! planet#intelligence#Action(command) abort
  if index(['LspDefinition', 'LspReferences', 'LspHover', 'LspRename', 'LspDocumentFormatSync',
        \ 'LspDocumentDiagnostics', 'LspImplementation', 'LspTypeDefinition',
        \ 'LspNextDiagnostic', 'LspPreviousDiagnostic'], a:command) < 0
    throw 'PlanetVim: unsupported language action'
  endif
  let l:name = s:Name()
  if empty(l:name)
    echom 'PlanetVim: language actions currently support C, C++ and Python. Use :PlanetLspStatus for setup.'
    return 0
  endif
  let l:info = planet#intelligence#Status()[l:name]
  if l:info.status !=# 'running'
    echom 'PlanetVim ' .. l:name .. ': ' .. l:info.status .. '. ' .. l:info.help
    return 0
  endif
  execute a:command
  return 1
endfunc

func! planet#intelligence#CompletionSources() abort
  if !get(g:, 'PV_intelligence_enabled', 1)
    return
  endif
  if index(asyncomplete#get_source_names(), 'planet-buffer') < 0
    call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
          \ 'name': 'planet-buffer', 'allowlist': ['*'], 'priority': 5,
          \ 'completor': function('asyncomplete#sources#buffer#completor'),
          \ 'config': {'max_buffer_size': 5000000}}))
  endif
  if index(asyncomplete#get_source_names(), 'planet-file') < 0
    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
          \ 'name': 'planet-file', 'allowlist': ['*'], 'priority': 10,
          \ 'completor': function('asyncomplete#sources#file#completor')}))
  endif
  " asyncomplete-lsp registers one source for each initialized LSP server.
  " An additional omnifunc source would duplicate those suggestions.
endfunc

func! s:Map(lhs, command) abort
  let l:previous = maparg(a:lhs, 'n', 0, 1)
  call add(b:PV_intelligence_maps, {'lhs': a:lhs,
        \ 'previous': get(l:previous, 'buffer', 0) ? l:previous : {}})
  execute 'nnoremap <silent> <buffer> ' .. a:lhs
        \ .. ' <Cmd>call planet#intelligence#Action(' .. string(a:command) .. ')<CR>'
endfunc

func! planet#intelligence#Undo() abort
  for l:item in get(b:, 'PV_intelligence_maps', [])
    execute 'silent! nunmap <buffer> ' .. l:item.lhs
    if !empty(l:item.previous)
      call mapset('n', 0, l:item.previous)
    endif
  endfor
  for [l:option, l:value] in items(get(b:, 'PV_intelligence_options', {}))
    execute 'let &l:' .. l:option .. ' = l:value'
  endfor
  if exists('b:PV_intelligence_undo')
    let b:undo_ftplugin = b:PV_intelligence_undo
  endif
  unlet! b:PV_intelligence_maps b:PV_intelligence_options b:PV_intelligence_undo
endfunc

func! planet#intelligence#SetupBuffer() abort
  if !get(g:, 'PV_intelligence_enabled', 1) || exists('b:PV_intelligence_maps') || empty(s:Name())
    return
  endif
  let b:PV_intelligence_maps = []
  let b:PV_intelligence_options = {}
  let b:PV_intelligence_undo = get(b:, 'undo_ftplugin', '')
  let b:undo_ftplugin = 'call planet#intelligence#Undo()'
        \ .. (empty(b:PV_intelligence_undo) ? '' : ' | ' .. b:PV_intelligence_undo)
  for [l:key, l:command] in items({'gd': 'LspDefinition', 'gr': 'LspReferences',
        \ 'gi': 'LspImplementation', 'gy': 'LspTypeDefinition', 'K': 'LspHover',
        \ '<leader>rn': 'LspRename', '<leader>f': 'LspDocumentFormatSync',
        \ '[d': 'LspPreviousDiagnostic', ']d': 'LspNextDiagnostic'})
    call s:Map(l:key, l:command)
  endfor
endfunc

func! planet#intelligence#Attach() abort
  call planet#intelligence#SetupBuffer()
  if !exists('b:PV_intelligence_options')
    return
  endif
  for [l:option, l:value] in items({'omnifunc': 'lsp#complete', 'tagfunc': 'lsp#tagfunc'})
    if !has_key(b:PV_intelligence_options, l:option)
      let b:PV_intelligence_options[l:option] = eval('&l:' .. l:option)
    endif
    execute 'let &l:' .. l:option .. ' = l:value'
  endfor
endfunc
