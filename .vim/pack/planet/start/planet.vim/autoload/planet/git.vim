scriptversion 4

let s:manual_write = 0
let s:auto_queues = {}
let s:auto_busy = {}

func! s:Error(message) abort
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. a:message
  echohl None
  return 0
endfunc

" Small local metadata queries use native argv too; no shell or network.
func! s:Query(directory, arguments) abort
  let l:output = tempname()
  try
    let l:job = job_start(['git', '--literal-pathspecs', '-C', a:directory] + a:arguments,
          \ #{in_io: 'null', out_io: 'file', out_name: l:output, err_io: 'null'})
    for l:i in range(500)
      if job_status(l:job) !=# 'run'
        break
      endif
      sleep 10m
    endfor
    if job_status(l:job) ==# 'run'
      call job_stop(l:job)
      return #{status: -1, lines: []}
    endif
    return #{status: get(job_info(l:job), 'exitval', -1),
          \ lines: filereadable(l:output) ? readfile(l:output) : []}
  finally
    call delete(l:output)
  endtry
endfunc

func! planet#git#Repository(path = getcwd()) abort
  let l:directory = isdirectory(a:path) ? a:path : fnamemodify(a:path, ':p:h')
  let l:result = s:Query(l:directory, ['rev-parse', '--show-toplevel'])
  return l:result.status == 0 && ! empty(l:result.lines) ? l:result.lines[0] : ''
endfunc

func! s:Git(repository, arguments, on_exit = v:null) abort
  return planet#term#RunArgv(['git', '--literal-pathspecs', '-C', a:repository]
        \ + a:arguments, v:false, v:false, v:false, a:repository, a:on_exit)
endfunc

func! s:AfterPush(repository, result, bufnr) abort
  if a:result.status ==# 'success'
    call s:Git(a:repository, ['status'])
  endif
endfunc

func! s:AfterCommit(repository, push, result, bufnr) abort
  " A failed commit/push stays visible. Each stage has its own job/result.
  if a:result.status !=# 'success'
    return
  endif
  if a:push
    call s:Git(a:repository, ['push'], function('s:AfterPush', [a:repository]))
  else
    call s:Git(a:repository, ['status'])
  endif
endfunc

func! s:Message(auto, name, supplied) abort
  if a:supplied isnot v:null
    return a:supplied
  endif
  if a:auto
    return (empty(a:name) ? '' : a:name .. ': ') .. 'Update at ' .. strftime('%Y-%m-%d %H:%M:%S')
  endif
  return inputdialog('Commit Message: ')
endfunc

func! planet#git#CommitFile(save = v:true, auto = v:true, push = v:false, message = v:null, filename = '') abort
  let l:filename = empty(a:filename) ? expand('%:p') : fnamemodify(a:filename, ':p')
  if empty(l:filename) || (empty(a:filename) && ! empty(&buftype))
    return s:Error('commit requires a named file buffer')
  endif
  if a:save && l:filename !=# expand('%:p')
    return s:Error('save-and-commit must target the current file buffer')
  endif
  let l:message = s:Message(a:auto, fnamemodify(l:filename, ':t'), a:message)
  if type(l:message) != v:t_string || empty(trim(l:message))
    return 0
  endif
  if a:save
    try
      let s:manual_write += 1
      write
    catch
      return s:Error('file was not saved; commit cancelled: ' .. v:exception)
    finally
      let s:manual_write -= 1
    endtry
  endif
  let l:repository = planet#git#Repository(l:filename)
  if empty(l:repository)
    return s:Error('file is not inside a Git working tree')
  endif
  return s:Git(l:repository, ['commit', '-m', l:message, '--', l:filename],
        \ function('s:AfterCommit', [l:repository, a:push]))
endfunc

