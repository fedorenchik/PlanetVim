" Requires an already installed official LanguageTool CLI; never a web service.
if !has('gui_running') || empty($PLANETVIM_TEST_LANGUAGETOOL_JAR) || !filereadable($PLANETVIM_TEST_LANGUAGETOOL_JAR) || !executable('java')
  throw 'Grammar integration requires --gui, Java17+, and PLANETVIM_TEST_LANGUAGETOOL_JAR'
endif
set hidden
let s:java_state = g:PV_test_dir .. '/java state'
call mkdir(s:java_state, 'p')
let g:PV_languagetool_argv = ['java', '-Xmx512m', '-Duser.home=' .. s:java_state,
      \ '-Djava.io.tmpdir=' .. s:java_state, '-jar', $PLANETVIM_TEST_LANGUAGETOOL_JAR]
let g:grammarous#default_lang = 'en-US'
let g:grammarous#use_location_list = 1
let g:grammarous#show_first_error = 0
let g:grammarous#move_to_first_error = 1
let s:source = g:PV_test_dir .. '/grammar source.txt'
call writefile(['😀 Café is is a test.', 'This is a second sentence.'], s:source)
execute 'edit ' .. fnameescape(s:source)
setfiletype text

func! s:Wait() abort
  for l:attempt in range(2500)
    if exists('b:grammarous_result')
      return 1
    endif
    sleep 10m
  endfor
  call assert_report('Real LanguageTool did not complete: ' .. execute('messages'))
  return 0
endfunc

call assert_equal(1, planet#writing#GrammarCheck())
if s:Wait()
  let s:errors = filter(copy(b:grammarous_result), 'v:val.ruleId ==# "ENGLISH_WORD_REPEAT_RULE"')
  call assert_equal(1, len(s:errors), string(b:grammarous_result))
  if !empty(s:errors)
    let s:error = s:errors[0]
    call assert_equal(0, str2nr(s:error.fromy))
    call assert_equal(strlen('😀 Café '), str2nr(s:error.fromx), 'UTF-16 API offsets must navigate to UTF-8 Vim byte columns')
    call assert_false(empty(filter(getmatches(), 'v:val.group ==# "GrammarousError"')), 'real grammar error is highlighted')
    call assert_false(empty(filter(getloclist(0), 'v:val.lnum == 1 && v:val.col == strlen("😀 Café ") + 1')), 'real grammar error is navigable')
    call grammarous#fixit(s:error)
    call assert_equal('😀 Café is a test.', getline(1), 'public Grammarous fix uses the adapter replacement')
  endif
endif
call planet#prose#Grammar('reset')
call setline(1, 'This is a clear sentence.')
call assert_equal(1, planet#prose#Grammar('check'))
if s:Wait()
  call assert_equal([], b:grammarous_result, 'clean text produces no diagnostics')
  call assert_equal([], getloclist(0), 'a repeated check clears stale locations')
endif
call assert_match(escape(g:PV_cache_dir, '\'), g:grammarous#jar_dir)
call assert_false(isdirectory(g:PV_root .. '/.vim/pack/writing/start/vim-grammarous/misc'), 'no bundled plugin download or generated installation directory')
call planet#prose#Grammar('reset')
