scriptversion 4


func! planet#selection#CopySelectionToFile() abort
  normal! y
  let l:new_file_name = ""
  if has("browse") && planet#planet#IsGuiDialogs()
    let l:new_file_name = browse(v:true, "Choose a file to save", "", "")
  else
    let l:new_file_name = input("File: ", "", "file")
  end
  if empty(l:new_file_name)
    return
  end
  "TODO: if filename contains directories, do a "mkdir -p" (mkdir(dirs, "p")) on them
  normal! gv
  exe "w " .. l:new_file_name
  normal! gv
  echohl Directory
  echo "Saved to " .. l:new_file_name
  echohl None
endfunc

func! planet#selection#MoveSelectionToFile() abort
  call planet#selection#CopySelectionToFile()
  normal! d
endfunc
