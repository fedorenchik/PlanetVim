execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/project_settings.vim')
set hidden sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
let s:root = g:PV_test_dir .. '/session project'
call mkdir(s:root, 'p')
execute 'cd ' .. fnameescape(s:root)
call PlanetTestProjectSettings({'default': 'debug', 'configurations': {
      \ 'debug': {'build_dir': 'debug'}, 'release': {'build_dir': 'release'}}})
call planet#project#Select('release')
for s:index in [0, 1]
  let s:directory = s:root .. '/part ' .. s:index
  call mkdir(s:directory .. '/sub', 'p')
  call writefile(['one', 'two', 'three'], s:directory .. '/source.txt')
  if s:index | tabnew | endif
  execute 'tcd ' .. fnameescape(s:directory)
  execute 'edit ' .. fnameescape(s:directory .. '/source.txt')
  call cursor(s:index + 2, 1)
  execute 'lcd ' .. fnameescape(s:directory .. '/sub')
endfor
let s:session = g:PV_test_dir .. '/project.session.vim'
call assert_equal(1, planet#session#SaveVariant('local', s:session, v:true))
tabonly
execute 'cd ' .. fnameescape(g:PV_test_dir)
execute 'source ' .. fnameescape(g:PV_root .. '/.vim/pack/planet/start/planet.vim/autoload/planet/run.vim')
call planet#session#OpenPath(s:session)
call assert_equal(2, tabpagenr('$'))
for s:index in [0, 1]
  execute 'tabnext ' .. (s:index + 1)
  let s:context = planet#project#Context()
  call assert_equal(s:root, s:context.root)
  call assert_equal(s:root, getcwd(-1))
  call assert_equal(s:root .. '/part ' .. s:index .. '/sub', getcwd())
  call assert_equal('release', s:context.configuration)
  call assert_equal(s:root .. '/release', s:context.build_dir)
  call assert_equal(s:index + 2, line('.'))
endfor
