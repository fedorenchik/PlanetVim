Include source for asyncomplete.vim via neoinclude
============================================

Provide include autocompletion source for [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim) via
[neoinclude](https://github.com/Shougo/neoinclude.vim)

### Installing

```vim
Plug 'Shougo/neocinclude.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-neoinclude.vim'
```

#### Registration

```vim
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#neoinclude#get_source_options({
    \ 'name': 'neoinclude',
    \ 'allowlist': ['cpp'],
    \ 'refresh_pattern': '\(<\|"\|/\)$',
    \ 'completor': function('asyncomplete#sources#neoinclude#completor'),
    \ }))
```
