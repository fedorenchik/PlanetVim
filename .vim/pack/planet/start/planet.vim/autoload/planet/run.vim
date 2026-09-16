vim9script

var script_legacy_imported = v:false
var instance_project: dict<any> = {}

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

# One active project follows Vim's global cwd, including native session restore.
export def Project(): any
  var project = instance_project
  var file: any
  var saved: any
  var root: any = planet#project#Root()
  if get(project, 'root', '') !=# root
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
    instance_project = project
  endif
  g:PV_build_dir = project.build_dir
  # Keep the legacy variables readable; all new commands use structured state.
  g:PV_run_configurations = join(map(copy(project.profiles), (_, lambda_profile) => lambda_profile.name), ',')
  return project
enddef

export def Save(project: any = planet#run#Project()): any
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
  var context = planet#project#Context()
  var cwd: any = get(profile, 'cwd', '')
  if empty(cwd)
    cwd = empty(context.build_dir) ? project.root : context.build_dir
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
  PlanetMenu an 510.510 ▶️&r.Project.Select\ Configuration <Cmd>PlanetProjectSelect<CR>
  PlanetMenu an 510.520 ▶️&r.Project.Show\ Configuration <Cmd>PlanetProjectInfo<CR>
  PlanetMenu an 510.530 ▶️&r.Project.Edit\ Shared\ Settings <Cmd>PlanetProjectEdit<CR>
  PlanetMenu an 510.540 ▶️&r.Project.Edit\ Private\ Settings <Cmd>PlanetProjectLocal<CR>
  PlanetMenu an 510.550 ▶️&r.Project.Reload\ Settings <Cmd>PlanetProjectReload<CR>
  PlanetMenu an 510.560 ▶️&r.Project.Trust\ and\ Load\ Shared\ Settings <Cmd>PlanetProjectReload!<CR>
  PlanetMenu an 510.600 ▶️&r.Tasks.Choose\ Task <Cmd>PlanetTask<CR>
  PlanetMenu an 510.610 ▶️&r.Tasks.Build\ and\ Run <Cmd>PlanetTask build-run<CR>
  PlanetMenu an 510.620 ▶️&r.Tasks.Build\ and\ Test <Cmd>PlanetTask build-test<CR>
  PlanetMenu an 510.630 ▶️&r.Tasks.Build\ and\ Debug <Cmd>PlanetTask build-debug<CR>
  PlanetMenu an 510.640 ▶️&r.Tasks.Rerun\ Last <Cmd>PlanetTaskRerun<CR>
  PlanetMenu an 510.650 ▶️&r.Tasks.Cancel <Cmd>PlanetTaskCancel<CR>
  PlanetMenu an 510.660 ▶️&r.Tasks.Show\ Results <Cmd>PlanetTasks<CR>
  PlanetMenu an 510.670 ▶️&r.Tasks.Show\ Diagnostics <Cmd>PlanetCommandDiagnostics<CR>
  PlanetMenu an 510.680 ▶️&r.Tasks.Open\ Raw\ Log <Cmd>PlanetCommandLog<CR>
  return 0
enddef

augroup PlanetVimRun
  autocmd!
  autocmd DirChanged global call planet#run#UpdateRunMenu()
augroup END
