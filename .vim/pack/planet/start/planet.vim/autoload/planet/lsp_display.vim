scriptversion 4
let s:features = {'hints': 'PV_inlay_hints', 'inline': 'PV_inline_diagnostics', 'signs': 'lsp_diagnostics_signs_enabled', 'underlines': 'lsp_diagnostics_highlights_enabled'}
let s:hint_generation = 0
let s:hint_types = ['PlanetLspInlayType', 'PlanetLspInlayParameter']
let s:types = ['PlanetLspErrorText', 'PlanetLspWarningText', 'PlanetLspInfoText', 'PlanetLspHintText']

func! planet#lsp_display#Valid(values) abort
  if type(a:values) != v:t_dict | return 0 | endif
  for [l:key, l:value] in items(a:values)
    if !has_key(s:features, l:key) || type(l:value) != v:t_number || index([0, 1], l:value) < 0 | return 0 | endif
  endfor
  return 1
endfunc

func! planet#lsp_display#Restore() abort
  for [l:key, l:value] in items(get(g:, 'PV_lsp_display', {}))
    let g:[s:features[l:key]] = l:value
  endfor
endfunc

func! s:Clear(types) abort
  for l:buffer in getbufinfo(#{bufloaded: 1})
    for l:type in a:types
      if !empty(prop_type_get(l:type))
        call prop_remove(#{type: l:type, bufnr: l:buffer.bufnr, all: v:true}, 1, l:buffer.linecount)
      endif
    endfor
  endfor
endfunc

func! planet#lsp_display#Inline() abort
  call s:Clear(s:types)
  if !get(g:, 'PV_inline_diagnostics', 0) || !get(g:, 'lsp_diagnostics_enabled', 0) | return | endif
  for l:index in range(4)
    if empty(prop_type_get(s:types[l:index]))
      call prop_type_add(s:types[l:index], #{highlight: ['ErrorMsg', 'WarningMsg', 'NonText', 'NonText'][l:index]})
    endif
  endfor
  for l:buffer in getbufinfo(#{bufloaded: 1})
    if !lsp#internal#diagnostics#state#_is_enabled_for_buffer(l:buffer.bufnr) | continue | endif
    let l:uri = lsp#utils#get_buffer_uri(l:buffer.bufnr)
    let l:lines = {}
    for l:response in values(lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(l:uri))
      for l:item in get(get(l:response, 'params', {}), 'diagnostics', [])
        let l:line = l:item.range.start.line + 1
        if l:line < 1 || l:line > l:buffer.linecount | continue | endif
        if !has_key(l:lines, l:line) | let l:lines[l:line] = #{messages: [], severity: 4} | endif
        if len(l:lines[l:line].messages) < 3
          call add(l:lines[l:line].messages, strcharpart(substitute(l:item.message, '[\r\n]', ' ', 'g'), 0, 300))
        endif
        let l:lines[l:line].severity = min([l:lines[l:line].severity, max([1, get(l:item, 'severity', 1)])])
      endfor
    endfor
    for [l:line, l:item] in items(l:lines)
      call prop_add(str2nr(l:line), 0, #{bufnr: l:buffer.bufnr, type: s:types[l:item.severity - 1], text: '● ' .. join(l:item.messages, '; '), text_align: 'after', text_padding_left: 1})
    endfor
  endfor
endfunc

func! planet#lsp_display#Set(feature, enabled) abort
  if !has_key(s:features, a:feature) || index([0, 1], a:enabled) < 0 | throw 'PlanetVim: invalid LSP display setting' | endif
  let g:[s:features[a:feature]] = a:enabled
  if a:feature ==# 'hints'
    let g:lsp_inlay_hints_enabled = 0
    call lsp#internal#inlay_hints#_disable()
    let s:hint_generation += 1
    call s:Clear(['vim_lsp_inlay_hint_type', 'vim_lsp_inlay_hint_parameter'] + s:hint_types)
    if a:enabled
      let l:servers = filter(lsp#get_allowed_servers(), {_, server -> lsp#capabilities#has_inlay_hint_provider(server)})
      if empty(l:servers)
        echomsg 'PlanetVim: inlay hints enabled; no attached server advertises inlayHintProvider for this buffer. See PlanetLspStatus.'
      else
        call planet#lsp_display#Hints()
      endif
    endif
  elseif a:feature ==# 'inline'
    call planet#lsp_display#Inline()
  else
    let l:kind = a:feature ==# 'signs' ? 'signs' : 'highlights'
    call call('lsp#internal#diagnostics#' .. l:kind .. '#_' .. (a:enabled ? 'enable' : 'disable'), [])
    if a:enabled | call lsp#internal#diagnostics#state#_force_notify_buffer(bufnr()) | endif
  endif
  let g:PV_lsp_display = get(g:, 'PV_lsp_display', {})
  let g:PV_lsp_display[a:feature] = a:enabled
  call planet#config#SavePreference('PV_lsp_display', g:PV_lsp_display)
  return 1
endfunc

" LSP defaults to UTF-16 offsets; Vim text properties require byte columns.
" The pinned client's hint renderer treats offsets as bytes. Keep the client
" transport/capabilities, but adapt rendering here without editing vendor code.
func! s:ByteColumn(text, character, encoding) abort
  if a:encoding ==# 'utf-8' | return min([strlen(a:text), a:character]) + 1 | endif
  let l:units = 0
  let l:bytes = 0
  for l:char in split(a:text, '\zs')
    let l:width = a:encoding ==# 'utf-32' ? 1 : char2nr(l:char) > 0xffff ? 2 : 1
    if l:units + l:width > a:character | break | endif
    let l:units += l:width
    let l:bytes += strlen(l:char)
  endfor
  return l:bytes + 1
endfunc

func! s:HintResult(context, data) abort
  if !get(g:, 'PV_inlay_hints', 0) || a:context.generation != s:hint_generation
        \ || !bufloaded(a:context.buffer) || getbufvar(a:context.buffer, 'changedtick') != a:context.tick
    return
  endif
  let l:response = get(a:data, 'response', {})
  if has_key(l:response, 'error') || type(get(l:response, 'result', v:null)) != v:t_list | return | endif
  for l:type in s:hint_types
    if empty(prop_type_get(l:type)) | call prop_type_add(l:type, #{highlight: 'NonText'}) | endif
    call prop_remove(#{type: l:type, bufnr: a:context.buffer, all: v:true})
  endfor
  for l:hint in l:response.result
    let l:line = get(l:hint.position, 'line', -1) + 1
    let l:lines = getbufline(a:context.buffer, l:line)
    if empty(l:lines) | continue | endif
    let l:label = type(l:hint.label) == v:t_list ? join(map(copy(l:hint.label), {_, part -> part.value}), '') : l:hint.label
    let l:label = (get(l:hint, 'paddingLeft', 0) ? ' ' : '') .. substitute(l:label, '[\r\n]', ' ', 'g') .. (get(l:hint, 'paddingRight', 0) ? ' ' : '')
    let l:column = s:ByteColumn(l:lines[0], max([0, get(l:hint.position, 'character', 0)]), a:context.encoding)
    call prop_add(l:line, l:column, #{bufnr: a:context.buffer, type: s:hint_types[get(l:hint, 'kind', 1) == 2 ? 1 : 0], text: l:label})
  endfor
endfunc

func! planet#lsp_display#Invalidate() abort
  let s:hint_generation += 1
  for l:type in s:hint_types
    if !empty(prop_type_get(l:type)) | call prop_remove(#{type: l:type, bufnr: bufnr(), all: v:true}) | endif
  endfor
endfunc

func! planet#lsp_display#Hints() abort
  if !get(g:, 'PV_inlay_hints', 0) || !empty(&buftype) | return | endif
  let l:servers = filter(lsp#get_allowed_servers(), {_, server -> lsp#capabilities#has_inlay_hint_provider(server)})
  if empty(l:servers) | return | endif
  let s:hint_generation += 1
  let l:server = l:servers[0]
  let l:context = #{buffer: bufnr(), tick: b:changedtick, generation: s:hint_generation, encoding: get(lsp#get_server_capabilities(l:server), 'positionEncoding', 'utf-16')}
  let l:end = l:context.encoding ==# 'utf-8' ? strlen(getline('$')) : 0
  if l:context.encoding !=# 'utf-8'
    for l:char in split(getline('$'), '\zs')
      let l:end += l:context.encoding ==# 'utf-32' ? 1 : char2nr(l:char) > 0xffff ? 2 : 1
    endfor
  endif
  call lsp#send_request(l:server, #{method: 'textDocument/inlayHint', params: #{textDocument: lsp#get_text_document_identifier(), range: #{start: #{line: 0, character: 0}, end: #{line: line('$') - 1, character: l:end}}}, on_notification: function('s:HintResult', [l:context])})
endfunc

func! planet#lsp_display#Status() abort
  for [l:key, l:variable] in items(s:features)
    echomsg 'PlanetVim LSP ' .. l:key .. ': ' .. (get(g:, l:variable, 0) ? 'enabled' : 'disabled')
  endfor
  call planet#intelligence#ShowStatus()
endfunc

func! planet#lsp_display#Menus() abort
  for [l:label, l:key] in [['Inlay Hints', 'hints'], ['Inline Diagnostics', 'inline'], ['Signs', 'signs'], ['Underlines', 'underlines']]
    for [l:verb, l:enabled] in [['Enable', 1], ['Disable', 0]]
      execute 'anoremenu 400.55 ❇️&[.Display.' .. escape(l:label, ' ') .. '.' .. l:verb .. " <Cmd>call planet#lsp_display#Set('" .. l:key .. "', " .. l:enabled .. ')<CR>'
    endfor
  endfor
  an 400.55 ❇️&[.Display.Status <Cmd>call planet#lsp_display#Status()<CR>
  an 400.55 ❇️&[.Display.Help <Cmd>help lsp<CR>
endfunc
