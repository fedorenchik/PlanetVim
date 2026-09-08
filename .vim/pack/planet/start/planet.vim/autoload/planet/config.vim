scriptversion 4

let s:menus = ['planet', 'basic', 'editing', 'dev', 'tools', 'nav', 'settings']

func! s:Valid(key, value) abort
  if a:key ==# 'PV_mode'
    return type(a:value) == v:t_string && index(['e', 's', 'p'], a:value) >= 0
  endif
  return index(map(copy(s:menus), {_, name -> 'PlanetVim_menus_' .. name}), a:key) >= 0
        \ && type(a:value) == v:t_number && index([0, 1], a:value) >= 0
endfunc

func! s:Read() abort
  let l:path = planet#paths#Config() .. '/preferences.json'
  if !filereadable(l:path)
    return {}
  endif
  let l:values = json_decode(join(readfile(l:path), "\n"))
  if type(l:values) != v:t_dict
    throw 'PlanetVim: preferences.json must contain an object'
  endif
  for [l:key, l:value] in items(l:values)
    if !s:Valid(l:key, l:value)
      throw 'PlanetVim: invalid saved preference: ' .. l:key
    endif
  endfor
  return l:values
endfunc

func! s:Warn(message) abort
  echohl WarningMsg
  echomsg 'PlanetVim preferences: ' .. a:message
  echohl None
endfunc

func! planet#config#SavePreference(key, value) abort
  let l:key = substitute(a:key, '^g:', '', '')
  if !s:Valid(l:key, a:value)
    call s:Warn('refusing invalid preference ' .. l:key)
    return v:false
  endif
  let l:temporary = ''
  try
    let l:values = s:Read()
    let l:values[l:key] = a:value
    let l:path = planet#paths#Config() .. '/preferences.json'
    let l:temporary = l:path .. '.' .. getpid() .. '.tmp'
    call writefile([json_encode(l:values)], l:temporary)
    call setfperm(l:temporary, 'rw-------')
    if rename(l:temporary, l:path) != 0
      throw 'could not replace ' .. l:path
    endif
    return v:true
  catch
    call s:Warn(v:exception)
    return v:false
  finally
    if !empty(l:temporary) && filereadable(l:temporary)
      call delete(l:temporary)
    endif
  endtry
endfunc

func! planet#config#Initialize() abort
  if get(g:, 'PV_config_loaded', 0)
    return
  endif
  let g:PV_initializing = 1
  try
    runtime plugin/globals.vim
    runtime plugin/settings.vim
    try
      call extend(g:, s:Read(), 'force')
    catch
      call s:Warn(v:exception)
    endtry
    " Read a legacy literal mode choice before applying defaults. The user's
    " script still runs exactly once; arbitrary expressions are never evaluated
    " by this preflight. Computed choices can call SetMode() in the script.
    if filereadable(expand(g:PV_config))
      for l:line in readfile(expand(g:PV_config))
        let l:choice = matchlist(l:line, '^\s*let\s\+g:PV_mode\s*=\s*["'']\([esp]\)["'']\s*\%(".*\)\?$')
        if !empty(l:choice)
          let g:PV_mode = l:choice[1]
        endif
      endfor
    endif
    call planet#planet#SetMode(g:PV_mode)
    let l:mode = g:PV_mode
    let l:options = {}
    for l:name in ['insertmode', 'selectmode', 'keymodel', 'backspace', 'selection', 'guioptions']
      let l:options[l:name] = eval('&' .. l:name)
    endfor
    let l:maps = {}
    for l:key in planet#planet#ModeKeys()
      let l:maps[l:key] = maparg(l:key, 'n', 0, 1)
    endfor
    if filereadable(expand(g:PV_config))
      execute 'source ' .. fnameescape(expand(g:PV_config))
    endif
    " Legacy configs may assign PV_mode. Apply it once, then restore explicit
    " user option/mapping overrides without sourcing their file twice.
    if l:mode !=# g:PV_mode
      let l:overrides = {}
      for [l:name, l:value] in items(l:options)
        if eval('&' .. l:name) !=# l:value
          let l:overrides[l:name] = eval('&' .. l:name)
        endif
      endfor
      let l:map_overrides = {}
      for [l:key, l:mapping] in items(l:maps)
        let l:current = maparg(l:key, 'n', 0, 1)
        if l:current !=# l:mapping
          let l:map_overrides[l:key] = l:current
        endif
      endfor
      call planet#planet#SetMode(g:PV_mode)
      for [l:name, l:value] in items(l:overrides)
        execute 'let &' .. l:name .. ' = ' .. string(l:value)
      endfor
      for [l:key, l:mapping] in items(l:map_overrides)
        if !empty(maparg(l:key, 'n'))
          execute 'nunmap ' .. l:key
        endif
        if !empty(l:mapping)
          call mapset('n', 0, l:mapping)
        endif
      endfor
    endif
    let g:PV_config_loaded = 1
  finally
    let g:PV_initializing = 0
  endtry
endfunc
