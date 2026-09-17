" Targeted tab actions retain identity, edits, recovery, and the active window.
set hidden noinsertmode
execute 'source ' .. fnameescape(g:PV_root .. '/.vim/pack/planet/start/planet.vim/plugin/autocmds.vim')
for s:name in ['one', 'two', 'three']
  call writefile([s:name], g:PV_test_dir .. '/' .. s:name .. '.txt')
endfor
execute 'edit ' .. fnameescape(g:PV_test_dir .. '/one.txt')
let s:origin = win_getid()
execute 'tabedit ' .. fnameescape(g:PV_test_dir .. '/two.txt')
let s:target_window = win_getid()
let s:target_buffer = bufnr()
let s:target = planet#tab#Id(tabpagenr())
execute 'tabedit ' .. fnameescape(g:PV_test_dir .. '/three.txt')
let s:last = planet#tab#Id(tabpagenr())
tabfirst
call planet#tab#Track()
let s:origin_id = planet#tab#Id(1)
call assert_true(planet#tab_menu#Build(s:target))
call assert_equal(s:origin, win_getid())
call assert_equal(':tabclose', menu_info(']PVTab.Close Tab', 'n').accel)
call assert_match(':call planet#tab_menu#Action', execute('tmenu ]PVTab.Close\ Tab'))
call planet#tab_menu#Action(s:target, 'path', s:target_window, s:target_buffer)
call assert_equal(g:PV_test_dir .. '/two.txt', getreg('+'))
call assert_equal(s:origin, win_getid())
call planet#tab_menu#Action(s:target, 'relative', s:target_window, s:target_buffer)
call assert_equal('two.txt', getreg('+'))

" A menu built before reordering continues to operate on the same tab.
call planet#tab_menu#Action(s:target, 'first')
call assert_equal(1, planet#tab#Find(s:target))
call assert_equal(s:origin, win_getid())
emenu ]PVTab.Close\ Tab
call assert_equal(0, planet#tab#Find(s:target))
call assert_equal(s:origin, win_getid())
call assert_true(planet#tab#CanReopen())
call planet#tab#Reopen()
call assert_equal('two.txt', expand('%:t'))
let s:reopened = planet#tab#Id(tabpagenr())

" Stale actions cannot close a replacement tab, or copy a changed file.
let s:count = tabpagenr('$')
call planet#tab_menu#Action(s:target, 'close')
call assert_equal(s:count, tabpagenr('$'))
call setreg('+', 'unchanged')
call planet#tab_menu#Action(s:reopened, 'path', s:target_window, s:target_buffer)
call assert_equal('unchanged', getreg('+'))

" Duplicate a layout with splits and modified buffers, sharing the buffers.
vsplit
call setline(1, 'unsaved shared text')
let s:buffer = bufnr()
let s:session = v:this_session
call planet#tab_menu#Action(s:reopened, 'duplicate')
call assert_equal(s:count + 1, tabpagenr('$'))
call assert_equal([s:buffer, s:buffer], tabpagebuflist())
call assert_equal('unsaved shared text', getline(1))
call assert_equal(s:session, v:this_session)
let s:duplicate = planet#tab#Id(tabpagenr())
let s:position = tabpagenr()
call planet#tab_menu#Action(s:duplicate, 'left')
call assert_equal(s:position - 1, planet#tab#Find(s:duplicate))
call planet#tab_menu#Action(s:duplicate, 'right')
call assert_equal(s:position, planet#tab#Find(s:duplicate))
call planet#tab_menu#Action(s:duplicate, 'first')
call planet#tab_menu#Action(s:duplicate, 'last')
call assert_equal(s:count + 1, planet#tab#Find(s:duplicate))

" A nofile tab offers layout actions, without misleading file operations.
tabnew
setlocal buftype=nofile
call planet#tab_menu#Build(planet#tab#Id(tabpagenr()))
call assert_equal({}, menu_info(']PVTab.Save File', 'n'))
call assert_false(empty(menu_info(']PVTab.Close Tab', 'n')))
tabclose

" Cancelling the first modified close must retain the whole remaining batch.
call planet#tab_menu#Action(s:reopened, 'close')
call planet#tab_menu#Action(s:duplicate, 'first')
call win_gotoid(s:origin)
let s:before = tabpagenr('$')
set nohidden
call timer_start(10, {timer -> test_feedinput('c')})
try
  call planet#tab_menu#Action(s:origin_id, 'others')
catch /E37\|E162/
endtry
call assert_true(planet#tab#Find(s:duplicate) > 0)
call assert_equal(s:before, tabpagenr('$'), 'cancellation stops before closing other tabs')
call assert_equal('unsaved shared text', getbufline(s:buffer, 1)[0])
call assert_equal(s:origin, win_getid())
set hidden
call setbufvar(s:buffer, '&modified', 0)

call planet#tab_menu#Action(s:origin_id, 'first')
call planet#tab_menu#Action(s:origin_id, 'close-right')
call assert_equal(1, tabpagenr('$'))
call planet#tab_menu#Build(s:origin_id)
call assert_false(menu_info(']PVTab.Close Tab', 'n').enabled)
call assert_false(menu_info(']PVTab.Move Tab Left', 'n').enabled)
call planet#tab_menu#Action(s:origin_id, 'new')
call assert_equal(2, tabpagenr('$'))
call planet#tab_menu#Action(planet#tab#Id(2), 'close-left')
call assert_equal(1, tabpagenr('$'))
call planet#tab#Cleanup()

" The optional helper fails closed when disabled, missing, or incompatible.
call planet#native_tabs#Stop()
let g:PV_native_tabs = v:false
call assert_false(planet#native_tabs#Start())
call assert_match('disabled', g:PV_native_tabs_status)
let g:PV_native_tabs = v:true
let g:PV_native_tabs_library = g:PV_test_dir .. '/missing-helper.so'
call assert_false(planet#native_tabs#Start())
call assert_false(get(g:, 'PV_native_tabs_active', 0))
let s:tooltip = &guitabtooltip
let &guitabtooltip = '%{g:GuiTabTooltip()}'
call writefile(['not a shared library'], g:PV_native_tabs_library)
call assert_false(planet#native_tabs#Start())
call assert_false(get(g:, 'PV_native_tabs_active', 0))
call planet#native_tabs#Stop()
let &guitabtooltip = s:tooltip
unlet g:PV_native_tabs_library g:PV_native_tabs

" Installed payloads resolve their helper from lib, checkout launches from build.
let s:root = g:PV_root
let g:PV_root = g:PV_test_dir .. '/installed root'
call assert_equal(g:PV_root .. '/build/native/planetvim-tabmenu.so', planet#native_tabs#Library())
call mkdir(g:PV_root .. '/lib', 'p')
call writefile(['payload fixture'], g:PV_root .. '/lib/planetvim-tabmenu.so')
call assert_equal(g:PV_root .. '/lib/planetvim-tabmenu.so', planet#native_tabs#Library())
let g:PV_root = s:root
