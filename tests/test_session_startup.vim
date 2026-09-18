" Real separate instances exercise VimEnter ordering, exit saves and Startify.
if !has('gui_running')
  let g:PV_test_skip = 'Session startup round trips require GUI processes.'
  finish
endif
let s:home = g:PV_test_dir .. '/home'
let s:folder = g:PV_test_dir .. '/folder'
call mkdir(s:home, 'p')
call mkdir(s:folder, 'p')
call writefile(['one', 'two', 'three'], s:folder .. '/one.txt')
call writefile(['another file'], s:folder .. '/two.txt')
let s:external = g:PV_test_dir .. '/named workspace'
let s:external = planet#session#PathForFile(s:external)
let s:counter = 0
func! s:Run(cwd, checks, args = [], after = 'qa!', interval = 30000) abort
  let s:counter += 1
  let l:base = g:PV_test_dir .. '/child-' .. s:counter
  let l:result = l:base .. '.result'
  let l:script = [
        \ 'set nomore guioptions+=c',
        \ 'let g:PV_session_interval = ' .. a:interval,
        \ 'let g:PV_clangd_argv = []',
        \ 'let g:PV_pylsp_argv = []',
        \ 'autocmd BufReadPre * let g:PlanetStartupUndoDir = &undodir',
        \ 'function! PlanetSessionCheck(timer) abort',
        \ '  try',
        \ '    set noinsertmode',
        \ ] + a:checks + [
        \ '  catch',
        \ '    call add(v:errors, v:exception .. " at " .. v:throwpoint)',
        \ '  endtry',
        \ '  call writefile(v:errors, ' .. string(l:result) .. ')',
        \ '  ' .. a:after,
        \ 'endfunction',
        \ 'autocmd VimEnter * call timer_start(100, function("PlanetSessionCheck"))',
        \ ]
  call writefile(l:script, l:base .. '.vim')
  let l:env = #{HOME:s:home, VIMINIT:'', EXINIT:'', GVIMINIT:'', PLANETVIM_ROOT:g:PV_root,
        \ PLANETVIM_CONFIG_DIR:g:PV_config_dir, PLANETVIM_STATE_DIR:g:PV_state_dir,
        \ PLANETVIM_CACHE_DIR:g:PV_cache_dir, PLANETVIM_SESSIONS_DIR:g:PV_test_dir .. '/sessions'}
  let l:command = [g:PV_test_gvim, '-f', '-n', '-i', 'NONE', '-U', 'NONE',
        \ '--cmd', 'source ' .. fnameescape(l:base .. '.vim'),
        \ '-u', g:PV_root .. '/scripts/planetvim.vim'] + a:args
  let l:job = job_start(l:command, #{cwd:a:cwd, env:l:env, out_io:'file', out_name:l:base .. '.log', err_io:'out'})
  for l:attempt in range(1200)
    if job_status(l:job) !=# 'run' | break | endif
    sleep 10m
  endfor
  if job_status(l:job) ==# 'run'
    call job_stop(l:job, 'kill')
    call assert_report('child ' .. s:counter .. ' timed out')
  endif
  call assert_true(filereadable(l:result), 'child ' .. s:counter .. ' produced a result')
  if filereadable(l:result)
    for l:error in readfile(l:result)
      call assert_report('child ' .. s:counter .. ': ' .. l:error)
    endfor
  endif
  call assert_equal(a:after ==# 'cquit!' ? 1 : 0, get(job_info(l:job), 'exitval', -1))
endfunc

" Initial viminfo must be selected before Vim reads it, not at VimEnter.
call s:Run(s:home, [
      \ 'let @z = "global-only register"',
      \ 'call histadd("cmd", "echo global-only-history")',
      \ ])

" A first folder launch displays welcome, then normal exit saves its layout.
call s:Run(s:folder, [
      \ 'call assert_equal("startify", &filetype)',
      \ 'call assert_equal(planet#session#PathForDirectory(getcwd(-1)), v:this_session)',
      \ 'call assert_equal("", @z)',
      \ 'call assert_notmatch("global-only-history", execute("history cmd"))',
      \ 'call assert_equal(fnamemodify(v:this_session, ":h") .. "/viminfo", &viminfofile)',
      \ 'let @a = "session-only register"',
      \ 'call histadd("cmd", "echo session-only-history")',
      \ 'edit one.txt',
      \ 'normal! 3G',
      \ 'vsplit two.txt',
      \ ])
let s:auto = planet#session#PathForDirectory(s:folder)
call assert_true(filereadable(s:auto), 'normal exit saves automatically')
call assert_equal(g:PV_test_dir .. '/sessions/folder.session/session.vim', s:auto)

" A namesake folder must never read the first project's snapshot or viminfo.
let s:namesake = g:PV_test_dir .. '/other/folder'
call mkdir(s:namesake, 'p')
let s:before_collision = readfile(s:auto)
call s:Run(s:namesake, [
      \ 'call assert_equal("", v:this_session)',
      \ 'call assert_equal(' .. string(s:namesake) .. ', getcwd(-1))',
      \ 'call assert_equal("global-only register", @z)',
      \ 'call assert_equal("", @a)',
      \ 'call assert_equal("", get(g:, "PV_session_state_dir", ""))',
      \ 'call assert_match("already in use.*Save As", execute("messages"))',
      \ 'call assert_equal(0, planet#session#AutoSave())',
      \ ])
call assert_equal(s:before_collision, readfile(s:auto))

" A crash before the first snapshot still reserves the directory's name/state.
let s:welcome = g:PV_test_dir .. "/one/项目 'welcome' | folder"
let s:other_welcome = g:PV_test_dir .. "/two/项目 'welcome' | folder"
call mkdir(s:welcome, 'p')
call mkdir(s:other_welcome, 'p')
let s:welcome_session = planet#session#PathForDirectory(s:welcome)
call s:Run(s:welcome, [
      \ 'call assert_equal(' .. string(s:welcome_session) .. ', v:this_session)',
      \ ], [], 'cquit!')
call assert_false(filereadable(s:welcome_session))
call s:Run(s:other_welcome, [
      \ 'call assert_equal("", v:this_session)',
      \ 'call assert_equal("global-only register", @z)',
      \ 'call assert_match("already in use.*Save As", execute("messages"))',
      \ ])
call s:Run(s:welcome, [
      \ 'call assert_equal(' .. string(s:welcome_session) .. ', v:this_session)',
      \ 'call assert_equal("", @z)',
      \ 'edit example.txt',
      \ ])
call assert_true(filereadable(s:welcome_session))
call s:Run(s:welcome, [
      \ 'call assert_equal(' .. string(s:welcome_session) .. ', v:this_session)',
      \ 'call assert_equal("example.txt", expand("%:t"))',
      \ ])

call s:Run(s:folder, [
      \ 'call assert_equal(2, winnr("$"))',
      \ 'call assert_equal("two.txt", expand("%:t"))',
      \ 'call assert_notequal("startify", &filetype)',
      \ 'call assert_equal(' .. string(s:folder) .. ', getcwd(-1))',
      \ 'call assert_equal("session-only register", @a)',
      \ 'call assert_equal("", @z)',
      \ 'call assert_match("session-only-history", execute("history cmd"))',
      \ 'call planet#session#SaveAs(' .. string(s:external) .. ')',
      \ 'only',
      \ 'edit one.txt',
      \ 'normal! 2G',
      \ ])
let s:original = readfile(s:auto)
call assert_true(filereadable(s:external))
call s:Run(s:folder, [
      \ 'call assert_equal(' .. string(s:external) .. ', v:this_session)',
      \ 'call assert_equal(1, winnr("$"))',
      \ 'call assert_equal("one.txt", expand("%:t"))',
      \ 'call assert_equal(2, line("."))',
      \ ])
call assert_equal(s:original, readfile(s:auto), 'Save As is never redirected into the managed directory')

" HOME starts unmanaged, with recent sessions visible and executable.
call s:Run(s:home, [
      \ 'call assert_equal("", v:this_session)',
      \ 'call assert_equal("startify", &filetype)',
      \ 'call assert_equal("global-only register", @z)',
      \ 'call assert_equal("", @a)',
      \ 'call assert_notmatch("session-only-history", execute("history cmd"))',
      \ 'call assert_match("Recent Sessions", join(getline(1, "$"), "\n"))',
      \ 'call assert_match("named workspace", join(getline(1, "$"), "\n"))',
      \ 'call assert_equal(' .. string(s:external) .. ', planet#session#Recent()[0].file)',
      \ 'let entries = filter(values(b:startify.entries), ''get(v:val, "cmd", "") =~# "named workspace"'')',
      \ 'call assert_true(!empty(entries))',
      \ 'execute entries[0].cmd',
      \ 'call assert_equal(' .. string(s:external) .. ', v:this_session)',
      \ ])

" Explicit file arguments leave both the requested layout and old session intact.
let s:snapshot = readfile(s:external)
call s:Run(s:folder, [
      \ 'call assert_equal("", v:this_session)',
      \ 'call assert_equal("two.txt", expand("%:t"))',
      \ ], ['two.txt'])
call assert_equal(s:snapshot, readfile(s:external))

" HOME excludes file launches even though PlanetVim changes cwd to the file.
call s:Run(s:home, [
      \ 'call assert_equal("", v:this_session)',
      \ 'call planet#session#SaveAs(' .. string(g:PV_test_dir .. '/home manual.vim') .. ')',
      \ 'call assert_notequal("", v:this_session)',
      \ ], [s:folder .. '/one.txt'])
call s:Run(s:home, ['call assert_equal("", v:this_session)'])

" An explicit native session takes precedence, including when launched in HOME.
call s:Run(s:home, [
      \ 'call assert_equal(' .. string(s:external) .. ', v:this_session)',
      \ 'call assert_notequal("startify", &filetype)',
      \ 'call assert_equal(fnamemodify(v:this_session, ":h") .. "/viminfo", &viminfofile)',
      \ 'call assert_equal("", @z)',
      \ ], ['-S', s:external])

" Emergency exit retains the previous snapshot.
let s:snapshot = readfile(s:external)
call s:Run(s:folder, ['split two.txt'], [], 'cquit!')
call assert_equal(s:snapshot, readfile(s:external))

" Timer autosave occurs while Vim is running; emergency exit does not save.
call s:Run(s:folder, [
      \ 'normal! 3G',
      \ 'sleep 250m',
      \ 'call assert_match("normal!.*", join(readfile(v:this_session), "\n"))',
      \ ], [], 'cquit!', 50)
call s:Run(s:folder, ['call assert_equal(3, line("."))'])

" A native -S import must ignore captured global persistence before reading files.
let s:legacy = g:PV_test_dir .. '/legacy native.vim'
call s:Run(s:home, [
      \ 'execute "edit " .. fnameescape(' .. string(s:folder .. '/one.txt') .. ')',
      \ 'set sessionoptions+=options',
      \ 'execute "mksession! " .. fnameescape(' .. string(s:legacy) .. ')',
      \ ], [], 'cquit!')
call s:Run(s:home, [
      \ 'call assert_equal(' .. string(planet#session#PathForFile(s:legacy)) .. ', v:this_session)',
      \ 'call assert_match("legacy.*session/undo", g:PlanetStartupUndoDir)',
      \ 'call assert_equal("", @z)',
      \ ], ['-S', s:legacy])

" Real restarts restore every list, using filenames rather than old buffer IDs.
let s:lists = planet#session#PathForFile(g:PV_test_dir .. '/diagnostics.vim')
call s:Run(s:home, [
      \ 'execute "edit " .. fnameescape(' .. string(s:folder .. '/one.txt') .. ')',
      \ 'call setqflist([], " ", {"title": "older build", "items": [{"bufnr": bufnr(), "lnum": 1, "text": "older"}]})',
      \ 'call setqflist([], " ", {"title": "latest build", "items": [{"bufnr": bufnr(), "lnum": 2, "text": "latest"}]})',
      \ 'call setloclist(0, [], " ", {"title": "older search", "items": [{"bufnr": bufnr(), "lnum": 1, "text": "old local"}]})',
      \ 'call setloclist(0, [], " ", {"title": "latest search", "items": [{"bufnr": bufnr(), "lnum": 3, "text": "new local"}]})',
      \ 'lopen 4',
      \ 'botright copen 5',
      \ 'call planet#session#SaveAs(' .. string(s:lists) .. ')',
      \ 'call setqflist([], "a", {"title": "timer saved build"})',
      \ 'sleep 200m',
      \ 'call assert_match("timer saved build", join(readfile(v:this_session), "\n"))',
      \ ], [], 'qa!', 50)
call s:Run(s:home, [
      \ 'call assert_equal(3, winnr("$"))',
      \ 'call assert_true(getwininfo(win_getid())[0].quickfix)',
      \ 'call assert_false(getwininfo(win_getid())[0].loclist)',
      \ 'call assert_equal(2, getqflist({"nr": "$"}).nr)',
      \ 'call assert_equal("timer saved build", getqflist({"title": 0}).title)',
      \ 'let owner = filter(getwininfo(), "!v:val.quickfix")[0].winid',
      \ 'call assert_equal(2, getloclist(owner, {"nr": "$"}).nr)',
      \ 'call assert_equal("latest search", getloclist(owner, {"title": 0}).title)',
      \ 'call assert_true(getloclist(owner, {"winid": 0}).winid > 0)',
      \ 'colder',
      \ 'cc',
      \ 'call assert_equal("one.txt", expand("%:t"))',
      \ 'call assert_equal(1, line("."))',
      \ ], ['-S', s:lists])
