vim9script
export def Option(key: any, value: any): any
  var values: any = filter(split(&diffopt, ','), (_, lambda_v) => lambda_v !=# key && stridx(lambda_v, key .. ':') != 0)
  if value != null
    add(values, key .. (empty(value) ? '' : ':' .. value))
  endif
  var old: any = &diffopt
  try
    &diffopt = join(values, ',')
  catch /^Vim\%((\a\+)\)\=:E/
    &diffopt = old
    return planet#prompt#Unavailable('diff ' .. key .. ' option', "'diffopt'")
  endtry
  return 1
enddef

export def Context(...args: list<any>): any
  var value: any = !empty(args) ? args[0] : planet#prompt#Ask('Diff context lines: ', matchstr(&diffopt, 'context:\zs\d\+'))
  if value == null || empty(value)
    return 0
  endif
  if value !~# '^\d\+$'
    echom 'PlanetVim: enter a nonnegative number of context lines.'
    return 0
  endif
  return planet#diff#Option('context', value)
enddef

export def Peers(): any
  var buffers: any = []
  for win in getwininfo()
    if win.tabnr == tabpagenr() && win.bufnr != bufnr() && getwinvar(win.winid, '&diff') && index(buffers, win.bufnr) < 0
      add(buffers, win.bufnr)
    endif
  endfor
  return buffers
enddef

export def Transfer(operation: any, arg_buffer: any = v:null, first: any = 0, last: any = 0): any
  var buffer: any
  var index: any
  if index(['get', 'put'], operation) < 0
    throw 'PlanetVim: invalid diff transfer'
  endif
  var peers: any = planet#diff#Peers()
  if !&diff || empty(peers)
    echomsg 'PlanetVim: open another diff buffer in this tab first'
    return 0
  endif
  buffer = arg_buffer
  if buffer == null
    index = len(peers) == 1 ? 0 : planet#prompt#Choose(operation ==# 'get' ? 'Get changes from:' : 'Put changes into:', map(copy(peers), (_, lambda_n) => '[' .. lambda_n .. '] ' .. (empty(bufname(lambda_n)) ? '[No Name]' : bufname(lambda_n))))
    if index < 0
      return 0
    endif
    buffer = peers[index]
  endif
  if index(peers, buffer) < 0
    echomsg 'PlanetVim: select a peer in this diff tab'
    return 0
  endif
  var range: any = first > 0 ? min([first, last]) .. ',' .. max([first, last]) : ''
  if mode() =~# '^[vVsS]' || index(["\<C-v>", "\<C-s>"], mode()) >= 0
    execute "normal! \<Esc>"
  endif
  execute ':' .. range .. 'diff' .. operation .. ' ' .. buffer
  return 1
enddef

export def Whitespace(policy: any): any
  var policies: any = ['exact', 'iwhite', 'iwhiteall', 'iwhiteeol']
  if index(policies, policy) < 0
    throw 'PlanetVim: unknown whitespace policy'
  endif
  var options: any = filter(split(&diffopt, ','), (_, lambda_v) => index(policies, lambda_v) < 0)
  if policy !=# 'exact'
    add(options, policy)
  endif
  &diffopt = join(options, ',')
  return 1
enddef

export def Anchors(...args: list<any>): any
  if !exists('+diffanchors')
    return planet#prompt#Unavailable('diff anchors', 'diff-anchors')
  endif
  var value: any = !empty(args) ? args[0] : planet#prompt#Ask('Anchor lines in this buffer (comma separated; empty clears). Set the same number in each peer: ',
       eval('&l:diffanchors'))
  if value == null
    return 0
  endif
  if !empty(value) && (value !~# '^\d\+\%(,\d\+\)*$' || len(split(value, ',')) > 20 || min(map(split(value,
       ','), (_, lambda_v) => str2nr(lambda_v))) < 1 || max(map(split(value, ','), (_, lambda_v) => str2nr(lambda_v))) > line('$') + 1)
    echomsg 'PlanetVim: enter up to 20 valid line numbers'
    return 0
  endif
  execute '&l:diffanchors = ' .. string(value)
  planet#diff#Option('anchor', '')
  diffupdate
  return 1
enddef

export def Menus(): any
  PlanetMenu an 710.41 ⛏️&;.Stop\ This\ Window <Cmd>diffoff<CR>
  PlanetMenu an 710.41 ⛏️&;.Stop\ This\ Tab <Cmd>diffoff!<CR>
  PlanetMenu an 710.41 ⛏️&;.Refresh <Cmd>diffupdate<CR>
  PlanetMenu an 710.40 ⛏️&;.Get\ Diff<Tab>:diffget <Cmd>call planet#diff#Transfer('get')<CR>
  PlanetMenu an 710.40 ⛏️&;.Put\ Diff<Tab>:diffput <Cmd>call planet#diff#Transfer('put')<CR>
  PlanetMenu vnoremenu 710.40 ⛏️&;.Get\ Diff<Tab>:diffget <Cmd>call planet#diff#Transfer('get', v:null, line('v'), line('.'))<CR>
  PlanetMenu vnoremenu 710.40 ⛏️&;.Put\ Diff<Tab>:diffput <Cmd>call planet#diff#Transfer('put', v:null, line('v'), line('.'))<CR>
  for [label, policy] in [['Compare all whitespace', 'exact'], ['Ignore whitespace amount', 'iwhite'], ['Ignore all whitespace', 'iwhiteall'], ['Ignore trailing whitespace', 'iwhiteeol']]
    execute 'PlanetMenu anoremenu 710.42 ⛏️&;.Whitespace.' .. escape(label, ' ') .. " <Cmd>call planet#diff#Whitespace('" .. policy .. "')<CR>"
  endfor
  for algorithm in ['myers', 'minimal', 'patience', 'histogram']
    execute 'PlanetMenu anoremenu 710.42 ⛏️&;.Algorithm.' .. algorithm .. " <Cmd>call planet#diff#Option('algorithm', '" .. algorithm .. "')<CR>"
  endfor
  for inline in ['char', 'word', 'simple', 'none']
    execute 'PlanetMenu anoremenu 710.42 ⛏️&;.Inline\ Highlighting.' .. inline .. " <Cmd>call planet#diff#Option('inline', '" .. inline .. "')<CR>"
  endfor
  PlanetMenu an 710.42 ⛏️&;.Align\ Similar\ Lines <Cmd>call planet#diff#Option('linematch', '60')<CR>
  PlanetMenu an 710.42 ⛏️&;.Disable\ Similar-line\ Alignment <Cmd>call planet#diff#Option('linematch', v:null)<CR>
  PlanetMenu an 710.42 ⛏️&;.Set\ Buffer\ Anchors <Cmd>call planet#diff#Anchors()<CR>
  PlanetMenu an 710.42 ⛏️&;.Disable\ Anchors <Cmd>call planet#diff#Option('anchor', v:null)<CR>
  PlanetMenu an 710.42 ⛏️&;.Current\ Diff\ Options <Cmd>set diffopt? diff?<CR>
  PlanetMenu an 710.42 ⛏️&;.Help <Cmd>help diff<CR>
  return 0
enddef
