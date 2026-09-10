vim9script
def LocalWarn(message: any): any
  echohl WarningMsg
  echom 'PlanetVim Git: ' .. message
  echohl None
  return 0
enddef

# Quoting groups literal arguments. No expansion, pipelines, or evaluation.
# Backslashes in Windows paths remain literal except before whitespace/quotes.
export def Arguments(text: any): any
  var c: any
  var args: any = []
  var word: any = ''
  var quote: any = ''
  var started: any = v:false
  var chars: any = split(text, '\zs')
  var i: any = 0
  while i < len(chars)
    c = chars[i]
    if c ==# '\' && quote !=# "'" && i + 1 < len(chars) && (chars[i + 1] ==# '\' || chars[i + 1] ==# '"' || (empty(quote) && (chars[i + 1] =~# '\s' || chars[i + 1] ==# "'")))
      i += 1
      word ..= chars[i]
      started = v:true
    elseif !empty(quote)
      if c ==# quote
        quote = ''
      else
        word ..= c
      endif
    elseif c ==# '"' || c ==# "'"
      quote = c
      started = v:true
    elseif c =~# '\s'
      if started
        add(args, word)
        word = ''
        started = v:false
      endif
    else
      word ..= c
      started = v:true
    endif
    i += 1
  endwhile
  if !empty(quote)
    throw 'PlanetVim: unmatched argument quote'
  endif
  if started
    add(args, word)
  endif
  return args
enddef

export def Query(arguments: any, directory: any = getcwd()): any
  var job: any
  var file: any = tempname()
  try
    job = job_start(['git', '-C', directory] + arguments, {in_io: 'null', out_io: 'file', out_name: file, err_io: 'null'})
    for i in range(300)
      if job_status(job) !=# 'run'
        return {status: get(job_info(job), 'exitval', -1), lines: filereadable(file) ? readfile(file) : []}
      endif
      sleep 10m
    endfor
    job_stop(job)
    return {status: -1, lines: []}
  finally
    delete(file)
  endtry
  return 0
enddef

export def Run(arguments: any, directory: any = getcwd(), confirmed: any = v:false, on_exit: any = v:null): any
  if !executable('git')
    return LocalWarn('install Git and put git on PATH.')
  endif
  if type(arguments) != v:t_list || empty(arguments) || !empty(filter(copy(arguments), (_, lambda_v) => type(lambda_v) != v:t_string))
    return LocalWarn('Git arguments must be a nonempty list of strings.')
  endif
  var repository: any = planet#git#Repository(directory)
  if empty(repository)
    if index(['init', 'clone', 'help', '--version'], arguments[0]) < 0
      return LocalWarn('current directory is not a Git working tree.')
    endif
    repository = directory
  endif
  return planet#term#RunArgv(['git', '--no-pager', '--literal-pathspecs', '-C', repository] + arguments, v:false, v:false, v:false, repository, on_exit)
enddef

def LocalPrompt(label: any, default: any = ''): any
  return inputdialog(label, default, "\x01")
enddef

def LocalExtension(command: any, package: any): any
  if executable('git-' .. command)
    return 1
  endif
  var execpath: any = planet#gittools#Query(['--exec-path'])
  if execpath.status == 0 && !empty(execpath.lines) && executable(execpath.lines[0] .. '/git-' .. command)
    return 1
  endif
  return LocalWarn('install ' .. package .. ' (git-' .. command .. ') and put it on PATH.')
enddef

def LocalConfirm(arguments: any, confirmed: any): any
  return confirmed || confirm('Run git ' .. string(arguments) .. "\nin " .. getcwd() .. '?', "&Run\n&Cancel", 2) == 1
enddef

