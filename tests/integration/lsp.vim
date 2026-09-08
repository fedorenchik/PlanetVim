" Requires real clangd and pylsp with diagnostics and formatting extras.
let g:PV_clangd_argv = [empty($PLANETVIM_TEST_CLANGD) ? exepath('clangd') : $PLANETVIM_TEST_CLANGD, '--background-index']
let g:PV_pylsp_argv = [empty($PLANETVIM_TEST_PYLSP) ? exepath('pylsp') : $PLANETVIM_TEST_PYLSP]
for s:argv in [g:PV_clangd_argv, g:PV_pylsp_argv]
  if empty(s:argv[0]) || !executable(s:argv[0])
    throw 'LSP integration requires clangd and pylsp; set PLANETVIM_TEST_CLANGD and PLANETVIM_TEST_PYLSP to executable paths.'
  endif
endfor
execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')

func! s:Wait(expression, message) abort
  for l:attempt in range(1000)
    if eval(a:expression) | return 1 | endif
    sleep 10m
  endfor
  call assert_report(a:message)
  return 0
endfunc

func! s:Response(response) abort
  let g:PV_lsp_response = a:response
endfunc

func! s:Request(server, method, params) abort
  let g:PV_lsp_response = {}
  call lsp#send_request(a:server, {'method': a:method, 'params': a:params,
        \ 'on_notification': function('s:Response')})
  call s:Wait('!empty(g:PV_lsp_response)', a:method .. ' timed out')
  call assert_false(has_key(get(g:PV_lsp_response, 'response', {}), 'error'), string(g:PV_lsp_response))
  return get(get(g:PV_lsp_response, 'response', {}), 'result', v:null)
endfunc

func! s:ObservePopup(timer) abort
  let g:PV_popup_attempts += 1
  if pumvisible()
    let g:PV_popup_items = filter(complete_info(['items']).items,
          \ '!empty(lsp#omni#get_managed_user_data_from_completed_item(v:val))')
  endif
  if !empty(g:PV_popup_items) || g:PV_popup_attempts > 400
    call timer_stop(a:timer)
    call feedkeys("\<C-e>\<Esc>", 't')
  endif
endfunc

let s:project = g:PV_test_dir .. '/real language project'
call mkdir(s:project, 'p')
call writefile(['-std=c++17'], s:project .. '/compile_flags.txt')
call writefile(['[project]', 'name = "planetvim-lsp-fixture"', 'version = "0.0.0"'], s:project .. '/pyproject.toml')

for s:language in ['cpp', 'python']
  let s:extension = s:language ==# 'cpp' ? 'cpp' : 'py'
  let s:server = s:language ==# 'cpp' ? 'planet-clangd' : 'planet-pylsp'
  let s:path = s:project .. '/sample.' .. s:extension
  let s:original = readfile(g:PV_root .. '/tests/fixtures/lsp/sample.' .. s:extension)
  call writefile(s:original, s:path)
  execute 'edit ' .. fnameescape(s:path)
  execute 'setfiletype ' .. s:language
  call s:Wait('lsp#get_server_status(' .. string(s:server) .. ') ==# "running"', s:server .. ' did not initialize')
  call s:Wait('&omnifunc ==# "lsp#complete"', s:server .. ' did not attach to buffer')
  call s:Wait('index(asyncomplete#get_source_names(), ' .. string('asyncomplete_lsp_' .. s:server) .. ') >= 0', 'LSP completion source did not register')
  call assert_equal([s:server], lsp#get_allowed_servers())

  " Actual navigation command travels from a call site to its definition.
  call cursor(s:language ==# 'cpp' ? 3 : 5, s:language ==# 'cpp' ? 12 : 13)
  call assert_equal(1, planet#intelligence#Action('LspDefinition'))
  call s:Wait('line(".") == 1', s:server .. ' definition navigation failed')
  call assert_equal(s:path, expand('%:p'))

  " The real server offers the local symbol through its protocol response.
  let s:params = {'textDocument': lsp#get_text_document_identifier(),
        \ 'position': {'line': s:language ==# 'cpp' ? 2 : 4, 'character': s:language ==# 'cpp' ? 15 : 17}}
  let s:completion = s:Request(s:server, 'textDocument/completion', s:params)
  let s:items = type(s:completion) == v:t_dict ? s:completion.items : s:completion
  call assert_true(!empty(filter(copy(s:items), 'get(v:val, "label", "") =~# "planet_add"')), s:server .. ' completion lacks the local symbol')

  " Exercise the actual asyncomplete popup while GVim is in Insert mode.
  let s:call_line = s:language ==# 'cpp' ? 3 : 5
  call setline(s:call_line, s:language ==# 'cpp' ? '  return planet_ad' : 'answer = planet_ad')
  call cursor(s:call_line, 1)
  let g:PV_popup_items = []
  let g:PV_popup_attempts = 0
  call timer_start(20, function('s:ObservePopup'), {'repeat': -1})
  call feedkeys("A\<C-r>=asyncomplete#_force_refresh()\<CR>", 'xt!')
  call assert_true(!empty(filter(copy(g:PV_popup_items), 'get(v:val, "word", "") =~# "planet_add"')), s:server .. ' actual completion popup lacks the local symbol')
  call setline(1, s:original)

  " Rename uses the real server workspace edit and the same client edit applier.
  call cursor(1, s:language ==# 'cpp' ? 8 : 9)
  let s:params = {'textDocument': lsp#get_text_document_identifier(), 'position': lsp#get_position(), 'newName': 'planet_sum'}
  let s:edits = s:Request(s:server, 'textDocument/rename', s:params)
  call lsp#utils#workspace_edit#apply_workspace_edit(s:edits)
  call assert_equal(2, len(split(join(getline(1, '$'), "\n"), 'planet_sum', 1)) - 1)
  call assert_notmatch('planet_add', join(getline(1, '$'), "\n"))

  " Formatting must apply edits, not merely complete a request successfully.
  call setline(1, s:language ==# 'cpp' ? 'int planet_sum(int left,int right){return left+right;}' : 'def planet_sum( left,right ):' )
  let s:unformatted = getline(1)
  call assert_equal(1, planet#intelligence#Action('LspDocumentFormatSync'))
  call assert_notequal(s:unformatted, getline(1), s:server .. ' did not format')
  call assert_match(s:language ==# 'cpp' ? 'left, int right' : 'left, right', getline(1))

  " Diagnostics must reach the client and a navigable location list.
  call append(line('$'), s:language ==# 'cpp' ? 'int broken = planet_unknown;' : 'broken = planet_unknown')
  write
  call s:Wait('get(lsp#get_buffer_diagnostics_counts(), "error", 0) > 0', s:server .. ' did not publish error diagnostics')
  call planet#intelligence#Action('LspDocumentDiagnostics')
  let s:diagnostics = getloclist(0)
  call assert_true(!empty(filter(copy(s:diagnostics), 'v:val.text =~# "planet_unknown"')), s:server .. ' location list lacks the unresolved symbol')
  lclose
  call lsp#stop_server(s:server)
endfor
