vim9script

var script_instance = getpid() .. '-' .. sha256(tempname())[ : 15]
var script_last_error = ''
var script_last_result = {}
var script_last_quickfix = 0

def LocalError(message: any): any
  script_last_error = message
  echohl ErrorMsg
  echom 'PlanetVim: ' .. message
  echohl None
  return 0
enddef

export def LastError(): any
  return script_last_error
enddef

def LocalCommand(key: any, default: any, guidance: any): any
  var argv: any = get(g:, key, default)
  if type(argv) != v:t_list || empty(argv) || !empty(filter(copy(argv), (_, lambda_value) => type(lambda_value) != v:t_string))
    throw 'Configure g:' .. key .. ' as a nonempty executable argv List'
  endif
  if !executable(argv[0])
    throw guidance .. '; or configure g:' .. key
  endif
  return copy(argv)
enddef

def LocalSource(types: any): any
  if index(types, &filetype) < 0 || !empty(&buftype) || empty(expand('%'))
    throw 'Save a ' .. join(types, '/') .. ' document before running this action'
  endif
  if &modified
    confirm update
    if &modified
      throw 'Document was not saved; the writing action was cancelled'
    endif
  endif
  var path: any = expand('%:p')
  if !filereadable(path)
    throw 'Save the document before running this action'
  endif
  return path
enddef

def LocalCache(source: any): any
  return planet#paths#Cache('writing/' .. script_instance .. '/' .. sha256(source)[ : 15])
enddef

def LocalOpen(path: any): any
  if !filereadable(path)
    throw 'The generated document is missing: ' .. path
  endif
  var default: any = has('win32') ? ['rundll32.exe', 'url.dll,FileProtocolHandler'] : ['xdg-open']
  var argv: any = LocalCommand('PV_document_viewer_argv', default, 'Install a desktop HTML/PDF viewer and xdg-open (Linux), or configure a document viewer')
  var job: any = planet#term#RunGuiApp(argv + [path], fnamemodify(path, ':h'))
  if type(job) != v:t_job || job_status(job) ==# 'fail'
    throw 'Could not start the document viewer'
  endif
  return 1
enddef

export def OpenOutput(): any
  var result: any = get(b:, 'PV_writing_result', script_last_result)
  if get(result, 'status', '') !=# 'success'
    return LocalError('Build or preview a document successfully before opening its output')
  endif
  try
    return LocalOpen(result.output)
  catch
    return LocalError(v:exception)
  endtry
enddef

def LocalDiagnostics(context: any, lines: any): any
  var match: any
  var file: any
  var nonempty: any
  var items: any = []
  for line in lines
    match = matchlist(line, '^\(.\{-}\):\(\d\+\):\s*\(.*\)$')
    if !empty(match)
      file = match[1]
      if file !~# '^\%(/\|[A-Za-z]:[/\\]\)'
        file = fnamemodify(context.source, ':h') .. '/' .. file
      endif
      add(items, {'filename': simplify(file), 'lnum': str2nr(match[2]), 'text': match[3], 'type': 'E'})
    endif
  endfor
  if empty(items)
    nonempty = filter(copy(lines), (_, lambda_line) => !empty(trim(lambda_line)))
    add(items, {'filename': context.source, 'lnum': 1, 'type': 'E', 'text': empty(nonempty) ? 'Writing command failed; inspect its Output buffer' : nonempty[-1]})
  endif
  setqflist([], ' ', {'title': 'PlanetVim ' .. context.kind .. ': ' .. context.source, 'items': items})
  script_last_quickfix = getqflist({'id': 0}).id
  return script_last_quickfix
enddef

export def Errors(): any
  var nr: any = getqflist({'id': script_last_quickfix, 'nr': 0}).nr
  if script_last_quickfix == 0 || nr == 0
    return LocalError('There are no writing errors to show')
  endif
  var current: any = getqflist({'nr': 0}).nr
  if nr != current
    execute ':' .. abs(nr - current) .. (nr < current ? 'colder' : 'cnewer')
  endif
  copen
  return 1
enddef

def LocalComplete(context: any, arg_result: any, output_buffer: any, timer: any): any
  var lines: any
  if bufexists(output_buffer) && term_getstatus(output_buffer) !~# 'finished'
    timer_start(20, function(LocalComplete, [context, arg_result, output_buffer]))
    return 0
  endif
  var result: any = extend(deepcopy(arg_result), {'output': context.output, 'source': context.source})
  if result.status ==# 'success' && !filereadable(context.output)
    result.status = 'failed'
    result.message = 'The command completed without creating ' .. context.output
  endif
  if result.status ==# 'failed'
    lines = filereadable(context.log) ? readfile(context.log) : getbufline(output_buffer, 1, '$')
    if has_key(result, 'message')
      add(lines, result.message)
    endif
    result.quickfix = LocalDiagnostics(context, lines)
  elseif result.status ==# 'success' && get(context, 'previous_errors', 0) > 0
    setqflist([], 'r', {'id': context.previous_errors, 'items': []})
  endif
  if bufexists(context.buffer)
    setbufvar(context.buffer, 'PV_writing_result', result)
  endif
  script_last_result = result
  if result.status ==# 'success' && context.open
    try
      LocalOpen(context.output)
    catch
      result.viewer_error = v:exception
      LocalError(v:exception)
    endtry
  endif
  return 0
