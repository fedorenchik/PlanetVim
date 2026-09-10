vim9script

var script_manual_write = 0
var script_auto_queues = {}
var script_auto_busy = {}

def LocalError(message: any): any
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. message
  echohl None
  return 0
enddef

# Small local metadata queries use native argv too; no shell or network.
def LocalQuery(directory: any, arguments: any): any
  var job: any
  var output: any = tempname()
  try
    job = job_start(['git', '--literal-pathspecs', '-C', directory] + arguments, {in_io: 'null', out_io: 'file', out_name: output, err_io: 'null'})
    for i in range(500)
      if job_status(job) !=# 'run'
        break
      endif
      sleep 10m
    endfor
    if job_status(job) ==# 'run'
      job_stop(job)
      return {status: -1, lines: []}
    endif
    return {status: get(job_info(job), 'exitval', -1), lines: filereadable(output) ? readfile(output) : []}
  finally
    delete(output)
  endtry
  return 0
enddef

export def Repository(path: any = getcwd()): any
  var directory: any = isdirectory(path) ? path : fnamemodify(path, ':p:h')
  var result: any = LocalQuery(directory, ['rev-parse', '--show-toplevel'])
  return result.status == 0 && ! empty(result.lines) ? result.lines[0] : ''
enddef

def LocalGit(repository: any, arguments: any, on_exit: any = v:null): any
  return planet#term#RunArgv(['git', '--literal-pathspecs', '-C', repository] + arguments, v:false, v:false, v:false, repository, on_exit)
enddef

def LocalAfterPush(repository: any, result: any, bufnr: any): any
  if result.status ==# 'success'
    LocalGit(repository, ['status'])
  endif
  return 0
enddef

def LocalAfterCommit(repository: any, push: any, result: any, bufnr: any): any
  # A failed commit/push stays visible. Each stage has its own job/result.
  if result.status !=# 'success'
    return 0
  endif
  if push
    LocalGit(repository, ['push'], function(LocalAfterPush, [repository]))
  else
    LocalGit(repository, ['status'])
  endif
  return 0
enddef

def LocalMessage(auto: any, name: any, supplied: any): any
  if supplied != null
    return supplied
  endif
  if auto
    return (empty(name) ? '' : name .. ': ') .. 'Update at ' .. strftime('%Y-%m-%d %H:%M:%S')
  endif
  return inputdialog('Commit Message: ')
enddef

export def CommitFile(save: any = v:true, auto: any = v:true, push: any = v:false, arg_message: any = v:null, arg_filename: any = ''): any
  var filename: any = empty(arg_filename) ? expand('%:p') : fnamemodify(arg_filename, ':p')
  if empty(filename) || (empty(arg_filename) && ! empty(&buftype))
    return LocalError('commit requires a named file buffer')
  endif
  if save && filename !=# expand('%:p')
    return LocalError('save-and-commit must target the current file buffer')
  endif
  var message: any = LocalMessage(auto, fnamemodify(filename, ':t'), arg_message)
  if type(message) != v:t_string || empty(trim(message))
    return 0
  endif
  if save
    try
      script_manual_write += 1
      write
    catch
      return LocalError('file was not saved; commit cancelled: ' .. v:exception)
    finally
      script_manual_write -= 1
    endtry
  endif
  var repository: any = planet#git#Repository(filename)
  if empty(repository)
    return LocalError('file is not inside a Git working tree')
  endif
  return LocalGit(repository, ['commit', '-m', message, '--', filename], function(LocalAfterCommit, [repository, push]))
enddef

