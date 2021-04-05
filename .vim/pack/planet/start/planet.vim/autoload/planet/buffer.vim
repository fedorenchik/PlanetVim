scriptversion 4

func! planet#buffer#DeleteAll()
  let l:buf = 1
  while l:buf <= bufnr('$')
    if !bufexists(l:buf)
      let l:buf += 1
      continue
    endif
    if !buflisted(l:buf) && !bufloaded(l:buf)
      let l:buf += 1
      continue
    endif
    exe "bdel " .. l:buf
    let l:buf += 1
  endwhile
endfunc

func! planet#buffer#DeleteHidden() abort
  let l:buf = 1
  while l:buf <= bufnr('$')
    if !bufexists(l:buf)
      let l:buf += 1
      continue
    endif
    if !buflisted(l:buf) && !bufloaded(l:buf)
      let l:buf += 1
      continue
    endif
    if bufwinid(l:buf) == -1
      exe "bdel " .. l:buf
    endif
    let l:buf += 1
  endwhile
endfunc

func! planet#buffer#IsNormal(name, num)
    if !bufexists(a:num)
      return 0
    endif
    if isdirectory(a:name) || !buflisted(a:num)
      return 0
    endif
    let type = getbufvar(a:num, '&buftype')
    if type != '' && type != 'nofile' && type != 'nowrite'
      return 0
    endif
    return 1
endfunc

func!planet#buffer#AddBuffer(name, num)
  if planet#buffer#IsNormal(a:name, a:num)
    let menu_name = planet#menu#MenuifyName(a:name)
    exe 'an 800.500 📖&b.Buffer\ List.' .. menu_name .. ' :confirm b ' .. a:num .. '<CR>'
  endif
endfunc

func! planet#buffer#AddBufferAu()
  let name = expand("<afile>")
  let num = expand("<abuf>") + 0
  call planet#buffer#AddBuffer(name, num)
endfunc

func! planet#buffer#RemoveBufferAu()
  let name = expand("<afile>")
  let menu_name = planet#menu#MenuifyName(name)
  if ! empty(menu_name)
    exe 'silent! aun 800.500 📖&b.Buffer\ List.' .. menu_name
  endif
endfunc

func! planet#buffer#AddBuffers()
  let buf = 1
  while buf <= bufnr('$')
    let name = bufname(buf)
    call planet#buffer#AddBuffer(name, num)
    let buf += 1
  endwhile
endfunc
