" Native state must follow the session, including already-open file buffers.
runtime plugin/globals.vim
runtime plugin/settings.vim
set hidden nomore nolazyredraw updatecount=1 backupskip=
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
set viminfo=!,%50,'100,<50,s10,h
let s:global = [&directory, &backupdir, &undodir, &viewdir, &viminfofile]
let s:file = g:PV_test_dir .. '/same file.txt'
call writefile(['original'], s:file)
execute 'edit ' .. fnameescape(s:file)
call setline(1, 'global edit')
write
let s:global_undo = undofile(s:file)
let s:global_swap = swapname(bufnr())
call assert_true(filereadable(s:global_undo))
call assert_true(filereadable(s:global_swap))
call histadd('cmd', 'echo "global-history"')
let @g = 'global register'
normal! mG

let s:main_buffer = bufnr()
let s:hidden_file = g:PV_test_dir .. '/hidden.txt'
call writefile(['hidden original'], s:hidden_file)
execute 'edit ' .. fnameescape(s:hidden_file)
setlocal noswapfile
call setline(1, 'hidden edit')
write
let s:hidden_buffer = bufnr()
execute 'buffer ' .. s:main_buffer
if exists('+winfixbuf') | set winfixbuf | endif

let s:chosen = g:PV_test_dir .. "/A's, work.vim"
call planet#session#SaveAs(s:chosen)
let s:a = planet#session#PathForFile(s:chosen)
let s:a_dir = fnamemodify(s:a, ':h')
call assert_equal(s:a, v:this_session)
call assert_false(filereadable(s:chosen), 'new Save As creates only the container')
call assert_equal(s:a_dir .. '/viminfo', &viminfofile)
call assert_equal(s:a_dir .. '/views', &viewdir)
call assert_true(stridx(swapname(bufnr()), s:a_dir .. '/swap/') == 0)
call assert_false(filereadable(s:global_swap), 'old swap is removed after relocating')
call assert_true(filereadable(swapname(bufnr())))
let s:a_undo = undofile(s:file)
call assert_true(stridx(s:a_undo, s:a_dir .. '/undo/') == 0)
call assert_true(filereadable(s:a_undo), 'Save As copies current undo to its own file')
call assert_notequal(s:global_undo, s:a_undo)
call assert_true(filereadable(undofile(s:hidden_file)), 'Save As copies hidden-buffer undo')
call assert_equal(0, getbufvar(s:hidden_buffer, '&swapfile'))
call assert_equal(s:main_buffer, bufnr())
if exists('+winfixbuf')
  call assert_true(&winfixbuf)
  set nowinfixbuf