func! planet#git#Commit(save = v:true, auto = v:true, push = v:false, message = v:null) abort
  let l:message = s:Message(a:auto, '', a:message)
  if type(l:message) != v:t_string || empty(trim(l:message))
    return 0
  endif
  if a:save
    try
      let s:manual_write += 1
      confirm wall
      if ! empty(filter(getbufinfo(#{bufmodified: 1}),
            \ {_, info -> empty(getbufvar(info.bufnr, '&buftype'))}))
        return s:Error('not all buffers were saved; commit cancelled')
      endif
    catch
      return s:Error('files were not saved; commit cancelled: ' .. v:exception)
    finally
      let s:manual_write -= 1
    endtry
  endif
  let l:repository = planet#git#Repository()
  if empty(l:repository)
    return s:Error('current directory is not inside a Git working tree')
  endif
  return s:Git(l:repository, ['commit', '-m', l:message],
        \ function('s:AfterCommit', [l:repository, a:push]))
endfunc

func! s:NextAuto(repository, ...) abort
  let s:auto_busy[a:repository] = v:false
  while ! empty(get(s:auto_queues, a:repository, []))
    let l:filename = remove(s:auto_queues[a:repository], 0)
    let l:tracked = s:Query(a:repository, ['ls-files', '--error-unmatch', '--', l:filename])
    if l:tracked.status != 0
      continue
    endif
    let l:changed = s:Query(a:repository, ['status', '--porcelain', '--', l:filename])
    if l:changed.status != 0 || empty(l:changed.lines)
      continue
    endif
    let s:auto_busy[a:repository] = v:true
    let l:buffer = s:Git(a:repository, ['commit', '-m',
          \ s:Message(v:true, fnamemodify(l:filename, ':t'), v:null), '--', l:filename],
          \ function('s:NextAuto', [a:repository]))
    if l:buffer == 0
      let s:auto_busy[a:repository] = v:false
    endif
    return
  endwhile
endfunc

func! planet#git#AutoCommit(bufnr, filename) abort
  if s:manual_write || ! empty(getbufvar(a:bufnr, '&buftype'))
    return
  endif
  let l:filename = fnamemodify(bufname(a:bufnr), ':p')
  " Whole-buffer exports (:write other-file) must not commit the source file.
  if empty(bufname(a:bufnr)) || l:filename !=# fnamemodify(a:filename, ':p')
        \ || ! filereadable(l:filename)
    return
  endif
  let l:repository = planet#git#Repository(l:filename)
  if empty(l:repository)
    return
  endif
  if ! has_key(s:auto_queues, l:repository)
    let s:auto_queues[l:repository] = []
  endif
  if index(s:auto_queues[l:repository], l:filename) < 0
    call add(s:auto_queues[l:repository], l:filename)
  endif
  if ! get(s:auto_busy, l:repository, v:false)
    call s:NextAuto(l:repository)
  endif
endfunc

func! planet#git#EnableAutoCommit() abort
  augroup AugPv_AutoCommit
    autocmd!
    autocmd BufWritePost * call planet#git#AutoCommit(str2nr(expand('<abuf>')), expand('<afile>:p'))
  augroup END
endfunc

func! planet#git#DisableAutoCommit() abort
  augroup AugPv_AutoCommit
    autocmd!
  augroup END
  let s:auto_queues = {}
endfunc

func! planet#git#CheckoutBranch(branch = v:null) abort
  let l:branch = a:branch is v:null ? inputdialog('Branch: ') : a:branch
  if empty(l:branch)
    return 0
  endif
  if l:branch =~# '^-' || l:branch =~# '[\r\n]'
    return s:Error('enter a branch name, without Git options')
  endif
  let l:repository = planet#git#Repository()
  if empty(l:repository)
    return s:Error('current directory is not inside a Git working tree')
  endif
  return s:Git(l:repository, ['checkout', l:branch, '--'])
endfunc

func! planet#git#Clone(url = v:null, destination = v:null) abort
  let l:url = a:url is v:null ? inputdialog('Repository URL: ') : a:url
  if empty(l:url)
    return 0
  endif
  let l:destination = a:destination is v:null
        \ ? inputdialog('Destination directory (empty uses repository name): ', '', 'CANCELLED') : a:destination
  if l:destination ==# 'CANCELLED'
    return 0
  endif
  let l:argv = ['git', 'clone', '--', l:url]
  if ! empty(l:destination)
    call add(l:argv, l:destination)
  endif
  return planet#term#RunArgv(l:argv)
endfunc
