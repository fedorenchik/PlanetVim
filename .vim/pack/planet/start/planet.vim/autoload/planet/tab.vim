scriptversion 4

"TODO: Cannot change browsefilter for mksession & so commands. Add support for it.

func! planet#tab#Save() abort
  let l:old_ssop = &ssop
  let l:old_session = v:this_session
  set sessionoptions-=tabpages
  set sessionoptions-=winpos
  let g:browsefilter = "Vim Tab\t*.vimtab\n"
  exe "browse mksession! " .. fnameescape(fnamemodify(bufname(), ":t:r") .. ".tab.vim")
  unlet g:browsefilter
  let v:this_session = l:old_session
  let &ssop = l:old_ssop
endfunc

func! planet#tab#Open() abort
  let l:old_ssop = &ssop
  let l:old_session = v:this_session
  set sessionoptions-=tabpages
  set sessionoptions-=winpos
  tabnew
  let g:browsefilter = "Vim Tab\t*.vimtab\n"
  exe "browse so " .. fnameescape(fnamemodify(bufname(), ":t:r") .. ".tab.vim")
  unlet g:browsefilter
  let v:this_session = l:old_session
  let &ssop = l:old_ssop
endfunc

func! planet#tab#SaveTmp() abort
  let l:old_ssop = &ssop
  let l:old_session = v:this_session
  set sessionoptions-=tabpages
  set sessionoptions-=winpos
  exe "mksession! " .. fnameescape(expand("$HOME/.vim/tab/tmp.tab.vim"))
  let v:this_session = l:old_session
  let &ssop = l:old_ssop
endfunc

func! planet#tab#Reopen() abort
  let l:old_ssop = &ssop
  let l:old_session = v:this_session
  set sessionoptions-=tabpages
  set sessionoptions-=winpos
  tabnew
  exe "so " .. fnameescape(expand("$HOME/.vim/tab/tmp.tab.vim"))
  let v:this_session = l:old_session
  let &ssop = l:old_ssop
endfunc
