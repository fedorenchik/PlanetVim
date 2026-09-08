let s:base = g:PV_test_dir .. '/generation'
let s:templates = s:base .. '/templates'
call mkdir(s:templates .. '/sample/nested', 'p')
call writefile(['sample content'], s:templates .. '/sample/nested/readme.txt')
call writefile(['never execute template environment'], s:templates .. '/sample/.envrc')
call writefile(0z00010AFFFE00, s:templates .. '/sample/binary.dat')
for s:name in ['electron-app', 'vue-3-app']
  call mkdir(s:templates .. '/' .. s:name, 'p')
  call writefile(['{"name":"fixture","version":"1.0.0"}'], s:templates .. '/' .. s:name .. '/package.json')
endfor
let g:PV_templates_dir = s:templates
let s:buffers = []
let s:callbacks = []

func! s:Native(path) abort
  let l:path = substitute(fnamemodify(a:path, ':p'), '[/\\]\+$', '', '')
  return has('win32') && !&shellslash ? substitute(l:path, '/', '\\', 'g') : l:path
endfunc

func! s:Completed(result, buffer) abort
  call add(s:callbacks, [a:result.status, a:result.exit_code])
endfunc

func! s:Wait(buffer) abort
  call assert_true(a:buffer > 0, 'generator starts')
  if a:buffer <= 0
    return {}
  endif
  call add(s:buffers, a:buffer)
  for l:index in range(200)
    call term_wait(a:buffer, 30)
    sleep 10m
    let l:result = planet#term#Result(a:buffer)
    if get(l:result, 'status', '') !=# 'running'
      return l:result
    endif
  endfor
  call assert_report('generator timed out')
  call planet#term#Cancel(a:buffer)
  return {}
endfunc

let s:options = #{hidden: v:true, on_exit: function('s:Completed')}
try
  let s:destination = s:base .. "/project with spaces 'quote' 工作"
  let s:result = s:Wait(planet#generate#Template('sample', s:destination, s:options))
  call assert_equal('success', get(s:result, 'status', ''))
  call assert_equal(['sample content'], readfile(s:destination .. '/nested/readme.txt'))
  call assert_equal(0z00010AFFFE00, readblob(s:destination .. '/binary.dat'))
  call assert_true(filereadable(s:destination .. '/.envrc'))
  call assert_false(isdirectory(s:destination .. '/sample'), 'template is not nested')
  call assert_equal(['success', 0], s:callbacks[-1])

  let s:empty = s:base .. '/existing empty'
  call mkdir(s:empty)
  call assert_equal('success', s:Wait(planet#generate#CopyDir('sample', s:empty, s:options)).status)
  call assert_true(filereadable(s:empty .. '/nested/readme.txt'))
  call assert_false(isdirectory(s:empty .. '/sample'))

  let s:terminals = len(term_list())
  call assert_equal(0, planet#generate#Template('sample', '', s:options), 'explicit empty destination cancels')
  call assert_equal(0, planet#generate#Template('sample', s:empty, s:options), 'nonempty destination is protected')
  call assert_equal(0, planet#generate#Template('sample', s:base .. '/missing-parent/new', s:options))
  call assert_equal(s:terminals, len(term_list()), 'preflight failures launch nothing')
  call assert_equal(['sample content'], readfile(s:empty .. '/nested/readme.txt'))

  let s:file = s:base .. '/file with spaces.txt'
  call assert_equal('success', s:Wait(planet#generate#CopyFile('sample/nested/readme.txt', s:file, s:options)).status)
  call assert_equal(['sample content'], readfile(s:file))
  call assert_equal(0, planet#generate#CopyFile('sample/nested/readme.txt', s:file, s:options))
  let s:missing = s:base .. '/invalid-template'
  call assert_equal('failed', s:Wait(planet#generate#Template('../sample', s:missing, s:options)).status)
  call assert_false(isdirectory(s:missing))

  " Plain framework creation copies one deterministic template and never calls
  " npm, even if a deliberately missing npm command is configured.
  let s:offline = s:base .. '/electron offline'
  let s:offline_options = extend(copy(s:options), #{npm: 'missing-planetvim-npm-command'})
  call assert_equal('success', s:Wait(planet#generate#Framework('electron', s:offline, s:offline_options)).status)
  call assert_true(filereadable(s:offline .. '/package.json'))
  call assert_false(isdirectory(s:offline .. '/electron offline'))

  let s:record = s:base .. '/tool-record.json'
  let s:stub = s:base .. '/mock tool.py'
  call writefile([
        \ 'import json, os, sys',
        \ 'from pathlib import Path',
        \ 'Path(' .. json_encode(s:record) .. ').write_text(json.dumps({"argv":sys.argv[1:], "cwd":os.getcwd()}))',
        \ 'sys.exit(7)'], s:stub)
  let s:install_options = extend(copy(s:options), #{install: v:true, open: v:true,
        \ npm: planet#generate#Python() + [s:stub]})
  let s:tabs = tabpagenr('$')
  let s:failed = s:base .. '/vue failed install'
  let s:result = s:Wait(planet#generate#Framework('vue3', s:failed, s:install_options))
  call assert_equal('failed', s:result.status)
  call assert_equal(7, s:result.exit_code)
  call assert_equal(s:tabs, tabpagenr('$'), 'failed installation does not open the project')
  call assert_true(filereadable(s:failed .. '/package.json'), 'failed install retains generated project for inspection')
  let s:recorded = json_decode(readfile(s:record)[0])
  call assert_equal(['install'], s:recorded.argv, 'no implicit npm start or fallback')
  call assert_equal(s:Native(s:failed), s:Native(s:recorded.cwd))
  call assert_equal(['failed', 7], s:callbacks[-1])

  let s:no_tool = s:base .. '/missing dependency'
  call assert_equal('failed', s:Wait(planet#generate#Framework('electron', s:no_tool,
        \ extend(copy(s:options), #{install: v:true, npm: 'missing-planetvim-npm-command'}))).status)
  call assert_false(isdirectory(s:no_tool), 'missing tools are checked before writing')

  call writefile([
        \ 'import json, sys',
        \ 'from pathlib import Path',
        \ 'destination=Path(sys.argv[1])',
        \ 'destination.mkdir(exist_ok=True)',
        \ '(destination / "package.json").write_text("{}")'], s:stub)
  let s:nuxt = s:base .. '/nuxt generated'
  let s:nuxt_options = extend(copy(s:options), #{nuxt: planet#generate#Python() + [s:stub]})
  call assert_equal('success', s:Wait(planet#generate#Framework('nuxt', s:nuxt, s:nuxt_options)).status)
  call assert_true(filereadable(s:nuxt .. '/package.json'))
  call assert_false(isdirectory(s:nuxt .. '/nuxt generated'))

  " Opening happens only after successful copying, with the resulting directory.
  let s:opened = s:base .. '/open project'
  call assert_equal('success', s:Wait(planet#generate#Template('sample', s:opened,
        \ extend(copy(s:options), #{open: v:true}))).status)
  call assert_equal(s:tabs + 1, tabpagenr('$'))
  call assert_equal(s:Native(s:opened), s:Native(getcwd()))
  tabclose!
finally
  for s:buffer in s:buffers
    if bufexists(s:buffer)
      execute 'silent! bwipeout! ' .. s:buffer
    endif
  endfor
  unlet! g:PV_templates_dir
endtry
