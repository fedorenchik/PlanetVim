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



func! planet#menu#Plain() abort
  for l:root in ['🌐&P', '📁&f', '📝&e', '✏️&m', '🔎&/', '🖍️&i', '📺&v', '↕️&,', '🧭&n', '📋&"', "🔖&'", '🏷️&=', '🖌️&h', '📎&k', '📜&z', '❇️&[', '🎚️&{', '📐&}', '🔨&b', '▶️&r', '🐞&d', '🧪&j', '🔬&y', '💻&c', '🔀&g', '🔤&\.', '🔠&-', '🔧&o', '📖&u', '🗃️&a', '🪟&w', '🗂️&t', '📚&s', '🗄️&x', '🎛️&@', '⚙️&\\', '⌨️&\|', '❔&?']
    execute 'menutrans ' .. l:root .. ' [' .. matchstr(l:root, '&.*$') .. ']'
  endfor
  for l:module in ['planet', 'basic', 'edit', 'dev', 'tools', 'nav', 'settings']
    call call('planet#menu#' .. l:module .. '#Update', [])
  endfor
endfunc
