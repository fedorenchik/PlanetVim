vim9script

export def DeleteAll(): any
  var buf: any = 1
  while buf <= bufnr('$')
    if !bufexists(buf)
      buf += 1
      continue
    endif
    if !buflisted(buf) && !bufloaded(buf)
      buf += 1
      continue
    endif
    exe "bdel " .. buf
    buf += 1
  endwhile
  return 0
enddef

export def DeleteHidden(): any
  var buf: any = 1
  while buf <= bufnr('$')
    if !bufexists(buf)
      buf += 1
      continue
    endif
    if !buflisted(buf) && !bufloaded(buf)
      buf += 1
      continue
    endif
    if win_findbuf(buf)->empty()
      exe "bdel " .. buf
    endif
    buf += 1
  endwhile
  return 0
enddef

export def IsNormal(name: any, num: any): any
  var type: any
  if !bufexists(num)
    return 0
  endif
  if isdirectory(name) || !buflisted(num)
    return 0
  endif
  type = getbufvar(num, '&buftype')
  if type != '' && type != 'nofile' && type != 'nowrite'
    return 0
  endif
  return 1
enddef

var script_entries = {}

def LocalRemove(number: any): any
  if has_key(script_entries, number)
    execute 'silent! aunmenu 📖&u.Buffer\ List.' .. script_entries[number]
    remove(script_entries, number)
  endif
  return 0
enddef

export def AddBuffer(name: any, num: any): any
  LocalRemove(num)
  if planet#buffer#IsNormal(name, num)
    script_entries[num] = planet#menu#MenuifyName('[' .. num .. '] ' .. (empty(name) ? '[No Name]' :  name))
    execute 'PlanetMenu an 800.500 📖&u.Buffer\ List.' .. script_entries[num] .. ' <Cmd>confirm buffer ' .. num .. '<CR>'
  endif
  return 0
enddef

export def AddBufferAu(): any
  if planet#menu#Visible('nav')
    planet#buffer#AddBuffer(expand('<afile>'), str2nr(expand('<abuf>')))
  endif
  return 0
enddef

export def RemoveBufferAu(): any
  LocalRemove(str2nr(expand('<abuf>')))
  return 0
enddef

export def AddBuffers(): any
  silent! aunmenu 📖&u.Buffer\ List
  script_entries = {}
  if planet#menu#Visible('nav')
    for buffer in getbufinfo({'buflisted': 1})
      planet#buffer#AddBuffer(buffer.name, buffer.bufnr)
    endfor
  endif
  return 0
enddef
