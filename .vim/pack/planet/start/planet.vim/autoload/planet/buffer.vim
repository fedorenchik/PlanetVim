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
    if win_findbuf(l:buf)->empty()
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

let s:entries = {}

func! s:Remove(number) abort
  if has_key(s:entries, a:number)
    execute 'silent! aunmenu 📖&u.Buffer\ List.' .. s:entries[a:number]
    call remove(s:entries, a:number)
  endif
endfunc

func! planet#buffer#AddBuffer(name, num) abort
  call s:Remove(a:num)
  if planet#buffer#IsNormal(a:name, a:num)
    let s:entries[a:num] = planet#menu#MenuifyName('[' .. a:num .. '] ' .. (empty(a:name) ? '[No Name]' : a:name))
    execute 'an 800.500 📖&u.Buffer\ List.' .. s:entries[a:num] .. ' <Cmd>confirm buffer ' .. a:num .. '<CR>'
  endif
endfunc

func! planet#buffer#AddBufferAu() abort
  if get(g:, 'PlanetVim_menus_nav', 1)
    call planet#buffer#AddBuffer(expand('<afile>'), str2nr(expand('<abuf>')))
  endif
endfunc

func! planet#buffer#RemoveBufferAu() abort
  call s:Remove(str2nr(expand('<abuf>')))
endfunc

func! planet#buffer#AddBuffers() abort
  silent! aunmenu 📖&u.Buffer\ List
  let s:entries = {}
  if get(g:, 'PlanetVim_menus_nav', 1)
    for l:buffer in getbufinfo({'buflisted': 1})
      call planet#buffer#AddBuffer(l:buffer.name, l:buffer.bufnr)
    endfor
  endif
endfunc
