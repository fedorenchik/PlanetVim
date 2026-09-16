let s:root = g:PV_test_dir .. '/diagnostics 工作'
call mkdir(s:root, 'p')
execute 'cd ' .. fnameescape(s:root)
let s:source = s:root .. '/source with spaces.c'
call writefile(['int main(void) {', '  broken syntax;', '}'], s:source)
let s:buffer = planet#term#RunArgv(['cc', '-c', s:source, '-o', s:root .. '/out.o'], v:false, v:false, v:true, s:root)
" Parse relative paths against the invocation cwd even if the user changes tabs.
tabnew
execute 'tcd ' .. fnameescape(g:PV_test_dir)
for s:i in range(600)
  if get(planet#term#Result(s:buffer), 'status', '') !=# 'running' | break | endif
  sleep 10m
endfor
let s:result = planet#term#Result(s:buffer)
call assert_equal('failed', s:result.status)
call assert_true(filereadable(s:result.log_file))
call assert_true(len(s:result.diagnostics) > 0)
call assert_equal(s:source, s:result.diagnostics[0].filename)
call assert_equal(2, s:result.diagnostics[0].lnum)
call assert_match('error:', join(readfile(s:result.log_file), "\n"))
call assert_false(has_key(s:result, 'diagnostic_error'))
call assert_equal(s:source, bufname(getqflist()[0].bufnr))
call assert_equal(s:root, getqflist({'context': 0}).context.project)
call assert_equal(1, len(planet#diagnostics#Parse(["\e[31mrelative.c:12:3: warning: message\e[0m"], s:root, 'compiler')))
let s:items = planet#diagnostics#Parse(['CMake Error at CMakeLists.txt:7 (message):', '  a useful error'], s:root, 'compiler')
call assert_equal(7, s:items[0].lnum)
call assert_match('a useful error', s:items[0].text)
let s:items = planet#diagnostics#Parse(['  File "app.py", line 4, in run', 'ValueError: invalid input'], s:root, 'python')
call assert_equal(s:root .. '/app.py', s:items[0].filename)
call assert_match('ValueError', s:items[0].text)
tabclose
