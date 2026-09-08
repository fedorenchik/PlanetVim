scriptversion 4
let s:requests = {}
let s:next = 0

func! s:Warn(message) abort
  echohl WarningMsg
  echom 'PlanetVim translation: ' .. a:message
  echohl None
  return 0
endfunc

func! s:Settings() abort
  if !exists('s:settings')
    let s:settings = #{source: get(g:, 'translator_source_lang', 'auto'), target: get(g:, 'translator_target_lang', 'zh'), engines: get(g:, 'translator_default_engines', ['google'])}
    let l:file = planet#paths#Config() .. '/translation.json'
    if filereadable(l:file)
      try
        call extend(s:settings, json_decode(join(readfile(l:file), "\n")), 'force')
      catch
        call s:Warn('could not load saved settings: ' .. v:exception)
      endtry
    endif
  endif
  " Bundled history writes inside the installation; this wrapper owns history.
  let g:translator_history_enable = v:false
  return s:settings
endfunc

func! planet#translation#Settings() abort
  return deepcopy(s:Settings())
endfunc

func! planet#translation#Language(which, value = v:null) abort
  if index(['source', 'target'], a:which) < 0
    return 0
  endif
  let l:settings = s:Settings()
  let l:value = a:value is v:null ? inputdialog(a:which .. ' language code:', l:settings[a:which], "\x01") : a:value
  if empty(l:value) || l:value ==# "\x01"
    return 0
  endif
  if l:value !~# '^\a\{2,12}\%([-_]\a\{2,12}\)*$'
    return s:Warn('use a language code such as en, zh-CN, or auto.')
  endif
  let l:settings[a:which] = l:value
  let g:['translator_' .. a:which .. '_lang'] = l:value
  call writefile([json_encode(l:settings)], planet#paths#Config() .. '/translation.json')
  return 1
endfunc

func! planet#translation#Engines(value = v:null) abort
  let l:settings = s:Settings()
  let l:value = a:value is v:null ? inputdialog('Translation engines (comma separated: google, bing, haici, iciba, youdao, baicizhan, trans, sdcv):', join(l:settings.engines, ', '), "\x01") : a:value
  if type(l:value) == v:t_string && (empty(l:value) || l:value ==# "\x01")
    return 0
  endif
  let l:engines = type(l:value) == v:t_list ? copy(l:value) : split(l:value, '\s*,\s*')
  if empty(l:engines) || !empty(filter(copy(l:engines), {_, e -> index(['google', 'bing', 'haici', 'iciba', 'youdao', 'baicizhan', 'trans', 'sdcv'], e) < 0}))
    return s:Warn('select at least one supported translation engine.')
  endif
  let l:settings.engines = []
  for l:engine in l:engines
    if index(l:settings.engines, l:engine) < 0
      call add(l:settings.engines, l:engine)
    endif
  endfor
  let g:translator_default_engines = copy(l:settings.engines)
  call writefile([json_encode(l:settings)], planet#paths#Config() .. '/translation.json')
  return 1
endfunc

func! s:Selection() abort
  let l:line = getline('.')
  let l:at = 0
  while l:at < strlen(l:line)
    let l:word = matchstrpos(l:line, '\k\+', l:at)
    if l:word[1] < 0
      break
    endif
    if l:word[1] <= col('.') - 1 && l:word[2] >= col('.')
      return #{buffer: bufnr(), type: 'v', exclusive: v:false,
            \ start: [0, line('.'), l:word[1] + 1, 0],
            \ end: [0, line('.'), l:word[1] + byteidx(l:word[0], strchars(l:word[0]) - 1) + 1, 0]}
    endif
    let l:at = l:word[2]
  endwhile
  return {}
endfunc

func! planet#translation#Result(id) abort
  return deepcopy(get(get(s:requests, a:id, {}), 'result', {}))
endfunc

func! planet#translation#Translate(mode = 'window', text = v:null, selection = v:null, options = {}) abort
  if index(['window', 'echo', 'replace'], a:mode) < 0
    return s:Warn('use window, echo, or replace.')
  endif
  if a:mode ==# 'replace' && !&modifiable
    return s:Warn('the source buffer is not modifiable.')
  endif
  let l:settings = extend(deepcopy(s:Settings()), a:options, 'force')
  let l:selection = a:selection is v:null ? s:Selection() : a:selection
  let l:text = a:text
  if l:text is v:null
    if empty(l:selection)
      return s:Warn('place the cursor on a word or select text to translate.')
    endif
    let l:capture = tempname()
    try
      call planet#selection#Export(l:capture, l:selection)
      let l:text = join(readfile(l:capture, 'b'), "\n")
    finally
      call delete(l:capture)
    endtry
  endif
  if type(l:text) != v:t_string || empty(l:text)
    return 0
  endif
  let l:command = get(g:, 'PV_translation_command', [executable('python3') ? 'python3' : 'python', planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/translate.py'])
  if type(l:command) != v:t_list || empty(l:command) || !executable(l:command[0])
    return s:Warn('install Python 3 or configure g:PV_translation_command as an executable argument list.')
  endif
  let s:next += 1
  for l:key in keys(s:requests)
    if str2nr(l:key) < s:next - 50 && s:requests[l:key].result.status !=# 'running'
      call remove(s:requests, l:key)
    endif
  endfor
  let l:context = #{id: s:next, mode: a:mode, buffer: bufnr(), tick: b:changedtick,
        \ selection: deepcopy(l:selection), request: tempname(), output: tempname(), error: tempname(),
        \ result: #{status: 'running', exit_code: v:null, text: l:text, results: [],
        \ source: l:settings.source, target: l:settings.target, engines: copy(l:settings.engines)}}
  let l:request = extend(deepcopy(l:settings), #{text: l:text,
        \ provider: planet#paths#Root() .. '/.vim/pack/writing/start/vim-translator/script/translator.py',
        \ proxy: get(g:, 'translator_proxy_url', ''), options: get(g:, 'translator_translate_shell_options', [])})
  call writefile([json_encode(l:request)], l:context.request)
  let s:requests[l:context.id] = l:context
  let l:context.job = job_start(l:command + ['--request', l:context.request],
        \ #{in_io: 'null', out_io: 'file', out_name: l:context.output,
        \ err_io: 'file', err_name: l:context.error, exit_cb: function('s:Exited', [l:context])})
  let l:context.timeout = timer_start(get(g:, 'PV_translation_timeout', 30000), function('s:Timeout', [l:context]))
  if job_status(l:context.job) ==# 'fail'
    call s:Exited(l:context, l:context.job, -1)
  endif
  return l:context.id
