set hidden
let g:PV_cache_dir = g:PV_test_dir .. '/grammar cache 工作'
let s:directory = g:PV_test_dir .. '/grammar backend 工作'
call mkdir(s:directory, 'p')
let s:backend = s:directory .. '/local backend.py'
let s:record = s:directory .. '/argv.json'
call writefile(readfile(g:PV_root .. '/tests/fixtures/writing/fake_language_tool.py'), s:backend)
let s:literal = 'two words; "quoted" $(literal) 工作'
let g:PV_languagetool_argv = planet#generate#Python() + [s:backend, s:record, s:literal]
let g:grammarous#default_lang = 'en-US'
let g:grammarous#show_first_error = 0
let g:grammarous#use_location_list = 1
let s:source = s:directory .. '/grammar source.txt'
call writefile(['A first sentence.', 'Café is is a test.'], s:source)
execute 'edit ' .. fnameescape(s:source)
setfiletype text

func! s:Wait(expression) abort
  for l:attempt in range(500)
    if eval(a:expression)
      return 1
    endif
    sleep 10m
  endfor
  call assert_report('Grammar adapter timed out: ' .. a:expression .. "\n" .. execute('messages'))
  return 0
endfunc

call assert_equal(1, planet#writing#GrammarCheck())
if s:Wait("exists('b:grammarous_result')")
  call assert_equal(1, len(b:grammarous_result), string(b:grammarous_result))
  if !empty(b:grammarous_result)
    call assert_equal('WORD_REPEAT', b:grammarous_result[0].ruleId)
    call assert_equal(1, str2nr(b:grammarous_result[0].fromy), 'later-line positions survive the native platform newline convention')
    call assert_equal(strlen('Café '), str2nr(b:grammarous_result[0].fromx))
    call grammarous#fixit(b:grammarous_result[0])
    call assert_equal('Café is a test.', getline(2))
  endif
endif
let s:arguments = json_decode(join(readfile(s:record), ''))
call assert_equal(s:literal, s:arguments[0], 'native backend argv preserves literal arguments')
call assert_true(index(s:arguments, '--json') >= 0)
call assert_equal(-1, index(s:arguments, '--api'))
call assert_match('grammar cache', g:grammarous#languagetool_cmd)
call planet#prose#Grammar('reset')
call assert_equal(1, planet#prose#Grammar('check'))
if s:Wait("exists('b:grammarous_result')")
  call assert_equal([], b:grammarous_result)
endif
call planet#prose#Grammar('reset')
call setline(1, 'FAIL request')
call assert_equal(1, planet#prose#Grammar('check'))
call s:Wait('execute("messages") =~# "Grammar check failed with exit status 7"')
call assert_false(exists('b:grammarous_result'), 'failed backend must not produce success diagnostics')
call assert_match('isolated grammar failure', join(readfile(g:PV_grammar_error_file), "\n"), 'backend stderr survives the upstream exit/close callback order')
call planet#prose#Grammar('status')
call assert_match('isolated grammar failure', execute('messages'))
