" Required Vim: {{{
" version: >= 8.0
" --with-features=huge --enable-luainterp --with-luajit [--enable-perlinterp]
" --enable-pythoninterp [--enable-tclinterp] [--enable-rubyinterp]
" --enable-cscope --enable-gui=gnome2
" }}}
" External Dependencies Of This Vimrc: {{{
" ctags (Universal Ctags), [cscope], gtags (GNU Global), wmctrl, trash-cli,
" latest GNU GLOBAL (compile from source) (6.5.7 as of 25.05.2017)
" }}}
" TODO: {{{
" Patches for vim:
" * Max number of quickfix lists change to 100 (from 10)
" * tag stack size change to 200 (from 20)
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
filetype plugin indent on
" }}}
" GUI Settings: {{{
augroup GUI_Settings
	autocmd!
	autocmd GUIEnter * set lines=300 columns=1000 guifont=Monospace\ 10
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
" Avoid the ":ptag" when there is no word under the cursor, and a few other
" things. Opens the tag under cursor in Preview window.
function PreviewWord()
	if &previewwindow
		return
	endif
	silent! wincmd P
	if &previewwindow
		wincmd p
		return
	endif
	let w = expand("<cword>")
	if w =~ '\a'
		try
			exe "ptag " . w
		catch
			return
		endtry
		silent! wincmd P
		if &previewwindow
			if has("folding")
				silent! .foldopen
			endif
			wincmd p
		endif
	endif
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
set cindent
set cinoptions=:0,l1,g0,t0,U1,j1,J1
set cinwords-=switch
set clipboard=autoselect,autoselectml,exclude:cons\|linux
set cmdheight=2
set colorcolumn=80,120,160,+0
set completeopt=menuone,preview
set confirm
set copyindent
set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-,a-
set cscoperelative
set nocscopetag
set cscopetagorder=1
set cscopeverbose
set nocursorbind
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
set foldclose=
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
set guioptions-=t
set guioptions-=T
set guioptions-=r
set guioptions-=L
set guioptions+=cp
set guipty
set guitablabel&
"TODO: Add second (and further) lines with useful info
set guitabtooltip=%{GuiTabLabel()}
set helpheight=8
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
set menuitems=40
set mkspellmem=900000,3000,800
set modeline
set modelines=5
set more
if has('mouse')
	set mouse=n
endif
set nomousefocus
set mousehide
set mousemodel=popup_setpos
set mouseshape+=o:question,c:pencil,e:hand2
set nrformats+=alpha
set nonumber
set opendevice&
set operatorfunc&
set patchmode=".orig"
set path+=/usr/include/c++/6,./include,./../include,./../../include,**
set nopreserveindent
set previewheight=7
set printfont=Monospace\ 10
set prompt
set pumheight=10
set redrawtime=1000
set norelativenumber
set ruler
set rulerformat&
set scroll&
set noscrollbind
set scrolljump=2
set scrolloff=2
set scrollopt=ver,hor,jump
set secure
set sessionoptions=blank,buffers,folds,help,localoptions,sesdir,slash,tabpages,unix,winsize
set shiftround
set shiftwidth=8
set shortmess+=mrwsIcF
set showbreak=>>>>>>>>
set showcmd
set showfulltag
set noshowmatch
set showmode
set showtabline=2
set sidescroll=30
set sidescrolloff=2
set signcolumn=yes
set smartcase
set smartindent
set smarttab
set softtabstop=8
set spell&
set spellcapcheck&
set spellfile&
set spelllang+=cjk
set spellsuggest&
set nosplitbelow
set nosplitright
set nostartofline
set suffixes-=.h
set swapfile
set swapsync=
set switchbuf=newtab
set synmaxcol=300
set tabline&
set tabstop=8
set tagbsearch
set tagcase=followscs
set taglength&
set tagrelative
set tags-=./TAGS
set tags-=TAGS
set tags+=$HOME/.vim/ctags,$HOME/.vim/cpptags,$HOME/.vim/linuxtags
set tagstack
set termguicolors
set textwidth=80
set thesaurus+=$HOME/.vim/thes/mobythes.txt
set notildeop
set notimeout
set timeoutlen=400
set title
set titlelen&
set titleold=$PWD
set titlestring=%F\ %a%r%m\ -\ VIM
set ttimeout
set ttimeoutlen=10
set toolbar&
set toolbariconsize&
set ttyfast
set ttymouse&
if has('persistent_undo')
	set undodir=$HOME/.vim/undo,.
	set undofile
