let s:root = g:PV_test_dir .. '/SDK project 工作'
call mkdir(s:root, 'p')
execute 'cd ' .. fnameescape(s:root)
let s:file = s:root .. "/input 'quoted' & file.ui"
call writefile(['fixture'], s:file)
execute 'edit ' .. fnameescape(s:file)
let s:buffers = []
let s:specs = planet#integrations#Specs()
let g:PV_integration_tools = {}
let s:python = planet#generate#Python()
let s:python[0] = exepath(s:python[0])
let s:record = s:root .. '/arguments.json'
let s:sanitizer_result = {}
let s:stub = s:root .. '/tool fixture.py'
call writefile(['import json, os, sys',
      \ 'from pathlib import Path',
      \ 'Path(' .. json_encode(s:record) .. ').write_text(json.dumps({"argv":sys.argv[1:],"cwd":os.getcwd()}))',
      \ 'sys.exit(7)'], s:stub)

func! s:Wait(buffer) abort
  call assert_true(a:buffer > 0, 'process starts')
  if a:buffer <= 0 | return {} | endif
  call add(s:buffers, a:buffer)
  for l:n in range(250)
    call term_wait(a:buffer, 20)
    sleep 10m
    let l:result = planet#term#Result(a:buffer)
    if get(l:result, 'status', '') !=# 'running' | return l:result | endif
  endfor
  call assert_report('SDK process timed out')
  call planet#term#Cancel(a:buffer)
  return {}
endfunc

func! s:Sanitized(result, buffer) abort
  let s:sanitizer_result = a:result
  call add(s:buffers, a:buffer)
endfunc