export def Commit(save: any = v:true, auto: any = v:true, push: any = v:false, arg_message: any = v:null): any
  var message: any = LocalMessage(auto, '', arg_message)
  if type(message) != v:t_string || empty(trim(message))
    return 0
  endif
  if save
    try
      script_manual_write += 1
      confirm wall
      if ! empty(filter(getbufinfo({bufmodified: 1}), (_, lambda_info) => empty(getbufvar(lambda_info.bufnr, '&buftype'))))
        return LocalError('not all buffers were saved; commit cancelled')
      endif
    catch
      return LocalError('files were not saved; commit cancelled: ' .. v:exception)
    finally
      script_manual_write -= 1
    endtry
  endif
  var repository: any = planet#git#Repository()
  if empty(repository)
    return LocalError('current directory is not inside a Git working tree')
  endif
  return LocalGit(repository, ['commit', '-m', message], function(LocalAfterCommit, [repository, push]))
enddef

def LocalNextAuto(repository: any, ...args: list<any>): any
  var filename: any
  var tracked: any
  var changed: any
  var buffer: any
  script_auto_busy[repository] = v:false
  while ! empty(get(script_auto_queues, repository, []))
    filename = remove(script_auto_queues[repository], 0)
    tracked = LocalQuery(repository, ['ls-files', '--error-unmatch', '--', filename])
    if tracked.status != 0
      continue
    endif
    changed = LocalQuery(repository, ['status', '--porcelain', '--', filename])
    if changed.status != 0 || empty(changed.lines)
      continue
    endif
    script_auto_busy[repository] = v:true
    buffer = LocalGit(repository, ['commit', '-m', LocalMessage(v:true, fnamemodify(filename, ':t'), v:null), '--', filename], function(LocalNextAuto, [repository]))
    if buffer == 0
      script_auto_busy[repository] = v:false
    endif
    return 0
  endwhile
  return 0
enddef

export def AutoCommit(bufnr: any, arg_filename: any): any
  if script_manual_write || ! empty(getbufvar(bufnr, '&buftype'))
    return 0
  endif
  var filename: any = fnamemodify(bufname(bufnr), ':p')
  # Whole-buffer exports (:write other-file) must not commit the source file.
  if empty(bufname(bufnr)) || filename !=# fnamemodify(arg_filename, ':p') || ! filereadable(filename)
    return 0
  endif
  var repository: any = planet#git#Repository(filename)
  if empty(repository)
    return 0
  endif
  if ! has_key(script_auto_queues, repository)
    script_auto_queues[repository] = []
  endif
  if index(script_auto_queues[repository], filename) < 0
    add(script_auto_queues[repository], filename)
  endif
  if ! get(script_auto_busy, repository, v:false)
    LocalNextAuto(repository)
  endif
  return 0
enddef

export def EnableAutoCommit(): any
  augroup AugPv_AutoCommit
  autocmd!
  autocmd BufWritePost * call planet#git#AutoCommit(str2nr(expand('<abuf>')), expand('<afile>:p'))
  augroup END
  return 0
enddef

export def DisableAutoCommit(): any
  augroup AugPv_AutoCommit
  autocmd!
  augroup END
  script_auto_queues = {}
  return 0
enddef

export def CheckoutBranch(arg_branch: any = v:null): any
  var branch: any = arg_branch == null ? inputdialog('Branch: ') : arg_branch
  if empty(branch)
    return 0
  endif
  if branch =~# '^-' || branch =~# '[\r\n]'
    return LocalError('enter a branch name, without Git options')
  endif
  var repository: any = planet#git#Repository()
  if empty(repository)
    return LocalError('current directory is not inside a Git working tree')
  endif
  return LocalGit(repository, ['checkout', branch, '--'])
enddef

export def Clone(arg_url: any = v:null, arg_destination: any = v:null): any
  var url: any = arg_url == null ? inputdialog('Repository URL: ') : arg_url
  if empty(url)
    return 0
  endif
  var destination: any = arg_destination == null ? inputdialog('Destination directory (empty uses repository name): ', '', 'CANCELLED') : arg_destination
  if destination ==# 'CANCELLED'
    return 0
  endif
  var argv: any = ['git', 'clone', '--', url]
  if ! empty(destination)
    add(argv, destination)
  endif
  return planet#term#RunArgv(argv)
enddef
