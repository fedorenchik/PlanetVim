vim9script

# Buffer-local manual types keep editing/clearing separate from plugin properties.
const prefix = 'PlanetVimManual_'

export def Types(): list<string>
  return sort(filter(prop_type_list({bufnr: bufnr()}), (_, name) => stridx(name, prefix) == 0))
enddef

def Label(name: string): string
  return strpart(name, strlen(prefix))
enddef

def Name(label: string): string
  if label !~# '^\w\+$'
    throw 'PlanetVim: a property type name must contain only letters, digits or underscores'
  endif
  return prefix .. label
enddef

export def Type(action: string, label: any = null, highlight: any = null): string
  var chosen = label
  if chosen == null
    if action ==# 'add'
      chosen = planet#prompt#Ask('New manual property type: ', 'Note')
    else
      var names = map(Types(), (_, name) => Label(name))
      var choice = planet#prompt#Choose('Manual property type to ' .. action, names)
      if choice < 0 | return '' | endif
      chosen = names[choice]
    endif
  endif
  if chosen == null || empty(chosen) | return '' | endif
  var name = Name(chosen)
  var options = {bufnr: bufnr()}
  var existing = prop_type_get(name, options)
  if action ==# 'add' && !empty(existing)
    throw 'PlanetVim: that manual property type already exists; use Change Highlight'
  elseif action !=# 'add' && empty(existing)
    throw 'PlanetVim: no such manual property type in this buffer'
  endif
  if action ==# 'delete'
    prop_remove({type: name, all: true}, 1, line('$'))
    prop_type_delete(name, options)
    return name
  endif
  if index(['add', 'change'], action) < 0
    throw 'PlanetVim: invalid property type action'
  endif
  var group = highlight == null
    ? planet#prompt#Ask('Highlight group: ', get(existing, 'highlight', 'Todo'), 'highlight') : highlight
  if group == null || empty(group) | return '' | endif
  if !hlexists(group) | throw 'PlanetVim: unknown highlight group: ' .. group | endif
  if action ==# 'add'
    prop_type_add(name, {bufnr: bufnr(), highlight: group, start_incl: false, end_incl: false})
  else
    prop_type_change(name, {bufnr: bufnr(), highlight: group})
  endif
  return name
enddef

def ChooseType(label: string): string
  if !empty(label)
    var name = Name(label)
    if empty(prop_type_get(name, {bufnr: bufnr()}))
      throw 'PlanetVim: no such manual property type in this buffer'
    endif
    return name
  endif
  var names = Types()
  if empty(names) | return Type('add') | endif
  var choice = planet#prompt#Choose('Manual text property type', map(copy(names), (_, name) => Label(name)))
  return choice < 0 ? '' : names[choice]
enddef

export def Items(manual: bool = true): list<dict<any>>
  var properties = prop_list(1, {end_lnum: -1})
  if !manual | return properties | endif
  filter(properties, (_, prop) => get(prop, 'id', -1) >= 0 && !has_key(prop, 'text') && get(prop, 'type_bufnr', 0) == bufnr()
    && stridx(get(prop, 'type', ''), prefix) == 0)
  # Some Vim versions omit virtual-text IDs from prop_list(). Retain the IDs
  # returned by prop_add(), and query their current positions after edits.
  var live: list<number> = []
  for id in get(b:, 'PV_textprop_notes', [])
    var notes = prop_list(1, {end_lnum: -1, ids: [id]})
    filter(notes, (_, prop) => get(prop, 'type_bufnr', 0) == bufnr()
      && stridx(get(prop, 'type', ''), prefix) == 0)
    if !empty(notes)
      add(live, id)
      for note in notes
        note.id = id
        add(properties, note)
      endfor
    endif
  endfor
  b:PV_textprop_notes = live
  return sort(properties, (a, b) => a.lnum == b.lnum ? a.col - b.col : a.lnum - b.lnum)
enddef

def ScreenSpan(position: list<number>): list<number>
  var bytes = strlen(getline(position[1]))
  var column = min([position[2], bytes + 1])
  var span = virtcol([position[1], column], true)
  var offset = position[3] + max([0, position[2] - bytes - 1])
  return offset > 0 ? [span[0] + offset, span[0] + offset] : span
enddef

def Ranges(selection: dict<any>): list<list<number>>
  var first = copy(selection.start)
  var last = copy(selection.end)
  if get(selection, 'buffer', bufnr()) != bufnr() || min([first[1], last[1]]) < 1
      || max([first[1], last[1]]) > line('$')
    throw 'PlanetVim: select text in the current buffer first'
  endif
  if first[1] > last[1] || (first[1] == last[1] && first[2] > last[2])
    [first, last] = [last, first]
  endif
  if selection.type ==# 'V'
    return [[first[1], 1, last[1], strlen(getline(last[1])) + 1]]
  elseif selection.type ==# "\<C-V>"
    # Properties address bytes: partially selected tabs/wide characters are
    # highlighted whole, without rewriting the buffer to expand them.
    var anchor = ScreenSpan(first)
    var finish = ScreenSpan(last)
    var left = min([anchor[0], finish[0]])
    var right = max([anchor[1], finish[1]])
    if selection.exclusive && right > left | right -= 1 | endif
    var ranges: list<list<number>> = []
    for lnum in range(first[1], last[1])
      var start = virtcol2col(win_getid(), lnum, left)
      var lastcol = virtcol2col(win_getid(), lnum, right)
      if start > 0 && virtcol([lnum, start]) >= left
        var end = lastcol + strlen(matchstr(strpart(getline(lnum), lastcol - 1), '^.'))
        add(ranges, [lnum, start, lnum, end])
      endif
    endfor
    return ranges
  endif
  var start = min([first[2], strlen(getline(first[1])) + 1])
  var end = min([last[2], strlen(getline(last[1])) + 1])
  if !selection.exclusive || (first[1] == last[1] && start == end)
    end += strlen(matchstr(strpart(getline(last[1]), end - 1), '^.'))
  endif
  return [[first[1], start, last[1], end]]
