# Verbosity

Provides mappings and commands for easily enabling verbose mode while working
in VIM, printing the verbose output on newly created log files in a temporary 
directory. 

This is especially useful for debugging just a few actions or auto commands 
while working inside the editor.

The default mappings (inspired by the style of
[Unimpaired](https://github.com/tpope/vim-unimpaired)) and commands are:

| Mapping | Command               | Description                                           |
|---------|-----------------------|-------------------------------------------------------|
| `[oV`   | `:VerbosityEnable`    | Enables verbose mode                                  |
| `]oV`   | `:VerbosityDisable`   | Disables verbose mode                                 |
| `=oV`   | `:VerbosityToggle`    | Toggles verbose mode                                  |
| `goV`   | `:VerbosityOpenLast`  | Opens last/current verbose output in a vertical split |
| `doV`   | `:VerbosityDeleteAll` | Deletes all Verbosity generated log files             |

Enable and toggle mappings and commands can be prefixed with a number (e.g.
`12[oV` or `:3VerbosityEnable`) to set a specific verbose level. 
This level will be treated as the new default level for the rest of the
session.


## Installation

### [VimPlug](https://github.com/junegunn/vim-plug)

Add `Plug 'mtdl9/vim-verbosity'` to your `~/.vimrc` and run `PlugInstall`.

### [Vundle](https://github.com/gmarik/Vundle.vim)

Add `Plugin 'mtdl9/vim-verbosity'` to your `~/.vimrc` and run `PluginInstall`.

### [Pathogen](https://github.com/tpope/vim-pathogen)

    $ git clone https://github.com/mtdl9/vim-verbosity ~/.vim/bundle/vim-verbosity

### Manual Install

Copy the contents of the `plugin` folder in its respective ~/.vim/\* counterpart.


## Configuration

By default Verbosity will create verbose log files inside a temporary
directory, created using the `tempname()` VIM function.
If you want to write the files in a specific directory, you can customize the
following variable:

```viml
let g:verbosity_log_directory = '/tmp'
```

The default verbose level used if none is specified is 10, you can overwrite
that with the following variable:

```viml
let g:verbosity_default_level = 5
```

You can overwrite the key mappings using the provided \<Plug\> maps, for example if
you do not need the `gV` mapping in Vim you can use:

```viml
nmap gVe <Plug>(verbosity-enable)
nmap gVd <Plug>(verbosity-disable)
nmap gVt <Plug>(verbosity-toggle)
nmap gVo <Plug>(verbosity-open-last)
nmap gVr <Plug>(verbosity-delete-all)
```
