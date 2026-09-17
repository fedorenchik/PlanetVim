vim9script

# Native popup_setpos has already selected the clicked window and position.
# Build only on MenuPopup: never start tools, search projects, or change mode here.
var popup_mode = 'n'
var spelling: dict<any> = {}
var link = ''

def Add(priority: number, label: string, rhs: string, remap: bool = false, hint: string = '')
  var path = 'PopUp.' .. join(map(split(label, '/'), (_, part) =>
    substitute(planet#menu#MenuifyName(part), '<', '<lt>', 'g')), '.')
  var shortcut = hint
  if remap && empty(shortcut) && popup_mode ==# 'n'
    var keys = map(filter(maplist(), (_, m) => m.mode =~# '[n ]' && !m.expr
      && m.lhs !~? '<Plug>\|<SNR>' && m.rhs ==# rhs && maparg(m.lhs, 'n') ==# m.rhs), (_, m) => m.lhs)
    sort(keys, (a, b) => strlen(a) - strlen(b))
    shortcut = empty(keys) ? '' : keys[0]
  endif
  if !empty(shortcut)
    path ..= '<Tab>' .. escape(shortcut, ' |')
  endif
  var action = rhs
  # Select-mode keys otherwise replace the selection with their literal text.
  if popup_mode ==# 's' && rhs !~# '^<Cmd>' && rhs !=# '<Nop>'
    action = '<C-G>' .. action
  endif
  execute planet#menu_help#Entry(popup_mode .. (remap ? 'menu' : 'noremenu')
    .. ' <silent> 1.' .. priority .. ' ', path, action)
enddef

def Separator(priority: number)
  Add(priority, '-section' .. priority .. '-', '<Nop>')
enddef

def WindowMenu()
  Add(90, 'Window/Split Right', '<Cmd>rightbelow vsplit<CR>')
  Add(90, 'Window/Split Below', '<Cmd>rightbelow split<CR>')
  Add(90, 'Window/Open in New Tab', '<Cmd>tab split<CR>')
  Add(95, 'Close', '<Cmd>confirm close<CR>')
enddef

def Capabilities(): dict<bool>
  var result: dict<bool> = {}
  if &buftype != '' || !exists('*lsp#get_allowed_servers')
    return result
  endif
  for server in lsp#get_allowed_servers()
    if lsp#get_server_status(server) !=# 'running'
      continue
    endif
    for [key, value] in items(lsp#get_server_capabilities(server))
      if key ==# 'codeActionProvider' && type(value) == v:t_dict
          && has_key(value, 'codeActionKinds') && empty(value.codeActionKinds)
        continue
      endif
      if (type(value) == v:t_bool && value) || type(value) == v:t_dict
        result[key] = true
      endif
    endfor
  endfor
  return result
enddef

def LanguageActions(selected: bool, editable: bool)
  var caps = Capabilities()
  var entries = selected ? [] : [
    ['Go to Definition', 'LspDefinition', 'definitionProvider'],
    ['Peek Definition', 'LspPeekDefinition', 'definitionProvider'],
    ['Find References', 'LspReferences', 'referencesProvider'],
    ['Go to Type Definition', 'LspTypeDefinition', 'typeDefinitionProvider'],
    ['Go to Implementation', 'LspImplementation', 'implementationProvider'],
    ['Show Hover', 'LspHover', 'hoverProvider']]
  if editable
    entries += [
      ['Code Actions', 'LspCodeAction', 'codeActionProvider'],
      [selected ? 'Format Selection' : 'Format Document',
       selected ? 'LspDocumentRangeFormat' : 'LspDocumentFormat',
       selected ? 'documentRangeFormattingProvider' : 'documentFormattingProvider']]
    if !selected
      add(entries, ['Rename Symbol', 'LspRename', 'renameProvider'])
    endif
  endif
  var added = false
  for [label, command, capability] in entries
    if !get(caps, capability, false) || exists(':' .. command) != 2
      continue
    endif
    # Include actual buffer-local language mappings, which the root-menu cache
    # deliberately excludes. A user's replacement mapping must not be advertised.
    var keys = popup_mode ==# 'n' ? map(filter(maplist(), (_, m) =>
      m.mode =~# '[n ]' && !m.expr && m.lhs !~? '<Plug>\|<SNR>'
      && m.rhs =~# '\<' .. command .. '\>' && maparg(m.lhs, 'n') ==# m.rhs), (_, m) => m.lhs) : []
    sort(keys, (a, b) => strlen(a) - strlen(b))
    var rhs = selected ? '<Esc>:' .. "'<,'>" .. command .. '<CR>' : '<Cmd>' .. command .. '<CR>'
    Add(20, label, rhs, false, empty(keys) ? '' : keys[0])
    added = true
  endfor
  if added | Separator(25) | endif
enddef

def SelectionMenu(editable: bool)
  Add(30, 'Copy', '"+y')
  Add(30, 'Yank', 'y')
  if editable
    Add(30, 'Cut', '"+x')
    Add(30, 'Paste', '"_x"+gP')
    Add(30, 'Delete', '"_x')
  endif
  Separator(35)
  Add(40, 'Search for Selection', '<Cmd>call planet#popup#SearchSelection()<CR>')
  Add(40, 'Save Selection As', '<Cmd>call planet#selection#CopySelectionToFile()<CR>')
  if editable
    if &commentstring =~# '%s' && &commentstring !=# '%s'
      Add(50, 'Toggle Line Comment', '<Esc>:''<,''>PlanetToggleComment<CR>')
    endif
    Add(50, 'Indent', '>gv')
    Add(50, 'Unindent', '<lt>gv')
    Add(50, 'Reindent', '=gv')
    Add(60, 'Transform/Uppercase', 'U')
    Add(60, 'Transform/Lowercase', 'u')
    Add(60, 'Transform/Toggle Case', '~')
    Add(60, 'Transform/Sort Lines', '<Esc>:''<,''>sort<CR>')
    Add(60, 'Transform/Format Text', 'gq')
  endif
enddef

def FileMenu(editable: bool)
  if &buftype != '' | return | endif
  if editable
    Add(80, 'File/Save', empty(expand('%')) ? '<Cmd>browse confirm saveas<CR>' : '<Cmd>confirm write<CR>')
    Add(80, 'File/Save As', '<Cmd>browse confirm saveas<CR>')
  endif
  if !empty(expand('%'))
    Add(80, 'File/Copy Path', '<Cmd>call setreg("+", expand("%:p"))<CR>')
    Add(80, 'File/Copy Relative Path', '<Cmd>call setreg("+", expand("%:."))<CR>')
    Add(80, 'File/Reveal in File Tree', '<Cmd>Fern %:p:h -reveal=%:p<CR>')
    Add(80, 'File/Open Terminal Here', '<Cmd>call planet#term#RunCmd([&shell], false, false, false, expand("%:p:h"))<CR>')
  endif
enddef

def Spelling()
  spelling = {}
  if !&spell || empty(&spelllang) | return | endif
  var view = winsaveview()
  try
    var [word, kind] = spellbadword()
    if empty(word) || line('.') != view.lnum || col('.') > view.col + 1
      return
    endif
    spelling = {word: word, line: line('.'), column: col('.'), buffer: bufnr(),
      suggestions: kind ==# 'caps' ? [substitute(word, '^.', '\u&', '')] : spellsuggest(word, 8)}
    var i = 0
    for suggestion in spelling.suggestions
      Add(10, 'Change "' .. word .. '" to/' .. suggestion,
        '<Cmd>call planet#popup#SpellReplace(' .. i .. ')<CR>')
      i += 1
    endfor
    Add(11, 'Add Word to Dictionary', '<Cmd>call planet#popup#SpellAccept(false)<CR>', false,
      popup_mode ==# 'i' ? '<C-O>zg' : 'zg')
    Add(11, 'Ignore Word for This Session', '<Cmd>call planet#popup#SpellAccept(true)<CR>', false,
      popup_mode ==# 'i' ? '<C-O>zG' : 'zG')
    Separator(15)
  finally
    winrestview(view)
  endtry
enddef

def QuickfixMenu()
  var local = get(getwininfo(win_getid()), 0, {}).loclist
  var prefix = local ? 'l' : 'c'
  Add(20, 'Open Entry', '<CR>', true, '<CR>')
  Add(20, 'Open Entry in Split', '<C-W><CR>', true, '<C-W><CR>')
  Separator(25)
  Add(30, 'Older List', '<Cmd>' .. prefix .. 'older<CR>')
  Add(30, 'Newer List', '<Cmd>' .. prefix .. 'newer<CR>')
  Add(30, 'List History', '<Cmd>' .. prefix .. 'history<CR>')
  Add(40, 'Filter List', '<Cmd>call planet#winbar#Filter(false)<CR>')
  Add(40, 'Exclude from List', '<Cmd>call planet#winbar#Filter(true)<CR>')
  Add(50, 'Copy Message', '"+yy')
enddef

def FernMenu()
  for [label, action] in [
    ['Open', 'open-or-enter'], ['Open in Split', 'open:split'],
    ['Open in Vertical Split', 'open:vsplit'], ['Open in New Tab', 'open:tabedit'],
    ['Preview', 'preview'], ['Expand Tree', 'expand-tree:stay'],
    ['Collapse', 'collapse'], ['Refresh', 'reload'],
    ['Files/New File', 'new-file'], ['Files/New Directory', 'new-dir'],
    ['Files/Move or Rename', 'move'], ['Files/Copy Files', 'clipboard-copy'],
    ['Files/Cut Files', 'clipboard-move'], ['Files/Paste Files', 'clipboard-paste-confirm'],
    ['Files/Delete', 'remove']]
    var plug = '<Plug>(fern-action-' .. action .. ')'
    if !empty(maparg(plug, 'n'))
      Add(20, label, plug, true)
    endif
  endfor
  Add(30, 'Copy Path', '"+<Plug>(fern-action-yank:bufname)', true)
enddef

export def Build(requested: string = 'n')
  popup_mode = index(['n', 'i', 'c', 'o', 'tl', 'v', 's'], requested) >= 0 ? requested : 'n'
  if popup_mode ==# 'v' | popup_mode = 'x' | endif
  var previous_error = v:errmsg
  silent! aunmenu PopUp
  silent! tlunmenu PopUp
  v:errmsg = previous_error
  planet#menu_help#ForgetPopup()
  if popup_mode ==# 'c'
    Add(30, 'Copy', '<Cmd>call setreg("+", getcmdline())<CR>')
    Add(30, 'Paste', '<C-R>+')
    Add(40, 'Clear to Start', '<C-U>')
    return
  elseif popup_mode ==# 'o'
    Add(30, 'Word', 'iw')
    Add(30, 'To Next Word', 'w')
    Add(30, 'Paragraph', 'ip')
    Add(30, 'Quoted Text', 'i"')
    Add(30, 'Parenthesized Text', 'i)')
    Add(40, 'Cancel Operator', '<Esc>')
    return
  endif
  var selected = index(['x', 's'], popup_mode) >= 0
  var editable = &modifiable && !&readonly && &buftype == ''
  if selected
    LanguageActions(true, editable)
    SelectionMenu(editable)
    return
  endif
  if &buftype ==# 'terminal'
    if popup_mode ==# 'tl'
      Add(30, 'Paste', '<C-W>"+')
      Add(30, 'Terminal Normal Mode', '<C-W>N')
    else
      if term_getstatus(bufnr()) =~# 'running' | Add(30, 'Resume Terminal Input', 'i') | endif
      Add(30, 'Copy Line', '"+yy')
      Add(30, 'Select All Output', 'ggVG')
    endif
    Add(40, 'Hide Terminal', '<Cmd>call planet#popup#HideTerminal()<CR>')
    if term_getstatus(bufnr()) =~# 'running'
      Add(50, 'Stop Job', '<Cmd>confirm bdelete<CR>')
    else
      Add(50, 'Close Finished Terminal', '<Cmd>bdelete<CR>')
    endif
    return
  elseif &buftype ==# 'quickfix'
    QuickfixMenu()
  elseif &filetype ==# 'fern'
    FernMenu()
  elseif &filetype ==# 'startify'
    Add(20, 'Open Entry', '<CR>', true, '<CR>')
    Add(30, 'New File', '<Cmd>enew<CR>')
    Add(30, 'Open File', '<Cmd>browse confirm edit<CR>')
    Add(30, 'Open Session', '<Cmd>call planet#session#Load()<CR>')
  elseif &buftype ==# 'help'
    Add(20, 'Follow Help Tag', '<C-]>')
    Add(20, 'Back', '<C-T>')
    Add(30, 'Copy Line', '"+yy')
    Add(30, 'Search Word', '*')
  else
    if editable
      Spelling()
      Add(30, 'Undo', popup_mode ==# 'i' ? '<C-O>u' : 'u')
      Add(30, 'Redo', popup_mode ==# 'i' ? '<C-O><C-R>' : '<C-R>')
      Add(30, 'Paste', popup_mode ==# 'i' ? '<C-R><C-P>+' : '"+gP')
    endif
    LanguageActions(false, editable)
    if popup_mode ==# 'n'
      Add(30, 'Copy Line', '"+yy')
      if editable | Add(30, 'Cut Line', '"+dd') | endif
      Separator(35)
      Add(40, 'Select Word', 'viw')
      Add(40, 'Select All', 'ggVG')
      if !empty(expand('<cword>')) | Add(40, 'Search Word', '*') | endif
      link = expand('<cfile>')
      if link =~# '^https\?://'
        Add(40, 'Open Link', '<Cmd>call planet#popup#OpenLink()<CR>')
      elseif link =~# '[/\.]'
        Add(40, 'Open File Under Cursor', 'gF')
        Add(40, 'Open File in Split', '<C-W>F')
      endif
    endif
    if editable && &commentstring =~# '%s' && &commentstring !=# '%s'
      Add(50, 'Toggle Line Comment', '<Cmd>PlanetToggleComment<CR>')
    endif
    if &diff
      if editable | Add(60, 'Diff/Get Change', '<Cmd>diffget<CR>') | endif
      Add(60, 'Diff/Put Change', '<Cmd>diffput<CR>')
      Add(60, 'Diff/Update', '<Cmd>diffupdate<CR>')
    endif
    FileMenu(editable)
  endif
  Separator(85)
  WindowMenu()
enddef

export def TerminalMouse()
  var mouse = getmousepos()
  if mouse.winid == 0 | return | endif
  if getbufvar(winbufnr(mouse.winid), '&buftype') !=# 'terminal'
    # Return to Vim's mouse handling when clicking an ordinary editor window.
    feedkeys("\<C-\>\<C-N>\<RightMouse>", 'n')
    return
  endif
  if !win_gotoid(mouse.winid) | return | endif
  doautocmd <nomodeline> MenuPopup tl
  popup! PopUptl
enddef

export def HideTerminal()
  if &buftype !=# 'terminal' | return | endif
  if winnr('$') == 1
    hide enew
  else
    hide
  endif
enddef

export def SearchSelection()
  var text = planet#selection#Text(planet#selection#Current())
  if empty(text) | return | endif
  @/ = '\V' .. substitute(escape(text, '\'), "\n", '\\n', 'g')
  set hlsearch
  search(@/, 'w')
enddef

export def OpenLink()
  if link =~# '^https\?://' | planet#gui#OpenUrl(link) | endif
enddef

def ValidSpelling(): bool
  return !empty(spelling) && bufnr() == spelling.buffer && &modifiable && !&readonly
    && strpart(getline(spelling.line), spelling.column - 1, strlen(spelling.word)) ==# spelling.word
enddef

export def SpellReplace(index: number)
  if !ValidSpelling() | return | endif
  var text = getline(spelling.line)
  setline(spelling.line, strpart(text, 0, spelling.column - 1) .. spelling.suggestions[index]
    .. strpart(text, spelling.column - 1 + strlen(spelling.word)))
enddef

export def SpellAccept(temporary: bool)
  if !ValidSpelling() | return | endif
  execute 'spellgood' .. (temporary ? '! ' : ' ') .. escape(spelling.word, '|')
enddef