endfunc

func! planet#translation#Command(mode, range, first, last, text, bang = v:false) abort
  let l:text = a:text
  let l:options = deepcopy(s:Settings())
  while l:text =~# '^\s*--'
    if l:text =~# '^\s*--\s'
      let l:text = substitute(l:text, '^\s*--\s', '', '')
      break
    endif
    let l:match = matchlist(l:text, '^\s*--\(engines\|source_lang\|target_lang\)=\([^[:space:]]\+\)\s*')
    if empty(l:match)
      return s:Warn('use --engines=, --source_lang=, --target_lang=, or -- before literal text.')
    endif
    let l:key = {'engines': 'engines', 'source_lang': 'source', 'target_lang': 'target'}[l:match[1]]
    if l:key ==# 'engines'
      let l:value = split(l:match[2], ',')
      if empty(l:value) || !empty(filter(copy(l:value), {_, e -> index(['google', 'bing', 'haici', 'iciba', 'youdao', 'baicizhan', 'trans', 'sdcv'], e) < 0}))
        return s:Warn('invalid engine option.')
      endif
    else
      let l:value = l:match[2]
      if l:value !~# '^\a\{2,12}\%([-_]\a\{2,12}\)*$'
        return s:Warn('invalid language option.')
      endif
    endif
    let l:options[l:key] = l:value
    let l:text = strpart(l:text, strlen(l:match[0]))
  endwhile
  if a:bang && l:options.source !=# 'auto'
    let [l:options.source, l:options.target] = [l:options.target, l:options.source]
  endif
  if !empty(l:text)
    return planet#translation#Translate(a:mode, l:text, v:null, l:options)
  endif
  if a:range
    return planet#translation#Translate(a:mode, v:null, #{buffer: bufnr(), type: 'V', exclusive: v:false,
          \ start: [0, a:first, 1, 0], end: [0, a:last, 1, 0]}, l:options)
  endif
  return planet#translation#Translate(a:mode, v:null, v:null, l:options)