try
  " Validate every declarative command with a native argv fixture. This checks
  " required-input resolution without installing/launching unrelated SDKs.
  for [s:id, s:spec] in items(s:specs)
    if has('win32') && get(s:spec, 'linux', v:false) | continue | endif
    let s:tool = substitute(s:spec.argv[0], '%root%', '\=s:root', 'g')
    let g:PV_integration_tools[s:tool] = s:python + [s:stub]
    let s:values = {}
    for s:field in s:spec.fields
      let s:values[s:field.name] = s:field.kind ==# 'file' ? s:file
            \ : s:field.kind ==# 'dir' ? s:root
            \ : s:field.kind ==# 'output' ? s:root .. '/generated output'
            \ : s:field.kind =~# 'args$' ? ['literal value', '$PATH', 'a&b']
            \ : s:field.kind ==# 'pid' ? '123' : 'literal value'
    endfor
    let s:plan = planet#integrations#Plan(s:id, s:values)
    call assert_equal(s:python + [s:stub], s:plan.argv[0:len(s:python)], s:id)
    call assert_equal(fnamemodify(s:root, ':p'), fnamemodify(s:plan.cwd, ':p'), s:id)
    call assert_equal([], filter(copy(s:plan.argv), {_, v -> v =~# '%\(root\|file\|build\)%\|{\w\+}'}), s:id)
  endfor
  call assert_true(len(s:specs) >= 100)
  let s:output = s:root .. "/out 'quote' & value.h"
  let s:result = s:Wait(planet#integrations#Run('uic', #{file:s:file, output:s:output}, #{hidden:v:true}))
  call assert_equal('failed', s:result.status)
  call assert_equal(7, s:result.exit_code)
  let s:recorded = json_decode(join(readfile(s:record), "\n"))
  call assert_equal([s:file, '-o', s:output], s:recorded.argv)
  call assert_equal(fnamemodify(s:root, ':p'), fnamemodify(s:recorded.cwd, ':p'))
  let s:count = len(term_list())
  call assert_equal(0, planet#integrations#Run('uic', #{file:'', output:s:output}, #{hidden:v:true}), 'cancel launches nothing')
  call assert_equal(0, planet#integrations#Run('uic', #{file:s:root .. '/absent', output:s:output}, #{hidden:v:true}))
  call assert_equal(s:count, len(term_list()))
  let g:PV_integration_tools.uic = 'planetvim-missing-uic'
  call assert_equal(0, planet#integrations#Run('uic', #{file:s:file, output:s:output}, #{hidden:v:true}), 'missing prerequisite launches nothing')

  " A real installed Qt tool compiles a small form; this exercises output-file
  " creation with spaces and quote characters, beyond the argv fixture.
  let g:PV_integration_tools = {}
  try
    let s:uic = planet#integrations#Tool('uic', v:true)
  catch
    let s:uic = []
  endtry
  if ! empty(s:uic)
    call writefile(['<?xml version="1.0" encoding="UTF-8"?>',
          \ '<ui version="4.0"><class>Form</class><widget class="QWidget" name="Form"/><resources/><connections/></ui>'], s:file)
    let s:result = s:Wait(planet#integrations#Run('uic', #{file:s:file, output:s:output}, #{hidden:v:true}))
    call assert_equal('success', s:result.status)
    call assert_match('class Ui_Form', join(readfile(s:output), "\n"))
  endif

  if ! has('win32') && executable('bash')
    let s:setup = s:root .. "/setup 'sdk'.sh"
    call writefile(['export PLANETVIM_SDK_FIXTURE="value with spaces"'], s:setup)
    let s:previous = getenv('PLANETVIM_SDK_FIXTURE')
    call assert_equal('success', s:Wait(planet#integrations#Environment('fixture', s:setup, [], #{hidden:v:true})).status)
    call assert_equal('value with spaces', getenv('PLANETVIM_SDK_FIXTURE'))
    call assert_equal(1, planet#integrations#RestoreEnvironment())
    call assert_equal(s:previous, getenv('PLANETVIM_SDK_FIXTURE'))
    let $PLANETVIM_SDK_REMOVED = 'original'
    call writefile(['unset PLANETVIM_SDK_REMOVED'], s:setup)
    call assert_equal('success', s:Wait(planet#integrations#Environment('fixture', s:setup, [], #{hidden:v:true})).status)
    call assert_equal(v:null, getenv('PLANETVIM_SDK_REMOVED'))
    call planet#integrations#RestoreEnvironment()
    call assert_equal('original', getenv('PLANETVIM_SDK_REMOVED'))
    call setenv('PLANETVIM_SDK_REMOVED', v:null)
    call writefile(['export PLANETVIM_SDK_FIXTURE="should not apply"', 'return 9'], s:setup)
    call assert_equal(9, s:Wait(planet#integrations#Environment('fixture', s:setup, [], #{hidden:v:true})).exit_code)
    call assert_equal(s:previous, getenv('PLANETVIM_SDK_FIXTURE'))
  endif
  let s:conf = s:root .. '/qt.conf'
  call assert_equal(1, planet#integrations#Write('qt-conf', s:conf, '/opt/Qt SDK'))
  call assert_equal(['[Paths]', 'Prefix=/opt/Qt SDK'], readfile(s:conf))
  call assert_equal(0, planet#integrations#Write('qt-conf', s:conf, 'must not overwrite'))
  call assert_equal(['[Paths]', 'Prefix=/opt/Qt SDK'], readfile(s:conf))
  if ! has('win32') && executable('cmake') && executable('cc')
    call writefile(['cmake_minimum_required(VERSION 3.16)', 'project(planetvim_fixture C)',
          \ 'add_executable(sanitizer_fixture main.c)'], s:root .. '/CMakeLists.txt')
    call writefile(['int main(void) { return 0; }'], s:root .. '/main.c')
    let s:build = s:root .. '/build-sanitizer'
    call assert_equal('success', s:Wait(planet#integrations#Run('ubsan', #{directory:s:build},
          \ #{hidden:v:true, on_exit:function('s:Sanitized')})).status)
    for s:n in range(600)
      if ! empty(s:sanitizer_result) | break | endif
      sleep 10m
    endfor
    call assert_equal('success', get(s:sanitizer_result, 'status', ''), 'configure success chains to real sanitizer build')
    call assert_true(executable(s:build .. '/sanitizer_fixture'))
    call assert_equal('success', s:Wait(planet#integrations#Command([s:build .. '/sanitizer_fixture'], #{hidden:v:true})).status)
  endif
finally
  unlet! g:PV_integration_tools
  for s:buffer in s:buffers
    if bufexists(s:buffer) | execute 'silent! bwipeout! ' .. s:buffer | endif
  endfor
endtry
