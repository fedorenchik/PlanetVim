scriptversion 4

func! s:Register(value, recording = 0) abort
  let l:value = a:value is v:null ? planet#prompt#Ask(a:recording ? 'Record into register a-z (uppercase appends): ' : 'Register to use: ', 'a') : a:value
  if l:value is v:null || empty(l:value) | return '' | endif
  if l:value !~# (a:recording ? '^[a-zA-Z]$' : '^[a-zA-Z0-9"+*]$')
    echomsg 'PlanetVim: enter a single named register'
    return ''
  endif
  return l:value
endfunc

func! planet#macros#Preview(register = v:null) abort
  let l:register = s:Register(a:register)
  if empty(l:register) | return 0 | endif
  let l:lines = getreg(l:register, 1, 1)
  if empty(l:lines) | let l:lines = ['[empty register]'] | endif
  return popup_create(map(l:lines[:99], {_, line -> strtrans(line)}), #{title: ' Register ' .. l:register .. ' (first 100 lines) ', maxheight: 15, maxwidth: max([30, &columns - 8]), close: 'click', filter: 'popup_filter_yesno', mapping: 0})
endfunc

func! planet#macros#Record(register = v:null) abort
  if !empty(reg_recording()) | echomsg 'PlanetVim: already recording into ' .. reg_recording() | return 0 | endif
  let l:register = s:Register(a:register, 1)
  if empty(l:register) | return 0 | endif
  call feedkeys('q' .. l:register, 'in')
  return 1
endfunc

func! planet#macros#Stop() abort
  if empty(reg_recording()) | return 0 | endif
  call feedkeys('q', 'in')
  return 1
endfunc

func! planet#macros#Play(register = v:null, count = 1, selected = 0, confirm = 1) abort
  let l:selection = a:selected ? planet#selection#Current() : {}
  let l:register = s:Register(a:register)
  if empty(l:register) | return 0 | endif
  let l:count = a:count is v:null ? planet#prompt#Ask('Repeat count: ', '1') : string(a:count)
  if l:count is v:null || empty(l:count) | return 0 | endif
  if l:count !~# '^\d\+$' || str2nr(l:count) < 1 | echomsg 'PlanetVim: enter a positive repeat count' | return 0 | endif
  if empty(getreg(l:register)) | echomsg 'PlanetVim: register ' .. l:register .. ' is empty' | return 0 | endif
  if a:selected
    let l:first = min([l:selection.start[1], l:selection.end[1]])
    let l:last = max([l:selection.start[1], l:selection.end[1]])
    if a:confirm && confirm('Run register ' .. l:register .. ' ' .. l:count .. ' time(s) on each of lines ' .. l:first .. '-' .. l:last .. "?\n" .. strcharpart(strtrans(getreg(l:register)), 0, 200), "&Apply\n&Cancel", 2) != 1 | return 0 | endif
    execute "normal! \<Esc>"
    execute l:first .. ',' .. l:last .. 'global/^/normal! ' .. l:count .. '@' .. l:register
  else
    call feedkeys(l:count .. '@' .. l:register, 'in')
  endif
  return 1
endfunc

func! planet#macros#Menus() abort
  PlanetMenu an 200.15 📋&".Guided\ Macros.Preview\ Register <Cmd>call planet#macros#Preview()<CR>
  PlanetMenu an 200.15 📋&".Guided\ Macros.Record\ Into <Cmd>call planet#macros#Record()<CR>
  PlanetMenu an 200.15 📋&".Guided\ Macros.Stop\ Recording <Cmd>call planet#macros#Stop()<CR>
  PlanetMenu an 200.15 📋&".Guided\ Macros.Play <Cmd>call planet#macros#Play()<CR>
  PlanetMenu an 200.15 📋&".Guided\ Macros.Repeat\ Count <Cmd>call planet#macros#Play(v:null, v:null)<CR>
  PlanetMenu an 200.15 📋&".Guided\ Macros.Apply\ to\ Selected\ Lines V<Cmd>call planet#macros#Play(v:null, v:null, 1)<CR>
  PlanetMenu vnoremenu 200.15 📋&".Guided\ Macros.Apply\ to\ Selected\ Lines <Cmd>call planet#macros#Play(v:null, v:null, 1)<CR>
  PlanetMenu snoremenu 200.15 📋&".Guided\ Macros.Apply\ to\ Selected\ Lines <Cmd>call planet#macros#Play(v:null, v:null, 1)<CR>
  PlanetMenu an 200.15 📋&".Guided\ Macros.Recording\ Status <Cmd>echo 'Recording: ' .. (empty(reg_recording()) ? 'off' : reg_recording())<CR>
  PlanetMenu an 200.15 📋&".Guided\ Macros.Help <Cmd>help recording<CR>
endfunc
