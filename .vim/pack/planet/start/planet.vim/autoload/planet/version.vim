scriptversion 4
func! planet#version#Get() abort
  let l:path = planet#paths#Root() .. '/VERSION'
  return filereadable(l:path) ? get(readfile(l:path, '', 1), 0, 'unknown') : 'unknown'
endfunc
