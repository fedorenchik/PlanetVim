scriptversion 4

fun! planet#settings#SetPath()
  if !exists("g:menutrans_path_dialog")
    let g:menutrans_path_dialog = "Enter search path for files.\nSeparate directory names with a comma."
  endif
  let n = inputdialog(g:menutrans_path_dialog, substitute(&path, '\\ ', ' ', 'g'))
  if n != ""
    let &path = substitute(n, ' ', '\\ ', 'g')
  endif
endfun

fun! planet#settings#SetTags()
  if !exists("g:menutrans_tags_dialog")
    let g:menutrans_tags_dialog = "Enter names of tag files.\nSeparate the names with a comma."
  endif
  let n = inputdialog(g:menutrans_tags_dialog, substitute(&tags, '\\ ', ' ', 'g'))
  if n != ""
    let &tags = substitute(n, ' ', '\\ ', 'g')
  endif
endfun

fun! planet#settings#SetTextWidth(...) abort
  if !exists("g:menutrans_textwidth_dialog")
    let g:menutrans_textwidth_dialog = "Enter new text width (0 to disable formatting): "
  endif
  let n = a:0 ? a:1 : inputdialog(g:menutrans_textwidth_dialog, &tw)
  if n != ""
    if n !~# '^\d\+$'
      throw 'PlanetVim: text width must be a non-negative integer'
    endif
    let &l:textwidth = str2nr(n, 10)
  endif
endfun

fun! planet#settings#EditOption(option, ...) abort
  let l:allowed = ['makeprg', 'grepprg', 'formatprg', 'equalprg', 'keywordprg',
        \ 'path', 'tags', 'dictionary', 'thesaurus', 'include', 'define', 'suffixesadd']
  if index(l:allowed, a:option) < 0
    throw 'PlanetVim: unsupported option editor'
  endif
  let l:value = a:0 ? a:1 : inputdialog('Set buffer option ' .. a:option .. ':', eval('&l:' .. a:option), "\n")
  if l:value ==# "\n" | return 0 | endif
  execute 'let &l:' .. a:option .. ' = l:value'
  return 1
endfun

fun! planet#settings#SetLineEndings()
  if !exists("g:menutrans_fileformat_dialog")
    let g:menutrans_fileformat_dialog = "Select line endings for file"
  endif
  if !exists("g:menutrans_fileformat_choices")
    let g:menutrans_fileformat_choices = "&Unix (LF)\n&Windows (CRLF)\nLegacy &Mac (CR)\n&Cancel"
  endif
  if &ff == "dos"
    let def = 2
  elseif &ff == "mac"
    let def = 3
  else
    let def = 1
  endif
  let n = confirm(g:menutrans_fileformat_dialog, g:menutrans_fileformat_choices, def, "Question")
  if n == 1
    set ff=unix
  elseif n == 2
    set ff=dos
  elseif n == 3
    set ff=mac
  endif
endfun

" func! planet#settings#ToggleGuiOption(option) abort
"   " If a:option is already set in guioptions, then we want to remove it
"   if match(&guioptions, "\\C" . a:option) > -1
"     exec "set go-=" . a:option
"   else
"     exec "set go+=" . a:option
"   endif
" endfunc
