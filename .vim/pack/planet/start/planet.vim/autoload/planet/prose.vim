vim9script

var script_state: dict<any> = {}

def LocalWarn(message: any): any
  echohl WarningMsg
  echom 'PlanetVim writing: ' .. message
  echohl None
  return 0
enddef

export def Swap(direction: any): any
  var word: any
  var left: any
  var right: any
  if !&modifiable || index([-1, 1], direction) < 0
    return 0
  endif
  var text: any = join(getline(1, '$'), "\n")
  var offset: any = col('.') - 1
  if line('.') > 1
    offset += strlen(join(getline(1, line('.') - 1), "\n")) + 1
  endif
  var words: any = []
  var at: any = 0
  while at < strlen(text)
    word = matchstrpos(text, "\\k\\+\\%(['’]\\k\\+\\)*", at)
    if word[1] < 0
      break
    endif
    add(words, word)
    at = word[2]
  endwhile
  var current: any = -1
  for i in range(len(words))
    if words[i][1] <= offset
      current = i
    endif
    if words[i][2] > offset
      break
    endif
  endfor
  var other: any = current + direction
  if current < 0 || other < 0 || other >= len(words)
    return 0
  endif
  [left, right] = [words[min([current, other])], words[max([current, other])]]
  var middle: any = strpart(text, left[2], right[1] - left[2])
  var result: any = strpart(text, 0, left[1]) .. right[0] .. middle .. left[0] .. strpart(text, right[2])
  var destination: any = direction < 0 ? left[1] : left[1] + strlen(right[0]) + strlen(middle)
  var prefix: any = split(strpart(result, 0, destination), "\n", 1)
  setline(1, split(result, "\n", 1))
  cursor(len(prefix), strlen(prefix[-1]) + 1)
  return 1
enddef

