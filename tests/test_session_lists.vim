runtime plugin/globals.vim
set hidden nomore nolazyredraw sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
let s:first = g:PV_test_dir .. "/first 'file'.txt"
let s:second = g:PV_test_dir .. '/second.txt'
call writefile(['one', 'two', 'three'], s:first)
call writefile(['four', 'five', 'six'], s:second)
execute 'edit ' .. fnameescape(s:first)
let s:owner = win_getid()
call setqflist([], ' ', {'title': 'older quickfix', 'items': [{'filename': s:first, 'lnum': 1, 'text': 'older'}]})
call setqflist([], ' ', {'title': "build 'results' 工作", 'context': {'tool': 'compiler', 'nested': [1, v:true]},
      \ 'items': [{'filename': s:first, 'lnum': 2, 'end_lnum': 3, 'col': 2, 'end_col': 4,
      \ 'type': 'W', 'nr': 19, 'text': 'warning', 'user_data': {'code': 'W19'}},
      \ {'filename': s:second, 'pattern': '^five$', 'text': 'pattern match'},
      \ {'text': "detail\nsecond line", 'valid': 0}], 'idx': 2})
call setqflist([], ' ', {'title': 'newer quickfix', 'items': []})
colder
call setloclist(0, [], ' ', {'title': 'older local', 'items': [{'filename': s:first, 'lnum': 1, 'text': 'local older'}]})
call setloclist(0, [], ' ', {'title': 'first owner', 'context': ['search'], 'items': [
      \ {'filename': s:first, 'lnum': 2, 'text': 'local one'},
      \ {'filename': s:first, 'lnum': 3, 'text': 'local two'}], 'idx': 2})
call setloclist(0, [], ' ', {'title': 'newer local', 'items': []})
lolder
vsplit
let s:other = win_getid()
call setloclist(0, [], 'f')
call setloclist(0, [], ' ', {'title': 'second owner, same file', 'items': [{'filename': s:first, 'lnum': 1, 'text': 'different list'}]})
call win_gotoid(s:owner)
lopen 4
let s:local_panel = win_getid()
call win_gotoid(s:other)
botright copen 5
let s:quick_panel = win_getid()
tabnew
execute 'edit ' .. fnameescape(s:second)
call setloclist(0, [], ' ', {'title': 'second tab', 'items': [{'filename': s:second, 'lnum': 2, 'text': 'tab local'}]})
tabfirst
call win_gotoid(s:quick_panel)
let s:layout = winlayout()
func! s:Shape(layout) abort
  return a:layout[0] ==# 'leaf' ? ['leaf'] : [a:layout[0], map(copy(a:layout[1]), 's:Shape(v:val)')]
