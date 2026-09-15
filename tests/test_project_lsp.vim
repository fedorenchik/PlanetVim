execute 'source ' .. fnameescape(g:PV_root .. '/tests/helpers/project_settings.vim')
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
let s:servers = []
let s:roots = []
for s:name in ['A', 'B']
  let s:root = g:PV_test_dir .. '/LSP ' .. s:name
  call mkdir(s:root, 'p')
  call add(s:roots, s:root)
  tabnew
  execute 'tcd ' .. fnameescape(s:root)
  call PlanetTestProjectSettings({'defaults': {'environment': {'PV_PROJECT': s:name, 'PV_LSP_LOG': s:root .. '/log.jsonl'}}})
  call writefile(['int main() { return 0; }'], s:root .. '/main.cpp')
  execute 'edit ' .. fnameescape(s:root .. '/main.cpp')
  let s:allowed = lsp#get_allowed_servers()
  call assert_equal(1, len(s:allowed))
  let s:server = s:allowed[0]
  call add(s:servers, s:server)
  call s:Wait('lsp#get_server_status(s:server) ==# "running"')
  call setline(1, 'int main() { return 1; }')
  doautocmd TextChanged
endfor
" Change A then switch immediately to B before the upstream event-queue delay.
tabprevious
call assert_equal([s:servers[0]], lsp#get_allowed_servers())
call setline(1, 'int main() { return 2; }')
doautocmd TextChanged
tabnext
sleep 1200m
for s:root in s:roots
  let s:records = map(readfile(s:root .. '/log.jsonl'), 'json_decode(v:val)')
  call assert_true(len(filter(copy(s:records), 'v:val.method ==# "textDocument/didOpen"')) > 0)
  for s:record in s:records
    call assert_equal(lsp#utils#path_to_uri(s:root), s:record.root)
    call assert_equal(fnamemodify(s:root, ':t')[-1:], s:record.env)
    if !empty(s:record.uri)
      call assert_equal(lsp#utils#path_to_uri(s:root .. '/main.cpp'), s:record.uri, 'no cross-project source delivery')
    endif
  endfor
endfor
for s:server in s:servers | call lsp#stop_server(s:server) | endfor
