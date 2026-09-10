let g:PlanetVim_menus_tools = 1
call planet#menu#tools#Update()
set hidden diffopt=internal,filler,context:3,algorithm:myers
new
call setline(1, ['one', 'local', 'three'])
let s:local = bufnr()
diffthis
vnew
call setline(1, ['one', 'remote', 'three'])
let s:remote = bufnr()
diffthis
vnew
call setline(1, ['one', 'base', 'three'])
let s:base = bufnr()
diffthis
wincmd p
call assert_equal(s:remote, bufnr())
call assert_equal(2, len(planet#diff#Peers()))
call assert_equal(1, planet#diff#Transfer('get', s:local, 2, 2))
call assert_equal('local', getline(2))
call setline(2, 'merged')
call assert_equal(1, planet#diff#Transfer('put', s:base, 2, 2))
call assert_equal('merged', getbufline(s:base, 2)[0])
call assert_equal(0, planet#diff#Transfer('get', 999999))
call assert_equal(1, planet#diff#Whitespace('iwhiteall'))
call assert_match('context:3', &diffopt)
call assert_match('algorithm:myers', &diffopt)
call assert_equal(1, planet#diff#Whitespace('exact'))
call assert_notmatch('iwhite', &diffopt)
let s:old = &diffopt
call assert_equal(0, planet#diff#Option('not-a-real-option', 'value'))
call assert_equal(s:old, &diffopt)
for s:key in ['inline', 'linematch']
  let s:result = planet#diff#Option(s:key, s:key ==# 'inline' ? 'word' : '60')
  if !s:result | call assert_equal(s:old, &diffopt) | endif
  let s:old = &diffopt
endfor
if exists('+diffanchors')
  call assert_equal(1, planet#diff#Anchors('2'))
  call assert_equal('2', &l:diffanchors)
  call assert_equal(0, planet#diff#Anchors('999999'))
endif
emenu ⛏️;.Refresh
emenu ⛏️;.Stop\ This\ Window
call assert_equal(0, &diff)
wincmd p
emenu ⛏️;.Stop\ This\ Tab
for s:window in getwininfo()
  if s:window.tabnr == tabpagenr() | call assert_equal(0, getwinvar(s:window.winid, '&diff')) | endif
endfor
