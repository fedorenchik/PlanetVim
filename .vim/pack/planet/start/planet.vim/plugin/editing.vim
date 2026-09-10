if exists('g:loaded_planet_editing') | finish | endif
let g:loaded_planet_editing = 1
command! -bar -range PlanetToggleComment call planet#editing#ToggleComment(<line1>, <line2>)
if empty(maparg('gcc', 'n'))
  nnoremap <silent> gcc <Cmd>PlanetToggleComment<CR>
endif
