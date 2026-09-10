vim9script
export def SetPath(): any
  if !exists("g:menutrans_path_dialog")
    g:menutrans_path_dialog = "Enter search path for files.\nSeparate directory names with a comma."
  endif
  var n: any = inputdialog(g:menutrans_path_dialog, substitute(&path, '\\ ', ' ', 'g'))
  if n != ""
    &path = substitute(n, ' ', '\\ ', 'g')
  endif
  return 0
enddef

export def SetTags(): any
  if !exists("g:menutrans_tags_dialog")
    g:menutrans_tags_dialog = "Enter names of tag files.\nSeparate the names with a comma."
  endif
  var n: any = inputdialog(g:menutrans_tags_dialog, substitute(&tags, '\\ ', ' ', 'g'))
  if n != ""
    &tags = substitute(n, ' ', '\\ ', 'g')
  endif
  return 0
enddef

export def SetTextWidth(...args: list<any>): any
  if !exists("g:menutrans_textwidth_dialog")
    g:menutrans_textwidth_dialog = "Enter new text width (0 to disable formatting): "
  endif
  var n: any = !empty(args) ? args[0] : inputdialog(g:menutrans_textwidth_dialog, string(&tw))
  if n != ""
    if n !~# '^\d\+$'
      throw 'PlanetVim: text width must be a non-negative integer'
    endif
    &l:textwidth = str2nr(n, 10)
  endif
  return 0
enddef

export def EditOption(option: any, ...args: list<any>): any
  var allowed: any = ['makeprg', 'grepprg', 'formatprg', 'equalprg', 'keywordprg', 'path', 'tags', 'dictionary',
       'thesaurus', 'include', 'define', 'suffixesadd']
  if index(allowed, option) < 0
    throw 'PlanetVim: unsupported option editor'
  endif
  var value: any = !empty(args) ? args[0] : inputdialog('Set buffer option ' .. option .. ':', eval('&l:' .. option), "\n")
  if value ==# "\n"
    return 0
  endif
  execute '&l:' .. option .. ' = ' .. string(value)
  return 1
enddef

export def SetLineEndings(): any
  var def: any
  var n: any
  if !exists("g:menutrans_fileformat_dialog")
    g:menutrans_fileformat_dialog = "Select line endings for file"
  endif
  if !exists("g:menutrans_fileformat_choices")
    g:menutrans_fileformat_choices = "&Unix (LF)\n&Windows (CRLF)\nLegacy &Mac (CR)\n&Cancel"
  endif
  if &ff == "dos"
def = 2
  elseif &ff == "mac"
def = 3
  else
def = 1
  endif
  n = confirm(g:menutrans_fileformat_dialog, g:menutrans_fileformat_choices, def, "Question")
  if n == 1
  set ff=unix
  elseif n == 2
  set ff=dos
  elseif n == 3
  set ff=mac
  endif
  return 0
enddef

# func! planet#settings#ToggleGuiOption(option) abort
#   " If a:option is already set in guioptions, then we want to remove it
#   if match(&guioptions, "\\C" . a:option) > -1
#     exec "set go-=" . a:option
#   else
#     exec "set go+=" . a:option
#   endif
# endfunc
