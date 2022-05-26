scriptversion 4

func! planet#modify#Filter() abort
  let l:pattern = input("Filter: ")
  if empty(l:pattern)
    return
  endif
  exe "g!/" .. l:pattern .. "/d"
endfunc

func! planet#modify#FilterOut() abort
  let l:pattern = input("Filter Out: ")
  if empty(l:pattern)
    return
  endif
  exe "g/" .. l:pattern .. "/d"
endfunc
