" A comma is a filename character as well as the spellfile list separator.
let s:isfname = &isfname
let s:root = g:PV_test_dir .. "/personal spelling, 'quoted' 工作"
let g:PV_state_dir = s:root .. '/state'
let s:global = s:root .. '/ordinary.utf-8.add'
let s:override = s:root .. '/override.utf-8.add'
call mkdir(s:root, 'p')
call planet#writing#SetSpellFile(escape(s:global, ','), v:false)
call assert_equal(s:isfname, &isfname)
enew
call assert_equal(escape(s:global, ','), &l:spellfile, 'new buffers inherit the dictionary')
setlocal spell spelllang=en_us
call setline(1, 'planetvimordinaryword')
normal! gg0zg
call assert_match('planetvimordinaryword', join(readfile(s:global), "\n"))

" Filetype setup, repeat setup, and cleanup must preserve the original value.
setlocal filetype=markdown
call planet#writing#Setup()
let s:state = planet#paths#State('spell') .. '/personal.utf-8.add'
call assert_equal(escape(s:state, ','), &l:spellfile)
call setline(1, 'planetvimwritingword')
normal! gg0zg
call assert_match('planetvimwritingword', join(readfile(s:state), "\n"))
call planet#writing#Setup()
call assert_equal(['', ''], spellbadword('planetvimwritingword'))
call planet#writing#Undo()
call assert_equal(escape(s:global, ','), &l:spellfile)
call assert_equal(['', ''], spellbadword('planetvimordinaryword'))

let g:PV_personal_spell_file = s:override
call planet#writing#Setup()
call setline(1, 'planetvimoverrideword')
normal! gg0zg
call assert_match('planetvimoverrideword', join(readfile(s:override), "\n"))
call planet#writing#Undo()
call assert_equal('bad', spellbadword('planetvimoverrideword')[1])
call planet#writing#Setup()
call assert_equal(['', ''], spellbadword('planetvimoverrideword'), 'compiled dictionary reloads from the native path')
call planet#writing#Undo()
call assert_equal(s:isfname, &isfname)

try
  call planet#writing#SetSpellFile(s:root .. '/invalid-extension')
  call assert_report('Invalid dictionary extension must fail')
catch /E474/
endtry
call assert_equal(s:isfname, &isfname, 'failed assignment restores filename settings')
