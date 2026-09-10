scriptversion 4
let s:left_directory = {}

func! planet#editing#FormatSelection() abort
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
  execute "'<,'>LspDocumentRangeFormat"
  return 1
endfunc

func! planet#editing#ExportHTML(selected = v:false) abort
  if exists(':TOhtml') != 2 | runtime plugin/tohtml.vim | endif
  if mode() =~# '^[sS\x13]'
    execute "normal! \<C-G>"
  endif
  if !a:selected
    TOhtml
    setlocal filetype=html
    return bufnr()
  endif
  let l:source_window = win_getid()
  let l:syntax = &syntax
  let l:directory = tempname()
  let l:scratch = 0
  let l:scratch_window = 0
  try
    let l:selection = planet#selection#Current()
    call mkdir(l:directory, 'p', 0o700)
    let l:path = l:directory .. '/selection'
    call planet#selection#Export(l:path, l:selection)
    execute 'noautocmd keepalt tabnew ' .. fnameescape(l:path)
    let l:scratch = bufnr()
    let l:scratch_window = win_getid()
    setlocal noswapfile nobuflisted bufhidden=wipe
    let &syntax = l:syntax
    TOhtml
    " The private input disappears below. Leave an unnamed HTML result so Save
    " offers a destination instead of writing into a deleted temporary folder.
    let l:generated_name = bufname()
    noautocmd keepalt 0file
    let l:old_name_buffer = bufnr(l:generated_name)
    if l:old_name_buffer > 0 && l:old_name_buffer != bufnr()
      execute 'noautocmd silent! bwipeout! ' .. l:old_name_buffer
    endif
    setlocal filetype=html
    return bufnr()
  catch
    echohl ErrorMsg | echom 'PlanetVim HTML export: ' .. v:exception | echohl None
    noautocmd call win_gotoid(l:source_window)
    return 0
  finally
    if l:scratch_window > 0 && win_id2win(l:scratch_window) > 0
      call win_execute(l:scratch_window, 'noautocmd close!')
    endif
    if l:scratch > 0 && bufexists(l:scratch)
      execute 'noautocmd silent! bwipeout! ' .. l:scratch
    endif
    call delete(l:directory, 'rf')
  endtry
endfunc

func! s:PathKey(path) abort
  let l:path = substitute(fnamemodify(resolve(a:path), ':p'), '\\', '/', 'g')
  let l:path = substitute(l:path, '/\+$', '', '')
  return has('win32') ? tolower(l:path) : l:path
endfunc

func! planet#editing#Order(action) abort
  let l:first = 1
  let l:last = line('$')
  if mode() =~# '^[vV\x16]'
    let l:first = min([line('v'), line('.')])
    let l:last = max([line('v'), line('.')])
  endif
  let l:lines = getline(l:first, l:last)
  if a:action ==# 'sort'
    call sort(l:lines)
  elseif a:action ==# 'reverse'
    call reverse(l:lines)
  elseif a:action ==# 'uniq'
    call uniq(l:lines)
  else
    throw 'PlanetVim: unknown line ordering action'
  endif
  call setline(l:first, l:lines)
  if len(l:lines) < l:last - l:first + 1
    call deletebufline(bufnr(), l:first + len(l:lines), l:last)
  endif
endfunc

func! planet#editing#TrimWhitespace() abort
  let l:view = winsaveview()
  try
    keeppatterns %s/\s\+$//e
  finally
    call winrestview(l:view)
  endtry
endfunc

func! planet#editing#Percentage(value = v:null) abort
  let l:value = a:value is v:null ? inputdialog('Percentage (0-100): ', '50')
        \ : type(a:value) == v:t_string ? a:value : string(a:value)
  if empty(l:value)
    return 0
  endif
  if l:value !~# '^\d\+$' || str2nr(l:value) > 100
    echomsg 'PlanetVim: percentage must be between 0 and 100.'
    return 0
  endif
  call cursor(max([1, float2nr(ceil(line('$') * str2nr(l:value) / 100.0))]), 1)
  return 1
endfunc

func! planet#editing#SubstituteSelection(pattern = v:null, replacement = v:null) abort
  " <Cmd> menus retain Visual/Select mode; publish this selection's marks
  " before reading a range, rather than reusing an older selection.
  if mode() =~# '^[vV\x16sS\x13]'
    execute "normal! \<Esc>"
  endif
  let l:pattern = a:pattern is v:null ? inputdialog('Pattern in the last visual selection: ') : a:pattern
  if empty(l:pattern)
    return 0
  endif
  let l:replacement = a:replacement is v:null ? inputdialog('Replacement: ', '', '\CANCEL') : a:replacement
  if l:replacement ==# '\CANCEL'
    return 0
  endif
  if line("'<") == 0 || line("'>") == 0
    echomsg 'PlanetVim: make a visual selection first.'
    return 0
  endif
  " Restrict matches with Vim's exact last-Visual-area atom (including blocks).
  execute "keeppatterns '<,'>s/\\%V\\%(" .. escape(l:pattern, '/') .. '\)\%(\%V\_.\)\@<=/' .. escape(l:replacement, '/') .. '/ge'
  return 1
