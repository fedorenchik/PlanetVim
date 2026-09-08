scriptversion 4
let s:runtime = expand('<sfile>:p:h:h:h')

func! s:Directory(kind) abort
  let l:value = get(g:, 'PV_' .. a:kind .. '_dir', getenv('PLANETVIM_' .. toupper(a:kind) .. '_DIR'))
  if l:value is v:null || empty(l:value)
    if has('win32')
      let l:value = (empty($LOCALAPPDATA) ? expand('~/AppData/Local') : $LOCALAPPDATA) .. '/PlanetVim/' .. a:kind
    else
      let l:xdg = {'config': ['XDG_CONFIG_HOME', '~/.config'], 'state': ['XDG_STATE_HOME', '~/.local/state'], 'cache': ['XDG_CACHE_HOME', '~/.cache']}[a:kind]
      let l:base = getenv(l:xdg[0])
      let l:value = (l:base is v:null || empty(l:base) ? expand(l:xdg[1]) : l:base) .. '/planetvim'
    endif
  endif
  return fnamemodify(l:value, ':p')->substitute('[/\\]\+$', '', '')
endfunc

func! s:DirectoryItem(kind) abort
  let l:path = s:Directory(tolower(a:kind))
  let l:parent = l:path
  while getftype(l:parent) ==# '' && fnamemodify(l:parent, ':h') !=# l:parent
    let l:parent = fnamemodify(l:parent, ':h')
  endwhile
  let l:ok = isdirectory(l:parent) && filewritable(l:parent) == 2
  return #{name:a:kind .. ' directory', ok:l:ok,
        \ help:l:path .. (l:ok ? '; writable directory/parent found (no write probe performed).' : '; directory or nearest existing parent is not writable.')}
endfunc

