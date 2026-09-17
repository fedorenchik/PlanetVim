let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call assert_equal(1, g:lsp_diagnostics_pull_enabled)
call assert_equal({}, menu_info('Lsp'), 'upstream duplicate root is folded into PlanetVim')
let s:target = g:PV_test_dir .. '/link target.txt'
let s:trace = g:PV_test_dir .. '/lsp-features.jsonl'
call writefile(['linked document'], s:target)
call lsp#register_server(#{name: 'planet-features-fixture', cmd: {server -> [exepath('python3'), g:PV_root .. '/tests/helpers/lsp_features_server.py', s:target, s:trace]}, allowlist: ['planetfeaturetest']})
let s:source = g:PV_test_dir .. '/source.fixture'
call writefile(['link'], s:source)
execute 'edit ' .. fnameescape(s:source)
setfiletype planetfeaturetest
func! s:Wait(expression) abort
  for l:attempt in range(300)
    if eval(a:expression) | return 1 | endif
    sleep 10m
  endfor
  call assert_report('Timed out: ' .. a:expression)
  return 0
endfunc
try
  call s:Wait('lsp#get_server_status("planet-features-fixture") ==# "running"')
  call s:Wait('lsp#internal#diagnostics#state#_get_diagnostics_count_for_buffer(bufnr()).warning == 1')
  let s:initialize = json_decode(readfile(s:trace)[0])
  call assert_true(has_key(s:initialize.params.capabilities.textDocument, 'diagnostic'))
  " Popup offers the initialized server's capabilities, including empty options
  " dictionaries; actions execute through the real client protocol.
  call planet#popup#Build('n')
  call assert_false(empty(menu_info('PopUp.Go to Definition', 'n')))
  call assert_false(empty(menu_info('PopUp.Format Document', 'n')))
  call assert_equal({}, menu_info('PopUp.Rename Symbol', 'n'))
  call assert_equal({}, menu_info('PopUp.Code Actions', 'n'))
  emenu PopUp.Format\ Document
  call s:Wait('getline(1) ==# "LINK"')
  emenu PopUp.Go\ to\ Definition
  call s:Wait('expand("%:p") ==# s:target')
  execute 'edit ' .. fnameescape(s:source)
  call planet#popup#Build('v')
  call assert_false(empty(menu_info('PopUp.Format Selection', 'x')))
  call assert_equal({}, menu_info('PopUp.Go to Definition', 'x'))
  call setline(1, 'link')
  xnoremap <F11> <Cmd>emenu PopUp.Format\ Selection<CR>
  call feedkeys("gg0v3l\<F11>\<Esc>", 'xt')
  call s:Wait('getline(1) ==# "LINK"')
  xunmap <F11>
  setlocal readonly
  call planet#popup#Build('n')
  call assert_equal({}, menu_info('PopUp.Format Document', 'n'))
  call assert_false(empty(menu_info('PopUp.Go to Definition', 'n')))
  setlocal noreadonly
  LspDocumentLink
  call s:Wait('!empty(getqflist())')
  call assert_equal(lsp#utils#path_to_uri(s:target), getqflist()[0].text)
  cclose
  call cursor(1, 2)
  LspDocumentLinkOpen
  call s:Wait('expand("%:p") ==# s:target')
  call assert_equal(['linked document'], getline(1, '$'))
  LspStopServer!
  call s:Wait('lsp#get_server_status("planet-features-fixture") ==# "exited"')
  call planet#popup#Build('n')
  call assert_equal({}, menu_info('PopUp.Go to Definition', 'n'))
finally
  call lsp#stop_server('planet-features-fixture')
endtry