endfunc

func! planet#editing#AutoSave() abort
  if get(g:, 'PV_autosave', 0) && &modified && &modifiable && !&readonly
        \ && &buftype ==# '' && !empty(expand('%:p')) && filereadable(expand('%:p'))
    try
      silent update
    catch
      echohl WarningMsg | echomsg 'PlanetVim autosave: ' .. v:exception | echohl None
    endtry
  endif
endfunc

func! planet#editing#AutoSaveToggle() abort
  let g:PV_autosave = !get(g:, 'PV_autosave', 0)
  augroup PlanetVimAutoSave
    autocmd!
    if g:PV_autosave
      autocmd InsertLeave,FocusLost,BufLeave * call planet#editing#AutoSave()
    endif
  augroup END
  echomsg 'PlanetVim autosave ' .. (g:PV_autosave ? 'enabled for existing writable files.' : 'disabled.')
  return g:PV_autosave
endfunc

func! planet#editing#RestoreDirectory(winid) abort
  if win_id2win(a:winid) > 0
    let l:saved = getwinvar(a:winid, 'PV_temporary_directory', {})
    if !empty(l:saved)
      let s:left_directory = l:saved
      call win_execute(a:winid, 'noautocmd ' .. l:saved.command .. ' ' .. fnameescape(l:saved.path))
      call setwinvar(a:winid, 'PV_temporary_directory', {})
    endif
  endif
endfunc

func! planet#editing#RestoreInheritedDirectory() abort
  if !empty(s:left_directory) && index(s:left_directory.windows, win_getid()) < 0
        \ && s:PathKey(getcwd()) ==# s:left_directory.temporary
    execute 'noautocmd ' .. s:left_directory.command .. ' ' .. fnameescape(s:left_directory.path)
  endif
  let s:left_directory = {}
endfunc

func! planet#editing#TemporaryDirectory(project, directory = v:null) abort
  let l:directory = a:directory
  if l:directory is v:null
    let l:directory = a:project ? planet#git#Repository(expand('%:p:h')) : inputdialog('Temporary window directory: ', getcwd())
  endif
  if empty(l:directory)
    return 0
  endif
  if !isdirectory(l:directory)
    echomsg 'PlanetVim: directory does not exist: ' .. l:directory
    return 0
  endif
  call planet#editing#RestoreDirectory(win_getid())
  let w:PV_temporary_directory = #{path: getcwd(), command: haslocaldir() == 1 ? 'lcd' : haslocaldir() == 2 ? 'tcd' : 'cd',
        \ windows: map(getwininfo(), {_, win -> win.winid}), temporary: s:PathKey(l:directory)}
  execute 'lcd ' .. fnameescape(l:directory)
  augroup PlanetVimTemporaryDirectory
    autocmd!
    autocmd WinLeave * call planet#editing#RestoreDirectory(win_getid())
    " :split copies local options before WinLeave; restore the inherited scope
    " when the new window is entered as well.
    autocmd WinEnter * call planet#editing#RestoreInheritedDirectory()
  augroup END
  return 1
endfunc

func! planet#editing#ToggleComment(first, last) abort
  " Use the filetype's comment format; no external comment plugin is required.
  let l:format = &l:commentstring
  if l:format !~# '%s' || l:format ==# '%s'
    echom 'PlanetVim: set commentstring for this filetype before commenting.'
    return 0
  endif
  let l:parts = split(l:format, '%s', 1)
  let l:prefix = l:parts[0]
  let l:suffix = l:parts[1]
  let l:lines = getline(a:first, a:last)
  let l:pattern = '^\(\s*\)\V' .. escape(l:prefix, '\') .. '\m\(.*\)\V' .. escape(l:suffix, '\') .. '\m$'
  let l:uncomment = !empty(l:lines) && empty(filter(copy(l:lines), 'v:val !~# l:pattern'))
  let l:result = []
  for l:line in l:lines
    if l:uncomment
      let l:match = matchlist(l:line, l:pattern)
      call add(l:result, l:match[1] .. l:match[2])
    else
      let l:indent = matchstr(l:line, '^\s*')
      call add(l:result, l:indent .. l:prefix .. strpart(l:line, strlen(l:indent)) .. l:suffix)
    endif
  endfor
  call setline(a:first, l:result)
  return 1
endfunc
