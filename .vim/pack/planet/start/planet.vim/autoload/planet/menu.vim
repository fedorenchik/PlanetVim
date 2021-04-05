scriptversion 4

func! planet#menu#MenuifyName(name) abort
  let menu_name = a:name
  if empty(menu_name)
    let menu_name = "[No Name]"
  endif
  let menu_name = escape(menu_name, "\\. \t|")
  let menu_name = substitute(menu_name, "&", "&&", "g")
  let menu_name = substitute(menu_name, "\n", "^@", "g")
  return menu_name
endfunc

