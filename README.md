### Some features of this Vim configuration:
 * automatically source local .vimrc/.exrc file from current directory
   - set secure to restrict what can be put into local .vimrc/.exrc
 * .viminfo files are local
   - saved in current directory
 * Minimum window size (width & height) is zero
 * No statusline plugins: they all slow down vim considerably

### Maps
 * Do not redefine standard Vim maps (except Vim anti-patterns, almost)
 * Do not redefine any vim-obsession mappings
 * Define additional (not mapped originally) mappings in g..., z..., Z...,
     [..., ]..., <A-...>
 * Leader is ',', LocalLeader is `'_'`

### Commands defined in .bashrc
 * e -- start gvim normally
 * r -- start gvim in RO mode
   - set nomodifiable readonly
 * S -- start gvim in "session" mode
   - local .session.vim file is automatically loaded/saved on start/exit.

Compile vim:
------------

```shell
sudo apt build-dep vim-gtk3
cd $HOME/src/vim
make clean
make distclean
rm -f auto/config.cache
git clean -fxd
git checkout master
git checkout -- .
git pull --ff-only
./configure \
	--enable-option-checking \
	--enable-fail-if-missing \
	--prefix=$HOME/.local \
	--with-features=huge \
	--enable-luainterp=dynamic \
	--disable-mzschemeinterp \
	--enable-perlinterp=no \
	--enable-pythoninterp=no \
	--enable-python3interp=dynamic \
	--with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
	--enable-tclinterp=no \
	--enable-rubyinterp=no \
	--enable-cscope \
	--disable-workshop \
	--enable-netbeans \
	--enable-channel \
	--enable-terminal \
	--enable-autoservername \
	--enable-multibyte \
	--enable-gui=gtk3 \
	--enable-largefile \
	--enable-acl \
	--disable-nls \
	--with-modified-by='Leonid V. Fedorenchik' \
	--with-compiledby='Leonid V. Fedorenchik'
make
make install
```
