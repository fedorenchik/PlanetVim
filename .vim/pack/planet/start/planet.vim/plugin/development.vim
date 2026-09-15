vim9script noclear
if exists('g:loaded_planet_development')
  finish
endif
g:loaded_planet_development = 1

command! -nargs=1 PlanetTest call planet#test#Test(<q-args>)
command! -nargs=+ PlanetDebug call planet#debug#Action(<f-args>)
command! -nargs=1 PlanetDebugSetup call planet#debug#Setup(<q-args>)
command! -nargs=? PlanetProjectSelect call planet#project#Select(<q-args>)
command! PlanetProjectEdit call planet#project#Edit()
command! PlanetProjectLocal call planet#project#Edit(v:true)
command! PlanetProjectInfo call planet#project#Show()
command! -nargs=? PlanetTask call empty(<q-args>) ? planet#task#Choose() : planet#task#Start(<q-args>)
command! PlanetTaskCancel call planet#task#Cancel()
command! PlanetTaskRerun call planet#task#Rerun()
command! PlanetTasks call planet#task#Show()

g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
g:test#custom_strategies.planet = function('planet#test#Strategy')
