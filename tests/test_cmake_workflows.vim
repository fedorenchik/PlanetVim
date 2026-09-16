execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/project_settings.vim')
set hidden
let s:root = g:PV_test_dir .. '/cmake project 工作'
let s:build = g:PV_test_dir .. '/out of tree 工作'
call mkdir(s:root .. '/presets', 'p')
execute 'cd ' .. fnameescape(s:root)
call writefile(['cmake_minimum_required(VERSION 3.20)', 'project(PVWorkflow C)',
      \ 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/applications")',
      \ 'add_executable(one main.c)', 'add_executable(two main.c)',
      \ 'enable_testing()', 'add_test(NAME smoke COMMAND one "${CMAKE_BINARY_DIR}/ctest.txt")'], s:root .. '/CMakeLists.txt')
call writefile(['#include <stdio.h>', '#include <stdlib.h>',
      \ 'int main(int argc, char **argv) {', 'if (argc < 2) return 1;',
      \ 'FILE *f = fopen(argv[1], "w"); if (!f) return 2;',
      \ 'fprintf(f, "%s\n%s\n", getenv("PV_PRESET_ENV"), argc > 2 ? argv[2] : "test");',
      \ 'return fclose(f);', '}'], s:root .. '/main.c')
call writefile([json_encode({'version': 6, 'configurePresets': [{'name': 'base', 'hidden': v:true,
      \ 'generator': 'Ninja Multi-Config', 'binaryDir': '$env{PV_BUILD_DIR}',
      \ 'environment': {'PV_BUILD_DIR': s:build, 'PV_PRESET_ENV': '${presetName}'}}]})], s:root .. '/presets/base.json')
call writefile([json_encode({'version': 6, 'include': ['presets/base.json'],
      \ 'configurePresets': [{'name': 'development', 'inherits': 'base'},
      \ {'name': 'unavailable', 'inherits': 'base', 'condition': v:false}]})], s:root .. '/CMakePresets.json')
call writefile([json_encode({'version': 6, 'configurePresets': [{'name': 'private', 'inherits': 'development'}]})], s:root .. '/CMakeUserPresets.json')
call PlanetTestProjectSettings({'defaults': {'hidden': v:true, 'build_type': 'Debug', 'args': [s:root .. '/ran.txt', 'literal $argument 工作']}})
call assert_equal(['development', 'private'], sort(planet#cmake#Preset(planet#project#Context()).names))
call assert_equal(1, planet#cmake#Select('preset', 'development'))
call assert_equal(s:build, planet#project#Context().build_dir)
func! s:Wait(id) abort
  for l:i in range(2500)
    let l:run = planet#task#Status(a:id)
    if l:run.status !=# 'running' | return l:run | endif
    sleep 10m
  endfor
  call planet#task#Cancel(a:id)
  call assert_report('CMake workflow timeout')
  return planet#task#Status(a:id)
endfunc
let s:id = planet#task#Start('configure')
tabnew
execute 'tcd ' .. fnameescape(g:PV_test_dir)
let s:run = s:Wait(s:id)
call assert_equal('success', s:run.status, get(s:run, 'error', ''))
call assert_equal(s:build, planet#project#Context().build_dir, 'configure result is shared by every tab')
tabclose
let s:model = planet#cmake#Model(planet#project#Context())
call assert_equal(s:build, s:model.build_dir)
call assert_true(index(s:model.configurations, 'Release') >= 0)
call assert_equal(['one', 'two'], map(copy(s:model.targets), 'v:val.name'))
try
  call planet#task#Program(planet#project#Context())
  call assert_report('ambiguous executable accepted')
catch /choose one executable/
endtry
call assert_equal(1, planet#cmake#Select('target', 'two'))
call assert_equal(1, planet#cmake#Select('configuration', 'Release'))
let s:run = s:Wait(planet#task#Start('build-run'))
call assert_equal('success', s:run.status, get(s:run, 'error', ''))
call assert_equal(['development', 'literal $argument 工作'], readfile(s:root .. '/ran.txt'))
call assert_equal(s:build .. '/applications/Release/two', planet#task#Program(planet#project#Context()))
call assert_true(filereadable(s:build .. '/compile_commands.json'))
call assert_equal([s:build .. '/applications/Release/two', s:build], planet#task#Expand(['${program}', '${build}'], planet#project#Context()))
let s:run = s:Wait(planet#task#Start('build-test'))
call assert_equal('success', s:run.status, get(s:run, 'error', ''))
call assert_equal(['development', 'test'], readfile(s:build .. '/ctest.txt'))
" A failing rebuild must not launch a stale executable from the prior build.
call delete(s:root .. '/ran.txt')
call writefile(['this is not valid C;'], s:root .. '/main.c')
let s:run = s:Wait(planet#task#Start('build-run'))
call assert_equal('failed', s:run.status)
call assert_false(filereadable(s:root .. '/ran.txt'))
call assert_equal(['configure', 'build'], map(copy(s:run.results), 'v:val.task'))
call assert_true(len(s:run.results[-1].result.diagnostics) > 0)
" Selected state survives reloading the project and is used by clangd.
execute 'source ' .. fnameescape(g:PV_root .. '/.vim/pack/planet/start/planet.vim/autoload/planet/run.vim')
call assert_equal('development', planet#project#Context().preset)
call assert_equal('two', planet#project#Context().target)
execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')
call planet#intelligence#Register()
call assert_true(index(planet#intelligence#Status().clangd.command, '--compile-commands-dir=' .. s:build) >= 0)