enddef

def LocalExited(context: any, result: any, output_buffer: any): any
  timer_start(0, function(LocalComplete, [context, result, output_buffer]))
  return 0
enddef

def LocalRun(kind: any, source: any, argv: any, output: any, log: any): any
  var context: any = {'kind': kind, 'source': source, 'output': output, 'log': log, 'buffer': bufnr(),
       'open': get(g:, 'PV_writing_auto_open', 1), 'previous_errors': get(get(b:, 'PV_writing_result',
       {}), 'quickfix', 0)}
  b:PV_writing_result = {'status':  'running', 'source':  source, 'output':  output}
  var output_buffer: any = planet#term#RunArgv(argv, v:false, v:false, v:false, fnamemodify(source, ':h'), function(LocalExited, [context]))
  if output_buffer == 0
    b:PV_writing_result.status = 'failed'
    return LocalError('Could not start the writing command')
  endif
  b:PV_writing_result.output_buffer = output_buffer
  return output_buffer
enddef

export def MarkdownPreview(): any
  var argv: any
  var source: any
  var output: any
  try
    argv = LocalCommand('PV_pandoc_argv', ['pandoc'], 'Install Pandoc 2.19 or newer for Markdown preview')
    source = LocalSource(['markdown'])
    output = LocalCache(source) .. '/preview.html'
    argv += ['--standalone', '--from=gfm', '--to=html5', '--embed-resources',  '--resource-path=' .. fnamemodify(source, ':h'),  '--metadata=title:' .. fnamemodify(source, ':t'), '--output=' .. output, source]
    return LocalRun('Markdown', source, argv, output, '')
  catch
    return LocalError(v:exception)
  endtry
enddef

export def LatexBuild(): any
  var argv: any
  var source: any
  var cache: any
  var basename: any
  try
    argv = LocalCommand('PV_latexmk_argv', ['latexmk'], 'Install latexmk and a TeX distribution (TeX Live or MiKTeX)')
    source = LocalSource(['tex', 'plaintex'])
    cache = LocalCache(source)
    basename = fnamemodify(source, ':t:r')
    argv += ['-pdf', '-interaction=nonstopmode', '-file-line-error', '-halt-on-error',  '-no-shell-escape', '-outdir=' .. cache, source]
    return LocalRun('LaTeX', source, argv, cache .. '/' .. basename .. '.pdf', cache .. '/' .. basename .. '.log')
  catch
    return LocalError(v:exception)
  endtry
enddef

# Accept an option value (commas in a single path must already be escaped).
# Vim 9.1 validates every byte against 'isfname', including the comma escape
# and UTF-8 bytes. Allow those while setting it, without changing gf behavior.
export def SetSpellFile(value: any, local: any = v:true): any
  var isfname: any = &isfname
  try
    set isfname+=32,39,92,128-255
    if local
      &l:spellfile = value
    else
      &spellfile = value
    endif
  finally
    &isfname = isfname
  endtry
  return 0
enddef

export def Undo(): any
  if !exists('b:PV_writing_setup')
    return 0
  endif
  var setup: any = b:PV_writing_setup
  for [option, value] in items(setup.options)
    if option ==# 'spellfile'
      planet#writing#SetSpellFile(value)
    else
      execute '&l:' .. option .. ' = ' .. string(value)
    endif
  endfor
  if setup.mapped
    silent! nunmap <buffer> <A-`>
    if !empty(setup.mapping)
      mapset('n', 0, setup.mapping)
    endif
  endif
  b:undo_ftplugin = setup.undo
  unlet b:PV_writing_setup
  return 0
enddef

export def Setup(): any
  planet#writing#Undo()
  var mapping: any = maparg('<A-`>', 'n', 0, 1)
  b:PV_writing_setup = {'options':  {}, 'undo':  get(b:, 'undo_ftplugin', ''),  'mapping':  get(mapping, 'buffer', 0) ? mapping :  {}, 'mapped':  v:false}
  if has('spell')
    b:PV_writing_setup.options = {'spell':  &l:spell, 'spellfile':  &l:spellfile, 'spelllang':  &l:spelllang}
    planet#writing#SetSpellFile(escape(get(g:, 'PV_personal_spell_file',  planet#paths#State('spell') .. '/personal.utf-8.add'), ','))
    &l:spelllang = get(g:, 'PV_spell_language', 'en_us')
    setlocal spell
  endif
  if &filetype ==# 'markdown'
    nnoremap <buffer> <silent> <A-`> <Cmd>PlanetMarkdownPreview<CR>
    b:PV_writing_setup.mapped = v:true
  elseif index(['tex', 'plaintex'], &filetype) >= 0
    nnoremap <buffer> <silent> <A-`> <Cmd>PlanetLatexBuild<CR>
    b:PV_writing_setup.mapped = v:true
  endif
  b:undo_ftplugin = 'call planet#writing#Undo()'  .. (empty(b:PV_writing_setup.undo) ? '' :  ' | ' .. b:PV_writing_setup.undo)
  return 0
enddef

export def GrammarCheck(): any
  if !planet#grammar#Configure()
    return LocalError('Install the local LanguageTool command and Java, or configure g:PV_languagetool_command')
  endif
  return planet#prose#Grammar('check')
enddef
