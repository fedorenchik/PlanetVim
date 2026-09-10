vim9script
export def Catalog(): any
  var snippets: any
  var file: any = planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/data/snippets.json'
  var all: any = json_decode(join(readfile(file), "\n"))
  snippets = extend(copy(get(all, '*', {})), get(all, &filetype, {}))
  var custom: any = planet#paths#Config('snippets') .. '/' .. (empty(&filetype) ? 'text' : &filetype) .. '.json'
  if filereadable(custom)
    extend(snippets, json_decode(join(readfile(custom), "\n")))
  endif
  return snippets
enddef

export def Insert(arg_name: any = v:null, arg_fields: any = {}): any
  var snippets: any
  var names: any
  var name: any
  var choice: any
  var body: any
  var text: any
  var fields: any
  var position: any
  var match: any
  var field: any
  var lines: any
  var indent: any
  var start: any
  var cursor: any
  var column: any
  try
    snippets = planet#snippets#Catalog()
    names = sort(keys(snippets))
    name = arg_name
    if name == null
      choice = inputlist(['Insert snippet:'] + map(copy(names), (lambda_index, lambda_name) => (lambda_index + 1) .. '. ' .. lambda_name))
      if choice <= 0 || choice > len(names)
        return 0
      endif
      name = names[choice - 1]
    endif
    if !has_key(snippets, name)
      return 0
    endif
    body = snippets[name]
    if type(body) != v:t_list || !empty(filter(copy(body), (_, lambda_line) => type(lambda_line) != v:t_string))
      throw 'snippet body must be a List of lines'
    endif
    text = join(body, "\n")
    fields = copy(arg_fields)
    position = 0
    while 1
      match = matchstrpos(text, '${\h\w*}', position)
      if match[1] < 0
        break
      endif
      field = match[0][2 : -2]
      if field !=# 'cursor' && !has_key(fields, field)
        fields[field] = inputdialog(field .. ': ', '', '\CANCEL')
        if fields[field] ==# '\CANCEL'
          return 0
        endif
      endif
      position = match[2]
    endwhile
    text = substitute(text, '${\(\h\w*\)}', (parts) => parts[1] ==# 'cursor' ? '${cursor}' : fields[parts[1]], 'g')
    lines = split(text, "\n", 1)
    indent = matchstr(getline('.'), '^\s*')
    start = getline('.') =~# '^\s*$' ? line('.') : line('.') + 1
    cursor = [start, strlen(indent) + 1]
    for index in range(len(lines))
      column = stridx(lines[index], '${cursor}')
      if column >= 0
        cursor = [start + index, strlen(indent) + column + 1]
      endif
      lines[index] = indent .. substitute(lines[index], '\V${cursor}', '', 'g')
    endfor
    if start == line('.')
      setline(start, lines[0])
      append(start, lines[1 : ])
    else
      append(line('.'), lines)
    endif
    cursor(cursor)
    return 1
  catch
    echohl ErrorMsg
    echomsg 'PlanetVim snippets: ' .. v:exception
    echohl None
    return 0
  endtry
enddef

export def Edit(): any
  var path: any = planet#paths#Config('snippets') .. '/' .. (empty(&filetype) ? 'text' : &filetype) .. '.json'
  if !filereadable(path)
    writefile(['{}'], path)
  endif
  execute 'tabedit ' .. fnameescape(path)
  return 0
enddef
