vim9script
def LocalRange(scope: any): any
  var selection: any
  if scope ==# 'buffer'
    return [1, line('$')]
  endif
  if scope !=# 'selection'
    throw 'PlanetVim: invalid editing scope'
  endif
  selection = planet#selection#Current()
  return [min([selection.start[1], selection.end[1]]), max([selection.start[1], selection.end[1]])]
enddef

export def Find(literal: any, arg_pattern: any = v:null, selected: any = 0): any
  var pattern: any = selected ? planet#selection#Text(planet#selection#Current()) : arg_pattern
  if pattern == null
    pattern = planet#prompt#Ask(literal ? 'Find literal text in this buffer: ' : 'Find Vim pattern in this buffer: ')
  endif
  if pattern == null || empty(pattern)
    return 0
  endif
  if literal
    pattern = '\V' .. substitute(escape(pattern, '\'), "\n", '\\n', 'g')
  endif
  try
    match('', pattern)
  catch
    echomsg 'PlanetVim: invalid search pattern: ' .. v:exception
    return 0
  endtry
  @/ = pattern
  histadd('/', pattern)
  set hlsearch
  return search(pattern, &wrapscan ? 'w' : 'W')
enddef

export def Case(kind: any): any
  if index(['sensitive', 'ignore', 'smart'], kind) < 0
    throw 'PlanetVim: invalid case policy'
  endif
  &ignorecase = kind !=# 'sensitive'
  &smartcase = kind ==# 'smart'
  return 0
enddef

export def Substitute(scope: any, arg_pattern: any = v:null, arg_replacement: any = v:null, arg_confirm: any = v:null): any
  var choice: any
  var range: any = LocalRange(scope)
  if scope ==# 'selection'
    execute "normal! \<Esc>"
  endif
  var pattern: any = arg_pattern == null ? planet#prompt#Ask('Replace pattern in ' .. scope .. ' (lines ' .. join(range, '-') .. '): ') : arg_pattern
  if pattern == null || empty(pattern)
    return 0
  endif
  var replacement: any = arg_replacement == null ? planet#prompt#Ask('Replacement (empty deletes matches): ') : arg_replacement
  if replacement == null
    return 0
  endif
  var confirm: any = arg_confirm
  if confirm == null
    choice = planet#prompt#Choose('Confirm substitutions?', ['Ask for each match', 'Apply all matches in the stated scope', 'Cancel'])
    if choice < 0 || choice == 2
      return 0
    endif
    confirm = choice == 0
  endif
  if scope ==# 'selection'
    pattern = '\%V\%(' .. pattern .. '\)\%(\%V\_.\)\@<='
  endif
  execute 'keeppatterns :' .. join(range, ',') .. 's/' .. escape(pattern, '/') .. '/' .. escape(replacement, '/') .. '/ge' .. (confirm ? 'c' : '')
  return 1
enddef

export def Global(inverse: any, scope: any, arg_pattern: any = v:null, arg_command: any = v:null, confirm: any = 1): any
  var range: any = LocalRange(scope)
  if scope ==# 'selection'
    execute "normal! \<Esc>"
  endif
  var pattern: any = arg_pattern == null ? planet#prompt#Ask('Pattern for ' .. (inverse ? 'nonmatching' : 'matching') .. ' lines in ' .. scope .. ': ') : arg_pattern
  if pattern == null || empty(pattern)
    return 0
  endif
  var command: any = arg_command == null ? planet#prompt#Ask('Ex command to run on each chosen line: ', 'print', 'command') : arg_command
  if command == null || empty(command)
    return 0
  endif
  if confirm && confirm('Run :' .. command .. ' on ' .. (inverse ? 'nonmatching' : 'matching') .. ' lines ' .. join(range,
       '-') .. ' for /' .. pattern .. '/?', "&Run\n&Cancel", 2) != 1
    return 0
  endif
  execute 'keeppatterns :' .. join(range, ',') .. (inverse ? 'vglobal/' : 'global/') .. escape(pattern, '/') .. '/' .. command
  return 1
enddef

export def Sort(kind: any, arg_pattern: any = v:null): any
  var visual: any = index(['v', 'V', "\<C-v>", 's', 'S', "\<C-s>"], mode()) >= 0
  var range: any = LocalRange(visual ? 'selection' : 'buffer')
  var flags: any = get({'text': '', 'numeric': 'n', 'float': 'f', 'ignore case': 'i', 'unique': 'u', 'reverse': '', 'matched key': 'r'}, kind, v:null)
  if flags == null
    throw 'PlanetVim: invalid sorting choice'
  endif
  var pattern: any = ''
  if kind ==# 'matched key'
    pattern = arg_pattern == null ? planet#prompt#Ask('Pattern matching the sort key on each line: ') : arg_pattern
    if pattern == null || empty(pattern)
      return 0
    endif
  endif
  if visual
    execute "normal! \<Esc>"
  endif
  execute ':' .. join(range, ',') .. 'sort' .. (kind ==# 'reverse' ? '!' : '') .. ' ' .. flags .. (empty(pattern) ? '' : ' /' .. escape(pattern, '/') .. '/')
  return 1
enddef

export def Menus(group: any): any
  var prefix: any
  var case: any
  var cmd: any
  if group ==# 'basic'
    PlanetMenu an 130.341 🔎&/.Find\ Literal\ Text <Cmd>call planet#search#Find(1)<CR>
    PlanetMenu an 130.341 🔎&/.Find\ Pattern <Cmd>call planet#search#Find(0)<CR>
    PlanetMenu an 130.341 🔎&/.Find\ Selection viw<Cmd>call planet#search#Find(1, v:null, 1)<CR>
    PlanetMenu vnoremenu 130.341 🔎&/.Find\ Selection <Cmd>call planet#search#Find(1, v:null, 1)<CR>
    PlanetMenu snoremenu 130.341 🔎&/.Find\ Selection <Cmd>call planet#search#Find(1, v:null, 1)<CR>
    PlanetMenu an 130.341 🔎&/.Clear\ Highlight <Cmd>nohlsearch<CR>
    for item_case in ['sensitive', 'ignore', 'smart']
      case = item_case
      execute 'PlanetMenu anoremenu 130.342 🔎&/.Case.' .. case .. " <Cmd>call planet#search#Case('" .. case .. "')<CR>"
    endfor
    PlanetMenu an 130.342 🔎&/.Toggle\ Wrap\ Search <Cmd>set wrapscan!<CR>
    PlanetMenu an 130.342 🔎&/.Current\ Search\ Options <Cmd>set ignorecase? smartcase? wrapscan? hlsearch?<CR>
    PlanetMenu an 130.342 🔎&/.Pattern\ Help <Cmd>help pattern<CR>
    for scope in ['buffer', 'selection']
      prefix = scope ==# 'selection' ? 'V' : ''
      execute 'PlanetMenu anoremenu 130.343 🔎&/.Replace\ with\ Scope.' .. scope .. ' ' .. prefix .. "<Cmd>call planet#search#Substitute('" .. scope .. "')<CR>"
      for [label, inverse] in [['Matching lines', 0], ['Nonmatching lines', 1]]
        execute 'PlanetMenu anoremenu 125.581 ✏️&m.Run\ on\ Lines.' .. escape(label, ' ') .. '.' .. scope .. ' ' .. prefix .. '<Cmd>call planet#search#Global(' .. inverse .. ", '" .. scope .. "')<CR>"
        if scope ==# 'selection'
          for item_cmd in ['vnoremenu', 'snoremenu']
            cmd = item_cmd
            execute 'PlanetMenu ' .. cmd .. ' 125.581 ✏️&m.Run\ on\ Lines.' .. escape(label, ' ') .. '.' .. scope .. ' <Cmd>call planet#search#Global(' .. inverse .. ", 'selection')<CR>"
          endfor
        endif
      endfor
    endfor
    PlanetMenu vnoremenu 130.343 🔎&/.Replace\ with\ Scope.selection <Cmd>call planet#search#Substitute('selection')<CR>
    PlanetMenu snoremenu 130.343 🔎&/.Replace\ with\ Scope.selection <Cmd>call planet#search#Substitute('selection')<CR>
    for kind in ['text', 'numeric', 'float', 'ignore case', 'unique', 'reverse', 'matched key']
      for item_cmd in ['anoremenu', 'vnoremenu', 'snoremenu']
        cmd = item_cmd
        execute 'PlanetMenu ' .. cmd .. ' 125.582 ✏️&m.Sort\ Options.' .. escape(kind, ' ') .. " <Cmd>call planet#search#Sort('" .. kind .. "')<CR>"
      endfor
    endfor
  elseif group ==# 'nav'
    PlanetMenu an 810.51 🗃️&a.Remove\ Duplicates <Cmd>argdedupe<CR>
  endif
  return 0
enddef
