scriptversion 4

let s:legacy_imported = v:false

func! s:Error(message) abort
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. a:message
  echohl None
  return 0
endfunc

func! planet#run#Path(path, base) abort
  let l:path = a:path =~# '^[/\\]\|^\a:[/\\]' ? a:path : a:base .. '/' .. a:path
  return fnamemodify(simplify(l:path) .. '/', ':p:h')
endfunc

func! s:StateFile(root) abort
  return planet#paths#State('projects') .. '/' .. sha256(a:root) .. '.json'
endfunc

func! s:Validate(profiles) abort
  if type(a:profiles) != v:t_list
    throw 'run profiles must be a JSON array'
  endif
  for l:profile in a:profiles
    if type(l:profile) != v:t_dict || type(get(l:profile, 'name', 0)) != v:t_string
          \ || empty(l:profile.name) || type(get(l:profile, 'cwd', '')) != v:t_string
      throw 'each run profile needs a name and an optional cwd String'
    endif
    if has_key(l:profile, 'argv') == has_key(l:profile, 'command')
      throw 'each run profile needs exactly one of argv or command'
    endif
    if has_key(l:profile, 'argv')
      if type(l:profile.argv) != v:t_list || empty(l:profile.argv)
            \ || ! empty(filter(copy(l:profile.argv), {_, value -> type(value) != v:t_string}))
            \ || empty(l:profile.argv[0])
        throw 'profile argv must be a nonempty List of Strings'
      endif
    elseif type(l:profile.command) != v:t_string || empty(l:profile.command)
      throw 'profile command must be a nonempty shell script String'
    endif
  endfor
endfunc

" Tab cwd is the project identity; window-local cwd changes do not select a
" different project. Profiles live in user state, never executable project files.
func! planet#run#Project() abort
  let l:root = fnamemodify(resolve(getcwd(-1, 0)), ':p:h')
  if ! exists('t:PV_projects')
    let t:PV_projects = {}
  endif
  if ! has_key(t:PV_projects, l:root)
    let l:project = #{root: l:root, build_dir: '', profiles: []}
    let l:file = s:StateFile(l:root)
    if filereadable(l:file)
      try
        let l:saved = json_decode(join(readfile(l:file), "\n"))
        if type(l:saved) != v:t_dict || get(l:saved, 'root', '') !=# l:root
              \ || type(get(l:saved, 'build_dir', 0)) != v:t_string
          throw 'invalid project state'
        endif
        call s:Validate(get(l:saved, 'profiles', v:null))
        let l:project = l:saved
      catch
        call s:Error('cannot load project state: ' .. v:exception)
      endtry
    elseif ! s:legacy_imported
      let l:project.build_dir = get(g:, 'PV_build_dir', '')
      if ! empty(l:project.build_dir)
        let l:project.build_dir = planet#run#Path(l:project.build_dir, l:root)
      endif
      for l:command in split(get(g:, 'PV_run_configurations', ''), ',')
        call add(l:project.profiles, #{name: l:command, command: l:command, cwd: ''})
      endfor
    endif
    let s:legacy_imported = v:true
    let t:PV_projects[l:root] = l:project
  endif
  let l:project = t:PV_projects[l:root]
  let g:PV_build_dir = l:project.build_dir
  " Keep the legacy variables readable; all new commands use structured state.
  let g:PV_run_configurations = join(map(copy(l:project.profiles), {_, profile -> profile.name}), ',')
  return l:project
endfunc

func! planet#run#Save() abort
  let l:project = planet#run#Project()
  let l:file = s:StateFile(l:project.root)
  let l:temporary = l:file .. '.' .. getpid() .. '.tmp'
  try
    call writefile([json_encode(l:project)], l:temporary)
    call setfperm(l:temporary, 'rw-------')
    if rename(l:temporary, l:file) != 0
      throw 'cannot replace ' .. l:file
    endif
  catch
    call delete(l:temporary)
    return s:Error('cannot save project state: ' .. v:exception)
  endtry
  return 1
endfunc

func! planet#run#SetProfiles(profiles) abort
  try
    call s:Validate(a:profiles)
  catch
    return s:Error(v:exception)
  endtry
  let l:project = planet#run#Project()
  let l:previous = l:project.profiles
  let l:project.profiles = deepcopy(a:profiles)
  if ! planet#run#Save()
    let l:project.profiles = l:previous
    let g:PV_run_configurations = join(map(copy(l:previous), {_, profile -> profile.name}), ',')
    return 0
  endif
  call planet#run#UpdateRunMenu()
  return 1
endfunc

func! planet#run#Run(index) abort
  let l:project = planet#run#Project()
  if a:index < 0 || a:index >= len(l:project.profiles)
    return s:Error('run profile does not exist in this project')
  endif
  let l:profile = l:project.profiles[a:index]
  let l:cwd = get(l:profile, 'cwd', '')
  if empty(l:cwd)
    let l:cwd = empty(l:project.build_dir) ? l:project.root : l:project.build_dir
  elseif l:cwd !~# '^[/\\]\|^\a:[/\\]'
    let l:cwd = l:project.root .. '/' .. l:cwd
  endif
  return planet#term#RunCmd(get(l:profile, 'argv', get(l:profile, 'command', '')),
        \ v:false, v:false, v:false, l:cwd)
endfunc

func! planet#run#InitRunConfigurations() abort
  call planet#run#UpdateRunMenu()
endfunc

func! planet#run#AddConfig(profile = v:null) abort
  let l:profile = a:profile
  if l:profile is v:null
    let l:command = inputdialog('Run command (shell syntax, relative to build directory): ')
    if empty(l:command)
      return 0
    endif
    let l:profile = #{name: l:command, command: l:command, cwd: ''}
  endif
  return planet#run#SetProfiles(planet#run#Project().profiles + [l:profile])
endfunc

func! planet#run#EditConfig() abort
  let l:json = inputdialog('Run profiles (JSON array with name, argv or command, optional cwd): ',
        \ json_encode(planet#run#Project().profiles), 'CANCELLED')
  if l:json ==# 'CANCELLED' || empty(l:json)
    return 0
  endif
  try
    return planet#run#SetProfiles(json_decode(l:json))
  catch
    return s:Error('invalid run profile JSON: ' .. v:exception)
  endtry
endfunc

func! planet#run#UpdateRunMenu() abort
  silent! aunmenu ▶️&r
  let l:project = planet#run#Project()
  if !planet#menu#Visible('dev')
    return
  endif
  PlanetMenu an 510.10 ▶️&r.Run <Nop>
  an disable ▶️&r.Run
  for l:index in range(len(l:project.profiles))
    let l:name = '[' .. (l:index + 1) .. '] ' .. l:project.profiles[l:index].name
    execute 'PlanetMenu an 510.100 ▶️&r.' .. planet#menu#MenuifyName(l:name)
          \ .. ' <Cmd>call planet#run#Run(' .. l:index .. ')<CR>'
  endfor
  PlanetMenu an 510.500 ▶️&r.--1-- <Nop>
  PlanetMenu an 510.500 ▶️&r.Add\ Run\ Configuration <Cmd>call planet#run#AddConfig()<CR>
  PlanetMenu an 510.500 ▶️&r.Edit\ Run\ Configurations <Cmd>call planet#run#EditConfig()<CR>
endfunc

augroup PlanetVimRunProjects
  autocmd!
  autocmd TabEnter,DirChanged * call planet#run#UpdateRunMenu()
augroup END
