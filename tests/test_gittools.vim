let s:root = g:PV_test_dir .. '/git tools 工作'
call mkdir(s:root, 'p')
execute 'tcd ' .. fnameescape(s:root)
let s:buffers = []

func! s:Wait(buffer) abort
  call assert_true(a:buffer > 0, 'command started')
  if a:buffer <= 0
    return {}
  endif
  call add(s:buffers, a:buffer)
  for l:i in range(500)
    call term_wait(a:buffer, 10)
    sleep 10m
    if planet#term#Result(a:buffer).status !=# 'running'
      return planet#term#Result(a:buffer)
    endif
  endfor
  call planet#term#Cancel(a:buffer)
  call assert_report('Git tools command timed out')
  return {}
endfunc

func! s:Git(args) abort
  let l:result = planet#gittools#Query(a:args)
  call assert_equal(0, l:result.status, string(a:args))
  return l:result.lines
endfunc

try
  call assert_equal(['two words', '', 'a;b', '$(literal)', 'C:\temp\name'], planet#gittools#Arguments('"two words" "" a;b $(literal) C:\temp\name'))
  call assert_equal(["a'b", 'quote"x', 'one two'], planet#gittools#Arguments('"a''b" "quote\"x" one\ two'))
  try
    call planet#gittools#Arguments('"unfinished')
    call assert_report('unmatched quotes accepted')
  catch /unmatched argument quote/
  endtry
  call assert_equal(0, planet#gittools#Run(['status']))
  call s:Git(['init', '-q'])
  call s:Git(['config', 'core.fsmonitor', 'false'])
  call s:Git(['config', 'commit.gpgsign', 'false'])
  call s:Git(['config', 'core.hooksPath', s:root .. '/empty-hooks'])
  call s:Git(['config', 'user.name', 'PlanetVim Fixture'])
  call s:Git(['config', 'user.email', 'fixture@example.invalid'])
  let s:file = s:root .. '/literal [file]; name.txt'
  call writefile(['initial'], s:file)
  execute 'edit ' .. fnameescape(s:file)
  call assert_equal('success', get(s:Wait(planet#gittools#File('add')), 'status', ''))
  call s:Git(['commit', '-qm', 'initial'])
  call assert_equal(0, planet#gittools#Named('tag', 'Tag', [], '', v:true))
  call assert_equal(0, planet#gittools#Named('tag', 'Tag', [], '-invalid', v:true))
  call assert_equal('success', get(s:Wait(planet#gittools#Named('tag', 'Tag', [], 'release;literal', v:true)), 'status', ''))
  call assert_equal(['release;literal'], s:Git(['tag', '--list']))
  call assert_equal(0, planet#gittools#Command('tag', [], '', "\x01", v:true))
  call assert_equal('success', get(s:Wait(planet#gittools#Notes('add', ['-m', 'note; $literal with spaces', 'HEAD'], v:true)), 'status', ''))
  call assert_equal(['note; $literal with spaces'], s:Git(['notes', 'show', 'HEAD']))
  call assert_equal('success', get(s:Wait(planet#gittools#Notes('append', ['-m', 'second paragraph', 'HEAD'], v:true)), 'status', ''))
  call assert_equal(['note; $literal with spaces', '', 'second paragraph'], s:Git(['notes', 'show', 'HEAD']))
  call assert_equal('success', get(s:Wait(planet#gittools#Notes('enable-push', 'origin', v:true)), 'status', ''))
  for s:i in range(300)
    if index(planet#gittools#Query(['config', '--get-all', 'remote.origin.push']).lines, 'refs/notes/*:refs/notes/*') >= 0
      break
    endif
    sleep 10m
  endfor
  call assert_equal(['HEAD', 'refs/notes/*:refs/notes/*'], s:Git(['config', '--get-all', 'remote.origin.push']))
  call assert_equal(1, planet#gittools#Notes('enable-push', 'origin', v:true), 'notes push configuration is idempotent')
  let s:moved = s:root .. '/moved [file]; name.txt'
  call assert_equal(0, planet#gittools#File('move', '', v:true))
  call assert_equal('success', get(s:Wait(planet#gittools#File('move', s:moved, v:true)), 'status', ''))
  call assert_false(filereadable(s:file))
  call assert_true(filereadable(s:moved))
  call assert_equal(s:moved, expand('%:p'), 'successful move follows the buffer name')
  call s:Git(['commit', '-qam', 'rename'])
  call writefile(['changed on disk'], s:moved)
  edit!
  call assert_equal('success', get(s:Wait(planet#gittools#File('restore', 'HEAD', v:true)), 'status', ''))
  call assert_equal(['initial'], getline(1, '$'), 'restored disk contents refresh the unmodified buffer')
  let s:tree = s:Git(['rev-parse', 'HEAD^{tree}'])[0]
  let s:input = s:root .. '/tree input.txt'
  call writefile(s:Git(['ls-tree', 'HEAD']), s:input)
  let s:treebuffer = planet#gittools#Input('mktree', [], '', [], s:input, v:true)
  call assert_equal('success', get(s:Wait(s:treebuffer), 'status', ''))
  call assert_match(s:tree, join(getbufline(s:treebuffer, 1, '$'), "\n"))
  let s:worktree = g:PV_test_dir .. '/sibling tree'
  call assert_equal('success', get(s:Wait(planet#gittools#Worktree('detached', [s:worktree, 'HEAD'], v:true)), 'status', ''))
  call assert_true(filereadable(s:worktree .. '/moved [file]; name.txt'))
  call assert_equal('success', get(s:Wait(planet#gittools#Worktree('remove', [s:worktree], v:true)), 'status', ''))
  call assert_false(isdirectory(s:worktree))
  call assert_equal('failed', get(s:Wait(planet#gittools#Run(['rev-parse', '--verify', 'missing-revision'])), 'status', ''))
  let g:PlanetVim_menus_tools = 1
  call planet#menu#tools#Update()
  call assert_match("planet#gittools#Notes('list')", menu_info('🔀g.Notes.List', 'n').rhs)
  call assert_match("planet#gittools#Stash('branch')", menu_info('🔀g.Stash (j).Branch', 'n').rhs)
  let g:PlanetVim_menus_tools = 0
  call planet#menu#tools#Update()
  for s:rootmenu in ['🔀g', '⛏️;', '🔤\.', '🔠-', '🔧o']
    call assert_equal({}, menu_info(s:rootmenu, 'n'), 'all Tools menu roots removed: ' .. s:rootmenu)
  endfor
  let g:PlanetVim_menus_tools = 1
  call planet#menu#tools#Update()
  for s:rootmenu in ['🔀g', '⛏️;', '🔤\.', '🔠-', '🔧o']
    call assert_false(empty(menu_info(s:rootmenu, 'n')), 'all Tools menu roots restored: ' .. s:rootmenu)
  endfor
  if !has('win32')
    let s:bin = s:root .. '/fake Git extensions'
    call mkdir(s:bin, 'p')
    let s:old_path = $PATH
    let s:old_capture = getenv('PLANETVIM_TOOL_CAPTURE')
    let $PLANETVIM_TOOL_CAPTURE = s:root .. '/extension argv.json'
    let s:python = exepath(executable('python3') ? 'python3' : 'python')
    for s:tool in ['git-subrepo', 'git-cp']
      call writefile(['#!' .. s:python, 'import json, os, sys',
            \ 'with open(os.environ["PLANETVIM_TOOL_CAPTURE"], "w") as output:',
            \ '    json.dump(sys.argv[1:], output)'], s:bin .. '/' .. s:tool)
      call setfperm(s:bin .. '/' .. s:tool, 'rwx------')
    endfor
    let $PATH = s:bin .. ':' .. s:old_path
    try
      call assert_equal('success', get(s:Wait(planet#gittools#Subrepo('status', '', ['vendor name;literal'], v:true)), 'status', ''))
      call assert_equal(['status', 'vendor name;literal'], json_decode(join(readfile($PLANETVIM_TOOL_CAPTURE), "\n")))
      call assert_equal('success', get(s:Wait(planet#gittools#Command('cp', [], '', ['source;literal', 'destination path'], v:true, 'git-extras')), 'status', ''))
      call assert_equal(['source;literal', 'destination path'], json_decode(join(readfile($PLANETVIM_TOOL_CAPTURE), "\n")))
    finally
      let $PATH = s:old_path
      call setenv('PLANETVIM_TOOL_CAPTURE', s:old_capture)
    endtry
  endif
finally
  for s:buffer in s:buffers
    if bufexists(s:buffer)
      call planet#term#Cancel(s:buffer)
      execute 'bwipeout! ' .. s:buffer
    endif
  endfor
endtry
