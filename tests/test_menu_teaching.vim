" Exercise the installed menu tree, including runtime plugins and late mappings.
aunmenu *
silent! tlunmenu *
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call planet#menu_help#RefreshTips()
let s:entries = planet#actions#Search('')
call assert_true(len(s:entries) > 2000)
for s:entry in s:entries
  try
  let s:tip = split(execute('tmenu ' .. s:entry.path), "\n")[-1]
  call assert_match('^\s*t\s\+[:"]', s:tip, s:entry.label)
  call assert_notmatch('<SID>\|; complete any requested', s:tip, s:entry.label)
  catch
    call assert_report(s:entry.label .. ': ' .. v:exception)
  endtry
  let s:mode = has_key(s:entry.modes, 'n') ? 'n' : keys(s:entry.modes)[0]
  let s:hint = get(s:entry.modes[s:mode], 'accel', '')
  call assert_true(len(split(s:hint, "\t")) <= 2, s:entry.label .. ': ' .. s:hint)
endfor
call assert_equal(":undo\tu", menu_info('📝e.Undo').accel)
call assert_equal("<C-PgDown>\tgt", menu_info('🗂️t.Next').accel)
call assert_match('signature#mark#List', execute("tmenu 🔖'.Open\\ LocList"))
call assert_match(':call .*TransformSetup', execute('tmenu ✏️m.XML\ Encode'))
call assert_match(':setlocal', execute("tmenu ⚙️\\\\.Toggle\\ 'cursorline'"))
call assert_match(':FastFoldUpdate!', execute("tmenu 📜z.Update\\ All\\ Folds\\ (')"))
call assert_equal(':vert sb ', menu_info('📖u.Open VSplit').rhs)
call assert_equal(':spellrepall<CR>', menu_info('🔠-.Repeat Correction').rhs)
call assert_true(menu_info('📖u.Open VSplit').accel =~# '^:')
call assert_match('PlanetToggleComment', execute('tmenu ✏️m.Toggle\ Comment'))

" Rebuilding with translated roots keeps tips and dynamic menu metadata.
call planet#menu#Style('descriptive')
call assert_match(':undo', execute('tmenu Edit.Undo'))
call planet#menu#Group('nav')
call assert_match(':suspend', execute('tmenu GUI.Minimize'))
new
file teaching-buffer.txt
call planet#buffer#AddBuffers()
call assert_match(':confirm buffer', execute('tmenu Buffers.Buffer\ List'))
call assert_equal({}, menu_info('Edit'))
call planet#menu_help#RefreshTips()
call assert_equal({}, menu_info('Edit'))

" Context-menu tips follow the actual mode, and repaired actions keep its state.
call assert_match('Copy the selected text', execute('tmenu PopUpv.Copy'))
call assert_match(':call setreg', execute('tmenu PopUpc.Copy'))
call assert_match('system clipboard into the command line', execute('tmenu PopUpc.Paste'))
set noinsertmode
execute 'cnoremap <F11> ' .. menu_info('PopUp.Copy', 'c').rhs
call feedkeys(":echo 'menu clipboard'\<F11>\<Esc>", 'xt')
call assert_equal("echo 'menu clipboard'", getreg('+'))
cunmap <F11>
new
let s:windows = winnr('$')
execute 'inoremap <F11> ' .. menu_info('PopUp.Close', 'i').rhs
call feedkeys("i\<F11>\<Esc>", 'xt')
call assert_equal(s:windows - 1, winnr('$'))
iunmap <F11>
