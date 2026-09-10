scriptversion 4

func! planet#matches#Add(...) abort
  let l:group = a:0 ? a:1 : planet#prompt#Ask('Highlight group: ', 'Search', 'highlight')
  if l:group is v:null || empty(l:group) | return 0 | endif
  let l:pattern = a:0 > 1 ? a:2 : planet#prompt#Ask('Vim search pattern: ')
  if l:pattern is v:null || empty(l:pattern) | return 0 | endif
  return matchadd(l:group, l:pattern)
endfunc

func! planet#matches#Position(...) abort
  let l:group = a:0 ? a:1 : planet#prompt#Ask('Highlight group: ', 'Search', 'highlight')
  if l:group is v:null || empty(l:group) | return 0 | endif
  let l:default = json_encode([[line('.'), col('.'), strlen(matchstr(strpart(getline('.'), col('.') - 1), '^.'))]])
  let l:value = a:0 > 1 ? a:2 : planet#prompt#Ask('Positions as JSON: [[line, byte column, byte length], ...]: ', l:default)
  if l:value is v:null || empty(l:value) | return 0 | endif
  let l:positions = type(l:value) == v:t_list ? l:value : json_decode(l:value)
  return matchaddpos(l:group, l:positions)
endfunc

func! planet#matches#Delete(...) abort
  let l:matches = getmatches()
  if a:0
    return matchdelete(a:1)
  endif
  let l:labels = map(copy(l:matches), {_, m -> printf('%d: %s %s', m.id, m.group, get(m, 'pattern', string(get(m, 'pos1', []))))})
  let l:i = planet#prompt#Choose('Delete window highlight', l:labels)
  if l:i < 0 | return 0 | endif
  return matchdelete(l:matches[l:i].id)
endfunc
