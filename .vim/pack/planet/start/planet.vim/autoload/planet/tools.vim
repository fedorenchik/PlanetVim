scriptversion 4

func s:XxdToHex()
  let mod = &mod
  if has("vms")
    %!mc vim:xxd
  else
    call s:XxdFind()
    exe '%!' . g:xxdprogram
  endif
  if getline(1) =~ "^0000000:"		" only if it worked
    set ft=xxd
  endif
  let &mod = mod
endfun

func s:XxdFromHex()
  let mod = &mod
  if has("vms")
    %!mc vim:xxd -r
  else
    call s:XxdFind()
    exe '%!' . g:xxdprogram . ' -r'
  endif
  set ft=
  doautocmd filetypedetect BufReadPost
  let &mod = mod
endfun

func s:XxdFind()
  if !exists("g:xxdprogram")
    " On the PC xxd may not be in the path but in the install directory
    if has("win32") && !executable("xxd")
      let g:xxdprogram = $VIMRUNTIME . (&shellslash ? '/' : '\') . "xxd.exe"
      if g:xxdprogram =~ ' '
        let g:xxdprogram = '"' .. g:xxdprogram .. '"'
      endif
    else
      let g:xxdprogram = "xxd"
    endif
  endif
endfun
