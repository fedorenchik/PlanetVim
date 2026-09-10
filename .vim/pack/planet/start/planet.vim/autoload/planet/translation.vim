vim9script

var script_state: dict<any> = {}
var script_requests = {}
var script_next = 0

def LocalWarn(message: any): any
  echohl WarningMsg
  echom 'PlanetVim translation: ' .. message
  echohl None
  return 0
enddef

def LocalSettings(): any
  var file: any
  if !has_key(script_state, 'settings')
    script_state.settings = {source:  get(g:, 'translator_source_lang', 'auto'), target:  get(g:, 'translator_target_lang', 'zh'), engines:  get(g:, 'translator_default_engines', ['google'])}
    file = planet#paths#Config() .. '/translation.json'
    if filereadable(file)
      try
        extend(script_state.settings, json_decode(join(readfile(file), "\n")), 'force')
      catch
        LocalWarn('could not load saved settings: ' .. v:exception)
      endtry
    endif
  endif
  # Bundled history writes inside the installation; this wrapper owns history.
  g:translator_history_enable = v:false
  return script_state.settings
enddef

export def Settings(): any
  return deepcopy(LocalSettings())
enddef

export def Language(which: any, arg_value: any = v:null): any
  if index(['source', 'target'], which) < 0
    return 0
  endif
  var settings: any = LocalSettings()
  var value: any = arg_value == null ? inputdialog(which .. ' language code:', settings[which], "\x01") : arg_value
  if empty(value) || value ==# "\x01"
    return 0
  endif
  if value !~# '^\a\{2,12}\%([-_]\a\{2,12}\)*$'
    return LocalWarn('use a language code such as en, zh-CN, or auto.')
  endif
  settings[which] = value
  g:['translator_' .. which .. '_lang'] = value
  writefile([json_encode(settings)], planet#paths#Config() .. '/translation.json')
  return 1
enddef

export def Engines(arg_value: any = v:null): any
  var engines: any
  var engine: any
  var settings: any = LocalSettings()
  var value: any = arg_value == null ? inputdialog('Translation engines (comma separated: google, bing, haici, iciba, youdao, baicizhan, trans, sdcv):',
       join(settings.engines, ', '), "\x01") : arg_value
  if type(value) == v:t_string && (empty(value) || value ==# "\x01")
    return 0
  endif
  engines = type(value) == v:t_list ? copy(value) : split(value, '\s*,\s*')
  if empty(engines) || !empty(filter(copy(engines), (_, lambda_e) => index(['google', 'bing', 'haici',
       'iciba', 'youdao', 'baicizhan', 'trans', 'sdcv'], lambda_e) < 0))
    return LocalWarn('select at least one supported translation engine.')
  endif
  settings.engines = []
  for item_engine in engines
    engine = item_engine
    if index(settings.engines, engine) < 0
      add(settings.engines, engine)
    endif
  endfor
  g:translator_default_engines = copy(settings.engines)
  writefile([json_encode(settings)], planet#paths#Config() .. '/translation.json')
  return 1
enddef

def LocalSelection(): any
  var word: any
  var line: any = getline('.')
  var at: any = 0
  while at < strlen(line)
    word = matchstrpos(line, '\k\+', at)
    if word[1] < 0
      break
    endif
    if word[1] <= col('.') - 1 && word[2] >= col('.')
      return {buffer: bufnr(), type: 'v', exclusive: v:false, start: [0, line('.'), word[1] + 1, 0], end: [0,
           line('.'), word[1] + byteidx(word[0], strchars(word[0]) - 1) + 1, 0]}
    endif
    at = word[2]
  endwhile
  return {}
enddef

export def Result(id: any): any
  return deepcopy(get(get(script_requests, id, {}), 'result', {}))
enddef

export def Translate(mode: any = 'window', arg_text: any = v:null, arg_selection: any = v:null, options: any = {}): any
  var capture: any
  var request: any
  if index(['window', 'echo', 'replace'], mode) < 0
    return LocalWarn('use window, echo, or replace.')
  endif
  if mode ==# 'replace' && !&modifiable
    return LocalWarn('the source buffer is not modifiable.')
  endif
  var settings: any = extend(deepcopy(LocalSettings()), options, 'force')
  var selection: any = arg_selection == null ? LocalSelection() : arg_selection
  var text: any = arg_text
  if text == null
    if empty(selection)
      return LocalWarn('place the cursor on a word or select text to translate.')
    endif
    capture = tempname()
    try
      planet#selection#Export(capture, selection)
      text = join(readfile(capture, 'b'), "\n")
    finally
      delete(capture)
    endtry
  endif
  if type(text) != v:t_string || empty(text)
    return 0
  endif
  var command: any = get(g:, 'PV_translation_command', [executable('python3') ? 'python3' : 'python',
       planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/translate.py'])
  if type(command) != v:t_list || empty(command) || !executable(command[0])
    return LocalWarn('install Python 3 or configure g:PV_translation_command as an executable argument list.')
  endif
  script_next += 1
  for key in keys(script_requests)
    if str2nr(key) < script_next - 50 && script_requests[key].result.status !=# 'running'
      remove(script_requests, key)
    endif
  endfor
  var context: any = {id: script_next, mode: mode, buffer: bufnr(), tick: b:changedtick, selection: deepcopy(selection),
       request: tempname(), output: tempname(), error: tempname(), result: {status: 'running', exit_code: v:null,
       text: text, results: [], source: settings.source, target: settings.target, engines: copy(settings.engines)}}
  request = extend(deepcopy(settings), {text: text, provider: planet#paths#Root() .. '/.vim/pack/writing/start/vim-translator/script/translator.py', proxy: get(g:, 'translator_proxy_url', ''), options: get(g:, 'translator_translate_shell_options', [])})
  writefile([json_encode(request)], context.request)
  script_requests[context.id] = context
  context.job = job_start(command + ['--request', context.request],  {in_io:  'null', out_io:  'file', out_name:  context.output,  err_io:  'file', err_name:  context.error, exit_cb:  function(LocalExited, [context])})
  context.timeout = timer_start(get(g:, 'PV_translation_timeout', 30000), function(LocalTimeout, [context]))
  if job_status(context.job) ==# 'fail'
    LocalExited(context, context.job, -1)
  endif
  return context.id
enddef

export def Command(mode: any, range: any, first: any, last: any, arg_text: any, bang: any = v:false): any
  var match: any
  var key: any
  var value: any
  var text: any = arg_text
  var options: any = deepcopy(LocalSettings())
  while text =~# '^\s*--'
    if text =~# '^\s*--\s'
      text = substitute(text, '^\s*--\s', '', '')
      break
    endif
    match = matchlist(text, '^\s*--\(engines\|source_lang\|target_lang\)=\([^[:space:]]\+\)\s*')
    if empty(match)
      return LocalWarn('use --engines=, --source_lang=, --target_lang=, or -- before literal text.')
    endif
    key = {'engines': 'engines', 'source_lang': 'source', 'target_lang': 'target'}[match[1]]
    if key ==# 'engines'
      value = split(match[2], ',')
      if empty(value) || !empty(filter(copy(value), (_, lambda_e) => index(['google', 'bing', 'haici',
           'iciba', 'youdao', 'baicizhan', 'trans', 'sdcv'], lambda_e) < 0))
        return LocalWarn('invalid engine option.')
      endif
    else
      value = match[2]
      if value !~# '^\a\{2,12}\%([-_]\a\{2,12}\)*$'
        return LocalWarn('invalid language option.')
      endif
    endif
    options[key] = value
    text = strpart(text, strlen(match[0]))
  endwhile
  if bang && options.source !=# 'auto'
    [options.source, options.target] = [options.target, options.source]
  endif
  if !empty(text)
    return planet#translation#Translate(mode, text, v:null, options)
  endif
  if range != 0
    return planet#translation#Translate(mode, v:null, {buffer: bufnr(), type: 'V', exclusive: v:false, start: [0, first, 1, 0], end: [0, last, 1, 0]}, options)
  endif
  return planet#translation#Translate(mode, v:null, v:null, options)
enddef

export def Complete(lead: any, command: any, position: any): any
  var choices: any = ['--engines=', '--source_lang=', '--target_lang=']
  if lead =~# '^--engines='
    choices = map(['google', 'bing', 'haici', 'iciba', 'youdao', 'baicizhan', 'trans', 'sdcv'], (_, engine) => '--engines=' .. engine)
  endif
  return filter(choices, (_, choice) => stridx(choice, lead) == 0)
enddef

def LocalTimeout(context: any, timer: any): any
  planet#translation#Cancel(context.id)
  return 0
enddef

export def Cancel(id: any): any
  var context: any = get(script_requests, id, {})
  if empty(context) || context.result.status !=# 'running'
    return 0
  endif
  context.cancelled = v:true
  return job_stop(context.job)
enddef

def LocalExited(context: any, job: any, status: any): any
  timer_start(0, function(LocalFinish, [context, status]))
  return 0
enddef

def LocalFinish(context: any, status: any, timer: any): any
  var result: any
  var decoded: any
  var stderr: any
  var window: any
  if context.result.status !=# 'running'
    return 0
  endif
  result = context.result
  timer_stop(context.timeout)
  result.exit_code = status
  try
    decoded = json_decode(join(readfile(context.output), "\n"))
    if type(decoded) != v:t_dict || type(get(decoded, 'results', 0)) != v:t_list
      throw 'invalid translation response'
    endif
    for entry in decoded.results
      if type(entry) != v:t_dict || type(get(entry, 'paraphrase', '')) != v:t_string || type(get(entry,
           'engine', '')) != v:t_string || type(get(entry, 'explains', [])) != v:t_list || !empty(filter(copy(get(entry,
           'explains', [])), (_, lambda_value) => type(lambda_value) != v:t_string))
        throw 'invalid translation entry'
      endif
    endfor
    result.results = decoded.results
    result.errors = get(decoded, 'errors', [])
    result.status = status == 0 && get(decoded, 'status', v:false) && !empty(result.results) ? 'success' :  'failed'
  catch
    result.status = 'failed'
    result.errors = [v:exception]
  finally
    stderr = filereadable(context.error) ? readfile(context.error) : []
    if !empty(stderr)
      result.errors = get(result, 'errors', []) + stderr
    endif
    for name in ['request', 'output', 'error']
      delete(context[name])
    endfor
  endtry
  if get(context, 'cancelled', v:false)
    result.status = 'cancelled'
  endif
  var event: any = {time: strftime('%Y-%m-%dT%H:%M:%S%z'), status: result.status, exit_code: status, errors: get(result, 'errors', [])}
  writefile([json_encode(event)], planet#paths#State('translation') .. '/events.jsonl', 'a')
  if result.status !=# 'success'
    LocalWarn('translation ' .. result.status .. ': ' .. join(get(result, 'errors', []), '; '))
    return 0
  endif
  writefile([json_encode(extend(copy(event), {text: result.text, results: result.results, source: result.source,
       target: result.target, engines: result.engines}))], planet#paths#State('translation') .. '/history.jsonl',
       'a')
  if context.mode ==# 'replace'
    window = bufwinid(context.buffer)
    if window < 0 || getbufvar(context.buffer, 'changedtick') != context.tick || empty(context.selection)
      LocalWarn('source changed or is hidden; replacement was not applied.')
      LocalShow(result)
    else
      win_execute(window, 'call planet#translation#Apply(' .. context.id .. ')')
    endif
  elseif context.mode ==# 'echo'
    echom join(LocalLines(result), ' | ')
  else
    LocalShow(result)
  endif
  return 0
enddef

def LocalLines(result: any): any
  var lines: any = [result.text, '']
  for translation in result.results
    add(lines, '[' .. get(translation, 'engine', 'translation') .. ']')
    if !empty(get(translation, 'paraphrase', ''))
      extend(lines, split(translation.paraphrase, "\n", 1))
    endif
    extend(lines, get(translation, 'explains', []))
  endfor
  return lines
enddef

def LocalShow(result: any): any
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  setline(1, LocalLines(result))
  setlocal nomodifiable
  return 0
enddef

export def Apply(id: any): any
  var registers: any
  var reg: any
  var context: any = get(script_requests, id, {})
  if empty(context) || bufnr() != context.buffer || b:changedtick != context.tick || !&modifiable
    return 0
  endif
  var text: any = ''
  for result in context.result.results
    if !empty(get(result, 'paraphrase', ''))
      text = result.paraphrase
      break
    endif
  endfor
  if empty(text)
    return LocalWarn('the selected engine supplied dictionary entries without a replacement phrase.')
  endif
  var saved: any = {selection: &selection, clipboard: &clipboard, virtualedit: &virtualedit, registers: {}}
  registers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', 'z', '"']
  for item_reg in registers
    reg = item_reg
    saved.registers[reg] = getreginfo(reg)
  endfor
  try
    &selection = context.selection.exclusive ? 'exclusive' :  'inclusive'
    set clipboard= virtualedit=all
    execute "normal! \<Esc>"
    setpos('.', context.selection.start)
    execute 'normal! ' .. context.selection.type
    setpos('.', context.selection.end)
    setreg('z', text, context.selection.type ==# 'V' ? 'V' : 'v')
    keepjumps normal! "zp
  finally
    &selection = saved.selection
    &clipboard = saved.clipboard
    &virtualedit = saved.virtualedit
    for item_reg in registers
      reg = item_reg
      setreg(reg, saved.registers[reg])
    endfor
  endtry
  return 1
enddef

export def History(path: any = v:null): any
  var source: any = planet#paths#State('translation') .. '/history.jsonl'
  if !filereadable(source)
    writefile([], source)
  endif
  if path != null
    if empty(path) || getftype(path) !=# ''
      return LocalWarn('choose a new history export filename.')
    endif
    writefile(readfile(source), path)
    return 1
  endif
  execute 'split ' .. fnameescape(source)
  setlocal filetype=jsonl
  return 1
enddef

export def ExportHistory(arg_path: any = v:null): any
  var path: any = arg_path == null ? inputdialog('Export translation history to a new file:', getcwd() .. '/translation-history.jsonl', "\x01") : arg_path
  if empty(path) || path ==# "\x01"
    return 0
  endif
  return planet#translation#History(path)
enddef

export def Log(): any
  var path: any = planet#paths#State('translation') .. '/events.jsonl'
  if !filereadable(path)
    writefile([], path)
  endif
  execute 'split ' .. fnameescape(path)
  return 1
enddef
