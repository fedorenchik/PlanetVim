scriptversion 4

let s:instance = getpid() .. '-' .. sha256(tempname())[:15]
let s:last_error = ''
let s:last_result = {}
let s:last_quickfix = 0

func! s:Error(message) abort
  let s:last_error = a:message
  echohl ErrorMsg
  echom 'PlanetVim: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#writing#LastError() abort
  return s:last_error
endfunc

func! s:Command(key, default, guidance) abort
  let l:argv = get(g:, a:key, a:default)
  if type(l:argv) != v:t_list || empty(l:argv)
        \ || !empty(filter(copy(l:argv), {_, value -> type(value) != v:t_string}))
    throw 'Configure g:' .. a:key .. ' as a nonempty executable argv List'
  endif
  if !executable(l:argv[0])
    throw a:guidance .. '; or configure g:' .. a:key
  endif
  return copy(l:argv)
endfunc

func! s:Source(types) abort
  if index(a:types, &filetype) < 0 || !empty(&buftype) || empty(expand('%'))
    throw 'Save a ' .. join(a:types, '/') .. ' document before running this action'
  endif
  if &modified
    confirm update
    if &modified
      throw 'Document was not saved; the writing action was cancelled'
    endif
  endif
  let l:path = expand('%:p')
  if !filereadable(l:path)
    throw 'Save the document before running this action'
  endif
  return l:path
endfunc

func! s:Cache(source) abort
  return planet#paths#Cache('writing/' .. s:instance .. '/' .. sha256(a:source)[:15])
endfunc

func! s:Open(path) abort
  if !filereadable(a:path)
    throw 'The generated document is missing: ' .. a:path
  endif
  let l:default = has('win32') ? ['rundll32.exe', 'url.dll,FileProtocolHandler'] : ['xdg-open']
  let l:argv = s:Command('PV_document_viewer_argv', l:default,
        \ 'Install a desktop HTML/PDF viewer and xdg-open (Linux), or configure a document viewer')
  let l:job = planet#term#RunGuiApp(l:argv + [a:path], fnamemodify(a:path, ':h'))
  if type(l:job) != v:t_job || job_status(l:job) ==# 'fail'
    throw 'Could not start the document viewer'
  endif
  return 1
endfunc

func! planet#writing#OpenOutput() abort
  let l:result = get(b:, 'PV_writing_result', s:last_result)
  if get(l:result, 'status', '') !=# 'success'
    return s:Error('Build or preview a document successfully before opening its output')
  endif
  try
    return s:Open(l:result.output)
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! s:Diagnostics(context, lines) abort
  let l:items = []
  for l:line in a:lines
    let l:match = matchlist(l:line, '^\(.\{-}\):\(\d\+\):\s*\(.*\)$')
    if !empty(l:match)
      let l:file = l:match[1]
      if l:file !~# '^\%(/\|[A-Za-z]:[/\\]\)'
        let l:file = fnamemodify(a:context.source, ':h') .. '/' .. l:file
      endif
      call add(l:items, {'filename': simplify(l:file), 'lnum': str2nr(l:match[2]),
            \ 'text': l:match[3], 'type': 'E'})
    endif
  endfor
  if empty(l:items)
    let l:nonempty = filter(copy(a:lines), {_, line -> !empty(trim(line))})
    call add(l:items, {'filename': a:context.source, 'lnum': 1, 'type': 'E',
          \ 'text': empty(l:nonempty) ? 'Writing command failed; inspect its Output buffer' : l:nonempty[-1]})
  endif
  call setqflist([], ' ', {'title': 'PlanetVim ' .. a:context.kind .. ': ' .. a:context.source, 'items': l:items})
  let s:last_quickfix = getqflist({'id': 0}).id
  return s:last_quickfix
endfunc

func! planet#writing#Errors() abort
  let l:nr = getqflist({'id': s:last_quickfix, 'nr': 0}).nr
  if s:last_quickfix == 0 || l:nr == 0
    return s:Error('There are no writing errors to show')
  endif
  let l:current = getqflist({'nr': 0}).nr
  if l:nr != l:current
    execute abs(l:nr - l:current) .. (l:nr < l:current ? 'colder' : 'cnewer')
  endif
  copen
  return 1
endfunc

func! s:Complete(context, result, output_buffer, timer) abort
  if bufexists(a:output_buffer) && term_getstatus(a:output_buffer) !~# 'finished'
    call timer_start(20, function('s:Complete', [a:context, a:result, a:output_buffer]))
    return
  endif
  let l:result = extend(deepcopy(a:result), {'output': a:context.output, 'source': a:context.source})
  if l:result.status ==# 'success' && !filereadable(a:context.output)
    let l:result.status = 'failed'
    let l:result.message = 'The command completed without creating ' .. a:context.output
  endif
  if l:result.status ==# 'failed'
    let l:lines = filereadable(a:context.log) ? readfile(a:context.log) : getbufline(a:output_buffer, 1, '$')
    if has_key(l:result, 'message')
      call add(l:lines, l:result.message)
    endif
    let l:result.quickfix = s:Diagnostics(a:context, l:lines)
  elseif l:result.status ==# 'success' && get(a:context, 'previous_errors', 0) > 0
    call setqflist([], 'r', {'id': a:context.previous_errors, 'items': []})
  endif
  if bufexists(a:context.buffer)
    call setbufvar(a:context.buffer, 'PV_writing_result', l:result)
  endif
  let s:last_result = l:result
  if l:result.status ==# 'success' && a:context.open
    try
      call s:Open(a:context.output)
    catch
      let l:result.viewer_error = v:exception
      call s:Error(v:exception)
    endtry
  endif
