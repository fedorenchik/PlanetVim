vim9script

var script_legacy_imported = v:false

def LocalError(message: any): any
  echohl ErrorMsg
  echomsg 'PlanetVim: ' .. message
  echohl None
  return 0
enddef

export def Path(arg_path: any, base: any): any
  var path: any = arg_path =~# '^[/\\]\|^\a:[/\\]' ? arg_path : base .. '/' .. arg_path
  return fnamemodify(simplify(path) .. '/', ':p:h')
enddef

def LocalStateFile(root: any): any
  return planet#paths#State('projects') .. '/' .. sha256(root) .. '.json'
enddef

def LocalValidate(profiles: any): any
  if type(profiles) != v:t_list
    throw 'run profiles must be a JSON array'
  endif
  for profile in profiles
    if type(profile) != v:t_dict || type(get(profile, 'name', 0)) != v:t_string || empty(profile.name) || type(get(profile, 'cwd', '')) != v:t_string
      throw 'each run profile needs a name and an optional cwd String'
    endif
    if has_key(profile, 'argv') == has_key(profile, 'command')
      throw 'each run profile needs exactly one of argv or command'
    endif
    if has_key(profile, 'argv')
      if type(profile.argv) != v:t_list || empty(profile.argv) || ! empty(filter(copy(profile.argv), (_, lambda_value) => type(lambda_value) != v:t_string)) || empty(profile.argv[0])
        throw 'profile argv must be a nonempty List of Strings'
      endif
    elseif type(profile.command) != v:t_string || empty(profile.command)
      throw 'profile command must be a nonempty shell script String'
    endif
  endfor
  return 0
enddef

# Tab cwd is the project identity; window-local cwd changes do not select a
# different project. Profiles live in user state, never executable project files.
export def Project(): any
  var project: any
  var file: any
  var saved: any
  var root: any = fnamemodify(resolve(getcwd(-1, 0)), ':p:h')
  if ! exists('t:PV_projects')
    t:PV_projects = {}
  endif
  if ! has_key(t:PV_projects, root)
    project = {root: root, build_dir: '', profiles: []}
    file = LocalStateFile(root)
    if filereadable(file)
      try
        saved = json_decode(join(readfile(file), "\n"))
        if type(saved) != v:t_dict || get(saved, 'root', '') !=# root || type(get(saved, 'build_dir', 0)) != v:t_string
          throw 'invalid project state'
        endif
        LocalValidate(get(saved, 'profiles', v:null))
        project = saved
      catch
        LocalError('cannot load project state: ' .. v:exception)
      endtry
    elseif ! script_legacy_imported
      project.build_dir = get(g:, 'PV_build_dir', '')
      if ! empty(project.build_dir)
        project.build_dir = planet#run#Path(project.build_dir, root)
      endif
      for command in split(get(g:, 'PV_run_configurations', ''), ',')
        add(project.profiles, {name: command, command: command, cwd: ''})
      endfor
    endif
    script_legacy_imported = v:true
    t:PV_projects[root] = project
  endif
  project = t:PV_projects[root]
  g:PV_build_dir = project.build_dir
  # Keep the legacy variables readable; all new commands use structured state.
  g:PV_run_configurations = join(map(copy(project.profiles), (_, lambda_profile) => lambda_profile.name), ',')
  return project
enddef

export def Save(): any
  var project: any = planet#run#Project()
  var file: any = LocalStateFile(project.root)
  var temporary: any = file .. '.' .. getpid() .. '.tmp'
  try
    writefile([json_encode(project)], temporary)
    setfperm(temporary, 'rw-------')
    if rename(temporary, file) != 0
      throw 'cannot replace ' .. file
    endif
  catch
    delete(temporary)
    return LocalError('cannot save project state: ' .. v:exception)
  endtry
  return 1
enddef

export def SetProfiles(profiles: any): any
  try
    LocalValidate(profiles)
  catch
    return LocalError(v:exception)
  endtry
  var project: any = planet#run#Project()
  var previous: any = project.profiles
  project.profiles = deepcopy(profiles)
  if ! planet#run#Save()
    project.profiles = previous
    g:PV_run_configurations = join(map(copy(previous), (_, lambda_profile) => lambda_profile.name), ',')
    return 0
  endif
  planet#run#UpdateRunMenu()
  return 1
enddef

export def Run(index: any): any
  var profile: any
  var project: any = planet#run#Project()
  if index < 0 || index >= len(project.profiles)
    return LocalError('run profile does not exist in this project')
  endif
  profile = project.profiles[index]
  var cwd: any = get(profile, 'cwd', '')
  if empty(cwd)
    cwd = empty(project.build_dir) ? project.root : project.build_dir
  elseif cwd !~# '^[/\\]\|^\a:[/\\]'
    cwd = project.root .. '/' .. cwd
  endif
  return planet#term#RunCmd(get(profile, 'argv', get(profile, 'command', '')), v:false, v:false, v:false, cwd)
enddef

export def InitRunConfigurations(): any
  planet#run#UpdateRunMenu()
  return 0
enddef

export def AddConfig(arg_profile: any = v:null): any
  var command: any
  var profile: any = arg_profile
  if profile == null
    command = inputdialog('Run command (shell syntax, relative to build directory): ')
    if empty(command)
      return 0
    endif
    profile = {name: command, command: command, cwd: ''}
  endif
  return planet#run#SetProfiles(planet#run#Project().profiles + [profile])
enddef

export def EditConfig(): any
  var json: any = inputdialog('Run profiles (JSON array with name, argv or command, optional cwd): ', json_encode(planet#run#Project().profiles), 'CANCELLED')
  if json ==# 'CANCELLED' || empty(json)
    return 0
  endif
  try
    return planet#run#SetProfiles(json_decode(json))
  catch
    return LocalError('invalid run profile JSON: ' .. v:exception)
  endtry
enddef

export def UpdateRunMenu(): any
  var name: any
  silent! aunmenu ▶️&r
  var project: any = planet#run#Project()
  if !planet#menu#Visible('dev')
    return 0
  endif
  PlanetMenu an 510.10 ▶️&r.Run <Nop>
  an disable ▶️&r.Run
  for index in range(len(project.profiles))
    name = '[' .. (index + 1) .. '] ' .. project.profiles[index].name
    execute 'PlanetMenu an 510.100 ▶️&r.' .. planet#menu#MenuifyName(name) .. ' <Cmd>call planet#run#Run(' .. index .. ')<CR>'
  endfor
  PlanetMenu an 510.500 ▶️&r.--1-- <Nop>
  PlanetMenu an 510.500 ▶️&r.Add\ Run\ Configuration <Cmd>call planet#run#AddConfig()<CR>
  PlanetMenu an 510.500 ▶️&r.Edit\ Run\ Configurations <Cmd>call planet#run#EditConfig()<CR>
  return 0
enddef

augroup PlanetVimRunProjects
  autocmd!
  autocmd TabEnter,DirChanged * call planet#run#UpdateRunMenu()
augroup END
