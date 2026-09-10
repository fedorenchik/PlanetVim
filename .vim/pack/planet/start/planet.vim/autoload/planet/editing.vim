vim9script
var script_left_directory = {}

export def FormatSelection(): any
  if mode() =~# '^[sS\x13]'
    execute "normal! \<C-G>"
  endif
  if mode() =~# '^[vV\x16]'
    execute "normal! \<Esc>"
  endif
  if line("'<") == 0 || line("'>") == 0
    echom 'PlanetVim: select text before requesting range formatting.'
    return 0
  endif
  execute ":'<,'>LspDocumentRangeFormat"
  return 1
enddef

export def ExportHTML(selected: any = v:false): any
  var selection: any
  var path: any
  var generated_name: any
  var old_name_buffer: any
  if exists(':TOhtml') != 2
    runtime plugin/tohtml.vim
  endif
  if mode() =~# '^[sS\x13]'
    execute "normal! \<C-G>"
  endif
  if !selected
    execute 'TOhtml'
    setlocal filetype=html
    return bufnr()
  endif
  var source_window: any = win_getid()
  var syntax: any = &syntax
  var directory: any = tempname()
  var scratch: any = 0
  var scratch_window: any = 0
  try
    selection = planet#selection#Current()
    mkdir(directory, 'p', 0o700)
    path = directory .. '/selection'
    planet#selection#Export(path, selection)
    execute 'noautocmd keepalt tabnew ' .. fnameescape(path)
    scratch = bufnr()
    scratch_window = win_getid()
    setlocal noswapfile nobuflisted bufhidden=wipe
    &syntax = syntax
    execute 'TOhtml'
    # The private input disappears below. Leave an unnamed HTML result so Save
    # offers a destination instead of writing into a deleted temporary folder.
    generated_name = bufname()
    noautocmd keepalt :0file
    old_name_buffer = bufnr(generated_name)
    if old_name_buffer > 0 && old_name_buffer != bufnr()
      execute 'noautocmd silent! bwipeout! ' .. old_name_buffer
    endif
    setlocal filetype=html
    return bufnr()
  catch
    echohl ErrorMsg
    echom 'PlanetVim HTML export: ' .. v:exception
    echohl None
    noautocmd win_gotoid(source_window)
    return 0
  finally
    if scratch_window > 0 && win_id2win(scratch_window) > 0
      win_execute(scratch_window, 'noautocmd close!')
    endif
    if scratch > 0 && bufexists(scratch)
      execute 'noautocmd silent! bwipeout! ' .. scratch
    endif
    delete(directory, 'rf')
  endtry
  return 0
enddef

def LocalPathKey(arg_path: any): any
  var path: any = substitute(fnamemodify(resolve(arg_path), ':p'), '\\', '/', 'g')
  path = substitute(path, '/\+$', '', '')
  return has('win32') ? tolower(path) : path
enddef

export def Order(action: any): any
  var first: any = 1
  var last: any = line('$')
  if mode() =~# '^[vV\x16]'
    first = min([line('v'), line('.')])
    last = max([line('v'), line('.')])
  endif
  var lines: any = getline(first, last)
  if action ==# 'sort'
    sort(lines)
  elseif action ==# 'reverse'
    reverse(lines)
  elseif action ==# 'uniq'
    uniq(lines)
  else
    throw 'PlanetVim: unknown line ordering action'
  endif
  setline(first, lines)
  if len(lines) < last - first + 1
    deletebufline(bufnr(), first + len(lines), last)
  endif
  return 0
enddef

export def TrimWhitespace(): any
  var view: any = winsaveview()
  try
    keeppatterns :%s/\s\+$//e
  finally
    winrestview(view)
  endtry
  return 0
enddef

export def Percentage(arg_value: any = v:null): any
  var value: any = arg_value == null ? inputdialog('Percentage (0-100): ', '50') : type(arg_value) == v:t_string ? arg_value : string(arg_value)
  if empty(value)
    return 0
  endif
  if value !~# '^\d\+$' || str2nr(value) > 100
    echomsg 'PlanetVim: percentage must be between 0 and 100.'
    return 0
  endif
  cursor(max([1, float2nr(ceil(line('$') * str2nr(value) / 100.0))]), 1)
  return 1
enddef

