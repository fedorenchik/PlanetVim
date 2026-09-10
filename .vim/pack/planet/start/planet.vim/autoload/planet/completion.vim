vim9script

var script_sources = [ ['Words', 'words', 'C-n'], ['Current buffer words', 'buffer', 'C-x C-n'], ['Whole lines',
     'lines', 'C-x C-l'], ['Filename', 'filename', 'C-x C-f'], ['Dictionary', 'dictionary', 'C-x C-k'],
     ['Thesaurus', 'thesaurus', 'C-x C-t'], ['Tags', 'tags', 'C-x C-]'], ['Included keywords', 'include',
     'C-x C-i'], ['Included definitions', 'define', 'C-x C-d'], ['Vim commands', 'commands', 'C-x C-v'],
     ['Omni (language server)', 'omni', 'C-x C-o'], ['User function', 'user', 'C-x C-u'], ['Spelling',
     'spell', 'C-x s'], ['Register contents', 'register', 'C-x C-r'], ['Accept', 'accept', 'C-y'], ['Cancel',
     'cancel', 'C-e']]

export def Start(arg_source: any, insert: any = 0): any
  var option: any
  var sequence: any
  var source: any
  for [label, item_source, keys] in script_sources
    source = item_source
    if arg_source !=# source
      continue
    endif
    if source ==# 'register' && !has('patch-9.1.1408')
      return planet#prompt#Unavailable('register completion (Vim 9.1.1408)', 'i_CTRL-X_CTRL-R')
    endif
    option = get({'dictionary': 'dictionary', 'thesaurus': 'thesaurus', 'omni': 'omnifunc', 'user': 'completefunc'}, source, '')
    if !empty(option) && empty(eval('&l:' .. option))
      echomsg 'PlanetVim: configure ' .. option .. ' for this buffer first (:help ' .. option .. ')'
      return 0
    endif
    if index(['accept', 'cancel'], source) >= 0 && !pumvisible()
      return 0
    endif
    sequence = ''
    for key in split(keys)
      sequence ..= key =~# '^C-' ? nr2char(char2nr(toupper(strpart(key, 2))) - 64) :  key
    endfor
    feedkeys((insert ? '' : 'a') .. sequence, 'in')
    return 1
  endfor
  throw 'PlanetVim: unknown completion source'
enddef

