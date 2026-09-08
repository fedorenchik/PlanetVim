let s:base = g:PV_test_dir .. '/project tests'
let s:root = s:base .. '/project A 工作'
let s:other = s:base .. '/project B'
call mkdir(s:root, 'p')
call mkdir(s:other, 'p')
let s:original_tab = tabpagenr()
let s:original_cwd = getcwd(-1, 0)
let s:buffers = []

func! s:Wait(buffer) abort
  call assert_true(a:buffer > 0, 'command started')
  if a:buffer <= 0
    return {}
  endif
  call add(s:buffers, a:buffer)
  for l:i in range(1000)
    call term_wait(a:buffer, 20)
    sleep 10m
    if planet#term#Result(a:buffer).status !=# 'running'
      return planet#term#Result(a:buffer)
    endif
  endfor
  call planet#term#Cancel(a:buffer)
  call assert_report('project command timed out')
  return {}
endfunc

try
  execute 'tcd ' .. fnameescape(s:root)
  call assert_equal('', planet#build#GetBuildDir())
  call assert_equal(1, planet#build#NewBuildDir('build space'))
  let s:first_build = s:root .. '/build space'
  call assert_equal(s:first_build, planet#build#GetBuildDir())
  call assert_true(index(planet#build#BuildDirs(), s:first_build) >= 0)
  call assert_equal(0, planet#build#SelectBuildDir(999))
  call assert_equal(0, planet#build#SelectBuildDir(0))
  call assert_equal(0, planet#build#SelectBuildDir(len(planet#build#BuildDirs()) + 1, ''))
  call assert_equal(s:first_build, planet#build#GetBuildDir())

  let s:profile = #{name: 'quoted "profile", with comma', argv: ['./app', 'two words', 'a,b'], cwd: ''}
  call assert_equal(1, planet#run#SetProfiles([s:profile]))
  call assert_equal(0, planet#run#SetProfiles([#{name: 'invalid', argv: []}]))
  call assert_equal([s:profile], planet#run#Project().profiles)
  call assert_equal(0, planet#run#Run(99))
  unlet t:PV_projects
  call planet#run#InitRunConfigurations()
  call assert_equal([s:profile], planet#run#Project().profiles)
  call assert_equal(s:first_build, planet#build#GetBuildDir())

  tabnew
  execute 'tcd ' .. fnameescape(s:other)
  call assert_equal('', planet#build#GetBuildDir(), 'other project has no inherited build tree')
  call assert_equal([], planet#run#Project().profiles, 'other project has no inherited commands')
  call assert_equal(0, planet#build#Build())
  call assert_equal(1, planet#build#NewBuildDir('build other'))
  tabclose
  call assert_equal(s:first_build, planet#build#GetBuildDir())
  call assert_equal([s:profile], planet#run#Project().profiles)

  call assert_true(executable('cmake'), 'CMake is required for the project integration fixture')
  if executable('cmake')
    call writefile([
          \ 'cmake_minimum_required(VERSION 3.20)',
          \ 'project(PlanetFixture C)',
          \ 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")',
          \ 'foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)',
          \ '  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${config} "${CMAKE_BINARY_DIR}/bin")',
          \ 'endforeach()',
          \ 'add_executable(pv_test main.c)'], s:root .. '/CMakeLists.txt')
    call writefile([
          \ '#include <stdio.h>',
          \ 'int main(int argc, char **argv) {',
          \ '  if (argc < 2) return 1;',
          \ '  FILE *out = fopen(argv[1], "w");',
          \ '  if (!out) return 2;',
          \ '  for (int i = 2; i < argc; ++i) fprintf(out, "%s\n", argv[i]);',
          \ '  return fclose(out) == 0 ? 0 : 3;',
          \ '}'], s:root .. '/main.c')
    let s:executable = './bin/pv_test' .. (has('win32') ? '.exe' : '')
    let s:arguments = ['two words', 'a,b', "apostrophe's", 'a"quote', '$literal']
    call assert_equal(1, planet#run#SetProfiles([
          \ #{name: 'native "args", comma', argv: [s:executable, 'args.txt'] + s:arguments, cwd: ''}]))
    for s:build in ['build space', '../build-project A 工作']
      call assert_equal(1, planet#build#NewBuildDir(s:build))
      let s:directory = planet#build#GetBuildDir()
      call assert_equal('success', get(s:Wait(planet#build#Configure(v:true)), 'status', ''))
      call assert_true(filereadable(s:directory .. '/compile_commands.json'))
      call assert_equal('success', get(s:Wait(planet#build#Build()), 'status', ''))
      call assert_equal('success', get(s:Wait(planet#run#Run(0)), 'status', ''))
      call assert_equal(s:arguments, readfile(s:directory .. '/args.txt'))
    endfor
    " A menu action stores an index, so changes to the build directory remain
    " effective without rebuilding the profile or embedding quoted Vim code.
    call planet#build#NewBuildDir('build space')
    let s:name = '[1] native "args", comma'
    execute 'emenu ▶️&r.' .. planet#menu#MenuifyName(s:name)
    " The direct run assertion above verifies argv; inspect the current project
    " state here because repeated output buffer names are permitted by Vim.
    call assert_equal(s:first_build, planet#build#GetBuildDir())
    for s:item in term_list()
      if get(getbufvar(s:item, 'planet_result', {}), 'status', '') ==# 'running'
        call s:Wait(s:item)
      endif
    endfor
    call assert_equal(s:arguments, readfile(s:first_build .. '/args.txt'))
  endif
finally
  for s:buffer in s:buffers
    if bufexists(s:buffer)
      call planet#term#Cancel(s:buffer)
      execute 'silent! bwipeout! ' .. s:buffer
    endif
  endfor
  execute 'tabnext ' .. s:original_tab
  execute 'tcd ' .. fnameescape(s:original_cwd)
endtry
