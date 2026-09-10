vim9script noclear
augroup PlanetVimFiletypes
  autocmd!
  autocmd FileType * call planet#filetype#Apply()
augroup END
