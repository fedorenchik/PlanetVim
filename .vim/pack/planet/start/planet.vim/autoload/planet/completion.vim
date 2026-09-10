scriptversion 4

let s:sources = [
      \ ['Words', 'words', 'C-n'], ['Current buffer words', 'buffer', 'C-x C-n'],
      \ ['Whole lines', 'lines', 'C-x C-l'], ['Filename', 'filename', 'C-x C-f'],
      \ ['Dictionary', 'dictionary', 'C-x C-k'], ['Thesaurus', 'thesaurus', 'C-x C-t'],
      \ ['Tags', 'tags', 'C-x C-]'], ['Included keywords', 'include', 'C-x C-i'],
      \ ['Included definitions', 'define', 'C-x C-d'], ['Vim commands', 'commands', 'C-x C-v'],
      \ ['Omni (language server)', 'omni', 'C-x C-o'], ['User function', 'user', 'C-x C-u'],
      \ ['Spelling', 'spell', 'C-x s'], ['Register contents', 'register', 'C-x C-r'],
      \ ['Accept', 'accept', 'C-y'], ['Cancel', 'cancel', 'C-e']]

func! planet#completion#Start(source, insert = 0) abort
  for [l:label, l:source, l:keys] in s:sources
    if a:source !=# l:source | continue | endif
    if l:source ==# 'register' && !has('patch-9.1.1408')
      return planet#prompt#Unavailable('register completion (Vim 9.1.1408)', 'i_CTRL-X_CTRL-R')
    endif
    let l:option = get({'dictionary': 'dictionary', 'thesaurus': 'thesaurus', 'omni': 'omnifunc', 'user': 'completefunc'}, l:source, '')
    if !empty(l:option) && empty(eval('&l:' .. l:option))
      echomsg 'PlanetVim: configure ' .. l:option .. ' for this buffer first (:help ' .. l:option .. ')'
      return 0
    endif
    if index(['accept', 'cancel'], l:source) >= 0 && !pumvisible() | return 0 | endif
    let l:sequence = ''
    for l:key in split(l:keys)
      let l:sequence ..= l:key =~# '^C-' ? nr2char(char2nr(toupper(strpart(l:key, 2))) - 64) : l:key
    endfor
    call feedkeys((a:insert ? '' : 'a') .. l:sequence, 'in')
    return 1
  endfor
  throw 'PlanetVim: unknown completion source'
endfunc

