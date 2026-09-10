execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')
call lsp#register_server(#{name: 'planet-display-fixture', cmd: {server -> [exepath('python3'), g:PV_root .. '/tests/helpers/lsp_display_server.py']}, allowlist: ['planetdisplaytest']})
let g:lsp_inlay_hints_delay = 1
let s:path = g:PV_test_dir .. '/display.fixture'
call writefile(['😀α value=1'], s:path)
execute 'edit ' .. fnameescape(s:path)
setfiletype planetdisplaytest
func! s:Wait(expression) abort
  for l:attempt in range(300)
    if eval(a:expression) | return 1 | endif
    sleep 10m
  endfor
  call assert_report('Timed out: ' .. a:expression)
  return 0
endfunc
call s:Wait('lsp#get_server_status("planet-display-fixture") ==# "running"')
call s:Wait('lsp#internal#diagnostics#state#_get_diagnostics_count_for_buffer(bufnr()).warning > 0')
call assert_equal(1, planet#lsp_display#Set('inline', 1))
call s:Wait('!empty(filter(prop_list(1), {_, p -> p.type ==# "PlanetLspWarningText"}))')
call planet#lsp_display#Set('inline', 0)
call assert_equal([], filter(prop_list(1), {_, p -> p.type ==# 'PlanetLspWarningText'}))
call planet#lsp_display#Set('hints', 1)
doautocmd CursorHold
call s:Wait('!empty(filter(prop_list(1), {_, p -> p.type ==# "PlanetLspInlayType"}))')
call assert_equal(13, filter(prop_list(1), {_, p -> p.type ==# 'PlanetLspInlayType'})[0].col)
call planet#lsp_display#Set('hints', 0)
call assert_equal([], filter(prop_list(1), {_, p -> p.type ==# 'PlanetLspInlayType'}))
call planet#lsp_display#Set('signs', 0)
call assert_equal([], sign_getplaced(bufnr(), #{group: 'vim_lsp'})[0].signs)
call planet#lsp_display#Set('signs', 1)
call s:Wait('!empty(sign_getplaced(bufnr(), #{group: "vim_lsp"})[0].signs)')
call planet#lsp_display#Set('underlines', 0)
call planet#lsp_display#Set('underlines', 1)
call assert_equal(1, g:lsp_diagnostics_highlights_enabled)
call lsp#stop_server('planet-display-fixture')
