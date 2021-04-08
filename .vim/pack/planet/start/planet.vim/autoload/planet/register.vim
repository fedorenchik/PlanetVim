scriptversion 4

func! planet#register#ChooseEdit() abort
  echohl Question
  echo "Register: " buffest#reg_complete()
  let l:reg_to_edit = nr2char(getchar())
  if l:reg_to_edit == "\<Esc>"
    return
  endif
  echohl None
  execute("silent Regpedit " .. l:reg_to_edit)
  execute("silent normal \<C-w>P")
endfunc
