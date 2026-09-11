vim9script
var script_runtime = expand('<script>:p:h:h:h')

def LocalDirectory(kind: any): any
  var xdg: any
  var base: any
  var value: any = get(g:, 'PV_' .. kind .. '_dir', getenv('PLANETVIM_' .. toupper(kind) .. '_DIR'))
  if value == null || empty(value)
    if has('win32')
      value = (empty($LOCALAPPDATA) ? expand('~/AppData/Local') : $LOCALAPPDATA) .. '/PlanetVim/' .. kind
    else
      xdg = {'config': ['XDG_CONFIG_HOME', '~/.config'], 'state': ['XDG_STATE_HOME', '~/.local/state'], 'cache': ['XDG_CACHE_HOME', '~/.cache']}[kind]
      base = getenv(xdg[0])
      value = (base == null || empty(base) ? expand(xdg[1]) : base) .. '/planetvim'
    endif
  endif
  return fnamemodify(value, ':p')->substitute('[/\\]\+$', '', '')
enddef

def LocalDirectoryItem(kind: any): any
  var path: any = LocalDirectory(tolower(kind))
  var parent: any = path
  while getftype(parent) ==# '' && fnamemodify(parent, ':h') !=# parent
    parent = fnamemodify(parent, ':h')
  endwhile
  var ok: any = isdirectory(parent) && filewritable(parent) == 2
  return {name: kind .. ' directory', ok: ok, help: path .. (ok ? '; writable directory/parent found (no write probe performed).' : '; directory or nearest existing parent is not writable.')}
enddef

