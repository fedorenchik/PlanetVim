runtime plugin/development.vim
let s:root = g:PV_test_dir .. '/test project 工作'
call mkdir(s:root, 'p')
let s:original = getcwd()
execute 'tcd ' .. fnameescape(s:root)
call writefile(['import unittest', '', 'class Example(unittest.TestCase):',
      \ '    def test_pass(self):', '        self.assertEqual(2 + 2, 4)', '',
      \ '    def test_fail(self):', '        self.assertEqual(2 + 2, 5)'], s:root .. '/test_sample.py')
let g:test#python#runner = 'pyunit'
let g:test#python#pyunit#executable = (executable('python3') ? 'python3' : 'python') .. ' -m unittest'
let s:buffers = []

func! s:Wait(buffer) abort
  call assert_true(a:buffer > 0, 'test process started')
  if a:buffer <= 0
    return {}
  endif
  call add(s:buffers, a:buffer)
  for l:i in range(500)
    call term_wait(a:buffer, 10)
    sleep 10m
    if planet#term#Result(a:buffer).status !=# 'running'
      return planet#term#Result(a:buffer)
    endif
  endfor
  call planet#term#Cancel(a:buffer)
  call assert_report('test process timed out')
  return {}
endfunc

try
  call assert_equal(2, exists(':PlanetTest'))
  call assert_equal(0, planet#test#Test('last'))
  execute 'edit ' .. fnameescape(s:root .. '/test_sample.py')
  let s:source = win_getid()
  call cursor(5, 1)
  let s:pass = planet#test#Test('nearest')
  call assert_equal('success', get(s:Wait(s:pass), 'status', ''))
  call assert_equal(s:root, planet#run#Path(planet#term#Result(s:pass).cwd, s:root))
  call assert_match('test_pass', planet#term#Result(s:pass).command)
  call win_gotoid(s:source)
  call assert_equal(s:root, getcwd())
  call assert_equal(1, planet#test#Test('visit'))
  call assert_equal(5, line('.'))
  call assert_equal('success', get(s:Wait(planet#test#Test('last')), 'status', ''))
  call win_gotoid(s:source)
  call cursor(8, 1)
  let s:fail = planet#test#Test('nearest')
  call assert_equal(1, get(s:Wait(s:fail), 'exit_code', -1))
  call assert_equal('failed', planet#term#Result(s:fail).status)
  call assert_equal('terminal', getbufvar(s:fail, '&buftype'))
  call win_gotoid(s:source)
  call assert_equal(1, get(s:Wait(planet#test#Test('file')), 'exit_code', -1))
  call win_gotoid(s:source)
  call assert_equal(1, get(s:Wait(planet#test#Test('suite')), 'exit_code', -1))
  call win_gotoid(s:source)
  let g:test#python#pyunit#executable = 'planetvim_missing_test_runner'
  let s:missing = s:Wait(planet#test#Test('nearest'))
  call assert_equal('failed', get(s:missing, 'status', ''))
  call assert_true(index([127, 9009], get(s:missing, 'exit_code', -1)) >= 0)
  call win_gotoid(s:source)
  tabnew
  let s:other = g:PV_test_dir .. '/another project'
  call mkdir(s:other, 'p')
  execute 'tcd ' .. fnameescape(s:other)
  call assert_equal(0, planet#test#Test('last'), 'test history must not leak across project tabs')
  call assert_equal(0, planet#test#Test('visit'))
  tabclose
finally
  for s:buffer in s:buffers
    if bufexists(s:buffer)
      call planet#term#Cancel(s:buffer)
      execute 'bwipeout! ' .. s:buffer
    endif
  endfor
  execute 'cd ' .. fnameescape(s:original)
endtry
