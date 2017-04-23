" Required Vim: {{{
" version: >= 8.0
" --with-features=huge --enable-luainterp --with-luajit [--enable-perlinterp]
" --enable-pythoninterp [--enable-tclinterp] [--enable-rubyinterp]
" --enable-cscope --enable-gui=gnome2
" }}}
" External Dependencies Of This Vimrc: {{{
" ctags, [cscope], gtags, wmctrl, trash-cli,
" latest GNU GLOBAL (compile from source) (6.5.5 as of 30.10.2016)
" }}}
" Prevent Multiple Sourcing: {{{
if exists("g:loaded_home_vimrc")
	finish
endif
let g:loaded_home_vimrc = 1
" }}}
" Basics: {{{
set nocompatible
if &t_Co > 2 || has("gui_running")
	syntax on
endif
filetype plugin indent on       " enable detection, plugins and indenting in one step
" }}}
" GUI Settings: {{{
augroup GUI_Settings
	autocmd!
	autocmd GUIEnter * set lines=30 columns=100 guifont=Monospace\ 10
	" maximize GUI window
	autocmd GUIEnter * call system('wmctrl -i -b add,maximized_vert,maximized_horz -r '.v:windowid)
augroup END
" }}}
" Functions: {{{
function GuiTabLabel()
	let label = ''
	let bufnrlist = tabpagebuflist(v:lnum)

	" Add '+' if one of the buffers in the tab page is modified
	for bufnr in bufnrlist
		if getbufvar(bufnr, "&modified")
			let label = '+'
			break
		endif
	endfor

	" Append the number of windows in the tab page if more than one
	let wincount = tabpagewinnr(v:lnum, '$')
	if wincount > 1
		let label .= wincount
	endif
	if label != ''
		let label .= ' '
	endif

	" Append the buffer name
	return label . bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
endfunction
" }}}
" Colorscheme: {{{
" set colorscheme
" nice term dark themes: molokai, skittles_dark, wombat256, wombat256mod
" nice term light themes:
" nice gui dark themes:
" nice gui light themes: default
" term dark  schemes last evaluation: 2013 Dec 1
" term light schemes last evaluation: no
" gui  dark  schemes last evaluation: no
" gui  light schemes last evaluation: no
if has("gui_running")
	set background=dark
	colorscheme molokai
elseif &t_Co >= 256
	set background=dark
	colorscheme molokai
endif
" }}}
" Settings: {{{
set autoindent
set autoread
set backspace=
set backup
set backupdir=~/.vim/backup,~/tmp,~/,.,/var/tmp,/tmp
set belloff=all,error
set nobreakindent
set browsedir=buffer
let c_comment_strings=1
set cindent
set cinoptions=:0,l1,g0,t0,U1,j1,J1
set cinwords-=switch
set clipboard=autoselect,autoselectml,exclude:cons\|linux
set cmdheight=2
set colorcolumn=80,120,160,+1
set completeopt=menuone,preview
set confirm
set copyindent
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-
set cscoperelative
set cscopetag
set cscopetagorder=1
set cscopeverbose
set cursorbind
set nocursorcolumn
set nocursorline
set debug=beep
set nodelcombine
set dictionary+=/usr/share/dict/words
set dictionary+=/usr/share/dict/web2
set directory=~/.vim/swap//,~/tmp//,~//,.//,/var/tmp//,/tmp//
set display=lastline,uhex
set eadirection=
set noedcompatible
set emoji
set encoding=utf-8
set noequalalways
set noerrorbells
set esckeys
set noexpandtab
set exrc
set fileformats=unix,dos,mac
set nofileignorecase
set nofixendofline
set foldclose=all
set foldcolumn=0
set nofoldenable
set foldlevel=99
set foldlevelstart=99
set foldmethod=manual
set foldminlines=1
set foldnestmax=20
set foldopen=quickfix,tag,undo
set formatoptions+=1jMmn
set nofsync
set nogdefault
set grepprg=grep\ -nH\ $*
set guicursor+=a:blinkon0
if has("gui_gtk2")
	set guifont=Monospace\ 10
	set guifontwide=WenQuanYi\ Zen\ Hei\ 10
