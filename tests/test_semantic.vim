let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')
let g:PlanetVim_menus_dev = 1
call planet#menu#dev#Update()
new
call setline(1, ['😀 hello world', 'second'])
let s:legend = #{tokenTypes:['variable', 'function'], tokenModifiers:['declaration', 'readonly']}
let s:items = planet#semantic#Decode(bufnr(), s:legend, [0,3,5,1,3, 0,6,5,0,0, 1,0,6,0,2])
call assert_equal([1,6,10], [s:items[0].lnum,s:items[0].col,s:items[0].end_col])
call assert_equal('function [declaration, readonly]: hello', s:items[0].text)
call assert_equal('variable: world', s:items[1].text)
call assert_equal('variable [readonly]: second', s:items[2].text)
call assert_equal(6, planet#semantic#Decode(bufnr(), s:legend, [0,5,5,1,0], 'utf-8')[0].col)
for s:data in [[0], [0,0,1,99,0], [0,1,1,0,0], [0,50,1,0,0]]
  try
    call planet#semantic#Decode(bufnr(), s:legend, s:data)
    call assert_report('invalid semantic data accepted: ' .. string(s:data))
  catch /semantic token/
  endtry
endfor
call assert_equal(0, planet#semantic#Show())
execute 'file ' .. fnameescape(g:PV_test_dir .. '/missing.py')
setfiletype python
call assert_equal(0, planet#semantic#Show())
call assert_match('no running server supports full semantic tokens', execute('messages'))
call assert_equal(0, planet#intelligence#Action('LspDocumentDiagnostics'))
call assert_match('PlanetVim pylsp: disabled', execute('messages'))
emenu 🔬y.Check
call assert_match('PlanetVim pylsp: disabled', execute('messages'))
call assert_equal('😀 hello world', getline(1))
