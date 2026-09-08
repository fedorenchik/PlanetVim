execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
set nomore
let s:original_path = $PATH
try
  if !has('win32') && !executable('xdg-open')
    let s:bin = g:PV_test_dir .. '/bin'
    call mkdir(s:bin, 'p')
    call writefile(['#!/bin/sh', 'exit 99'], s:bin .. '/xdg-open')
    call setfperm(s:bin .. '/xdg-open', 'rwx------')
    let $PATH = s:bin .. ':' .. $PATH
  endif
  " Capture the process boundary. No desktop browser or network is launched.
  call planet#term#Result(-1)
  let s:stub = g:PV_test_dir .. '/autoload/planet'
  call mkdir(s:stub, 'p')
  call writefile([
        \ 'func! planet#term#RunGuiApp(argv, ...) abort',
        \ '  let g:PV_url_argv = copy(a:argv)',
        \ '  return 1',
        \ 'endfunc'], s:stub .. '/term.vim')
  execute 'source ' .. fnameescape(s:stub .. '/term.vim')
  new
  let s:url = 'https://example.invalid/page?q=two%20words&literal=$(value);x="quote"#fragment'
  call setline(1, s:url)
  call cursor(1, 1)
  let s:prefix = has('win32') ? ['rundll32.exe', 'url.dll,FileProtocolHandler'] : ['xdg-open']
  call feedkeys('gx', 'xt')
  call assert_equal(s:prefix + [s:url], get(g:, 'PV_url_argv', []))
  call assert_equal(s:url, getline(1))
  let s:spaced = 'https://example.invalid/a path?first=1&second=two words'
  call assert_equal(1, planet#gui#OpenUrl(s:spaced))
  call assert_equal(s:prefix + [s:spaced], g:PV_url_argv)
finally
  let $PATH = s:original_path
endtry
