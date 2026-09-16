runtime plugin/development.vim
set hidden noexrc
let s:root = g:PV_test_dir .. "/settings user's 工作"
call mkdir(s:root, 'p')
execute 'cd ' .. fnameescape(s:root)
let s:file = planet#project#File()
call assert_equal(s:root .. '/.planetvim.vim', s:file)
call assert_match('/projects/.*\.vim$', planet#project#File(v:true))
let g:PV_project_sources = 0
let s:script = ['vim9script', 'g:PV_project_sources += 1',
      \ 'def Arguments(): list<string>', "  return ['first', 'space 工作']", 'enddef',
      \ 'export var config: dict<any> = {defaults: {args: Arguments()}}']
call writefile(s:script, s:file)
try
  call planet#project#Context()
  call assert_report('shared script executed without approval')
catch /review .* then run :PlanetProjectReload!/
endtry
call assert_equal(0, g:PV_project_sources)
PlanetProjectReload!
call assert_equal(['first', 'space 工作'], planet#project#Context().args)
call assert_equal(1, g:PV_project_sources)
let s:snapshot = planet#project#Settings()
let s:snapshot.defaults.args[0] = 'snapshot edit'
call assert_equal('first', planet#project#Context().args[0])
call assert_equal(1, g:PV_project_sources, 'settings execute once, not on every context read')

" Edits need an explicit reload, and changed shared code needs fresh approval.
let s:script[3] = "  return ['other', 'space 工作']"
call writefile(s:script, s:file)
call assert_equal('first', planet#project#Context().args[0])
try
  PlanetProjectReload
  call assert_report('changed shared script executed without approval')
catch /review .* then run :PlanetProjectReload!/
endtry
call assert_equal(1, g:PV_project_sources)
PlanetProjectReload!
call assert_equal('other', planet#project#Context().args[0])
call assert_equal(2, g:PV_project_sources)
PlanetProjectReload
call assert_equal(3, g:PV_project_sources, 'unchanged approved content can reload')

" Personal settings are normal user configuration and override shared values.
call writefile(['vim9script', "export var config: dict<any> = {defaults: {args: ['private']}}"], planet#project#File(v:true))
PlanetProjectReload
call assert_equal(['private'], planet#project#Context().args)
call delete(planet#project#File(v:true))
PlanetProjectReload
call assert_equal('other', planet#project#Context().args[0])

" Reinitializing the loader keeps approval on disk, not only in memory.
execute 'source ' .. fnameescape(g:PV_root .. '/.vim/pack/planet/start/planet.vim/autoload/planet/project.vim')
call assert_equal('other', planet#project#Context().args[0])
call assert_equal(6, g:PV_project_sources)

" A broken file fails visibly and is not re-executed by buffer events.
call writefile(['vim9script', 'g:PV_project_sources += 1', "throw 'broken configuration'"], s:file)
for s:attempt in [0, 1]
  try
    if s:attempt == 0
      PlanetProjectReload!
    else
      call planet#project#Context()
    endif
    call assert_report('broken settings accepted')
  catch /cannot load project settings .*broken configuration/
  endtry
endfor
call assert_equal(7, g:PV_project_sources)
for s:script in [['vim9script'], ['vim9script', "export var config = 'invalid'"],
      \ ["let s:config = {}"]]
  call writefile(s:script, s:file)
  try
    PlanetProjectReload!
    call assert_report('missing or invalid Vim9 config accepted')
  catch /Expected vim9script with export var config: dict<any>/
  endtry
endfor

" The editor creates a directly sourceable Vim9 template.
call delete(s:file)
PlanetProjectReload
PlanetProjectEdit
call assert_equal('vim', &filetype)
call assert_equal('vim9script', getline(1))
write
PlanetProjectReload!
call assert_equal({'defaults': {}, 'configurations': {}}, planet#project#Settings())
call assert_false(&exrc, 'project settings do not enable startup-local vimrc loading')
call planet#run#UpdateRunMenu()
call assert_match(':PlanetProjectReload!', menu_info('▶️r.Project.Trust and Load Shared Settings', 't').rhs)

" Native :source retains symlink names and can link them to an existing SID.
if has('unix')
  for s:already_sourced in [0, 1]
    let s:target = s:root .. '/actual ' .. s:already_sourced .. '.vim'
    call writefile(['vim9script', "export var config: dict<any> = {defaults: {args: ['linked']}}"], s:target)
    if s:already_sourced | execute 'source ' .. fnameescape(s:target) | endif
    call delete(s:file)
    call system('ln -s ' .. shellescape(s:target) .. ' ' .. shellescape(s:file))
    call assert_equal(0, v:shell_error)
    call assert_equal(['linked'], planet#project#Reload(v:true).args)
  endfor
endif