endfunc

func! s:Exited(context, result, output_buffer) abort
  call timer_start(0, function('s:Complete', [a:context, a:result, a:output_buffer]))
endfunc

func! s:Run(kind, source, argv, output, log) abort
  let l:context = {'kind': a:kind, 'source': a:source, 'output': a:output,
        \ 'log': a:log, 'buffer': bufnr(), 'open': get(g:, 'PV_writing_auto_open', 1),
        \ 'previous_errors': get(get(b:, 'PV_writing_result', {}), 'quickfix', 0)}
  let b:PV_writing_result = {'status': 'running', 'source': a:source, 'output': a:output}
  let l:output_buffer = planet#term#RunArgv(a:argv, v:false, v:false, v:false,
        \ fnamemodify(a:source, ':h'), function('s:Exited', [l:context]))
  if l:output_buffer == 0
    let b:PV_writing_result.status = 'failed'
    return s:Error('Could not start the writing command')
  endif
  let b:PV_writing_result.output_buffer = l:output_buffer
  return l:output_buffer
endfunc

func! planet#writing#MarkdownPreview() abort
  try
    let l:argv = s:Command('PV_pandoc_argv', ['pandoc'], 'Install Pandoc 2.19 or newer for Markdown preview')
    let l:source = s:Source(['markdown'])
    let l:output = s:Cache(l:source) .. '/preview.html'
    let l:argv += ['--standalone', '--from=gfm', '--to=html5', '--embed-resources',
          \ '--resource-path=' .. fnamemodify(l:source, ':h'),
          \ '--metadata=title:' .. fnamemodify(l:source, ':t'), '--output=' .. l:output, l:source]
    return s:Run('Markdown', l:source, l:argv, l:output, '')
  catch
    return s:Error(v:exception)
  endtry
endfunc

func! planet#writing#LatexBuild() abort
  try
    let l:argv = s:Command('PV_latexmk_argv', ['latexmk'], 'Install latexmk and a TeX distribution (TeX Live or MiKTeX)')
    let l:source = s:Source(['tex', 'plaintex'])
    let l:cache = s:Cache(l:source)
    let l:basename = fnamemodify(l:source, ':t:r')
    let l:argv += ['-pdf', '-interaction=nonstopmode', '-file-line-error', '-halt-on-error',
          \ '-no-shell-escape', '-outdir=' .. l:cache, l:source]
    return s:Run('LaTeX', l:source, l:argv, l:cache .. '/' .. l:basename .. '.pdf', l:cache .. '/' .. l:basename .. '.log')
  catch
    return s:Error(v:exception)
  endtry
endfunc

" Accept an option value (commas in a single path must already be escaped).
" Vim 9.1 validates every byte against 'isfname', including the comma escape
" and UTF-8 bytes. Allow those while setting it, without changing gf behavior.
func! planet#writing#SetSpellFile(value, local = v:true) abort
  let l:isfname = &isfname
  try
    set isfname+=32,39,92,128-255
    if a:local
      let &l:spellfile = a:value
    else
      let &spellfile = a:value
    endif
  finally
    let &isfname = l:isfname
  endtry
endfunc

func! planet#writing#Undo() abort
  if !exists('b:PV_writing_setup')
    return
  endif
  let l:setup = b:PV_writing_setup
  for [l:option, l:value] in items(l:setup.options)
    if l:option ==# 'spellfile'
      call planet#writing#SetSpellFile(l:value)
    else
      execute 'let &l:' .. l:option .. ' = l:value'
    endif
  endfor
  if l:setup.mapped
    silent! nunmap <buffer> <A-`>
    if !empty(l:setup.mapping)
      call mapset('n', 0, l:setup.mapping)
    endif
  endif
  let b:undo_ftplugin = l:setup.undo
  unlet b:PV_writing_setup
endfunc

func! planet#writing#Setup() abort
  call planet#writing#Undo()
  let l:mapping = maparg('<A-`>', 'n', 0, 1)
  let b:PV_writing_setup = {'options': {}, 'undo': get(b:, 'undo_ftplugin', ''),
        \ 'mapping': get(l:mapping, 'buffer', 0) ? l:mapping : {}, 'mapped': v:false}
  if has('spell')
    let b:PV_writing_setup.options = {'spell': &l:spell, 'spellfile': &l:spellfile, 'spelllang': &l:spelllang}
    call planet#writing#SetSpellFile(escape(get(g:, 'PV_personal_spell_file',
          \ planet#paths#State('spell') .. '/personal.utf-8.add'), ','))
    let &l:spelllang = get(g:, 'PV_spell_language', 'en_us')
    setlocal spell
  endif
  if &filetype ==# 'markdown'
    nnoremap <buffer> <silent> <A-`> <Cmd>PlanetMarkdownPreview<CR>
    let b:PV_writing_setup.mapped = v:true
  elseif index(['tex', 'plaintex'], &filetype) >= 0
    nnoremap <buffer> <silent> <A-`> <Cmd>PlanetLatexBuild<CR>
    let b:PV_writing_setup.mapped = v:true
  endif
  let b:undo_ftplugin = 'call planet#writing#Undo()'
        \ .. (empty(b:PV_writing_setup.undo) ? '' : ' | ' .. b:PV_writing_setup.undo)
endfunc

func! planet#writing#GrammarCheck() abort
  if !planet#grammar#Configure()
    return s:Error('Install the local LanguageTool command and Java, or configure g:PV_languagetool_command')
  endif
  return planet#prose#Grammar('check')
endfunc
