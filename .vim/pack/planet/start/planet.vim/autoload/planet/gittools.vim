scriptversion 4

func! s:Warn(message) abort
  echohl WarningMsg
  echom 'PlanetVim Git: ' .. a:message
  echohl None
  return 0
endfunc

" Quoting groups literal arguments. No expansion, pipelines, or evaluation.
" Backslashes in Windows paths remain literal except before whitespace/quotes.
func! planet#gittools#Arguments(text) abort
  let l:args = []
  let l:word = ''
  let l:quote = ''
  let l:started = v:false
  let l:chars = split(a:text, '\zs')
  let l:i = 0
  while l:i < len(l:chars)
    let l:c = l:chars[l:i]
    if l:c ==# '\' && l:quote !=# "'" && l:i + 1 < len(l:chars)
          \ && (l:chars[l:i + 1] ==# '\' || l:chars[l:i + 1] ==# '"'
          \ || (empty(l:quote) && (l:chars[l:i + 1] =~# '\s' || l:chars[l:i + 1] ==# "'")))
      let l:i += 1
      let l:word ..= l:chars[l:i]
      let l:started = v:true
    elseif !empty(l:quote)
      if l:c ==# l:quote
        let l:quote = ''
      else
        let l:word ..= l:c
      endif
    elseif l:c ==# '"' || l:c ==# "'"
      let l:quote = l:c
      let l:started = v:true
    elseif l:c =~# '\s'
      if l:started
        call add(l:args, l:word)
        let l:word = ''
        let l:started = v:false
      endif
    else
      let l:word ..= l:c
      let l:started = v:true
    endif
    let l:i += 1
  endwhile
  if !empty(l:quote)
    throw 'PlanetVim: unmatched argument quote'
  endif
  if l:started
    call add(l:args, l:word)
  endif
  return l:args
endfunc

func! planet#gittools#Query(arguments, directory = getcwd()) abort
  let l:file = tempname()
  try
    let l:job = job_start(['git', '-C', a:directory] + a:arguments,
          \ #{in_io: 'null', out_io: 'file', out_name: l:file, err_io: 'null'})
    for l:i in range(300)
      if job_status(l:job) !=# 'run'
        return #{status: get(job_info(l:job), 'exitval', -1), lines: filereadable(l:file) ? readfile(l:file) : []}
      endif
      sleep 10m
    endfor
    call job_stop(l:job)
    return #{status: -1, lines: []}
  finally
    call delete(l:file)
  endtry
endfunc

func! planet#gittools#Run(arguments, directory = getcwd(), confirmed = v:false, on_exit = v:null) abort
  if !executable('git')
    return s:Warn('install Git and put git on PATH.')
  endif
  if type(a:arguments) != v:t_list || empty(a:arguments)
        \ || !empty(filter(copy(a:arguments), {_, v -> type(v) != v:t_string}))
    return s:Warn('Git arguments must be a nonempty list of strings.')
  endif
  let l:repository = planet#git#Repository(a:directory)
  if empty(l:repository)
    if index(['init', 'clone', 'help', '--version'], a:arguments[0]) < 0
      return s:Warn('current directory is not a Git working tree.')
    endif
    let l:repository = a:directory
  endif
  return planet#term#RunArgv(['git', '--no-pager', '--literal-pathspecs', '-C', l:repository] + a:arguments,
        \ v:false, v:false, v:false, l:repository, a:on_exit)
endfunc

func! s:Prompt(label, default = '') abort
  return inputdialog(a:label, a:default, "\x01")
endfunc

func! s:Extension(command, package) abort
  if executable('git-' .. a:command)
    return 1
  endif
  let l:execpath = planet#gittools#Query(['--exec-path'])
  if l:execpath.status == 0 && !empty(l:execpath.lines)
        \ && executable(l:execpath.lines[0] .. '/git-' .. a:command)
    return 1
  endif
  return s:Warn('install ' .. a:package .. ' (git-' .. a:command .. ') and put it on PATH.')
endfunc

func! s:Confirm(arguments, confirmed) abort
  return a:confirmed || confirm('Run git ' .. string(a:arguments) .. "\nin " .. getcwd() .. '?', "&Run\n&Cancel", 2) == 1
endfunc

func! planet#gittools#File(action, value = v:null, confirmed = v:false) abort
  let l:file = expand('%:p')
  if empty(l:file) || &buftype !=# ''
    return s:Warn('this action requires a named file buffer.')
  endif
  if a:action ==# 'add'
    return planet#gittools#Run(['add', '--', l:file], fnamemodify(l:file, ':h'))
  elseif a:action ==# 'move'
    let l:destination = a:value is v:null ? s:Prompt('Move tracked file to:', l:file) : a:value
    if l:destination ==# "\x01" || empty(l:destination) || l:destination ==# l:file
      return 0
    endif
    let l:args = ['mv', '--', l:file, fnamemodify(l:destination, ':p')]
  elseif a:action ==# 'remove'
    let l:args = ['rm', '--', l:file]
  elseif index(['restore', 'checkout'], a:action) >= 0
    let l:revision = a:value is v:null ? s:Prompt('Restore this file from revision (discards its working-tree changes):', 'HEAD') : a:value
    if l:revision ==# "\x01" || empty(l:revision)
      return 0
    endif
    let l:args = ['restore', '--source=' .. l:revision, '--worktree', '--', l:file]
  elseif index(['blame', 'annotate'], a:action) >= 0
    return planet#gittools#Run([a:action, '--', l:file], fnamemodify(l:file, ':h'))
  else
    return s:Warn('unknown file action: ' .. a:action)
  endif
  if !s:Confirm(l:args, a:confirmed)
    return 0
  endif
  if &modified
    return s:Warn("save or discard this buffer's edits before moving/removing/restoring its disk file.")
  endif
  let l:Callback = a:action ==# 'move' ? function('s:Moved', [bufnr(), win_getid(), l:args[-1]])
        \ : index(['restore', 'checkout'], a:action) >= 0 ? function('s:Restored', [bufnr()]) : v:null
  return planet#gittools#Run(l:args, fnamemodify(l:file, ':h'), v:false, l:Callback)
endfunc

func! s:Restored(buffer, result, output) abort
  if a:result.status !=# 'success' || !bufexists(a:buffer)
    return
  endif
  if getbufvar(a:buffer, '&modified')
    call s:Warn('disk file restored; newer buffer edits were retained. Review before saving.')
    return
  endif
  let l:window = bufwinid(a:buffer)
  if l:window >= 0
    call win_execute(l:window, 'edit!')
  endif
endfunc

func! s:Moved(buffer, window, destination, result, output) abort
  if a:result.status !=# 'success' || !bufexists(a:buffer)
    return
  endif
  let l:window = bufwinid(a:buffer)
  if l:window >= 0
    call win_execute(l:window, 'file ' .. fnameescape(a:destination))
  elseif !getbufvar(a:buffer, '&modified')
    execute 'bwipeout ' .. a:buffer
  else
    call s:Warn('file moved to ' .. a:destination .. '; a hidden buffer still has edits at its old name.')
  endif
endfunc

func! planet#gittools#Named(command, prompt, prefix = [], value = v:null, confirmed = v:false) abort
  let l:value = a:value is v:null ? s:Prompt(a:prompt) : a:value
  if l:value ==# "\x01" || empty(l:value)
    return 0
  endif
  if l:value =~# '^-'
    return s:Warn('a name or revision cannot begin with a dash.')
  endif
  let l:args = [a:command] + a:prefix + [l:value]
  if index(['branch', 'tag', 'rebase', 'reset', 'revert', 'cherry-pick', 'merge'], a:command) >= 0
        \ && !s:Confirm(l:args, a:confirmed)
    return 0
  endif
  return planet#gittools#Run(l:args)
endfunc

" Command-specific argument prompts cover Git's advanced/plumbing interfaces.
" The command is fixed by the menu; entered text becomes literal argv only.
func! planet#gittools#Command(command, prefix = [], default = '', supplied = v:null, confirmed = v:false, package = '') abort
  if !empty(a:package) && !s:Extension(a:command, a:package)
    return 0
  endif
  let l:text = a:supplied is v:null ? s:Prompt('git ' .. join([a:command] + a:prefix, ' ') .. ' arguments (quote paths with spaces):', a:default) : a:supplied
  if l:text is v:null || (type(l:text) == v:t_string && l:text ==# "\x01")
    return 0
  endif
  try
    let l:args = [a:command] + a:prefix + (type(l:text) == v:t_list ? copy(l:text) : planet#gittools#Arguments(l:text))
  catch
    return s:Warn(v:exception)
  endtry
  if len(l:args) == 1 && index(['am', 'apply', 'checkout-index', 'commit-tree', 'hash-object',
        \ 'merge-file', 'read-tree', 'update-index', 'update-ref', 'for-each-repo', 'verify-tag',
        \ 'switch', 'revert', 'cherry-pick', 'subtree', 'unpack-file', 'verify-pack', 'index-pack'], a:command) >= 0
    return s:Warn('git ' .. a:command .. ' requires arguments; no command was run.')
  endif
  if a:command ==# 'stash' && get(a:prefix, 0, '') ==# 'branch' && len(l:args) == 2
    return s:Warn('enter a new branch name for git stash branch.')
  endif
  if a:command ==# 'worktree' && index(['add', 'lock', 'unlock', 'move', 'remove'], get(a:prefix, 0, '')) >= 0
        \ && len(l:args) == 1 + len(a:prefix)
    return s:Warn('enter the worktree path(s) for git worktree ' .. a:prefix[0] .. '.')
  endif
  if !s:Confirm(l:args, a:confirmed)
    return 0
  endif
  return planet#gittools#Run(l:args)
endfunc

func! planet#gittools#Notes(action, values = v:null, confirmed = v:false) abort
  if index(['list', 'get-ref'], a:action) >= 0
    return planet#gittools#Run(['notes', a:action])
  elseif a:action ==# 'enable-push'
    let l:remote = a:values is v:null ? s:Prompt('Remote to receive Git notes:', 'origin') : a:values
    if empty(l:remote) || l:remote ==# "\x01" || l:remote =~# '^-'
      return 0
    endif
    let l:existing = planet#gittools#Query(['config', '--get-all', 'remote.' .. l:remote .. '.push'])
    if index(l:existing.lines, 'refs/notes/*:refs/notes/*') >= 0
      return 1
    endif
    let l:args = ['config', '--local', '--add', 'remote.' .. l:remote .. '.push', 'refs/notes/*:refs/notes/*']
    if empty(l:existing.lines)
      let l:normal = a:values is v:null ? s:Prompt('Normal push refspec to retain alongside notes:', 'HEAD') : 'HEAD'
      if empty(l:normal) || l:normal ==# "\x01"
        return 0
      endif
      if !s:Confirm(['config', '--local', '--add', 'remote.' .. l:remote .. '.push', l:normal, 'and notes refspec'], a:confirmed)
        return 0
      endif
      let l:root = planet#git#Repository()
      return planet#gittools#Run(['config', '--local', '--add', 'remote.' .. l:remote .. '.push', l:normal],
            \ l:root, v:false, function('s:NotesPushConfigured', [l:root, l:args]))
    endif
    return s:Confirm(l:args, a:confirmed) ? planet#gittools#Run(l:args) : 0
  endif
  let l:defaults = {'add': '-m "Note text" HEAD', 'append': '-m "Note text" HEAD',
        \ 'edit': 'HEAD', 'copy': 'HEAD HEAD~1', 'show': 'HEAD', 'merge': 'refs/notes/commits',
        \ 'remove': 'HEAD', 'prune': '--dry-run'}
  return planet#gittools#Command('notes', [a:action], get(l:defaults, a:action, ''), a:values, a:confirmed)
endfunc

func! s:NotesPushConfigured(root, args, result, buffer) abort
  if a:result.status ==# 'success'
    call planet#gittools#Run(a:args, a:root)
  endif
endfunc

func! planet#gittools#Worktree(action, supplied = v:null, confirmed = v:false) abort
  if a:action ==# 'list'
    return planet#gittools#Run(['worktree', 'list'])
  endif
  let l:defaults = {'add': '', 'sibling': '../' .. fnamemodify(getcwd(), ':t') .. '-worktree',
        \ 'detached': '', 'lock': '', 'unlock': '', 'move': '', 'remove': '', 'prune': '--dry-run', 'repair': ''}
  let l:prefix = a:action ==# 'detached' ? ['add', '--detach'] : [a:action ==# 'sibling' ? 'add' : a:action]
  return planet#gittools#Command('worktree', l:prefix, get(l:defaults, a:action, ''), a:supplied, a:confirmed)
endfunc

func! planet#gittools#Subrepo(action, all = '', supplied = v:null, confirmed = v:false) abort
  if !s:Extension('subrepo', 'git-subrepo')
    return 0
  endif
  if !empty(a:all)
    let l:args = ['subrepo', a:action, a:all]
    return s:Confirm(l:args, a:confirmed) ? planet#gittools#Run(l:args) : 0
  endif
  return planet#gittools#Command('subrepo', [a:action], '', a:supplied, a:confirmed)
endfunc

func! planet#gittools#Stash(action, supplied = v:null, confirmed = v:false) abort
  if index(['list', 'show'], a:action) >= 0
    return planet#gittools#Run(['stash', a:action])
  endif
  let l:default = a:action ==# 'branch' ? '' : a:action ==# 'push' ? '-m "Work in progress"' : ''
  return planet#gittools#Command('stash', [a:action], l:default, a:supplied, a:confirmed)
endfunc

func! planet#gittools#CommitAll(untracked, message = v:null) abort
  let l:message = a:message is v:null ? s:Prompt('Commit message:') : a:message
  if empty(l:message) || l:message ==# "\x01"
    return 0
  endif
  if !a:untracked
    return planet#gittools#Run(['commit', '-a', '-m', l:message])
  endif
  let l:root = planet#git#Repository()
  if empty(l:root)
    return s:Warn('current directory is not a Git working tree.')
  endif
  return planet#term#RunArgv(['git', '-C', l:root, 'add', '--all'], v:false, v:false, v:false,
        \ l:root, function('s:CommitAfterAdd', [l:root, l:message]))
endfunc

func! s:CommitAfterAdd(root, message, result, buffer) abort
  if a:result.status ==# 'success'
    call planet#gittools#Run(['commit', '-m', a:message], a:root)
  endif
endfunc

func! planet#gittools#Gui(argv) abort
  if empty(a:argv) || !executable(a:argv[0])
    return s:Warn('install ' .. get(a:argv, 0, 'the selected GUI tool') .. ' and put it on PATH.')
  endif
  if a:argv[0] ==# 'git' && len(a:argv) > 1 && !s:Extension(a:argv[1], 'Git GUI tools')
    return 0
  endif
  return planet#term#RunGuiApp(a:argv, getcwd())
endfunc

func! planet#gittools#Input(command, prefix = [], default = '', arguments = v:null, filename = v:null, confirmed = v:false) abort
  let l:file = a:filename is v:null ? s:Prompt('Input file for git ' .. a:command .. ':') : a:filename
  if empty(l:file) || l:file ==# "\x01"
    return 0
  endif
  if !filereadable(l:file)
    return s:Warn('input file is not readable: ' .. l:file)
  endif
  let l:text = a:arguments is v:null ? s:Prompt('git ' .. a:command .. ' arguments:', a:default) : a:arguments
  if type(l:text) == v:t_string && l:text ==# "\x01"
    return 0
  endif
  try
    let l:args = [a:command] + a:prefix + (type(l:text) == v:t_list ? l:text : planet#gittools#Arguments(l:text))
  catch
    return s:Warn(v:exception)
  endtry
  if !s:Confirm(l:args, a:confirmed)
    return 0
  endif
  let l:root = planet#git#Repository()
  if empty(l:root)
    return s:Warn('current directory is not a Git working tree.')
  endif
  return planet#term#RunInput(['git', '--no-pager', '--literal-pathspecs', '-C', l:root] + l:args, l:file, l:root)
endfunc

func! planet#gittools#Extra(command = v:null) abort
  let l:command = a:command is v:null ? s:Prompt('Git subcommand name:') : a:command
  if empty(l:command) || l:command ==# "\x01"
    return 0
  endif
  if l:command !~# '^[a-zA-Z0-9][a-zA-Z0-9-]*$'
    return s:Warn('enter one Git subcommand name; arguments are requested separately.')
  endif
  return planet#gittools#Command(l:command)
endfunc

func! planet#gittools#Hooks() abort
  let l:path = planet#gittools#Query(['rev-parse', '--git-path', 'hooks'])
  if l:path.status != 0 || empty(l:path.lines)
    return s:Warn("cannot find this repository's hooks directory.")
  endif
  execute 'edit ' .. fnameescape(fnamemodify(l:path.lines[0], ':p'))
  return 1
endfunc

func! planet#gittools#Mercurial(url = v:null) abort
  if !s:Extension('remote-hg', 'git-remote-hg')
    return 0
  endif
  let l:url = a:url is v:null ? s:Prompt('Mercurial repository URL:') : a:url
  if empty(l:url) || l:url ==# "\x01"
    return 0
  endif
  return planet#gittools#Run(['clone', '--', 'hg::' .. l:url])
endfunc
