vim9script

var script_did_open_help = v:false
export def Curwin(subject: any): any
  var mods: any = 'silent noautocmd keepalt'
  if !script_did_open_help
    execute mods .. ' help'
    execute mods .. ' helpclose'
    script_did_open_help = v:true
  endif
  if !getcompletion(subject, 'help')->empty()
    execute mods .. ' edit ' .. &helpfile
  endif
  return 'help ' .. subject
enddef