endif
set undolevels=1000
set undoreload&
set updatecount&
set updatetime=1000
set verbose&
set verbosefile&
set viewdir&
set viewoptions=cursor,folds,localoptions,slash,unix
set viminfo=!,%50,'100,<50,c,f1,h,r/tmp,r/var,r/mnt,r/media,s10,n$PWD/.viminfo
set virtualedit=block
set novisualbell
set warn
set noweirdinvert
set whichwrap=
set wildchar&
set wildcharm&
set wildignore&
set nowildignorecase
set wildmenu
set wildmode=full
set wildoptions=tagfile
set winaltkeys=no
set winheight&
set winfixheight&
set winfixwidth&
set winminheight=0
set winminwidth=0
set winwidth&
set nowrap
set wrapmargin&
set nowrapscan
set nowriteany
set writebackup
" }}}
" Leaders: {{{
" should be before any mappings: it affects only mappings below
let mapleader=","
let maplocalleader="\\"
" }}}
" Mappings: {{{
" Keys Limitations: {{{
" Shifted cursor keys are not available on all terminals (but available in GUI).
" Cannot distinguish between <Tab> and <C-I>.
" Cannot distinguish between <Enter> and <C-M>.
" }}}
" Insert Mode: {{{
" Standard Vim Mappings i_^: @ A C D E F G H I J K L M N O P Q R
" S T U V W X Y Z [ \ ] ^ _
" Available To Remap: @ A B E J L M Q S Y Z _ <F2>..<F12>
inoremap <silent> <C-@> <Nop>
inoremap <silent> <C-A> <Nop>
inoremap <silent> <C-B> <Nop>
inoremap <silent> <C-E> <C-R>=pumvisible() ? "\<lt>C-E>" : "\<lt>Esc>"<CR>
" Insert Mode i_^G: {{{
" Standard Vim Mappings: j ^J k ^K u U <Up> <Down>
" }}}
"inoremap <silent> <C-J> <Nop>
inoremap <silent> <C-L> <Nop>
"inoremap <silent> <C-M> <Nop>
inoremap <silent> <C-Q> <Nop>
inoremap <silent> <C-R><C-D> <Esc>:Unite register<CR>
inoremap <silent> <C-S> <Nop>
" Insert Mode i_^X: {{{
" Standard Vim Mappings ^: D E F I K L N O P S T U V Y ]
" Available To Map: A B C G H J M Q R W X Z
" }}}
inoremap <silent> <C-Y> <C-R>=pumvisible() ? "\<lt>C-Y>" : "\<lt>Esc>"<CR>
inoremap <silent> <C-Z> <Nop>
" Insert Mode i_<A-...>: {{{
" }}}
" Insert Mode: <leader>...: {{{
inoremap <silent> <leader>w <C-O>:up<CR>
"}}}
" }}}
" Normal (Command) Mode: {{{
" Metakeys: <BS> <Tab> <CR> <Esc> <Space> <Del> <Up> <Down> <Left> <Right>
" <F1>..<F12> <Insert> <Home> <End> <PageUp> <PageDown>
" Commands Expecting Text Objects: d < = >
" Commands Expecting Marks: m ' `
" Commands Expecting Registers: q " @
" Standard Text Objects: b B p s t w W [ { } ( ) ] ` < > ' "
" Normal Keys: {{{
" Available To Remap: f F h j k l Q s S t T U + ; : , \ - _ <BS> <CR> <Space>
" <Del> <Up> <Down> <Left> <Right> <F2>..<F12> <Insert> <Home> <End> <PageUp>
" <PageDown>
" TODO: 1. Make f F t T search multiline
" TODO: 2. Make h l behave like f F but input 2 characters
" TODO: 3. Make j k behave like f F but input 3 characters
nnoremap <silent> <BS> <Nop>
nnoremap <silent> <CR> :GtagsCursor<CR>
nnoremap <silent> <F2> :call ToggleFileExplorer()<CR>
nnoremap <silent> <F4> :VimShellPop<CR><ESC>
nnoremap <silent> <S-F4> :VimShell -split -split-command=vsplit\ +wincmd\\ l -toggle<CR><ESC>
nnoremap <silent> <F8> <Nop>
nnoremap <silent> <F9> :TagbarToggle<CR>
nnoremap <silent> <F10> <Nop>
nnoremap <silent> <F12> :UndotreeToggle<CR>
nnoremap <silent> <Space> <Nop>
nnoremap <silent> ` '
nnoremap <silent> ' `
nnoremap <unique> ; :
nnoremap <unique> : q:i
" Normal Keys: g...: {{{
" Standard Vim Mappings: a ^A d D e E f F g ^G h H ^H i I j J k m n N o p P q Q
" r R s t T u U v V w x 0 8 ] ^] # $ & ' ` * + , - ; < ? ^ _ @ ~ <Down> <End>
" <Home> <LeftMouse> <MiddleMouse> <RightMouse> <Up>
" Available To Map: A b B c C G K l L M O S W X y Y z Z 1 2 3 4 5 6 7 9 % [ { }
" ( = ) ! : > . / \ | "
nnoremap <silent> gA :args<CR>
nnoremap <silent> gc :changes<CR>
nnoremap <silent> gC :undolist<CR>
nnoremap <silent> gl :llist<CR>
nnoremap <silent> gL :lhistory<CR>
nnoremap <silent> gO :jumps<CR>
nnoremap <silent> gq :clist<CR>
nnoremap <silent> gQ :chistory<CR>
nnoremap <silent> gS ^vg_y:execute @@<CR>:echo 'Sourced: ' . @@<CR>
nnoremap <silent> gt :tselect<CR>
nnoremap <silent> gT :tags<CR>
nnoremap <silent> gW Q
nnoremap <silent> gX gQ
nnoremap <silent> gy :%y+<CR>
nnoremap <silent> gz :buffers<CR>
nnoremap <silent> gZ :tabs<CR>
nnoremap <silent> g" :registers<CR>
nnoremap <silent> g. :marks<CR>
nnoremap <silent> g: :history<CR>
" }}}
nnoremap <silent> h F
nnoremap <silent> l f
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> Q gq
nnoremap <silent> Y y$
" Normal Keys: z...: {{{
" Standard Vim Mappings: a A b c C d D e E f F g G h H i j k l L m M n N o O r R
" s t v w W x X z ^ + - . = <Left> <Right> <CR>
" Available To Map: B I J K p P q Q S T u U V y Y Z $ ~ & % [ { } ( * ) ] ! # `
" ; : , < > / ? @ \ | _ ' "
" }}}
" Normal Keys: Z...: {{{
" Standard Vim Mappings: Q Z
nnoremap <silent> Zc :copen<CR>
nnoremap <silent> ZC :cclose<CR>
nnoremap <silent> Zl :lopen<CR>
nnoremap <silent> ZL :lclose<CR>
nnoremap <silent> Zn :tabnext<CR>
nnoremap <silent> ZN :tablast<CR>
nnoremap <silent> Zp :tabprevious<CR>
nnoremap <silent> ZP :tabfirst<CR>
" }}}
nnoremap <silent> - <Nop>
nnoremap <silent> + <Nop>
nnoremap <silent> _ <Nop>
" Normal Keys: [...: {{{
" Standard Vim Mappings: c d D ^D f i I ^I m p P s z # ' ( * ` / [ ] {
" <MiddleMouse>
" Vim Unimpaired Mappings: a A b B e f l L ^L n o q Q ^Q t T u x y <Space>
" Available To Remap: C E F g G h H j J k K M N O r R S U v V w W X Y Z 0 1 2 3
" 4 5 6 7 8 9 $ ~ & % } = ) + ! ; : , < . > ? @ ^ \ | - _ "
nnoremap [1 :call signature#marker#Goto('prev', 1, v:count)<CR>
nnoremap [2 :call signature#marker#Goto('prev', 2, v:count)<CR>
nnoremap [3 :call signature#marker#Goto('prev', 3, v:count)<CR>
nnoremap [4 :call signature#marker#Goto('prev', 4, v:count)<CR>
nnoremap [5 :call signature#marker#Goto('prev', 5, v:count)<CR>
nnoremap [6 :call signature#marker#Goto('prev', 6, v:count)<CR>
nnoremap [7 :call signature#marker#Goto('prev', 7, v:count)<CR>
nnoremap [8 :call signature#marker#Goto('prev', 8, v:count)<CR>
nnoremap [9 :call signature#marker#Goto('prev', 9, v:count)<CR>
nnoremap [0 :call signature#marker#Goto('prev', 0, v:count)<CR>
" }}}
" Normal Keys: ]...: {{{
" Standard Vim Mappings: c d D ^D f i I ^I m p P s z # ' ) * ` / [ ] }
" <MiddleMouse>
" Vim Unimpaired Mappings: a A b B e f l L ^L n o q Q ^Q t T u x y <Space>
" Available To Remap: C E F g G h H j J k K M N O r R S U v V w W X Y Z 0 1 2 3
" 4 5 6 7 8 9 $ ~ & % } = ) + ! ; : , < . > ? @ ^ \ | - _ "
nnoremap ]1 :call signature#marker#Goto('next', 1, v:count)<CR>
nnoremap ]2 :call signature#marker#Goto('next', 2, v:count)<CR>
nnoremap ]3 :call signature#marker#Goto('next', 3, v:count)<CR>
nnoremap ]4 :call signature#marker#Goto('next', 4, v:count)<CR>
nnoremap ]5 :call signature#marker#Goto('next', 5, v:count)<CR>
nnoremap ]6 :call signature#marker#Goto('next', 6, v:count)<CR>
nnoremap ]7 :call signature#marker#Goto('next', 7, v:count)<CR>
nnoremap ]8 :call signature#marker#Goto('next', 8, v:count)<CR>
nnoremap ]9 :call signature#marker#Goto('next', 9, v:count)<CR>
nnoremap ]0 :call signature#marker#Goto('next', 0, v:count)<CR>
" }}}
" }}}
" Ctrl Key: {{{
" XXX: Ctrl-Shift modifier does not work neither in terminal nor in GUI.
" Standard Vim Mappings: A C G I M O R T V W X Z [ \ ] ^
" Available To Map: B D E F H J K L N P Q S U Y @ _
nnoremap <silent> <C-@> <C-L>
nnoremap <silent> <C-F4> :VimShell -toggle<CR><ESC>
nnoremap <silent> <C-F12> :!ctags -R --sort=yes --excmd=p --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>
nnoremap <silent> <C-PageDown> :bnext<CR>
nnoremap <silent> <C-PageUp> :bprevious<CR>
nnoremap <silent> <C-E> 2<C-E>
nnoremap <silent> <C-G> :tag<CR>
nnoremap <silent> <C-H> <C-W>h
nnoremap <silent> <C-J> <C-W>j
nnoremap <silent> <C-K> <C-W>k
nnoremap <silent> <C-L> <C-W>l
" Ctrl Key: <C-W>...: {{{
" Ctrl Key: <C-W>g...: {{{
" }}}
" }}}
nnoremap <silent> <C-Y> 2<C-Y>
nnoremap <silent> <C-_> <Nop>
" Ctrl Key: <C-\>...: {{{
" }}}
" }}}
" Alt Key: {{{
nnoremap <silent> <A-F4> :VimShell -split -split-command=tabnew -toggle<CR><ESC>
nnoremap <silent> <A-/> /\v\c
nnoremap <silent> <A-L> :lolder<CR>
nnoremap <silent> <A-l> :lnewer<CR>
nnoremap <silent> <A-Q> :colder<CR>
nnoremap <silent> <A-q> :cnewer<CR>
" }}}
" Mouse Keys: {{{
" Mousekeys: <LeftMouse> <MiddleMouse> <RightMouse> <X1Mouse> <X2Mouse>
" <ScrollWheelDown> <ScrollWheelUp> <ScrollWheelLeft> <ScrollWheelRight>
" When remap mousekeys, they send key events to the active window.
" (by default, they send key events to the window under mouse cursor).
"nnoremap <silent> <ScrollWheelUp> 6<C-y>
"nnoremap <silent> <ScrollWheelDown> 6<C-e>
"nnoremap <silent> <S-ScrollWheelUp> <C-b>
"nnoremap <silent> <S-ScrollWheelDown> <C-f>
"nnoremap <silent> <C-ScrollWheelUp> <Nop>
"nnoremap <silent> <C-ScrollWheelDown> <Nop>
"nnoremap <silent> <A-ScrollWheelUp> <Nop>
"nnoremap <silent> <A-ScrollWheelDown> <Nop>
" }}}
" Leader: {{{
" Available To Map: a A b B c C d D e E f F g G h H i I j J k K l L m M n N o O
" p P q Q r R s S t T u U v V w W x X y Y z Z 0 1 2 3 4 5 6 7 8 9
" $ ~ & % [ { } ( = * ) + ] ! # ` ; : , < . > / ? @ ^ \ | - _ ' "
" <BS> <Tab> <CR> <Esc> <Space> <Del> <Up> <Down> <Left> <Right> <F1>..<F12>
" <Insert> <Home> <End> <PageUp> <PageDown>
nnoremap <silent> <Leader><Space> :set hlsearch! hlsearch?<CR>
nnoremap <silent> <Leader>a :e #<CR>
nnoremap <silent> <Leader>b :Unite -start-insert -smartcase -buffer-name=unite-buffer buffer<CR>
nnoremap <silent> <Leader>c :Unite -buffer-name=unite-quickfix quickfix<CR>
nnoremap <silent> <Leader>C :Unite -no-resize -no-split -buffer-name=unite-quickfix quickfix<CR>
nnoremap <silent> <Leader>e :Unite -start-insert -no-resize -no-split -buffer-name=unite-file file<CR>
nnoremap <silent> <Leader>f :Unite -start-insert -smartcase -buffer-name=unite-file file:`expand('%:p:h')`<CR>
nnoremap <silent> <Leader>F :Unite -start-insert -smartcase -buffer-name=unite-file file_rec/async<CR>
nnoremap <silent> <Leader>g :GtagsCursor<CR>:Unite -auto-preview -vertical-preview -buffer-name=unite-quickfix quickfix<CR>
nnoremap <silent> <Leader>G :Unite -auto-preview -vertical-preview -buffer-name=unite-gtags gtags/context<CR>
nnoremap <silent> <Leader>h :VimShellPop -buffer-name=vimshell<CR>
nnoremap <silent> <Leader>i :Unite -start-insert -buffer-name=unite-line<CR>
nnoremap <silent> <Leader>j :Unite -start-insert -smartcase -buffer-name=unite-jump jump<CR>
nnoremap <silent> <Leader>k :Unite -start-insert -smartcase -buffer-name=unite-mark mark<CR>
nnoremap <silent> <Leader>l :Unite -buffer-name=unite-location-list location_list<CR>
nmap <silent> <unique> <Leader>m <Plug>MarkSet
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
nnoremap <silent> <Leader>u :UniteResume<CR>
nnoremap <silent> <Leader>w :confirm up<CR>
nnoremap <silent> <Leader>W :confirm wa<CR>
nnoremap <silent> <Leader>; ,
nmap <silent> <Leader>/ <Plug>MarkSearchAnyNext
nmap <silent> <Leader>? <Plug>MarkSearchAnyPrev
nnoremap <silent> <Leader>- :Unite -start-insert -smartcase -buffer-name=unite-window window:no-current<CR>
nnoremap <silent> <Leader>_ :Unite -start-insert -smartcase -buffer-name=unite-window window/gui<CR>
" }}}
" }}}
" Visual Mode: {{{
" Subcommands & submodes: Ctrl-\, a, g, i.
xnoremap <Space> za
xnoremap ; :
xnoremap / /\v
xnoremap gy "+y
" make p in visual mode replace selected text with the yank register
xnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
vmap <silent> <Leader>m <Plug>MarkSet
vmap <silent> <Leader>r <Plug>MarkRegex
xnoremap X y/<C-R>"<CR>
" }}}
" Command-line (Cmdline) Mode: {{{
" Subcommands & submodes: Ctrl-R, Ctrl-\
"cnoremap <C-@> <Nop>
"cnoremap <C-O> <Nop>
"cnoremap <silent> %% <C-R>=expand('%:h').'/'<cr>
cnoremap <silent> w!! w !sudo tee % >/dev/null
" }}}
" }}}
" Abbreviations: {{{
inoreabbrev @lf leonid@fedorenchik.ru
inoreabbrev @gm leonidsbox@gmail.com
inoreabbrev @cc Copyright (C) 2016 Leonid V. Fedorenchik
inoreabbrev @sig -- <CR>Leonid V. Fedorenchik
inoreabbrev teh the
cnoreabbrev unite Unite
cnoreabbrev calc Calc
cnoreabbrev gblame Gblame
cnoreabbrev gtags Gtags
cnoreabbrev grep grep -IarFw
cnoreabbrev split rightbelow split
cnoreabbrev vsplit rightbelow vsplit
" }}}
" Autocommands: {{{
if has("autocmd")
augroup autocommands
autocmd!
if exists("+omnifunc")
	autocmd Filetype * if &omnifunc == "" |
				\   setlocal omnifunc=syntaxcomplete#Complete |
				\ endif
