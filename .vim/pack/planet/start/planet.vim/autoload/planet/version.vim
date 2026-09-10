vim9script
export def Get(): string
  var path: any = planet#paths#Root() .. '/VERSION'
  return filereadable(path) ? get(readfile(path, '', 1), 0, 'unknown') : 'unknown'
enddef
