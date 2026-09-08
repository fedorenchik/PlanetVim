set hidden
runtime plugin/writing.vim
let s:python = exepath('python3')
if empty(s:python)
  let s:python = exepath('python')
endif
call assert_false(empty(s:python), 'Python is required for deterministic writing-tool process fixtures')
let s:fixture = g:PV_root .. '/tests/fixtures/writing/fake_tools.py'
let s:viewer_record = g:PV_test_dir .. '/viewer.json'
let g:PV_document_viewer_argv = [s:python, s:fixture, 'viewer', s:viewer_record]
let g:PV_writing_auto_open = 1
let s:project = g:PV_test_dir .. '/writing project'
call mkdir(s:project, 'p')

func! s:Wait(buffer) abort
  for l:attempt in range(300)
    if get(getbufvar(a:buffer, 'PV_writing_result', {}), 'status', '') !=# 'running'
      return getbufvar(a:buffer, 'PV_writing_result')
    endif
    sleep 10m
  endfor
  call assert_report('The writing action did not complete')
  return {}
endfunc

let s:markdown = s:project .. '/a document.md'
call writefile(readfile(g:PV_root .. '/tests/fixtures/writing/sample.md'), s:markdown)
execute 'edit ' .. fnameescape(s:markdown)
setfiletype markdown
let s:source_buffer = bufnr()
let s:spellfile = &l:spellfile
call assert_match(escape(g:PV_state_dir, '\') .. '.*personal.utf-8.add$', s:spellfile)
call assert_equal(1, &l:spell)
let g:PV_pandoc_argv = [s:python, s:fixture, 'pandoc', g:PV_test_dir .. '/pandoc.json']
call assert_true(planet#writing#MarkdownPreview() > 0)
let s:result = s:Wait(s:source_buffer)
call assert_equal('success', get(s:result, 'status', ''))
call assert_true(filereadable(s:result.output))
call assert_match(escape(g:PV_cache_dir, '\'), s:result.output)
call assert_equal(s:markdown, json_decode(join(readfile(g:PV_test_dir .. '/pandoc.json'), ''))[-1])
for s:attempt in range(100)
  if filereadable(s:viewer_record) | break | endif
  sleep 10m
endfor
call assert_equal([s:result.output], json_decode(join(readfile(s:viewer_record), '')))
call assert_false(filereadable(s:project .. '/preview.html'))

let s:tex = s:project .. '/a document.tex'
call writefile(readfile(g:PV_root .. '/tests/fixtures/writing/sample.tex'), s:tex)
execute 'edit ' .. fnameescape(s:tex)
setfiletype tex
let s:source_buffer = bufnr()
let g:PV_latexmk_argv = [s:python, s:fixture, 'latexmk', g:PV_test_dir .. '/latexmk.json']
call assert_true(planet#writing#LatexBuild() > 0)
let s:result = s:Wait(s:source_buffer)
call assert_equal('success', get(s:result, 'status', ''))
call assert_true(filereadable(s:result.output))
call assert_false(filereadable(s:project .. '/a document.pdf'))
call assert_equal(s:tex, json_decode(join(readfile(g:PV_test_dir .. '/latexmk.json'), ''))[-1])
" Even when a previous PDF exists, a failed rebuild must not open stale output.
for s:attempt in range(100)
  if filereadable(s:viewer_record) && json_decode(join(readfile(s:viewer_record), '')) ==# [s:result.output] | break | endif
  sleep 10m
endfor
call delete(s:viewer_record)
let g:PV_latexmk_argv = [s:python, s:fixture, 'failure', g:PV_test_dir .. '/failure.json']
call assert_true(planet#writing#LatexBuild() > 0)
let s:failed = s:Wait(s:source_buffer)
call assert_equal('failed', get(s:failed, 'status', ''))
call assert_equal(7, s:failed.exit_code)
call assert_equal(0, planet#writing#OpenOutput())
call assert_false(filereadable(s:viewer_record))
let s:items = getqflist({'id': s:failed.quickfix, 'items': 1}).items
call assert_equal(3, s:items[0].lnum)
call assert_equal(s:tex, bufname(s:items[0].bufnr))
call planet#writing#Errors()
cfirst
call assert_equal(s:tex, expand('%:p'))
call assert_equal(3, line('.'))
cclose

let g:PV_pandoc_argv = [g:PV_test_dir .. '/missing-pandoc']
call assert_equal(0, planet#writing#MarkdownPreview())
call assert_match('Install Pandoc', planet#writing#LastError())
let g:PV_languagetool_command = g:PV_test_dir .. '/missing-languagetool'
call assert_equal(0, planet#writing#GrammarCheck())
call assert_match('LanguageTool', planet#writing#LastError())
" Personal spelling is outside the installation/project and survives setup.
call writefile(['PlanetVimword'], s:spellfile)
call planet#writing#Setup()
call assert_equal(['PlanetVimword'], readfile(s:spellfile))
