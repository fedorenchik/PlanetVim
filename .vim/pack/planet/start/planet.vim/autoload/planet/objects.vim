vim9script
export def Block(action: any): any
  if index(['insert', 'append', 'change', 'corner'], action) < 0
    throw 'PlanetVim: unknown block action'
  endif
  if mode() ==# "\<C-s>"
    execute "normal! \<C-g>"
  endif
  if mode() !=# "\<C-v>"
    echomsg 'PlanetVim: select a rectangular block first (Selection → Visual Block Mode)'
    return 0
  endif
  feedkeys(get({'insert': 'I', 'append': 'A', 'change': 'c', 'corner': 'o'}, action), 'in')
  return 1
enddef

export def Number(action: any, arg_count: any = v:null): any
  if index(['increment', 'decrement', 'increase each', 'decrease each'], action) < 0
    throw 'PlanetVim: unknown number action'
  endif
  var visual: any = index(['v', 'V', "\<C-v>", 's', 'S', "\<C-s>"], mode()) >= 0
  var selection: any = visual ? planet#selection#Current() : {}
  var count: any = arg_count == null ? planet#prompt#Ask('Positive increment/decrement count: ', '1') : string(arg_count)
  if count == null || empty(count)
    return 0
  endif
  if count !~# '^\d\+$' || str2nr(count) < 1
    echomsg 'PlanetVim: enter a positive integer'
    return 0
  endif
  if action =~# 'each' && !visual
    echomsg 'PlanetVim: select lines or a block before creating a number sequence'
    return 0
  endif
  if visual
    planet#selection#Restore(selection)
  endif
  execute 'normal! ' .. str2nr(count) .. (action =~# 'each' ? 'g' : '') .. (action =~# '^dec' ? "\<C-x>" : "\<C-a>")
  return 1
enddef

export def Menus(): any
  var keys: any
  var path: any
  var label: any
  var action: any
  var command: any
  var objects: any = [['Word', 'w'], ['WORD', 'W'], ['Sentence', 's'], ['Paragraph', 'p'], ['Double quotes',
       '"'], ['Single quotes', "'"], ['Backtick quotes', '`'], ['Parentheses', ')'], ['Brackets', ']'],
       ['Braces', '}'], ['Tag block', 't']]
  for [kind, prefix] in [['Inside', 'i'], ['Around', 'a']]
    for [item_label, object] in objects
      label = item_label
      keys = prefix .. object
      path = '🖍️&i.' .. kind .. '.' .. escape(label, ' ') .. '<Tab>' .. keys
      execute 'PlanetMenu anoremenu 140.20 ' .. path .. ' v' .. keys
      execute 'PlanetMenu vnoremenu 140.20 ' .. path .. ' ' .. keys
      execute 'PlanetMenu snoremenu 140.20 ' .. path .. ' <C-g>' .. keys
      execute 'PlanetMenu onoremenu 140.20 ' .. path .. ' ' .. keys
      execute 'PlanetMenu inoremenu 140.20 ' .. path .. ' <Esc>v' .. keys
      for [verb, operator] in [['Delete', 'd'], ['Change', 'c'], ['Yank', 'y'], ['Format', 'gq']]
        execute 'PlanetMenu anoremenu 140.22 🖍️&i.Text\ Objects.' .. verb .. '.' .. kind .. '.' .. escape(label, ' ') .. '<Tab>' .. operator .. keys .. ' ' .. operator .. keys
      endfor
    endfor
    path = '🖍️&i.' .. kind .. '.Fold<Tab>' .. prefix .. 'z'
    execute 'PlanetMenu nmenu 140.20 ' .. path .. ' v' .. prefix .. 'z'
    execute 'PlanetMenu vmenu 140.20 ' .. path .. ' ' .. prefix .. 'z'
    execute 'PlanetMenu smenu 140.20 ' .. path .. ' <C-g>' .. prefix .. 'z'
    execute 'PlanetMenu omenu 140.20 ' .. path .. ' :<C-u>normal v' .. prefix .. 'z<CR>'
  endfor
  for [item_label, item_action] in [['Insert before block', 'insert'], ['Append after block', 'append'], ['Change block', 'change'], ['Other corner', 'corner']]
    label = item_label
    action = item_action
    for item_command in ['anoremenu', 'vnoremenu', 'snoremenu']
      command = item_command
      execute 'PlanetMenu ' .. command .. ' 140.24 🖍️&i.Block.' .. escape(label, ' ') .. " <Cmd>call planet#objects#Block('" .. action .. "')<CR>"
    endfor
  endfor
  PlanetMenu an 140.25 🖍️&i.Text\ Object\ Help <Cmd>help text-objects<CR>
  PlanetMenu an 140.25 🖍️&i.Block\ Editing\ Help <Cmd>help blockwise-operators<CR>
  for [item_label, item_action] in [['Increment', 'increment'], ['Decrement', 'decrement'], ['Increase each line', 'increase each'], ['Decrease each line', 'decrease each']]
    label = item_label
    action = item_action
    for item_command in ['anoremenu', 'vnoremenu', 'snoremenu']
      command = item_command
      execute 'PlanetMenu ' .. command .. ' 125.580 ✏️&m.Numbers.' .. escape(label, ' ') .. " <Cmd>call planet#objects#Number('" .. action .. "', 1)<CR>"
      execute 'PlanetMenu ' .. command .. ' 125.580 ✏️&m.Numbers.' .. escape(label .. ' by...', ' .') .. " <Cmd>call planet#objects#Number('" .. action .. "')<CR>"
    endfor
  endfor
  for format in ['alpha', 'bin', 'hex', 'octal', 'unsigned', 'blank']
    execute 'PlanetMenu anoremenu 125.580 ✏️&m.Numbers.Formats.Toggle\ ' .. format .. " <Cmd>call planet#preferences#Flag('nrformats', '" .. format .. "', 1)<CR>"
  endfor
  PlanetMenu an 125.580 ✏️&m.Numbers.Current\ Formats <Cmd>setlocal nrformats?<CR>
  PlanetMenu an 125.580 ✏️&m.Numbers.Help <Cmd>help v_g_CTRL-A<CR>
  # These native operators must consume the active selection, not amenu's
  # generic CTRL-C wrapper followed by a fresh pending operator.
  for [item_path, item_keys] in [['✏️&m.To\ UPPER', 'gU'], ['✏️&m.To\ lower', 'gu'], ['✏️&m.Swap\ Case', 'g~'], ['✏️&m.Format\ Text', 'gq'], ['✏️&m.Format\ Text\ Keep\ Cursor', 'gw'], ['✏️&m.Join\ Lines', 'J'], ['✏️&m.Join\ Lines\ without\ Whitespace', 'gJ']]
    path = item_path
    keys = item_keys
    execute 'PlanetMenu vnoremenu ' .. path .. ' ' .. keys
    execute 'PlanetMenu snoremenu ' .. path .. ' <C-g>' .. keys
  endfor
  return 0
enddef
