vim9script

var script_state: dict<any> = {}

export def Pending(): any
  var text: any = get(script_state, 'pending', '')
  script_state.pending = ''
  return text
enddef

export def Insert(kind: any, arg_value: any = v:null, context: any = 'n'): any
  var selection: any
  var text: any
  var hex: any
  var code: any
  var result: any
  if kind ==# 'literal'
    if context ==# 'v'
      planet#selection#Restore(planet#selection#Current())
    endif
    feedkeys((context ==# 'i' ? '' : context ==# 'v' ? 'c' : 'a') .. "\<C-v>", 'in')
    return 1
  endif
  var prompts: any = {'digraph': 'Two digraph characters (Edit → Insert Special Character → List Digraphs): ',
       'unicode': 'Unicode code point in hexadecimal (for example 00E9 or 1F600): ', 'expression': 'Vim expression to insert: '}
  if !has_key(prompts, kind)
    throw 'PlanetVim: unknown character input'
  endif
  selection = context ==# 'v' ? planet#selection#Current() : {}
  var value: any = arg_value == null ? planet#prompt#Ask(prompts[kind]) : arg_value
  if value == null || empty(value)
    return 0
  endif
  try
    if kind ==# 'digraph'
      if strchars(value) != 2
        echomsg 'PlanetVim: enter exactly two digraph characters'
        return 0
      endif
      text = digraph_get(value)
    elseif kind ==# 'unicode'
      hex = substitute(value, '^\%(U+\|0x\)', '', '')
      if hex !~# '^\x\{1,6}$'
        echomsg 'PlanetVim: enter a hexadecimal code point'
        return 0
      endif
      code = str2nr(hex, 16)
      if code < 1 || code > 0x10ffff || (code >= 0xd800 && code <= 0xdfff)
        echomsg 'PlanetVim: enter a valid nonzero Unicode scalar value'
        return 0
      endif
      text = nr2char(code)
    else
      result = eval(value)
      text = type(result) == v:t_string ? result : string(result)
    endif
  catch
    echomsg 'PlanetVim character input: ' .. v:exception
    return 0
  endtry
  script_state.pending = text
  if !empty(selection)
    planet#selection#Restore(selection)
  endif
  feedkeys((context ==# 'i' ? '' : context ==# 'v' ? 'c' : 'a') .. "\<C-r>=planet#input#Pending()\<CR>", 'in')
  return 1
enddef

export def Keymaps(): any
  var names: any = []
  for file in globpath(&runtimepath, 'keymap/*.vim', 0, 1)
    add(names, substitute(fnamemodify(file, ':t:r'), '_.*$', '', ''))
  endfor
  return uniq(sort(names))
enddef

export def Keymap(arg_value: any = v:null): any
  var items: any
  var index: any
  var value: any = arg_value
  if value == null
    items = ['None (use the operating system keyboard)'] + planet#input#Keymaps()
    index = planet#prompt#Choose('Buffer input language/keymap:', items)
    if index < 0
      return 0
    endif
    value = index == 0 ? '' : items[index]
  endif
  if !empty(value) && index(planet#input#Keymaps(), value) < 0
    echomsg 'PlanetVim: choose an installed keymap'
    return 0
  endif
  &l:keymap = value
  &l:iminsert = empty(value) ? 0 :  1
  &l:imsearch = -1
  return 1
enddef

export def SpellLanguages(): any
  var languages: any = []
  for file in globpath(&runtimepath, 'spell/*.spl', 0, 1)
    add(languages, matchstr(fnamemodify(file, ':t'), '^[^.]*'))
  endfor
  return uniq(sort(languages))
enddef

export def SpellLanguage(arg_value: any = v:null): any
  var languages: any
  var index: any
  var value: any = arg_value
  if value == null
    languages = planet#input#SpellLanguages()
    index = planet#prompt#Choose('Installed spelling language for this buffer:', languages)
    if index < 0
      return 0
    endif
    value = languages[index]
  endif
  if index(planet#input#SpellLanguages(), value) < 0
    echomsg 'PlanetVim: install this Vim spelling dictionary first (:help spell-load)'
    return 0
  endif
  &l:spelllang = value
  setlocal spell
  return 1
enddef

export def Menus(group: any): any
  if group ==# 'basic'
    for [label, kind] in [['Digraph', 'digraph'], ['Unicode code point', 'unicode'], ['Literal character (then type a key)', 'literal'], ['Expression result', 'expression']]
      for [cmd, context] in [['anoremenu', 'n'], ['inoremenu', 'i'], ['vnoremenu', 'v'], ['snoremenu', 'v']]
        execute 'PlanetMenu ' .. cmd .. ' 120.306 📝&e.Insert\ Special\ Character.' .. escape(label, ' .') .. " <Cmd>call planet#input#Insert('" .. kind .. "', v:null, '" .. context .. "')<CR>"
      endfor
    endfor
    PlanetMenu an 120.306 📝&e.Insert\ Special\ Character.List\ Digraphs <Cmd>digraphs<CR>
    PlanetMenu an 120.306 📝&e.Insert\ Special\ Character.Help <Cmd>help i_CTRL-K<CR>
  elseif group ==# 'settings'
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Choose\ Buffer\ Keymap <Cmd>call planet#input#Keymap()<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Use\ Operating\ System\ Keyboard <Cmd>call planet#input#Keymap('')<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Toggle\ Vim\ Keymap <Cmd>let &l:iminsert = &l:iminsert == 1 ? 0 : 1<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Current\ Values <Cmd>setlocal keymap? iminsert? imsearch?<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Help <Cmd>help mbyte-keymap<CR>
  elseif group ==# 'tools'
    PlanetMenu an 720.11 🔠&-.Choose\ Spelling\ Language <Cmd>call planet#input#SpellLanguage()<CR>
  endif
  return 0
enddef