func! planet#completion#Engine(engine, save = 1) abort
  if index(['asyncomplete', 'native', 'off'], a:engine) < 0 | throw 'PlanetVim: unknown completion engine' | endif
  if a:engine ==# 'native' && !exists('+autocomplete')
    return planet#prompt#Unavailable('native automatic completion', "'autocomplete'")
  endif
  let g:PV_completion_engine = a:engine
  let g:asyncomplete_auto_popup = a:engine ==# 'asyncomplete'
  let g:asyncomplete_auto_completeopt = 0
  if exists('+autocomplete') | let &autocomplete = a:engine ==# 'native' | endif
  for l:buffer in getbufinfo()
    call setbufvar(l:buffer.bufnr, 'asyncomplete_enable', a:engine ==# 'asyncomplete')
  endfor
  if a:engine ==# 'asyncomplete' && get(g:, 'asyncomplete_loaded', 0) | call asyncomplete#enable_for_buffer() | endif
  if a:save | call planet#config#SavePreference('PV_completion_engine', a:engine) | endif
  return 1
endfunc

func! planet#completion#Buffer() abort
  if exists('g:PV_completion_engine')
    let b:asyncomplete_enable = g:PV_completion_engine ==# 'asyncomplete'
    if b:asyncomplete_enable && get(g:, 'asyncomplete_loaded', 0) | call asyncomplete#enable_for_buffer() | endif
  endif
endfunc

func! planet#completion#Preset(name) abort
  let l:options = split(&completeopt, ',')
  if a:name ==# 'fuzzy'
    call filter(l:options, {_, v -> index(['preinsert', 'nearest'], v) < 0})
    if index(l:options, 'fuzzy') < 0 | call add(l:options, 'fuzzy') | else | call remove(l:options, index(l:options, 'fuzzy')) | endif
  elseif a:name ==# 'preinsert'
    call filter(l:options, {_, v -> index(['fuzzy', 'noinsert', 'noselect', 'longest', 'preinsert'], v) < 0})
    call extend(l:options, ['menuone', 'preinsert'])
  elseif a:name ==# 'nearest'
    call filter(l:options, {_, v -> index(['fuzzy', 'nosort', 'nearest'], v) < 0})
    call add(l:options, 'nearest')
  elseif a:name ==# 'standard'
    let l:options = ['menuone', 'noinsert', 'noselect']
  elseif index(['popup', 'nosort'], a:name) >= 0
    return planet#preferences#Flag('completeopt', a:name)
  else
    throw 'PlanetVim: unknown completion preset'
  endif
  return planet#preferences#Set('completeopt', join(uniq(sort(l:options)), ','))
endfunc

func! planet#completion#Search(start = 1) abort
  if !has('patch-9.1.1490')
    return planet#prompt#Unavailable('search-pattern completion (Vim 9.1.1490)', "'wildchar'")
  endif
  " The same native key completes Ex commands and search patterns. No mapping
  " is installed, so literal Tab remains available with CTRL-V Tab.
  if &wildchar == 0
    echomsg 'PlanetVim: set wildchar to a completion key first (:help wildchar)'
    return 0
  endif
  echomsg 'PlanetVim: press ' .. keytrans(nr2char(&wildchar)) .. ' to complete; CTRL-N/CTRL-P choose; CTRL-E cancels; CTRL-V inserts a literal key'
  if a:start | call feedkeys('/', 'n') | endif
  return 1
endfunc

func! planet#completion#Menus(group) abort
  if a:group ==# 'basic'
    an 130.340 🔎&/.Complete\ Search\ Pattern <Cmd>call planet#completion#Search()<CR>
    for [l:label, l:source, l:keys] in s:sources
      let l:path = '📝&e.Complete.' .. escape(l:label, ' .') .. '<Tab>' .. substitute(l:keys, ' ', ',', 'g')
      execute 'anoremenu 120.305 ' .. l:path .. " <Cmd>call planet#completion#Start('" .. l:source .. "')<CR>"
      execute 'inoremenu 120.305 ' .. l:path .. " <Cmd>call planet#completion#Start('" .. l:source .. "', 1)<CR>"
    endfor
  elseif a:group ==# 'settings'
    for l:engine in ['asyncomplete', 'native', 'off']
      execute 'anoremenu 900.50 ⚙️&\\.Completion.Automatic.' .. l:engine .. " <Cmd>call planet#completion#Engine('" .. l:engine .. "')<CR>"
    endfor
    for [l:label, l:preset] in [['Standard suggestions', 'standard'], ['Toggle fuzzy matching', 'fuzzy'], ['Toggle documentation popup', 'popup'], ['Nearest buffer matches', 'nearest'], ['Toggle original fuzzy order', 'nosort'], ['Preinsert preview', 'preinsert']]
      execute 'anoremenu 900.50 ⚙️&\\.Completion.' .. escape(l:label, ' ') .. " <Cmd>call planet#completion#Preset('" .. l:preset .. "')<CR>"
    endfor
    an 900.51 ⚙️&\\.Command-line\ Completion.Toggle\ Popup <Cmd>call planet#preferences#Flag('wildoptions', 'pum')<CR>
    an 900.51 ⚙️&\\.Command-line\ Completion.Toggle\ Fuzzy <Cmd>call planet#preferences#Flag('wildoptions', 'fuzzy')<CR>
    an 900.51 ⚙️&\\.Command-line\ Completion.Search\ Pattern\ Completion\ Help <Cmd>call planet#completion#Search(0)<CR>
    an 900.51 ⚙️&\\.Command-line\ Completion.Help <Cmd>help cmdline-completion<CR>
  endif
endfunc
