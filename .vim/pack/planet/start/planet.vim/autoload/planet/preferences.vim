scriptversion 4

let s:options = ['completeopt', 'wildoptions', 'wildmode', 'wildchar', 'splitkeep', 'jumpoptions', 'showtabpanel', 'tabpanelopt', 'guifont', 'guiligatures', 'background', 'renderoptions', 'scrolloffpad', 'statuslineopt']

func! planet#preferences#Valid(values) abort
  if type(a:values) != v:t_dict | return 0 | endif
  for [l:name, l:value] in items(a:values)
    if index(s:options, l:name) < 0 || index([v:t_string, v:t_number], type(l:value)) < 0 | return 0 | endif
  endfor
  return 1
endfunc

func! planet#preferences#Set(name, value, local = 0, save = 1) abort
  if a:name !~# '^\a\+$' || !exists('+' .. a:name)
    return planet#prompt#Unavailable(a:name, "'" .. a:name .. "'")
  endif
  let l:scope = a:local ? 'l:' : 'g:'
  let l:old = eval('&' .. l:scope .. a:name)
  try
    execute 'let &' .. l:scope .. a:name .. ' = ' .. string(a:value)
  catch /^Vim\%((\a\+)\)\=:E/
    execute 'let &' .. l:scope .. a:name .. ' = ' .. string(l:old)
    return planet#prompt#Unavailable(a:name .. '=' .. string(a:value), "'" .. a:name .. "'")
  endtry
  if !a:local && a:save && index(s:options, a:name) >= 0
    let g:PV_editor_options = get(g:, 'PV_editor_options', {})
    let g:PV_editor_options[a:name] = a:value
    call planet#config#SavePreference('PV_editor_options', g:PV_editor_options)
  endif
  return 1
endfunc

func! planet#preferences#Toggle(name, local = 0) abort
  if !exists('+' .. a:name) | return planet#prompt#Unavailable(a:name, "'" .. a:name .. "'") | endif
  return planet#preferences#Set(a:name, !eval('&' .. (a:local ? 'l:' : 'g:') .. a:name), a:local)
endfunc

func! planet#preferences#Flag(name, flag, local = 0) abort
  if !exists('+' .. a:name) | return planet#prompt#Unavailable(a:name, "'" .. a:name .. "'") | endif
  let l:flags = split(eval('&' .. (a:local ? 'l:' : 'g:') .. a:name), ',')
  let l:index = index(l:flags, a:flag)
  if l:index >= 0 | call remove(l:flags, l:index) | else | call add(l:flags, a:flag) | endif
  return planet#preferences#Set(a:name, join(l:flags, ','), a:local)
endfunc

func! planet#preferences#Apply() abort
  for [l:name, l:value] in items(get(g:, 'PV_editor_options', {}))
    call planet#preferences#Set(l:name, l:value, 0, 0)
  endfor
  if exists('g:PV_gui_theme') | call planet#appearance#Theme(g:PV_gui_theme, 0) | endif
  if exists('g:PV_completion_engine') | call planet#completion#Engine(g:PV_completion_engine, 0) | endif
endfunc
