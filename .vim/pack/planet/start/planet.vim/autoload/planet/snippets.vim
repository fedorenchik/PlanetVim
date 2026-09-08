scriptversion 4

func! planet#snippets#Catalog() abort
  let l:file = planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/data/snippets.json'
  let l:all = json_decode(join(readfile(l:file), "\n"))
  let l:snippets = extend(copy(get(l:all, '*', {})), get(l:all, &filetype, {}))
  let l:custom = planet#paths#Config('snippets') .. '/' .. (empty(&filetype) ? 'text' : &filetype) .. '.json'
  if filereadable(l:custom)
    call extend(l:snippets, json_decode(join(readfile(l:custom), "\n")))
  endif
  return l:snippets
endfunc

func! planet#snippets#Insert(name = v:null, fields = {}) abort
  try
    let l:snippets = planet#snippets#Catalog()
    let l:names = sort(keys(l:snippets))
    let l:name = a:name
    if l:name is v:null
      let l:choice = inputlist(['Insert snippet:'] + map(copy(l:names), {index, name -> (index + 1) .. '. ' .. name}))
      if l:choice <= 0 || l:choice > len(l:names)
        return 0
      endif
      let l:name = l:names[l:choice - 1]
    endif
    if !has_key(l:snippets, l:name)
      return 0
    endif
    let l:body = l:snippets[l:name]
    if type(l:body) != v:t_list || !empty(filter(copy(l:body), {_, line -> type(line) != v:t_string}))
      throw 'snippet body must be a List of lines'
    endif
    let l:text = join(l:body, "\n")
    let l:fields = copy(a:fields)
    let l:position = 0
    while 1
      let l:match = matchstrpos(l:text, '${\h\w*}', l:position)
      if l:match[1] < 0
        break
      endif
      let l:field = l:match[0][2:-2]
      if l:field !=# 'cursor' && !has_key(l:fields, l:field)
        let l:fields[l:field] = inputdialog(l:field .. ': ', '', '\CANCEL')
        if l:fields[l:field] ==# '\CANCEL'
          return 0
        endif
      endif
      let l:position = l:match[2]
    endwhile
    let l:text = substitute(l:text, '${\(\h\w*\)}', '\=submatch(1) ==# "cursor" ? "${cursor}" : l:fields[submatch(1)]', 'g')
    let l:lines = split(l:text, "\n", 1)
    let l:indent = matchstr(getline('.'), '^\s*')
    let l:start = getline('.') =~# '^\s*$' ? line('.') : line('.') + 1
    let l:cursor = [l:start, strlen(l:indent) + 1]
    for l:index in range(len(l:lines))
      let l:column = stridx(l:lines[l:index], '${cursor}')
      if l:column >= 0
        let l:cursor = [l:start + l:index, strlen(l:indent) + l:column + 1]
      endif
      let l:lines[l:index] = l:indent .. substitute(l:lines[l:index], '\V${cursor}', '', 'g')
    endfor
    if l:start == line('.')
      call setline(l:start, l:lines[0])
      call append(l:start, l:lines[1:])
    else
      call append(line('.'), l:lines)
    endif
    call cursor(l:cursor)
    return 1
  catch
    echohl ErrorMsg | echomsg 'PlanetVim snippets: ' .. v:exception | echohl None
    return 0
  endtry
endfunc

func! planet#snippets#Edit() abort
  let l:path = planet#paths#Config('snippets') .. '/' .. (empty(&filetype) ? 'text' : &filetype) .. '.json'
  if !filereadable(l:path)
    call writefile(['{}'], l:path)
  endif
  execute 'tabedit ' .. fnameescape(l:path)
endfunc