export def File(action: any, value: any = v:null, confirmed: any = v:false): any
  var destination: any
  var args: any
  var revision: any
  var file: any = expand('%:p')
  if empty(file) || &buftype !=# ''
    return LocalWarn('this action requires a named file buffer.')
  endif
  if action ==# 'add'
    return planet#gittools#Run(['add', '--', file], fnamemodify(file, ':h'))
  elseif action ==# 'move'
    destination = value == null ? LocalPrompt('Move tracked file to:', file) : value
    if destination ==# "\x01" || empty(destination) || destination ==# file
      return 0
    endif
    args = ['mv', '--', file, fnamemodify(destination, ':p')]
  elseif action ==# 'remove'
    args = ['rm', '--', file]
  elseif index(['restore', 'checkout'], action) >= 0
    revision = value == null ? LocalPrompt('Restore this file from revision (discards its working-tree changes):', 'HEAD') : value
    if revision ==# "\x01" || empty(revision)
      return 0
    endif
    args = ['restore', '--source=' .. revision, '--worktree', '--', file]
  elseif index(['blame', 'annotate'], action) >= 0
    return planet#gittools#Run([action, '--', file], fnamemodify(file, ':h'))
  else
    return LocalWarn('unknown file action: ' .. action)
  endif
  if !LocalConfirm(args, confirmed)
    return 0
  endif
  if &modified
    return LocalWarn("save or discard this buffer's edits before moving/removing/restoring its disk file.")
  endif
  var Callback: any = action ==# 'move' ? function(LocalMoved, [bufnr(), win_getid(), args[-1]]) : index(['restore',
       'checkout'], action) >= 0 ? function(LocalRestored, [bufnr()]) : v:null
  return planet#gittools#Run(args, fnamemodify(file, ':h'), v:false, Callback)
enddef

def LocalRestored(buffer: any, result: any, output: any): any
  if result.status !=# 'success' || !bufexists(buffer)
    return 0
  endif
  if getbufvar(buffer, '&modified')
    LocalWarn('disk file restored; newer buffer edits were retained. Review before saving.')
    return 0
  endif
  var window: any = bufwinid(buffer)
  if window >= 0
    win_execute(window, 'edit!')
  endif
  return 0
enddef

def LocalMoved(buffer: any, arg_window: any, destination: any, result: any, output: any): any
  if result.status !=# 'success' || !bufexists(buffer)
    return 0
  endif
  var window: any = bufwinid(buffer)
  if window >= 0
    win_execute(window, 'file ' .. fnameescape(destination))
  elseif !getbufvar(buffer, '&modified')
    execute 'bwipeout ' .. buffer
  else
    LocalWarn('file moved to ' .. destination .. '; a hidden buffer still has edits at its old name.')
  endif
  return 0
enddef

export def Named(command: any, prompt: any, prefix: any = [], arg_value: any = v:null, confirmed: any = v:false): any
  var value: any = arg_value == null ? LocalPrompt(prompt) : arg_value
  if value ==# "\x01" || empty(value)
    return 0
  endif
  if value =~# '^-'
    return LocalWarn('a name or revision cannot begin with a dash.')
  endif
  var args: any = [command] + prefix + [value]
  if index(['branch', 'tag', 'rebase', 'reset', 'revert', 'cherry-pick', 'merge'], command) >= 0 && !LocalConfirm(args, confirmed)
    return 0
  endif
  return planet#gittools#Run(args)
enddef

