vim9script

var script_package = expand('<script>:p:h:h:h')->resolve()

def LocalError(message: any): any
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. message
  echohl None
  return 0
enddef

export def Python(): any
  var command: any
  if exists('g:PV_python')
    command = type(g:PV_python) == v:t_list ? copy(g:PV_python) : [g:PV_python]
  elseif executable('python3')
    command = ['python3']
  elseif has('win32') && executable('py')
    command = ['py', '-3']
  elseif has('win32') && executable('python')
    command = ['python']
  else
    LocalError('project generation requires Python 3; install it or set g:PV_python')
    return []
  endif
  if empty(command) || !empty(filter(copy(command), (_, lambda_value) => type(lambda_value) != v:t_string)) || !executable(command[0])
    LocalError('g:PV_python must name an available Python 3 executable or argv List')
    return []
  endif
  return command
enddef

def LocalCompleted(context: any, result: any, bufnr: any): any
  if result.status ==# 'success' && get(context.options, 'open', v:false)
    if context.file
      execute 'tabedit ' .. fnameescape(context.destination)
    else
      tabnew
      execute 'tcd ' .. fnameescape(context.destination)
      if exists(':Fern') == 2
        execute 'Fern . -drawer'
      else
        execute 'edit ' .. fnameescape(context.destination)
      endif
    endif
  endif
  var Callback: any = get(context.options, 'on_exit', v:null)
  if type(Callback) == v:t_func
    call(Callback, [result, bufnr])
  endif
  return 0
enddef

def LocalGenerate(operation: any, name: any, arg_destination: any, options: any): any
  var default: any
  var destination: any
  var type: any
  var value: any
  if type(options) != v:t_dict
    return LocalError('generator options must be a Dictionary')
  endif
  if arg_destination == null
    default = operation ==# 'file' ? fnamemodify(name, ':t') : 'my-' .. name
    destination = input(operation ==# 'file' ? 'Destination file: ' : 'Project directory: ', default, operation ==# 'file' ? 'file' : 'dir')
  else
    destination = arg_destination
  endif
  if type(destination) != v:t_string || empty(destination)
    return 0
  endif
  destination = fnamemodify(destination, ':p')->substitute('[/\\]$', '', '')
  var parent: any = fnamemodify(destination, ':h')
  if !isdirectory(parent)
    return LocalError('destination parent does not exist: ' .. parent)
  endif
  type = getftype(destination)
  if !empty(type) && (operation ==# 'file' || type !=# 'dir' || !empty(readdir(destination)))
    return LocalError('destination exists and cannot be overwritten: ' .. destination)
  endif
  var python: any = planet#generate#Python()
  if empty(python)
    return 0
  endif
  var argv: any = python + [script_package .. '/bin/generate-project.py', operation, name, destination]
  if exists('g:PV_templates_dir')
    argv += ['--templates', g:PV_templates_dir]
  endif
  if get(options, 'install', v:false)
    argv += ['--install']
  endif
  for tool in ['npm', 'nuxt']
    if has_key(options, tool)
      value = options[tool]
      argv += ['--' .. tool, type(value) == v:t_list ? json_encode(value) :  value]
    endif
  endfor
  var context: any = {destination: destination, file: operation ==# 'file', options: copy(options)}
  return planet#term#RunCmd(argv, v:false, v:false, get(options, 'hidden', v:false), parent, function(LocalCompleted, [context]))
enddef

# An omitted destination prompts; an explicitly empty one means cancellation.
# Functions return an output-buffer number, or 0 when cancelled/rejected.
# opts.open opens the result only on success; opts.on_exit(result, bufnr)
# receives completion. Copies never execute template contents or install tools.
export def Template(name: any, destination: any = v:null, options: any = {}): any
  return LocalGenerate('template', name, destination, options)
enddef

export def CopyDir(name: any, destination: any = v:null, options: any = {}): any
  return planet#generate#Template(name, destination, options)
enddef

export def CopyFile(name: any, destination: any = v:null, options: any = {}): any
  return LocalGenerate('file', name, destination, options)
enddef

# Electron/Vue copy bundled templates. opts.install explicitly runs npm install;
# opts.open never starts the app. Nuxt invokes its installed interactive creator.
export def Framework(name: any, destination: any = v:null, options: any = {}): any
  return LocalGenerate('framework', name, destination, options)
enddef
