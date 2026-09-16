runtime plugin/globals.vim
call planet#menu#edit#Update()
set hidden
delmarks A-Z
let s:first = g:PV_test_dir .. "/first 'file' 工作.txt"
let s:second = g:PV_test_dir .. '/second.txt'
call writefile(['one', '  second line', 'three'], s:first)
call writefile(['other file'], s:second)
execute 'edit ' .. fnameescape(s:first)
call cursor(2, 5)
emenu n 📎k.Add\ Next\ Free
call assert_equal([bufnr(), 2, 5, 0], getpos("'A"))
call cursor(3, 2)
call assert_equal('Z', planet#bookmark#Set('Z'))
execute 'edit ' .. fnameescape(s:second)
call assert_equal('B', planet#bookmark#Set(v:null, v:true))
call assert_equal(["'A", "'B", "'Z"], map(planet#bookmark#Items(), 'v:val.mark'))
call assert_equal(1, planet#bookmark#Jump('A'))
call assert_equal(s:first, expand('%:p'))
call assert_equal([2, 5], getcurpos()[1:2])
call planet#bookmark#Jump('B')
call planet#bookmark#Jump('A', v:true)
call assert_equal([2, 3], getcurpos()[1:2])

" The menu lists native marks and teaches the matching Normal commands.
let s:window = win_getid()
emenu n 📎k.Open\ LocList
call assert_equal(3, len(getloclist(0)))
call assert_match('Bookmark A', getloclist(0)[0].text)
lclose
call win_gotoid(s:window)
call assert_equal('m{A-Z}', menu_info('📎k.Set / Replace').accel)
call assert_equal('`{A-Z}', menu_info('📎k.Choose Exact Position').accel)
call assert_equal("'{A-Z}", menu_info('📎k.Choose Line').accel)
call assert_match(':call planet#bookmark#Jump()', execute('tmenu 📎k.Choose\ Exact\ Position'))
call assert_match(':delmarks A-Z', execute('tmenu 📎k.Delete\ All'))

" Native viminfo owns persistence; unloaded bookmarks need no custom registry.
let &viminfofile = g:PV_test_dir .. '/marks.viminfo'
set viminfo='100,f1
wviminfo!
delmarks A-Z
execute 'bwipeout! ' .. fnameescape(s:first)
rviminfo!
call planet#bookmark#Jump('Z')
call assert_equal(s:first, expand('%:p'))
call assert_equal([3, 2], getcurpos()[1:2])

" Cancellation, validation, occupied slots and deletion preserve other marks.
call assert_equal('', planet#bookmark#Set(''))
call assert_equal(0, planet#bookmark#Delete(''))
call assert_equal(0, planet#bookmark#Jump(''))
call timer_start(20, {-> feedkeys("0\<CR>", 't')})
call assert_equal(0, planet#bookmark#Delete())
call assert_equal(3, len(planet#bookmark#Items()))
call timer_start(20, {-> feedkeys("\<C-u>C\<CR>", 't')})
call assert_equal('C', planet#bookmark#Set())
call planet#bookmark#Delete('C')
try
  call planet#bookmark#Set('A|quit')
  call assert_report('Invalid bookmark names must be rejected')
catch /one uppercase letter/
endtry
normal! ma
call planet#bookmark#Delete('B')
call assert_equal(["'A", "'Z"], map(planet#bookmark#Items(), 'v:val.mark'))
for s:letter in split('ABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs')
  call planet#bookmark#Set(s:letter)
endfor
let s:marks = planet#bookmark#Items()
call assert_equal('', planet#bookmark#Set(v:null, v:true))
call assert_equal(s:marks, planet#bookmark#Items())
emenu n 📎k.Delete\ All
call assert_equal([], planet#bookmark#Items())
call assert_equal(3, getpos("'a")[1])
call assert_equal(0, planet#bookmark#List())
call assert_equal([], getloclist(0))
enew
try
  call planet#bookmark#Set('C')
  call assert_report('A bookmark needs a file name')
catch /named file buffer/
endtry
