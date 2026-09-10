vim9script
def LocalRegister(arg_value: any, recording: any = 0): any
  var value: any = arg_value == null ? planet#prompt#Ask(recording ? 'Record into register a-z (uppercase appends): ' : 'Register to use: ', 'a') : arg_value
  if value == null || empty(value)
    return ''
  endif
  if value !~# (recording ? '^[a-zA-Z]$' : '^[a-zA-Z0-9"+*]$')
    echomsg 'PlanetVim: enter a single named register'
    return ''
  endif
  return value
enddef

export def Preview(arg_register: any = v:null): any
  var register: any = LocalRegister(arg_register)
  if empty(register)
    return 0
  endif
  var lines: any = getreg(register, 1, 1)
  if empty(lines)
    lines = ['[empty register]']
  endif
  return popup_create(map(lines[ : 99], (_, lambda_line) => strtrans(lambda_line)), {title: ' Register ' .. register .. ' (first 100 lines) ',
       maxheight: 15, maxwidth: max([30, &columns - 8]), close: 'click', filter: 'popup_filter_yesno',
       mapping: 0})
enddef

export def Record(arg_register: any = v:null): any
  if !empty(reg_recording())
    echomsg 'PlanetVim: already recording into ' .. reg_recording()
    return 0
  endif
  var register: any = LocalRegister(arg_register, 1)
  if empty(register)
    return 0
  endif
  feedkeys('q' .. register, 'in')
  return 1
enddef

export def Stop(): any
  if empty(reg_recording())
    return 0
  endif
  feedkeys('q', 'in')
  return 1
enddef

export def Play(arg_register: any = v:null, arg_count: any = 1, selected: any = 0, confirm: any = 1): any
  var first: any
  var last: any
  var selection: any = selected ? planet#selection#Current() : {}
  var register: any = LocalRegister(arg_register)
  if empty(register)
    return 0
  endif
  var count: any = arg_count == null ? planet#prompt#Ask('Repeat count: ', '1') : string(arg_count)
  if count == null || empty(count)
    return 0
  endif
  if count !~# '^\d\+$' || str2nr(count) < 1
    echomsg 'PlanetVim: enter a positive repeat count'
    return 0
  endif
  if empty(getreg(register))
    echomsg 'PlanetVim: register ' .. register .. ' is empty'
    return 0
  endif
  if selected
    first = min([selection.start[1], selection.end[1]])
    last = max([selection.start[1], selection.end[1]])
    if confirm && confirm('Run register ' .. register .. ' ' .. count .. ' time(s) on each of lines ' .. first .. '-' .. last .. "?\n" .. strcharpart(strtrans(getreg(register)),
         0, 200), "&Apply\n&Cancel", 2) != 1
      return 0
    endif
    execute "normal! \<Esc>"
    execute ':' .. first .. ',' .. last .. 'global/^/normal! ' .. count .. '@' .. register
  else
    feedkeys(count .. '@' .. register, 'in')
  endif
  return 1
enddef

export def Menus(): any
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
  return 0
enddef
