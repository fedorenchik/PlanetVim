" Automatic directory sessions and manual native files share one owner.
runtime plugin/globals.vim
set hidden sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
let s:home = $HOME
let $HOME = g:PV_test_dir .. '/home'
call mkdir($HOME, 'p')
let g:PV_sessions_dir = g:PV_test_dir .. '/managed sessions'
let s:first = g:PV_test_dir .. '/one/project'
let s:second = g:PV_test_dir .. '/two/project'
for s:root in [s:first, s:second]
  call mkdir(s:root, 'p')
  call writefile(['one', 'two', 'three'], s:root .. '/main.txt')
endfor
call assert_notequal(planet#session#PathForDirectory(s:first), planet#session#PathForDirectory(s:second))
if has('unix')
  call system('ln -s ' .. shellescape(s:first) .. ' ' .. shellescape(g:PV_test_dir .. '/alias'))
  call assert_equal(planet#session#PathForDirectory(s:first), planet#session#PathForDirectory(g:PV_test_dir .. '/alias'))
endif

execute 'cd ' .. fnameescape(s:first)
call planet#session#Init()
call planet#session#Startup()
let s:auto = planet#session#PathForDirectory(s:first)
call assert_equal(s:auto, v:this_session)
call assert_equal(0, planet#session#AutoSave(), 'welcome/empty buffers alone are not saved')
execute 'edit ' .. fnameescape(s:first .. '/main.txt')
call cursor(3, 2)
vsplit
redraw
call assert_equal(1, planet#session#AutoSave())
call assert_true(filereadable(s:auto))
call assert_equal(s:auto, planet#session#Recent()[0].file)
call assert_equal(s:first, planet#session#Recent()[0].root)
call assert_equal([], glob(g:PV_sessions_dir .. '/.*.tmp.vim', 0, 1))

" Restore the directory without changing buffers via tab-switch handlers.
call planet#session#Close()
call planet#session#Init()
call planet#session#Startup()
call assert_equal(s:auto, v:this_session)
call assert_equal(2, winnr('$'))
call assert_equal('main.txt', expand('%:t'))
call assert_equal([3, 2], getcurpos()[1:2])
call planet#session#Close()
unlet! g:startify_disable_at_vimenter

" Manually chosen paths become the next automatic destination and MRU entry.
execute 'cd ' .. fnameescape(s:first)
execute 'edit ' .. fnameescape(s:first .. '/main.txt')
let s:external = g:PV_test_dir .. "/chosen 'name' | session.vim"
let s:external = planet#session#PathForFile(s:external)
call assert_equal(1, planet#session#SaveAs(s:external))
call cursor(2, 1)
call assert_equal(1, planet#session#AutoSave())
call assert_equal(s:external, v:this_session)
call assert_equal(s:external, planet#session#Recent()[0].file)
call assert_match("chosen 'name'", planet#session#StartifyList()[0].line)
let s:entry = planet#session#StartifyList()[0]
execute s:entry.cmd
call assert_equal(s:external, v:this_session)
call assert_equal(2, line('.'))
call planet#session#Close()
call planet#session#Init()
call planet#session#Startup()
call assert_equal(s:external, v:this_session, 'directory remembers external Save As')

" Loading another session cannot discard changed text.
call setline(1, 'unsaved')
try
  call planet#session#OpenPath(s:auto)
  call assert_report('modified buffers must block session loading')
catch /save or discard modified buffers/
endtry
call assert_equal('unsaved', getline(1))
setlocal nomodified
let s:contents = readfile(s:external)
try
  call planet#session#SaveAs(g:PV_test_dir .. '/missing/session.vim')
  call assert_report('saving into a missing directory must fail')
catch /PlanetVim:/
endtry
call assert_equal(s:external, v:this_session)
call assert_equal(s:contents, readfile(s:external))
call planet#session#Close()
unlet! g:startify_disable_at_vimenter

" HOME stays unmanaged even with a previous manually saved home session.
execute 'cd ' .. fnameescape($HOME)
call planet#session#Init()
call planet#session#Startup()
call assert_equal('', v:this_session)
execute 'edit ' .. fnameescape(s:first .. '/main.txt')
call assert_equal(0, planet#session#AutoSave())
call planet#session#Save()
let s:home_session = v:this_session
call assert_true(filereadable(s:home_session))
call assert_equal(1, planet#session#AutoSave())
call planet#session#Close()
call planet#session#Init()
call planet#session#Startup()
call assert_equal('', v:this_session)

" A native :mksession explicitly opts HOME in too.
execute 'edit ' .. fnameescape(s:second .. '/main.txt')
let s:native = g:PV_test_dir .. '/native session.vim'
execute 'mksession! ' .. fnameescape(s:native)
call assert_equal(1, planet#session#AutoSave())
let s:native = planet#session#PathForFile(s:native)
call assert_equal(s:native, planet#session#Recent()[0].file)
call planet#session#Close()

" A failed restore must never overwrite the broken file with a partial layout.
let s:broken = g:PV_test_dir .. '/broken.vim'
call writefile(['let g:SessionLoad = 1', 'let v:this_session = expand("<sfile>:p")', "throw 'broken session'"], s:broken)
try
  call planet#session#OpenPath(s:broken)
  call assert_report('broken session should raise')
catch /broken session/
endtry
call assert_equal('', v:this_session)
call assert_equal(0, planet#session#AutoSave())
call assert_false(exists('g:SessionLoad'))
call delete(s:native)
call assert_equal([], filter(planet#session#Recent(), 'v:val.file ==# s:native'))

" Save variants retain their policy during later automatic writes and reloads.
call planet#session#OpenPath(s:external)
let g:PlanetSessionFixture = 'do not save'
set sessionoptions+=globals
let s:variant = g:PV_test_dir .. '/no globals.vim'
let s:variant = planet#session#PathForFile(s:variant)
call planet#session#SaveVariant('no-globals', s:variant, v:true)
call planet#session#AutoSave()
call assert_notmatch('PlanetSessionFixture', join(readfile(s:variant), "\n"))
call planet#session#Close()
call planet#session#OpenPath(s:variant)
call planet#session#AutoSave()
call assert_notmatch('PlanetSessionFixture', join(readfile(s:variant), "\n"))
let s:before_close = getcwd(-1)
call planet#session#Close(v:true)
call assert_equal($HOME, getcwd(-1))
call assert_equal('', v:this_session)
call planet#session#OpenPath(s:variant)
call assert_equal(s:before_close, getcwd(-1), 'Close Everything saves the project before returning home')
let $HOME = s:home
