scriptversion 4

func! planet#file#OldFilesQF() abort
  call setqflist([], ' ', {'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})
endfunc

func! QfOldFiles(info) abort
  let items = getqflist({'id' : a:info.id, 'items' : 1}).items
  let l = []
  for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
    call add(l, fnamemodify(bufname(items[idx].bufnr), ':p:.'))
  endfor
  return l
endfunc

func! planet#file#NewProject(project_type) abort
  let l:project_name = input("Project Name: ", 'test-' .. a:project_type, "dir")
  if ! empty(l:project_name)
    call planet#term#RunScript('copy-template ' .. a:project_type .. ' ' .. l:project_name)
  end
endfunc

" mod can be: '', 'windo', 'tabdo windo'
func! planet#file#ClearLocalCwd(mod) abort
  let l:win_id = win_getid()
  let l:global_cwd = getcwd(-1)
  exe "noautocmd " .. a:mod .. " cd " .. l:global_cwd
  call win_gotoid(l:win_id)
endfunc
