" First-party defaults must run after user config and before plugin loading.
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
let s:plugin = g:PV_root .. '/.vim/pack/planet/start/planet.vim/plugin/planet.vim'
let s:missing = g:PV_test_dir .. '/missing-git-executable'

func! s:Configure(lines) abort
  unlet! g:PV_config_loaded g:gitgutter_enabled g:gitgutter_git_executable
  call writefile(a:lines, g:PV_config)
  execute 'source ' .. fnameescape(s:plugin)
endfunc

call s:Configure([])
call assert_equal(executable('git'), g:gitgutter_enabled, 'default follows Git availability')
call s:Configure(['let g:gitgutter_git_executable = ' .. string(s:missing)])
call assert_equal(0, g:gitgutter_enabled, 'absent optional Git does not warn at startup')
call assert_equal(s:missing, g:gitgutter_git_executable)
let v:warningmsg = ''
execute 'source ' .. fnameescape(g:PV_root .. '/.vim/pack/git/start/vim-gitgutter/plugin/gitgutter.vim')
call assert_equal('', v:warningmsg, 'upstream missing-Git path remains silent')

" A real executable establishes availability; this test does not execute it.
call s:Configure(['let g:gitgutter_git_executable = ' .. string(v:progpath)])
call assert_equal(1, g:gitgutter_enabled, 'available configured executable defaults on')
call assert_equal(v:progpath, g:gitgutter_git_executable)
call s:Configure(['let g:gitgutter_enabled = 0',
      \ 'let g:gitgutter_git_executable = ' .. string(v:progpath)])
call assert_equal(0, g:gitgutter_enabled, 'explicit off overrides availability')
call s:Configure(['let g:gitgutter_enabled = 1',
      \ 'let g:gitgutter_git_executable = ' .. string(s:missing)])
call assert_equal(1, g:gitgutter_enabled, 'explicit on remains authoritative')
call assert_equal(s:missing, g:gitgutter_git_executable)
