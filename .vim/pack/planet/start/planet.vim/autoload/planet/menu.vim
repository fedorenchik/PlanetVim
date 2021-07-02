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

func! planet#menu#AddMenuItem(priority, text, command, tooltip) abort
    "TODO...
    an 110.10  &File.&New                                   :confirm enew<CR>
    an a:priority a:text a:command
    tln 110.10  &File.&New                                  :confirm enew<CR>
    no <A-f>n :confirm enew<CR>
    no a:map a:command
    ln <A-f>n :confirm enew<CR>
    tno <A-f>n :confirm enew<CR>
endfunc
