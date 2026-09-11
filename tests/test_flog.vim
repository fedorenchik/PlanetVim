if !executable('git') || !executable('luajit')
  let g:PV_test_skip = 'Flog integration requires Git and LuaJIT 2.1'
  finish
endif
let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
let s:root = g:PV_test_dir .. '/graph repo'
call mkdir(s:root, 'p')
func! s:Git(args) abort
  let l:job = job_start(['git', '-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null', '-C', s:root] + a:args, #{out_io: 'null', err_io: 'null'})
  for l:attempt in range(300)
    if job_status(l:job) !=# 'run' | break | endif
    sleep 10m
  endfor
  call assert_equal(0, get(job_info(l:job), 'exitval', -1))
endfunc
call s:Git(['init', '-q'])
call writefile(['before'], s:root .. '/sample.txt')
call s:Git(['add', 'sample.txt'])
call s:Git(['commit', '-qm', 'first fixture commit'])
call writefile(['after'], s:root .. '/sample.txt')
call s:Git(['commit', '-qam', 'second fixture commit'])
execute 'cd ' .. fnameescape(s:root)
execute 'edit ' .. fnameescape(s:root .. '/sample.txt')
silent Flogsplit -max-count=2
call assert_equal('floggraph', &filetype)
call assert_match('first fixture commit', join(getline(1, '$'), "\n"))
call assert_match('second fixture commit', join(getline(1, '$'), "\n"))
call search('second fixture commit')
let s:new = line('.')
call search('first fixture commit')
let s:old = line('.')
call setpos("'<", [0, s:new, 1, 0])
call setpos("'>", [0, s:old, 1, 0])
" Execute the actual PlanetVim visual mapping, including Flog's format API.
call feedkeys("gvD", 'xt')
for s:attempt in range(300)
  if &filetype ==# 'git' | break | endif
  sleep 10m
endfor
call assert_equal('git', &filetype)
call assert_match('-before', join(getline(1, '$'), "\n"))
call assert_match('+after', join(getline(1, '$'), "\n"))
