scriptversion 4

func! s:Column(text, character, encoding) abort
  let l:units = 0
  let l:byte = 0
  for l:char in split(a:text, '\zs')
    if l:units >= a:character | break | endif
    let l:units += a:encoding ==# 'utf-8' ? strlen(l:char)
          \ : a:encoding ==# 'utf-32' ? 1 : char2nr(l:char) > 0xffff ? 2 : 1
    let l:byte += strlen(l:char)
  endfor
  if l:units != a:character
    throw 'semantic token position is outside the source character boundaries'
  endif
  return l:byte + 1
endfunc

func! planet#semantic#Decode(buffer, legend, data, encoding = 'utf-16') abort
  if type(a:data) != v:t_list || len(a:data) % 5
        \ || !empty(filter(copy(a:data), {_, value -> type(value) != v:t_number || value < 0}))
    throw 'invalid semantic token response'
  endif
  let l:types = get(a:legend, 'tokenTypes', [])
  let l:modifiers = get(a:legend, 'tokenModifiers', [])
  let l:items = []
  let l:line = 0
  let l:character = 0
  let l:index = 0
  while l:index < len(a:data)
    let [l:delta, l:start, l:length, l:type, l:bits] = a:data[l:index : l:index + 4]
    let l:line += l:delta
    let l:character = l:delta ? l:start : l:character + l:start
    let l:text = get(getbufline(a:buffer, l:line + 1), 0, '')
    if l:type >= len(l:types) || l:length == 0
      throw 'invalid semantic token type or length'
    endif
    let l:first = s:Column(l:text, l:character, a:encoding)
    let l:last = s:Column(l:text, l:character + l:length, a:encoding)
    let l:labels = []
    let l:mask = 1
    for l:modifier in l:modifiers
      if and(l:bits, l:mask) | call add(l:labels, l:modifier) | endif
      let l:mask *= 2
    endfor
    call add(l:items, #{bufnr:a:buffer, lnum:l:line+1, col:l:first, end_col:l:last-1,
          \ text:l:types[l:type] .. (empty(l:labels) ? '' : ' [' .. join(l:labels, ', ') .. ']')
          \ .. ': ' .. strpart(l:text, l:first-1, l:last-l:first)})
    let l:index += 5
  endwhile
  return l:items
endfunc

func! s:Finish(context, response) abort
  if a:context.done | return | endif
  let a:context.done = 1
  call timer_stop(a:context.timer)
  let l:result = #{status:'failed', items:[], server:a:context.server}
  try
    if !bufexists(a:context.buffer) || getbufvar(a:context.buffer, 'changedtick') != a:context.tick
      throw 'source changed while semantic scopes were requested; run the action again'
    endif
    let l:response = get(a:response, 'response', {})
    if has_key(l:response, 'error')
      throw get(l:response.error, 'message', 'semantic token request failed')
    endif
    let l:tokens = get(l:response, 'result', v:null)
    let l:data = l:tokens is v:null ? [] : get(l:tokens, 'data', [])
    let l:result.items = planet#semantic#Decode(a:context.buffer, a:context.legend, l:data, a:context.encoding)
    let l:result.status = 'success'
    if win_id2win(a:context.window) > 0
      call setloclist(win_id2win(a:context.window), [], ' ', #{title:'Semantic scopes: ' .. a:context.server, items:l:result.items})
      if win_getid() == a:context.window && !empty(l:result.items)
        lopen
      endif
    endif
    if empty(l:result.items) | echom 'PlanetVim: the server returned no semantic scopes for this document.' | endif
  catch
    let l:result.error = v:exception
    echohl WarningMsg | echom 'PlanetVim semantic scopes: ' .. v:exception | echohl None
  endtry
  if bufexists(a:context.buffer)
    call setbufvar(a:context.buffer, 'PV_semantic_result', l:result)
  endif
endfunc

func! s:Timeout(context, timer) abort
  if has_key(a:context, 'Dispose') | call a:context.Dispose() | endif
  call s:Finish(a:context, #{response:#{error:#{message:'semantic token request timed out'}}})
endfunc

func! planet#semantic#Show() abort
  if empty(expand('%:p')) || &buftype !=# ''
    echom 'PlanetVim: semantic scopes require a named source buffer.'
    return 0
  endif
  for l:server in lsp#get_allowed_servers()
    if lsp#get_server_status(l:server) !=# 'running' | continue | endif
    let l:capabilities = lsp#get_server_capabilities(l:server)
    let l:provider = get(l:capabilities, 'semanticTokensProvider', {})
    if type(l:provider) != v:t_dict || !has_key(l:provider, 'legend') | continue | endif
    let l:full = get(l:provider, 'full', v:false)
    if type(l:full) != v:t_dict && !l:full | continue | endif
    let l:context = #{buffer:bufnr(), window:win_getid(), tick:b:changedtick, done:0,
          \ server:l:server, legend:l:provider.legend, encoding:get(l:capabilities, 'positionEncoding', 'utf-16')}
    let b:PV_semantic_result = #{status:'running', items:[], server:l:server}
    let l:context.timer = timer_start(5000, function('s:Timeout', [l:context]))
    let l:context.Dispose = lsp#callbag#pipe(
          \ lsp#request(l:server, #{method:'textDocument/semanticTokens/full',
          \ params:#{textDocument:lsp#get_text_document_identifier()}}),
          \ lsp#callbag#subscribe(#{next:function('s:Finish', [l:context]), error:function('s:Finish', [l:context])}))
    return 1
  endfor
  echom 'PlanetVim: no running server supports full semantic tokens. Configure/start a capable server such as clangd; use :PlanetLspStatus.'
  return 0
endfunc
