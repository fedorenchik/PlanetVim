let s:a = g:PV_test_dir .. '/project A'
let s:b = g:PV_test_dir .. '/project B'
call mkdir(s:a .. '/bin', 'p')
call mkdir(s:b, 'p')
let $PLANET_ENV_REMOVED = 'inherited'
let s:python = exepath('python3')
let s:script = s:a .. '/record.py'
call writefile(['import json, os, sys', 'open(sys.argv[1], "w").write(json.dumps(dict(os.environ)))'], s:script)
call writefile(['#!/bin/sh', 'exec ' .. shellescape(s:python) .. ' ' .. shellescape(s:script) .. ' "$@"'], s:a .. '/bin/planet-env-test')
call setfperm(s:a .. '/bin/planet-env-test', 'rwx------')
execute 'tcd ' .. fnameescape(s:a)
call writefile([json_encode({'defaults': {'environment': {'PLANET_ENV': 'A', 'PLANET_ENV_REMOVED': v:null, 'PATH': '${root}/bin:${env:PATH}'}}})], planet#project#File())
let s:context = planet#project#Context()
tabnew
execute 'tcd ' .. fnameescape(s:b)
call writefile([json_encode({'defaults': {'environment': {'PLANET_ENV': 'B'}}})], planet#project#File())
let s:output = s:a .. '/captured.json'
let s:buffer = planet#term#RunArgv(['planet-env-test', s:output], v:false, v:false, v:true, s:a, v:null, '', {'context': s:context})
for s:i in range(300)
  if get(planet#term#Result(s:buffer), 'status', '') !=# 'running' | break | endif
  sleep 10m
endfor
call assert_equal('success', planet#term#Result(s:buffer).status)
let s:env = json_decode(join(readfile(s:output), "\n"))
call assert_equal('A', s:env.PLANET_ENV)
call assert_false(has_key(s:env, 'PLANET_ENV_REMOVED'))
call assert_equal('B', planet#project#Context().env_snapshot.PLANET_ENV)
call assert_equal('inherited', $PLANET_ENV_REMOVED)
call assert_equal(s:a, planet#term#Result(s:buffer).project)

" Distinct project servers retain their own environment and root; only the
" current project's registrations participate in filetype actions.
let g:PV_clangd_argv = [s:python]
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/tests/fixtures/lsp/load.vim')
call planet#intelligence#Register()
let s:server_b = filter(lsp#get_server_names(), 'v:val =~# "^planet-clangd"')[0]
tabprevious
call planet#intelligence#Register()
let s:server_a = filter(lsp#get_server_names(), 'v:val !=# s:server_b')[0]
call assert_equal('A', lsp#get_server_info(s:server_a).env.PLANET_ENV)
call assert_equal('B', lsp#get_server_info(s:server_b).env.PLANET_ENV)
call assert_equal([], lsp#get_server_info(s:server_b).allowlist)
call assert_equal(['c', 'cpp'], lsp#get_server_info(s:server_a).allowlist)
unlet $PLANET_ENV_REMOVED
