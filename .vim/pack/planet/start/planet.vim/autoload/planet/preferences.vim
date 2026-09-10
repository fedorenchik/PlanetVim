vim9script

var script_options = ['pumopt', 'printoptions', 'printdevice', 'printfont', 'completeopt', 'wildoptions', 'wildmode', 'wildchar', 'splitkeep', 'jumpoptions', 'showtabpanel', 'tabpanelopt', 'guifont', 'guiligatures', 'background', 'renderoptions', 'scrolloffpad', 'statuslineopt']

export def Valid(values: any): number
  if type(values) != v:t_dict
    return 0
  endif
  for [name, value] in items(values)
    if index(script_options, name) < 0 || index([v:t_string, v:t_number], type(value)) < 0
      return 0
    endif
  endfor
  return 1
enddef

export def Set(name: string, value: any, local: number = 0, save: number = 1): number
  if name !~# '^\a\+$' || !exists('+' .. name)
    return planet#prompt#Unavailable(name, "'" .. name .. "'")
  endif
  var scope: any = local ? 'l:' : 'g:'
  var old: any = eval('&' .. scope .. name)
  try
    execute '&' .. scope .. name .. ' = ' .. string(value)
  catch /^Vim\%((\a\+)\)\=:E/
    execute '&' .. scope .. name .. ' = ' .. string(old)
    return planet#prompt#Unavailable(name .. '=' .. string(value), "'" .. name .. "'")
  endtry
  if !local && save && index(script_options, name) >= 0
    g:PV_editor_options = get(g:, 'PV_editor_options', {})
    g:PV_editor_options[name] = value
    planet#config#SavePreference('PV_editor_options', g:PV_editor_options)
  endif
  return 1
enddef

export def Toggle(name: string, local: number = 0): number
  if !exists('+' .. name)
    return planet#prompt#Unavailable(name, "'" .. name .. "'")
  endif
  return planet#preferences#Set(name, !eval('&' .. (local ? 'l:' : 'g:') .. name), local)
enddef

export def Flag(name: string, flag: string, local: number = 0): number
  if !exists('+' .. name)
    return planet#prompt#Unavailable(name, "'" .. name .. "'")
  endif
  var flags: any = split(eval('&' .. (local ? 'l:' : 'g:') .. name), ',')
  var index: any = index(flags, flag)
  if index >= 0
    remove(flags, index)
  else
    add(flags, flag)
  endif
  return planet#preferences#Set(name, join(flags, ','), local)
enddef

export def Apply(): number
  planet#lsp_display#Restore()
  for [name, value] in items(get(g:, 'PV_editor_options', {}))
    planet#preferences#Set(name, value, 0, 0)
  endfor
  if exists('g:PV_gui_theme')
    planet#appearance#Theme(g:PV_gui_theme, 0)
  endif
  if exists('g:PV_completion_engine')
    planet#completion#Engine(g:PV_completion_engine, 0)
  endif
  return 0
enddef