endif
call setline(1, 'session A edit')
write
call assert_false(empty(readdir(s:a_dir .. '/backup')))
mkview
call assert_false(empty(readdir(s:a_dir .. '/views')))
call histadd('cmd', 'echo "only-session-A"')
let @a = 'register A'
normal! mA
call planet#session#AutoSave()
let s:a_info = readfile(&viminfofile)
let s:a_undo_bytes = readblob(s:a_undo)
call assert_match('only-session-A', join(s:a_info, "\n"))
call assert_equal(s:a_dir .. '/task-logs', planet#paths#SessionState('task-logs'))
call planet#session#Close()
call assert_equal(s:global, [&directory, &backupdir, &undodir, &viewdir, &viminfofile])
call assert_equal('global register', @g)
call assert_equal('', @a, 'session registers do not leak to global editing')
call assert_notmatch('only-session-A', execute('history cmd'))
call assert_equal(0, getpos("'A")[1])

" A separate session for the same file must not read global or A's undo.
let s:b = planet#session#PathForFile(g:PV_test_dir .. '/B.vim')
call planet#session#SaveAs(s:b)
execute 'edit ' .. fnameescape(s:file)
call assert_equal(0, undotree().seq_last)
call assert_equal('', @a)
call histadd('cmd', 'echo "only-session-B"')
let @b = 'register B'
normal! mB
call setline(1, 'session B edit')
write
let s:b_undo = undofile(s:file)
call assert_true(filereadable(s:b_undo))
call assert_notequal(s:a_undo, s:b_undo)
call assert_equal(s:a_undo_bytes, readblob(s:a_undo), 'B cannot overwrite A undo')
" Return the file contents to A's saved version so A's undo checksum matches.
undo
write
call planet#session#AutoSave()
call planet#session#OpenPath(s:a)
call assert_equal('register A', @a)
call assert_equal('', @b)
call assert_match('only-session-A', execute('history cmd'))
call assert_notmatch('only-session-B', execute('history cmd'))
call assert_notequal(0, getpos("'A")[1])
call assert_equal(0, getpos("'B")[1])
call assert_true(stridx(swapname(bufnr()), s:a_dir .. '/swap/') == 0)
undo
call assert_equal('global edit', getline(1), 'reopening A restores A undo tree')
setlocal nomodified
call planet#session#Close()

" A failed restore returns all persistence options to the global scope.
let s:broken = g:PV_test_dir .. '/broken.vim'
call writefile(["throw 'fixture broken'"], s:broken)
try
  call planet#session#OpenPath(s:broken)
  call assert_report('broken restore should fail')
catch /fixture broken/
endtry
call assert_equal('', v:this_session)
call assert_equal(s:global, [&directory, &backupdir, &undodir, &viewdir, &viminfofile])
call assert_equal(planet#paths#State('tabs'), planet#paths#SessionState('tabs'))

" Import a native flat session and keep its original path usable with :source.
execute 'edit ' .. fnameescape(s:file)
let s:old = g:PV_test_dir .. '/native.vim'
execute 'mksession! ' .. fnameescape(s:old)
let s:original = readfile(s:old)
call planet#session#OpenPath(s:old)
let s:imported = planet#session#PathForFile(s:old)
call assert_equal(s:imported, v:this_session)
call assert_equal(s:original, readfile(fnamemodify(s:imported, ':h') .. '/previous-session.vim'))
call planet#session#Close()
execute 'source ' .. fnameescape(s:old)
call assert_equal(s:imported, v:this_session)
call assert_equal(fnamemodify(s:imported, ':h') .. '/viminfo', &viminfofile)

" Capturing all options cannot restore the prior owner's storage paths.
let s:all = planet#session#PathForFile(g:PV_test_dir .. '/all options.vim')
call planet#session#SaveVariant('all', s:all, v:true)
call planet#session#Close()
call planet#session#OpenPath(s:all)
call assert_equal(fnamemodify(s:all, ':h') .. '/viminfo', &viminfofile)
call assert_true(stridx(undofile(s:file), fnamemodify(s:all, ':h') .. '/undo/') == 0)
call assert_true(stridx(swapname(bufnr()), fnamemodify(s:all, ':h') .. '/swap/') == 0)

" Legacy option capture must also be isolated before its first buffer read.
call planet#session#Close()
execute 'edit ' .. fnameescape(s:file)
set sessionoptions+=options
let s:old_all = g:PV_test_dir .. '/legacy all.vim'
execute 'mksession! ' .. fnameescape(s:old_all)
call writefile(['let g:PlanetSessionExtra = get(g:, "PlanetSessionExtra", 0) + 1'],
      \ fnamemodify(s:old_all, ':r') .. 'x.vim')
augroup PlanetTestStorage
  autocmd!
  autocmd BufReadPre * let g:PlanetReadUndoDir = &undodir
augroup END
call planet#session#OpenPath(s:old_all)
call assert_match('legacy all.session/undo', g:PlanetReadUndoDir)
call assert_equal(1, g:PlanetSessionExtra)
call planet#session#Close()
call planet#session#OpenPath(s:old_all)
call assert_equal(2, g:PlanetSessionExtra, 'native extra configuration survives import')
augroup PlanetTestStorage
  autocmd!
augroup END
