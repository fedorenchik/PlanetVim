let s:checks = planet#health#Check()
call assert_true(len(s:checks) > 15)
call assert_equal([], filter(deepcopy(s:checks), {_, item -> !item.ok && !get(item, 'optional', 0)}))
call planet#health#FirstRun()
call assert_true(filereadable(planet#paths#State() .. '/onboarding-seen'))
call planet#health#Show()
call assert_equal('nofile', &buftype)
call assert_false(&modifiable)
call assert_match('PlanetVim health check', getline(1))
let g:PV_state_dir = g:PV_test_dir .. '/not-a-directory'
call writefile(['occupied'], g:PV_state_dir)
let s:checks = planet#health#Check()
call assert_equal(1, len(filter(s:checks, {_, item -> item.name ==# 'State directory' && !item.ok})))
call assert_equal(['occupied'], readfile(g:PV_state_dir))

" Doctor inspects configured executables without launching them or creating
" missing configuration/cache directories.
let s:original_state = g:PV_state_dir
let s:missing_state = g:PV_test_dir .. '/doctor-must-not-create/state'
let g:PV_state_dir = s:missing_state
let s:marker = g:PV_test_dir .. '/doctor-executed-tool'
let s:fake = g:PV_test_dir .. '/doctor-tool.py'
call writefile(['from pathlib import Path', 'Path(' .. json_encode(s:marker) .. ').write_text("launched")'], s:fake)
let s:python = executable('python3') ? exepath('python3') : exepath('python')
let g:PV_python = [s:python]
let g:PV_clangd_argv = [s:python, s:fake]
let g:PV_pandoc_argv = [s:python, s:fake]
let g:PV_debugpy_command = [s:python, s:fake]
let g:PV_debug_tools = #{lldb:[s:python, s:fake]}
let g:PV_test_tools = #{ffmpeg:[s:python, s:fake]}
let g:PV_integration_tools = #{qvkgen:[s:python, s:fake], uic:'planetvim-missing-health-uic'}
let s:terminals = len(term_list())
let s:checks = planet#health#Check()
call assert_false(filereadable(s:marker), 'Doctor never runs configured tool commands')
call assert_false(isdirectory(s:missing_state), 'Doctor never creates missing directories')
call assert_equal(s:terminals, len(term_list()))
let s:names = map(copy(s:checks), {_, item -> item.name})
for s:name in ['Generation Python', 'C++ language server', 'Markdown preview', 'Python debug adapter command',
      \ 'GDB debug adapter command', 'Debug tool: lldb', 'Test tool: ffmpeg', 'Tool: qvkgen', 'Tool: uic',
      \ 'Tool: docker', 'Tool: sdkmanager', 'Tool: ffmpeg', 'Tool: ngrok', 'Tool: x11vnc', 'Clap native Maple']
  call assert_true(index(s:names, s:name) >= 0, s:name .. ' covered')
endfor
call assert_true(len(filter(copy(s:checks), {_, item -> item.name =~# '^Tool: '})) > 100)
for s:name in ['C++ language server', 'Markdown preview', 'Tool: qvkgen', 'Debug tool: lldb', 'Test tool: ffmpeg']
  let s:item = filter(copy(s:checks), {_, item -> item.name ==# s:name})[0]
  call assert_true(s:item.ok, s:name .. ' honors configured executable')
  call assert_equal([s:python, s:fake], s:item.argv)
endfor
call assert_false(filter(copy(s:checks), {_, item -> item.name ==# 'Tool: uic'})[0].ok)
call assert_equal('unverified', filter(copy(s:checks), {_, item -> item.name ==# 'Python debug adapter command'})[0].status)
let g:PV_state_dir = s:original_state
unlet! g:PV_python g:PV_clangd_argv g:PV_pandoc_argv g:PV_debugpy_command g:PV_debug_tools g:PV_test_tools g:PV_integration_tools
