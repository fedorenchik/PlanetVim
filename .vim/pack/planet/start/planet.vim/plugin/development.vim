if exists('g:loaded_planet_development')
  finish
endif
let g:loaded_planet_development = 1

command! -nargs=1 PlanetTest call planet#test#Test(<q-args>)
command! -nargs=+ PlanetDebug call planet#debug#Action(<f-args>)
command! -nargs=1 PlanetDebugSetup call planet#debug#Setup(<q-args>)

let g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
let g:test#custom_strategies.planet = function('planet#test#Strategy')