endfunc

func! planet#translation#Complete(lead, command, position) abort
  let l:choices = ['--engines=', '--source_lang=', '--target_lang=']
  if a:lead =~# '^--engines='
    let l:choices = map(['google', 'bing', 'haici', 'iciba', 'youdao', 'baicizhan', 'trans', 'sdcv'], '"--engines=" .. v:val')
  endif
  return filter(l:choices, 'stridx(v:val, a:lead) == 0')
endfunc

func! s:Timeout(context, timer) abort
  call planet#translation#Cancel(a:context.id)
endfunc

func! planet#translation#Cancel(id) abort
  let l:context = get(s:requests, a:id, {})
  if empty(l:context) || l:context.result.status !=# 'running'
    return 0
  endif
  let l:context.cancelled = v:true
  return job_stop(l:context.job)
endfunc

func! s:Exited(context, job, status) abort
  call timer_start(0, function('s:Finish', [a:context, a:status]))
endfunc

func! s:Finish(context, status, timer) abort
  if a:context.result.status !=# 'running'
    return
  endif
  let l:result = a:context.result
  call timer_stop(a:context.timeout)
  let l:result.exit_code = a:status
  try
    let l:decoded = json_decode(join(readfile(a:context.output), "\n"))
    if type(l:decoded) != v:t_dict || type(get(l:decoded, 'results', 0)) != v:t_list
      throw 'invalid translation response'
    endif
    for l:entry in l:decoded.results
      if type(l:entry) != v:t_dict || type(get(l:entry, 'paraphrase', '')) != v:t_string
            \ || type(get(l:entry, 'engine', '')) != v:t_string || type(get(l:entry, 'explains', [])) != v:t_list
            \ || !empty(filter(copy(get(l:entry, 'explains', [])), {_, value -> type(value) != v:t_string}))
        throw 'invalid translation entry'
      endif
    endfor
    let l:result.results = l:decoded.results
    let l:result.errors = get(l:decoded, 'errors', [])
    let l:result.status = a:status == 0 && get(l:decoded, 'status', v:false) && !empty(l:result.results) ? 'success' : 'failed'
  catch
    let l:result.status = 'failed'
    let l:result.errors = [v:exception]
  finally
    let l:stderr = filereadable(a:context.error) ? readfile(a:context.error) : []
    if !empty(l:stderr)
      let l:result.errors = get(l:result, 'errors', []) + l:stderr
    endif
    for l:name in ['request', 'output', 'error']
      call delete(a:context[l:name])
    endfor
  endtry
  if get(a:context, 'cancelled', v:false)
    let l:result.status = 'cancelled'
  endif
  let l:event = #{time: strftime('%Y-%m-%dT%H:%M:%S%z'), status: l:result.status, exit_code: a:status, errors: get(l:result, 'errors', [])}
  call writefile([json_encode(l:event)], planet#paths#State('translation') .. '/events.jsonl', 'a')
  if l:result.status !=# 'success'
    call s:Warn('translation ' .. l:result.status .. ': ' .. join(get(l:result, 'errors', []), '; '))
    return
  endif
  call writefile([json_encode(extend(copy(l:event), #{text: l:result.text, results: l:result.results,
        \ source: l:result.source, target: l:result.target, engines: l:result.engines}))], planet#paths#State('translation') .. '/history.jsonl', 'a')
  if a:context.mode ==# 'replace'
    let l:window = bufwinid(a:context.buffer)
    if l:window < 0 || getbufvar(a:context.buffer, 'changedtick') != a:context.tick || empty(a:context.selection)
      call s:Warn('source changed or is hidden; replacement was not applied.')
      call s:Show(l:result)
    else
      call win_execute(l:window, 'call planet#translation#Apply(' .. a:context.id .. ')')
    endif
  elseif a:context.mode ==# 'echo'
    echom join(s:Lines(l:result), ' | ')
  else
    call s:Show(l:result)
  endif
endfunc

func! s:Lines(result) abort
  let l:lines = [a:result.text, '']
  for l:translation in a:result.results
    call add(l:lines, '[' .. get(l:translation, 'engine', 'translation') .. ']')
    if !empty(get(l:translation, 'paraphrase', ''))
      call extend(l:lines, split(l:translation.paraphrase, "\n", 1))
    endif
    call extend(l:lines, get(l:translation, 'explains', []))
  endfor
  return l:lines
endfunc

func! s:Show(result) abort
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, s:Lines(a:result))
  setlocal nomodifiable
