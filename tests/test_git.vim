let s:base = g:PV_test_dir .. '/git tests'
let s:repository = s:base .. '/repository with space'
let s:remote = s:base .. '/local remote.git'
let s:hooks = s:base .. '/empty hooks'
call mkdir(s:repository, 'p')
call mkdir(s:hooks, 'p')
let s:original_cwd = getcwd(-1, 0)
let s:file = s:repository .. "/tracked [literal]; 'quote'.txt"
let s:git_commands = []

func! s:Git(arguments, directory = s:repository) abort
  let l:output = tempname()
  let l:job = job_start(['git', '--literal-pathspecs', '-c', 'core.fsmonitor=false',
        \ '-C', a:directory] + a:arguments,
        \ #{in_io: 'null', out_io: 'file', out_name: l:output, err_io: 'out'})
  for l:i in range(500)
    if job_status(l:job) !=# 'run'
      break
    endif
    sleep 10m
  endfor
  let l:lines = filereadable(l:output) ? readfile(l:output) : []
  call delete(l:output)
  call assert_equal(0, get(job_info(l:job), 'exitval', -1), string(a:arguments) .. ': ' .. join(l:lines))
  return l:lines
endfunc

func! s:Drain() abort
  for l:i in range(500)
    let l:running = v:false
    for l:buffer in term_list()
      if ! empty(getbufvar(l:buffer, 'planet_result', {}))
        call term_wait(l:buffer, 10)
        let l:running = l:running || planet#term#Result(l:buffer).status ==# 'running'
      endif
    endfor
    sleep 10m
    if ! l:running
      return
    endif
  endfor
  call assert_report('Git command did not finish')
endfunc

func! s:Count() abort
  return str2nr(s:Git(['rev-list', '--count', 'HEAD'])[0])
endfunc

try
  call assert_true(executable('git'), 'Git is required for this integration fixture')
  call s:Git(['init'])
  call s:Git(['config', 'user.name', 'PlanetVim Test'])
  call s:Git(['config', 'user.email', 'planetvim-test@example.invalid'])
  call s:Git(['config', 'commit.gpgsign', 'false'])
  call s:Git(['config', 'core.fsmonitor', 'false'])
  call s:Git(['config', 'core.hooksPath', s:hooks])
  call writefile(['initial', 'second line'], s:file)
  call s:Git(['add', '--', s:file])
  call s:Git(['commit', '-m', 'initial'])
  call s:Git(['init', '--bare', s:remote])
  call s:Git(['remote', 'add', 'origin', s:remote])
  " All push tests use a disposable local filesystem remote, never a network.
  call s:Git(['push', '-u', 'origin', 'HEAD'])
  let s:remote_head = s:Git(['rev-parse', 'HEAD'], s:remote)[0]
  execute 'tcd ' .. fnameescape(s:base)
  execute 'edit ' .. fnameescape(s:file)
  call assert_equal(s:repository, planet#git#Repository(s:file))

  call setline(1, 'disabled save')
  write
  call s:Drain()
  call assert_equal(1, s:Count(), 'save without opt-in does not commit')

  call planet#git#EnableAutoCommit()
  call setline(1, 'enabled save')
  write
  call s:Drain()
  call assert_equal(2, s:Count(), 'normal save commits once in the actual file repository')
  call assert_equal(s:remote_head, s:Git(['rev-parse', 'HEAD'], s:remote)[0], 'auto-commit never pushes')

  call setline(1, 'uncommitted source edit')
  execute '1,1write! ' .. fnameescape(s:base .. '/partial export.txt')
  call s:Drain()
  call assert_equal(2, s:Count(), 'partial write does not commit source buffer')
  execute 'write! ' .. fnameescape(s:base .. '/whole export.txt')
  call s:Drain()
  call assert_equal(2, s:Count(), 'whole-buffer export does not commit source buffer')

  let s:message = "preserve \"quotes\", commas; $literal and apostrophe's"
  let s:commit = planet#git#CommitFile(v:true, v:false, v:false, s:message)
  call s:Drain()
  call assert_equal('success', planet#term#Result(s:commit).status)
  call assert_equal(3, s:Count(), 'save-and-commit suppresses a duplicate auto-commit')
  call assert_equal(s:message, s:Git(['log', '-1', '--format=%s'])[0])
  call assert_equal(s:remote_head, s:Git(['rev-parse', 'HEAD'], s:remote)[0], 'plain commit never pushes')

  call setline(1, 'cancelled message edit')
  call assert_equal(0, planet#git#CommitFile(v:true, v:false, v:false, ''))
  call assert_equal(1, &modified, 'cancelled message does not write the buffer')
  call assert_equal(3, s:Count())
  setlocal readonly
  call assert_equal(0, planet#git#CommitFile(v:true, v:false, v:false, 'cannot save'))
  setlocal noreadonly
  call assert_equal(3, s:Count(), 'failed write never starts a commit')

  call planet#git#DisableAutoCommit()
  let s:commit = planet#git#CommitFile(v:true, v:false, v:true, 'explicit local push')
  call s:Drain()
  call assert_equal('success', planet#term#Result(s:commit).status)
  call assert_equal(4, s:Count())
  call assert_equal(s:Git(['rev-parse', 'HEAD'])[0], s:Git(['rev-parse', 'HEAD'], s:remote)[0])

  let s:failed = planet#git#CommitFile(v:false, v:false, v:true, 'no changes')
  call s:Drain()
  call assert_equal('failed', planet#term#Result(s:failed).status)
  call assert_notequal(0, planet#term#Result(s:failed).exit_code)
  call assert_false(empty(win_findbuf(s:failed)), 'failed commit stays visible')
  call assert_equal(4, s:Count())
  call assert_equal(s:Git(['rev-parse', 'HEAD'])[0], s:Git(['rev-parse', 'HEAD'], s:remote)[0])

  hide enew
  setlocal buftype=nofile
  call planet#git#AutoCommit(bufnr('%'), s:file)
  call assert_equal(0, planet#git#CommitFile(v:false, v:true, v:false))
  call s:Drain()
  call assert_equal(4, s:Count(), 'special buffer cannot commit another file')
  call assert_equal(0, planet#git#CheckoutBranch('-b'))
  call assert_equal(0, planet#git#Clone(''))
finally
  call planet#git#DisableAutoCommit()
  for s:buffer in term_list()
    if ! empty(getbufvar(s:buffer, 'planet_result', {}))
      call planet#term#Cancel(s:buffer)
      execute 'silent! bwipeout! ' .. s:buffer
    endif
  endfor
  execute 'tcd ' .. fnameescape(s:original_cwd)
endtry
