scriptversion 4

augroup PlanetVimFiletypes
  autocmd!
  autocmd FileType * call planet#filetype#Apply()
augroup END
