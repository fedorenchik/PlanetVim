vim9script
def LocalColumn(text: any, character: any, encoding: any): any
  var units: any = 0
  var byte: any = 0
  for char in split(text, '\zs')
    if units >= character
      break
    endif
    units += encoding ==# 'utf-8' ? strlen(char)  :  encoding ==# 'utf-32' ? 1 :  char2nr(char) > 0xffff ? 2 :  1
    byte += strlen(char)
  endfor
  if units != character
    throw 'semantic token position is outside the source character boundaries'
  endif
  return byte + 1
enddef

export def Decode(buffer: any, legend: any, data: any, encoding: any = 'utf-16'): any
  var delta: any
  var start: any
  var length: any
  var type: any
  var bits: any
  var text: any
  var first: any
  var last: any
  var labels: any
  var mask: any
  if type(data) != v:t_list || len(data) % 5 != 0 || !empty(filter(copy(data), (_, lambda_value) => type(lambda_value) != v:t_number || lambda_value < 0))
    throw 'invalid semantic token response'
  endif
  var types: any = get(legend, 'tokenTypes', [])
  var modifiers: any = get(legend, 'tokenModifiers', [])
  var items: any = []
  var line: any = 0
  var character: any = 0
  var index: any = 0
  while index < len(data)
    [delta, start, length, type, bits] = data[index :  index + 4]
    line += delta
    character = delta != 0 ? start : character + start
    text = get(getbufline(buffer, line + 1), 0, '')
    if type >= len(types) || length == 0
      throw 'invalid semantic token type or length'
    endif
    first = LocalColumn(text, character, encoding)
    last = LocalColumn(text, character + length, encoding)
    labels = []
    mask = 1
    for modifier in modifiers
      if and(bits, mask) != 0
        add(labels, modifier)
      endif
      mask *= 2
    endfor
    add(items, {bufnr: buffer, lnum: line + 1, col: first, end_col: last - 1, text: types[type] .. (empty(labels) ? '' : ' [' .. join(labels,
         ', ') .. ']') .. ': ' .. strpart(text, first - 1, last - first)})
    index += 5
  endwhile
  return items
enddef

def LocalFinish(context: any, arg_response: any): any
  var response: any
  var tokens: any
  var data: any
  if context.done
    return 0
  endif
  context.done = 1
  timer_stop(context.timer)
  var result: any = {status: 'failed', items: [], server: context.server}
  try
    if !bufexists(context.buffer) || getbufvar(context.buffer, 'changedtick') != context.tick
      throw 'source changed while semantic scopes were requested; run the action again'
    endif
    response = get(arg_response, 'response', {})
    if has_key(response, 'error')
      throw get(response.error, 'message', 'semantic token request failed')
    endif
    tokens = get(response, 'result', v:null)
    data = tokens == null ? [] : get(tokens, 'data', [])
    result.items = planet#semantic#Decode(context.buffer, context.legend, data, context.encoding)
    result.status = 'success'
    if win_id2win(context.window) > 0
      setloclist(win_id2win(context.window), [], ' ', {title: 'Semantic scopes: ' .. context.server, items: result.items})
      if win_getid() == context.window && !empty(result.items)
        lopen
      endif
    endif
    if empty(result.items)
      echom 'PlanetVim: the server returned no semantic scopes for this document.'
    endif
  catch
    result.error = v:exception
    echohl WarningMsg
    echom 'PlanetVim semantic scopes: ' .. v:exception
    echohl None
  endtry
  if bufexists(context.buffer)
    setbufvar(context.buffer, 'PV_semantic_result', result)
  endif
  return 0
enddef

def LocalTimeout(context: any, timer: any): any
  if has_key(context, 'Dispose')
    context.Dispose()
  endif
  LocalFinish(context, {response: {error: {message: 'semantic token request timed out'}}})
  return 0
enddef

export def Show(): any
  var capabilities: any
  var provider: any
  var full: any
  var context: any
  var server: any
  if empty(expand('%:p')) || &buftype !=# ''
    echom 'PlanetVim: semantic scopes require a named source buffer.'
    return 0
  endif
  for item_server in lsp#get_allowed_servers()
    server = item_server
    if lsp#get_server_status(server) !=# 'running'
      continue
    endif
    capabilities = lsp#get_server_capabilities(server)
    provider = get(capabilities, 'semanticTokensProvider', {})
    if type(provider) != v:t_dict || !has_key(provider, 'legend')
      continue
    endif
    full = get(provider, 'full', v:false)
    if type(full) != v:t_dict && !full
      continue
    endif
    context = {buffer: bufnr(), window: win_getid(), tick: b:changedtick, done: 0, server: server, legend: provider.legend, encoding: get(capabilities, 'positionEncoding', 'utf-16')}
    b:PV_semantic_result = {status: 'running', items: [], server: server}
    context.timer = timer_start(5000, function(LocalTimeout, [context]))
    context.Dispose = lsp#callbag#pipe(  lsp#request(server, {method: 'textDocument/semanticTokens/full',  params: {textDocument: lsp#get_text_document_identifier()}}),  lsp#callbag#subscribe({next: function(LocalFinish, [context]), error: function(LocalFinish, [context])}))
    return 1
  endfor
  echom 'PlanetVim: no running server supports full semantic tokens. Configure/start a capable server such as clangd; use :PlanetLspStatus.'
  return 0
enddef
