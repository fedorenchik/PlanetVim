vim9script
var script_features = {'hints': 'PV_inlay_hints', 'inline': 'PV_inline_diagnostics', 'signs': 'lsp_diagnostics_signs_enabled',
     'underlines': 'lsp_diagnostics_highlights_enabled'}
var script_hint_generation = 0
var script_hint_types = ['PlanetLspInlayType', 'PlanetLspInlayParameter']
var script_types = ['PlanetLspErrorText', 'PlanetLspWarningText', 'PlanetLspInfoText', 'PlanetLspHintText']

export def Valid(values: any): any
  if type(values) != v:t_dict
    return 0
  endif
  for [key, value] in items(values)
    if !has_key(script_features, key) || type(value) != v:t_number || index([0, 1], value) < 0
      return 0
    endif
  endfor
  return 1
enddef

export def Restore(): any
  for [key, value] in items(get(g:, 'PV_lsp_display', {}))
    g:[script_features[key]] = value
  endfor
  return 0
enddef

def LocalClear(types: any): any
  for buffer in getbufinfo({bufloaded: 1})
    for type in types
      if !empty(prop_type_get(type))
        prop_remove({type: type, bufnr: buffer.bufnr, all: v:true}, 1, buffer.linecount)
      endif
    endfor
  endfor
  return 0
enddef

export def Inline(): any
  var uri: any
  var lines: any
  var line: any
  var item: any
  LocalClear(script_types)
  if !get(g:, 'PV_inline_diagnostics', 0) || !get(g:, 'lsp_diagnostics_enabled', 0)
    return 0
  endif
  for index in range(4)
    if empty(prop_type_get(script_types[index]))
      prop_type_add(script_types[index], {highlight: ['ErrorMsg', 'WarningMsg', 'NonText', 'NonText'][index]})
    endif
  endfor
  for buffer in getbufinfo({bufloaded: 1})
    if !lsp#internal#diagnostics#state#_is_enabled_for_buffer(buffer.bufnr)
      continue
    endif
    uri = lsp#utils#get_buffer_uri(buffer.bufnr)
    lines = {}
    for response in values(lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri))
      for item_item in get(get(response, 'params', {}), 'diagnostics', [])
        item = item_item
        line = item.range.start.line + 1
        if line < 1 || line > buffer.linecount
          continue
        endif
        if !has_key(lines, line)
          lines[line] = {messages:  [], severity:  4}
        endif
        if len(lines[line].messages) < 3
          add(lines[line].messages, strcharpart(substitute(item.message, '[\r\n]', ' ', 'g'), 0, 300))
        endif
        lines[line].severity = min([lines[line].severity, max([1, get(item, 'severity', 1)])])
      endfor
    endfor
    for [item_line, item_item] in items(lines)
      item = item_item
      line = item_line
      prop_add(str2nr(line), 0, {bufnr: buffer.bufnr, type: script_types[item.severity - 1], text: '● ' .. join(item.messages,
           '; '), text_align: 'after', text_padding_left: 1})
    endfor
  endfor
  return 0
enddef

