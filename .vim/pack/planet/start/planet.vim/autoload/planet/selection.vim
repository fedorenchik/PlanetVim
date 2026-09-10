vim9script
# Capture the anchor and cursor before a menu or dialog ends Visual mode.
export def Current(): any
  var start: any
  var end: any
  var type: any = mode()
  var select: any = index(['s', 'S', "\<C-s>"], type)
  if select >= 0
    type = ['v', 'V', "\<C-v>"][select]
  endif
  if index(['v', 'V', "\<C-v>"], type) >= 0
    start = getpos('v')
    end = getpos('.')
  else
    type = visualmode()
    start = getpos("'<")
    end = getpos("'>")
  endif
  if start[1] == 0 || end[1] == 0
    throw 'PlanetVim: select text before exporting it'
  endif
  return {'start': start, 'end': end, 'type': type, 'exclusive': &selection ==# 'exclusive', 'buffer': bufnr()}
enddef

def LocalValidate(selection: any): any
  var pos: any
  if get(selection, 'buffer', bufnr()) != bufnr()
    throw 'PlanetVim: the selected buffer is no longer current'
  endif
  if index(['v', 'V', "\<C-v>"], get(selection, 'type', '')) < 0
    throw 'PlanetVim: invalid selection type'
  endif
  for key in ['start', 'end']
    pos = get(selection, key, [])
    if len(pos) != 4 || (pos[0] != 0 && pos[0] != bufnr()) || pos[1] < 1 || pos[1] > line('$') || pos[2] < 1
      throw 'PlanetVim: invalid selection position'
    endif
  endfor
  return 0
enddef

# Let Vim handle tabs, virtual columns, multibyte text and exclusive endpoints.
def LocalSelect(selection: any): any
  execute "normal! \<Esc>"
  setpos('.', selection.start)
  execute 'normal! ' .. selection.type
  setpos('.', selection.end)
  return 0
enddef

# Noninteractive export. Existing destinations require explicit overwrite=true;
# append uses flags='a'. A failed write always leaves the source intact.
export def Export(arg_path: any, arg_selection: any, to_delete: any = v:false, arg_flags: any = '', overwrite: any = v:false): any
  var contents: any
  var flags: any
  if empty(arg_path)
    return 0
  endif
  LocalValidate(arg_selection)
  if arg_flags !=# '' && arg_flags !=# 'a'
    throw 'PlanetVim: unsupported export flags'
  endif
  var path: any = fnamemodify(arg_path, ':p')
  if isdirectory(path)
    throw 'PlanetVim: the export destination is a directory'
  endif
  if arg_flags !=# 'a' && !overwrite && getftype(path) !=# ''
    throw 'PlanetVim: the export destination already exists'
  endif
  if to_delete && !&modifiable
    throw 'PlanetVim: the selected buffer is not modifiable'
  endif

  var view: any = winsaveview()
  var selection: any = &selection
  var virtualedit: any = &virtualedit
  var clipboard: any = &clipboard
  var registers: any = {'z': getreginfo('z'), '0': getreginfo('0'), '"': getreginfo('"')}
  var marks: any = [getpos("'<"), getpos("'>")]
  try
    &selection = get(arg_selection, 'exclusive', v:false) ? 'exclusive' :  'inclusive'
    set virtualedit=all clipboard=
    LocalSelect(arg_selection)
    keepjumps normal! "zy
    contents = getreg('z', 1, 1)
    flags = arg_flags .. (getregtype('z') ==# 'v' ? 'b' : '')
    mkdir(fnamemodify(path, ':h'), 'p')
    if writefile(contents, path, flags) != 0
      throw 'PlanetVim: could not write the selection'
    endif
    if to_delete
      LocalSelect(arg_selection)
      keepjumps normal! "_d
    endif
  finally
    execute "normal! \<Esc>"
    &selection = selection
    &virtualedit = virtualedit
    &clipboard = clipboard
    for reg in ['0', 'z', '"']
      setreg(reg, registers[reg])
    endfor
    setpos("'<", marks[0])
    setpos("'>", marks[1])
    winrestview(view)
  endtry
  return 1
enddef

export def CopySelectionToFile(to_delete: any = v:false, flags: any = ''): any
  var selection: any
  var path: any
  var overwrite: any
  try
    selection = planet#selection#Current()
    if has('browse') && planet#planet#IsGuiDialogs()
      path = browse(v:true, 'Export selection', '', '')
    else
      inputsave()
      try
        path = input('Export selection to: ', '', 'file')
      finally
        inputrestore()
      endtry
    endif
    if empty(path)
      return 0
    endif
    overwrite = v:false
    if flags !=# 'a' && getftype(path) !=# ''
      if confirm('Overwrite ' .. path .. '?', "&Overwrite\n&Cancel", 2) != 1
        return 0
      endif
      overwrite = v:true
    endif
    planet#selection#Export(path, selection, to_delete, flags, overwrite)
    echom 'Saved selection to ' .. fnamemodify(path, ':p')
    return 1
  catch
    echohl ErrorMsg
    echom v:exception
    echohl None
    return 0
  endtry
enddef

export def Restore(selection: any): any
  LocalValidate(selection)
  LocalSelect(selection)
  return 0
enddef

export def Text(selection: any): any
  LocalValidate(selection)
  var registers: any = {'z': getreginfo('z'), '0': getreginfo('0'), '"': getreginfo('"')}
  var clipboard: any = &clipboard
  var view: any = winsaveview()
  try
    set clipboard=
    LocalSelect(selection)
    normal! "zy
    return getreg('z')
  finally
    for [name, contents] in items(registers)
      setreg(name, contents)
    endfor
    &clipboard = clipboard
    winrestview(view)
  endtry
  return 0
enddef
