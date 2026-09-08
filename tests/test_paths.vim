let s:base = g:PV_test_dir .. "/private space's 工作"
let g:PV_state_dir = s:base .. '/state'
let g:PV_config_dir = s:base .. '/config'
let g:PV_cache_dir = s:base .. '/cache'
for s:kind in ['State', 'Config', 'Cache']
  let s:directory = call('planet#paths#' .. s:kind, ['nested/child'])
  call assert_true(isdirectory(s:directory))
  if !has('win32')
    call assert_equal('rwx------', getfperm(s:directory))
  endif
endfor
runtime plugin/settings.vim
set nomore
call assert_match(escape(s:base, '\'), &directory)
call assert_match(escape(s:base, '\'), &backupdir)
call assert_match(escape(s:base, '\'), &undodir)
call assert_match(escape(s:base, '\'), &spellfile)
call assert_match(escape(s:base, '\'), &viewdir)
call assert_match(escape(s:base, '\'), &viminfofile)
call assert_true(&swapfile)
call assert_true(&writebackup)
call assert_false(&autowriteall)
call assert_false(&exrc)
let s:file = g:PV_test_dir .. '/state-check.txt'
call writefile(['before'], s:file)
execute 'edit ' .. fnameescape(s:file)
set backupskip=
call setline(1, 'after')
write
call assert_equal(['after'], readfile(s:file))
call assert_false(empty(globpath(planet#paths#State('backup'), '*', 0, 1)))
call assert_true(stridx(undofile(s:file), g:PV_state_dir) == 0)
" Verify the actual automatic undo persistence used by the distribution.
" :wundo has different filename parsing on Windows and is not used here.
call assert_true(filereadable(undofile(s:file)))
execute 'bwipeout ' .. bufnr()
execute 'edit ' .. fnameescape(s:file)
" Vim 9.1.0's lazyredraw message check polls closed stdin during :undo in
" silent Ex mode and exits. The supported GUI exercises the configured value.
if !has('gui_running') | set nolazyredraw | endif
silent undo
call assert_equal(['before'], getline(1, '$'))
set nomore
