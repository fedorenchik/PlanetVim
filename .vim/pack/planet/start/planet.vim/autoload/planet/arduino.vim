vim9script
export def Baud(arg_value: any = v:null): any
  if exists(':ArduinoSetBaud') != 2
    echom 'PlanetVim: open an Arduino sketch before setting its serial baud rate.'
    return 0
  endif
  var value: any = arg_value == null ? inputdialog('Arduino serial baud rate: ', '115200', '\CANCEL') : type(arg_value) == v:t_string ? arg_value : string(arg_value)
  if empty(value) || value ==# '\CANCEL'
    return 0
  endif
  if value !~# '^\d\+$' || str2nr(value, 10) <= 0
    echom 'PlanetVim: baud rate must be a positive integer.'
    return 0
  endif
  execute 'ArduinoSetBaud ' .. str2nr(value, 10)
  return 1
enddef
