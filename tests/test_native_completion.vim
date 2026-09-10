aunmenu *
silent! tlunmenu *
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call planet#planet#SetStandardMode()
set noinsertmode
call planet#completion#Engine('off')
call assert_equal(0, g:asyncomplete_auto_popup)
if exists('+autocomplete') | call assert_equal(0, &autocomplete) | endif
call assert_equal(1, planet#completion#Engine('asyncomplete'))
call assert_equal(1, b:asyncomplete_enable)
if exists('+autocomplete')
  call assert_equal(1, planet#completion#Engine('native'))
  call assert_equal(1, &autocomplete)
  call assert_equal(0, g:asyncomplete_auto_popup)
  new
  call assert_equal(0, b:asyncomplete_enable)
  close
else
  call assert_equal(0, planet#completion#Engine('native'))
endif
call planet#completion#Engine('off')
let s:old = &completeopt
call assert_equal(0, planet#preferences#Set('completeopt', 'not-a-real-option'))
call assert_equal(s:old, &completeopt)
call planet#completion#Preset('preinsert')
if index(split(&completeopt, ','), 'preinsert') >= 0
  call assert_notmatch('fuzzy\|noselect\|noinsert', &completeopt)
endif
call planet#completion#Preset('fuzzy')
if index(split(&completeopt, ','), 'fuzzy') >= 0 | call assert_notmatch('preinsert', &completeopt) | endif
call planet#completion#Preset('standard')
set wildoptions=tagfile
call assert_equal(1, planet#preferences#Flag('wildoptions', 'pum'))
call assert_match('tagfile', &wildoptions)
call assert_match('pum', &wildoptions)
call assert_equal(1, planet#preferences#Flag('wildoptions', 'fuzzy'))
call assert_match('tagfile', &wildoptions)
call assert_match('fuzzy', &wildoptions)
call assert_true(planet#preferences#Valid({'wildoptions': 'pum'}))
call assert_false(planet#preferences#Valid({'shell': 'evil'}))
call setline(1, ['unique completion line', 'unique'])
call cursor(2, 6)
execute 'inoremap <F11> ' .. menu_info('📝e.Complete.Whole\ lines', 'i').rhs
call feedkeys("a\<F11>\<C-n>\<C-y>\<Esc>", 'xt')
call assert_equal('unique completion line', getline(2))
iunmap <F11>
let &l:dictionary = ''
call assert_equal(0, planet#completion#Start('dictionary'))
let s:dict = g:PV_test_dir .. '/dictionary.txt'
call writefile(['zebratest'], s:dict)
let &l:dictionary = s:dict
call setline(2, 'zebr')
call cursor(2, 4)
execute 'inoremap <F11> ' .. menu_info('📝e.Complete.Dictionary', 'i').rhs
call feedkeys("a\<F11>\<C-n>\<C-y>\<Esc>", 'xt')
call assert_equal('zebratest', getline(2))
iunmap <F11>
call writefile([''], g:PV_test_dir .. '/uniquefile.txt')
execute 'lcd ' .. fnameescape(g:PV_test_dir)
call setline(2, 'uniquefile')
call cursor(2, 10)
execute 'inoremap <F11> ' .. menu_info('📝e.Complete.Filename', 'i').rhs
call feedkeys("a\<F11>\<C-n>\<C-y>\<Esc>", 'xt')
call assert_equal('uniquefile.txt', getline(2))
iunmap <F11>
