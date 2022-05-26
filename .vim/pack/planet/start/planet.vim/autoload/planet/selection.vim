scriptversion 4

" XXX: Currently only works linewise.
func! planet#selection#CopySelectionToFile(to_delete = v:false, flags = '') abort
  let l:range = ""
  if line("'<") != 0
    let l:range = "'<,'>"
  endif
  exe "silent " .. l:range .. "y"
  let l:new_file_name = ""
  if has("browse") && planet#planet#IsGuiDialogs()
    let l:new_file_name = browse(v:true, "Choose a file to save", "", "")
  else
    call inputsave()
    call feedkeys("\<C-z>")
    let l:new_file_name = input("File: ", "", "file")
    call inputrestore()
  endif
  if empty(l:new_file_name)
    return
  endif
  call mkdir(fnamemodify(l:new_file_name, ":h"), "p")
  call writefile(getreg('0', 1, v:true), l:new_file_name, a:flags)
  if a:to_delete
    exe l:range .. "d"
  endif
  echohl Directory
  echo "\rSaved to " .. l:new_file_name
  echohl None
endfunc
