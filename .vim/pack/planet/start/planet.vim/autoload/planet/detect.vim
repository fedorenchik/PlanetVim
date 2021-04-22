scriptversion 4

" Detects binaries used by PlanetVim
func planet#detect#Binaries() abort
  let l:binaries = [
        \ 'aqtinstall',
        \ 'conan',
        \ 'docker',
        \ 'git',
        \ 'languagetool',
        \ 'pip',
        \ 'pipenv',
        \ 'xxd',
        \ ]
  for bin in l:binaries
    exe 'let g:PV_has_' .. bin .. ' = ! exepath("' .. bin .. '")->empty()'
  endfor
endfunc
