scriptversion 4

func! planet#util#buffer#DeleteAll()
  let buf = 1
  while buf <= bufnr('$')
    if !buflisted(buf) && !bufloaded(buf)
      continue
    endif
    bdelete buf
    let buf += 1
  endwhile
endfunc

func! planet#util#buffer#DeleteHidden() abort
  let buf = 1
  while buf <= bufnr('$')
    if !buflisted(buf) && !bufloaded(buf)
      continue
    endif
    if getbufvar('&bufhidden') == v:true
      bdelete buf
    endif
    let buf += 1
  endwhile
endfunc

func! planet#util#buffer#IsNormal(name, num)
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

func!planet#util#buffer#AddBuffer(name, num)
  if planet#util#buffer#IsNormal(a:name, a:num)
    let menu_name = planet#util#MenuifyName(a:name)
    exe 'an 800.500 📖&b.' .. menu_name .. ' :confirm b ' .. a:num .. '<CR>'
  endif
endfunc

func! planet#util#buffer#AddBufferAu()
  let name = expand("<afile>")
  let num = expand("<abuf>") + 0
  call planet#util#buffer#AddBuffer(name, num)
endfunc

func! planet#util#buffer#RemoveBufferAu()
  let name = expand("<afile>")
  let menu_name = planet#util#MenuifyName(name)
  if ! empty(menu_name)
    exe 'silent! aun 800.500 📖&b.' .. menu_name
  endif
endfunc

func! planet#util#buffer#AddBuffers()
  let buf = 1
  while buf <= bufnr('$')
    let name = bufname(buf)
    call planet#util#buffer#AddBuffer(name, num)
    let buf += 1
  endwhile
endfunc

aug AugPv_MenuBuffers
au!
au BufCreate,BufFilePost * call planet#util#buffer#AddBufferAu()
au BufDelete,BufFilePre * call planet#util#buffer#RemoveBufferAu()
aug END
