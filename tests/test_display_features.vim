let s:original = &l:statusline
if exists('+pumopt')
  set pumopt=height:10
  call assert_equal(1, planet#display#Popup('border', 'round'))
  call assert_match('height:10', &pumopt)
  call assert_match('border:round', &pumopt)
  call planet#display#Popup('opacity', '85')
  call assert_match('opacity:85', &pumopt)
  call planet#display#Popup('border', '')
  call assert_notmatch('border:', &pumopt)
else
  call assert_equal(0, planet#display#Popup('border', 'round'))
endif
if exists('+scrolloffpad')
  setlocal scrolloff=0 scrolloffpad=0
  call planet#display#Padding()
  call assert_equal(1, &scrolloffpad)
  call assert_equal(2, &scrolloff)
  call planet#display#Padding()
  call assert_equal(0, &scrolloffpad)
endif
if exists('+statuslineopt')
  let s:options = &l:statuslineopt
  call assert_equal(1, planet#display#Status('multiline'))
  call assert_match('maxheight:2', &l:statuslineopt)
  call assert_match('%@', &l:statusline)
  redraw!
  call planet#display#Status('restore')
  call assert_equal(s:options, &l:statuslineopt)
else
  call assert_equal(0, planet#display#Status('multiline'))
endif
if has('statusline_click')
  call assert_equal(1, planet#display#Status('clickable'))
  call assert_match('planet#display#Click', &l:statusline)
  redraw!
  call planet#display#Status('restore')
else
  call assert_equal(0, planet#display#Status('clickable'))
endif
call assert_equal(s:original, &l:statusline)

if !planet#image#Supported()
  call assert_equal(0, planet#image#Open('/does/not/exist.png'))
  finish
endif
func! s:Wait() abort
  for l:attempt in range(500)
    if planet#image#State().phase !=# 'loading' | return | endif
    sleep 10m
  endfor
  call assert_report('Image preview timed out')
endfunc
let s:path = g:PV_test_dir .. '/image with spaces.png'
let s:python = [exepath('python3'), '-c', 'from PIL import Image; import sys; Image.new("RGB", (1400, 1000), "red").save(sys.argv[1])', s:path]
let s:fixture = job_start(s:python, #{out_io: 'null', err_io: 'null'})
for s:attempt in range(200)
  if job_status(s:fixture) !=# 'run' | break | endif
  sleep 10m
endfor
call assert_equal(0, job_info(s:fixture).exitval, 'Pillow must be installed for this optional-feature test')
call assert_equal(1, planet#image#Open(s:path))
call s:Wait()
let s:state = planet#image#State()
call assert_equal('ready', s:state.phase, string(s:state))
if s:state.phase ==# 'ready'
  call assert_true(s:state.width <= 1024 && s:state.height <= 768)
  call assert_true(popup_getpos(s:state.id).visible)
  call planet#image#Resize()
  sleep 200m
  call s:Wait()
  call assert_equal('ready', planet#image#State().phase)
  call assert_notequal(s:state.id, planet#image#State().id)
  call feedkeys("\<Esc>", 'xt')
  call assert_equal('idle', planet#image#State().phase)
endif
call planet#image#Open(s:path)
call planet#image#Close()
sleep 200m
call assert_equal('idle', planet#image#State().phase, 'Closing cancels a pending decoder')
call writefile(['not an image'], s:path)
call planet#image#Open(s:path)
call s:Wait()
call assert_equal('error', planet#image#State().phase)
call planet#image#Close()
