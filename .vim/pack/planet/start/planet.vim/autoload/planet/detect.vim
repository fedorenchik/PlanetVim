vim9script
# Detects binaries used by PlanetVim
export def Binaries(): any
  var binaries: any = [ 'aqtinstall', 'conan', 'docker', 'git', 'languagetool', 'pip', 'pipenv', 'xxd', ]
  for bin in binaries
    g:['PV_has_' .. bin] = !empty(exepath(bin))
  endfor
  return 0
enddef
