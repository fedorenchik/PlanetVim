" Compile first-party runtime functions, including optional menu actions.
" Keep this fixture in legacy syntax to exercise the public compatibility API.
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
set nomore
let s:root = g:PV_root .. '/.vim/pack/planet/start/'
let s:autoload = s:root .. 'planet.vim/autoload/planet'
let s:loaded = map(getscriptinfo(), 'v:val.name')
for s:path in glob(s:autoload .. '/**/*.vim', 0, 1)
  if index(s:loaded, s:path) < 0
    execute 'source ' .. fnameescape(s:path)
  endif
endfor
" The generated Vim plugin is first-party code too.
execute 'source ' .. fnameescape(s:root .. 'planet.vim/templates/vim-plugin/plugin/vim-plugin.vim')
call assert_equal('This Plugin Works!', trim(execute('call MyNewFunction()')))
let s:compiled = []
for s:script in getscriptinfo()
  if stridx(s:script.name, s:root) != 0
        \ && index([g:PV_root .. '/.vimrc', g:PV_root .. '/scripts/planetvim.vim'], s:script.name) < 0
    continue
  endif
  for s:name in getscriptinfo({'sid': s:script.sid})[0].functions
    " Numeric tag addresses require legacy context on the minimum Vim version.
    " test_tag_preview.vim exercises this one native bridge through its menu.
    if s:script.name ==# s:root .. 'planet.vim/plugin/planet.vim'
          \ && s:name ==# '<SNR>' .. s:script.sid .. '_LocalPreviewTag'
      continue
    endif
    try
      execute 'defcompile ' .. s:name
      call add(s:compiled, s:name)
    catch
      call assert_report(s:name .. ': ' .. v:exception .. ' at ' .. v:throwpoint)
    endtry
  endfor
endfor
call assert_true(len(s:compiled) > 500, 'compile coverage must include the full runtime')

" Lowercase legacy autoload names are still compiled and callable.
call assert_match('PUSH\|EXEC', execute('disassemble planet#planet#f'))
call assert_equal('', planet#input#Pending())

" The popup retains its defining script's callback context after migration.
set spell spelllang=en_us
call setline(1, 'mispeling')
call cursor(1, 1)
doautocmd MenuPopup
call assert_false(empty(menu_info('PopUp', 'n')))
let s:suggestions = filter(copy(menu_info('PopUp', 'n').submenus), 'v:val =~# "^Change"')
call assert_equal(1, len(s:suggestions), 'spelling suggestions must be present')
if !empty(s:suggestions)
  let s:submenu = 'PopUp.' .. escape(s:suggestions[0], '.\\ ')
  let s:replacement = menu_info(s:submenu, 'n').submenus[0]
  execute 'emenu ' .. s:submenu .. '.' .. escape(s:replacement, '.\\ ')
  call assert_notequal('mispeling', getline(1), 'spelling menu callback must run')
endif
" Startup guards permit re-sourcing without losing script-local callbacks.
execute 'source ' .. fnameescape(g:PV_root .. '/.vimrc')
doautocmd MenuPopup
runtime plugin/planet.vim
call assert_equal(1, exists('*PreviewWord'))