export def Set(feature: any, enabled: any): any
  var servers: any
  var kind: any
  if !has_key(script_features, feature) || index([0, 1], enabled) < 0
    throw 'PlanetVim: invalid LSP display setting'
  endif
  g:[script_features[feature]] = enabled
  if feature ==# 'hints'
    g:lsp_inlay_hints_enabled = 0
    lsp#internal#inlay_hints#_disable()
    script_hint_generation += 1
    LocalClear(['vim_lsp_inlay_hint_type', 'vim_lsp_inlay_hint_parameter'] + script_hint_types)
    if enabled
      servers = filter(lsp#get_allowed_servers(), (_, lambda_server) => lsp#capabilities#has_inlay_hint_provider(lambda_server))
      if empty(servers)
        echomsg 'PlanetVim: inlay hints enabled; no attached server advertises inlayHintProvider for this buffer. See PlanetLspStatus.'
      else
        planet#lsp_display#Hints()
      endif
    endif
  elseif feature ==# 'inline'
    planet#lsp_display#Inline()
  else
    kind = feature ==# 'signs' ? 'signs' : 'highlights'
    call('lsp#internal#diagnostics#' .. kind .. '#_' .. (enabled ? 'enable' : 'disable'), [])
    if enabled
      lsp#internal#diagnostics#state#_force_notify_buffer(bufnr())
    endif
  endif
  g:PV_lsp_display = get(g:, 'PV_lsp_display', {})
  g:PV_lsp_display[feature] = enabled
  planet#config#SavePreference('PV_lsp_display', g:PV_lsp_display)
  return 1
enddef

# LSP defaults to UTF-16 offsets; Vim text properties require byte columns.
# The pinned client's hint renderer treats offsets as bytes. Keep the client
# transport/capabilities, but adapt rendering here without editing vendor code.
def LocalByteColumn(text: any, character: any, encoding: any): any
  var width: any
  if encoding ==# 'utf-8'
    return min([strlen(text), character]) + 1
  endif
  var units: any = 0
  var bytes: any = 0
  for char in split(text, '\zs')
    width = encoding ==# 'utf-32' ? 1 : char2nr(char) > 0xffff ? 2 : 1
    if units + width > character
      break
    endif
    units += width
    bytes += strlen(char)
  endfor
  return bytes + 1
enddef

def LocalHintResult(context: any, data: any): any
  var line: any
  var lines: any
  var label: any
  var column: any
  var type: any
  if !get(g:, 'PV_inlay_hints', 0) || context.generation != script_hint_generation || !bufloaded(context.buffer) || getbufvar(context.buffer,
       'changedtick') != context.tick
    return 0
  endif
  var response: any = get(data, 'response', {})
  if has_key(response, 'error') || type(get(response, 'result', v:null)) != v:t_list
    return 0
  endif
  for item_type in script_hint_types
    type = item_type
    if empty(prop_type_get(type))
      prop_type_add(type, {highlight: 'NonText'})
    endif
    prop_remove({type: type, bufnr: context.buffer, all: v:true})
  endfor
  for hint in response.result
    line = get(hint.position, 'line', -1) + 1
    lines = getbufline(context.buffer, line)
    if empty(lines)
      continue
    endif
    label = type(hint.label) == v:t_list ? join(map(copy(hint.label), (_, lambda_part) => lambda_part.value), '') : hint.label
    label = (get(hint, 'paddingLeft', 0) ? ' ' : '') .. substitute(label, '[\r\n]', ' ', 'g') .. (get(hint, 'paddingRight', 0) ? ' ' : '')
    column = LocalByteColumn(lines[0], max([0, get(hint.position, 'character', 0)]), context.encoding)
    prop_add(line, column, {bufnr: context.buffer, type: script_hint_types[get(hint, 'kind', 1) == 2 ? 1 : 0], text: label})
  endfor
  return 0
enddef

export def Invalidate(): any
  script_hint_generation += 1
  for type in script_hint_types
    if !empty(prop_type_get(type))
      prop_remove({type: type, bufnr: bufnr(), all: v:true})
    endif
  endfor
  return 0
enddef

export def Hints(): any
  if !get(g:, 'PV_inlay_hints', 0) || !empty(&buftype)
    return 0
  endif
  var servers: any = filter(lsp#get_allowed_servers(), (_, lambda_server) => lsp#capabilities#has_inlay_hint_provider(lambda_server))
  if empty(servers)
    return 0
  endif
  script_hint_generation += 1
  var server: any = servers[0]
  var context: any = {buffer: bufnr(), tick: b:changedtick, generation: script_hint_generation, encoding: get(lsp#get_server_capabilities(server),
       'positionEncoding', 'utf-16')}
  var end: any = context.encoding ==# 'utf-8' ? strlen(getline('$')) : 0
  if context.encoding !=# 'utf-8'
    for char in split(getline('$'), '\zs')
      end += context.encoding ==# 'utf-32' ? 1 :  char2nr(char) > 0xffff ? 2 :  1
    endfor
  endif
  lsp#send_request(server, {method:  'textDocument/inlayHint', params:  {textDocument:  lsp#get_text_document_identifier(), range:  {start:  {line:  0, character:  0}, end:  {line:  line('$') - 1, character:  end}}}, on_notification:  function(LocalHintResult, [context])})
  return 0
enddef

export def Status(): any
  for [key, variable] in items(script_features)
    echomsg 'PlanetVim LSP ' .. key .. ': ' .. (get(g:, variable, 0) ? 'enabled' :  'disabled')
  endfor
  planet#intelligence#ShowStatus()
  return 0
enddef

export def Menus(): any
  for [label, key] in [['Inlay Hints', 'hints'], ['Inline Diagnostics', 'inline'], ['Signs', 'signs'], ['Underlines', 'underlines']]
    for [verb, enabled] in [['Enable', 1], ['Disable', 0]]
      execute 'PlanetMenu anoremenu 400.55 ❇️&[.Display.' .. escape(label, ' ') .. '.' .. verb .. " <Cmd>call planet#lsp_display#Set('" .. key .. "', " .. enabled .. ')<CR>'
    endfor
  endfor
  PlanetMenu an 400.55 ❇️&[.Display.Status <Cmd>call planet#lsp_display#Status()<CR>
  PlanetMenu an 400.55 ❇️&[.Display.Help <Cmd>help lsp<CR>
  return 0
enddef
