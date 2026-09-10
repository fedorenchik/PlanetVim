vim9script
export def OldFilesQF(): any
  setqflist([], ' ', {'lines': v:oldfiles, 'efm': '%f', 'quickfixtextfunc': 'QfOldFiles'})
  return 0
enddef

def g:QfOldFiles(info: any): any
  var items: any = getqflist({'id': info.id, 'items': 1}).items
  var l: any = []
  for idx in range(info.start_idx - 1, info.end_idx - 1)
    add(l, fnamemodify(bufname(items[idx - 1].bufnr), ':p:.'))
  endfor
  return l
enddef

export def NewProject(project_type: any): any
  return planet#generate#Template(project_type, v:null, {open: v:true})
enddef

export def NewProjectFromScript(project_type: any): any
  return planet#generate#Framework(project_type, v:null, {open: v:true})
enddef

# mod can be: '', 'windo', 'tabdo windo'
export def ClearLocalCwd(mod: any): any
  var win_id: any = win_getid()
  var global_cwd: any = getcwd(-1)
  exe "noautocmd " .. mod .. " cd " .. fnameescape(global_cwd)
  win_gotoid(win_id)
  return 0
enddef

# Makes global cd from tcd & clears tcd
export def TcdToCd(): any
  var win_id: any
  var tab_cwd: any
  if haslocaldir() == 2
    win_id = win_getid()
    tab_cwd = getcwd(-1, 0)
    exe "noautocmd windo cd " .. fnameescape(tab_cwd)
    win_gotoid(win_id)
  endif
  return 0
enddef

# Makes global cd from lcd & clears lcd
export def LcdToCd(): any
  if haslocaldir() == 1
    exe "noautocmd cd " .. fnameescape(getcwd())
  endif
  return 0
enddef
