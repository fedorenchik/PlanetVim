vim9script

# Private settings and generated caches share the project-settings format.
export def Read(path: string): dict<any>
  execute 'source ' .. fnameescape(path)
  var scripts = getscriptinfo({name: '^\V' .. escape(fnamemodify(path, ':p'), '\') .. '\m$'})
  if empty(scripts)
    throw 'PlanetVim: could not inspect settings script: ' .. path
  endif
  var script = scripts[-1]
  var info = getscriptinfo({sid: script.sourced > 0 ? script.sourced : script.sid})[0]
  var data = get(info.variables, 'config', null)
  if info.version != 999999 || type(data) != v:t_dict
    throw 'PlanetVim: expected vim9script with export var config: dict<any> in ' .. path
  endif
  return deepcopy(data)
enddef

def Literal(value: any): string
  if type(value) == v:t_string
    # Double-quoted literals preserve line breaks and control characters.
    return json_encode(value)
  elseif type(value) == v:t_dict
    return '{' .. join(mapnew(sort(keys(value)), (_, key) => Literal(key) .. ': ' .. Literal(value[key])), ', ') .. '}'
  elseif type(value) == v:t_list
    return '[' .. join(mapnew(value, (_, item) => Literal(item)), ', ') .. ']'
  elseif index([v:t_number, v:t_float, v:t_bool, v:t_none], type(value)) >= 0
    return string(value)
  endif
  throw 'PlanetVim: unsupported settings value type: ' .. typename(value)
enddef

export def Write(path: string, config: dict<any>)
  var lines = ['vim9script', '', 'export var config: dict<any> = {']
  for key in sort(keys(config))
    add(lines, '  ' .. Literal(key) .. ': ' .. Literal(config[key]) .. ',')
  endfor
  add(lines, '}')
  var temporary = path .. '.' .. getpid() .. '.tmp'
  try
    writefile(lines, temporary)
    if !setfperm(temporary, 'rw-------') || rename(temporary, path) != 0
      throw 'PlanetVim: could not replace ' .. path
    endif
  finally
    if filereadable(temporary)
      delete(temporary)
    endif
  endtry
enddef
