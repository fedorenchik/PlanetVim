# sparta.vim

Vim Distribution from Spartans.

# Features

* GUI
* Menus
* Auto Save

## Distinguishable features from other Distributions

* Persistent undo in $HOME/.vim/undo
* No swap files (persistent undo is used as alternative)
* No backup files (persistent undo is used as alternative)
* automatically source local .vimrc/.exrc file from current directory
  - `'secure'` option is set to restrict what can be put into local .vimrc/.exrc
* Auto Save files
  - `set autowrite autowriteall` and some `autocmd`s.
* Discoverable:
  - Redefine all menus
* GUI officially supported

### Some unusual technical details

* Minimum window size (width & height) is zero

### Maps
 * Try to not redefine standard Vim maps (except Vim anti-patterns, almost)
 * Do not redefine any vim-obsession mappings
 * Define additional (not mapped originally) mappings in g..., z..., Z...,
     [..., ]..., <A-...>
 * Leader is ',', LocalLeader is `'_'`