endif
autocmd FileType c setlocal foldmethod=syntax
autocmd FileType cpp setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
autocmd FileType html setlocal clipboard=autoselect,autoselectml,html,exclude:cons\|linux
autocmd FileType sh setlocal formatoptions-=t formatoptions+=croql
autocmd FileType text setlocal textwidth=72 linebreak breakindent
autocmd FileType text setlocal complete+=k,s
autocmd FileType vim setlocal foldenable foldmethod=marker foldlevelstart=0 foldlevel=0
autocmd CmdWinEnter : noremap <buffer> <S-CR> <CR>q:
autocmd CmdWinEnter / noremap <buffer> <S-CR> <CR>q/
autocmd CmdWinEnter ? noremap <buffer> <S-CR> <CR>q?
autocmd CursorHold *.[ch] nested call PreviewWord()
autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
			\   exe "normal! g`\"" |
			\ endif
autocmd BufReadPost *.log normal G
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
	nnoremap <silent> <down> <Nop>
	nnoremap <silent> <left> <Nop>
	nnoremap <silent> <right> <Nop>
	nnoremap <silent> <up> <Nop>
endfunction
function! ToggleFileExplorer()
	try
		Rexplore
	catch
		Explore
	endtry
endfunction
" }}}
" $VIMRUNTIME/ {{{
" ftplugin/man.vim {{{
runtime! ftplugin/man.vim
" }}}
" pack/dist/opt/editexisting/ {{{
packadd! editexisting
" }}}
" pack/dist/opt/matchit/ {{{
if has('syntax') && has('eval')
	packadd! matchit