endfunc
let s:shape = s:Shape(s:layout)
let s:windows = winnr('$')
let s:a = planet#session#PathForFile(g:PV_test_dir .. '/lists A.vim')
call planet#session#SaveAs(s:a)
call assert_equal(s:layout, winlayout(), 'autosave cannot disturb live list windows')
call assert_equal(s:quick_panel, win_getid())
let s:original = readfile(s:a)
call assert_match('session_lists#Restore', join(s:original, "\n"))
call planet#session#Close()
call assert_equal([], getqflist(), 'closed-session diagnostics must not leak')
call assert_equal(0, planet#session#AutoSave())
call assert_equal(s:original, readfile(s:a), 'no session means no list autosave')

" Reopening uses new buffer and window IDs, preserving navigation and ownership.
call planet#session#OpenPath(s:a)
call assert_equal(2, tabpagenr('$'))
call assert_equal(s:windows, winnr('$'))
call assert_equal(s:shape, s:Shape(winlayout()))
call assert_true(getwininfo(win_getid())[0].quickfix)
call assert_false(getwininfo(win_getid())[0].loclist)
call assert_equal(3, getqflist({'nr': '$'}).nr)
call assert_equal(2, getqflist({'nr': 0}).nr)
call assert_equal(2, getqflist({'idx': 0}).idx)
call assert_equal("build 'results' 工作", getqflist({'title': 0}).title)
call assert_equal({'tool': 'compiler', 'nested': [1, v:true]}, getqflist({'context': 0}).context)
let s:items = getqflist()
call assert_equal(s:first, fnamemodify(bufname(s:items[0].bufnr), ':p'))
call assert_equal({'code': 'W19'}, s:items[0].user_data)
call assert_equal([2, 3, 2, 4, 19, 'W'], [s:items[0].lnum, s:items[0].end_lnum, s:items[0].col, s:items[0].end_col, s:items[0].nr, s:items[0].type])
call assert_equal("detail\nsecond line", s:items[2].text)
let s:owners = filter(getwininfo(), '!v:val.quickfix && v:val.tabnr == 1')
call assert_equal(['first owner', 'second owner, same file'], sort(map(copy(s:owners), 'getloclist(v:val.winid, {"title": 0}).title')))
let s:restored_owner = filter(copy(s:owners), 'getloclist(v:val.winid, {"title": 0}).title ==# "first owner"')[0].winid
let s:panel = getloclist(s:restored_owner, {'winid': 0}).winid
call assert_true(s:panel > 0)
call assert_equal(s:restored_owner, getloclist(s:panel, {'filewinid': 0}).filewinid)
call assert_equal(3, getloclist(s:restored_owner, {'nr': '$'}).nr)
call assert_equal(2, getloclist(s:restored_owner, {'nr': 0}).nr)
call assert_equal(2, getloclist(s:restored_owner, {'idx': 0}).idx)
call win_execute(s:restored_owner, 'lolder')
call assert_equal('older local', getloclist(s:restored_owner, {'title': 0}).title)
call assert_equal(0, getloclist(s:owners[0].winid == s:restored_owner ? s:owners[1].winid : s:owners[0].winid, {'winid': 0}).winid)
tabnext 2
call assert_equal('second tab', getloclist(0, {'title': 0}).title)
tabfirst
cc 2
call assert_equal(s:second, expand('%:p'))
call assert_equal(2, line('.'), 'restored quickfix entries remain navigable')

" Save As copies list state; clearing and autosaving B cannot modify A.
let s:b = planet#session#PathForFile(g:PV_test_dir .. '/lists B.vim')
call planet#session#SaveAs(s:b)
call setqflist([], 'f')
for s:window in getwininfo()
  if !s:window.quickfix | call setloclist(s:window.winid, [], 'f') | endif
endfor
call planet#session#AutoSave()
call assert_equal(s:original, readfile(s:a))
call planet#session#OpenPath(s:a)
call assert_equal(3, getqflist({'nr': '$'}).nr)
call planet#session#OpenPath(s:b)
call assert_equal([], getqflist())

" All-options snapshots still replace list placeholders with real list windows.
call planet#session#OpenPath(s:a)
let s:all = planet#session#PathForFile(g:PV_test_dir .. '/all list options.vim')
call planet#session#SaveVariant('all', s:all, v:true)
call planet#session#Close()
call planet#session#OpenPath(s:all)
call assert_equal(s:shape, s:Shape(winlayout()))
call assert_equal(3, getqflist({'nr': '$'}).nr)
call assert_equal(1, len(filter(getwininfo(), 'v:val.loclist')))
call planet#session#Close()

" Explicitly omitted scratch windows must not shift location-list ownership.
execute 'edit ' .. fnameescape(s:first)
execute 'vsplit ' .. fnameescape(s:second)
let s:kept = win_getid()
call setloclist(0, [], ' ', {'title': 'kept owner', 'items': [{'filename': s:second, 'lnum': 1, 'text': 'kept'}]})
new
setlocal buftype=nofile bufhidden=wipe
file scratch
set sessionoptions-=blank
call win_gotoid(s:kept)
let s:filtered = planet#session#PathForFile(g:PV_test_dir .. '/filtered windows.vim')
call planet#session#SaveAs(s:filtered)
call planet#session#Close()
call planet#session#OpenPath(s:filtered)
call assert_equal(2, winnr('$'))
call assert_equal('kept owner', getloclist(0, {'title': 0}).title)
call assert_equal(s:second, expand('%:p'))
call planet#session#Close()

" A session containing search results alone is useful and must autosave too.
let s:results_folder = g:PV_test_dir .. '/results only'
call mkdir(s:results_folder, 'p')
execute 'cd ' .. fnameescape(s:results_folder)
set sessionoptions+=blank
call planet#session#Init()
call planet#session#Startup()
call setqflist([], ' ', {'title': 'results only', 'items': [{'filename': s:first, 'lnum': 1, 'text': 'match'}]})
copen
call assert_equal(1, planet#session#AutoSave())
let s:results_session = v:this_session
call planet#session#Close()
call planet#session#OpenPath(s:results_session)
call assert_equal('results only', getqflist({'title': 0}).title)

" A quickfix window can also own a location-list history.
call setloclist(0, [], ' ', {'title': 'quickfix window local', 'items': [{'filename': s:first, 'lnum': 2, 'text': 'owned by quickfix'}]})
call planet#session#AutoSave()
call planet#session#Close()
call planet#session#OpenPath(s:results_session)
call assert_equal('quickfix window local', getloclist(0, {'title': 0}).title)
lopen
call planet#session#AutoSave()
call planet#session#Close()
call planet#session#OpenPath(s:results_session)
let s:quickfix_owner = filter(getwininfo(), 'v:val.quickfix && !v:val.loclist')[0].winid
let s:location_panel = filter(getwininfo(), 'v:val.loclist')[0].winid
call assert_equal(getloclist(s:quickfix_owner, {'id': 0}).id, getloclist(s:location_panel, {'id': 0}).id)