endif
set guioptions-=T
set guioptions-=r
set guioptions-=L
set guioptions+=cp
set guipty
set guitablabel=%{GuiTabLabel()}
"TODO: Add second (and further) lines with useful info
set guitabtooltip=%{GuiTabLabel()}
set helpheight=10
set helplang=en
set hidden
set nohlsearch
set history=1000
set icon
set iconstring=
set noignorecase
if has('reltime')
	set incsearch
endif
set infercase
set joinspaces
set keymodel=
set keywordprg=:Man
set langmenu=none
if has('langmap') && exists('+langremap')
	set nolangremap
endif
set laststatus=2
set lazyredraw
set nolinebreak
set list
set listchars=tab:»\ ,trail:·,extends:>,precedes:<
set magic
set matchpairs+=<:>
set nomodeline
if has('mouse')
	set mouse=ar
endif
set mousehide
set nrformats+=alpha
set nonumber
set patchmode=".orig"
set path+=./../include,./../../include
set pumheight=10
set norelativenumber
set ruler
set scrolljump=2
set scrolloff=2
set secure
set sessionoptions=buffers,folds,help,sesdir,slash,tabpages,unix,winsize
set shellcmdflag=-ic
set shiftround
set shiftwidth=8
set shortmess+=Im
set showbreak=>>>>>>>>
set showfulltag
set showcmd             " display incomplete commands
set noshowmatch		" do not jump to open paren/bracket/brace when close one is typed
set noshowmode		" do not show mode since PowerLine shows it
set showmode		" always show mode we're currently in
set showtabline=2
set sidescroll=30
set sidescrolloff=2
set signcolumn=yes
set smartindent
set smarttab
set softtabstop=8
set nostartofline
set swapfile
set swapsync=
set switchbuf=useopen	" reuse opened buffers from quickfix window
set tabstop=8
set tags-=./TAGS
set tags-=TAGS
set tags+=$HOME/.vim/systags
set termencoding=utf-8
set textwidth=80
set thesaurus+=$HOME/.vim/thes/mobythes.txt
set notildeop
set timeout
set timeoutlen=400
set title
set titlestring=%F\ %a%r%m\ -\ VIM
set ttimeout
set ttimeoutlen=10
set ttyfast
set t_vb=		" do not visual blink
if has('persistent_undo')
	set undodir=$HOME/.vim/undo
	set undofile
