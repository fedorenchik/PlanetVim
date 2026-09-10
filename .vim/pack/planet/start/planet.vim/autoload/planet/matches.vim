vim9script
export def Add(...args: list<any>): any
  var group: any = !empty(args) ? args[0] : planet#prompt#Ask('Highlight group: ', 'Search', 'highlight')
  if group == null || empty(group)
    return 0
  endif
  var pattern: any = len(args) > 1 ? args[1] : planet#prompt#Ask('Vim search pattern: ')
  if pattern == null || empty(pattern)
    return 0
  endif
  return matchadd(group, pattern)
enddef

export def Position(...args: list<any>): any
  var group: any = !empty(args) ? args[0] : planet#prompt#Ask('Highlight group: ', 'Search', 'highlight')
  if group == null || empty(group)
    return 0
  endif
  var default: any = json_encode([[line('.'), col('.'), strlen(matchstr(strpart(getline('.'), col('.') - 1), '^.'))]])
  var value: any = len(args) > 1 ? args[1] : planet#prompt#Ask('Positions as JSON: [[line, byte column, byte length], ...]: ', default)
  if value == null || empty(value)
    return 0
  endif
  var positions: any = type(value) == v:t_list ? value : json_decode(value)
  return matchaddpos(group, positions)
enddef

export def Delete(...args: list<any>): any
  var matches: any = getmatches()
  if !empty(args)
    return matchdelete(args[0])
  endif
  var labels: any = map(copy(matches), (_, lambda_m) => printf('%d: %s %s', lambda_m.id, lambda_m.group,
       get(lambda_m, 'pattern', string(get(lambda_m, 'pos1', [])))))
  var i: any = planet#prompt#Choose('Delete window highlight', labels)
  if i < 0
    return 0
  endif
  return matchdelete(matches[i].id)
enddef