export def SubstituteSelection(arg_pattern: any = v:null, arg_replacement: any = v:null): any
  # <Cmd> menus retain Visual/Select mode; publish this selection's marks
  # before reading a range, rather than reusing an older selection.
  if mode() =~# '^[vV\x16sS\x13]'
    execute "normal! \<Esc>"
  endif
  var pattern: any = arg_pattern == null ? inputdialog('Pattern in the last visual selection: ') : arg_pattern
  if empty(pattern)
    return 0
  endif
  var replacement: any = arg_replacement == null ? inputdialog('Replacement: ', '', '\CANCEL') : arg_replacement
  if replacement ==# '\CANCEL'
    return 0
  endif
  if line("'<") == 0 || line("'>") == 0
    echomsg 'PlanetVim: make a visual selection first.'
    return 0
  endif
  # Restrict matches with Vim's exact last-Visual-area atom (including blocks).
  execute "keeppatterns :'<,'>s/\\%V\\%(" .. escape(pattern, '/') .. '\)\%(\%V\_.\)\@<=/' .. escape(replacement, '/') .. '/ge'
  return 1
enddef

export def AutoSave(): any
  if get(g:, 'PV_autosave', 0) && &modified && &modifiable && !&readonly && &buftype ==# '' && !empty(expand('%:p')) && filereadable(expand('%:p'))
    try
      silent update
    catch
      echohl WarningMsg
      echomsg 'PlanetVim autosave: ' .. v:exception
      echohl None
    endtry
  endif
  return 0
enddef

export def AutoSaveToggle(): any
  g:PV_autosave = get(g:, 'PV_autosave', 0) ? 0 : 1
  augroup PlanetVimAutoSave
  autocmd!
  if g:PV_autosave
    autocmd InsertLeave,FocusLost,BufLeave * call planet#editing#AutoSave()
  endif
  augroup END
  echomsg 'PlanetVim autosave ' .. (g:PV_autosave ? 'enabled for existing writable files.' :  'disabled.')
  return g:PV_autosave
enddef

export def RestoreDirectory(winid: any): any
  var saved: any
  if win_id2win(winid) > 0
    saved = getwinvar(winid, 'PV_temporary_directory', {})
    if !empty(saved)
      script_left_directory = saved
      win_execute(winid, 'noautocmd ' .. saved.command .. ' ' .. fnameescape(saved.path))
      setwinvar(winid, 'PV_temporary_directory', {})
    endif
  endif
  return 0
enddef

export def RestoreInheritedDirectory(): any
  if !empty(script_left_directory) && index(script_left_directory.windows, win_getid()) < 0 && LocalPathKey(getcwd()) ==# script_left_directory.temporary
    execute 'noautocmd ' .. script_left_directory.command .. ' ' .. fnameescape(script_left_directory.path)
  endif
  script_left_directory = {}
  return 0
enddef

export def TemporaryDirectory(project: any, arg_directory: any = v:null): any
  var directory: any = arg_directory
  if directory == null
    directory = project ? planet#git#Repository(expand('%:p:h')) : inputdialog('Temporary window directory: ', getcwd())
  endif
  if empty(directory)
    return 0
  endif
  if !isdirectory(directory)
    echomsg 'PlanetVim: directory does not exist: ' .. directory
    return 0
  endif
  planet#editing#RestoreDirectory(win_getid())
  w:PV_temporary_directory = {path:  getcwd(), command:  haslocaldir() == 1 ? 'lcd' :  haslocaldir() == 2 ? 'tcd' :  'cd',
        windows:  map(getwininfo(), (_, lambda_win) => lambda_win.winid), temporary:  LocalPathKey(directory)}
  execute 'lcd ' .. fnameescape(directory)
  augroup PlanetVimTemporaryDirectory
  autocmd!
  autocmd WinLeave * call planet#editing#RestoreDirectory(win_getid())
  # :split copies local options before WinLeave; restore the inherited scope
  # when the new window is entered as well.
  autocmd WinEnter * call planet#editing#RestoreInheritedDirectory()
  augroup END
  return 1
enddef

export def ToggleComment(first: any, last: any): any
  var match: any
  var indent: any
  # Use the filetype's comment format; no external comment plugin is required.
  var format: any = &l:commentstring
  if format !~# '%s' || format ==# '%s'
    echom 'PlanetVim: set commentstring for this filetype before commenting.'
    return 0
  endif
  var parts: any = split(format, '%s', 1)
  var prefix: any = parts[0]
  var suffix: any = parts[1]
  var lines: any = getline(first, last)
  var pattern: any = '^\(\s*\)\V' .. escape(prefix, '\') .. '\m\(.*\)\V' .. escape(suffix, '\') .. '\m$'
  var uncomment: any = !empty(lines) && empty(filter(copy(lines), (_, text) => text !~# pattern))
  var result: any = []
  for line in lines
    if uncomment
      match = matchlist(line, pattern)
      add(result, match[1] .. match[2])
    else
      indent = matchstr(line, '^\s*')
      add(result, indent .. prefix .. strpart(line, strlen(indent)) .. suffix)
    endif
  endfor
  setline(first, result)
  return 1
enddef
