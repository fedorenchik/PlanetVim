" Real TeX acceptance; no downloads, user latexmkrc, or user TeX trees.
if !has('gui_running') || has('win32') || empty($PLANETVIM_TEST_LATEXMK) || !executable($PLANETVIM_TEST_LATEXMK)
  throw 'LaTeX integration requires Linux --gui and PLANETVIM_TEST_LATEXMK pointing to a local latexmk'
endif
if !executable('pdftotext')
  throw 'LaTeX integration requires Poppler pdftotext to verify PDF contents'
endif
set hidden
runtime plugin/writing.vim
let g:PV_latexmk_argv = [$PLANETVIM_TEST_LATEXMK, '-norc']
let g:PV_writing_auto_open = 0
let s:viewer = g:PV_test_dir .. '/latex-viewer.json'
let g:PV_document_viewer_argv = planet#generate#Python() + [g:PV_root .. '/tests/fixtures/writing/fake_tools.py', 'viewer', s:viewer]
let s:environment = {}
for s:name in ['PATH', 'TEXMFHOME', 'TEXMFVAR', 'TEXMFCONFIG']
  let s:environment[s:name] = getenv(s:name)
endfor
let $PATH = fnamemodify($PLANETVIM_TEST_LATEXMK, ':p:h') .. ':' .. $PATH
let $TEXMFHOME = g:PV_test_dir .. '/tex-home'
let $TEXMFVAR = g:PV_test_dir .. '/tex-cache'
let $TEXMFCONFIG = g:PV_test_dir .. '/tex-config'
for s:path in [$TEXMFHOME, $TEXMFVAR, $TEXMFCONFIG]
  call mkdir(s:path, 'p')
endfor

func! s:Wait(expression, message) abort
  for l:attempt in range(2000)
    if eval(a:expression)
      return 1
    endif
    sleep 10m
  endfor
  call assert_report(a:message .. "\n" .. execute('messages'))
  return 0
endfunc

func! s:Build(source) abort
  execute 'edit ' .. fnameescape(a:source)
  setfiletype tex
  let l:buffer = bufnr()
  let l:output = planet#writing#LatexBuild()
  call assert_true(l:output > 0, 'real latexmk must start')
  call s:Wait("get(getbufvar(" .. l:buffer .. ", 'PV_writing_result', {}), 'status', '') !=# 'running'", 'real LaTeX build timed out')
  return getbufvar(l:buffer, 'PV_writing_result', {})
endfunc

func! s:Pdf(result, expected) abort
  call assert_equal('success', get(a:result, 'status', ''), string(a:result))
  if get(a:result, 'status', '') !=# 'success'
    throw 'Real TeX failed: ' .. string(getbufline(get(a:result, 'output_buffer', 0), 1, '$'))
  endif
  call assert_true(getfsize(a:result.output) > 100, 'PDF must contain real content')
  call assert_equal(0z255044462D, readblob(a:result.output, 0, 5), 'PDF signature')
  call assert_match(escape(g:PV_cache_dir, '\'), a:result.output)
  let l:text = tempname()
  let l:job = planet#term#RunArgv(['pdftotext', '-layout', a:result.output, l:text], v:false, v:false, v:true)
  call s:Wait("get(planet#term#Result(" .. l:job .. "), 'status', '') !=# 'running'", 'PDF text extraction timed out')
  call assert_equal('success', planet#term#Result(l:job).status)
  call assert_match(a:expected, join(readfile(l:text), "\n"))
  call delete(l:text)
endfunc

try
  let s:project = g:PV_test_dir .. '/real latex project'
  call mkdir(s:project, 'p')
  let s:source = s:project .. '/sample document.tex'
  let s:original = readfile(g:PV_root .. '/tests/fixtures/writing/sample.tex')
  call writefile(s:original, s:source)
  let s:result = s:Build(s:source)
  call s:Pdf(s:result, 'PlanetVim writing sample')
  call assert_equal(1, planet#writing#OpenOutput())
  call s:Wait('filereadable(s:viewer)', 'the viewer did not receive the PDF')
  call assert_equal([s:result.output], json_decode(join(readfile(s:viewer), '')))
  call delete(s:viewer)

  " Real file/line TeX diagnostics must navigate back to the source error;
  " a successful older PDF must not make the failed rebuild look successful.
  call setline(4, '\PlanetVimUndefinedCommand')
  write
  let s:failure = s:Build(s:source)
  call assert_equal('failed', get(s:failure, 'status', ''))
  call assert_notequal(0, s:failure.exit_code)
  call assert_equal(0, planet#writing#OpenOutput())
  call assert_false(filereadable(s:viewer), 'failed rebuild must not open a stale PDF')
  let s:items = getqflist({'id': s:failure.quickfix, 'items': 1}).items
  call assert_false(empty(filter(copy(s:items), 'v:val.lnum == 4 && v:val.text =~# "Undefined control sequence"')))
  call assert_equal(1, planet#writing#Errors())
  cfirst
  call assert_equal(s:source, expand('%:p'))
  call assert_equal(4, line('.'))
  cclose
  call setline(1, s:original)
  write
  call s:Pdf(s:Build(s:source), 'PDF build and viewer workflow')
  call assert_equal([], getqflist({'id': s:failure.quickfix, 'items': 1}).items, 'successful rebuild clears stale errors')
  call assert_equal(['sample document.tex'], sort(readdir(s:project)), 'compiler auxiliary files must stay outside the source project')

  " Also build the shipped multi-file book template, including its chapter.
  let s:book = g:PV_test_dir .. '/real latex book'
  call mkdir(s:book, 'p')
  let s:template = g:PV_root .. '/.vim/pack/planet/start/planet.vim/templates/latex-book'
  for s:name in ['main.tex', 'chapter-one.tex', 'README.md']
    call writefile(readfile(s:template .. '/' .. s:name), s:book .. '/' .. s:name)
  endfor
  " TeX's default T1 bitmap font can encode the 'fi' ligature as one glyph.
  call s:Pdf(s:Build(s:book .. '/main.tex'), 'Welcome to the .*rst chapter')
  call assert_equal(['README.md', 'chapter-one.tex', 'main.tex'], sort(readdir(s:book)), 'book auxiliary files must stay in the cache')
finally
  for [s:name, s:value] in items(s:environment)
    call setenv(s:name, s:value)
  endfor
endtry
