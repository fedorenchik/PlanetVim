" Real debugger acceptance is optional unless CI requires its dependencies.
func! PlanetDebugTestProbe(argv) abort
  if empty(a:argv) || !executable(a:argv[0])
    return 0
  endif
  let l:output = tempname()
  try
    let l:job = job_start(a:argv, #{out_io: 'file', out_name: l:output, err_io: 'out'})
    for l:i in range(300)
      if job_status(l:job) !=# 'run'
        return job_status(l:job) ==# 'dead' && get(job_info(l:job), 'exitval', -1) == 0
      endif
      sleep 10m
    endfor
    call job_stop(l:job, 'kill')
    return 0
  finally
    call delete(l:output)
  endtry
endfunc

func! PlanetDebugTestAvailable(language) abort
  let l:reason = ''
  if !has('gui_running')
    let l:reason = 'real debugger acceptance requires --gui'
  elseif !has('python3')
    let l:reason = 'GVim needs working +python3 support'
  elseif a:language ==# 'python'
    let l:python = get(g:, 'PV_python', [executable('python3') ? 'python3' : 'python'])
    if !empty($PLANETVIM_TEST_DEBUGPY_ADAPTER)
      let g:PV_debugpy_command = l:python + [$PLANETVIM_TEST_DEBUGPY_ADAPTER]
      if !isdirectory($PLANETVIM_TEST_DEBUGPY_ADAPTER) || !executable(l:python[0])
        let l:reason = 'PLANETVIM_TEST_DEBUGPY_ADAPTER must name an installed debugpy adapter directory'
      endif
    else
      let g:PV_debugpy_command = l:python + ['-m', 'debugpy.adapter']
      if !PlanetDebugTestProbe(l:python + ['-c', 'import debugpy.adapter'])
        let l:reason = 'install debugpy in the test Python or set PLANETVIM_TEST_DEBUGPY_ADAPTER'
      endif
    endif
  elseif !executable('g++') || !PlanetDebugTestProbe(['gdb', '--nx', '--quiet', '--batch', '-ex', 'python import gdb.dap'])
    let l:reason = 'C++ debugger acceptance requires g++ and a Python DAP-capable GDB 14+'
  endif
  if !empty(l:reason)
    let g:PV_test_skip = l:reason
    echom 'SKIP: ' .. l:reason
    if has('gui_running') && ($PLANETVIM_REQUIRE_DEBUG_TESTS ==# '1' || (a:language ==# 'python' && $PLANETVIM_REQUIRE_DEBUG_PYTHON ==# '1'))
      call assert_report('Required debugger dependency unavailable: ' .. l:reason)
    endif
    return 0
  endif
  return 1
endfunc
