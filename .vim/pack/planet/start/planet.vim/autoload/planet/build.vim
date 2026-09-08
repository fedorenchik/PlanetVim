scriptversion 4

func! s:Error(message) abort
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#build#BuildDirs() abort
  let l:root = planet#run#Project().root
  let l:basename = fnamemodify(l:root, ':t')
  let l:parent = fnamemodify(l:root, ':h')
  let l:dirs = []
  for l:name in readdir(l:root)
    if stridx(l:name, 'build') == 0 && isdirectory(l:root .. '/' .. l:name)
      call add(l:dirs, l:root .. '/' .. l:name)
    endif
  endfor
  for l:name in readdir(l:parent)
    if stridx(l:name, 'build') == 0 && stridx(l:name, l:basename) >= 0
          \ && isdirectory(l:parent .. '/' .. l:name)
      call add(l:dirs, l:parent .. '/' .. l:name)
    endif
  endfor
  return uniq(sort(l:dirs))
endfunc

" Optional explicit selections make the same validation usable without UI.
func! planet#build#SelectBuildDir(selection = v:null, new_name = v:null) abort
  let l:dirs = planet#build#BuildDirs()
  let l:labels = ['Select Build Directory:']
  for l:index in range(len(l:dirs))
    call add(l:labels, '[' .. (l:index + 1) .. '] ' .. l:dirs[l:index])
  endfor
  call add(l:labels, '[' .. (len(l:dirs) + 1) .. '] Create New Build Directory')
  let l:selection = a:selection is v:null ? inputlist(l:labels) : a:selection
  if type(l:selection) != v:t_number || l:selection <= 0
        \ || l:selection > len(l:dirs) + 1
    return 0
  endif
  if l:selection == len(l:dirs) + 1
    let l:name = a:new_name is v:null ? input('New Build Directory Name: ', 'build', 'dir') : a:new_name
    return planet#build#NewBuildDir(l:name)
  endif
  return planet#build#NewBuildDir(l:dirs[l:selection - 1])
endfunc

func! planet#build#NewInTreeBuildDir() abort
  return planet#build#NewBuildDir('build')
endfunc

func! planet#build#NewOOTBuildDir() abort
  return planet#build#NewBuildDir('../build-' .. fnamemodify(planet#run#Project().root, ':t'))
endfunc

func! planet#build#NewBuildDir(build_dir) abort
  if type(a:build_dir) != v:t_string || empty(a:build_dir)
    return 0
  endif
  let l:project = planet#run#Project()
  let l:directory = planet#run#Path(a:build_dir, l:project.root)
  try
    if ! isdirectory(l:directory)
      call mkdir(l:directory, 'p')
    endif
    if ! isdirectory(l:directory)
      throw 'directory was not created'
    endif
  catch
    return s:Error('cannot use build directory: ' .. v:exception)
  endtry
  let l:previous = l:project.build_dir
  let l:project.build_dir = l:directory
  if ! planet#run#Save()
    let l:project.build_dir = l:previous
    let g:PV_build_dir = l:previous
    return 0
  endif
  echo 'Build Directory: ' .. l:directory
  return 1
endfunc

func! planet#build#GetBuildDir(create_default = v:false) abort
  let l:project = planet#run#Project()
  if empty(l:project.build_dir) && a:create_default
    if ! planet#build#NewInTreeBuildDir()
      return ''
    endif
  endif
  return l:project.build_dir
endfunc

func! planet#build#Configure(export_compile_commands = v:false, on_exit = v:null) abort
  let l:directory = planet#build#GetBuildDir(v:true)
  if empty(l:directory)
    return 0
  endif
  let l:project = planet#run#Project()
  let l:argv = ['cmake', '-S', l:project.root, '-B', l:directory]
  if a:export_compile_commands
    call add(l:argv, '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON')
  endif
  return planet#term#RunArgv(l:argv, v:false, v:false, v:false, l:directory, a:on_exit)
endfunc

func! planet#build#Build(target = '', on_exit = v:null) abort
  let l:directory = planet#build#GetBuildDir()
  if empty(l:directory)
    return s:Error('configure or select this project build directory first')
  endif
  let l:argv = ['cmake', '--build', l:directory]
  if ! empty(a:target)
    let l:argv += ['--target', a:target]
  endif
  return planet#term#RunArgv(l:argv, v:false, v:false, v:false, l:directory, a:on_exit)
endfunc

func! planet#build#Rebuild() abort
  let l:directory = planet#build#GetBuildDir()
  if empty(l:directory)
    return s:Error('configure or select this project build directory first')
  endif
  return planet#term#RunArgv(['cmake', '--build', l:directory, '--clean-first'],
        \ v:false, v:false, v:false, l:directory)
endfunc

func! planet#build#Browse() abort
  let l:directory = planet#build#GetBuildDir()
  if empty(l:directory) || ! isdirectory(l:directory)
    return s:Error('select an existing build directory first')
  endif
  execute 'Fern ' .. fnameescape(l:directory)
endfunc

func! planet#build#ConfigureTui() abort
  let l:directory = planet#build#GetBuildDir(v:true)
  if ! empty(l:directory)
    return planet#term#RunCmdTab(['ccmake', '-S', planet#run#Project().root, '-B', l:directory], l:directory)
  endif
  return 0
endfunc

func! planet#build#ConfigureGui() abort
  let l:directory = planet#build#GetBuildDir(v:true)
  if ! empty(l:directory)
    return planet#term#RunGuiApp(['cmake-gui', '-S', planet#run#Project().root, '-B', l:directory], l:directory)
  endif
  return 0
endfunc
