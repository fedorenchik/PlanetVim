let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call assert_equal([], filter(getscriptinfo(), 'v:val.name =~# "autoload/planet/action_index.vim$"'))
call assert_equal([], filter(getscriptinfo(), 'v:val.name =~# "vista/executive/ctags.vim$"'))
call assert_false(exists('*Vim_Markdown_Preview'))
call assert_equal(2, exists(':Vista'))
call planet#startup#NearestSymbol()
call assert_equal([], filter(getscriptinfo(), 'v:val.name =~# "vista/executive/ctags.vim$"'))
call assert_true(len(planet#actions#Search('')) > 1000)
call planet#startup#MarkdownPreview()
call assert_true(exists('*Vim_Markdown_Preview'))
call assert_true(exists('*Vim_Markdown_Preview_Local'))
let s:count = len(getscriptinfo())
call planet#startup#MarkdownPreview()
call assert_equal(s:count, len(getscriptinfo()))

" A real buffer activates LSP and receives diagnostics without reopening it.
call assert_true(get(g:, 'PV_lsp_deferred', 0))
call lsp#register_server(#{name: 'planet-startup-fixture', cmd: {server -> [exepath('python3'), g:PV_root .. '/tests/helpers/lsp_display_server.py']}, allowlist: ['planetstartuptest']})
let s:file = g:PV_test_dir .. '/startup.fixture'
call writefile(['value=1'], s:file)
execute 'edit ' .. fnameescape(s:file)
setfiletype planetstartuptest
call assert_false(g:PV_lsp_deferred)
for s:attempt in range(300)
  if lsp#get_server_status('planet-startup-fixture') ==# 'running'
        \ && lsp#internal#diagnostics#state#_get_diagnostics_count_for_buffer(bufnr()).warning > 0
    break
  endif
  sleep 10m
endfor
call assert_equal('running', lsp#get_server_status('planet-startup-fixture'))
call assert_true(lsp#internal#diagnostics#state#_get_diagnostics_count_for_buffer(bufnr()).warning > 0)
call lsp#stop_server('planet-startup-fixture')

if has('linux')
  let s:shell = &shell
  let s:flags = &shellcmdflag
  set shell=/usr/bin/fish shellcmdflag=-c
  call planet#startup#ConfigureShell()
  call assert_equal('/usr/bin/fish', &shell, 'interactive terminals retain Fish')
  call assert_equal('--no-config -c', &shellcmdflag)
  set shellcmdflag=-c
  let g:PV_fast_shell = 0
  call planet#startup#ConfigureShell()
  call assert_equal('-c', &shellcmdflag)
  unlet g:PV_fast_shell
  set shellcmdflag=--private\ -c
  call planet#startup#ConfigureShell()
  call assert_equal('--private -c', &shellcmdflag, 'explicit flags are preserved')
  if executable('/usr/bin/fish')
    let s:xdg = $XDG_CONFIG_HOME
    let $XDG_CONFIG_HOME = g:PV_test_dir .. '/fish config'
    call mkdir($XDG_CONFIG_HOME .. '/fish', 'p')
    let s:marker = g:PV_test_dir .. '/fish-config-ran'
    call writefile(['echo configured >> ' .. shellescape(s:marker),
          \ 'if status is-interactive; exit; end'], $XDG_CONFIG_HOME .. '/fish/config.fish')
    try
      set shellcmdflag=-c
      call planet#startup#ConfigureShell()
      call assert_equal('fast', system('printf fast'))
      call assert_false(filereadable(s:marker), 'noninteractive Fish skips configuration')
      let s:terminal = term_start(&shell, #{hidden: 1})
      call term_wait(s:terminal, 300)
      for s:attempt in range(100)
        if filereadable(s:marker) | break | endif
        sleep 10m
      endfor
      call assert_true(filereadable(s:marker), 'plain :terminal still initializes interactive Fish')
      execute 'silent! bwipeout! ' .. s:terminal
    finally
      let $XDG_CONFIG_HOME = s:xdg
    endtry
  endif
  let &shell = s:shell
  let &shellcmdflag = s:flags
endif