endif
" }}}
" plugin/netrwPlugin.vim {{{
"augroup VimStartup
"	autocmd!
"	autocmd VimEnter * if expand("%") == "" | e . | endif
"augroup END
let g:netrw_fastbrowse = 2
"let g:netrw_keepdir = 0
let g:netrw_liststyle = 2
let g:netrw_special_syntax = 1
" }}}
" plugin/tohtml.vim {{{
let g:html_number_lines = 1
let g:html_use_css = 1
let g:html_ignore_conceal = 0
let g:html_dynamic_folds = 1
let g:html_no_foldcolumn = 0
let g:html_prevent_copy = "fn"
let g:html_hover_unfold = 0
let g:html_pre_wrap = 1
" }}}
" syntax/c.vim {{{
let c_gnu = 1
let c_comment_strings = 1
let c_space_errors = 1
" }}}
" syntax/doxygen.vim {{{
let g:load_doxygen_syntax = 1
let g:doxygen_enhanced_color = 1
" }}}
" syntax/lisp.vim {{{
let g:lisp_rainbow = 1
" }}}
" syntax/perl.vim {{{
let perl_fold = 1
let perl_fold_blocks = 1
let perl_nofold_subs = 1
let perl_fold_anonymous_subs = 1
let perl_nofold_packages = 1
" }}}
" syntax/python.vim {{{
let python_space_error_highlight = 1
let python_highlight_all = 1
" }}}
" syntax/readline.vim {{{
let readline_has_bash = 1
" }}}
" syntax/ruby.vim {{{
let ruby_operators = 1
let ruby_space_errors = 1
let ruby_fold = 1
let ruby_spellcheck_strings = 1
" }}}
" syntax/sed.vim {{{
let highlight_sedtabs = 1
" }}}
" syntax/sh.vim {{{
let g:is_bash = 1
let g:sh_fold_enabled = 7
" }}}
" syntax/vim.vim {{{
let g:vimsyn_embed = "lmpPrt"
let g:vimsyn_folding = "aflmpPrt"
" }}}
" syntax/xml.vim {{{
let g:xml_syntax_folding = 1
" }}}
" }}}
" External Plugins: {{{
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
" Plugin: gitv {{{
let g:Gitv_OpenHorizontal = 1
" }}}
" Plugin: gtags {{{
let g:Gtags_OpenQuickfixWindow = 0
" }}}
" Plugin: mark-2.8.5 {{{
let g:mwDefaultHighlightingPalette = 'maximum'
let g:mwAutoLoadMarks = 0
let g:mwAutoSaveMarks = 0
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
let g:tagbar_type_make = { 'kinds':[ 'm:macros', 't:targets' ] }
" }}}
" Plugin: undotree {{{
let g:undotree_WindowLayout=4
" }}}
" Plugin: vim-cpp-enhanced-highlight {{{
let g:cpp_no_function_highlight=1
" }}}
" Plugin: vimshell {{{
let g:vimshell_prompt = '$ '
let g:vimshell_scrollback_limit = 10000
" }}}
" }}}
