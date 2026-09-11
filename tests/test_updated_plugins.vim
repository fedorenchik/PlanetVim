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
  call clap#handler#exit()
  Clap buffers
  call assert_true(len(g:clap.display.get_lines()) > 0, 'built-in source provider without Maple')
  call clap#handler#exit()
  Clap
  call assert_match('buffers:', join(g:clap.display.get_lines(), "\n"))
  call clap#handler#exit()
  call g:clap_provider_files.sink('picker file.txt')
  call assert_equal(s:file, expand('%:p'))
  call assert_equal(['picker content'], getline(1, '$'))
  " User provider definitions take precedence over the fallback.
  let g:clap_provider_files = {'source': ['custom entry'], 'sink': {line -> 0}}
  call remove(g:clap.registrar, 'files')
  Clap files
  call assert_equal(['custom entry'], g:clap.display.get_lines())
  call clap#handler#exit()
endif