export def Thesaurus(arg_path: any = v:null): any
  if arg_path == null && !empty(&l:thesaurus)
    return 1
  endif
  var path: any = arg_path == null ? inputdialog('Thesaurus file (one synonym group per line):', get(g:, 'PV_thesaurus_file', ''), "\x01") : arg_path
  if empty(path) || path ==# "\x01"
    return 0
  endif
  if !filereadable(path)
    return LocalWarn('select a readable thesaurus file; each line contains a word and its synonyms.')
  endif
  g:PV_thesaurus_file = fnamemodify(path, ':p')
  &l:thesaurus = escape(g:PV_thesaurus_file, ',\')
  return 1
enddef

export def Complete(): any
  if !planet#prose#Thesaurus()
    return 0
  endif
  # Start Vim's native thesaurus completion at the current word.
  if strpart(getline('.'), col('.')) =~# '^\k'
    normal! e
  endif
  feedkeys("a\<C-x>\<C-t>", 'n')
  return 1
enddef

export def Sample(paragraphs: any = v:null): any
  var line: any
  var value: any = paragraphs == null ? inputdialog('Number of sample paragraphs (1–100):', '1', "\x01") : paragraphs
  var text: any = type(value) == v:t_number ? string(value) : value
  if text ==# "\x01" || empty(text)
    return 0
  endif
  if text !~# '^\d\+$' || str2nr(text) < 1 || str2nr(text) > 100 || !&modifiable
    return LocalWarn('choose 1 through 100 paragraphs in a modifiable buffer.')
  endif
  var paragraph: any = 'A clear paragraph carries one idea from its opening sentence to its final detail. Specific words help the reader follow the thought, and varied sentences give the passage a natural rhythm. This sample provides ordinary prose for testing layout, editing, and typography.'
  var lines: any = []
  for i in range(str2nr(text))
    if i > 0
      add(lines, '')
    endif
    line = ''
    for word in split(paragraph)
      if strlen(line) + strlen(word) + 1 > 76
        add(lines, line)
        line = ''
      endif
      line ..= (empty(line) ? '' :  ' ') .. word
    endfor
    add(lines, line)
  endfor
  append(line('.'), lines)
  return 1
enddef

export def MarkRare(temporary: any): any
  var word: any = expand('<cword>')
  if empty(word)
    return 0
  endif
  if !temporary && empty(&l:spellfile)
    &l:spellfile = planet#paths#State('spell') .. '/personal.utf-8.add'
  endif
  execute 'spellrare' .. (temporary ? '! ' : ' ') .. escape(word, ' \|"')
  return 1
enddef

export def Focus(enable: any): any
  var value: any
  var option: any
  if enable
    if has_key(script_state, 'focus')
      return 1
    endif
    if has_key(script_state, 'focus_restore')
      timer_stop(script_state.focus_restore.timer)
      unlet script_state.focus_restore
    endif
    script_state.focus_generation = get(script_state, 'focus_generation', 0) + 1
    script_state.focus = {window:  win_getid(), size:  winrestcmd(), columns:  &columns, lines:  &lines, global:  {}, local:  {},  generation:  script_state.focus_generation, windows:  copy(gettabinfo(tabpagenr())[0].windows)}
    for item_option in ['guioptions', 'laststatus', 'showtabline', 'ruler', 'showmode']
      option = item_option
      script_state.focus.global[option] = eval('&' .. option)
    endfor
    for item_option in ['number', 'relativenumber', 'signcolumn', 'foldcolumn', 'colorcolumn', 'wrap', 'linebreak']
      option = item_option
      script_state.focus.local[option] = eval('&l:' .. option)
    endfor
    set guioptions-=m guioptions-=T guioptions-=r guioptions-=L laststatus=0 showtabline=0 noruler noshowmode
    setlocal nonumber norelativenumber signcolumn=no foldcolumn=0 colorcolumn= wrap linebreak
    wincmd _
    wincmd |

    return 1
  endif
  if !has_key(script_state, 'focus')
    return 1
  endif
  for [item_option, item_value] in items(script_state.focus.global)
    value = item_value
    option = item_option
    execute '&' .. option .. ' = ' .. string(value)
  endfor
  # GUI widgets can resize the text grid while guioptions is restored. Put
  # the original grid back before restoring split dimensions.
  &columns = script_state.focus.columns
  &lines = script_state.focus.lines
  redraw!
  if win_id2tabwin(script_state.focus.window)[0] > 0
    for [item_option, item_value] in items(script_state.focus.local)
      value = item_value
      option = item_option
      win_execute(script_state.focus.window, '&l:' .. option .. ' = ' .. string(value))
    endfor
    win_execute(script_state.focus.window, script_state.focus.size)
  endif
  if has('gui_running')
    script_state.focus_restore = deepcopy(script_state.focus)
    script_state.focus_restore.attempts = 0
    script_state.focus_restore.stable = 0
    script_state.focus_restore.timer = timer_start(20, function(LocalRestoreFocus), {repeat:  -1})
  endif
  unlet script_state.focus
  return 1
enddef

export def FocusPending(): any
  return has_key(script_state, 'focus_restore')
enddef

def LocalRestoreFocus(timer: any): any
  if !has_key(script_state, 'focus_restore') || script_state.focus_restore.timer != timer
    timer_stop(timer)
    return 0
  endif
  var restore: any = script_state.focus_restore
  var tab: any = win_id2tabwin(restore.window)[0]
  # A new focus operation or user split/close must supersede this restore.
  if has_key(script_state, 'focus') || restore.generation != get(script_state, 'focus_generation', 0) || tab == 0 || gettabinfo(tab)[0].windows !=# restore.windows
    timer_stop(timer)
    unlet script_state.focus_restore
    return 0
  endif
  restore.attempts += 1
  if &columns != restore.columns || &lines != restore.lines
    restore.stable = 0
    &columns = restore.columns
    &lines = restore.lines
  else
    restore.stable += 1
  endif
  win_execute(restore.window, restore.size)
  # GTK may deliver several grid resizes after the widgets are restored.
  # Keep applying the saved split sizes while those events settle, bounded to
  # one second; no callback survives a subsequent focus operation.
  if (restore.attempts >= 10 && restore.stable >= 3) || restore.attempts >= 50
    timer_stop(timer)
    unlet script_state.focus_restore
  endif
  return 0
enddef

def LocalFocusResized(): any
  if has_key(script_state, 'focus_restore')
    script_state.focus_restore.stable = 0
  endif
  return 0
enddef

augroup PlanetVimFocusRestore
  autocmd!
  autocmd VimResized * call LocalFocusResized()
augroup END

export def Load(package: any, plugin: any): any
  var path: any = planet#paths#Root() .. '/.vim/pack/writing/start/' .. package
  if !filereadable(path .. '/plugin/' .. plugin .. '.vim')
    return LocalWarn('bundled ' .. package .. ' is missing.')
  endif
  var entry: any = planet#paths#Runtime(path)
  if stridx(',' .. &runtimepath .. ',', ',' .. entry .. ',') < 0
    &runtimepath = entry .. ',' .. &runtimepath
  endif
  execute 'source ' .. fnameescape(path .. '/plugin/' .. plugin .. '.vim')
  return 1
enddef

export def AutoCorrect(): any
  if index(getcompletion('AutoCorrect', 'function'), 'AutoCorrect()') < 0 && !planet#prose#Load('vim-autocorrect', 'autocorrect')
    return 0
  endif
  g:AutoCorrect()
  return 1
enddef

export def Proofread(category: any): any
  var source: any
  var spell: any
  var target: any
  g:wordy_spell_dir = planet#paths#Cache('wordy')
  var entry: any = planet#paths#Runtime(g:wordy_spell_dir)
  if stridx(',' .. &runtimepath .. ',', ',' .. entry .. ',') < 0
    &runtimepath ..= ',' .. entry
  endif
  if exists(':Wordy') != 2 && !planet#prose#Load('vim-wordy', 'wordy')
    return 0
  endif
  if category ==# 'off'
    execute 'NoWordy'
  elseif category =~# '^[a-z-]\+$'
    # Upstream's mkspell command does not escape paths. Build the selected
    # dictionary safely in the cache, so its normal public API can reuse it.
    source = g:wordy_dir .. '/data/en/' .. category .. '.dic'
    if !filereadable(source)
      return LocalWarn('unknown proofreading dictionary: ' .. category)
    endif
    spell = g:wordy_spell_dir .. '/spell'
    mkdir(spell, 'p')
    target = spell .. '/' .. category .. '.utf-8.spl'
    if !filereadable(target) || getftime(target) < getftime(source)
      execute 'mkspell! ' .. fnameescape(target) .. ' ' .. fnameescape(source)
    endif
    execute 'Wordy ' .. category
  else
    return LocalWarn('invalid proofreading category.')
  endif
  return 1
enddef

export def Grammar(action: any): any
  if action ==# 'status'
    echom 'LanguageTool: ' .. string(get(g:, 'PV_languagetool_argv', [get(g:, 'PV_languagetool_command', 'languagetool')]))
    echom 'Grammar results in this buffer: ' .. string(get(b:, 'grammarous_result', {}))
    if filereadable(get(g:, 'PV_grammar_error_file', ''))
      echom 'Last LanguageTool error: ' .. join(readfile(g:PV_grammar_error_file), "\n")
    endif
    return 1
  endif
  if exists(':GrammarousCheck') != 2 && !planet#prose#Load('vim-grammarous', 'grammarous')
    return 0
  endif
  if action ==# 'reset'
    execute 'GrammarousReset'
    return 1
  endif
  if !planet#grammar#Configure()
    return 0
  endif
  if action ==# 'comments'
    execute 'GrammarousCheck --comments-only'
  else
    execute 'GrammarousCheck'
  endif
  return 1
enddef
