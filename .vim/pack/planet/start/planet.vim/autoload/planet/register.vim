vim9script
export def ChooseEdit(): any
  echohl Question
  echo "Register: " buffest#reg_complete()
  var reg_to_edit: any = nr2char(getchar())
  if reg_to_edit == "\<Esc>"
    return 0
  endif
  echohl None
  execute("silent Regpedit " .. reg_to_edit)
  execute("silent normal \<C-w>P")
  return 0
enddef
