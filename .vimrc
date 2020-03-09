" Required Vim: {{{
" version: >= 8.0
" --with-features=huge --enable-luainterp --with-luajit [--enable-perlinterp]
" --enable-pythoninterp [--enable-tclinterp] [--enable-rubyinterp]
" --enable-cscope --enable-gui=gtk3
" }}}
" External Dependencies Of This Vimrc: {{{
" ctags (Universal Ctags), [cscope], gtags (GNU Global), wmctrl, trash-cli,
" pylint3
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
if has('autocmd')
	filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
	syntax on
endif
" }}}
" Start Vim Server: {{{
if empty(v:servername) && exists('*remote_startserver')
	call remote_startserver('GVIM')
endif
" }}}
" Functions: {{{
function! GuiTabLabel() abort
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
function! PreviewWord() abort
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
function! ListMonths() abort
	let l:line = getline(".")
	let l:last_word_start_idx = match(l:line, '\w*$')
	let l:last_word = matchstr(l:line, '\w*$')
	let l:months = ['January', 'February', 'March', 'April', 'May', 'June',
				\ 'July', 'August', 'September',
				\ 'October', 'November', 'December']
	call filter(l:months, 'v:val =~ "^' . l:last_word . '"')
	echom 'l:last_word_start_idx = ' . l:last_word_start_idx
	echom 'l:last_word = ' . l:last_word
	echom 'l:months = ' . string(l:months)
	call complete(l:last_word_start_idx + 1, l:months)
	return ''
endfunction
function! SetupCommandAlias(input, output) abort
	exec 'cabbrev <expr> '.a:input
				\ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:input.'")'
				\ .'? ("'.a:output.'") : ("'.a:input.'"))'
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
highlight lCursor guifg=NONE guibg=Cyan
" }}}
" Keymap: {{{
set keymap=russian-dvp
" }}}
" Settings: {{{
set autoindent
set autoread
set backspace=start
set nobackup
set backupdir=/tmp
set ballooneval
set balloonevalterm
set belloff=all,error,ctrlg
set nobomb
set nobreakindent
set browsedir=buffer
set cindent
set cinoptions=:0,l1,g0,N-s,E-s,t0,U1,j1,J1
set cinwords-=switch
set clipboard=autoselect,autoselectml,exclude:cons\|linux
set cmdheight=2
set colorcolumn=80,120,+0
if has("gui_running")
	set columns=90
endif
set complete-=i
set completeopt=menuone,preview,noinsert,noselect
set confirm
set copyindent
set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-,a-
set cscoperelative
set nocscopetag
set cscopetagorder=0
set cscopeverbose
"set nocursorbind
"set nocursorcolumn
"set nocursorline
set debug=beep
set nodelcombine
set dictionary+=/usr/share/dict/words
set dictionary+=/usr/share/dict/web2
set diffopt=filler,context:12,iwhite,vertical,foldcolumn:2,internal,indent-heuristic,algorithm:histogram
set directory=~/.vim/swap//,~/tmp//,.//,~//,/var/tmp//,/tmp//
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
set fillchars=stl:\ ,stlnc:\ ,vert:\ ,fold:\ ,diff:\ 
set nofixendofline
set foldcolumn=4
set foldlevel=20
set foldlevelstart=20
set foldminlines=0
set foldopen=quickfix,tag,undo
set formatoptions+=1jMmn
set nofsync
set nogdefault
set grepprg=grep\ -nH\ $*
"TODO: Colorize cursor in different modes.
"set guicursor+=a:blinkon0
if has("gui_gtk2")
	set guifont=Ubuntu\ Mono\ 11,Monospace\ 9
	"set guifontwide=WenQuanYi\ Zen\ Hei\ 10
endif
set guiheadroom=0
set guioptions=aAceigpk
set guipty
set guitablabel=%!flagship#tablabel()
"TODO: Add second (and further) lines with useful info
set guitabtooltip=%{GuiTabLabel()}
set helpheight=8
set helplang=en
set hidden
set nohlsearch
set history=10000
set icon
set iconstring=
set noignorecase
set iminsert=0
set imsearch=-1
if has('reltime')
	set incsearch
endif
set infercase
set isfname+=@-@
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
if has("gui_running")
	set lines=28
