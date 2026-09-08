scriptversion 4

func! planet#scaffold#Catalog() abort
  return json_decode(join(readfile(planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/templates/catalog.json'), "\n"))
endfunc

func! planet#scaffold#New(name, destination = v:null, options = {}) abort
  let l:catalog = planet#scaffold#Catalog()
  if !has_key(l:catalog, a:name)
    echomsg 'PlanetVim: unknown template: ' .. a:name
    return 0
  endif
  let l:entry = l:catalog[a:name]
  let l:options = extend(copy(a:options), #{open: v:true}, 'keep')
  return l:entry.kind ==# 'file'
        \ ? planet#generate#CopyFile(l:entry.path, a:destination, l:options)
        \ : planet#generate#Template(l:entry.path, a:destination, l:options)
endfunc
