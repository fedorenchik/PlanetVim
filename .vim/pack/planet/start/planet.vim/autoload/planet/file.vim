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
  let l:project_name = input("Project Name: ", 'my-' .. a:project_type, "dir")
  if ! empty(l:project_name)
    if isdirectory(l:project_name) || filereadable(l:project_name) || filewritable(l:project_name)
      call popup_notification("Error: Directory or file already exists! Please, change project name.", {})
      return
    end
    call mkdir(l:project_name)
    call planet#term#RunScript('copy-template ' .. a:project_type .. ' ' .. l:project_name)
    tabnew
    exe "tcd " .. l:project_name
    Fern . -reveal=% -drawer -toggle
  end
endfunc

func! planet#file#NewProjectFromScript(project_type) abort
  let l:project_name = input("Project Name: ", 'my-' .. a:project_type, "dir")
  if ! empty(l:project_name)
    if isdirectory(l:project_name) || filereadable(l:project_name) || filewritable(l:project_name)
      call popup_notification("Error: Directory or file already exists! Please, change project name.", {})
      return
    end
    call mkdir(l:project_name)
    call planet#term#RunScript('create-' .. a:project_type .. '-project ' .. l:project_name)
    tabnew
    exe "tcd " .. l:project_name
    Fern . -reveal=% -drawer -toggle
  end
endfunc

" mod can be: '', 'windo', 'tabdo windo'
func! planet#file#ClearLocalCwd(mod) abort
  let l:win_id = win_getid()
  let l:global_cwd = getcwd(-1)
  exe "noautocmd " .. a:mod .. " cd " .. l:global_cwd
  call win_gotoid(l:win_id)
endfunc

" Makes global cd from tcd & clears tcd
func! planet#file#TcdToCd() abort
  if haslocaldir() == 2
    let l:win_id = win_getid()
    let l:tab_cwd = getcwd(-1, 0)
    exe "noautocmd windo cd " .. l:tab_cwd
    call win_gotoid(l:win_id)
  end
endfunc

" Makes global cd from lcd & clears lcd
func! planet#file#LcdToCd() abort
  if haslocaldir() == 1
    exe "noautocmd cd " .. getcwd()
  end
endfunc