export def Engine(engine: any, save: any = 1): any
  if index(['asyncomplete', 'native', 'off'], engine) < 0
    throw 'PlanetVim: unknown completion engine'
  endif
  if engine ==# 'native' && !exists('+autocomplete')
    return planet#prompt#Unavailable('native automatic completion', "'autocomplete'")
  endif
  g:PV_completion_engine = engine
  g:asyncomplete_auto_popup = engine ==# 'asyncomplete' ? 1 : 0
  g:asyncomplete_auto_completeopt = 0
  if exists('+autocomplete')
    execute '&autocomplete = ' .. (engine ==# 'native' ? 1 : 0)
  endif
  for buffer in getbufinfo()
    setbufvar(buffer.bufnr, 'asyncomplete_enable', engine ==# 'asyncomplete' ? 1 : 0)
  endfor
  if engine ==# 'asyncomplete' && get(g:, 'asyncomplete_loaded', 0)
    asyncomplete#enable_for_buffer()
  endif
  if save
    planet#config#SavePreference('PV_completion_engine', engine)
  endif
  return 1
enddef

export def Buffer(): any
  if exists('g:PV_completion_engine')
    b:asyncomplete_enable = g:PV_completion_engine ==# 'asyncomplete' ? 1 : 0
    if b:asyncomplete_enable && get(g:, 'asyncomplete_loaded', 0)
      asyncomplete#enable_for_buffer()
    endif
  endif
  return 0
enddef

export def Preset(name: any): any
  var options: any = split(&completeopt, ',')
  if name ==# 'fuzzy'
    filter(options, (_, lambda_v) => index(['preinsert', 'nearest'], lambda_v) < 0)
    if index(options, 'fuzzy') < 0
      add(options, 'fuzzy')
    else
      remove(options, index(options, 'fuzzy'))
    endif
  elseif name ==# 'preinsert'
    filter(options, (_, lambda_v) => index(['fuzzy', 'noinsert', 'noselect', 'longest', 'preinsert'], lambda_v) < 0)
    extend(options, ['menuone', 'preinsert'])
  elseif name ==# 'nearest'
    filter(options, (_, lambda_v) => index(['fuzzy', 'nosort', 'nearest'], lambda_v) < 0)
    add(options, 'nearest')
  elseif name ==# 'standard'
    options = ['menuone', 'noinsert', 'noselect']
  elseif index(['popup', 'nosort'], name) >= 0
    return planet#preferences#Flag('completeopt', name)
  else
    throw 'PlanetVim: unknown completion preset'
  endif
  return planet#preferences#Set('completeopt', join(uniq(sort(options)), ','))
enddef

export def Search(start: any = 1): any
  if !has('patch-9.1.1490')
    return planet#prompt#Unavailable('search-pattern completion (Vim 9.1.1490)', "'wildchar'")
  endif
  # The same native key completes Ex commands and search patterns. No mapping
  # is installed, so literal Tab remains available with CTRL-V Tab.
  if &wildchar == 0
    echomsg 'PlanetVim: set wildchar to a completion key first (:help wildchar)'
    return 0
  endif
  echomsg 'PlanetVim: press ' .. keytrans(nr2char(&wildchar)) .. ' to complete; CTRL-N/CTRL-P choose; CTRL-E cancels; CTRL-V inserts a literal key'
  if start
    feedkeys('/', 'n')
  endif
  return 1
enddef

export def Menus(group: any): any
  var path: any
  var label: any
  if group ==# 'basic'
    PlanetMenu an 130.340 🔎&/.Complete\ Search\ Pattern <Cmd>call planet#completion#Search()<CR>
    for [item_label, source, keys] in script_sources
      label = item_label
      path = '📝&e.Complete.' .. escape(label, ' .') .. '<Tab>' .. substitute(keys, ' ', ',', 'g')
      execute 'PlanetMenu anoremenu 120.305 ' .. path .. " <Cmd>call planet#completion#Start('" .. source .. "')<CR>"
      execute 'PlanetMenu inoremenu 120.305 ' .. path .. " <Cmd>call planet#completion#Start('" .. source .. "', 1)<CR>"
    endfor
  elseif group ==# 'settings'
    for engine in ['asyncomplete', 'native', 'off']
      execute 'PlanetMenu anoremenu 900.50 ⚙️&\\.Completion.Automatic.' .. engine .. " <Cmd>call planet#completion#Engine('" .. engine .. "')<CR>"
    endfor
    for [item_label, preset] in [['Standard suggestions', 'standard'], ['Toggle fuzzy matching', 'fuzzy'], ['Toggle documentation popup', 'popup'], ['Nearest buffer matches', 'nearest'], ['Toggle original fuzzy order', 'nosort'], ['Preinsert preview', 'preinsert']]
      label = item_label
      execute 'PlanetMenu anoremenu 900.50 ⚙️&\\.Completion.' .. escape(label, ' ') .. " <Cmd>call planet#completion#Preset('" .. preset .. "')<CR>"
    endfor
    PlanetMenu an 900.51 ⚙️&\\.Command-line\ Completion.Toggle\ Popup <Cmd>call planet#preferences#Flag('wildoptions', 'pum')<CR>
    PlanetMenu an 900.51 ⚙️&\\.Command-line\ Completion.Toggle\ Fuzzy <Cmd>call planet#preferences#Flag('wildoptions', 'fuzzy')<CR>
    PlanetMenu an 900.51 ⚙️&\\.Command-line\ Completion.Search\ Pattern\ Completion\ Help <Cmd>call planet#completion#Search(0)<CR>
    PlanetMenu an 900.51 ⚙️&\\.Command-line\ Completion.Help <Cmd>help cmdline-completion<CR>
  endif
  return 0
enddef
