vim9script

# Keep :Clap and its existing mappings useful without the optional Maple binary.
command! -bang -nargs=* -bar -range -complete=customlist,clap#helper#complete Clap call planet#picker#Clap(<bang>0, [<f-args>])

augroup PlanetClapFallback
  autocmd!
  autocmd User ClapOnInitialize call planet#picker#Prepare()
augroup END
