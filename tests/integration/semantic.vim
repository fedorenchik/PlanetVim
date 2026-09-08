let g:PV_clangd_argv = [empty($PLANETVIM_TEST_CLANGD) ? exepath('clangd') : $PLANETVIM_TEST_CLANGD, '--background-index']
let g:PV_pylsp_argv = []
if empty(g:PV_clangd_argv[0]) | throw 'real semantic scope acceptance requires clangd' | endif
execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')
let g:PlanetVim_menus_dev = 1
call planet#menu#dev#Update()
let s:path = g:PV_test_dir .. '/semantic.cpp'
call writefile(['int planet_value = 3;', 'int main() { return planet_value; }'], s:path)
execute 'edit ' .. fnameescape(s:path)
setfiletype cpp
for s:attempt in range(1000)
  if lsp#get_server_status('planet-clangd') ==# 'running' | break | endif
  sleep 10m
endfor
call assert_equal('running', lsp#get_server_status('planet-clangd'))
let s:buffer = bufnr()
emenu ❇️[.Document\ Semantic\ Scopes
for s:attempt in range(600)
  if get(getbufvar(s:buffer,'PV_semantic_result',{}),'status','') !=# 'running' | break | endif
  sleep 10m
endfor
let s:result = getbufvar(s:buffer,'PV_semantic_result',{})
call assert_equal('success', get(s:result,'status',''), string(s:result))
call assert_true(!empty(filter(copy(get(s:result,'items',[])),{_, item->item.text =~# 'planet_value'})))
call assert_match('Semantic scopes', getloclist(0,{'title':1}).title)
lfirst
call assert_equal(s:buffer, bufnr())
call assert_equal(1, line('.'))
lclose
call setline(1, 'int planet_value = missing_symbol;')
write
for s:attempt in range(1000)
  if get(lsp#get_buffer_diagnostics_counts(), 'error', 0) > 0 | break | endif
  sleep 10m
endfor
emenu 🔬y.Check
call assert_true(!empty(filter(getloclist(0), {_, item->item.text =~# 'missing_symbol'})))
call lsp#disable()
