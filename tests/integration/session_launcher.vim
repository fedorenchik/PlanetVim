if !has('gui_running') || has('win32') || !executable('gio')
  throw 'The session launcher integration test requires Linux GVim GUI and gio'
endif
let g:PV_applications_dir = g:PV_test_dir .. '/applications'
let s:source = g:PV_test_dir .. '/launcher source.txt'
let s:session = g:PV_test_dir .. "/session 'quoted' % $ name.vim"
let s:marker = g:PV_test_dir .. '/launch-result.json'
call writefile(['launcher fixture'], s:source)
execute 'edit ' .. fnameescape(s:source)
execute 'mksession! ' .. fnameescape(s:session)
call writefile(['call writefile([json_encode([v:this_session, expand("%:p")])], ' .. string(s:marker) .. ')', 'qa!'], s:session, 'a')
let s:launcher = planet#session#DesktopEntry(0, 0, s:session)
let s:job = planet#term#RunGuiApp(['gio', 'launch', s:launcher])
for s:attempt in range(400)
  if filereadable(s:marker) | break | endif
  sleep 25m
endfor
call assert_true(filereadable(s:marker), 'The freedesktop launcher did not open the session')
if filereadable(s:marker)
  call assert_equal([s:session, s:source], json_decode(join(readfile(s:marker), '')))
endif
call planet#session#DesktopEntry(1, 0, s:session)
call assert_false(filereadable(s:launcher))
