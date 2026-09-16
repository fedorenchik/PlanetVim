execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/project_settings.vim')
let s:root = g:PV_test_dir .. '/LSP project'
call mkdir(s:root, 'p')
execute 'cd ' .. fnameescape(s:root)
call PlanetTestProjectSettings({'defaults': {'environment': {'PV_PROJECT': 'A', 'PV_LSP_LOG': s:root .. '/log.jsonl'}}})
let g:PV_clangd_argv = [exepath('python3'), g:PV_root .. '/tests/fixtures/lsp/scoped_server.py']
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')
func! s:Wait(expression) abort
  for l:i in range(500)
    if eval(a:expression) | return | endif
    sleep 10m
  endfor
  call assert_report('LSP timeout: ' .. a:expression)
endfunc
let s:server = 'planet-clangd'
let s:queue = get(g:, 'lsp_use_event_queue', 1)
for s:name in ['A', 'B']
  let s:directory = s:root .. '/' .. s:name
  call mkdir(s:directory, 'p')
  call writefile(['vim9script', "throw 'tab-local project file must not execute'"], s:directory .. '/.planetvim.vim')
  tabnew
  execute 'tcd ' .. fnameescape(s:directory)
  call writefile(['int main() { return 0; }'], s:directory .. '/main.cpp')
  execute 'edit ' .. fnameescape(s:directory .. '/main.cpp')
  call assert_equal([s:server], lsp#get_allowed_servers())
  call s:Wait('lsp#get_server_status(s:server) ==# "running"')
  call setline(1, 'int main() { return 1; }')
  doautocmd TextChanged
endfor
" Rapid tab switches keep the same process and normal upstream event queue.
if has('profile')
  execute 'profile start ' .. s:root .. '/tab-switch.profile'
  profile func planet#intelligence#Register
  profile func planet#run#UpdateRunMenu
endif
for s:i in range(20) | tabprevious | tabnext | endfor
if has('profile')
  profile stop
  let s:profile = join(readfile(s:root .. '/tab-switch.profile'), "\n")
  call assert_notmatch('FUNCTION.*planet#intelligence#Register', s:profile)
  call assert_notmatch('FUNCTION.*planet#run#UpdateRunMenu', s:profile)
endif
tabprevious
call setline(1, 'int main() { return 2; }')
doautocmd TextChanged
tabnext
sleep 1200m
let s:records = map(readfile(s:root .. '/log.jsonl'), 'json_decode(v:val)')
call assert_equal(1, len(filter(copy(s:records), 'v:val.method ==# "initialize"')))
call assert_equal(s:queue, get(g:, 'lsp_use_event_queue', 1))
call assert_equal([s:server], lsp#get_server_names())
for s:record in s:records
  call assert_equal(lsp#utils#path_to_uri(s:root), s:record.root)
  call assert_equal('A', s:record.env)
endfor
let s:opened = filter(copy(s:records), 'v:val.method ==# "textDocument/didOpen"')
call assert_equal(2, len(s:opened))
" Explicit environment changes restart the fixed registration with new values.
call planet#project_env#Set({'PV_PROJECT': 'updated'})
call s:Wait('lsp#get_server_status(s:server) ==# "running"')
sleep 100m
let s:records = map(readfile(s:root .. '/log.jsonl'), 'json_decode(v:val)')
call assert_equal(2, len(filter(copy(s:records), 'v:val.method ==# "initialize"')))
call assert_equal('updated', s:records[-1].env)
call assert_equal([s:server], lsp#get_server_names())
call lsp#stop_server(s:server)