def LocalCommandItem(name: any, arg_argv: any, help: any, optional: any = 1): any
  var argv: any = type(arg_argv) == v:t_string ? [arg_argv] : arg_argv
  var valid: any = type(argv) == v:t_list && !empty(argv) && empty(filter(copy(argv), (_, lambda_v) => type(lambda_v) != v:t_string || lambda_v =~# '[\r\n]'))
  var ok: any = valid && executable(argv[0])
  return {name: name, ok: ok, optional: optional, argv: deepcopy(argv), help: (valid ? string(argv) : 'Invalid argv configuration') .. '. ' .. (ok ? 'Executable found; version and runtime behavior not probed. ' : '') .. help}
enddef

def LocalConfigured(items: any, label: any, key: any, default: any, help: any): any
  add(items, LocalCommandItem(label, get(g:, key, default), help .. ' Configure g:' .. key .. '.'))
  return 0
enddef

# Read declarative SDK contracts and literal command launch sites. This keeps
# Doctor coverage in step with enabled first-party menus without executing any
# action, loading third-party modules, or inspecting a user's shell startup.
def LocalIntegrationItems(items: any): any
  var specs: any
  var name: any
  var match: any
  var label: any
  var meta: any
  var help: any
  var path: any
  var argv: any
  var qt_dirs: any
  var spec_file: any = script_runtime .. '/data/integrations.json'
  var tools: any = {}
  var overrides: any = get(g:, 'PV_integration_tools', {})
  if type(overrides) != v:t_dict
    add(items, {name: 'SDK executable configuration', ok: 0, optional: 1, help: 'g:PV_integration_tools must be a Dictionary of executable/argv overrides.'})
    overrides = {}
  endif
  try
    specs = json_decode(join(readfile(spec_file), "\n"))
    for [id, spec] in items(specs)
      name = spec.argv[0]
      if !has_key(tools, name)
        tools[name] = {qt: get(spec, 'qt', v:false), actions: []}
      endif
      add(tools[name].actions, id)
    endfor
  catch
    add(items, {name: 'SDK command inventory', ok: 0, optional: 1, help: v:exception})
  endtry
  for file in globpath(planet#paths#Runtime(script_runtime .. '/autoload/planet'), '**/*.vim', 0, 1)
    if fnamemodify(file, ':t') ==# 'health.vim'
      continue
    endif
    for line in readfile(file)
      if line =~# '^\s*"'
        continue
      endif
      match = matchlist(line, '\%(#\|s:\)\%(Run\|Command\|Ask\|Gui\|RunArgv\|RunGuiApp\|RunCmd\|RunInput\|RunCmdTab\)(\s*\[''\([^'']\+\)''')
      if !empty(match) && match[1] !~# '^[-:]'
        if !has_key(tools, match[1])
          tools[match[1]] = {qt: 0, actions: []}
        endif
        label = fnamemodify(file, ':t:r')
        if index(tools[match[1]].actions, label) < 0
          add(tools[match[1]].actions, label)
        endif
      endif
    endfor
  endfor
  # Dynamic dispatchers, SDK prerequisites, and feature providers.
  for item_name in ['git', 'direnv', 'cmake', 'ctest', 'ccmake', 'cmake-gui', 'cc', 'c++', 'git-subrepo', 'git-extras', 'gdb', 'lldb', 'rr', 'live-record', 'r2', 'cutter', 'picocom', 'plink', 'ffmpeg', 'python3', 'python', 'py', 'node', 'java', 'cargo', 'ctags', 'rg', 'fd', 'fzf', 'docker', 'conda', 'aqt', 'emcc', 'em++', 'arduino-cli', 'pio', 'flutter', 'ngrok', 'nmap', 'socat', 'websocat', 'pandoc', 'latexmk', 'languagetool', 'xxd', 'x11vnc', 'vncviewer', 'Xvfb', 'xvfb-run', 'xclip', 'wl-copy']
    name = item_name
    if !has_key(tools, name)
      tools[name] = {qt: 0, actions: ['optional workflow']}
    endif
  endfor
  for item_name in sort(keys(tools))
    name = item_name
    meta = tools[name]
    label = 'Tool: ' .. name
    help = 'Used by ' .. join(meta.actions, ', ') .. '.'
    if name =~# '%root%'
      path = substitute(name, '%root%', '\=getcwd()', 'g')
      add(items, {name: label, ok: filereadable(path), optional: 1, help: help .. ' Project-relative prerequisite: ' .. path .. '; select the source tree before running this action.'})
      continue
    endif
    argv = get(overrides, name, [name])
    if meta.qt && !has_key(overrides, name)
      qt_dirs = empty($QTDIR) ? [] : [$QTDIR .. '/bin', $QTDIR .. '/libexec']
      if !has('win32')
        qt_dirs += ['/usr/lib/qt6/bin', '/usr/lib/qt6', '/usr/lib/qt6/libexec']
      endif
      if !executable(name)
        for dir in qt_dirs
          if executable(dir .. '/' .. name)
            argv = [dir .. '/' .. name]
            break
          endif
        endfor
      endif
    endif
    if type(argv) == v:t_list && argv ==# [name] && executable(getcwd() .. '/node_modules/.bin/' .. name)
      argv = [getcwd() .. '/node_modules/.bin/' .. name]
    endif
    add(items, LocalCommandItem(label, argv, help .. ' Install its SDK/CLI or configure g:PV_integration_tools[' .. string(name) .. '].'))
  endfor
  return 0
enddef

def LocalAdapterItems(items: any, root: any): any
  var item: any
  var config: any
  var values: any
  var name: any
  var adapter: any
  var python: any = executable('python3') ? 'python3' : 'python'
  LocalConfigured(items, 'Python debug adapter command', 'PV_debugpy_command', [python, '-m', 'debugpy.adapter'], 'Install debugpy in this interpreter.')
  LocalConfigured(items, 'GDB debug adapter command', 'PV_gdb_command', ['gdb', '--quiet', '--nx', '--interpreter=dap'],
       'GDB needs Python DAP support (GDB 14+).')
  for item_name in ['Python debug adapter command', 'GDB debug adapter command']
    name = item_name
    item = filter(copy(items), (_, lambda_item) => lambda_item.name ==# name)[0]
    if item.ok
      item.status = 'unverified'
      item.help ..= ' Adapter protocol/module support is verified on launch, not by Doctor.'
    endif
  endfor
  var vimspector: any = root .. '/.vim/pack/apps/opt/vimspector'
  add(items, {name: 'Bundled Vimspector', ok: filereadable(vimspector .. '/plugin/vimspector.vim'), optional: 1,
       help: vimspector .. '; loaded only when debugging starts.'})
  var configuration: any = findfile('.vimspector.json', getcwd() .. ';')
  if !empty(configuration)
    try
      config = json_decode(join(readfile(configuration), "\n"))
      for [item_name, item_adapter] in items(get(config, 'adapters', {}))
        name = item_name
        adapter = item_adapter
        if has_key(adapter, 'command')
          add(items, LocalCommandItem('Project adapter: ' .. name, adapter.command, configuration .. '; adapter protocol, modules and credentials are checked when launched.'))
        else
          add(items, {name: 'Project adapter: ' .. name, ok: 0, optional: 1, status: 'unverified', help: 'Custom/TCP adapter configuration in ' .. configuration .. '; no network connection was attempted.'})
        endif
      endfor
    catch
      add(items, {name: 'Project debugger configuration', ok: 0, optional: 1, help: v:exception})
    endtry
  endif
  for [setting, prefix] in [['PV_debug_tools', 'Debug tool'], ['PV_test_tools', 'Test tool']]
    values = get(g:, setting, {})
    if type(values) != v:t_dict
      add(items, {name: prefix .. ' configuration', ok: 0, optional: 1, help: 'g:' .. setting .. ' must be a Dictionary.'})
      continue
    endif
    for [item_name, argv] in items(values)
      name = item_name
      add(items, LocalCommandItem(prefix .. ': ' .. name, argv, 'Configured by g:' .. setting .. '.'))
    endfor
  endfor
  return 0
enddef

export def Check(): any
  var value: any
  var program: any
  var items: any = []
  var root: any = get(g:, 'PV_root', fnamemodify(script_runtime, ':h:h:h:h:h'))
  # Vim 9.1.0000 misfolds an OR of constant has() calls. Read each first.
  var unix = has('unix')
  var windows = has('win32')
  var platform_ok = unix || windows
  if has('mac') || has('macunix')
    platform_ok = false
  endif
  add(items, {name: 'Platform', ok: platform_ok, help: 'Linux first; Windows secondary; GVim only.'})
  add(items, {name: 'GVim version', ok: has('patch-9.1.0016'), help: 'GVim 9.1.0016 or newer is required.'})
  for feature in ['gui', 'menu', 'terminal', 'job', 'channel', 'timers', 'popupwin', 'persistent_undo']
    add(items, {name: '+' .. feature, ok: has(feature), help: 'Install a full GVim build.'})
  endfor
  for kind in ['Config', 'State', 'Cache']
    try
      add(items, LocalDirectoryItem(kind))
    catch
      add(items, {name: kind .. ' directory', ok: 0, help: v:exception})
    endtry
  endfor
  var python: any = executable('python3') ? ['python3'] : has('win32') && executable('py') ? ['py', '-3'] : has('win32') ? ['python'] : ['python3']
  LocalConfigured(items, 'Generation Python', 'PV_python', python, 'Python 3 runs the bundled generators.')
  LocalConfigured(items, 'C++ language server', 'PV_clangd_argv', ['clangd'], 'Generate compile_commands.json for project include paths.')
  LocalConfigured(items, 'Python language server', 'PV_pylsp_argv', ['pylsp'], 'Install python-lsp-server with diagnostics/formatting extras.')
  LocalConfigured(items, 'Markdown preview', 'PV_pandoc_argv', ['pandoc'], 'Pandoc 2.19+ is required.')
  LocalConfigured(items, 'LaTeX build', 'PV_latexmk_argv', ['latexmk'], 'Install TeX Live/MiKTeX with latexmk.')
  LocalConfigured(items, 'Grammar checking', 'PV_languagetool_argv', [get(g:, 'PV_languagetool_command',
       'languagetool')], 'Install the local LanguageTool JSON CLI and Java. An argv List can select java -jar and a local command-line JAR.')
  LocalConfigured(items, 'Document viewer', 'PV_document_viewer_argv', has('win32') ? ['explorer.exe'] : ['xdg-open'],
       'Select the viewer used for generated previews.')
  LocalConfigured(items, 'HEX conversion', 'xxdprogram', 'xxd', 'xxd provides reversible HEX conversion.')
  add(items, {name: 'Python debugger provider', ok: has('python3') && py3eval('__import__("sys").version_info >= (3, 10)'), optional: 1, help: 'Vimspector needs GVim +python3 with Python 3.10 or newer.'})
  add(items, {name: 'Flog Lua runtime', ok: get(g:, 'flog_use_internal_lua', 0) ? has('lua') : executable(get(g:, 'flog_lua_bin', 'luajit')), optional: 1, help: 'Flog 3 needs LuaJIT 2.1 (g:flog_lua_bin); alternatively enable g:flog_use_internal_lua in a GVim built with LuaJIT.'})
  LocalAdapterItems(items, root)
  LocalIntegrationItems(items)
  for variable in ['CC', 'CXX', 'CROSS_COMPILE', 'ANDROID_HOME', 'ANDROID_NDK_HOME', 'EMSDK', 'QTDIR']
    value = getenv(variable)
    if value != null && !empty(value)
      if index(['CC', 'CXX'], variable) >= 0
        add(items, LocalCommandItem('Environment compiler: ' .. variable, [value], 'Compiler flags in this variable require a shell; prefer an executable path.'))
      else
        add(items, {name: 'SDK environment: ' .. variable, ok: variable ==# 'CROSS_COMPILE' ? executable(value .. 'gcc') : isdirectory(value),
             optional: 1, help: value})
      endif
    endif
  endfor
  for option in ['equalprg', 'formatprg', 'keywordprg', 'makeprg', 'grepprg']
    value = eval('&' .. option)
    program = executable(value) ? value : matchstr(value, '^\S\+')
    add(items, {name: 'Vim option: ' .. option, ok: empty(value) || value[0] ==# ':' || executable(program),
         optional: 1, help: empty(value) ? 'Vim built-in/default behavior.' : value .. '; shell command arguments are not executed or validated by Doctor.'})
  endfor
  var clap: any = root .. '/.vim/pack/basic/start/vim-clap'
  var maple: any = clap .. '/target/release/maple' .. (has('win32') ? '.exe' : '')
  if !executable(maple)
    maple = clap .. '/bin/maple' .. (has('win32') ? '.exe' : '')
  endif
  if !executable(maple) && executable('maple')
    maple = exepath('maple')
  endif
  add(items, {name: 'Clap native Maple', ok: executable(maple), optional: 1, help: maple .. '; optional native Clap providers require this component. Build/install it explicitly; core fallback pickers remain available.'})
  add(items, {name: 'Font', ok: !empty(&guifont), optional: 1, help: &guifont .. '; use Unicode/emoji fallback or :PlanetPlainMenus.'})
  return items
enddef

export def Show(): any
  var lines: any = ['PlanetVim health check', '', 'Missing optional tools affect only their named workflow.', '']
  for item in planet#health#Check()
    add(lines, (get(item, 'status', '') ==# 'unverified' ? '[CHECK] ' : item.ok ? '[OK] ' : get(item,
         'optional', 0) ? '[OPTIONAL] ' : '[MISSING] ') .. item.name)
    add(lines, '  ' .. item.help)
  endfor
  planet#health#Scratch('PlanetVim Health', lines)
  return 0
enddef

export def Scratch(name: any, lines: any): any
  tabnew
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  execute 'file ' .. fnameescape(name)
  setline(1, lines)
  setlocal nomodifiable nomodified wrap
  return 0
enddef

export def FirstRun(): any
  var marker: any = planet#paths#State() .. '/onboarding-seen'
  if !filereadable(marker)
    echomsg 'Welcome to PlanetVim. Run :PlanetDoctor for setup checks and :help planetvim for the guide.'
    writefile(['1'], marker)
  endif
  return 0
enddef
