" Write and explicitly approve a disposable project configuration.
func! PlanetTestProjectSettings(config, ...) abort
  let l:private = a:0 ? a:1 : v:false
  call writefile(['vim9script', 'export var config: dict<any> = ' .. string(a:config)], planet#project#File(l:private))
  call planet#project#Reload(v:true)
endfunc
