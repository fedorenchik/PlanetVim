" A refused write must not be followed by a forced quit.
let s:file = g:PV_test_dir .. '/saved.txt'
call writefile(['original'], s:file)
execute 'edit ' .. fnameescape(s:file)
call setline(1, 'unsaved')
setlocal readonly
call timer_start(10, {timer -> test_feedinput('n')})
call planet#planet#SaveExit()
call assert_equal(['original'], readfile(s:file))
call assert_equal('unsaved', getline(1))
call assert_true(&modified)
setlocal noreadonly

" A successful save clears the dirty state and preserves the exact text.
call assert_true(planet#planet#SaveAll())
call assert_equal(['unsaved'], readfile(s:file))
call assert_false(&modified)

" Failure in a second buffer must retain its edits and the editor.
enew
call setline(1, 'unnamed work')
call assert_false(planet#planet#SaveAll())
call assert_true(&modified)
call assert_equal('unnamed work', getline(1))
setlocal nomodified
execute 'file ' .. fnameescape(g:PV_test_dir .. '/missing/target.txt')
call setline(1, 'unwritable destination')
call assert_false(planet#planet#SaveAll())
call assert_equal('unwritable destination', getline(1))
call assert_true(&modified)
