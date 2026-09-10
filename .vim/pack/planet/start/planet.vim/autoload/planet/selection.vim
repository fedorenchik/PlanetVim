scriptversion 4

" Capture the anchor and cursor before a menu or dialog ends Visual mode.
func! planet#selection#Current() abort
  let l:type = mode()
  let l:select = index(['s', 'S', "\<C-s>"], l:type)
  if l:select >= 0 | let l:type = ['v', 'V', "\<C-v>"][l:select] | endif
  if index(['v', 'V', "\<C-v>"], l:type) >= 0
    let l:start = getpos('v')
    let l:end = getpos('.')
  else
    let l:type = visualmode()
    let l:start = getpos("'<")
    let l:end = getpos("'>")
  endif
  if l:start[1] == 0 || l:end[1] == 0
    throw 'PlanetVim: select text before exporting it'
  endif
  return {'start': l:start, 'end': l:end, 'type': l:type,
        \ 'exclusive': &selection ==# 'exclusive', 'buffer': bufnr()}
endfunc

func! s:Validate(selection) abort
  if get(a:selection, 'buffer', bufnr()) != bufnr()
    throw 'PlanetVim: the selected buffer is no longer current'
  endif
  if index(['v', 'V', "\<C-v>"], get(a:selection, 'type', '')) < 0
    throw 'PlanetVim: invalid selection type'
  endif
  for l:key in ['start', 'end']
    let l:pos = get(a:selection, l:key, [])
    if len(l:pos) != 4 || (l:pos[0] != 0 && l:pos[0] != bufnr())
          \ || l:pos[1] < 1 || l:pos[1] > line('$') || l:pos[2] < 1
      throw 'PlanetVim: invalid selection position'
    endif
  endfor
endfunc

" Let Vim handle tabs, virtual columns, multibyte text and exclusive endpoints.
func! s:Select(selection) abort
  execute "normal! \<Esc>"
  call setpos('.', a:selection.start)
  execute 'normal! ' .. a:selection.type
  call setpos('.', a:selection.end)
endfunc

" Noninteractive export. Existing destinations require explicit overwrite=true;
" append uses flags='a'. A failed write always leaves the source intact.
func! planet#selection#Export(path, selection, to_delete = v:false, flags = '', overwrite = v:false) abort
  if empty(a:path)
    return 0
  endif
  call s:Validate(a:selection)
  if a:flags !=# '' && a:flags !=# 'a'
    throw 'PlanetVim: unsupported export flags'
  endif
  let l:path = fnamemodify(a:path, ':p')
  if isdirectory(l:path)
    throw 'PlanetVim: the export destination is a directory'
  endif
  if a:flags !=# 'a' && !a:overwrite && getftype(l:path) !=# ''
    throw 'PlanetVim: the export destination already exists'
  endif
  if a:to_delete && !&modifiable
    throw 'PlanetVim: the selected buffer is not modifiable'
  endif

  let l:view = winsaveview()
  let l:selection = &selection
  let l:virtualedit = &virtualedit
  let l:clipboard = &clipboard
  let l:registers = {'z': getreginfo('z'), '0': getreginfo('0'), '"': getreginfo('"')}
  let l:marks = [getpos("'<"), getpos("'>")]
  try
    let &selection = get(a:selection, 'exclusive', v:false) ? 'exclusive' : 'inclusive'
    set virtualedit=all clipboard=
    call s:Select(a:selection)
    keepjumps normal! "zy
    let l:contents = getreg('z', 1, 1)
    let l:flags = a:flags .. (getregtype('z') ==# 'v' ? 'b' : '')
    call mkdir(fnamemodify(l:path, ':h'), 'p')
    if writefile(l:contents, l:path, l:flags) != 0
      throw 'PlanetVim: could not write the selection'
    endif
    if a:to_delete
      call s:Select(a:selection)
      keepjumps normal! "_d
    endif
  finally
    execute "normal! \<Esc>"
    let &selection = l:selection
    let &virtualedit = l:virtualedit
    let &clipboard = l:clipboard
    for l:reg in ['0', 'z', '"']
      call setreg(l:reg, l:registers[l:reg])
    endfor
    call setpos("'<", l:marks[0])
    call setpos("'>", l:marks[1])
    call winrestview(l:view)
  endtry
  return 1
endfunc

func! planet#selection#CopySelectionToFile(to_delete = v:false, flags = '') abort
  try
    let l:selection = planet#selection#Current()
    if has('browse') && planet#planet#IsGuiDialogs()
      let l:path = browse(v:true, 'Export selection', '', '')
    else
      call inputsave()
      try
        let l:path = input('Export selection to: ', '', 'file')
      finally
        call inputrestore()
      endtry
    endif
    if empty(l:path)
      return 0
    endif
    let l:overwrite = v:false
    if a:flags !=# 'a' && getftype(l:path) !=# ''
      if confirm('Overwrite ' .. l:path .. '?', "&Overwrite\n&Cancel", 2) != 1
        return 0
      endif
      let l:overwrite = v:true
    endif
    call planet#selection#Export(l:path, l:selection, a:to_delete, a:flags, l:overwrite)
    echom 'Saved selection to ' .. fnamemodify(l:path, ':p')
    return 1
  catch
    echohl ErrorMsg
    echom v:exception
    echohl None
    return 0
  endtry
endfunc

func! planet#selection#Restore(selection) abort
  call s:Validate(a:selection)
  call s:Select(a:selection)
endfunc

func! planet#selection#Text(selection) abort
  call s:Validate(a:selection)
  let l:registers = {'z': getreginfo('z'), '0': getreginfo('0'), '"': getreginfo('"')}
  let l:clipboard = &clipboard
  let l:view = winsaveview()
  try
    set clipboard=
    call s:Select(a:selection)
    normal! "zy
    return getreg('z')
  finally
    for [l:name, l:contents] in items(l:registers) | call setreg(l:name, l:contents) | endfor
    let &clipboard = l:clipboard
    call winrestview(l:view)
  endtry
endfunc
