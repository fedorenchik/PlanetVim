scriptversion 4

func! s:Warn(message) abort
  echohl WarningMsg
  echom 'PlanetVim writing: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#prose#Swap(direction) abort
  if !&modifiable || index([-1, 1], a:direction) < 0
    return 0
  endif
  let l:text = join(getline(1, '$'), "\n")
  let l:offset = col('.') - 1
  if line('.') > 1
    let l:offset += strlen(join(getline(1, line('.') - 1), "\n")) + 1
  endif
  let l:words = []
  let l:at = 0
  while l:at < strlen(l:text)
    let l:word = matchstrpos(l:text, "\\k\\+\\%(['’]\\k\\+\\)*", l:at)
    if l:word[1] < 0
      break
    endif
    call add(l:words, l:word)
    let l:at = l:word[2]
  endwhile
  let l:current = -1
  for l:i in range(len(l:words))
    if l:words[l:i][1] <= l:offset
      let l:current = l:i
    endif
    if l:words[l:i][2] > l:offset
      break
    endif
  endfor
  let l:other = l:current + a:direction
  if l:current < 0 || l:other < 0 || l:other >= len(l:words)
    return 0
  endif
  let [l:left, l:right] = [l:words[min([l:current, l:other])], l:words[max([l:current, l:other])]]
  let l:middle = strpart(l:text, l:left[2], l:right[1] - l:left[2])
  let l:result = strpart(l:text, 0, l:left[1]) .. l:right[0] .. l:middle .. l:left[0] .. strpart(l:text, l:right[2])
  let l:destination = a:direction < 0 ? l:left[1] : l:left[1] + strlen(l:right[0]) + strlen(l:middle)
  let l:prefix = split(strpart(l:result, 0, l:destination), "\n", 1)
  call setline(1, split(l:result, "\n", 1))
  call cursor(len(l:prefix), strlen(l:prefix[-1]) + 1)
  return 1
endfunc