enddef

export def Add(scope: string, label: string = '', selection: dict<any> = {}): number
  var ranges: list<list<number>>
  if scope ==# 'selection'
    ranges = Ranges(empty(selection) ? planet#selection#Current() : selection)
  elseif scope ==# 'line'
    ranges = [[line('.'), 1, line('.'), strlen(getline('.')) + 1]]
  elseif scope ==# 'character'
    var column = min([col('.'), strlen(getline('.')) + 1])
    ranges = [[line('.'), column, line('.'), column + strlen(matchstr(strpart(getline('.'), column - 1), '^.'))]]
  else
    throw 'PlanetVim: invalid text property scope'
  endif
  if empty(ranges) | return 0 | endif
  var name = ChooseType(label)
  if empty(name) | return 0 | endif
  var id = max([0] + mapnew(Items(false), (_, prop) => get(prop, 'id', 0))) + 1
  prop_add_list({type: name, id: id}, ranges)
  return id
enddef

export def Note(align: string, text: any = null, label: string = ''): number
  if index(['inline', 'after', 'right', 'above', 'below'], align) < 0
    throw 'PlanetVim: invalid virtual text alignment'
  endif
  var value = text == null ? planet#prompt#Ask('Virtual text (not written to the file): ') : text
  if value == null || empty(value) | return 0 | endif
  var name = ChooseType(label)
  if empty(name) | return 0 | endif
  var options: dict<any> = {type: name, text: value}
  if align !=# 'inline'
    options.text_align = align
    options.text_padding_left = 1
  endif
  var id = prop_add(line('.'), align ==# 'inline' ? col('.') : 0, options)
  var notes = get(b:, 'PV_textprop_notes', [])
  if index(notes, id) < 0 | add(notes, id) | endif
  b:PV_textprop_notes = notes
  return id
enddef

def Description(prop: dict<any>): string
  return printf('%d:%d  %s  %s', prop.lnum, prop.col,
    get(prop, 'type', '(deleted type)'), has_key(prop, 'text') ? prop.text
      : printf('id=%d  length=%d', prop.id, prop.length))
enddef

export def List(manual: bool = true): number
  var entries = mapnew(Items(manual), (_, prop) => ({bufnr: bufnr(), lnum: prop.lnum,
    col: max([1, prop.col]), text: Description(prop)}))
  setloclist(0, [], ' ', {title: manual ? 'Manual text properties' : 'All text properties', items: entries})
  if empty(entries)
    echom 'PlanetVim: no text properties in this buffer'
  else
    lopen
  endif
  return len(entries)
enddef

export def InspectTypes()
  var lines = ['Text property types (buffer ' .. bufnr() .. ')', '']
  for buffer in [0, bufnr()]
    var options = buffer == 0 ? {} : {bufnr: buffer}
    for name in sort(prop_type_list(options))
      add(lines, (buffer == 0 ? 'Global: ' : 'Buffer: ') .. name)
      add(lines, '  ' .. string(prop_type_get(name, options)))
    endfor
  endfor
  planet#health#Scratch('PlanetVim Text Property Types', lines)
enddef

export def Jump(forward: bool): number
  var properties = filter(Items(), (_, prop) => prop.start)
  sort(properties, (a, b) => a.lnum == b.lnum ? a.col - b.col : a.lnum - b.lnum)
  if !forward | reverse(properties) | endif
  if empty(properties)
    echom 'PlanetVim: no manual text properties in this buffer'
    return 0
  endif
  var matches = filter(copy(properties), (_, prop) => forward
    ? (prop.lnum > line('.') || (prop.lnum == line('.') && max([1, prop.col]) > col('.')))
    : (prop.lnum < line('.') || (prop.lnum == line('.') && max([1, prop.col]) < col('.'))))
  var target = empty(matches) ? properties[0] : matches[0]
  normal! m'
  cursor(target.lnum, max([1, target.col]))
  normal! zv
  return 1
enddef

export def Remove(id: any = null): number
  var properties = filter(Items(), (_, prop) => prop.start)
  if id != null
    properties = filter(properties, (_, prop) => prop.id == id)
  else
    var choice = planet#prompt#Choose('Remove manual text property', mapnew(properties, (_, prop) => Description(prop)))
    if choice < 0 | return 0 | endif
    properties = [properties[choice]]
  endif
  var removed = 0
  for prop in properties
    removed += prop_remove({type: prop.type, id: prop.id, both: true, all: true}, 1, line('$'))
  endfor
  return removed
enddef

export def Clear(): number
  var types = Types()
  b:PV_textprop_notes = []
  return empty(types) ? 0 : prop_remove({types: types, all: true}, 1, line('$'))
enddef