endif
set list
set listchars=tab:»\ ,trail:·,extends:>,precedes:<,nbsp:+
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
set path+=.,,./include,../include,../*/include,*/include,*,../*,/usr/include,**
set nopreserveindent
set previewheight=3
set printencoding=utf-8
set printexpr&
set printfont=Ubuntu\ Mono\ 11,Monospace\ 9
set printmbcharset=ISO10646
set printmbfont=r:WenQuanYi\ Zen\ Hei,a:yes
set prompt
set pumheight=10
set pyxversion=3
set redrawtime=1000
set regexpengine=1
set norelativenumber
set ruler
set rulerformat&
set scroll&
set noscrollbind
set scrolljump=2
set scrolloff=2
set scrollopt=ver,hor,jump
set secure
set sessionoptions=blank,buffers,globals,help,localoptions,resize,sesdir,slash,tabpages,terminal,unix,winpos,winsize
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
	set shell=/bin/bash
endif
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
set sidescrolloff=1
set signcolumn=yes
set smartcase
set smartindent
set smarttab
set softtabstop=8
set spellfile=$HOME/src/homerc/.vim/spell/personal.utf-8.add,/tmp/tmp.utf-8.add
set spelllang+=cjk
set spellsuggest=fast,10
set nosplitbelow
set nosplitright
set nostartofline
set suffixes-=.h
set noswapfile
set swapsync=
set switchbuf=
set synmaxcol=1000
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
	set t_Co=16
endif
set tabline&
set tabpagemax=50
set tabstop=8
set tagbsearch
set tagcase=followscs
set taglength&
set tagrelative
set tags=tags;
set tagstack
set termguicolors
set termwinsize=""
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
set viewoptions=cursor,localoptions,slash,unix
set viminfo=!,%50,'100,<50,c,f1,h,r/tmp,r/var,r/mnt,r/media,s10,n$PWD/.viminfo
set virtualedit=block
set novisualbell
set warn
set whichwrap=
set wildchar=<C-E>
set wildcharm=<C-Z>
let &wildignore=netrw_gitignore#Hide()
set nowildignorecase
set wildmenu
set wildmode=longest:full,list:full
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
set nowritebackup
" }}}
" Leaders: {{{
" should be before any mappings: it affects only mappings below
let mapleader=","
let maplocalleader="_"
" }}}
" Mappings: {{{
" Keys Limitations: {{{
" Shifted cursor keys are not available on all terminals (but available in GUI).
" Cannot distinguish between <Tab> and <C-I>.
" Cannot distinguish between <Enter> and <C-M>.
" Remap <CR> is too troublesome (inconvenient in quickfix and plugins), so
" do not do it.
" }}}
" Alt: make <A-...> work in terminal {{{
let c=' '
while c <= '~'
	if (c != ' ') && (c != '"') && (c != '>') && (c != '[') && (c != '\')
				\ && (c != ']') && (c != '|')
		exec "set <A-".c.">=\e".c
		exec "map \e".c." <A-".c.">"
		exec "map! \e".c." <A-".c.">"
	endif
	let c = nr2char(1+char2nr(c))
endwhile
" }}}
" Normal (Command) Mode: {{{
" Keys Description: {{{
" Metakeys: <BS> <Tab> <CR> <Esc> <Space> <Del> <Up> <Down> <Left> <Right>
" <F1>..<F12> <Insert> <Home> <End> <PageUp> <PageDown>
" Commands Expecting Text Objects: c d < = >
" Commands Expecting Marks: m ' `
" Commands Expecting Registers: q " @
" Standard Text Objects: b B p s t w W [ { } ( ) ] ` < > ' "
" Submodes: <Space> g s S z Z - + [ ] <A-...> <C-...> <BS>
" }}}
" Normal Keys: {{{
" Normal Keys: {{{
" Available To Remap: f F h j k l Q s S t T U + ; : , \ - _ <BS> <Space>
" TODO: 1. Make f F t T search multiline
" TODO: 2. Make h l behave like f F but input 2 characters
" TODO: 3. Make j k behave like f F but input 3 characters
nnoremap ` '
nnoremap ' `
nnoremap _ :Unite -no-resize -no-split -buffer-name=unite-file fire_rec<CR>
nnoremap <unique> ; :
nnoremap <unique> : q:i
nmap + <C-W>
nnoremap G G$
nnoremap h F
nnoremap l f
nnoremap n nzz
nnoremap N Nzz
nnoremap Q gq
nnoremap Y y$
" }}}
" -----------: <Space>...: unite.vim mappings: {{{
" Available To Map: all
" 0123456789$&[{}(=*)+]!#;,./@\-'~%`:<>?^|_"
"                  +       +    +          +
" aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ
" + +++++++ +++++ + + ++++    +++++++++++ +   ++  +
nnoremap <Space> <Nop>
nmap <S-Space> <Space>
nnoremap <Space>. :UniteResume<CR>
nnoremap <Space>a :Unite -smartcase -buffer-name=unite-alternate -input=`expand('%:t:r')` -immediately file_rec<CR>
nnoremap <Space>b :Unite -start-insert -smartcase -buffer-name=unite-buffer buffer<CR>
nnoremap <Space>B :Unite -no-resize -no-split -buffer-name=unite-buffer buffer<CR>
nnoremap <Space>c :Unite -buffer-name=unite-gtags gtags/context<CR>
nnoremap <Space>C :Unite -auto-preview -vertical-preview -buffer-name=unite-gtags gtags/context<CR>
nnoremap <Space>d :Unite -buffer-name=unite-gtags gtags/def<CR>
nnoremap <Space>D :Unite -auto-preview -vertical-preview -buffer-name=unite-gtags gtags/def<CR>
nnoremap <Space>e :Unite -start-insert -no-resize -no-split -buffer-name=unite-file file<CR>
nnoremap <Space>f :Unite -start-insert -smartcase -buffer-name=unite-file file:`expand('%:p:h')`<CR>
nnoremap <Space>F :Unite -start-insert -smartcase -buffer-name=unite-file file_rec<CR>
nnoremap <Space>g :Unite -buffer-name=unite-gtags gtags/completion<CR>
nnoremap <Space>G :Unite -auto-preview -vertical-preview -buffer-name=unite-gtags gtags/completion<CR>
nnoremap <Space>h :VimShellPop -buffer-name=vimshell<CR>
nnoremap <Space>i :Unite -start-insert -buffer-name=unite-line<CR>
nnoremap <Space>j :Unite -smartcase -buffer-name=unite-jump jump<CR>
nnoremap <Space>k :Unite -start-insert -smartcase -buffer-name=unite-gtags gtags/file<CR>
nnoremap <Space>K :Unite -no-resize -no-split -smartcase -buffer-name=unite-gtags gtags/file<CR>
nnoremap <Space>l :Unite -buffer-name=unite-location-list location_list<CR>
nnoremap <Space>L :Unite -no-resize -no-split -buffer-name=unite-location-list location_list<CR>
nnoremap <Space>m :Unite -buffer-name=unime-mark mark<CR>
nnoremap <Space>o :Unite -start-insert -smartcase -buffer-name=unite-outline outline<CR>
nnoremap <Space>O :Unite -no-resize -no-split -smartcase -buffer-name=unite-outline outline<CR>
nnoremap <Space>p :Unite -auto-preview -vertical-preview -buffer-name=unite-quickfix quickfix<CR>
nnoremap <Space>P :Unite -no-resize -no-split -auto-preview -vertical-preview -buffer-name=unite-quickfix quickfix<CR>
nnoremap <Space>q :Unite -buffer-name=unite-quickfix quickfix<CR>
nnoremap <Space>Q :Unite -no-resize -no-split -buffer-name=unite-quickfix quickfix<CR>
nnoremap <Space>r :Unite -buffer-name=unite-gtags gtags/ref<CR>
nnoremap <Space>R :Unite -auto-preview -vertical-preview -buffer-name=unite-gtags gtags/ref<CR>
nnoremap <Space>s :Unite -start-insert -smartcase -buffer-name=unite-grep grep:%::`expand('<cword>')`<CR>
nnoremap <Space>S :Scratch<CR>
nnoremap <Space>t :Unite -start-insert -smartcase -buffer-name=unite-tab tab<CR>
nnoremap <Space>u :UniteResume<CR>
nnoremap <Space>w :Unite -start-insert -smartcase -buffer-name=unite-window window:all:no-current<CR>
nnoremap <Space>W :Unite -start-insert -smartcase -buffer-name=unite-window window/gui<CR>
nnoremap <Space>y :Unite -buffer-name=unite-yank history/yank<CR>
nnoremap <Space>' :Unite -start-insert -smartcase -buffer-name=unite-mark mark<CR>
nnoremap <Space>" :Unite -start-insert -smartcase -buffer-name=unite-register register<CR>
nnoremap <Space>* :Grepper -cword -noprompt<CR>
" }}}
" -----------: g...: vim status: {{{
" Standard Vim Mappings: a ^A d D e E f F g ^G h H ^H i I j J k m n N o p P q Q
" r R s t T u U v V w x 0 8 ] ^] # $ & ' ` * + , - ; < ? ^ _ @ ~ <Down> <End>
" <Home> <LeftMouse> <MiddleMouse> <RightMouse> <Up>
" vim-commentary: gc
" vim-capslock: gC
" Available To Map:
" A b B G K l L M O S W X y Y z Z 1 2 3 4 5 6 7 9 % [ { } ( = ) ! : > . / \ | "
" + + + +   + +   + + + + + + + +                                 +   +       +
nnoremap gA :args<CR>
nnoremap gb :tselect<CR>
nnoremap gB :tags<CR>
nnoremap gg gg0
nnoremap gG :changes<CR>
nnoremap gl :llist<CR>
nnoremap gL :lhistory<CR>
nnoremap gO :jumps<CR>
nnoremap gq :clist<CR>
nnoremap gQ :chistory<CR>
nmap gs <plug>(GrepperOperator)
nnoremap gS ^vg_y:execute @@<CR>:echo 'Sourced: ' . @@<CR>
nnoremap gW Q
nnoremap gX gQ
nnoremap gy :%y+<CR>
nnoremap gY :undolist<CR>
nnoremap gz :buffers<CR>
nnoremap gZ :tabs<CR>
nnoremap g: :history<CR>
nnoremap g. :marks<CR>
nnoremap g" :registers<CR>
nnoremap g= :tabnew<CR>
" }}}
" -----------: s...: source navigation (lsp): {{{
" Available To Map: all
nnoremap s <Nop>
nmap <silent> sd <Plug>(coc-definition)
nnoremap sg :Grepper -tool git<CR>
nnoremap sG :Grepper -tool rg<CR>
nmap <silent> si <Plug>(coc-implementation)
nmap <silent> sr <Plug>(coc-references)
nmap <silent> st <Plug>(coc-type-definition)
" }}}
" -----------: S...: open windows: {{{
" Available To Map: all
nnoremap S <Nop>
nnoremap SH :help<CR>
nnoremap SL :lopen<CR>
nnoremap SP :ptag<CR>
nnoremap SQ :botright copen<CR>
nnoremap ST :TagbarOpen<CR>
nnoremap SU :UndotreeShow<CR>
" }}}
" -----------: z...: {{{
" Standard Vim Mappings: a A b c C d D e E f F g G h H i j k l L m M n N o O r R
" s t u v w W x X z ^ + - . = <Left> <Right> <CR>
" Available To Map:
" B I J K p P q Q S T U V y Y Z $ ~ & % [ { } ( * ) ] ! # ` ; : , < > / ? @ \ | _ ' " 0 1 2 3 4 5 6 7 8 9
" }}}
" -----------: Z...: close windows: {{{
" Standard Vim Mappings: Q Z
" Available To Map: all
nnoremap ZH :helpclose<CR>
nnoremap ZL :lclose<CR>
nnoremap ZP :pclose<CR>
nnoremap ZQ :cclose<CR>
nnoremap ZT :TagbarClose<CR>
nnoremap ZU :UndotreeHide<CR>
" }}}
" -----------: [...: {{{
" Standard Vim Mappings: c d D ^D f i I ^I m p P s S z # ' ( * ` / [ ] {
" <MiddleMouse>
" Vim Unimpaired Mappings: a A b B e f l L ^L n o q Q ^Q t T u x y <Space>
" Available To Remap:
" C E F g G h H j J k K M N O r R U v V w W X Y Z 0 1 2 3 4 5 6 7 8 9 $ ~ & % } = ) + ! ; : , < . > ? @ ^ \ | - _ "
" +                         +           + +       + + + + + + + + + +
nnoremap [C :colder<CR>
nnoremap [O :lolder<CR>
nmap <silent> [w <Plug>(coc-diagnostic-prev)
nmap <silent> [W <Plug>(coc-diagnostic-prev-error)
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
" -----------: ]...: {{{
" Standard Vim Mappings: c d D ^D f i I ^I m p P s S z # ' ) * ` / [ ] }
" <MiddleMouse>
" Vim Unimpaired Mappings: a A b B e f l L ^L n o q Q ^Q t T u x y <Space>
" Available To Remap:
" C E F g G h H j J k K M N O r R U v V w W X Y Z 0 1 2 3 4 5 6 7 8 9 $ ~ & % } = ) + ! ; : , < . > ? @ ^ \ | - _ "
" +                         +           + +       + + + + + + + + + +
nnoremap ]C :cnewer<CR>
nnoremap ]O :lnewer<CR>
nmap <silent> ]w <Plug>(coc-diagnostic-next)
nmap <silent> ]W <Plug>(coc-diagnostic-next-error)
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
" Ctrl Key: tags, quickfix, location list navigation: {{{
" XXX: Ctrl-Shift modifier does not work neither in terminal nor in GUI.
" XXX: Uppercase/lowercase distinction is not available with <Ctrl-...>
" XXX: modifier.
" Standard Vim Mappings: A C G I M O Q R S T V W X Z [ \ ] ^
" Available To Map:
" B D E F H J K L N P Q S U Y 1 2 3 4 5 6 7 8 9 0 $ & { } ( = * ) + ! # ~ % ` ; : , < . > / ? @ | - _ ' " <BS> <Tab> <CR> <Esc> <Space>
" + + + + + + + + + +   + + +                                                                         +
nnoremap <C-'> :tag<CR>
nnoremap <C-b> :colder<CR>
nnoremap <C-d> :lnewer<CR>
nnoremap <C-e> :cnext<CR>
nnoremap <C-f> :cnewer<CR>
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-l> <C-W>l
nnoremap <C-n> :UniteNext<CR>
nnoremap <C-p> :UnitePrevious<CR>
nnoremap <C-s> :emenu <C-Z>
nnoremap <C-u> :lolder<CR>
" Ctrl Key: <C-W>...: {{{
nnoremap <C-W>V :botright vsplit<CR>
" Ctrl Key: <C-W>g...: {{{
" }}}
" }}}
nnoremap <C-y> :cprevious<CR>
nnoremap <C-_> <Nop>
" Ctrl Key: <C-\>...: {{{
" }}}
" }}}
" Alt Key: {{{
" Available To Map: all keys
nnoremap <A-Left> <C-o>
nnoremap <A-Right> <C-i>
nnoremap <A-f> :NERDTreeToggle<CR>
nnoremap <A-F> :silent call system('wmctrl -i -b toggle,fullscreen -r' . v:windowid)<CR>
nnoremap <A-m> :silent call system('wmctrl -i -b add,maximized_vert,maximized_horz -r' . v:windowid)<CR>
nnoremap <A-M> :silent call system('wmctrl -i -b remove,maximized_vert,maximized_horz -r' . v:windowid)<CR>
nnoremap <A-n> :<C-U><C-R><C-R>='let @'. v:register .' = '. string(getreg(v:register))<CR><C-F><Left>
nnoremap <A-q> :q<CR>
nnoremap <A-Q> :qa<CR>
nnoremap <A-r> :nohlsearch<CR>:diffupdate<CR>:syntax sync fromstart<CR><C-L>
nnoremap <A-s> :rightbelow terminal<CR>
nnoremap <A-t> :TagbarToggle<CR>
nnoremap <A-w> :confirm up<CR>
nnoremap <A-W> :wa<CR>
" }}}
" Leader: {{{
nmap <Leader>M <Plug>MarkToggle
nmap <Leader>N <Plug>MarkConfirmAllClear
" }}}
" Mouse Keys: {{{
" Mousekeys: <LeftMouse> <MiddleMouse> <RightMouse> <X1Mouse> <X2Mouse>
" <ScrollWheelDown> <ScrollWheelUp> <ScrollWheelLeft> <ScrollWheelRight>
" When remap mousekeys, they send key events to the active window.
" (by default, they send key events to the window under mouse cursor).
" }}}
" }}}
" Insert Mode: {{{
" Keys Description: {{{
" Standard Vim Mappings i_^: @ A C D E F G H I J K L M N O P Q R
" S T U V W X Y Z [ \ ] ^ _
" Available To Remap: @ A B E J L M Q S Y Z _
" Submodes: <A-...> <C-...> <C-X>... <C-G>...
" }}}
inoremap <Tab> <Esc>
inoremap <expr> <CR> pumvisible() ? "<C-Y><CR>" : "<CR>"
" Ctrl Key: {{{
inoremap <silent><expr> <C-Space> coc#refresh()
inoremap <C-@> <C-^>
inoremap <C-E> <C-R>=pumvisible() ? "\<lt>C-E>" : "\<lt>Esc>"<CR>
" Insert Mode i_^G: {{{
" Standard Vim Mappings: j ^J k ^K u U <Up> <Down>
" }}}
"inoremap <C-J> <Nop>
"inoremap <C-L> <Nop>
"inoremap <C-M> <Nop>
inoremap <C-Q> <Nop>
inoremap <C-S> <Nop>
" Insert Mode i_^X: {{{
" Standard Vim Mappings ^: D E F I K L N O P S T U V Y ]
" Unmappable: C
" Available To Map: A B G H J M Q R W X Z
" }}}
inoremap <C-Y> <C-R>=pumvisible() ? "\<lt>C-Y>" : "\<lt>Esc>"<CR>
inoremap <C-Z> <Nop>
inoremap <C-{> <Esc>
" }}}
" Alt Key: {{{
" Available to map:
" 0123456789$&[{}(=*)+]!#;,./@\-'~%`:<>?^|_"
"              ++  + ++                 +
" aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ
" +   +++ + +   + +   + + + + + +     + + + + + + +
inoremap <silent><expr> <A-Space> coc#refresh()
inoremap <A-*> <C-L>
inoremap <A-+> <PageDown>
inoremap <A-^> <PageUp>
inoremap <A-]> <C-X><C-]>
inoremap <A-{> <Up>
inoremap <A-}> <Down>
inoremap <A-a> <Esc>
inoremap <A-c> <C-X><C-N>
inoremap <A-C> <C-X><C-P>
inoremap <A-d> <C-X><C-D>
inoremap <expr> <A-e> pumvisible() ? "<C-E>" : "<Esc>u"
inoremap <A-f> <C-X><C-F>
inoremap <A-h> <BS>
inoremap <A-i> <C-X><C-I>
inoremap <A-k> <C-X><C-K>
inoremap <A-l> <C-X><C-L>
inoremap <A-m> <C-R>=ListMonths()<CR>
inoremap <A-n> <C-N>
inoremap <A-o> <C-X><C-O>
inoremap <A-p> <C-P>
inoremap <A-s> <C-X><C-S>
inoremap <A-t> <C-X><C-T>
inoremap <A-u> <C-X><C-U>
inoremap <A-v> <C-X><C-V>
inoremap <A-w> <C-O>:up<CR>
inoremap <A-x> <C-X>
inoremap <expr> <A-y> pumvisible() ? "<C-Y>" : "<Esc>"
" }}}
" }}}
" Visual Mode: {{{
" Subcommands & submodes: Ctrl-\, a, g, i.
vnoremap <Tab> <Esc>
xnoremap ; :
xnoremap / /\v
xmap gs <plug>(GrepperOperator)
xnoremap gy "+y
" make p in visual mode replace selected text with the yank register
xnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
vmap <Leader>m <Plug>MarkSet
vmap <Leader>r <Plug>MarkRegex
xnoremap X y/<C-R>"<CR>
xmap <Leader>* <Plug>MarkIWhiteSet
vnoremap / y/\V<C-R>"<CR>
vnoremap ? y/\V\<<C-R>"\><CR>
vnoremap * y/\V\<<C-R>"<CR>
vnoremap # y/\V<C-R>"\><CR>
" }}}
" Command-line (Cmdline) Mode: {{{
" Subcommands & submodes: Ctrl-R, Ctrl-\
cnoremap <Tab> <C-U><BS>
cnoremap <C-Y> <S-Tab>
" }}}
" Terminal Window: {{{
tnoremap <Esc> <C-w>N
tnoremap <C-j> <C-w><C-j>
tnoremap <C-k> <C-w><C-k>
tnoremap <C-l> <C-w><C-l>
tnoremap <C-h> <C-w><C-h>
if has('nvim')
	tnoremap <Esc> <C-\><C-n>
	tnoremap <C-v><Esc> <Esc>
endif
" }}}
" Operator-pending Mode: {{{
onoremap <Tab> <Esc>
" }}}
" Lang-Arg Mode: {{{
lnoremap <Tab> <Esc>
" }}}
" }}}
" Abbreviations: {{{
"inoreabbrev @lf leonid@fedorenchik.ru
"inoreabbrev @gm leonidsbox@gmail.com
"inoreabbrev @cc Copyright (C) 2016 Leonid V. Fedorenchik
"inoreabbrev @sig -- <CR>Leonid V. Fedorenchik
inoreabbrev teh the
cnoreabbrev calc Calc
cnoreabbrev f find
cnoreabbrev gblame Gblame
cnoreabbrev gtags Gtags
call SetupCommandAlias("grep", "GrepperGrep")
" }}}
" Autocommands: {{{
if has("autocmd")
augroup vimrc
autocmd!
autocmd BufReadPre *.asm let g:asmsyntax = "fasm"
autocmd BufReadPre *.[sS] let g:asmsyntax = "asm"
autocmd BufReadPost */linux/*.h setfiletype c
autocmd BufReadPost *.log normal G
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit' | exe "normal! g`\"" | endif
autocmd CmdWinEnter : noremap <buffer> <S-CR> <CR>q:
autocmd CmdWinEnter / noremap <buffer> <S-CR> <CR>q/
autocmd CmdWinEnter ? noremap <buffer> <S-CR> <CR>q?
autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
autocmd FileType c,cpp setlocal tags+=$HOME/.vim/ctags
autocmd FileType c,cpp setlocal tags+=$HOME/.vim/linuxtags
autocmd FileType c,cpp setlocal foldmethod=syntax
autocmd FileType c,cpp inoreabbrev #i #include 
autocmd FileType c,cpp inoreabbrev ,, <<
autocmd FileType c,cpp inoreabbrev ;b std::begin
autocmd FileType c,cpp inoreabbrev ;c std::cout
autocmd FileType c,cpp inoreabbrev ;e std::end
autocmd FileType c,cpp inoreabbrev ;m std::map
autocmd FileType c,cpp inoreabbrev ;s std::string
autocmd FileType c,cpp inoreabbrev ;v std::vector
autocmd FileType c,cpp inoremap ;; ::
autocmd FileType c,cpp nnoremap <silent> K :call CocAction('doHover')<CR>
autocmd FileType cpp setlocal path+=/usr/include/c++/7
autocmd FileType cpp setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
autocmd FileType cpp setlocal tags+=$HOME/.vim/cxxtags
autocmd FileType html setlocal clipboard=autoselect,autoselectml,html,exclude:cons\|linux
autocmd FileType dockerfile,python,qmake setlocal expandtab
autocmd FileType dockerfile,python,qmake setlocal tabstop=4
autocmd FileType dockerfile,python,qmake setlocal shiftwidth=4
autocmd FileType python setlocal makeprg=pylint3\ --reports=n\ --msg-template=\"{path}:{line}:\ {msg_id}\ {symbol},\ {obj}\ {msg}\"\ %:p
autocmd FileType python setlocal errorformat=%f:%l:\ %m
autocmd FileType sh setlocal formatoptions-=t formatoptions+=croql
autocmd FileType sh packadd shellmenu
autocmd FileType sh setlocal include=^\\s*\\%(\\.\\\|source\\)\\s
autocmd FileType sh setlocal define=\\<\\%(\\i\\+\\s*()\\)\\@=
autocmd FileType text setlocal textwidth=72 linebreak breakindent
autocmd FileType text setlocal complete+=k,s
autocmd FileType text,markdown setlocal spell
autocmd FileType vim setlocal foldmethod=marker foldlevelstart=0 foldlevel=0
if exists("+omnifunc")
	autocmd Filetype * if &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif
	autocmd Filetype * if &completefunc == "" | setlocal completefunc=syntaxcomplete#Complete | endif
endif
autocmd GUIEnter * set guifont=Ubuntu\ Mono\ 11,Monospace\ 9
autocmd SessionLoadPost * let g:vimrc_auto_session = 1
autocmd User Flags call Hoist("global", "%{&ignorecase ? '[IC]' : ''}")
autocmd User Flags call Hoist("global", "%{coc#status()}")
autocmd VimEnter * if exists('g:vimrc_auto_session') && filereadable('.session.vim') | source .session.vim | endif
autocmd VimEnter * if expand("%") != "" && getcwd() == expand("~") | cd %:h | endif
autocmd VimLeavePre * if exists('g:vimrc_auto_session') | mksession! .session.vim | endif
augroup END
endif
" }}}
" Commands: {{{
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
	command DiffOrig vertical new | setlocal buftype=nofile | r ++edit # |
				\ 0d_ | diffthis | wincmd p | diffthis
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
function! ToggleFileExplorer()
	try
		Rexplore
	catch
		Explore
	endtry
endfunction
" }}}
" Run Commands: {{{
if has("cscope")
	set nocscopeverbose
	if filereadable("cscope.out")
		cscope add cscope.out
	elseif $CSCOPE_DB != ""
		cscope add $CSCOPE_DB
	endif
	set cscopeverbose
endif
" }}}
" $VIMRUNTIME/ {{{
" filetype.vim {{{
let g:bash_is_sh = 1
" }}}
" ftplugin/changelog.vim {{{
runtime ftplugin/changelog.vim
" }}}
" ftplugin/man.vim {{{
runtime! ftplugin/man.vim
let g:ft_man_folding_enable = 1
" }}}
" ftplugin/spec.vim {{{
let spec_chglog_release_info = 1
" }}}
" ftplugin/sql.vim {{{
let g:ftplugin_sql_statements = 'create,alter'
" }}}
" ftplugin/tex.vim {{{
let g:tex_flavor = "latex"
" }}}
" menu.vim {{{
if !has("gui_running")
	let do_syntax_sel_menu = 1
	source $VIMRUNTIME/menu.vim
endif
let v:this_session = ".session.vim"
" }}}
" pack/dist/opt/justify/ {{{
packadd! justify
" }}}
" pack/dist/opt/matchit/ {{{
if has('syntax') && has('eval')
	packadd! matchit
endif
" }}}
" pack/dist/opt/termdebug/ {{{
packadd! termdebug
" }}}
" plugin/netrwPlugin.vim {{{
function! NFH_pdf(pdf) abort
  if executable("xdg-open")
    exe 'silent! !xdg-open ' . shellescape(a:pdf, 1) . ' &'
  else
    return 0
  endif
  return 1
endfunction
let g:netrw_alto = 1
let g:netrw_altv = 1
let g:netrw_banner = 0
let g:netrw_browsex_viewer = "-"
let g:netrw_dirhistmax = 100
let g:netrw_fastbrowse = 1
let g:netrw_hide = 1
let g:netrw_keepdir = 1
let g:netrw_list_hide = netrw_gitignore#Hide() . ',\(^\|\s\s\)\zs\.\S\+'
let g:netrw_liststyle = 2
"TODO: choose custom mapping for nnoremap xxx <Plug>NetrwReturn
"let g:netrw_retmap = 1
let g:netrw_silent = 1
let g:netrw_sizestyle = "H"
let g:netrw_sort_options = "i"
let g:netrw_special_syntax = 1
let g:netrw_use_errorwindow = 0
let g:netrw_usetab = 1
let g:netrw_winsize = -40
let g:netrw_wiw = 35
let g:netrw_xstrlen = 3
" }}}
" plugin/tarPlugin.vim {{{
let g:tar_secure = "--"
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
" spell/ {{{
let g:spell_clean_limit = 60 * 60
" }}}
" synmenu.vim {{{
if has("gui_running")
	let do_syntax_sel_menu = 1
	runtime! synmenu.vim
	aunmenu &Syntax.&Show\ File\ Types\ in\ Menu
endif
" }}}
" syntax/c.vim {{{
let c_gnu = 1
let c_comment_strings = 1
let c_space_errors = 1
" }}}
" syntax/diff.vim {{{
let g:diff_translations = 0
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
" syntax/synload.vim {{{
let g:load_doxygen_syntax = 1
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
" Plugin: asyncomplete.vim {{{
let g:asyncomplete_auto_completeopt = 0
" }}}
" Plugin: coc.nvim {{{
autocmd User CocNvimInit call coc#config('languageserver', {
			\ 'ccls': {
			\   "command": "ccls",
			\   "trace.server": "verbose",
			\   "filetypes": ["c", "cpp", "cuda", "objc", "objcpp"],
			\   "rootPatterns": [".ccls-root", "compile_commands.json", ".git/", ".ccls"],
			\   "initializationOptions": {
			\     "cache": {
			\       "directory": ".ccls-cache"
			\     }
			\   }
			\ }
			\})
" }}}
" Plugin: FastFold {{{
let g:fastfold_force = 1
" }}}
" Plugin: gtags {{{
let g:Gtags_OpenQuickfixWindow = 0
" }}}
" Plugin: gutentags {{{
let g:gutentags_modules = [ 'ctags', 'gtags_cscope' ]
let g:gutentags_generate_on_missing = 0
let g:gutentags_generate_on_new = 0
" }}}
" Plugin: nerdtree {{{
let NERDTreeWinSize = 41
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
" Plugin: undotree {{{
let g:undotree_WindowLayout=4
" }}}
" Plugin: vim-cpp-enhanced-highlight {{{
let g:cpp_no_function_highlight=1
" }}}
" Plugin: vim-grepper {{{
let g:grepper = {}
let g:grepper.tools = ['grep', 'git', 'rg']
" }}}
" Plugin: vim-lsp {{{
let g:lsp_highlight_references_enabled = 0
if executable('ccls')
	au User lsp_setup call lsp#register_server({
				\ 'name': 'ccls',
				\ 'cmd': {server_info->['ccls']},
				\ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'compile_commands.json'))},
				\ 'initialization_options': {},
				\ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
				\ })
endif
" }}}
" Plugin: vim-mark {{{
let g:mwPalettes = {
\	'mypalette': [
		\   { 'ctermbg':'Cyan',       'ctermfg':'Black', 'guibg':'#8CCBEA', 'guifg':'Black' },
		\   { 'ctermbg':'Green',      'ctermfg':'Black', 'guibg':'#A4E57E', 'guifg':'Black' },
		\   { 'ctermbg':'Yellow',     'ctermfg':'Black', 'guibg':'#FFDB72', 'guifg':'Black' },
		\   { 'ctermbg':'Magenta',    'ctermfg':'Black', 'guibg':'#FFB3FF', 'guifg':'Black' },
		\   { 'ctermbg':'Blue',       'ctermfg':'Black', 'guibg':'#9999FF', 'guifg':'Black' },
		\   { 'ctermfg':'Black',      'ctermbg':'202',   'guifg':'Black',   'guibg':'#ff5f00' },
		\   { 'ctermfg':'Black',      'ctermbg':'204',   'guifg':'Black',   'guibg':'#ff5f87' },
		\   { 'ctermfg':'Black',      'ctermbg':'209',   'guifg':'Black',   'guibg':'#ff875f' },
		\   { 'ctermfg':'Black',      'ctermbg':'212',   'guifg':'Black',   'guibg':'#ff87d7' },
		\   { 'ctermfg':'Black',      'ctermbg':'215',   'guifg':'Black',   'guibg':'#ffaf5f' },
		\   { 'ctermfg':'Black',      'ctermbg':'220',   'guifg':'Black',   'guibg':'#ffd700' },
		\   { 'ctermfg':'Black',      'ctermbg':'224',   'guifg':'Black',   'guibg':'#ffd7d7' },
		\   { 'ctermfg':'Black',      'ctermbg':'228',   'guifg':'Black',   'guibg':'#ffff87' },
		\   {                                            'guifg':'Black',   'guibg':'#b3dcff' },
		\   {                                            'guifg':'Black',   'guibg':'#99cbd6' },
		\   {                                            'guifg':'Black',   'guibg':'#7afff0' },
		\   {                                            'guifg':'Black',   'guibg':'#a6ffd2' },
		\   {                                            'guifg':'Black',   'guibg':'#a2de9e' },
		\   {                                            'guifg':'Black',   'guibg':'#bcff80' },
		\   {                                            'guifg':'Black',   'guibg':'#e7ff8c' },
		\   {                                            'guifg':'Black',   'guibg':'#f2e19d' },
		\   {                                            'guifg':'Black',   'guibg':'#ffcc73' },
		\   {                                            'guifg':'Black',   'guibg':'#f7af83' },
		\   {                                            'guifg':'Black',   'guibg':'#fcb9b1' },
		\   {                                            'guifg':'Black',   'guibg':'#ff8092' },
		\   {                                            'guifg':'Black',   'guibg':'#ff73bb' },
		\   {                                            'guifg':'Black',   'guibg':'#fc97ef' },
		\   {                                            'guifg':'Black',   'guibg':'#c8a3d9' },
		\   {                                            'guifg':'Black',   'guibg':'#ac98eb' },
		\   {                                            'guifg':'Black',   'guibg':'#6a6feb' },
		\   {                                            'guifg':'Black',   'guibg':'#8caeff' },
		\   { 'ctermfg':'Black',      'ctermbg':'166',   'guifg':'Black',   'guibg':'#d75f00' },
		\   { 'ctermfg':'Black',      'ctermbg':'169',   'guifg':'Black',   'guibg':'#d75faf' },
		\   { 'ctermfg':'Black',      'ctermbg':'174',   'guifg':'Black',   'guibg':'#d78787' },
		\   { 'ctermfg':'Black',      'ctermbg':'175',   'guifg':'Black',   'guibg':'#d787af' },
		\   { 'ctermfg':'Black',      'ctermbg':'186',   'guifg':'Black',   'guibg':'#d7d787' },
		\   { 'ctermfg':'Black',      'ctermbg':'190',   'guifg':'Black',   'guibg':'#d7ff00' },
		\   { 'ctermfg':'Black',      'ctermbg':'133',   'guifg':'Black',   'guibg':'#af5faf' },
		\   { 'ctermfg':'Black',      'ctermbg':'138',   'guifg':'Black',   'guibg':'#af8787' },
		\   { 'ctermfg':'Black',      'ctermbg':'142',   'guifg':'Black',   'guibg':'#afaf00' },
		\   { 'ctermfg':'Black',      'ctermbg':'152',   'guifg':'Black',   'guibg':'#afd7d7' },
		\   {                                            'guifg':'Black',   'guibg':'#70b9fa' },
		\   { 'ctermfg':'Black',      'ctermbg':'101',   'guifg':'Black',   'guibg':'#87875f' },
		\   { 'ctermfg':'Black',      'ctermbg':'107',   'guifg':'Black',   'guibg':'#87af5f' },
		\   { 'ctermfg':'Black',      'ctermbg':'114',   'guifg':'Black',   'guibg':'#87d787' },
		\   { 'ctermfg':'Black',      'ctermbg':'117',   'guifg':'Black',   'guibg':'#87d7ff' },
		\   { 'ctermfg':'Black',      'ctermbg':'118',   'guifg':'Black',   'guibg':'#87ff00' },
		\   { 'ctermfg':'Black',      'ctermbg':'122',   'guifg':'Black',   'guibg':'#87ffd7' },
		\   { 'ctermfg':'Black',      'ctermbg':'66',    'guifg':'Black',   'guibg':'#5f8787' },
		\   { 'ctermfg':'Black',      'ctermbg':'72',    'guifg':'Black',   'guibg':'#5faf87' },
		\   { 'ctermfg':'Black',      'ctermbg':'74',    'guifg':'Black',   'guibg':'#5fafd7' },
		\   { 'ctermfg':'Black',      'ctermbg':'78',    'guifg':'Black',   'guibg':'#5fd787' },
		\   { 'ctermfg':'Black',      'ctermbg':'79',    'guifg':'Black',   'guibg':'#5fd7af' },
		\   { 'ctermfg':'Black',      'ctermbg':'85',    'guifg':'Black',   'guibg':'#5fffaf' },
		\   { 'ctermfg':'White',      'ctermbg':'22',    'guifg':'White',   'guibg':'#005f00' },
		\   { 'ctermfg':'White',      'ctermbg':'23',    'guifg':'White',   'guibg':'#005f5f' },
		\   { 'ctermfg':'White',      'ctermbg':'27',    'guifg':'White',   'guibg':'#005fff' },
		\   { 'ctermfg':'White',      'ctermbg':'29',    'guifg':'White',   'guibg':'#00875f' },
		\   { 'ctermfg':'White',      'ctermbg':'34',    'guifg':'White',   'guibg':'#00af00' },
		\   { 'ctermfg':'Black',      'ctermbg':'37',    'guifg':'Black',   'guibg':'#00afaf' },
		\   { 'ctermfg':'Black',      'ctermbg':'43',    'guifg':'Black',   'guibg':'#00d7af' },
		\   { 'ctermfg':'Black',      'ctermbg':'47',    'guifg':'Black',   'guibg':'#00ff5f' },
		\   { 'ctermfg':'White',      'ctermbg':'53',    'guifg':'White',   'guibg':'#5f005f' },
		\   { 'ctermfg':'White',      'ctermbg':'58',    'guifg':'White',   'guibg':'#5f5f00' },
		\   { 'ctermfg':'White',      'ctermbg':'60',    'guifg':'White',   'guibg':'#5f5f87' },
		\   { 'ctermfg':'White',      'ctermbg':'64',    'guifg':'White',   'guibg':'#5f8700' },
		\   { 'ctermfg':'White',      'ctermbg':'65',    'guifg':'White',   'guibg':'#5f875f' },
		\   { 'ctermfg':'White',      'ctermbg':'90',    'guifg':'White',   'guibg':'#870087' },
		\   { 'ctermfg':'White',      'ctermbg':'95',    'guifg':'White',   'guibg':'#875f5f' },
		\   { 'ctermfg':'White',      'ctermbg':'96',    'guifg':'White',   'guibg':'#875f87' },
		\   { 'ctermfg':'White',      'ctermbg':'130',   'guifg':'White',   'guibg':'#af5f00' },
		\   { 'ctermfg':'White',      'ctermbg':'131',   'guifg':'White',   'guibg':'#af5f5f' },
		\   { 'ctermfg':'White',      'ctermbg':'17',    'guifg':'White',   'guibg':'#00005f' },
		\   { 'ctermbg':'Red',        'ctermfg':'Black', 'guibg':'#FF7272', 'guifg':'Black' },
		\   { 'ctermfg':'White',      'ctermbg':'52',    'guifg':'White',   'guibg':'#5f0000' },
		\   { 'ctermfg':'White',      'ctermbg':'160',   'guifg':'White',   'guibg':'#d70000' },
		\   { 'ctermfg':'White',      'ctermbg':'198',   'guifg':'White',   'guibg':'#ff0087' },
\	]
\}
let g:mwDefaultHighlightingPalette = 'mypalette'
let g:mwAutoLoadMarks = 1
let g:mwAutoSaveMarks = 1
nmap <Plug>IgnoreMarkSearchNext <Plug>MarkSearchNext
nmap <Plug>IgnoreMarkSearchPrev <Plug>MarkSearchPrev
" }}}
" Plugin: vim-markdown-preview {{{
let vim_markdown_preview_hotkey='<A-`>'
" }}}
" Plugin: vim-nerdtree-syntax-highlight {{{
let g:NERDTreeLimitedSyntax = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeHighlightFolders = 1
let g:NERDTreeHighlightFoldersFullName = 1
" }}}
" Plugin: vim-test {{{
let test#strategy = "dispatch"
" }}}
" Plugin: vimwiki {{{
let g:vimwiki_list = [{'path': '~/doc/notes/'}]
" }}}
" Plugin: unite-mark {{{
let g:unite_source_mark_marks =
\   "abcdefghijklmnopqrstuvwxyz"
\ . "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
\ . "0123456789.'`^<>[]{}()\""
" }}}
" Plugin: unite-quickfix {{{
let g:unite_quickfix_filename_is_pathshorten = 0
" }}}
" }}}
