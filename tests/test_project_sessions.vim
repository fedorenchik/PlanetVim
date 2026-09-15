execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/project_settings.vim')
set hidden sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
let s:roots = [g:PV_test_dir .. '/session project A', g:PV_test_dir .. '/session project B']
for s:index in [0, 1]
  let s:root = s:roots[s:index]
  call mkdir(s:root .. '/sub', 'p')
  call writefile(['one', 'two', 'three'], s:root .. '/source.txt')
  if s:index | tabnew | endif
  execute 'tcd ' .. fnameescape(s:root)
  call PlanetTestProjectSettings({'default': 'debug', 'configurations': {
        \ 'debug': {'build_dir': 'debug'}, 'release': {'build_dir': 'release'}}})
  if s:index | call planet#project#Select('release') | endif
  execute 'edit ' .. fnameescape(s:root .. '/source.txt')
  call cursor(s:index + 2, 1)
  execute 'lcd ' .. fnameescape(s:root .. '/sub')
endfor
let s:session = g:PV_test_dir .. '/projects.session.vim'
call assert_equal(1, planet#session#SaveVariant('local', s:session, v:true))
tabonly
unlet! t:PV_projects
execute 'cd ' .. fnameescape(g:PV_test_dir)
call planet#session#OpenPath(s:session)
call assert_equal(2, tabpagenr('$'))
for s:index in [0, 1]
  execute 'tabnext ' .. (s:index + 1)
  let s:context = planet#project#Context()
  call assert_equal(s:roots[s:index], s:context.root)
  call assert_equal(s:roots[s:index] .. '/sub', getcwd())
  call assert_equal(s:index ? 'release' : 'debug', s:context.configuration)
  call assert_equal(s:roots[s:index] .. '/' .. s:context.configuration, s:context.build_dir)
  call assert_equal(s:index + 2, line('.'))
endfor