endfunc

func! planet#translation#Apply(id) abort
  let l:context = get(s:requests, a:id, {})
  if empty(l:context) || bufnr() != l:context.buffer || b:changedtick != l:context.tick || !&modifiable
    return 0
  endif
  let l:text = ''
  for l:result in l:context.result.results
    if !empty(get(l:result, 'paraphrase', ''))
      let l:text = l:result.paraphrase
      break
    endif
  endfor
  if empty(l:text)
    return s:Warn('the selected engine supplied dictionary entries without a replacement phrase.')
  endif
  let l:saved = #{selection: &selection, clipboard: &clipboard, virtualedit: &virtualedit,
        \ registers: {}}
  let l:registers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', 'z', '"']
  for l:reg in l:registers
    let l:saved.registers[l:reg] = getreginfo(l:reg)
  endfor
  try
    let &selection = l:context.selection.exclusive ? 'exclusive' : 'inclusive'
    set clipboard= virtualedit=all
    execute "normal! \<Esc>"
    call setpos('.', l:context.selection.start)
    execute 'normal! ' .. l:context.selection.type
    call setpos('.', l:context.selection.end)
    call setreg('z', l:text, l:context.selection.type ==# 'V' ? 'V' : 'v')
    keepjumps normal! "zp
  finally
    let &selection = l:saved.selection
    let &clipboard = l:saved.clipboard
    let &virtualedit = l:saved.virtualedit
    for l:reg in l:registers
      call setreg(l:reg, l:saved.registers[l:reg])
    endfor
  endtry
  return 1
endfunc

func! planet#translation#History(path = v:null) abort
  let l:source = planet#paths#State('translation') .. '/history.jsonl'
  if !filereadable(l:source)
    call writefile([], l:source)
  endif
  if a:path isnot v:null
    if empty(a:path) || getftype(a:path) !=# ''
      return s:Warn('choose a new history export filename.')
    endif
    call writefile(readfile(l:source), a:path)
    return 1
  endif
  execute 'split ' .. fnameescape(l:source)
  setlocal filetype=jsonl
  return 1
endfunc

func! planet#translation#ExportHistory(path = v:null) abort
  let l:path = a:path is v:null ? inputdialog('Export translation history to a new file:', getcwd() .. '/translation-history.jsonl', "\x01") : a:path
  if empty(l:path) || l:path ==# "\x01"
    return 0
  endif
  return planet#translation#History(l:path)
endfunc

func! planet#translation#Log() abort
  let l:path = planet#paths#State('translation') .. '/events.jsonl'
  if !filereadable(l:path)
    call writefile([], l:path)
  endif
  execute 'split ' .. fnameescape(l:path)
  return 1
endfunc
