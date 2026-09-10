scriptversion 4

func! planet#prompt#Ask(prompt, default = '', completion = '') abort
  call inputsave()
  try
    if empty(a:completion) && planet#planet#IsGuiDialogs()
      let l:value = inputdialog(a:prompt, a:default, "\x1b")
      return l:value ==# "\x1b" ? v:null : l:value
    endif
    return input(a:prompt, a:default, a:completion)
  catch /^Vim:Interrupt$/
    return v:null
  finally
    call inputrestore()
  endtry
endfunc

func! planet#prompt#Choose(title, choices) abort
  if empty(a:choices)
    echom 'PlanetVim: no choices available for ' .. a:title
    return -1
  endif
  call inputsave()
  try
    let l:lines = [a:title .. ' (0 cancels)']
    for l:i in range(len(a:choices))
      call add(l:lines, printf('%d. %s', l:i + 1, a:choices[l:i]))
    endfor
    let l:n = inputlist(l:lines)
    return l:n > 0 && l:n <= len(a:choices) ? l:n - 1 : -1
  catch /^Vim:Interrupt$/
    return -1
  finally
    call inputrestore()
  endtry
endfunc

func! planet#prompt#Unavailable(feature, help) abort
  echom 'PlanetVim: ' .. a:feature .. ' is unavailable in this GVim/runtime. See :help ' .. a:help
  return 0
endfunc
