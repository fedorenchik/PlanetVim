new
file first.txt
let s:first = bufnr()
call planet#winbar#Change('add')
call planet#winbar#Change('add')
call assert_equal([s:first], w:PV_winbar_buffers)
enew
file second.txt
let s:second = bufnr()
call planet#winbar#Change('add')
call assert_equal([s:first, s:second], w:PV_winbar_buffers)
call assert_equal(2, len(menu_info('WinBar').submenus))
call planet#winbar#Change('others')
call assert_equal([s:second], w:PV_winbar_buffers)
call planet#winbar#Change('remove')
call assert_equal([], w:PV_winbar_buffers)
call planet#winbar#Change('clear')
call assert_equal({}, menu_info('WinBar'))
call assert_equal(0, planet#winbar#Terminal(1))
