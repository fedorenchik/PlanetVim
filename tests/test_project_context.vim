let s:root = g:PV_test_dir .. '/workspace 工作'
call mkdir(s:root, 'p')
execute 'tcd ' .. fnameescape(s:root)
let s:settings = {'version': 1, 'default': 'debug', 'defaults': {'environment': {'COMMON': 'shared'}, 'args': ['a b']},
      \ 'configurations': {'debug': {'build_dir': 'out/debug', 'program': 'out/debug/app'}, 'release': {'build_dir': 'out/release'}}}
call writefile([json_encode(s:settings)], planet#project#File())
call writefile([json_encode({'defaults': {'environment': {'LOCAL': 'private'}}, 'configurations': {'debug': {'args': ['local arg']}}})], planet#project#File(v:true))
let s:context = planet#project#Context()
call assert_equal(s:root .. '/out/debug', s:context.build_dir)
call assert_equal({'COMMON': 'shared', 'LOCAL': 'private'}, s:context.environment)
call assert_equal(['local arg'], s:context.args)
call assert_equal(1, planet#project#Select('release'))
call assert_equal(['a b'], planet#project#Context().args)
call assert_equal(1, planet#build#NewBuildDir('custom release'))
call assert_equal(s:root .. '/custom release', planet#build#GetBuildDir())
call planet#project#Select('debug')
call assert_equal(s:root .. '/out/debug', planet#build#GetBuildDir())
unlet t:PV_projects
call assert_equal('debug', planet#project#Context().configuration)
call assert_equal('debug', s:context.configuration, 'captured context is independent of selection')
call mkdir(s:root .. '/sub', 'p')
execute 'lcd ' .. fnameescape(s:root .. '/sub')
call assert_equal(s:root, planet#project#Context().root, 'window-local cwd cannot change project')
tabnew
execute 'tcd ' .. fnameescape(g:PV_test_dir)
call assert_equal('', planet#project#Context().configuration)
tabclose
call assert_equal(s:root, planet#project#Context().root)
call writefile(['{"version": 2}'], planet#project#File())
try
  call planet#project#Context()
  call assert_report('unsupported settings version accepted')
catch /invalid project settings/
endtry
call writefile([json_encode(s:settings)], planet#project#File())