# Command-specific argument prompts cover Git's advanced/plumbing interfaces.
# The command is fixed by the menu; entered text becomes literal argv only.
export def Command(command: any, prefix: any = [], default: any = '', supplied: any = v:null, confirmed: any = v:false, package: any = ''): any
  var args: any
  if !empty(package) && !LocalExtension(command, package)
    return 0
  endif
  var text: any = supplied == null ? LocalPrompt('git ' .. join([command] + prefix, ' ') .. ' arguments (quote paths with spaces):', default) : supplied
  if text == null || (type(text) == v:t_string && text ==# "\x01")
    return 0
  endif
  try
    args = [command] + prefix + (type(text) == v:t_list ? copy(text) : planet#gittools#Arguments(text))
  catch
    return LocalWarn(v:exception)
  endtry
  if len(args) == 1 && index(['am', 'apply', 'checkout-index', 'commit-tree', 'hash-object', 'merge-file',
       'read-tree', 'update-index', 'update-ref', 'for-each-repo', 'verify-tag', 'switch', 'revert', 'cherry-pick',
       'subtree', 'unpack-file', 'verify-pack', 'index-pack'], command) >= 0
    return LocalWarn('git ' .. command .. ' requires arguments; no command was run.')
  endif
  if command ==# 'stash' && get(prefix, 0, '') ==# 'branch' && len(args) == 2
    return LocalWarn('enter a new branch name for git stash branch.')
  endif
  if command ==# 'worktree' && index(['add', 'lock', 'unlock', 'move', 'remove'], get(prefix, 0, '')) >= 0 && len(args) == 1 + len(prefix)
    return LocalWarn('enter the worktree path(s) for git worktree ' .. prefix[0] .. '.')
  endif
  if !LocalConfirm(args, confirmed)
    return 0
  endif
  return planet#gittools#Run(args)
enddef

export def Notes(action: any, values: any = v:null, confirmed: any = v:false): any
  var remote: any
  var existing: any
  var args: any
  var normal: any
  var root: any
  if index(['list', 'get-ref'], action) >= 0
    return planet#gittools#Run(['notes', action])
  elseif action ==# 'enable-push'
    remote = values == null ? LocalPrompt('Remote to receive Git notes:', 'origin') : values
    if empty(remote) || remote ==# "\x01" || remote =~# '^-'
      return 0
    endif
    existing = planet#gittools#Query(['config', '--get-all', 'remote.' .. remote .. '.push'])
    if index(existing.lines, 'refs/notes/*:refs/notes/*') >= 0
      return 1
    endif
    args = ['config', '--local', '--add', 'remote.' .. remote .. '.push', 'refs/notes/*:refs/notes/*']
    if empty(existing.lines)
      normal = values == null ? LocalPrompt('Normal push refspec to retain alongside notes:', 'HEAD') : 'HEAD'
      if empty(normal) || normal ==# "\x01"
        return 0
      endif
      if !LocalConfirm(['config', '--local', '--add', 'remote.' .. remote .. '.push', normal, 'and notes refspec'], confirmed)
        return 0
      endif
      root = planet#git#Repository()
      return planet#gittools#Run(['config', '--local', '--add', 'remote.' .. remote .. '.push', normal],
           root, v:false, function(LocalNotesPushConfigured, [root, args]))
    endif
    return LocalConfirm(args, confirmed) ? planet#gittools#Run(args) : 0
  endif
  var defaults: any = {'add': '-m "Note text" HEAD', 'append': '-m "Note text" HEAD', 'edit': 'HEAD',
       'copy': 'HEAD HEAD~1', 'show': 'HEAD', 'merge': 'refs/notes/commits', 'remove': 'HEAD', 'prune': '--dry-run'}
  return planet#gittools#Command('notes', [action], get(defaults, action, ''), values, confirmed)
enddef

def LocalNotesPushConfigured(root: any, args: any, result: any, buffer: any): any
  if result.status ==# 'success'
    planet#gittools#Run(args, root)
  endif
  return 0
enddef

export def Worktree(action: any, supplied: any = v:null, confirmed: any = v:false): any
  if action ==# 'list'
    return planet#gittools#Run(['worktree', 'list'])
  endif
  var defaults: any = {'add': '', 'sibling': '../' .. fnamemodify(getcwd(), ':t') .. '-worktree', 'detached': '',
       'lock': '', 'unlock': '', 'move': '', 'remove': '', 'prune': '--dry-run', 'repair': ''}
  var prefix: any = action ==# 'detached' ? ['add', '--detach'] : [action ==# 'sibling' ? 'add' : action]
  return planet#gittools#Command('worktree', prefix, get(defaults, action, ''), supplied, confirmed)
enddef

export def Subrepo(action: any, all: any = '', supplied: any = v:null, confirmed: any = v:false): any
  var args: any
  if !LocalExtension('subrepo', 'git-subrepo')
    return 0
  endif
  if !empty(all)
    args = ['subrepo', action, all]
    return LocalConfirm(args, confirmed) ? planet#gittools#Run(args) : 0
  endif
  return planet#gittools#Command('subrepo', [action], '', supplied, confirmed)
enddef

export def Stash(action: any, supplied: any = v:null, confirmed: any = v:false): any
  if index(['list', 'show'], action) >= 0
    return planet#gittools#Run(['stash', action])
  endif
  var default: any = action ==# 'branch' ? '' : action ==# 'push' ? '-m "Work in progress"' : ''
  return planet#gittools#Command('stash', [action], default, supplied, confirmed)
enddef

export def CommitAll(untracked: any, arg_message: any = v:null): any
  var message: any = arg_message == null ? LocalPrompt('Commit message:') : arg_message
  if empty(message) || message ==# "\x01"
    return 0
  endif
  if !untracked
    return planet#gittools#Run(['commit', '-a', '-m', message])
  endif
  var root: any = planet#git#Repository()
  if empty(root)
    return LocalWarn('current directory is not a Git working tree.')
  endif
  return planet#term#RunArgv(['git', '-C', root, 'add', '--all'], v:false, v:false, v:false, root, function(LocalCommitAfterAdd, [root, message]))
enddef

def LocalCommitAfterAdd(root: any, message: any, result: any, buffer: any): any
  if result.status ==# 'success'
    planet#gittools#Run(['commit', '-m', message], root)
  endif
  return 0
enddef

export def Gui(argv: any): any
  if empty(argv) || !executable(argv[0])
    return LocalWarn('install ' .. get(argv, 0, 'the selected GUI tool') .. ' and put it on PATH.')
  endif
  if argv[0] ==# 'git' && len(argv) > 1 && !LocalExtension(argv[1], 'Git GUI tools')
    return 0
  endif
  return planet#term#RunGuiApp(argv, getcwd())
enddef

export def Input(command: any, prefix: any = [], default: any = '', arguments: any = v:null, filename: any = v:null, confirmed: any = v:false): any
  var args: any
  var file: any = filename == null ? LocalPrompt('Input file for git ' .. command .. ':') : filename
  if empty(file) || file ==# "\x01"
    return 0
  endif
  if !filereadable(file)
    return LocalWarn('input file is not readable: ' .. file)
  endif
  var text: any = arguments == null ? LocalPrompt('git ' .. command .. ' arguments:', default) : arguments
  if type(text) == v:t_string && text ==# "\x01"
    return 0
  endif
  try
    args = [command] + prefix + (type(text) == v:t_list ? text : planet#gittools#Arguments(text))
  catch
    return LocalWarn(v:exception)
  endtry
  if !LocalConfirm(args, confirmed)
    return 0
  endif
  var root: any = planet#git#Repository()
  if empty(root)
    return LocalWarn('current directory is not a Git working tree.')
  endif
  return planet#term#RunInput(['git', '--no-pager', '--literal-pathspecs', '-C', root] + args, file, root)
enddef

export def Extra(arg_command: any = v:null): any
  var command: any = arg_command == null ? LocalPrompt('Git subcommand name:') : arg_command
  if empty(command) || command ==# "\x01"
    return 0
  endif
  if command !~# '^[a-zA-Z0-9][a-zA-Z0-9-]*$'
    return LocalWarn('enter one Git subcommand name; arguments are requested separately.')
  endif
  return planet#gittools#Command(command)
enddef

export def Hooks(): any
  var path: any = planet#gittools#Query(['rev-parse', '--git-path', 'hooks'])
  if path.status != 0 || empty(path.lines)
    return LocalWarn("cannot find this repository's hooks directory.")
  endif
  execute 'edit ' .. fnameescape(fnamemodify(path.lines[0], ':p'))
  return 1
enddef

export def Mercurial(arg_url: any = v:null): any
  if !LocalExtension('remote-hg', 'git-remote-hg')
    return 0
  endif
  var url: any = arg_url == null ? LocalPrompt('Mercurial repository URL:') : arg_url
  if empty(url) || url ==# "\x01"
    return 0
  endif
  return planet#gittools#Run(['clone', '--', 'hg::' .. url])
enddef
