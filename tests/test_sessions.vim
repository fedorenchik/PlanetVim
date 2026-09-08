" Tab recovery uses actual TabLeave/TabClosed events and process-isolated state.
func! s:Stage(name) abort
  call writefile([a:name], g:PV_test_dir .. '/stage.txt')
endfunc
call s:Stage('tab setup')
set hidden
execute 'source ' .. fnameescape(g:PV_root .. '/.vim/pack/planet/start/planet.vim/plugin/autocmds.vim')
execute 'cd ' .. fnameescape(g:PV_test_dir)
call mkdir(g:PV_test_dir .. '/project a', 'p')
call mkdir(g:PV_test_dir .. '/project b', 'p')
call writefile(['alpha'], g:PV_test_dir .. '/project a/a.txt')
call writefile(['one', 'two', 'three', 'four'], g:PV_test_dir .. '/project b/b.txt')
call writefile(['another window'], g:PV_test_dir .. '/project b/c.txt')
execute 'edit ' .. fnameescape(g:PV_test_dir .. '/project a/a.txt')
execute 'tcd ' .. fnameescape(g:PV_test_dir .. '/project a')
let s:original_window = win_getid()
let s:session = g:PV_test_dir .. '/full session.vim'
let v:this_session = s:session
let s:ssop = &sessionoptions
execute 'tabedit ' .. fnameescape(g:PV_test_dir .. '/project b/b.txt')
execute 'tcd ' .. fnameescape(g:PV_test_dir .. '/project b')
call cursor(3, 2)
execute 'vsplit ' .. fnameescape(g:PV_test_dir .. '/project b/c.txt')
wincmd p
let s:cursor = getcurpos()[1:2]
call planet#tab#Close()
call assert_equal('a.txt', expand('%:t'))
call assert_equal(s:ssop, &sessionoptions)
call assert_equal(s:session, v:this_session)
" Switching through another open tab must not replace the closed snapshot.
tabnew
tabprevious
call assert_equal(1, planet#tab#Reopen())
call assert_equal(['b.txt', 'c.txt'], sort(map(gettabinfo(tabpagenr())[0].windows,
      \ {_, id -> fnamemodify(bufname(winbufnr(id)), ':t')})))
call assert_equal('b.txt', expand('%:t'))
call assert_equal(s:cursor, getcurpos()[1:2])
call assert_equal(g:PV_test_dir .. '/project b', getcwd())
call assert_equal(g:PV_test_dir, getcwd(-1))
call assert_equal(g:PV_test_dir .. '/project a', getcwd(win_id2tabwin(s:original_window)[1], win_id2tabwin(s:original_window)[0]))
call assert_equal(s:ssop, &sessionoptions)
call assert_equal(s:session, v:this_session)
let s:directories = globpath(planet#paths#State('tabs'), '*', 0, 1)
call assert_equal(1, len(s:directories))
call assert_match('/' .. getpid() .. '-', s:directories[0])
call s:Stage('native tab recovery')

" Newer Vim builds also preserve every split when using native :tabclose.
if exists('##TabClosedPre')
  tabclose
  call planet#tab#Reopen()
  call assert_equal(['b.txt', 'c.txt'], sort(map(gettabinfo(tabpagenr())[0].windows,
        \ {_, id -> fnamemodify(bufname(winbufnr(id)), ':t')})))
endif

let s:tabs = tabpagenr('$')
call s:Stage('tab error recovery')
let s:window = win_getid()
call assert_equal(0, planet#tab#SaveTo(''))
try
  call planet#tab#OpenFrom(g:PV_test_dir .. '/missing.tab.vim')
  call assert_report('A missing snapshot should be rejected')
catch /saved tab does not exist/
endtry
call assert_equal(s:tabs, tabpagenr('$'))
call assert_equal(s:window, win_getid())
call writefile(['let &sessionoptions = "blank"', "throw 'broken snapshot'"], g:PV_test_dir .. '/broken.tab.vim')
try
  call planet#tab#OpenFrom(g:PV_test_dir .. '/broken.tab.vim')
  call assert_report('A malformed snapshot should be rejected')
catch /could not restore tab/
endtry
call assert_equal(s:tabs, tabpagenr('$'))
call assert_equal(s:window, win_getid())
call assert_equal(s:ssop, &sessionoptions)
call assert_equal(s:session, v:this_session)
try
  call planet#tab#SaveTo(g:PV_test_dir .. '/missing-parent/file.tab.vim')
  call assert_report('Saving to a missing directory should fail')
catch
endtry
call assert_equal(s:ssop, &sessionoptions)
call assert_equal(s:session, v:this_session)

" An explicitly saved tab also restores without replacing the full session.
call s:Stage('saved tab roundtrip')
call planet#tab#SaveTo(g:PV_test_dir .. '/saved tab.tab.vim')
call planet#tab#OpenFrom(g:PV_test_dir .. '/saved tab.tab.vim')
call assert_equal(s:session, v:this_session)
call assert_equal(s:ssop, &sessionoptions)

" Exercise actual Startify persistence; all session state remains under /tmp.
call s:Stage('Startify setup')
let g:startify_session_dir = planet#paths#State('sessions')
let g:startify_session_persistence = 0
let g:startify_disable_at_vimenter = 1
execute 'set runtimepath+=' .. fnameescape(g:PV_root .. '/.vim/pack/basic/start/vim-startify')
runtime plugin/startify.vim
call mkdir(g:PV_test_dir .. '/session name with spaces', 'p')
execute 'cd ' .. fnameescape(g:PV_test_dir .. '/session name with spaces')
let v:this_session = ''
call s:Stage('Startify save')
call planet#session#Save()
let s:saved_session = g:startify_session_dir .. '/session name with spaces'
call assert_true(filereadable(s:saved_session))
call assert_equal(s:saved_session, v:this_session)
call assert_false(empty(menu_info('📚s.Open Session.session name with spaces')))
call planet#session#MenuList()
call assert_false(empty(menu_info('📚s.Current: session name with spaces')))
call setline(1, 'unsaved edit')
try
  call planet#session#Load('session name with spaces')
  call assert_report('Opening a session must not discard modified buffers')
catch /save or discard modified buffers/
endtry
call assert_equal('unsaved edit', getline(1))
setlocal nomodified
call s:Stage('Startify load')
call planet#session#Load('session name with spaces')
call assert_equal(s:saved_session, v:this_session)
call planet#tab#Cleanup()
call s:Stage('complete')
call assert_equal([], globpath(planet#paths#State('tabs'), '*', 0, 1))
