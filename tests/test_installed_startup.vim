" Exercise -u startup in a separate GVim using the real installed payload.
if !has('gui_running')
  let g:PV_test_skip = 'Installed startup requires a real GUI display.'
  finish
endif

let s:started = reltime()
func! s:Wait(job, label, logfile) abort
  while reltimefloat(reltime(s:started)) < get(g:, 'PV_test_timeout', 60) - 5
    if job_status(a:job) !=# 'run'
      let l:exit = get(job_info(a:job), 'exitval', -1)
      call assert_equal(0, l:exit, a:label .. ': ' .. join(readfile(a:logfile), "\n"))
      return l:exit == 0
    endif
    sleep 10m
  endwhile
  call job_stop(a:job, 'kill')
  call assert_report(a:label .. ' timed out')
  return 0
endfunc

let s:prefix = g:PV_test_dir .. "/installed root, 'quoted' 工作"
let s:log = g:PV_test_dir .. '/installed-startup.log'
let s:installer = planet#generate#Python() + [g:PV_root .. '/scripts/install.py', 'install', '--prefix', s:prefix]
let s:job = job_start(s:installer, #{out_io:'file', out_name:s:log, err_io:'out'})
if !s:Wait(s:job, 'real installer', s:log) | finish | endif

" Extra disposable files prove plugin/after ordering and exactly-once loading.
let s:probe = s:prefix .. '/.vim/pack/fixture/start/startup-fixture'
for s:path in [s:probe .. '/plugin', s:probe .. '/after/plugin', s:probe .. '/ftplugin',
      \ s:probe .. '/after/ftplugin', s:prefix .. '/.vim/after/plugin']
  call mkdir(s:path, 'p')
endfor
call writefile(['let g:PV_startup_order = get(g:, "PV_startup_order", []) + ["plugin"]'], s:probe .. '/plugin/fixture.vim')
call writefile(['call add(g:PV_startup_order, "package-after")'], s:probe .. '/after/plugin/fixture.vim')
call writefile(['call add(g:PV_startup_order, "root-after")'], s:prefix .. '/.vim/after/plugin/fixture.vim')
call writefile(['let b:PV_startup_ft = ["ftplugin"]'], s:probe .. '/ftplugin/pvfixture.vim')
call writefile(['call add(b:PV_startup_ft, "after-ftplugin")'], s:probe .. '/after/ftplugin/pvfixture.vim')

let s:result = g:PV_test_dir .. '/installed-startup-result.json'
let s:child = g:PV_test_dir .. '/installed-startup.vim'
let s:config = g:PV_test_dir .. "/child config, 'quoted' 工作"
let s:state = g:PV_test_dir .. "/child state, 'quoted' 工作"
let s:cache = g:PV_test_dir .. "/child cache, 'quoted' 工作"
call writefile([
      \ 'set encoding=utf-8 nomore nomodeline',
      \ 'let g:startify_disable_at_vimenter = 1',
      \ 'let g:PV_config_dir = ' .. string(s:config),
      \ 'let g:PV_state_dir = ' .. string(s:state),
      \ 'let g:PV_cache_dir = ' .. string(s:cache),
      \ 'function! PlanetInstalledCheck(timer) abort',
      \ '  try',
      \ '    set nomore',
      \ '    call assert_true(has("gui_running"))',
      \ '    call assert_true(exists("g:loaded_planet_vim_globals"))',
      \ '    call assert_equal(["plugin", "package-after", "root-after"], g:PV_startup_order)',
      \ '    call assert_equal(2, exists(":PlanetDoctor"))',
      \ '    call assert_equal("molokai", g:colors_name)',
      \ '    call assert_equal(1, len(globpath(&runtimepath, "autoload/planet/paths.vim", 0, 1)))',
      \ '    call assert_equal(fnamemodify(' .. string(s:prefix) .. ', ":p"), fnamemodify(g:PV_root, ":p"))',
      \ '    call assert_equal(fnamemodify(' .. string(s:config .. '/planetvimrc.vim') .. ', ":p"), fnamemodify(g:PV_config, ":p"))',
      \ '    call assert_true(len(menu_info("").submenus) > 0)',
      \ '    enew',
      \ '    setfiletype pvfixture',
      \ '    call assert_equal(["ftplugin", "after-ftplugin"], b:PV_startup_ft)',
      \ '    PlanetHelp',
      \ '    call assert_equal("planetvim.txt", expand("%:t"))',
      \ '    call assert_true(exists(":Cfilter") == 2, "built-in optional cfilter loads")',
      \ '  catch',
      \ '    call add(v:errors, v:exception .. " at " .. v:throwpoint)',
      \ '  endtry',
      \ '  let g:PV_startup_messages = execute("messages")',
      \ '  call assert_notmatch(''\<E\d\+:'', g:PV_startup_messages)',
      \ '  call writefile([json_encode({"errors": v:errors, "messages": g:PV_startup_messages})], ' .. string(s:result) .. ')',
      \ '  execute "cquit " .. (empty(v:errors) ? 0 : 1)',
      \ 'endfunction',
      \ 'autocmd VimEnter * call timer_start(0, function("PlanetInstalledCheck"))',
      \ ], s:child)
let s:argv = [v:progpath, '-g', '-f', '-N', '-n', '-i', 'NONE', '-U', 'NONE',
      \ '-u', s:prefix .. '/scripts/planetvim.vim', '--cmd', 'source ' .. fnameescape(s:child)]
let s:env = #{PLANETVIM_ROOT:s:prefix, PLANETVIM_CONFIG_DIR:s:config,
      \ PLANETVIM_STATE_DIR:s:state, PLANETVIM_CACHE_DIR:s:cache}
" Keep an actual fish installation visible: its unmatched-glob behavior exposed
" the original failure. Other hosts retain their existing shell environment.
if !has('win32') && executable('fish') | let s:env.SHELL = exepath('fish') | endif
let s:job = job_start(s:argv, #{out_io:'file', out_name:s:log, err_io:'out', env:s:env})
call s:Wait(s:job, 'installed GVim startup', s:log)
call assert_true(filereadable(s:result), 'installed startup wrote its result')
if filereadable(s:result)
  let s:record = json_decode(join(readfile(s:result), "\n"))
  call assert_equal([], s:record.errors, s:record.messages)
endif
