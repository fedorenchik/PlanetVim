vim9script

var script_menus = ['planet', 'basic', 'editing', 'dev', 'tools', 'nav', 'settings']

def LocalValid(key: string, value: any): any
  if key ==# 'PV_gui_theme'
    return type(value) == v:t_string && index(['light', 'dark', 'system'], value) >= 0
  endif
  if key ==# 'PV_lsp_display'
    return planet#lsp_display#Valid(value)
  endif
  if key ==# 'PV_editor_options'
    return planet#preferences#Valid(value)
  endif
  if key ==# 'PV_completion_engine'
    return type(value) == v:t_string && index(['asyncomplete', 'native', 'off'], value) >= 0
  endif
  if key ==# 'PV_menu_style'
    return type(value) == v:t_string && index(['emoji', 'plain', 'descriptive'], value) >= 0
  endif
  if key ==# 'PV_menu_group'
    return type(value) == v:t_string && index(['basic', 'editing', 'dev', 'tools', 'nav', 'settings'], value) >= 0
  endif
  if key ==# 'PV_mode'
    return type(value) == v:t_string && index(['e', 's', 'p'], value) >= 0
  endif
  return index(map(copy(script_menus), (_, lambda_name) => 'PlanetVim_menus_' .. lambda_name), key) >= 0 && type(value) == v:t_number && index([0, 1], value) >= 0
enddef

def LocalRead(): dict<any>
  var path: any = planet#paths#Config() .. '/preferences.json'
  if !filereadable(path)
    return {}
  endif
  var values: any = json_decode(join(readfile(path), "\n"))
  if type(values) != v:t_dict
    throw 'PlanetVim: preferences.json must contain an object'
  endif
  for [key, value] in items(values)
    if !LocalValid(key, value)
      throw 'PlanetVim: invalid saved preference: ' .. key
    endif
  endfor
  return values
enddef

def LocalWarn(message: string): number
  echohl WarningMsg
  echomsg 'PlanetVim preferences: ' .. message
  echohl None
  return 0
enddef

export def SavePreference(arg_key: string, value: any): any
  var values: any
  var path: any
  var key: any = substitute(arg_key, '^g:', '', '')
  if !LocalValid(key, value)
    LocalWarn('refusing invalid preference ' .. key)
    return v:false
  endif
  var temporary: any = ''
  try
    values = LocalRead()
    values[key] = value
    path = planet#paths#Config() .. '/preferences.json'
    temporary = path .. '.' .. getpid() .. '.tmp'
    writefile([json_encode(values)], temporary)
    setfperm(temporary, 'rw-------')
    if rename(temporary, path) != 0
      throw 'could not replace ' .. path
    endif
    return v:true
  catch
    LocalWarn(v:exception)
    return v:false
  finally
    if !empty(temporary) && filereadable(temporary)
      delete(temporary)
    endif
  endtry
  return 0
enddef

export def Initialize(): number
  var choice: any
  var mode: any
  var options: any
  var maps: any
  var overrides: any
  var map_overrides: any
  var current: any
  var mapping: any
  var name: any
  var value: any
  var key: any
  if get(g:, 'PV_config_loaded', 0)
    return 0
  endif
  g:PV_initializing = 1
  try
    runtime plugin/globals.vim
    runtime plugin/settings.vim
    try
      extend(g:, LocalRead(), 'force')
    catch
      LocalWarn(v:exception)
    endtry
    # Read a legacy literal mode choice before applying defaults. The user's
    # script still runs exactly once; arbitrary expressions are never evaluated
    # by this preflight. Computed choices can call SetMode() in the script.
    if filereadable(expand(g:PV_config))
      for line in readfile(expand(g:PV_config))
        choice = matchlist(line, '^\s*let\s\+g:PV_mode\s*=\s*["'']\([esp]\)["'']\s*\%(".*\)\?$')
        if !empty(choice)
          g:PV_mode = choice[1]
        endif
      endfor
    endif
    planet#planet#SetMode(g:PV_mode)
    planet#preferences#Apply()
    mode = g:PV_mode
    options = {}
    for item_name in ['insertmode', 'selectmode', 'keymodel', 'backspace', 'selection', 'guioptions']
      name = item_name
      options[name] = eval('&' .. name)
    endfor
    maps = {}
    for item_key in planet#planet#ModeKeys()
      key = item_key
      maps[key] = maparg(key, 'n', 0, 1)
    endfor
    if filereadable(expand(g:PV_config))
      execute 'source ' .. fnameescape(expand(g:PV_config))
    endif
    # Legacy configs may assign PV_mode. Apply it once, then restore explicit
    # user option/mapping overrides without sourcing their file twice.
    if mode !=# g:PV_mode
      overrides = {}
      for [item_name, item_value] in items(options)
        value = item_value
        name = item_name
        if eval('&' .. name) !=# value
          overrides[name] = eval('&' .. name)
        endif
      endfor
      map_overrides = {}
      for [item_key, item_mapping] in items(maps)
        key = item_key
        mapping = item_mapping
        current = maparg(key, 'n', 0, 1)
        if current !=# mapping
          map_overrides[key] = current
        endif
      endfor
      planet#planet#SetMode(g:PV_mode)
      for [item_name, item_value] in items(overrides)
        value = item_value
        name = item_name
        execute '&' .. name .. ' = ' .. string(value)
      endfor
      for [item_key, item_mapping] in items(map_overrides)
        key = item_key
        mapping = item_mapping
        if !empty(maparg(key, 'n'))
          execute 'nunmap ' .. key
        endif
        if !empty(mapping)
          mapset('n', 0, mapping)
        endif
      endfor
    endif
    g:PV_config_loaded = 1
  finally
    g:PV_initializing = 0
  endtry
  return 0
enddef
