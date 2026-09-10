vim9script
export def Filter(): any
  var pattern: any = input("Filter: ")
  if empty(pattern)
    return 0
  endif
  exe "g!/" .. pattern .. "/d"
  return 0
enddef

export def FilterOut(): any
  var pattern: any = input("Filter Out: ")
  if empty(pattern)
    return 0
  endif
  exe "g/" .. pattern .. "/d"
  return 0
enddef
