scriptversion 4

"TODO: Cannot change browsefilter for mksession & so commands. Add support for it.

func! planet#tab#Save() abort
  let l:old_ssop = &ssop
  set sessionoptions-=tabpages
  set sessionoptions-=winpos
  let g:browsefilter = "Vim Tab\t*.vimtab\n"
  exe "browse mksession! " .. fnameescape(fnamemodify(bufname(), ":t:r") .. ".tab.vim")
  unlet g:browsefilter
  let &ssop = l:old_ssop
endfunc

func! planet#tab#Open() abort
  let l:old_ssop = &ssop
  set sessionoptions-=tabpages
  set sessionoptions-=winpos
  tabnew
  let g:browsefilter = "Vim Tab\t*.vimtab\n"
  exe "browse so " .. fnameescape(fnamemodify(bufname(), ":t:r") .. ".tab.vim")
  unlet g:browsefilter
  let &ssop = l:old_ssop
endfunc

"TODO: Use au TabLeave to save current tab
func! planet#tab#Reopen() abort
  echo "TODO: Use au TabLeave to save current tab"
endfunc
