scriptversion 4

func! planet#arduino#Baud(value = v:null) abort
  if exists(':ArduinoSetBaud') != 2
    echom 'PlanetVim: open an Arduino sketch before setting its serial baud rate.'
    return 0
  endif
  let l:value = a:value is v:null ? inputdialog('Arduino serial baud rate: ', '115200', '\CANCEL')
        \ : type(a:value) == v:t_string ? a:value : string(a:value)
  if empty(l:value) || l:value ==# '\CANCEL' | return 0 | endif
  if l:value !~# '^\d\+$' || str2nr(l:value, 10) <= 0
    echom 'PlanetVim: baud rate must be a positive integer.'
    return 0
  endif
  execute 'ArduinoSetBaud ' .. str2nr(l:value, 10)
  return 1
endfunc
