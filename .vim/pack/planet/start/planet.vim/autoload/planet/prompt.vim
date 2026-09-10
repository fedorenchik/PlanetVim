vim9script
export def Ask(prompt: string, default: string = '', completion: string = ''): any
  var value: any
  inputsave()
  try
    if empty(completion) && planet#planet#IsGuiDialogs()
      value = inputdialog(prompt, default, "\x1b")
      return value ==# "\x1b" ? v:null : value
    endif
    return input(prompt, default, completion)
  catch /^Vim:Interrupt$/
    return v:null
  finally
    inputrestore()
  endtry
  return 0
enddef

export def Choose(title: string, choices: list<string>): number
  var lines: any
  var n: any
  if empty(choices)
    echom 'PlanetVim: no choices available for ' .. title
    return -1
  endif
  inputsave()
  try
    lines = [title .. ' (0 cancels)']
    for i in range(len(choices))
      add(lines, printf('%d. %s', i + 1, choices[i]))
    endfor
    n = inputlist(lines)
    return n > 0 && n <= len(choices) ? n - 1 : -1
  catch /^Vim:Interrupt$/
    return -1
  finally
    inputrestore()
  endtry
  return 0
enddef

export def Unavailable(feature: string, help: string): number
  echom 'PlanetVim: ' .. feature .. ' is unavailable in this GVim/runtime. See :help ' .. help
  return 0
enddef
