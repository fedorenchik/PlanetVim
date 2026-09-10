scriptversion 4

func! planet#diff#Option(key, value) abort
  let l:values = filter(split(&diffopt, ','), {_, v -> v !=# a:key && stridx(v, a:key .. ':') != 0})
  if a:value isnot v:null
    call add(l:values, a:key .. (empty(a:value) ? '' : ':' .. a:value))
  endif
  let l:old = &diffopt
  try
    let &diffopt = join(l:values, ',')
  catch /^Vim\%((\a\+)\)\=:E/
    let &diffopt = l:old
    return planet#prompt#Unavailable('diff ' .. a:key .. ' option', "'diffopt'")
  endtry
  return 1
endfunc

func! planet#diff#Context(...) abort
  let l:value = a:0 ? a:1 : planet#prompt#Ask('Diff context lines: ', matchstr(&diffopt, 'context:\zs\d\+'))
  if l:value is v:null || empty(l:value) | return 0 | endif
  if l:value !~# '^\d\+$'
    echom 'PlanetVim: enter a nonnegative number of context lines.'
    return 0
  endif
  return planet#diff#Option('context', l:value)
endfunc

func! planet#diff#Peers() abort
  let l:buffers = []
  for l:win in getwininfo()
    if l:win.tabnr == tabpagenr() && l:win.bufnr != bufnr() && getwinvar(l:win.winid, '&diff') && index(l:buffers, l:win.bufnr) < 0
      call add(l:buffers, l:win.bufnr)
    endif
  endfor
  return l:buffers
endfunc

func! planet#diff#Transfer(operation, buffer = v:null, first = 0, last = 0) abort
  if index(['get', 'put'], a:operation) < 0 | throw 'PlanetVim: invalid diff transfer' | endif
  let l:peers = planet#diff#Peers()
  if !&diff || empty(l:peers)
    echomsg 'PlanetVim: open another diff buffer in this tab first'
    return 0
  endif
  let l:buffer = a:buffer
  if l:buffer is v:null
    let l:index = len(l:peers) == 1 ? 0 : planet#prompt#Choose(a:operation ==# 'get' ? 'Get changes from:' : 'Put changes into:', map(copy(l:peers), {_, n -> '[' .. n .. '] ' .. (empty(bufname(n)) ? '[No Name]' : bufname(n))}))
    if l:index < 0 | return 0 | endif
    let l:buffer = l:peers[l:index]
  endif
  if index(l:peers, l:buffer) < 0 | echomsg 'PlanetVim: select a peer in this diff tab' | return 0 | endif
  let l:range = a:first > 0 ? min([a:first, a:last]) .. ',' .. max([a:first, a:last]) : ''
  if mode() =~# '^[vVsS]' || index(["\<C-v>", "\<C-s>"], mode()) >= 0 | execute "normal! \<Esc>" | endif
  execute l:range .. 'diff' .. a:operation .. ' ' .. l:buffer
  return 1
endfunc

func! planet#diff#Whitespace(policy) abort
  let l:policies = ['exact', 'iwhite', 'iwhiteall', 'iwhiteeol']
  if index(l:policies, a:policy) < 0 | throw 'PlanetVim: unknown whitespace policy' | endif
  let l:options = filter(split(&diffopt, ','), {_, v -> index(l:policies, v) < 0})
  if a:policy !=# 'exact' | call add(l:options, a:policy) | endif
  let &diffopt = join(l:options, ',')
  return 1
endfunc

func! planet#diff#Anchors(...) abort
  if !exists('+diffanchors') | return planet#prompt#Unavailable('diff anchors', 'diff-anchors') | endif
  let l:value = a:0 ? a:1 : planet#prompt#Ask('Anchor lines in this buffer (comma separated; empty clears). Set the same number in each peer: ', &l:diffanchors)
  if l:value is v:null | return 0 | endif
  if !empty(l:value) && (l:value !~# '^\d\+\%(,\d\+\)*$' || len(split(l:value, ',')) > 20 || min(map(split(l:value, ','), {_, v -> str2nr(v)})) < 1 || max(map(split(l:value, ','), {_, v -> str2nr(v)})) > line('$') + 1)
    echomsg 'PlanetVim: enter up to 20 valid line numbers'
    return 0
  endif
  let &l:diffanchors = l:value
  call planet#diff#Option('anchor', '')
  diffupdate
  return 1
endfunc

func! planet#diff#Menus() abort
  PlanetMenu an 710.41 ⛏️&;.Stop\ This\ Window <Cmd>diffoff<CR>
  PlanetMenu an 710.41 ⛏️&;.Stop\ This\ Tab <Cmd>diffoff!<CR>
  PlanetMenu an 710.41 ⛏️&;.Refresh <Cmd>diffupdate<CR>
  PlanetMenu an 710.40 ⛏️&;.Get\ Diff<Tab>:diffget <Cmd>call planet#diff#Transfer('get')<CR>
  PlanetMenu an 710.40 ⛏️&;.Put\ Diff<Tab>:diffput <Cmd>call planet#diff#Transfer('put')<CR>
  PlanetMenu vnoremenu 710.40 ⛏️&;.Get\ Diff<Tab>:diffget <Cmd>call planet#diff#Transfer('get', v:null, line('v'), line('.'))<CR>
  PlanetMenu vnoremenu 710.40 ⛏️&;.Put\ Diff<Tab>:diffput <Cmd>call planet#diff#Transfer('put', v:null, line('v'), line('.'))<CR>
  for [l:label, l:policy] in [['Compare all whitespace', 'exact'], ['Ignore whitespace amount', 'iwhite'], ['Ignore all whitespace', 'iwhiteall'], ['Ignore trailing whitespace', 'iwhiteeol']]
    execute 'PlanetMenu anoremenu 710.42 ⛏️&;.Whitespace.' .. escape(l:label, ' ') .. " <Cmd>call planet#diff#Whitespace('" .. l:policy .. "')<CR>"
  endfor
  for l:algorithm in ['myers', 'minimal', 'patience', 'histogram']
    execute 'PlanetMenu anoremenu 710.42 ⛏️&;.Algorithm.' .. l:algorithm .. " <Cmd>call planet#diff#Option('algorithm', '" .. l:algorithm .. "')<CR>"
  endfor
  for l:inline in ['char', 'word', 'simple', 'none']
    execute 'PlanetMenu anoremenu 710.42 ⛏️&;.Inline\ Highlighting.' .. l:inline .. " <Cmd>call planet#diff#Option('inline', '" .. l:inline .. "')<CR>"
  endfor
  PlanetMenu an 710.42 ⛏️&;.Align\ Similar\ Lines <Cmd>call planet#diff#Option('linematch', '60')<CR>
  PlanetMenu an 710.42 ⛏️&;.Disable\ Similar-line\ Alignment <Cmd>call planet#diff#Option('linematch', v:null)<CR>
  PlanetMenu an 710.42 ⛏️&;.Set\ Buffer\ Anchors <Cmd>call planet#diff#Anchors()<CR>
  PlanetMenu an 710.42 ⛏️&;.Disable\ Anchors <Cmd>call planet#diff#Option('anchor', v:null)<CR>
  PlanetMenu an 710.42 ⛏️&;.Current\ Diff\ Options <Cmd>set diffopt? diff?<CR>
  PlanetMenu an 710.42 ⛏️&;.Help <Cmd>help diff<CR>
endfunc
