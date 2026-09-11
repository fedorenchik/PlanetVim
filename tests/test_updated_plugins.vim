let g:PV_clangd_argv = []
let g:PV_pylsp_argv = []
execute 'source ' .. fnameescape(g:PV_root .. '/scripts/planetvim.vim')
runtime! plugin/**/*.vim
call assert_true(exists('*CrystallineStatuslineFn'))
call assert_match('%f', CrystallineStatuslineFn(winnr()))
vsplit
call assert_match('Inactive', CrystallineStatuslineFn(winnr('#')))
call assert_match('flog#ExecTmp', execute('autocmd Flog'))
call assert_notmatch('++query', maparg('<Space>s', 'n'))

" Exercise the popup and its selection, without any native Clap binary.
if !clap#maple#is_available()
  let s:file = g:PV_test_dir .. '/picker file.txt'
  call writefile(['picker content'], s:file)
  execute 'cd ' .. fnameescape(g:PV_test_dir)
  Clap files
  for s:attempt in range(200)
    if match(g:clap.display.get_lines(), 'picker file.txt') >= 0 | break | endif
    sleep 10m
  endfor
  call assert_match('picker file.txt', join(g:clap.display.get_lines(), "\n"))
  call g:clap.input.set('pkr')
  call g:clap.provider._().on_typed()
  call assert_equal(['picker file.txt'], g:clap.display.get_lines())
  call g:clap.input.set('impossible-name-999999')
  call g:clap.provider._().on_typed()
  call assert_true(g:__clap_has_no_matches)
  call g:clap.input.set('')
  call g:clap.provider._().on_typed()
  call assert_false(g:__clap_has_no_matches, 'clearing a failed search restores selection')
  call clap#handler#exit()
  Clap buffers
  call assert_true(len(g:clap.display.get_lines()) > 0, 'built-in source provider without Maple')
  call clap#handler#exit()
  Clap
  call assert_match('buffers:', join(g:clap.display.get_lines(), "\n"))
  call clap#handler#exit()
  call g:clap_provider_providers.sink('files: File picker')
  for s:attempt in range(100)
    sleep 10m
    if g:clap.provider.id ==# 'files' | break | endif
  endfor
  call assert_equal('files', g:clap.provider.id)
  call assert_match('picker file.txt', join(g:clap.display.get_lines(), "\n"))
  call clap#handler#exit()
  call g:clap_provider_files.sink('picker file.txt')
  call assert_equal(s:file, expand('%:p'))
  call assert_equal(['picker content'], getline(1, '$'))
  if executable('rg')
    let g:clap_disable_run_rooter = 1
    execute 'cd ' .. fnameescape(g:PV_test_dir)
    Clap grep --query=content
    for s:attempt in range(200)
      if match(g:clap.display.get_lines(), 'picker content') >= 0 | break | endif
      sleep 10m
    endfor
    call assert_match('picker content', join(g:clap.display.get_lines(), "\n"))
    let s:match = filter(g:clap.display.get_lines(), {_, row -> row =~# 'picker file.txt:1:8:picker content'})[0]
    call clap#handler#exit()
    call g:clap_provider_grep.sink(s:match)
    call assert_equal(s:file, expand('%:p'))
    call assert_equal(8, col('.'))
    Clap grep --query=[
    for s:attempt in range(200)
      if match(g:clap.display.get_lines(), 'regex parse error') >= 0 | break | endif
      sleep 10m
    endfor
    call assert_match('regex parse error', join(g:clap.display.get_lines(), "\n"))
    call clap#handler#exit()
  endif
  " User provider definitions take precedence over the fallback.
  let g:clap_provider_files = {'source': ['custom entry'], 'sink': {line -> 0}}
  call remove(g:clap.registrar, 'files')
  Clap files
  call assert_equal(['custom entry'], g:clap.display.get_lines())
  call clap#handler#exit()
endif
