runtime plugin/prose.vim
enew
let s:registers = {'z': getreginfo('z'), '0': getreginfo('0'), '"': getreginfo('"')}
call setline(1, ['First, second! Third.', 'fourth word.'])
call cursor(1, 9)
call assert_equal(1, planet#prose#Swap(-1))
call assert_equal(['second, First! Third.', 'fourth word.'], getline(1, '$'))
call assert_equal('second', expand('<cword>'), 'cursor follows moved word')
call assert_equal(1, planet#prose#Swap(1))
call assert_equal(['First, second! Third.', 'fourth word.'], getline(1, '$'))
call cursor(2, 2)
call assert_equal(1, planet#prose#Swap(-1))
call assert_equal(['First, second! fourth.', 'Third word.'], getline(1, '$'))
call setline(1, ["don't, stop! 工作", ''])
call cursor(1, 9)
call assert_equal(1, planet#prose#Swap(-1))
call assert_equal("stop, don't! 工作", getline(1))
call cursor(1, 1)
call assert_equal(0, planet#prose#Swap(-1))
for s:register in keys(s:registers)
  call assert_equal(s:registers[s:register], getreginfo(s:register), 'swap preserves register ' .. s:register)
endfor

let s:thesaurus = g:PV_test_dir .. '/synonyms 工作, one.txt'
call writefile(['clear lucid understandable', 'quick fast swift'], s:thesaurus)
call assert_equal(0, planet#prose#Thesaurus(''))
call assert_equal(0, planet#prose#Thesaurus(s:thesaurus .. '.missing'))
call assert_equal(1, planet#prose#Thesaurus(s:thesaurus))
call assert_equal(escape(s:thesaurus, ',\'), &l:thesaurus)
call setline(1, 'clear')
call cursor(1, 2)
call planet#prose#Complete()
call feedkeys("\<C-n>\<C-y>\<Esc>", 'xt')
call assert_match('\v^(lucid|understandable)$', getline(1), 'native thesaurus completion reads the configured file: ' .. execute('messages'))
call assert_equal(0, planet#prose#Sample(0))
call assert_equal(0, planet#prose#Sample(101))
let s:before = line('$')
call assert_equal(1, planet#prose#Sample(2))
call assert_true(line('$') > s:before + 2)

let s:globals = {}
for s:option in ['guioptions', 'laststatus', 'showtabline', 'ruler', 'showmode']
  let s:globals[s:option] = eval('&' .. s:option)
endfor
let s:local = {}
for s:option in ['number', 'relativenumber', 'signcolumn', 'foldcolumn', 'colorcolumn', 'wrap', 'linebreak']
  let s:local[s:option] = eval('&l:' .. s:option)
endfor
vsplit
let s:count = winnr('$')
let s:window = win_getid()
let s:sizes = map(getwininfo(), {_, w -> [w.winid, w.width, w.height]})
call assert_equal(1, planet#prose#Focus(v:true))
call assert_equal(0, &number)
call assert_equal(0, &laststatus)
call assert_equal(1, planet#prose#Focus(v:true))
call assert_equal(1, planet#prose#Focus(v:false))
call assert_equal(1, planet#prose#Focus(v:false))
for s:attempt in range(200)
  if !planet#prose#FocusPending() | break | endif
  sleep 10m
endfor
call assert_false(planet#prose#FocusPending(), 'GUI layout restoration must finish')
call assert_equal(s:count, winnr('$'))
for s:option in keys(s:globals)
  call assert_equal(s:globals[s:option], eval('&' .. s:option), 'focus restores ' .. s:option)
endfor
for s:option in keys(s:local)
  call assert_equal(s:local[s:option], eval('&l:' .. s:option), 'focus restores ' .. s:option)
endfor
call assert_equal(s:sizes, map(getwininfo(), {_, w -> [w.winid, w.width, w.height]}))
" A new focus operation cancels the older GUI resize callback.
call planet#prose#Focus(v:true)
call planet#prose#Focus(v:false)
call planet#prose#Focus(v:true)
sleep 100m
call assert_equal(0, &laststatus)
call assert_false(planet#prose#FocusPending())
call planet#prose#Focus(v:false)
for s:attempt in range(200)
  if !planet#prose#FocusPending() | break | endif
  sleep 10m
endfor
call assert_equal(1, planet#prose#AutoCorrect())
call assert_equal('the', maparg('teh', 'i', 1))
let g:PV_cache_dir = g:PV_test_dir .. '/cache with spaces 工作'
call assert_equal(1, planet#prose#Proofread('weak'))
call assert_equal(planet#paths#Cache('wordy'), g:wordy_spell_dir)
call assert_true(filereadable(g:wordy_spell_dir .. '/spell/weak.utf-8.spl'))
call assert_false(filereadable(g:PV_root .. '/.vim/pack/writing/start/vim-wordy/spell/weak.utf-8.spl'))
call assert_equal(1, planet#prose#Proofread('off'))
let g:PV_languagetool_command = 'planetvim_missing_languagetool'
call assert_equal(0, planet#prose#Grammar('check'))
let g:PlanetVim_menus_tools = 1
call planet#menu#tools#Update()
call assert_match('planet#prose#Swap(-1)', menu_info('🔤\..Swap Words', 'n').rhs)
call assert_match('planet#translation#Translate', menu_info('🔤\..Translation.Translate', 'v').rhs)
