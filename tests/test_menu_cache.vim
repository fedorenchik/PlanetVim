" Hints survive cache reuse; mappings and script context always come from code.
let s:module = g:PV_root .. '/.vim/pack/planet/start/planet.vim/autoload/planet/menu_help.vim'
call planet#menu_help#Reset()
PlanetMenu an Cached.Undo u
let s:expected = menu_info('Cached.Undo')
let s:tip = menu_info('Cached.Undo', 't').rhs
call planet#menu_help#SaveCache()
call assert_true(filereadable(g:PV_cache_dir .. '/menu-hints.json'))
execute 'source ' .. fnameescape(s:module)
call planet#menu_help#Reset()
PlanetMenu an Cached.Undo u
call assert_equal(1, planet#menu_help#CacheStats().hits)
call assert_equal(s:expected.rhs, menu_info('Cached.Undo').rhs)
call assert_equal(s:expected.accel, menu_info('Cached.Undo').accel)
call assert_equal(s:tip, menu_info('Cached.Undo', 't').rhs)

" Changing mappings invalidates cached accelerators.
nnoremap zx <Cmd>buffers<CR>
call planet#menu_help#Reset()
PlanetMenu an Cached.Buffers <Cmd>buffers<CR>
call assert_match('zx$', menu_info('Cached.Buffers').accel)
nunmap zx
nnoremap zy <Cmd>buffers<CR>
call planet#menu_help#Reset()
aunmenu Cached.Buffers
PlanetMenu an Cached.Buffers <Cmd>buffers<CR>
call assert_match('zy$', menu_info('Cached.Buffers').accel)
nunmap zy

" Corrupt cache data falls back to live hints.
call writefile(['{invalid json'], g:PV_cache_dir .. '/menu-hints.json')
execute 'source ' .. fnameescape(s:module)
call planet#menu_help#Reset()
PlanetMenu an Cached.Undo u
call assert_equal(0, planet#menu_help#CacheStats().hits)
call assert_equal(s:tip, menu_info('Cached.Undo', 't').rhs)

" Cache strings cannot introduce Ex commands, even if manually modified.
call planet#menu_help#SaveCache()
let s:cache = json_decode(join(readfile(g:PV_cache_dir .. '/menu-hints.json'), "\n"))
for s:bucket in values(s:cache)
  if has_key(s:bucket, 'an Cached.Undo u')
    let s:bucket['an Cached.Undo u'] = [':undo | let g:PV_cache_injected = 1', "hint\n|let g:PV_cache_injected = 1"]
  endif
endfor
call writefile([json_encode(s:cache)], g:PV_cache_dir .. '/menu-hints.json')
execute 'source ' .. fnameescape(s:module)
call planet#menu_help#Reset()
PlanetMenu an Cached.Undo u
call assert_false(exists('g:PV_cache_injected'))
call assert_equal('u', menu_info('Cached.Undo').rhs)

let g:PV_menu_cache = 0
call planet#menu_help#Reset()
PlanetMenu an Cached.Undo u
call assert_equal(s:expected.accel, menu_info('Cached.Undo').accel)
unlet g:PV_menu_cache