func! s:CommandItem(name, argv, help, optional = 1) abort
  let l:argv = type(a:argv) == v:t_string ? [a:argv] : a:argv
  let l:valid = type(l:argv) == v:t_list && !empty(l:argv)
        \ && empty(filter(copy(l:argv), {_, v -> type(v) != v:t_string || v =~# '[\r\n]'}))
  let l:ok = l:valid && executable(l:argv[0])
  return #{name:a:name, ok:l:ok, optional:a:optional,
        \ argv:deepcopy(l:argv), help: (l:valid ? string(l:argv) : 'Invalid argv configuration')
        \ .. '. ' .. (l:ok ? 'Executable found; version and runtime behavior not probed. ' : '') .. a:help}
endfunc

func! s:Configured(items, label, key, default, help) abort
  call add(a:items, s:CommandItem(a:label, get(g:, a:key, a:default), a:help .. ' Configure g:' .. a:key .. '.'))
endfunc

" Read declarative SDK contracts and literal command launch sites. This keeps
" Doctor coverage in step with enabled first-party menus without executing any
" action, loading third-party modules, or inspecting a user's shell startup.
func! s:IntegrationItems(items) abort
  let l:spec_file = s:runtime .. '/data/integrations.json'
  let l:tools = {}
  let l:overrides = get(g:, 'PV_integration_tools', {})
  if type(l:overrides) != v:t_dict
    call add(a:items, #{name:'SDK executable configuration', ok:0, optional:1, help:'g:PV_integration_tools must be a Dictionary of executable/argv overrides.'})
    let l:overrides = {}
  endif
  try
    let l:specs = json_decode(join(readfile(l:spec_file), "\n"))
    for [l:id, l:spec] in items(l:specs)
      let l:name = l:spec.argv[0]
      if !has_key(l:tools, l:name)
        let l:tools[l:name] = #{qt:get(l:spec, 'qt', v:false), actions:[]}
      endif
      call add(l:tools[l:name].actions, l:id)
    endfor
  catch
    call add(a:items, #{name:'SDK command inventory', ok:0, optional:1, help:v:exception})
  endtry
  for l:file in globpath(planet#paths#Runtime(s:runtime .. '/autoload/planet'), '**/*.vim', 0, 1)
    if fnamemodify(l:file, ':t') ==# 'health.vim' | continue | endif
    for l:line in readfile(l:file)
      if l:line =~# '^\s*"' | continue | endif
      let l:match = matchlist(l:line, '\%(#\|s:\)\%(Run\|Command\|Ask\|Gui\|RunArgv\|RunGuiApp\|RunCmd\|RunInput\|RunCmdTab\)(\s*\[''\([^'']\+\)''')
      if !empty(l:match) && l:match[1] !~# '^[-:]'
        if !has_key(l:tools, l:match[1])
          let l:tools[l:match[1]] = #{qt:0, actions:[]}
        endif
        let l:label = fnamemodify(l:file, ':t:r')
        if index(l:tools[l:match[1]].actions, l:label) < 0 | call add(l:tools[l:match[1]].actions, l:label) | endif
      endif
    endfor
  endfor
  " Dynamic dispatchers, SDK prerequisites, and feature providers.
  for l:name in ['git', 'cmake', 'ctest', 'ccmake', 'cmake-gui', 'cc', 'c++', 'git-subrepo', 'git-extras',
        \ 'gdb', 'lldb', 'rr', 'live-record', 'r2', 'cutter', 'picocom', 'plink', 'ffmpeg',
        \ 'python3', 'python', 'py', 'node', 'java', 'cargo', 'ctags', 'rg', 'fd', 'fzf',
        \ 'docker', 'conda', 'aqt', 'emcc', 'em++', 'arduino-cli', 'pio', 'flutter',
        \ 'ngrok', 'nmap', 'socat', 'websocat', 'pandoc', 'latexmk', 'languagetool', 'xxd',
        \ 'x11vnc', 'vncviewer', 'Xvfb', 'xvfb-run', 'xclip', 'wl-copy']
    if !has_key(l:tools, l:name) | let l:tools[l:name] = #{qt:0, actions:['optional workflow']} | endif
  endfor
  for l:name in sort(keys(l:tools))
    let l:meta = l:tools[l:name]
    let l:label = 'Tool: ' .. l:name
    let l:help = 'Used by ' .. join(l:meta.actions, ', ') .. '.'
    if l:name =~# '%root%'
      let l:path = substitute(l:name, '%root%', '\=getcwd()', 'g')
      call add(a:items, #{name:l:label, ok:filereadable(l:path), optional:1,
            \ help:l:help .. ' Project-relative prerequisite: ' .. l:path .. '; select the source tree before running this action.'})
      continue
    endif
    let l:argv = get(l:overrides, l:name, [l:name])
    if l:meta.qt && !has_key(l:overrides, l:name)
      let l:qt_dirs = empty($QTDIR) ? [] : [$QTDIR .. '/bin', $QTDIR .. '/libexec']
      if !has('win32') | let l:qt_dirs += ['/usr/lib/qt6/bin', '/usr/lib/qt6', '/usr/lib/qt6/libexec'] | endif
      if !executable(l:name)
        for l:dir in l:qt_dirs
          if executable(l:dir .. '/' .. l:name) | let l:argv = [l:dir .. '/' .. l:name] | break | endif
        endfor
      endif
    endif
    if type(l:argv) == v:t_list && l:argv ==# [l:name] && executable(getcwd() .. '/node_modules/.bin/' .. l:name)
      let l:argv = [getcwd() .. '/node_modules/.bin/' .. l:name]
    endif
    call add(a:items, s:CommandItem(l:label, l:argv, l:help .. ' Install its SDK/CLI or configure g:PV_integration_tools[' .. string(l:name) .. '].'))
  endfor
endfunc

func! s:AdapterItems(items, root) abort
  let l:python = executable('python3') ? 'python3' : 'python'
  call s:Configured(a:items, 'Python debug adapter command', 'PV_debugpy_command', [l:python, '-m', 'debugpy.adapter'], 'Install debugpy in this interpreter.')
  call s:Configured(a:items, 'GDB debug adapter command', 'PV_gdb_command', ['gdb', '--quiet', '--nx', '--interpreter=dap'], 'GDB needs Python DAP support (GDB 14+).')
  for l:name in ['Python debug adapter command', 'GDB debug adapter command']
    let l:item = filter(copy(a:items), {_, item -> item.name ==# l:name})[0]
    if l:item.ok
      let l:item.status = 'unverified'
      let l:item.help ..= ' Adapter protocol/module support is verified on launch, not by Doctor.'
    endif
  endfor
  let l:vimspector = a:root .. '/.vim/pack/apps/opt/vimspector'
  call add(a:items, #{name:'Bundled Vimspector', ok:filereadable(l:vimspector .. '/plugin/vimspector.vim'), optional:1,
        \ help:l:vimspector .. '; loaded only when debugging starts.'})
  let l:configuration = findfile('.vimspector.json', getcwd() .. ';')
  if !empty(l:configuration)
    try
      let l:config = json_decode(join(readfile(l:configuration), "\n"))
      for [l:name, l:adapter] in items(get(l:config, 'adapters', {}))
        if has_key(l:adapter, 'command')
          call add(a:items, s:CommandItem('Project adapter: ' .. l:name, l:adapter.command,
                \ l:configuration .. '; adapter protocol, modules and credentials are checked when launched.'))
        else
          call add(a:items, #{name:'Project adapter: ' .. l:name, ok:0, optional:1, status:'unverified',
                \ help:'Custom/TCP adapter configuration in ' .. l:configuration .. '; no network connection was attempted.'})
        endif
      endfor
    catch
      call add(a:items, #{name:'Project debugger configuration', ok:0, optional:1, help:v:exception})
    endtry
  endif
  for [l:setting, l:prefix] in [['PV_debug_tools', 'Debug tool'], ['PV_test_tools', 'Test tool']]
    let l:values = get(g:, l:setting, {})
    if type(l:values) != v:t_dict
      call add(a:items, #{name:l:prefix .. ' configuration', ok:0, optional:1, help:'g:' .. l:setting .. ' must be a Dictionary.'})
      continue
    endif
    for [l:name, l:argv] in items(l:values)
      call add(a:items, s:CommandItem(l:prefix .. ': ' .. l:name, l:argv, 'Configured by g:' .. l:setting .. '.'))
    endfor
  endfor
endfunc

func! planet#health#Check() abort
  let l:items = []
  let l:root = get(g:, 'PV_root', fnamemodify(s:runtime, ':h:h:h:h:h'))
  call add(l:items, #{name:'Platform', ok:!has('mac') && !has('macunix') && (has('unix') || has('win32')), help:'Linux first; Windows secondary; GVim only.'})
  call add(l:items, #{name:'GVim version', ok:has('patch-9.1.0000'), help:'GVim 9.1 or newer is required.'})
  for l:feature in ['gui', 'menu', 'terminal', 'job', 'channel', 'timers', 'popupwin', 'persistent_undo']
    call add(l:items, #{name:'+' .. l:feature, ok:has(l:feature), help:'Install a full GVim build.'})
  endfor
  for l:kind in ['Config', 'State', 'Cache']
    try
      call add(l:items, s:DirectoryItem(l:kind))
    catch
      call add(l:items, #{name:l:kind .. ' directory', ok:0, help:v:exception})
    endtry
  endfor
  let l:python = executable('python3') ? ['python3'] : has('win32') && executable('py') ? ['py', '-3'] : has('win32') ? ['python'] : ['python3']
  call s:Configured(l:items, 'Generation Python', 'PV_python', l:python, 'Python 3 runs the bundled generators.')
  call s:Configured(l:items, 'C++ language server', 'PV_clangd_argv', ['clangd'], 'Generate compile_commands.json for project include paths.')
  call s:Configured(l:items, 'Python language server', 'PV_pylsp_argv', ['pylsp'], 'Install python-lsp-server with diagnostics/formatting extras.')
  call s:Configured(l:items, 'Markdown preview', 'PV_pandoc_argv', ['pandoc'], 'Pandoc 2.19+ is required.')
  call s:Configured(l:items, 'LaTeX build', 'PV_latexmk_argv', ['latexmk'], 'Install TeX Live/MiKTeX with latexmk.')
  call s:Configured(l:items, 'Grammar checking', 'PV_languagetool_argv', [get(g:, 'PV_languagetool_command', 'languagetool')], 'Install the local LanguageTool JSON CLI and Java. An argv List can select java -jar and a local command-line JAR.')
  call s:Configured(l:items, 'Document viewer', 'PV_document_viewer_argv', has('win32') ? ['explorer.exe'] : ['xdg-open'], 'Select the viewer used for generated previews.')
  call s:Configured(l:items, 'HEX conversion', 'xxdprogram', 'xxd', 'xxd provides reversible HEX conversion.')
  call add(l:items, #{name:'Python debugger provider', ok:has('python3'), optional:1, help:'Vimspector needs GVim +python3 and its compatible shared library.'})
  call s:AdapterItems(l:items, l:root)
  call s:IntegrationItems(l:items)
  for l:variable in ['CC', 'CXX', 'CROSS_COMPILE', 'ANDROID_HOME', 'ANDROID_NDK_HOME', 'EMSDK', 'QTDIR']
    let l:value = getenv(l:variable)
    if l:value isnot v:null && !empty(l:value)
      if index(['CC', 'CXX'], l:variable) >= 0
        call add(l:items, s:CommandItem('Environment compiler: ' .. l:variable, [l:value], 'Compiler flags in this variable require a shell; prefer an executable path.'))
      else
        call add(l:items, #{name:'SDK environment: ' .. l:variable, ok:l:variable ==# 'CROSS_COMPILE' ? executable(l:value .. 'gcc') : isdirectory(l:value), optional:1, help:l:value})
      endif
    endif
  endfor
  for l:option in ['equalprg', 'formatprg', 'keywordprg', 'makeprg', 'grepprg']
    let l:value = eval('&' .. l:option)
    let l:program = executable(l:value) ? l:value : matchstr(l:value, '^\S\+')
    call add(l:items, #{name:'Vim option: ' .. l:option, ok:empty(l:value) || l:value[0] ==# ':' || executable(l:program), optional:1,
          \ help:empty(l:value) ? 'Vim built-in/default behavior.' : l:value .. '; shell command arguments are not executed or validated by Doctor.'})
  endfor
  let l:clap = l:root .. '/.vim/pack/basic/start/vim-clap'
  let l:maple = get(g:, 'clap_maple_binary', l:clap .. '/bin/maple' .. (has('win32') ? '.exe' : ''))
  if !executable(l:maple) && executable(l:clap .. '/target/release/maple') | let l:maple = l:clap .. '/target/release/maple' | endif
  call add(l:items, #{name:'Clap native Maple', ok:executable(l:maple), optional:1,
        \ help:l:maple .. '; optional native Clap providers require this component. Build/install it explicitly; core fallback pickers remain available.'})
  call add(l:items, #{name:'Font', ok:!empty(&guifont), optional:1, help:&guifont .. '; use Unicode/emoji fallback or :PlanetPlainMenus.'})
  return l:items
endfunc

func! planet#health#Show() abort
  let l:lines = ['PlanetVim health check', '', 'Missing optional tools affect only their named workflow.', '']
  for l:item in planet#health#Check()
    call add(l:lines, (get(l:item, 'status', '') ==# 'unverified' ? '[CHECK] ' : l:item.ok ? '[OK] ' : get(l:item, 'optional', 0) ? '[OPTIONAL] ' : '[MISSING] ') .. l:item.name)
    call add(l:lines, '  ' .. l:item.help)
  endfor
  call planet#health#Scratch('PlanetVim Health', l:lines)
endfunc

func! planet#health#Scratch(name, lines) abort
  tabnew
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  execute 'file ' .. fnameescape(a:name)
  call setline(1, a:lines)
  setlocal nomodifiable nomodified wrap
endfunc

func! planet#health#FirstRun() abort
  let l:marker = planet#paths#State() .. '/onboarding-seen'
  if !filereadable(l:marker)
    echomsg 'Welcome to PlanetVim. Run :PlanetDoctor for setup checks and :help planetvim for the guide.'
    call writefile(['1'], l:marker)
  endif
endfunc
