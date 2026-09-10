scriptversion 4

func! planet#objects#Block(action) abort
  if index(['insert', 'append', 'change', 'corner'], a:action) < 0 | throw 'PlanetVim: unknown block action' | endif
  if mode() ==# "\<C-s>" | execute "normal! \<C-g>" | endif
  if mode() !=# "\<C-v>"
    echomsg 'PlanetVim: select a rectangular block first (Selection → Visual Block Mode)'
    return 0
  endif
  call feedkeys(get({'insert': 'I', 'append': 'A', 'change': 'c', 'corner': 'o'}, a:action), 'in')
  return 1
endfunc

func! planet#objects#Number(action, count = v:null) abort
  if index(['increment', 'decrement', 'increase each', 'decrease each'], a:action) < 0 | throw 'PlanetVim: unknown number action' | endif
  let l:visual = index(['v', 'V', "\<C-v>", 's', 'S', "\<C-s>"], mode()) >= 0
  let l:selection = l:visual ? planet#selection#Current() : {}
  let l:count = a:count is v:null ? planet#prompt#Ask('Positive increment/decrement count: ', '1') : string(a:count)
  if l:count is v:null || empty(l:count) | return 0 | endif
  if l:count !~# '^\d\+$' || str2nr(l:count) < 1
    echomsg 'PlanetVim: enter a positive integer'
    return 0
  endif
  if a:action =~# 'each' && !l:visual
    echomsg 'PlanetVim: select lines or a block before creating a number sequence'
    return 0
  endif
  if l:visual | call planet#selection#Restore(l:selection) | endif
  execute 'normal! ' .. str2nr(l:count) .. (a:action =~# 'each' ? 'g' : '') .. (a:action =~# '^dec' ? "\<C-x>" : "\<C-a>")
  return 1
endfunc

func! planet#objects#Menus() abort
  let l:objects = [['Word', 'w'], ['WORD', 'W'], ['Sentence', 's'], ['Paragraph', 'p'], ['Double quotes', '"'], ['Single quotes', "'"], ['Backtick quotes', '`'], ['Parentheses', ')'], ['Brackets', ']'], ['Braces', '}'], ['Tag block', 't']]
  for [l:kind, l:prefix] in [['Inside', 'i'], ['Around', 'a']]
    for [l:label, l:object] in l:objects
      let l:keys = l:prefix .. l:object
      let l:path = '🖍️&i.' .. l:kind .. '.' .. escape(l:label, ' ') .. '<Tab>' .. l:keys
      execute 'PlanetMenu anoremenu 140.20 ' .. l:path .. ' v' .. l:keys
      execute 'PlanetMenu vnoremenu 140.20 ' .. l:path .. ' ' .. l:keys
      execute 'PlanetMenu snoremenu 140.20 ' .. l:path .. ' <C-g>' .. l:keys
      execute 'PlanetMenu onoremenu 140.20 ' .. l:path .. ' ' .. l:keys
      execute 'PlanetMenu inoremenu 140.20 ' .. l:path .. ' <Esc>v' .. l:keys
      for [l:verb, l:operator] in [['Delete', 'd'], ['Change', 'c'], ['Yank', 'y'], ['Format', 'gq']]
        execute 'PlanetMenu anoremenu 140.22 🖍️&i.Text\ Objects.' .. l:verb .. '.' .. l:kind .. '.' .. escape(l:label, ' ') .. '<Tab>' .. l:operator .. l:keys .. ' ' .. l:operator .. l:keys
      endfor
    endfor
    let l:path = '🖍️&i.' .. l:kind .. '.Fold<Tab>' .. l:prefix .. 'z'
    execute 'PlanetMenu nmenu 140.20 ' .. l:path .. ' v' .. l:prefix .. 'z'
    execute 'PlanetMenu vmenu 140.20 ' .. l:path .. ' ' .. l:prefix .. 'z'
    execute 'PlanetMenu smenu 140.20 ' .. l:path .. ' <C-g>' .. l:prefix .. 'z'
    execute 'PlanetMenu omenu 140.20 ' .. l:path .. ' :<C-u>normal v' .. l:prefix .. 'z<CR>'
  endfor
  for [l:label, l:action] in [['Insert before block', 'insert'], ['Append after block', 'append'], ['Change block', 'change'], ['Other corner', 'corner']]
    for l:command in ['anoremenu', 'vnoremenu', 'snoremenu']
      execute 'PlanetMenu ' .. l:command .. ' 140.24 🖍️&i.Block.' .. escape(l:label, ' ') .. " <Cmd>call planet#objects#Block('" .. l:action .. "')<CR>"
    endfor
  endfor
  PlanetMenu an 140.25 🖍️&i.Text\ Object\ Help <Cmd>help text-objects<CR>
  PlanetMenu an 140.25 🖍️&i.Block\ Editing\ Help <Cmd>help blockwise-operators<CR>
  for [l:label, l:action] in [['Increment', 'increment'], ['Decrement', 'decrement'], ['Increase each line', 'increase each'], ['Decrease each line', 'decrease each']]
    for l:command in ['anoremenu', 'vnoremenu', 'snoremenu']
      execute 'PlanetMenu ' .. l:command .. ' 125.580 ✏️&m.Numbers.' .. escape(l:label, ' ') .. " <Cmd>call planet#objects#Number('" .. l:action .. "', 1)<CR>"
      execute 'PlanetMenu ' .. l:command .. ' 125.580 ✏️&m.Numbers.' .. escape(l:label .. ' by...', ' .') .. " <Cmd>call planet#objects#Number('" .. l:action .. "')<CR>"
    endfor
  endfor
  for l:format in ['alpha', 'bin', 'hex', 'octal', 'unsigned', 'blank']
    execute 'PlanetMenu anoremenu 125.580 ✏️&m.Numbers.Formats.Toggle\ ' .. l:format .. " <Cmd>call planet#preferences#Flag('nrformats', '" .. l:format .. "', 1)<CR>"
  endfor
  PlanetMenu an 125.580 ✏️&m.Numbers.Current\ Formats <Cmd>setlocal nrformats?<CR>
  PlanetMenu an 125.580 ✏️&m.Numbers.Help <Cmd>help v_g_CTRL-A<CR>
  " These native operators must consume the active selection, not amenu's
  " generic CTRL-C wrapper followed by a fresh pending operator.
  for [l:path, l:keys] in [['✏️&m.To\ UPPER', 'gU'], ['✏️&m.To\ lower', 'gu'], ['✏️&m.Swap\ Case', 'g~'], ['✏️&m.Format\ Text', 'gq'], ['✏️&m.Format\ Text\ Keep\ Cursor', 'gw'], ['✏️&m.Join\ Lines', 'J'], ['✏️&m.Join\ Lines\ without\ Whitespace', 'gJ']]
    execute 'PlanetMenu vnoremenu ' .. l:path .. ' ' .. l:keys
    execute 'PlanetMenu snoremenu ' .. l:path .. ' <C-g>' .. l:keys
  endfor
endfunc
