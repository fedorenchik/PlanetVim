new
call setline(1, ['one  ', 'two\t', 'three'])
let @/ = 'preserve search'
call cursor(2, 2)
let s:view = winsaveview()
call planet#editing#TrimWhitespace()
call assert_equal('one', getline(1))
call assert_equal('preserve search', @/)
call assert_equal(s:view.lnum, line('.'))
call assert_equal(1, planet#editing#Percentage('100'))
call assert_equal(3, line('.'))
call assert_equal(0, planet#editing#Percentage('101'))
call assert_equal(0, planet#editing#Percentage(''))
call assert_equal(1, planet#editing#Percentage(0))
call assert_equal(1, line('.'))

call setline(1, 'prefix selected suffix')
normal! gg07lv7l
execute "normal! \<Esc>"
call assert_equal(1, planet#editing#SubstituteSelection('selected', 'done'))
call assert_equal('prefix done suffix', getline(1))
call setline(1, 'prefix selected suffix')
normal! gg07lv7l
execute "normal! \<Esc>"
call planet#editing#SubstituteSelection('selected suffix', 'bad')
call assert_equal('prefix selected suffix', getline(1), 'match cannot escape selected range')
call planet#editing#SubstituteSelection('selected', '')
call assert_equal('prefix  suffix', getline(1), 'empty replacement is supported')
call setline(3, 'three')
normal! 3G0v4l
if !has('gui_running')
  " Ex mode reports command-line mode even after :normal v. Publish the marks
  " here; the GUI run exercises the live Visual selection used by <Cmd> menus.
  execute "normal! \<Esc>"
endif
call planet#editing#SubstituteSelection('three', 'THREE')
call assert_equal('THREE', getline(3), 'the active selection replaces stale marks')

let s:directory = g:PV_test_dir .. '/temporary 工作'
call mkdir(s:directory)
let s:cwd = getcwd()
let s:scope = haslocaldir()
call assert_equal(0, planet#editing#TemporaryDirectory(0, ''))
call assert_equal(0, planet#editing#TemporaryDirectory(0, s:directory .. '/missing'))
call assert_equal(1, planet#editing#TemporaryDirectory(0, s:directory))
call assert_equal(substitute(fnamemodify(s:directory, ':p'), '\\', '/', 'g'), substitute(fnamemodify(getcwd(), ':p'), '\\', '/', 'g'))
split
call assert_equal(s:cwd, getcwd())
close
call assert_equal(s:cwd, getcwd())
call assert_equal(s:scope, haslocaldir())

let s:file = g:PV_test_dir .. '/autosave.txt'
call writefile(['before'], s:file)
execute 'edit! ' .. fnameescape(s:file)
call assert_equal(1, planet#editing#AutoSaveToggle())
call setline(1, 'saved')
doautocmd InsertLeave
call assert_equal(['saved'], readfile(s:file))
setlocal readonly
call setline(1, 'unsaved')
doautocmd FocusLost
call assert_equal(['saved'], readfile(s:file))
call assert_true(&modified)
setlocal noreadonly
call assert_equal(0, planet#editing#AutoSaveToggle())
doautocmd FocusLost
call assert_equal(['saved'], readfile(s:file))
