scriptversion 4

func! s:Hex(reverse) abort
  let l:xxd = get(g:, 'xxdprogram', exepath('xxd'))
  if empty(l:xxd) && has('win32')
    let l:xxd = fnamemodify(v:progpath, ':h') .. '/xxd.exe'
  endif
  if !executable(l:xxd)
    echomsg 'PlanetVim: install xxd or set g:xxdprogram to its executable path.'
    return 0
  endif
  let l:lines = getline(1, '$')
  let l:modified = &modified
  let l:view = winsaveview()
  execute '%!' .. shellescape(l:xxd) .. (a:reverse ? ' -r' : '')
  if v:shell_error
    let l:error = join(getline(1, '$'), ' ')
    silent %delete _
    call setline(1, l:lines)
    let &modified = l:modified
    call winrestview(l:view)
    echomsg 'PlanetVim: HEX conversion failed: ' .. l:error
    return 0
  endif
  if a:reverse
    setlocal filetype=
    filetype detect
  else
    setlocal filetype=xxd
  endif
  return 1
endfunc

func! planet#tools#XxdToHex() abort
  return s:Hex(v:false)
endfunc

func! planet#tools#XxdFromHex() abort
  return s:Hex(v:true)
endfunc
