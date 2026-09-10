scriptversion 4

func! planet#input#Pending() abort
  let l:text = get(s:, 'pending', '')
  let s:pending = ''
  return l:text
endfunc

func! planet#input#Insert(kind, value = v:null, context = 'n') abort
  if a:kind ==# 'literal'
    if a:context ==# 'v' | call planet#selection#Restore(planet#selection#Current()) | endif
    call feedkeys((a:context ==# 'i' ? '' : a:context ==# 'v' ? 'c' : 'a') .. "\<C-v>", 'in')
    return 1
  endif
  let l:prompts = {'digraph': 'Two digraph characters (Edit → Insert Special Character → List Digraphs): ', 'unicode': 'Unicode code point in hexadecimal (for example 00E9 or 1F600): ', 'expression': 'Vim expression to insert: '}
  if !has_key(l:prompts, a:kind) | throw 'PlanetVim: unknown character input' | endif
  let l:selection = a:context ==# 'v' ? planet#selection#Current() : {}
  let l:value = a:value is v:null ? planet#prompt#Ask(l:prompts[a:kind]) : a:value
  if l:value is v:null || empty(l:value) | return 0 | endif
  try
    if a:kind ==# 'digraph'
      if strchars(l:value) != 2 | echomsg 'PlanetVim: enter exactly two digraph characters' | return 0 | endif
      let l:text = digraph_get(l:value)
    elseif a:kind ==# 'unicode'
      let l:hex = substitute(l:value, '^\%(U+\|0x\)', '', '')
      if l:hex !~# '^\x\{1,6}$' | echomsg 'PlanetVim: enter a hexadecimal code point' | return 0 | endif
      let l:code = str2nr(l:hex, 16)
      if l:code < 1 || l:code > 0x10ffff || (l:code >= 0xd800 && l:code <= 0xdfff)
        echomsg 'PlanetVim: enter a valid nonzero Unicode scalar value'
        return 0
      endif
      let l:text = nr2char(l:code)
    else
      let l:result = eval(l:value)
      let l:text = type(l:result) == v:t_string ? l:result : string(l:result)
    endif
  catch
    echomsg 'PlanetVim character input: ' .. v:exception
    return 0
  endtry
  let s:pending = l:text
  if !empty(l:selection) | call planet#selection#Restore(l:selection) | endif
  call feedkeys((a:context ==# 'i' ? '' : a:context ==# 'v' ? 'c' : 'a') .. "\<C-r>=planet#input#Pending()\<CR>", 'in')
  return 1
endfunc

func! planet#input#Keymaps() abort
  let l:names = []
  for l:file in globpath(&runtimepath, 'keymap/*.vim', 0, 1)
    call add(l:names, substitute(fnamemodify(l:file, ':t:r'), '_.*$', '', ''))
  endfor
  return uniq(sort(l:names))
endfunc

func! planet#input#Keymap(value = v:null) abort
  let l:value = a:value
  if l:value is v:null
    let l:items = ['None (use the operating system keyboard)'] + planet#input#Keymaps()
    let l:index = planet#prompt#Choose('Buffer input language/keymap:', l:items)
    if l:index < 0 | return 0 | endif
    let l:value = l:index == 0 ? '' : l:items[l:index]
  endif
  if !empty(l:value) && index(planet#input#Keymaps(), l:value) < 0
    echomsg 'PlanetVim: choose an installed keymap'
    return 0
  endif
  let &l:keymap = l:value
  let &l:iminsert = empty(l:value) ? 0 : 1
  let &l:imsearch = -1
  return 1
endfunc

func! planet#input#SpellLanguages() abort
  let l:languages = []
  for l:file in globpath(&runtimepath, 'spell/*.spl', 0, 1)
    call add(l:languages, matchstr(fnamemodify(l:file, ':t'), '^[^.]*'))
  endfor
  return uniq(sort(l:languages))
endfunc

func! planet#input#SpellLanguage(value = v:null) abort
  let l:value = a:value
  if l:value is v:null
    let l:languages = planet#input#SpellLanguages()
    let l:index = planet#prompt#Choose('Installed spelling language for this buffer:', l:languages)
    if l:index < 0 | return 0 | endif
    let l:value = l:languages[l:index]
  endif
  if index(planet#input#SpellLanguages(), l:value) < 0
    echomsg 'PlanetVim: install this Vim spelling dictionary first (:help spell-load)'
    return 0
  endif
  let &l:spelllang = l:value
  setlocal spell
  return 1
endfunc

func! planet#input#Menus(group) abort
  if a:group ==# 'basic'
    for [l:label, l:kind] in [['Digraph', 'digraph'], ['Unicode code point', 'unicode'], ['Literal character (then type a key)', 'literal'], ['Expression result', 'expression']]
      for [l:cmd, l:context] in [['anoremenu', 'n'], ['inoremenu', 'i'], ['vnoremenu', 'v'], ['snoremenu', 'v']]
        execute 'PlanetMenu ' .. l:cmd .. ' 120.306 📝&e.Insert\ Special\ Character.' .. escape(l:label, ' .') .. " <Cmd>call planet#input#Insert('" .. l:kind .. "', v:null, '" .. l:context .. "')<CR>"
      endfor
    endfor
    PlanetMenu an 120.306 📝&e.Insert\ Special\ Character.List\ Digraphs <Cmd>digraphs<CR>
    PlanetMenu an 120.306 📝&e.Insert\ Special\ Character.Help <Cmd>help i_CTRL-K<CR>
  elseif a:group ==# 'settings'
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Choose\ Buffer\ Keymap <Cmd>call planet#input#Keymap()<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Use\ Operating\ System\ Keyboard <Cmd>call planet#input#Keymap('')<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Toggle\ Vim\ Keymap <Cmd>let &l:iminsert = &l:iminsert == 1 ? 0 : 1<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Current\ Values <Cmd>setlocal keymap? iminsert? imsearch?<CR>
    PlanetMenu an 900.56 ⚙️&\\.Input\ Language.Help <Cmd>help mbyte-keymap<CR>
  elseif a:group ==# 'tools'
    PlanetMenu an 720.11 🔠&-.Choose\ Spelling\ Language <Cmd>call planet#input#SpellLanguage()<CR>
  endif
endfunc
