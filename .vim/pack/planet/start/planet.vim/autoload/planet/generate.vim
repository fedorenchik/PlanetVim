scriptversion 4

let s:package = expand('<sfile>:p:h:h:h')->resolve()

func! s:Error(message) abort
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#generate#Python() abort
  if exists('g:PV_python')
    let l:command = type(g:PV_python) == v:t_list ? copy(g:PV_python) : [g:PV_python]
  elseif executable('python3')
    let l:command = ['python3']
  elseif has('win32') && executable('py')
    let l:command = ['py', '-3']
  elseif has('win32') && executable('python')
    let l:command = ['python']
  else
    call s:Error('project generation requires Python 3; install it or set g:PV_python')
    return []
  endif
  if empty(l:command) || !empty(filter(copy(l:command), {_, value -> type(value) != v:t_string}))
        \ || !executable(l:command[0])
    call s:Error('g:PV_python must name an available Python 3 executable or argv List')
    return []
  endif
  return l:command
endfunc

func! s:Completed(context, result, bufnr) abort
  if a:result.status ==# 'success' && get(a:context.options, 'open', v:false)
    if a:context.file
      execute 'tabedit ' .. fnameescape(a:context.destination)
    else
      tabnew
      execute 'tcd ' .. fnameescape(a:context.destination)
      if exists(':Fern') == 2
        Fern . -drawer
      else
        execute 'edit ' .. fnameescape(a:context.destination)
      endif
    endif
  endif
  let l:Callback = get(a:context.options, 'on_exit', v:null)
  if type(l:Callback) == v:t_func
    call call(l:Callback, [a:result, a:bufnr])
  endif
endfunc

func! s:Generate(operation, name, destination, options) abort
  if type(a:options) != v:t_dict
    return s:Error('generator options must be a Dictionary')
  endif
  if a:destination is v:null
    let l:default = a:operation ==# 'file' ? fnamemodify(a:name, ':t') : 'my-' .. a:name
    let l:destination = input(a:operation ==# 'file' ? 'Destination file: ' : 'Project directory: ', l:default,
          \ a:operation ==# 'file' ? 'file' : 'dir')
  else
    let l:destination = a:destination
  endif
  if type(l:destination) != v:t_string || empty(l:destination)
    return 0
  endif
  let l:destination = fnamemodify(l:destination, ':p')->substitute('[/\\]$', '', '')
  let l:parent = fnamemodify(l:destination, ':h')
  if !isdirectory(l:parent)
    return s:Error('destination parent does not exist: ' .. l:parent)
  endif
  let l:type = getftype(l:destination)
  if !empty(l:type) && (a:operation ==# 'file' || l:type !=# 'dir' || !empty(readdir(l:destination)))
    return s:Error('destination exists and cannot be overwritten: ' .. l:destination)
  endif
  let l:python = planet#generate#Python()
  if empty(l:python)
    return 0
  endif
  let l:argv = l:python + [s:package .. '/bin/generate-project.py', a:operation, a:name, l:destination]
  if exists('g:PV_templates_dir')
    let l:argv += ['--templates', g:PV_templates_dir]
  endif
  if get(a:options, 'install', v:false)
    let l:argv += ['--install']
  endif
  for l:tool in ['npm', 'nuxt']
    if has_key(a:options, l:tool)
      let l:value = a:options[l:tool]
      let l:argv += ['--' .. l:tool, type(l:value) == v:t_list ? json_encode(l:value) : l:value]
    endif
  endfor
  let l:context = #{destination: l:destination, file: a:operation ==# 'file', options: copy(a:options)}
  return planet#term#RunCmd(l:argv, v:false, v:false, get(a:options, 'hidden', v:false), l:parent,
        \ function('s:Completed', [l:context]))
endfunc

" An omitted destination prompts; an explicitly empty one means cancellation.
" Functions return an output-buffer number, or 0 when cancelled/rejected.
" opts.open opens the result only on success; opts.on_exit(result, bufnr)
" receives completion. Copies never execute template contents or install tools.
func! planet#generate#Template(name, destination = v:null, options = {}) abort
  return s:Generate('template', a:name, a:destination, a:options)
endfunc

func! planet#generate#CopyDir(name, destination = v:null, options = {}) abort
  return planet#generate#Template(a:name, a:destination, a:options)
endfunc

func! planet#generate#CopyFile(name, destination = v:null, options = {}) abort
  return s:Generate('file', a:name, a:destination, a:options)
endfunc

" Electron/Vue copy bundled templates. opts.install explicitly runs npm install;
" opts.open never starts the app. Nuxt invokes its installed interactive creator.
func! planet#generate#Framework(name, destination = v:null, options = {}) abort
  return s:Generate('framework', a:name, a:destination, a:options)
endfunc
