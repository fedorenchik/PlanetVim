scriptversion 4

func! s:Range(scope) abort
  if a:scope ==# 'buffer' | return [1, line('$')] | endif
  if a:scope !=# 'selection' | throw 'PlanetVim: invalid editing scope' | endif
  let l:selection = planet#selection#Current()
  return [min([l:selection.start[1], l:selection.end[1]]), max([l:selection.start[1], l:selection.end[1]])]
endfunc

func! planet#search#Find(literal, pattern = v:null, selected = 0) abort
  let l:pattern = a:selected ? planet#selection#Text(planet#selection#Current()) : a:pattern
  if l:pattern is v:null | let l:pattern = planet#prompt#Ask(a:literal ? 'Find literal text in this buffer: ' : 'Find Vim pattern in this buffer: ') | endif
  if l:pattern is v:null || empty(l:pattern) | return 0 | endif
  if a:literal | let l:pattern = '\V' .. substitute(escape(l:pattern, '\'), "\n", '\\n', 'g') | endif
  try
    call match('', l:pattern)
  catch
    echomsg 'PlanetVim: invalid search pattern: ' .. v:exception
    return 0
  endtry
  let @/ = l:pattern
  call histadd('/', l:pattern)
  set hlsearch
  return search(l:pattern, &wrapscan ? 'w' : 'W')
endfunc

func! planet#search#Case(kind) abort
  if index(['sensitive', 'ignore', 'smart'], a:kind) < 0 | throw 'PlanetVim: invalid case policy' | endif
  let &ignorecase = a:kind !=# 'sensitive'
  let &smartcase = a:kind ==# 'smart'
endfunc

func! planet#search#Substitute(scope, pattern = v:null, replacement = v:null, confirm = v:null) abort
  let l:range = s:Range(a:scope)
  if a:scope ==# 'selection' | execute "normal! \<Esc>" | endif
  let l:pattern = a:pattern is v:null ? planet#prompt#Ask('Replace pattern in ' .. a:scope .. ' (lines ' .. join(l:range, '-') .. '): ') : a:pattern
  if l:pattern is v:null || empty(l:pattern) | return 0 | endif
  let l:replacement = a:replacement is v:null ? planet#prompt#Ask('Replacement (empty deletes matches): ') : a:replacement
  if l:replacement is v:null | return 0 | endif
  let l:confirm = a:confirm
  if l:confirm is v:null
    let l:choice = planet#prompt#Choose('Confirm substitutions?', ['Ask for each match', 'Apply all matches in the stated scope', 'Cancel'])
    if l:choice < 0 || l:choice == 2 | return 0 | endif
    let l:confirm = l:choice == 0
  endif
  if a:scope ==# 'selection'
    let l:pattern = '\%V\%(' .. l:pattern .. '\)\%(\%V\_.\)\@<='
  endif
  execute 'keeppatterns ' .. join(l:range, ',') .. 's/' .. escape(l:pattern, '/') .. '/' .. escape(l:replacement, '/') .. '/ge' .. (l:confirm ? 'c' : '')
  return 1
endfunc

func! planet#search#Global(inverse, scope, pattern = v:null, command = v:null, confirm = 1) abort
  let l:range = s:Range(a:scope)
  if a:scope ==# 'selection' | execute "normal! \<Esc>" | endif
  let l:pattern = a:pattern is v:null ? planet#prompt#Ask('Pattern for ' .. (a:inverse ? 'nonmatching' : 'matching') .. ' lines in ' .. a:scope .. ': ') : a:pattern
  if l:pattern is v:null || empty(l:pattern) | return 0 | endif
  let l:command = a:command is v:null ? planet#prompt#Ask('Ex command to run on each chosen line: ', 'print', 'command') : a:command
  if l:command is v:null || empty(l:command) | return 0 | endif
  if a:confirm && confirm('Run :' .. l:command .. ' on ' .. (a:inverse ? 'nonmatching' : 'matching') .. ' lines ' .. join(l:range, '-') .. ' for /' .. l:pattern .. '/?', "&Run\n&Cancel", 2) != 1 | return 0 | endif
  execute 'keeppatterns ' .. join(l:range, ',') .. (a:inverse ? 'vglobal/' : 'global/') .. escape(l:pattern, '/') .. '/' .. l:command
  return 1
endfunc

func! planet#search#Sort(kind, pattern = v:null) abort
  let l:visual = index(['v', 'V', "\<C-v>", 's', 'S', "\<C-s>"], mode()) >= 0
  let l:range = s:Range(l:visual ? 'selection' : 'buffer')
  let l:flags = get({'text': '', 'numeric': 'n', 'float': 'f', 'ignore case': 'i', 'unique': 'u', 'reverse': '', 'matched key': 'r'}, a:kind, v:null)
  if l:flags is v:null | throw 'PlanetVim: invalid sorting choice' | endif
  let l:pattern = ''
  if a:kind ==# 'matched key'
    let l:pattern = a:pattern is v:null ? planet#prompt#Ask('Pattern matching the sort key on each line: ') : a:pattern
    if l:pattern is v:null || empty(l:pattern) | return 0 | endif
  endif
  if l:visual | execute "normal! \<Esc>" | endif
  execute join(l:range, ',') .. 'sort' .. (a:kind ==# 'reverse' ? '!' : '') .. ' ' .. l:flags .. (empty(l:pattern) ? '' : ' /' .. escape(l:pattern, '/') .. '/')
  return 1
endfunc

func! planet#search#Menus(group) abort
  if a:group ==# 'basic'
    an 130.341 🔎&/.Find\ Literal\ Text <Cmd>call planet#search#Find(1)<CR>
    an 130.341 🔎&/.Find\ Pattern <Cmd>call planet#search#Find(0)<CR>
    an 130.341 🔎&/.Find\ Selection viw<Cmd>call planet#search#Find(1, v:null, 1)<CR>
    vnoremenu 130.341 🔎&/.Find\ Selection <Cmd>call planet#search#Find(1, v:null, 1)<CR>
    snoremenu 130.341 🔎&/.Find\ Selection <Cmd>call planet#search#Find(1, v:null, 1)<CR>
    an 130.341 🔎&/.Clear\ Highlight <Cmd>nohlsearch<CR>
    for l:case in ['sensitive', 'ignore', 'smart']
      execute 'anoremenu 130.342 🔎&/.Case.' .. l:case .. " <Cmd>call planet#search#Case('" .. l:case .. "')<CR>"
    endfor
    an 130.342 🔎&/.Toggle\ Wrap\ Search <Cmd>set wrapscan!<CR>
    an 130.342 🔎&/.Current\ Search\ Options <Cmd>set ignorecase? smartcase? wrapscan? hlsearch?<CR>
    an 130.342 🔎&/.Pattern\ Help <Cmd>help pattern<CR>
    for l:scope in ['buffer', 'selection']
      let l:prefix = l:scope ==# 'selection' ? 'V' : ''
      execute 'anoremenu 130.343 🔎&/.Replace\ with\ Scope.' .. l:scope .. ' ' .. l:prefix .. "<Cmd>call planet#search#Substitute('" .. l:scope .. "')<CR>"
      for [l:label, l:inverse] in [['Matching lines', 0], ['Nonmatching lines', 1]]
        execute 'anoremenu 125.581 ✏️&m.Run\ on\ Lines.' .. escape(l:label, ' ') .. '.' .. l:scope .. ' ' .. l:prefix .. '<Cmd>call planet#search#Global(' .. l:inverse .. ", '" .. l:scope .. "')<CR>"
        if l:scope ==# 'selection'
          for l:cmd in ['vnoremenu', 'snoremenu']
            execute l:cmd .. ' 125.581 ✏️&m.Run\ on\ Lines.' .. escape(l:label, ' ') .. '.' .. l:scope .. ' <Cmd>call planet#search#Global(' .. l:inverse .. ", 'selection')<CR>"
          endfor
        endif
      endfor
    endfor
    vnoremenu 130.343 🔎&/.Replace\ with\ Scope.selection <Cmd>call planet#search#Substitute('selection')<CR>
    snoremenu 130.343 🔎&/.Replace\ with\ Scope.selection <Cmd>call planet#search#Substitute('selection')<CR>
    for l:kind in ['text', 'numeric', 'float', 'ignore case', 'unique', 'reverse', 'matched key']
      for l:cmd in ['anoremenu', 'vnoremenu', 'snoremenu']
        execute l:cmd .. ' 125.582 ✏️&m.Sort\ Options.' .. escape(l:kind, ' ') .. " <Cmd>call planet#search#Sort('" .. l:kind .. "')<CR>"
      endfor
    endfor
  elseif a:group ==# 'nav'
    an 810.51 🗃️&a.Remove\ Duplicates <Cmd>argdedupe<CR>
  endif
endfunc
