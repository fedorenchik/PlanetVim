scriptversion 4

let s:did_open_help = v:false
func! planet#help#Curwin(subject) abort
  let mods = 'silent noautocmd keepalt'
  if !s:did_open_help
    execute mods .. ' help'
    execute mods .. ' helpclose'
    let s:did_open_help = v:true
  endif
  if !getcompletion(a:subject, 'help')->empty()
    execute mods .. ' edit ' .. &helpfile
  endif
  return 'help ' .. a:subject
endfunc