endif
set undolevels=1000
set updatetime=1000
set viminfo='100,<50,s10,h,!,c,r/tmp,r/var,n$PWD/.viminfo
set virtualedit=block
set visualbell		" do not visual blink
set whichwrap=
set wildmenu		" make tab completion like bash
set wildmode=list:longest	" show tab completion menu and complete longest match
set wildoptions=tagfile
set nowrap
set nowrapscan
set writebackup
" }}}
" Leaders: {{{
" should be before any mappings: it affects only mappings below
let mapleader=","
let maplocalleader=","	" <leader> local to buffer
" }}}
" Mappings: {{{
" Modes: {{{
" Normal (Command) Mode: nmap
" Visual Mode: xmap, vmap
" Select Mode: smap, vmap
" Insert Mode: imap
" Command-line (Cmdline) Mode: cmap
" Ex Mode:
" Operator-pending Mode: omap
" Replace Mode:
" Virtual Replace Mode:
" Insert Normal Mode:
" Insert Visual Mode:
" Insert Select Mode:
" }}}
" Keys Limitations: {{{
" Shifted cursor keys are not available on all terminals (but available in GUI).
" Cannot distinguish between <Tab> and <C-I>.
" Cannot distinguish between <Enter> and <C-M>.
" }}}
" Go To Normal Mode: {{{
" <C-\><C-N>
" <C-\><C-G>
" i_<C-@>
" i_<c-c>
" i_<C-[>
" }}}
" Insert Mode: {{{
" Subcommands & submodes: Ctrl-G, Ctrl-R, Ctrl-R Ctrl-R, Ctrl-X, Ctrl-\.
" Tmp normal mode: Ctrl-O
" Tmp command-line mode: Ctrl-R =
" Ctrl-X - insert-mode completion.
inoremap <silent> <C-@> <esc>
inoremap <silent> <C-A> <esc>
inoremap <silent> <C-B> <esc>
inoremap <silent> <C-E> <C-R>=pumvisible() ? "\<lt>C-E>" : "\<lt>Esc>"<CR>
inoremap <silent> <C-J> <esc>
inoremap <silent> <C-Q> <esc>
inoremap <silent> <C-R><C-D> <Esc>:Unite register<CR>
inoremap <silent> <C-Y> <C-R>=pumvisible() ? "\<lt>C-Y>" : "\<lt>Esc>"<CR>
inoremap <silent> <C-Z> <esc>
inoremap <silent> <leader>w <C-O>:up<CR>
" }}}
" Normal (Command) Mode: {{{
" Subcommands & submodes: Ctrl-W, Ctrl-W g, Ctrl-\, ", ', <, =, >, @, F, T, Z,
" [, ], `, d, f, g, m, q, t, z.
" ', ` -- jumping to marks/markers
" [, ] -- moving through text objects
" z    -- folding & moving lines in window
" Normal Keys: {{{
nnoremap <silent> <BS> <nop>
nnoremap <silent> <CR> <nop>
nnoremap <silent> <F2> :call ToggleFileExplorer()<CR>
nnoremap <silent> <F4> :VimShellPop<CR><ESC>
nnoremap <silent> <F8> :call Marvim_search()<CR>
nnoremap <silent> <F10> :TagbarToggle<CR>
nnoremap <silent> <F12> :UndotreeToggle<CR>
nnoremap <silent> <Space> za
nnoremap <silent> ` '
nnoremap <silent> ' `
" swap semicolon and colon seems very weird:
cnoremap <expr> ; getcmdpos() == 1 ? '<C-F>A' : ';'
silent! nunmap ;
"silent! nunmap :
nnoremap <unique> ; :
"nnoremap <unique> : ;
nnoremap <silent> / /\v
" yank entire buffer with gy
nnoremap <silent> gy :%y+<CR>
nnoremap <silent> h F
nnoremap <silent> l f
nnoremap <silent> n :<C-u>if !mark#SearchNext(0)<Bar>execute 'normal! nzv'<Bar>endif<CR>
nnoremap <silent> N :<C-u>if !mark#SearchNext(1)<Bar>execute 'normal! Nzv'<Bar>endif<CR>
nnoremap <silent> Y y$
nnoremap <silent> - <nop>
nnoremap <silent> + <nop>
nnoremap <silent> _ <nop>
nnoremap [1 :call signature#marker#Goto('prev', 1, v:count)
nnoremap ]1 :call signature#marker#Goto('next', 1, v:count)
nnoremap [2 :call signature#marker#Goto('prev', 2, v:count)
nnoremap ]2 :call signature#marker#Goto('next', 2, v:count)
nnoremap [3 :call signature#marker#Goto('prev', 3, v:count)
nnoremap ]3 :call signature#marker#Goto('next', 3, v:count)
nnoremap [4 :call signature#marker#Goto('prev', 4, v:count)
nnoremap ]4 :call signature#marker#Goto('next', 4, v:count)
nnoremap [5 :call signature#marker#Goto('prev', 5, v:count)
nnoremap ]5 :call signature#marker#Goto('next', 5, v:count)
nnoremap [6 :call signature#marker#Goto('prev', 6, v:count)
nnoremap ]6 :call signature#marker#Goto('next', 6, v:count)
nnoremap [7 :call signature#marker#Goto('prev', 7, v:count)
nnoremap ]7 :call signature#marker#Goto('next', 7, v:count)
nnoremap [8 :call signature#marker#Goto('prev', 8, v:count)
nnoremap ]8 :call signature#marker#Goto('next', 8, v:count)
nnoremap [9 :call signature#marker#Goto('prev', 9, v:count)
nnoremap ]9 :call signature#marker#Goto('next', 9, v:count)
nnoremap [0 :call signature#marker#Goto('prev', 0, v:count)
nnoremap ]0 :call signature#marker#Goto('next', 0, v:count)
" }}}
" Ctrl Key: {{{
nnoremap <silent> <C-@> <C-L>
nnoremap <silent> <C-F4> :VimShell -toggle<CR><ESC>
nnoremap <silent> <C-F12> :!ctags -R --sort=yes --excmd=p --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>
nnoremap <silent> <C-PageDown> :bnext<CR>
nnoremap <silent> <C-PageUp> :bprevious<CR>
nnoremap <silent> <C-]> :GtagsCursor<CR>
nnoremap <silent> <C-E> 2<C-E>
nnoremap <silent> <C-H> <C-W>h
nnoremap <silent> <C-J> <C-W>j
nnoremap <silent> <C-K> <C-W>k
nnoremap <silent> <C-L> <C-W>l
nnoremap <silent> <C-N> :UniteNext<CR>
nnoremap <silent> <C-P> :UnitePrevious<CR>
nnoremap <silent> <C-T> :tabnew<CR>
nnoremap <silent> <C-Y> 2<C-Y>
nnoremap <silent> <C-[> <nop>
nnoremap <silent> <C-_> <nop>
" }}}
" Shift Key: {{{
nnoremap <silent> <S-F4> :VimShell -split -split-command=vsplit\ +wincmd\\ l -toggle<CR><ESC>
nnoremap <silent> <S-F6> :Unite history/yank<CR>
nnoremap <silent> <S-F7> :Unite -start-insert file_rec/async<CR>
nnoremap <silent> <S-F8> :call Marvim_macro_store()<CR>
" }}}
" Alt Key: {{{
nnoremap <silent> <A-F4> :VimShell -split -split-command=tabnew -toggle<CR><ESC>
nnoremap <silent> <A-/> /\v\c
nnoremap <silent> <A-n> :cnewer<CR>
nnoremap <silent> <A-p> :colder<CR>
" }}}
" Ctrl Shift Key: {{{
" Ctrl-Shift modifier does not work neither in terminal nor in GUI.
" }}}
" Mouse Keys: {{{
" When remap mousekeys, they send key events to the active window.
" (by default, they send key events to the window under mouse cursor).
"nnoremap <silent> <ScrollWheelUp> 6<C-y>
"nnoremap <silent> <ScrollWheelDown> 6<C-e>
"nnoremap <silent> <S-ScrollWheelUp> <C-b>
"nnoremap <silent> <S-ScrollWheelDown> <C-f>
"nnoremap <silent> <C-ScrollWheelUp> <nop>
"nnoremap <silent> <C-ScrollWheelDown> <nop>
"nnoremap <silent> <A-ScrollWheelUp> <nop>
"nnoremap <silent> <A-ScrollWheelDown> <nop>
" }}}
" Leader: {{{
nnoremap <silent> <Leader><Space> :set hlsearch! hlsearch?<CR>
"nnoremap <silent> <Leader><Tab> <Nop>
"nnoremap <silent> <Leader><Enter> <Nop>
"nnoremap <silent> <Leader><Backspace> <Nop>
"nnoremap <silent> <Leader><Esc> <Nop>
"nnoremap <silent> <Leader>0 <Nop>
"nnoremap <silent> <Leader>1 <Nop>
"nnoremap <silent> <Leader>2 <Nop>
"nnoremap <silent> <Leader>3 <Nop>
"nnoremap <silent> <Leader>4 <Nop>
"nnoremap <silent> <Leader>5 <Nop>
"nnoremap <silent> <Leader>6 <Nop>
"nnoremap <silent> <Leader>7 <Nop>
"nnoremap <silent> <Leader>8 <Nop>
"nnoremap <silent> <Leader>9 <Nop>
nnoremap <silent> <Leader>a :e #<CR>
"nnoremap <silent> <Leader>A <Nop>
nnoremap <silent> <Leader>b :Unite -start-insert -smartcase -buffer-name=unite-buffer buffer<CR>
"nnoremap <silent> <Leader>B <Nop>
nnoremap <silent> <Leader>c :Unite -buffer-name=unite-quickfix quickfix<CR>
nnoremap <silent> <Leader>C :Unite -no-resize -no-split -buffer-name=unite-quickfix quickfix<CR>
"nnoremap <silent> <Leader>d <Nop>
"nnoremap <silent> <Leader>D <Nop>
nnoremap <silent> <Leader>e :Unite -start-insert -no-resize -no-split -buffer-name=unite-file file<CR>
"nnoremap <silent> <Leader>E <Nop>
nnoremap <silent> <Leader>f :Unite -start-insert -smartcase -buffer-name=unite-file file:`expand('%:p:h')`<CR>
nnoremap <silent> <Leader>F :Unite -start-insert -smartcase -buffer-name=unite-file file_rec/async<CR>
nnoremap <silent> <Leader>g :GtagsCursor<CR>:Unite -auto-preview -vertical-preview -buffer-name=unite-quickfix quickfix<CR>
nnoremap <silent> <Leader>G :Unite -auto-preview -vertical-preview -buffer-name=unite-gtags gtags/context<CR>
nnoremap <silent> <Leader>h :VimShellPop -buffer-name=vimshell<CR>
"nnoremap <silent> <Leader>H <Nop>
nnoremap <silent> <Leader>i :Unite -start-insert -buffer-name=unite-line<cr>
"nnoremap <silent> <Leader>I <Nop>
nnoremap <silent> <Leader>j :Unite -start-insert -smartcase -buffer-name=unite-jump jump<CR>
"nnoremap <silent> <Leader>J <Nop>
nnoremap <silent> <Leader>k :Unite -start-insert -smartcase -buffer-name=unite-mark mark<CR>
"nnoremap <silent> <Leader>K <Nop>
nnoremap <silent> <Leader>l :Unite -buffer-name=unite-location-list location_list<CR>
"nnoremap <silent> <Leader>L <Nop>
nmap <silent> <unique> <Leader>m <Plug>MarkSet
"nnoremap <silent> <Leader>M <Nop>
nmap <silent> <Leader>n <Plug>MarkSearchCurrentNext
nmap <silent> <Leader>N <Plug>MarkSearchCurrentPrev
nnoremap <silent> <Leader>o :Unite -start-insert -smartcase outline<CR>
nnoremap <silent> <Leader>O :Unite -no-resize -no-split -smartcase outline<CR>
nnoremap <silent> <Leader>p :Unite -auto-preview -vertical-preview -buffer-name=unite-quickfix quickfix<CR>
nnoremap <silent> <Leader>P :Unite -no-resize -no-split -auto-preview -vertical-preview -buffer-name=unite-quickfix quickfix<CR>
nnoremap <silent> <Leader>q :confirm q<CR>
nnoremap <silent> <Leader>Q :confirm qa<CR>
nmap <silent> <Leader>r <Plug>MarkRegex
nnoremap <silent> <Leader>R :Unite -start-insert -smartcase -buffer-name=unite-register register<CR>
nnoremap <silent> <Leader>s :Unite -start-insert -smartcase -buffer-name=unite-grep grep:%::`expand('<cword>')`<CR>
nnoremap <silent> <Leader>S :Scratch<CR>
nnoremap <silent> <Leader>t :Unite -start-insert -smartcase -buffer-name=unite-tab tab<CR>
"nnoremap <silent> <Leader>T <Nop>
nnoremap <silent> <Leader>u :UniteResume<CR>
"nnoremap <silent> <Leader>U <Nop>
"nnoremap <silent> <Leader>v <Nop>
"nnoremap <silent> <Leader>V <Nop>
nnoremap <silent> <Leader>w :confirm up<CR>
nnoremap <silent> <Leader>W :confirm wa<CR>
"nnoremap <silent> <Leader>x <Nop>
"nnoremap <silent> <Leader>X <Nop>
"nnoremap <silent> <Leader>y <Nop>
"nnoremap <silent> <Leader>Y <Nop>
"nnoremap <silent> <Leader>z <Nop>
"nnoremap <silent> <Leader>Z <Nop>
nnoremap <silent> <Leader>; ,
"nnoremap <silent> <Leader>: <Nop>
"nnoremap <silent> <Leader>, <Nop>
"nnoremap <silent> <Leader>< <Nop>
"nnoremap <silent> <Leader>. <Nop>
"nnoremap <silent> <Leader>> <Nop>
nmap <silent> <Leader>/ <Plug>MarkSearchAnyNext
nmap <silent> <Leader>? <Plug>MarkSearchAnyPrev
"nnoremap <silent> <Leader>@ <Nop>
"nnoremap <silent> <Leader>^ <Nop>
"nnoremap <silent> <Leader>\ <Nop>
"nnoremap <silent> <Leader><Bar> <Nop>
nnoremap <silent> <Leader>- :Unite -start-insert -smartcase -buffer-name=unite-window window:no-current<CR>
nnoremap <silent> <Leader>_ :Unite -start-insert -smartcase -buffer-name=unite-window window/gui<CR>
"nnoremap <silent> <Leader>' <Nop>
"nnoremap <silent> <Leader>" <Nop>
"nnoremap <silent> <Leader>$ <Nop>
"nnoremap <silent> <Leader>~ <Nop>
"nnoremap <silent> <Leader>& <Nop>
"nnoremap <silent> <Leader>% <Nop>
"nnoremap <silent> <Leader># :e #<CR>
"nnoremap <silent> <Leader>` <Nop>
"nnoremap <silent> <Leader>[ <Nop>
"nnoremap <silent> <Leader>{ <Nop>
"nnoremap <silent> <Leader>} <Nop>
"nnoremap <silent> <Leader>( <Nop>
"nnoremap <silent> <Leader>= <Nop>
"nnoremap <silent> <Leader>* <Nop>
"nnoremap <silent> <Leader>) <Nop>
"nnoremap <silent> <Leader>+ <Nop>
"nnoremap <silent> <Leader>] <Nop>
"nnoremap <silent> <Leader>! <Nop>
"nnoremap <silent> <Leader><Up> <Nop>
"nnoremap <silent> <Leader><Down> <Nop>
"nnoremap <silent> <Leader><Left> <Nop>
"nnoremap <silent> <Leader><Right> <Nop>
"nnoremap <silent> <Leader><Home> <Nop>
"nnoremap <silent> <Leader><End> <Nop>
"nnoremap <silent> <Leader><PageUp> <Nop>
"nnoremap <silent> <Leader><PageDown> <Nop>
"nnoremap <silent> <Leader><Insert> <Nop>
"nnoremap <silent> <Leader><Delete> <Nop>
"nnoremap <silent> <Leader><F1> <Nop>
"nnoremap <silent> <Leader><F2> <Nop>
"nnoremap <silent> <Leader><F3> <Nop>
"nnoremap <silent> <Leader><F4> <Nop>
"nnoremap <silent> <Leader><F5> <Nop>
"nnoremap <silent> <Leader><F6> <Nop>
"nnoremap <silent> <Leader><F7> <Nop>
"nnoremap <silent> <Leader><F8> <Nop>
"nnoremap <silent> <Leader><F9> <Nop>
"nnoremap <silent> <Leader><F10> <Nop>
"nnoremap <silent> <Leader><F11> <Nop>
"nnoremap <silent> <Leader><F12> <Nop>
" }}}
" }}}
" Visual Mode: {{{
" Subcommands & submodes: Ctrl-\, a, g, i.
vnoremap <Space> za
vnoremap ; :
vnoremap / /\v
" make p in visual mode replace selected text with the yank register
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
vmap <silent> <Leader>m <Plug>MarkSet
vmap <silent> <Leader>r <Plug>MarkRegex
xnoremap X y/<C-R>"<CR>
" }}}
" Command-line (Cmdline) Mode: {{{
" Subcommands & submodes: Ctrl-R, Ctrl-\
"cnoremap <C-@> <nop>
"cnoremap <C-O> <nop>
"cnoremap <silent> %% <C-R>=expand('%:h').'/'<cr>
cnoremap <silent> w!! w !sudo tee % >/dev/null
" }}}
" }}}
" Abbreviations: {{{
inoreabbrev lf leonid@fedorenchik.ru
inoreabbrev gm leonidsbox@gmail.com
inoreabbrev cc Copyright (C) 2016 Leonid V. Fedorenchik
inoreabbrev ssig -- <cr>Leonid V. Fedorenchik
inoreabbrev fr fedorenchik.ru
inoreabbrev teh the
inoreabbrev rr REVIEW:
cnoreabbrev unite Unite
cnoreabbrev calc Calc
cnoreabbrev gblame Gblame
cnoreabbrev gt Gtags
cnoreabbrev gtags Gtags
cnoreabbrev grep grep -IarFw
" }}}
" Autocommands: {{{
if has("autocmd")
	augroup filetypes
		autocmd!
		if exists("+omnifunc")
			autocmd Filetype * if &omnifunc == "" |
						\   setlocal omnifunc=syntaxcomplete#Complete |
						\ endif
		endif
		autocmd FileType cpp setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
		autocmd FileType html setlocal clipboard=autoselect,autoselectml,html,exclude:cons\|linux
		autocmd FileType sh setlocal formatoptions-=t formatoptions+=croql
		autocmd FileType text setlocal textwidth=72 linebreak breakindent
		autocmd FileType text setlocal complete+=k,s
		autocmd FileType vim setlocal foldenable foldmethod=marker foldlevelstart=0 foldlevel=0
		autocmd CmdWinEnter : noremap <buffer> <S-CR> <CR>q:
		autocmd CmdWinEnter / noremap <buffer> <S-CR> <CR>q/
		autocmd CmdWinEnter ? noremap <buffer> <S-CR> <CR>q?
	augroup END
	augroup vimrcEx
		autocmd!
		" When editing a file, always jump to the last known cursor position.
		" Don't do it when the position is invalid or when inside an event handler
		" (happens when dropping a file on gvim).
		" Also don't do it when the mark is in the first line, that is the default
		" position when opening a file.
		autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
					\   exe "normal! g`\"" |
					\ endif
	augroup END
	augroup auto_sessions
		autocmd!
		autocmd VimLeavePre * if !&readonly |
					\   mksession! .session.vim |
					\ endif
	augroup END
endif
" }}}
" Commands: {{{
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
	command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
				\ | wincmd p | diffthis
endif
if !exists(":EasyModeOn")
	command EasyModeOn call StandardMoveMappings()
endif
if !exists(":EasyModeOff")
	command EasyModeOff call EfficientMoveMappings()
endif
" }}}
" Functions: {{{
function! FoldColumnToggle()
	if &foldcolumn
		setlocal foldcolumn=0
	else
		setlocal foldcolumn=4
	endif
endfunction
function! StandardMoveMappings()
	nunmap <silent> h
	nunmap <silent> l
	nunmap <silent> <down>
	nunmap <silent> <left>
	nunmap <silent> <right>
	nunmap <silent> <up>
endfunction
function! EfficientMoveMappings()
	nnoremap <silent> h F
	nnoremap <silent> l f
	nnoremap <silent> <down> <nop>
	nnoremap <silent> <left> <nop>
	nnoremap <silent> <right> <nop>
	nnoremap <silent> <up> <nop>
endfunction
function! ToggleFileExplorer()
	try
		Rexplore
	catch
		Explore
	endtry
endfunction
" }}}
"  Standard Plugins: {{{
" Plugin: man {{{
runtime! ftplugin/man.vim
" }}}
" Plugin: netrw {{{
"augroup VimStartup
"	autocmd!
"	autocmd VimEnter * if expand("%") == "" | e . | endif
"augroup END
let g:netrw_fastbrowse = 2
"let g:netrw_keepdir = 0
let g:netrw_liststyle = 2
let g:netrw_special_syntax = 1
" }}}
" }}}
" $VIMRUNTIME/pack/dist/opt/ Plugins: {{{
" Plugin: matchit {{{
if has('syntax') && has('eval')
	packadd! matchit
endif
" }}}
" Plugin: editexisting {{{
packadd! editexisting
" }}}
" }}}
" 3rd Party Plugins: {{{
" Plugin: airline {{{
let g:airline#extensions#bufferline#enabled = 0
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#syntastic#enabled = 0
let g:airline#extensions#virtualenv#enabled = 0
let g:airline#extensions#eclim#enabled = 0
let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#enabled = 0
" }}}
" Plugin: conque-gdb {{{
let g:ConqueGdb_Leader = '\'
" }}}
" Plugin: conque-term {{{
let g:ConqueTerm_ReadUnfocused = 1
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_ShowBell = 1
let g:ConqueTerm_SendFunctionKeys = 1
" }}}
" Plugin: gitv {{{
let g:Gitv_OpenHorizontal = 1
" }}}
" Plugin: gtags {{{
let g:Gtags_OpenQuickfixWindow = 0
" }}}
" Plugin: IndexedSearch {{{
let g:indexed_search_shortmess=1
" }}}
" Plugin: mark-2.8.5 {{{
let g:mwDefaultHighlightingPalette = 'maximum'
let g:mwAutoLoadMarks = 0
let g:mwAutoSaveMarks = 0
" }}}
" Plugin: neocomplete {{{
let g:neocomplete#enable_at_startup = 1
" }}}
" Plugin: signature {{{
let g:SignatureMap = {
        \ 'Leader'             :  "m",
        \ 'PlaceNextMark'      :  "m,",
        \ 'ToggleMarkAtLine'   :  "m.",
        \ 'PurgeMarksAtLine'   :  "m-",
        \ 'DeleteMark'         :  "dm",
        \ 'PurgeMarks'         :  "m<Space>",
        \ 'PurgeMarkers'       :  "m<BS>",
        \ 'GotoNextLineAlpha'  :  "'+",
        \ 'GotoPrevLineAlpha'  :  "'-",
        \ 'GotoNextSpotAlpha'  :  "`+",
        \ 'GotoPrevSpotAlpha'  :  "`-",
        \ 'GotoNextLineByPos'  :  "]'",
        \ 'GotoPrevLineByPos'  :  "['",
        \ 'GotoNextSpotByPos'  :  "]`",
        \ 'GotoPrevSpotByPos'  :  "[`",
        \ 'GotoNextMarker'     :  "]-",
        \ 'GotoPrevMarker'     :  "[-",
        \ 'GotoNextMarkerAny'  :  "]=",
        \ 'GotoPrevMarkerAny'  :  "[=",
        \ 'ListBufferMarks'    :  "m/",
        \ 'ListBufferMarkers'  :  "m?"
        \ }
let g:SignatureIncludeMarkers = '*()}+{][!='
let g:SignatureWrapJumps = 0
let g:SignatureMarkTextHLDynamic = 1
let g:SignatureMarkerTextHLDynamic = 1
let g:SignatureDeleteConfirmation = 1
let g:SignaturePurgeConfirmation = 1
let g:SignatureForceMarkPlacement = 1
let g:SignatureForceMarkerPlacement = 1
" }}}
" Plugin: tagbar {{{
let g:tagbar_sort=0			" do not sort tags by name
let g:tagbar_compact=1			" compact layout
let g:tagbar_autofocus=0		" do not move cursor to Tagbar
" }}}
" Plugin: undotree {{{
let g:undotree_WindowLayout=4
" }}}
" Plugin: unite {{{
"let g:unite_source_history_yank_enable = 1
" }}}
" Plugin: unite-quickfix {{{
let g:unite_quickfix_filename_is_pathshorten = 0
let g:unite_quickfix_is_multiline = 0
" }}}
" Plugin: vimshell {{{
let g:vimshell_prompt = '$ '
let g:vimshell_scrollback_limit = 10000
" }}}
" }}}
