runtime plugin/development.vim
if !has('python3') || !py3eval('__import__("sys").version_info >= (3, 10)')
  let g:PV_test_skip = 'Debugger sessions require embedded Python 3.10+'
  finish
endif
call assert_equal(1, planet#debug#Session('new', 'first session'))
call assert_equal('first session', vimspector#GetSessionName())
let s:first = vimspector#GetSessionID()
call assert_equal(1, planet#debug#Session('new', 'second session'))
call assert_notequal(s:first, vimspector#GetSessionID())
call assert_equal(1, planet#debug#Session('switch', 'first session'))
call assert_equal(s:first, vimspector#GetSessionID())
call assert_equal(1, planet#debug#Session('rename', 'renamed session'))
call assert_equal('renamed session', vimspector#GetSessionName())
call assert_equal(1, planet#debug#Session('close', 'second session'))
call assert_notmatch('second session', vimspector#CompleteSessionName('', '', 0))
