# Window Mode

Adds a new VIM mode that allows performing window operations (selecting,
moving, resizing...) quickly by removing the `<C-w>` prefix from all the window
mappings.

The Window mode is activated either by pressing `<C-w>m`, or by using the
command `:WindowMode`.

While the mode is active, all keypresses will act as being prefixed by the
mapping `<C-w>`. 
For example if you press `j` and then `K` the inputs VIM will receive will be
`<C-w>j` and `<C-w>K`.

Pressing `<ESC>` or `<C-c>` will exit the Window Mode, returning to Normal Mode.

The digits `0` through `9` can be used, as in normal mode, to repeat commands.

The repeat mapping `.` will repeat the last non-movement operation.

## Installation

### [VimPlug](https://github.com/junegunn/vim-plug)

Add `Plug 'mtdl9/vim-window-mode'` to your `~/.vimrc` and run `PlugInstall`.

### [Vundle](https://github.com/gmarik/Vundle.vim)

Add `Plugin 'mtdl9/vim-window-mode'` to your `~/.vimrc` and run `PluginInstall`.

### [Pathogen](https://github.com/tpope/vim-pathogen)

    $ git clone https://github.com/mtdl9/vim-window-mode ~/.vim/bundle/vim-window-mode

### Manual Install

Copy the contents of the `plugin` folder in its respective ~/.vim/\* counterpart.


## Configuration

This mode supports custom mappings after the `<C-w>` prefix, for example you
can define some additional mappings in your .vimrc for switching/deleting
buffers:

```viml
nnoremap <C-w>B :bnext<CR>
nnoremap <C-w>V :bprev<CR>
nnoremap <C-w>D :bdelete<CR>
```


## Lightline Integration

This plugin defines a custom function `window_mode#lightlineComponent` that
can be used in the Lightline plugin for defining a custom component.

This function will return `'WINDOW'` when Window Mode is enabled or an empty
string when it is not active.

This is an example of bare-bones Lightline configuration, where Window Mode
will show an additional marker next to NORMAL (similar to the marker shown 
when PASTE is active)

```viml
let g:lightline = {}
let g:lightline.active = {}
let g:lightline.active.left = [
    \    [ 'mode', 'paste', 'window_mode' ],
    \    [ 'readonly', 'filename', 'modified' ],
    \]
let g:lightline.component_function = {
    \     'window_mode': 'window_mode#lightlineComponent',
    \}
```
