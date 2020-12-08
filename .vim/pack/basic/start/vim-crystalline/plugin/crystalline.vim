scriptencoding utf-8

" Helper Variables {{{

if !exists('g:crystalline_mode_labels')
  let g:crystalline_mode_labels = {
        \ 'n': ' NORMAL ',
        \ 'i': ' INSERT ',
        \ 'v': ' VISUAL ',
        \ 'R': ' REPLACE ',
        \ '': '',
        \ }
endif

let g:crystalline_mode_hi_groups = {
      \ 'n': 'NormalMode',
      \ 'i': 'InsertMode',
      \ 'v': 'VisualMode',
      \ 'R': 'ReplaceMode',
      \ '': '',
      \ }

if !exists('g:crystalline_separators')
  let g:crystalline_separators = ['', '']
endif

if !exists('g:crystalline_tab_separator')
  let g:crystalline_tab_separator = ''
endif

if !exists('g:crystalline_tab_empty')
  let g:crystalline_tab_empty = '[No Name]'
endif

if !exists('g:crystalline_tab_mod')
  let g:crystalline_tab_mod = '[+]'
endif

if !exists('g:crystalline_tab_left')
  let g:crystalline_tab_left = ' '
endif

if !exists('g:crystalline_tab_nomod')
  let g:crystalline_tab_nomod = ' '
endif

if !exists('g:crystalline_sep_hi_groups')
  let g:crystalline_sep_hi_groups = {}
endif

if !exists('g:crystalline_tab_type_fake_separators')
  let g:crystalline_tab_type_fake_separators = {}
endif

if !exists('g:crystalline_syn_modes')
  let g:crystalline_syn_modes = ['term', 'cterm', 'gui']
endif

if !exists('g:crystalline_syn_attrs')
  let g:crystalline_syn_attrs = [
        \ 'font',
        \ 'bold',
        \ 'italic',
        \ 'reverse',
        \ 'standout',
        \ 'underline',
        \ 'undercurl',
        \ 'strikethrough'
        \ ]
endif

if !exists('g:crystalline_syn_colors')
  let g:crystalline_syn_colors = ['fg', 'bg', 'sp']
endif

if !exists('g:crystalline_theme')
  let g:crystalline_theme = 'default'
endif

" }}}

" Load User Settings {{{

if exists('g:crystalline_tabline_fn')
  call crystalline#set_tabline(g:crystalline_tabline_fn)
endif

if exists('g:crystalline_statusline_fn')
  call crystalline#set_statusline(g:crystalline_statusline_fn)
endif

call crystalline#apply_current_theme()

" }}}

" Setup autogroups {{{

augroup CrystallineTheme
  au!
  au ColorScheme * call crystalline#apply_current_theme()
  au OptionSet background call crystalline#apply_current_theme()
augroup END

" }}}

" vim:set et sw=2 ts=2 fdm=marker:
