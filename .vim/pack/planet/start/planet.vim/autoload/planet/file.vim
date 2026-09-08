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
  return planet#generate#Template(a:project_type, v:null, #{open: v:true})
endfunc

func! planet#file#NewProjectFromScript(project_type) abort
  return planet#generate#Framework(a:project_type, v:null, #{open: v:true})
endfunc

" mod can be: '', 'windo', 'tabdo windo'
func! planet#file#ClearLocalCwd(mod) abort
  let l:win_id = win_getid()
  let l:global_cwd = getcwd(-1)
  exe "noautocmd " .. a:mod .. " cd " .. fnameescape(l:global_cwd)
  call win_gotoid(l:win_id)
endfunc

" Makes global cd from tcd & clears tcd
func! planet#file#TcdToCd() abort
  if haslocaldir() == 2
    let l:win_id = win_getid()
    let l:tab_cwd = getcwd(-1, 0)
    exe "noautocmd windo cd " .. fnameescape(l:tab_cwd)
    call win_gotoid(l:win_id)
  end
endfunc

" Makes global cd from lcd & clears lcd
func! planet#file#LcdToCd() abort
  if haslocaldir() == 1
    exe "noautocmd cd " .. fnameescape(getcwd())
  end
endfunc
