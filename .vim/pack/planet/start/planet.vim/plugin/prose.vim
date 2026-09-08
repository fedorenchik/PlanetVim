if exists('g:loaded_planet_prose')
  finish
endif
let g:loaded_planet_prose = 1
" Keep the bundled Python engines, replace its eval-based Vim job layer.
let g:loaded_translator = 1
let g:translator_history_enable = v:false
" Wordy's generated spelling data must never go into its installed package.
let g:wordy_spell_dir = planet#paths#Cache('wordy')
command! -nargs=1 PlanetFocus call planet#prose#Focus(<q-args> ==# 'on')
command! -nargs=? PlanetTranslate call planet#translation#Translate(empty(<q-args>) ? 'window' : <q-args>)
command! PlanetTranslationHistory call planet#translation#History()
command! -complete=customlist,planet#translation#Complete -nargs=* -bang -range Translate call planet#translation#Command('echo', <range>, <line1>, <line2>, <q-args>, <bang>0)
command! -complete=customlist,planet#translation#Complete -nargs=* -bang -range TranslateW call planet#translation#Command('window', <range>, <line1>, <line2>, <q-args>, <bang>0)
command! -complete=customlist,planet#translation#Complete -nargs=* -bang -range TranslateR call planet#translation#Command('replace', <range>, <line1>, <line2>, <q-args>, <bang>0)
command! -complete=customlist,planet#translation#Complete -nargs=* -bang TranslateX call planet#translation#Command('echo', 0, 0, 0, <q-args> .. ' ' .. getreg('*'), <bang>0)
command! TranslateH call planet#translation#History()
command! TranslateL call planet#translation#Log()
nnoremap <silent> <Plug>Translate <Cmd>call planet#translation#Translate('echo')<CR>
xnoremap <silent> <Plug>TranslateV <Cmd>call planet#translation#Translate('echo', v:null, planet#selection#Current())<CR>
nnoremap <silent> <Plug>TranslateW <Cmd>call planet#translation#Translate('window')<CR>
xnoremap <silent> <Plug>TranslateWV <Cmd>call planet#translation#Translate('window', v:null, planet#selection#Current())<CR>
nnoremap <silent> <Plug>TranslateR <Cmd>call planet#translation#Translate('replace')<CR>
xnoremap <silent> <Plug>TranslateRV <Cmd>call planet#translation#Translate('replace', v:null, planet#selection#Current())<CR>
nnoremap <silent> <Plug>TranslateX <Cmd>TranslateX<CR>
