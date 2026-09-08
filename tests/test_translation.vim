runtime plugin/prose.vim
let g:PV_translation_command = planet#generate#Python() + [g:PV_root .. '/tests/fixtures/translation_engine.py']
let s:vendor_history = g:PV_root .. '/.vim/pack/writing/start/vim-translator/translation_history.data'
let s:before = filereadable(s:vendor_history) ? readblob(s:vendor_history) : v:null

func! s:Wait(id) abort
  call assert_true(a:id > 0, 'translation request started')
  for l:i in range(500)
    sleep 10m
    if planet#translation#Result(a:id).status !=# 'running'
      return planet#translation#Result(a:id)
    endif
  endfor
  call planet#translation#Cancel(a:id)
  call assert_report('translation timed out')
  return {}
endfunc

call assert_equal(0, planet#translation#Language('source', ''))
call assert_equal(0, planet#translation#Language('target', 'en|quit'))
call assert_equal(1, planet#translation#Language('source', 'auto'))
call assert_equal(1, planet#translation#Language('target', 'zh-CN'))
call assert_equal(0, planet#translation#Engines(['unknown']))
call assert_equal(1, planet#translation#Engines(['bing', 'google', 'bing']))
call assert_equal(['bing', 'google'], planet#translation#Settings().engines)
call assert_true(filereadable(planet#paths#Config() .. '/translation.json'))
let s:options = s:Wait(planet#translation#Command('echo', 0, 0, 0, '--source_lang=en --target_lang=zh --engines=google Exact Case', v:true))
call assert_equal('Exact Case', s:options.text)
call assert_equal('zh', s:options.source)
call assert_equal('en', s:options.target)
call assert_equal(['google'], s:options.engines)
call assert_match('planet#translation#Command', execute('command TranslateW'))
call assert_match('planet#translation#Translate', maparg('<Plug>TranslateWV', 'x'))
let s:literal = 'UPPER Case, apostrophe''s; $literal 中文'
call assert_equal('success', s:Wait(planet#translation#Translate('echo', s:literal)).status)
call assert_equal(v:false, g:translator_history_enable)
call assert_equal('failed', s:Wait(planet#translation#Translate('echo', 'FAIL')).status)
call assert_equal('failed', s:Wait(planet#translation#Translate('echo', 'INVALID')).status)
call assert_false(exists('g:PV_translation_injected'), 'engine response is decoded as JSON, never evaluated')

enew
call setline(1, 'before ORIGINAL after')
call cursor(1, 10)
let s:registers = {}
for s:reg in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', 'z', '"']
  let s:registers[s:reg] = getreginfo(s:reg)
endfor
call assert_equal('success', s:Wait(planet#translation#Translate('replace')).status)
call assert_equal('before 译文 ORIGINAL after', getline(1))
for s:reg in keys(s:registers)
  call assert_equal(s:registers[s:reg], getreginfo(s:reg), 'replacement preserves ' .. s:reg)
endfor
call setline(1, ['prefix WORD', 'NEXT suffix'])
let s:visual = #{buffer: bufnr(), type: 'v', exclusive: v:false,
      \ start: [0, 1, 8, 0], end: [0, 2, 4, 0]}
call assert_equal('success', s:Wait(planet#translation#Translate('replace', v:null, s:visual)).status)
call assert_equal(['prefix 译文 WORD', 'NEXT suffix'], getline(1, '$'), 'multi-line visual translation replaces only captured text')
for s:reg in keys(s:registers)
  call assert_equal(s:registers[s:reg], getreginfo(s:reg), 'multiline replacement preserves ' .. s:reg)
endfor
silent 2,$delete _
call setline(1, 'DELAY original')
call cursor(1, 1)
let s:buffer = bufnr()
let s:request = planet#translation#Translate('replace')
call setline(1, 'newer edits')
call assert_equal('success', s:Wait(s:request).status)
call assert_equal(['newer edits'], getbufline(s:buffer, 1, '$'), 'late result cannot overwrite newer edits')
let s:cancelled = planet#translation#Translate('echo', 'HANG')
call assert_equal(1, planet#translation#Cancel(s:cancelled))
call assert_equal('cancelled', s:Wait(s:cancelled).status)
let s:history = planet#paths#State('translation') .. '/history.jsonl'
call assert_true(filereadable(s:history))
let s:entries = map(readfile(s:history), 'json_decode(v:val)')
call assert_equal(s:literal, s:entries[1].text)
call assert_true(filereadable(planet#paths#State('translation') .. '/events.jsonl'))
let s:export = g:PV_test_dir .. '/history exported.jsonl'
call assert_equal(1, planet#translation#History(s:export))
call assert_equal(readblob(s:history), readblob(s:export))
call assert_equal(0, planet#translation#History(s:export))
call assert_equal(s:before, filereadable(s:vendor_history) ? readblob(s:vendor_history) : v:null)
