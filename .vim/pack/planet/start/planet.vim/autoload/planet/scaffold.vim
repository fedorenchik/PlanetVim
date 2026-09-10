vim9script
export def Catalog(): any
  return json_decode(join(readfile(planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/templates/catalog.json'), "\n"))
enddef

export def New(name: any, destination: any = v:null, arg_options: any = {}): any
  var catalog: any = planet#scaffold#Catalog()
  if !has_key(catalog, name)
    echomsg 'PlanetVim: unknown template: ' .. name
    return 0
  endif
  var entry: any = catalog[name]
  var options: any = extend(copy(arg_options), {open: v:true}, 'keep')
  return entry.kind ==# 'file' ? planet#generate#CopyFile(entry.path, destination, options) : planet#generate#Template(entry.path, destination, options)
enddef