func! planet#prose#Thesaurus(path = v:null) abort
  if a:path is v:null && !empty(&l:thesaurus)
    return 1
  endif
  let l:path = a:path is v:null ? inputdialog('Thesaurus file (one synonym group per line):', get(g:, 'PV_thesaurus_file', ''), "\x01") : a:path
  if empty(l:path) || l:path ==# "\x01"
    return 0
  endif
  if !filereadable(l:path)
    return s:Warn('select a readable thesaurus file; each line contains a word and its synonyms.')
  endif
  let g:PV_thesaurus_file = fnamemodify(l:path, ':p')
  let &l:thesaurus = escape(g:PV_thesaurus_file, ',\')
  return 1
endfunc

func! planet#prose#Complete() abort
  if !planet#prose#Thesaurus()
    return 0
  endif
  " Start Vim's native thesaurus completion at the current word.
  if strpart(getline('.'), col('.')) =~# '^\k'
    normal! e
  endif
  call feedkeys("a\<C-x>\<C-t>", 'n')
  return 1
endfunc

func! planet#prose#Sample(paragraphs = v:null) abort
  let l:value = a:paragraphs is v:null ? inputdialog('Number of sample paragraphs (1–100):', '1', "\x01") : a:paragraphs
  let l:text = type(l:value) == v:t_number ? string(l:value) : l:value
  if l:text ==# "\x01" || empty(l:text)
    return 0
  endif
  if l:text !~# '^\d\+$' || str2nr(l:text) < 1 || str2nr(l:text) > 100 || !&modifiable
    return s:Warn('choose 1 through 100 paragraphs in a modifiable buffer.')
  endif
  let l:paragraph = 'A clear paragraph carries one idea from its opening sentence to its final detail. Specific words help the reader follow the thought, and varied sentences give the passage a natural rhythm. This sample provides ordinary prose for testing layout, editing, and typography.'
  let l:lines = []
  for l:i in range(str2nr(l:text))
    if l:i > 0
      call add(l:lines, '')
    endif
    let l:line = ''
    for l:word in split(l:paragraph)
      if strlen(l:line) + strlen(l:word) + 1 > 76
        call add(l:lines, l:line)
        let l:line = ''
      endif
      let l:line ..= (empty(l:line) ? '' : ' ') .. l:word
    endfor
    call add(l:lines, l:line)
  endfor
  call append(line('.'), l:lines)
  return 1
endfunc

func! planet#prose#MarkRare(temporary) abort
  let l:word = expand('<cword>')
  if empty(l:word)
    return 0
  endif
  if !a:temporary && empty(&l:spellfile)
    let &l:spellfile = planet#paths#State('spell') .. '/personal.utf-8.add'
  endif
  execute 'spellrare' .. (a:temporary ? '! ' : ' ') .. escape(l:word, ' \|"')
  return 1
endfunc

func! planet#prose#Focus(enable) abort
  if a:enable
    if exists('s:focus')
      return 1
    endif
    if exists('s:focus_restore')
      call timer_stop(s:focus_restore.timer)
      unlet s:focus_restore
    endif
    let s:focus_generation = get(s:, 'focus_generation', 0) + 1
    let s:focus = #{window: win_getid(), size: winrestcmd(), columns: &columns, lines: &lines, global: {}, local: {},
          \ generation: s:focus_generation, windows: copy(gettabinfo(tabpagenr())[0].windows)}
    for l:option in ['guioptions', 'laststatus', 'showtabline', 'ruler', 'showmode']
      let s:focus.global[l:option] = eval('&' .. l:option)
    endfor
    for l:option in ['number', 'relativenumber', 'signcolumn', 'foldcolumn', 'colorcolumn', 'wrap', 'linebreak']
      let s:focus.local[l:option] = eval('&l:' .. l:option)
    endfor
    set guioptions-=m guioptions-=T guioptions-=r guioptions-=L laststatus=0 showtabline=0 noruler noshowmode
    setlocal nonumber norelativenumber signcolumn=no foldcolumn=0 colorcolumn= wrap linebreak
    wincmd _
    wincmd |
    return 1
  endif
  if !exists('s:focus')
    return 1
  endif
  for [l:option, l:value] in items(s:focus.global)
    execute 'let &' .. l:option .. ' = l:value'
  endfor
  " GUI widgets can resize the text grid while guioptions is restored. Put
  " the original grid back before restoring split dimensions.
  let &columns = s:focus.columns
  let &lines = s:focus.lines
  redraw!
  if win_id2tabwin(s:focus.window)[0] > 0
    for [l:option, l:value] in items(s:focus.local)
      call win_execute(s:focus.window, 'let &l:' .. l:option .. ' = ' .. string(l:value))
    endfor
    call win_execute(s:focus.window, s:focus.size)
  endif
  if has('gui_running')
    let s:focus_restore = deepcopy(s:focus)
    let s:focus_restore.attempts = 0
    let s:focus_restore.stable = 0
    let s:focus_restore.timer = timer_start(20, function('s:RestoreFocus'), #{repeat: -1})
  endif
  unlet s:focus
  return 1
endfunc

func! planet#prose#FocusPending() abort
  return exists('s:focus_restore')
endfunc

func! s:RestoreFocus(timer) abort
  if !exists('s:focus_restore') || s:focus_restore.timer != a:timer
    call timer_stop(a:timer)
    return
  endif
  let l:restore = s:focus_restore
  let l:tab = win_id2tabwin(l:restore.window)[0]
  " A new focus operation or user split/close must supersede this restore.
  if exists('s:focus') || l:restore.generation != get(s:, 'focus_generation', 0)
        \ || l:tab == 0 || gettabinfo(l:tab)[0].windows !=# l:restore.windows
    call timer_stop(a:timer)
    unlet s:focus_restore
    return
  endif
  let l:restore.attempts += 1
  if &columns != l:restore.columns || &lines != l:restore.lines
    let l:restore.stable = 0
    let &columns = l:restore.columns
    let &lines = l:restore.lines
  else
    let l:restore.stable += 1
  endif
  call win_execute(l:restore.window, l:restore.size)
  " GTK may deliver several grid resizes after the widgets are restored.
  " Keep applying the saved split sizes while those events settle, bounded to
  " one second; no callback survives a subsequent focus operation.
  if (l:restore.attempts >= 10 && l:restore.stable >= 3) || l:restore.attempts >= 50
    call timer_stop(a:timer)
    unlet s:focus_restore
  endif
endfunc

func! s:FocusResized() abort
  if exists('s:focus_restore')
    let s:focus_restore.stable = 0
  endif
endfunc

augroup PlanetVimFocusRestore
  autocmd!
  autocmd VimResized * call s:FocusResized()
augroup END

func! planet#prose#Load(package, plugin) abort
  let l:path = planet#paths#Root() .. '/.vim/pack/writing/start/' .. a:package
  if !filereadable(l:path .. '/plugin/' .. a:plugin .. '.vim')
    return s:Warn('bundled ' .. a:package .. ' is missing.')
  endif
  if stridx(',' .. &runtimepath .. ',', ',' .. l:path .. ',') < 0
    let &runtimepath = escape(l:path, ',') .. ',' .. &runtimepath
  endif
  execute 'source ' .. fnameescape(l:path .. '/plugin/' .. a:plugin .. '.vim')
  return 1
endfunc

func! planet#prose#AutoCorrect() abort
  if !exists('*AutoCorrect') && !planet#prose#Load('vim-autocorrect', 'autocorrect')
    return 0
  endif
  call AutoCorrect()
  return 1
endfunc

func! planet#prose#Proofread(category) abort
  let g:wordy_spell_dir = planet#paths#Cache('wordy')
  if stridx(',' .. &runtimepath .. ',', ',' .. g:wordy_spell_dir .. ',') < 0
    let &runtimepath ..= ',' .. escape(g:wordy_spell_dir, ',')
  endif
  if exists(':Wordy') != 2 && !planet#prose#Load('vim-wordy', 'wordy')
    return 0
  endif
  if a:category ==# 'off'
    NoWordy
  elseif a:category =~# '^[a-z-]\+$'
    " Upstream's mkspell command does not escape paths. Build the selected
    " dictionary safely in the cache, so its normal public API can reuse it.
    let l:source = g:wordy_dir .. '/data/en/' .. a:category .. '.dic'
    if !filereadable(l:source)
      return s:Warn('unknown proofreading dictionary: ' .. a:category)
    endif
    let l:spell = g:wordy_spell_dir .. '/spell'
    call mkdir(l:spell, 'p')
    let l:target = l:spell .. '/' .. a:category .. '.utf-8.spl'
    if !filereadable(l:target) || getftime(l:target) < getftime(l:source)
      execute 'mkspell! ' .. fnameescape(l:target) .. ' ' .. fnameescape(l:source)
    endif
    execute 'Wordy ' .. a:category
  else
    return s:Warn('invalid proofreading category.')
  endif
  return 1
endfunc

func! planet#prose#Grammar(action) abort
  if a:action ==# 'status'
    echom 'LanguageTool: ' .. get(g:, 'PV_languagetool_command', 'languagetool')
    echom 'Grammar results in this buffer: ' .. string(get(b:, 'grammarous_result', {}))
    return 1
  endif
  if exists(':GrammarousCheck') != 2 && !planet#prose#Load('vim-grammarous', 'grammarous')
    return 0
  endif
  if a:action ==# 'reset'
    GrammarousReset
    return 1
  endif
  let l:command = get(g:, 'PV_languagetool_command', 'languagetool')
  if type(l:command) != v:t_string || !executable(l:command)
    return s:Warn('install LanguageTool and Java or set g:PV_languagetool_command to the local executable.')
  endif
  let g:grammarous#languagetool_cmd = '"' .. escape(l:command, '"') .. '"'
  if a:action ==# 'comments'
    GrammarousCheck --comments-only
  else
    GrammarousCheck
  endif
  return 1
endfunc
