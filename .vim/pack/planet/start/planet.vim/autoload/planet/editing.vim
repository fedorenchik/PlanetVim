scriptversion 4
let s:left_directory = {}

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
        \ && getcwd() ==# s:left_directory.temporary
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
        \ windows: map(getwininfo(), {_, win -> win.winid}), temporary: substitute(fnamemodify(l:directory, ':p'), '[/\\]\+$', '', '')}
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
