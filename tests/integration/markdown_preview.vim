let s:pandoc = empty($PLANETVIM_TEST_PANDOC) ? exepath('pandoc') : $PLANETVIM_TEST_PANDOC
if empty(s:pandoc) || !executable(s:pandoc)
  throw 'Real Markdown integration requires Pandoc; set PLANETVIM_TEST_PANDOC to its executable'
endif
set hidden
runtime plugin/writing.vim
let g:PV_pandoc_argv = [s:pandoc]
let g:PV_writing_auto_open = 0
let s:directory = g:PV_test_dir .. '/real markdown project'
call mkdir(s:directory, 'p')
call writefile(['<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"><rect width="8" height="8" fill="red"/></svg>'], s:directory .. '/local image.svg')
let s:source = s:directory .. '/real document.md'
call writefile(['# Markdown acceptance', '', '- [x] Task list', '', '| A | B |', '|---|---|', '| one | two |', '', '![Local image](<local image.svg>)'], s:source)
execute 'edit ' .. fnameescape(s:source)
setfiletype markdown
let s:source_buffer = bufnr()
let s:output = planet#writing#MarkdownPreview()
for s:attempt in range(1000)
  let s:result = getbufvar(s:source_buffer, 'PV_writing_result', {})
  if get(s:result, 'status', '') !=# 'running' | break | endif
  sleep 10m
endfor
call assert_equal('success', get(s:result, 'status', ''))
let s:html = join(readfile(s:result.output), "\n")
call assert_match('<!DOCTYPE html>', s:html)
call assert_match('<table>', s:html)
call assert_match('type="checkbox"', s:html)
call assert_match('data:image/svg+xml', s:html)
call assert_match(escape(g:PV_cache_dir, '\'), s:result.output)
call assert_equal('', getftype(s:directory .. '/preview.html'))
