set hidden
func! s:Native(path) abort
  let l:path = substitute(fnamemodify(a:path, ':p'), '[/\\]\+$', '', '')
  return has('win32') && !&shellslash ? substitute(l:path, '/', '\\', 'g') : l:path
endfunc
let &runtimepath ..= ',' .. g:PV_root .. '/.vim/pack/basic/start/vim-startify'
let g:startify_session_dir = planet#paths#State('sessions')
let g:startify_disable_at_vimenter = 1
runtime plugin/startify.vim
let &viewdir = planet#paths#State('views')
let g:PlanetVim_menus_nav = 1
let g:PlanetVim_menus_settings = 1
call planet#menu#nav#Update()
call planet#menu#settings#Update()
let s:project = g:PV_test_dir .. '/navigation project'
call mkdir(s:project, 'p')
let s:file = s:project .. '/a file.txt'
call writefile(['one', 'two', 'three', 'four'], s:file)
execute 'edit ' .. fnameescape(s:file)
setlocal filetype=text nowrap
call cursor(3, 2)

" Number validation and literal option assignment never execute input as Ex.
call planet#settings#SetTextWidth('0080')
call assert_equal(80, &l:textwidth)
try
  call planet#settings#SetTextWidth('-1')
  call assert_report('Negative text width must be rejected')
catch
  call assert_match('PlanetVim: text width', v:exception)
endtry
call planet#settings#EditOption('makeprg', 'tool --arg | literal')
call assert_equal('tool --arg | literal', &l:makeprg)

let s:options = &viewoptions
set viewoptions-=localoptions
call planet#windowview#ToggleLocalOptions()
call assert_true(index(split(&viewoptions, ','), 'localoptions') >= 0)
call planet#windowview#Save(2)
setlocal wrap
call cursor(1, 1)
call planet#windowview#Load(2)
call assert_equal(0, &l:wrap)
call assert_equal(3, line('.'))
let &viewoptions = s:options
call planet#windowview#ToggleAutoSave()
enew
call assert_equal(0, planet#windowview#Save())
execute 'buffer ' .. fnameescape(s:file)
call planet#windowview#ToggleAutoSave()

let s:ssop = &sessionoptions
let s:cwd = getcwd()
let g:PlanetFixture = 'saved global'
set sessionoptions+=globals
let s:ssop = &sessionoptions
for s:variant in ['relative', 'local', 'all', 'no-globals']
  let s:path = s:project .. '/session ' .. s:variant .. '.vim'
  call assert_equal(1, planet#session#SaveVariant(s:variant, s:path))
  call assert_equal(s:ssop, &sessionoptions)
  call assert_equal(s:cwd, getcwd())
  call assert_true(filereadable(s:path))
  let s:text = join(readfile(s:path), "\n")
  if s:variant ==# 'relative'
    call assert_match('expand("<sfile>:p:h")', s:text)
    call assert_match('a\\ file.txt', s:text)
  elseif s:variant ==# 'all'
    call assert_match('set .*', s:text)
    call assert_match('PlanetFixture', s:text)
  elseif s:variant ==# 'no-globals'
    call assert_notmatch('PlanetFixture', s:text)
  endif
  let s:contents = readfile(s:path)
  call assert_equal(0, planet#session#SaveVariant(s:variant, s:path, v:false))
  call assert_equal(s:contents, readfile(s:path))
endfor
" Saving/reopening a project session retains its full path, outside Startify.
let s:external_session = s:Native(s:project .. '/session local.vim')
let v:this_session = s:external_session
call planet#session#Save()
call assert_equal(s:external_session, v:this_session)
call assert_equal([s:external_session], readfile(planet#paths#State() .. '/last-session'))
try
  call planet#session#SaveVariant('all', s:project .. '/absent/session.vim')
  call assert_report('Session write should fail for a missing destination directory')
catch
  call assert_equal(s:ssop, &sessionoptions)
  call assert_equal(s:cwd, getcwd())
endtry

" Session launchers keep names and installed bootstrap paths as literal argv.
let g:PV_applications_dir = g:PV_test_dir .. '/applications'
let g:PV_desktop_dir = g:PV_test_dir .. '/desktop'
let s:launcher = planet#session#DesktopEntry(0, 0, s:project .. '/session all.vim')
if !has('win32')
  call assert_true(filereadable(s:launcher))
  let s:entry = join(readfile(s:launcher), "\n")
  call assert_match('scripts/planetvim.vim', s:entry)
  call assert_match('session#OpenPath', s:entry)
  call assert_match('session all.vim', s:entry)
  call assert_match('%%', planet#session#DesktopExec(['literal%value']))
  if executable('desktop-file-validate')
    call system('desktop-file-validate ' .. shellescape(s:launcher))
    call assert_equal(0, v:shell_error)
  endif
  call planet#session#DesktopEntry(1, 0, s:project .. '/session all.vim')
  call assert_false(filereadable(s:launcher))
endif

" An unsaved Unicode buffer is restored exactly, without writing its file.
call setline(1, ['edited α', 'line two'])
call deletebufline(bufnr(), 3, '$')
setlocal noendofline
call cursor(2, 3)
let s:snapshot = planet#gui#TransferSnapshot()
let s:snapshot_path = g:PV_test_dir .. '/transfer.json'
call writefile([json_encode(s:snapshot)], s:snapshot_path)
enew
call assert_equal(1, planet#gui#RestoreTransfer(s:snapshot_path))
call assert_equal(s:snapshot.lines, getline(1, '$'))
call assert_equal(1, &modified)
call assert_equal(0, &endofline)
call assert_equal(2, line('.'))
call assert_equal(['one', 'two', 'three', 'four'], readfile(s:file))
call assert_true(filereadable(s:snapshot_path .. '.ready'))
