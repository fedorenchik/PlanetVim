" Generated Vim9 data must round-trip literals without executing their contents.
let s:path = g:PV_test_dir .. '/settings ''quoted'' 工作.vim'
let s:value = {'quotes': "a'\"b\\c", 'lines': "one\ntwo\r\t\b", 'unicode': '中文 😀',
      \ 'command': '" | let g:PV_storage_injected = 1',
      \ 'nested': {'list': [1, -2, 1.5, v:true, v:false, v:null, [], {}]}}
call planet#storage#Write(s:path, s:value)
call assert_equal('vim9script', readfile(s:path)[0])
call assert_equal(s:value, planet#storage#Read(s:path))
call assert_equal(s:value, planet#storage#Read(fnamemodify(s:path, ':h') .. '//./' .. fnamemodify(s:path, ':t')))
call assert_false(exists('g:PV_storage_injected'))
if !has('win32')
  call assert_equal('rw-------', getfperm(s:path))
endif
" Resourcing must pick up edited values, and reads must return independent data.
let s:loaded = planet#storage#Read(s:path)
let s:loaded.nested.list[0] = 42
call assert_equal(1, planet#storage#Read(s:path).nested.list[0])
call writefile(['vim9script', 'export var config: dict<any> = {answer: 6 * 7}'], s:path)
call assert_equal({'answer': 42}, planet#storage#Read(s:path))
" Reject unsupported values before replacing an existing file.
let s:before = readfile(s:path)
try
  call planet#storage#Write(s:path, {'callback': function('tr')})
  call assert_report('Function reference must be rejected')
catch /unsupported settings value/
endtry
call assert_equal(s:before, readfile(s:path))
call writefile(['vim9script', 'export var wrong = {}'], s:path)
try
  call planet#storage#Read(s:path)
  call assert_report('Missing exported config must be rejected')
catch /expected vim9script/
endtry
