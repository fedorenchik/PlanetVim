vim9script

# This traverses thousands of menu nodes. Compile the hot loop while keeping
# the UI and mode-restoration code in the existing legacy autoload module.
const synonyms = {
  diff: ' compare merge',
  inside: ' inner text object',
  recover: ' recovery swap rescue',
  filename: ' file path',
  complete: ' completion autocomplete',
  register: ' clipboard macro',
}

var entries: list<dict<any>> = []

def Walk(path: string, label: string, group: string)
  var children: list<string> = []
  for menu_mode in ['', '!', 't']
    for child in get(menu_info(path, menu_mode), 'submenus', [])
      if index(children, child) < 0
        add(children, child)
      endif
    endfor
  endfor
  if !empty(children)
    for child in children
      Walk(path .. '.' .. escape(child, '\. |'), label .. ' → ' .. child, group)
    endfor
    return
  endif
  var modes: dict<any> = {}
  for menu_mode in ['n', 'i', 'x', 's', 'o', 'c', 't']
    var item = menu_info(path, menu_mode)
    if get(item, 'enabled', 0) && get(item, 'rhs', '<Nop>') !=# '<Nop>'
      modes[menu_mode] = item
    endif
  endfor
  if empty(modes)
    return
  endif
  var text = tolower(substitute(label, '\(\l\)\(\u\)', '\1 \2', 'g'))
  for [pattern, words] in items(synonyms)
    if stridx(text, pattern) >= 0
      text ..= words
    endif
  endfor
  add(entries, {path: path, label: label, group: group, modes: modes, search: text})
enddef

export def Build(path: string, label: string, group: string): list<dict<any>>
  entries = []
  Walk(path, label, group)
  return entries
enddef
