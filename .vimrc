" Required Vim: {{{
" Approximate compile command:
" ./configure \
"	--enable-option-checking \
"	--enable-fail-if-missing \
"	--prefix=$HOME/.local \
"	--with-features=huge \
"	--enable-luainterp=dynamic \
"	--with-luajit \
"	--disable-mzschemeinterp \
"	--enable-perlinterp=no \
"	--enable-pythoninterp=no \
"	--enable-python3interp=dynamic \
"	--enable-tclinterp=no \
"	--enable-rubyinterp=no \
"	--enable-cscope \
"	--enable-channel \
"	--enable-terminal \
"	--enable-autoservername \
"	--enable-multibyte \
"	--enable-gui=gtk3 \
"	--enable-gtk3-check \
"	--enable-largefile \
"	--enable-acl \
"	--disable-nls \
"	--with-modified-by='Leonid V. Fedorenchik' \
"	--with-compiledby='Leonid V. Fedorenchik' \
"	--with-x
"make
"make install
" version: >= 8.2
" --with-features=huge --enable-luainterp --with-luajit
" --enable-python3interp -enable-cscope --enable-gui=gtk3
" }}}
" External Dependencies Of This Vimrc: {{{
" ctags - for tags support
" python - for vimspector, codi.vim
" wmctrl - for WM GUI window control
" trash-cli - for fern.vim
" cling, sript - for codi.vim
" rg (ripgrep) - for vim-grepper
" pylint3
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
set guioptions+=M
if has('autocmd')
  filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
  syntax on
endif
" }}}
" Start Vim Server: {{{
if empty(v:servername) && exists('*remote_startserver')
  call remote_startserver('VIM')
endif
" }}}
" Emoji: {{{
" TODO: make all emojis (including text emojis) double width
" }}}
" Nerdfont: {{{
" Codepoints for Nerdfont v2.1.0
call setcellwidths([
      \ [0xe5fa, 0xe62b, 2],
      \ [0xe700, 0xe7c5, 2],
      \ [0xf000, 0xf2e0, 2],
      \ [0xe200, 0xe2a9, 2],
      \ [0xf500, 0xfd46, 2],
      \ [0xe300, 0xe3eb, 2],
      \ [0xf400, 0xf4a8, 2],
      \ [0x2665, 0x2665, 2],
      \ [0x26a1, 0x26a1, 2],
      \ [0xe0a3, 0xe0a3, 2],
      \ [0xe0b4, 0xe0c8, 2],
      \ [0xe0ca, 0xe0ca, 2],
      \ [0xe0cc, 0xe0d2, 2],
      \ [0xe0d4, 0xe0d4, 2],
      \ [0x23fb, 0x23fe, 2],
      \ [0x2b58, 0x2b58, 2],
      \ [0xf300, 0xf313, 2],
      \ [0xe000, 0xe00d, 2],
      \ ])
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

function! GuiTabTooltip() abort
  let l:tooltip = ''
  let l:tooltip ..= '[Tab: ' .. tabpagenr() .. '/' .. tabpagenr('$') .. '] '
  let l:tooltip ..= 'win#: ' .. tabpagewinnr(v:lnum, '$')

  let l:bufnrlist = tabpagebuflist(v:lnum)
  for bufnr in l:bufnrlist
    let l:tooltip ..= "\n"
    " Prefix
    if getbufvar(bufnr, "&modified")
      let l:tooltip ..= '+ '
    endif
    " Buffer Name
    let l:cur_buf_name = bufname(bufnr)
    if empty(l:cur_buf_name)
      let l:cur_buf_name = "[No Name]"
    endif
    let l:tooltip ..= l:cur_buf_name
    " Suffix
    let l:cur_filetype = getbufvar(bufnr, "&filetype")
    if l:cur_filetype != ''
      let l:tooltip ..= ' [' .. l:cur_filetype .. ']'
    endif
    let l:cur_buftype = getbufvar(bufnr, "&buftype")
    if l:cur_buftype != ''
      let l:tooltip ..= ' [' .. l:cur_buftype .. ']'
    endif
  endfor

  return l:tooltip
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

let s:did_open_help = v:false
function! s:HelpCurwin(subject) abort
  let mods = 'silent noautocmd keepalt'
  if !s:did_open_help
    execute mods .. ' help'
    execute mods .. ' helpclose'
    let s:did_open_help = v:true
  endif
  if !getcompletion(a:subject, 'help')->empty()
    execute mods .. ' edit ' .. &helpfile
  endif
  return 'help ' .. a:subject
endfunction
" }}}
" Colorscheme: {{{
" set colorscheme
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
set autowrite
set autowriteall
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
  set columns=128
endif
set complete-=i
set completeopt=menuone,preview,popup,popuphidden,noinsert,noselect
set confirm
set copyindent
set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-,a-
set cscoperelative
set nocscopetag
set cscopetagorder=0
set cscopeverbose
set debug=beep
set nodelcombine
set dictionary+=/usr/share/dict/words
set dictionary+=/usr/share/dict/web2
set diffopt=filler,context:12,iwhite,vertical,foldcolumn:2,internal,indent-heuristic,algorithm:histogram,closeoff,hiddenoff
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
set foldcolumn=2
set foldlevel=20
set foldlevelstart=20
set foldminlines=0
set foldopen=quickfix,tag,undo
set formatoptions-=t
set formatoptions+=1jMmn
set nofsync
set nogdefault
set grepprg=grep\ -nH\ $*
"TODO: Colorize cursor in different modes.
"set guicursor+=a:blinkon0
if has("gui")
  set guifont=Ubuntu\ Mono\ 11,Monospace\ 9
endif
set guiheadroom=0
"XXX: add '!' to guioptions when startify bug #460 will be fixed
set guioptions=aAcdeimMgTpk
set guipty
"set guitablabel&
set guitabtooltip=%{GuiTabTooltip()}
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
  set lines=64
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
  set mouse=ar
endif
set nomousefocus
set mousehide
set mousemodel=popup_setpos
set mouseshape+=o:question,c:pencil,e:hand2
set nrformats+=alpha
set number
set patchmode=".orig"
set path+=.,,./include,../include,../*/include,*/include,*,../*,/usr/include,**
set nopreserveindent
set previewheight=3
set printencoding=utf-8
set printfont=&guifont
set printmbcharset=ISO10646
set printmbfont=r:WenQuanYi\ Zen\ Hei,a:yes
set prompt
set pumheight=10
set pyxversion=3
set redrawtime=1000
set relativenumber
set ruler
set noscrollbind
set scrollfocus
set scrolljump=2
set scrolloff=2
set scrollopt=ver,hor,jump
set secure
set sessionoptions=blank,buffers,curdir,globals,help,resize,slash,tabpages,terminal,unix,winpos,winsize
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/bin/bash
endif
set shiftround
set shiftwidth=8
set shortmess=""
set showbreak=>>>>>>>>
set showcmd
set showfulltag
set noshowmatch
set showmode
set showtabline=2
set sidescroll=30
set sidescrolloff=1
set signcolumn=number
set smartcase
set smartindent
set smarttab
set softtabstop=8
set spellfile=$HOME/src/homerc/.vim/spell/personal.utf-8.add,/tmp/tmp.utf-8.add
set spelllang+=cjk
set spelloptions=camel
set spellsuggest=fast,10
set nosplitbelow
set nosplitright
set nostartofline
"TODO: set statusline^=%{exists('*CapsLockStatusline')?CapsLockStatusline():''}
set suffixes-=.h
set noswapfile
set swapsync=
set switchbuf=uselast
set synmaxcol=1000
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif
set tabpagemax=50
set tabstop=8
set tagbsearch
set tagcase=followscs
set tagrelative
set tags=tags;
set tagstack
set termguicolors
set textwidth=80
set thesaurus+=$HOME/.vim/thes/mobythes.txt
set notildeop
set notimeout
set timeoutlen=400
set title
set titleold=$PWD
"TODO: titlestring -> cur dir, server name
set titlestring=%F\ %a%r%m\ -\ VIM
set ttimeout
set ttimeoutlen=10
set ttyfast
if has('persistent_undo')
  set undodir=$HOME/.vim/undo,.
  set undofile
endif
set undolevels=1000
set updatetime=1000
set viewoptions=cursor,folds,slash,unix,curdir
set viminfo=!,%50,'100,<50,c,f1,h,r/run,r/tmp,r/var,r/mnt,r/media,s10
"TODO: set viminfofile="~/.vim/viminfo/$PWD_viminfo.vim"
set virtualedit=block
set novisualbell
set warn
set whichwrap=
set wildchar=<C-E>
set wildcharm=<C-Z>
set nowildignorecase
set wildmenu
set wildmode=longest:full,list:full
set wildoptions=tagfile
set winaltkeys=menu
"set winheight&
"set winfixheight&
"set winfixwidth&
set winminheight=0
set winminwidth=0
"set winwidth&
set nowrap
"set wrapmargin&
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
" -----------: <Space>... mappings: {{{
nnoremap <Space>h :rightbelow terminal ++kill=kill<CR>
" }}}
" -----------: g...: vim status: {{{
" Standard Vim Mappings: a ^A d D e E f F g ^G h H ^H i I j J k m n N o p P q Q
" r R s t T u U v V w x 0 8 ] ^] # $ & ' ` * + , - ; < ? ^ _ @ ~ <Down> <End>
" <Home> <LeftMouse> <MiddleMouse> <RightMouse> <Up>
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
" }}}
" -----------: S...: open windows: {{{
" Available To Map: all
nnoremap S <Nop>
nnoremap SH :help<CR>
nnoremap SL :lopen<CR>
nnoremap SP :ptag<CR>
nnoremap SQ :botright copen<CR>
" }}}
" -----------: z...: {{{
" Standard Vim Mappings: a A b c C d D e E f F g G h H i j k l L m M n N o O r R
" s t u v w W x X z ^ + - . = <Left> <Right> <CR>
" Available To Map:
" B I J K p P q Q S T U V y Y Z $ ~ & % [ { } ( * ) ] ! # ` ; : , < > / ? @ \ | _ ' " 0 1 2 3 4 5 6 7 8 9
nnoremap <silent> zr zr:<c-u>setlocal foldlevel?<CR>
nnoremap <silent> zm zm:<c-u>setlocal foldlevel?<CR>
nnoremap <silent> zR zR:<c-u>setlocal foldlevel?<CR>
nnoremap <silent> zM zM:<c-u>setlocal foldlevel?<CR>
nnoremap z{ 0
nnoremap z} zLzL
nnoremap z( zHzH
nnoremap z) zLzL
" }}}
" -----------: Z...: close windows: {{{
nnoremap ZH :helpclose<CR>
nnoremap ZL :lclose<CR>
nnoremap ZP :pclose<CR>
nnoremap ZQ :cclose<CR>
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
nnoremap <A-n> :<C-U><C-R><C-R>='let @'. v:register .' = '. string(getreg(v:register))<CR><C-F><Left>
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
xnoremap gy "+y
" make p in visual mode replace selected text with the yank register
xnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
xnoremap X y/<C-R>"<CR>
vnoremap / y/\V<C-R>"<CR>
vnoremap ? y/\V\<<C-R>"\><CR>
vnoremap * y/\V\<<C-R>"<CR>
vnoremap # y/\V<C-R>"\><CR>
" }}}
" Command-line (Cmdline) Mode: {{{
" Subcommands & submodes: Ctrl-R, Ctrl-\
cnoremap <Tab> <C-U><BS>
"FIXME: Below does not work. Make <C-Tab> behave as <Tab>.
cnoremap <C-Tab> <Tab>
cnoremap <C-Y> <S-Tab>
" }}}
" Terminal Window: {{{
tnoremap <Esc> <C-w>N
tnoremap <C-e> <Tab>
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
inoreabbrev teh the
cnoreabbrev calc Calc
cnoreabbrev f find
cnoreabbrev gblame Gblame
" }}}
" Autocommands: {{{
if has("autocmd")
augroup vimrc
autocmd!
autocmd BufReadPre *.asm let g:asmsyntax = "fasm"
autocmd BufReadPre *.[sS] let g:asmsyntax = "asm"
autocmd BufReadPost */linux/*.h setfiletype c
autocmd BufReadPost *.log normal G
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit' | exe "normal! g`\"" | endif
autocmd CmdWinEnter : noremap <buffer> <S-CR> <CR>q:
autocmd CmdWinEnter / noremap <buffer> <S-CR> <CR>q/
autocmd CmdWinEnter ? noremap <buffer> <S-CR> <CR>q?
autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
autocmd CursorHold * checktime
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
autocmd FileType cpp setlocal path+=/usr/include/c++/7
autocmd FileType cpp setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
autocmd FileType dockerfile,python,qmake setlocal expandtab
autocmd FileType dockerfile,python,qmake setlocal tabstop=4
autocmd FileType dockerfile,python,qmake setlocal shiftwidth=4
autocmd FileType python setlocal makeprg=pylint3\ --reports=n\ --msg-template=\"{path}:{line}:\ {msg_id}\ {symbol},\ {obj}\ {msg}\"\ %:p
autocmd FileType python setlocal errorformat=%f:%l:\ %m
autocmd FileType sh setlocal formatoptions+=croql
autocmd FileType sh setlocal include=^\\s*\\%(\\.\\\|source\\)\\s
autocmd FileType sh setlocal define=\\<\\%(\\i\\+\\s*()\\)\\@=
autocmd FileType text setlocal textwidth=72 linebreak breakindent
autocmd FileType text setlocal complete+=k,s
autocmd FileType text setlocal spell
autocmd FileType text,markdown setlocal formatoptions+=t
autocmd FileType vim setlocal foldmethod=marker foldlevelstart=0 foldlevel=0
if exists("+omnifunc")
  autocmd Filetype * if &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif
  autocmd Filetype * if &completefunc == "" | setlocal completefunc=syntaxcomplete#Complete | endif
endif
autocmd FocusLost * wa
autocmd GUIEnter * set guifont=Ubuntu\ Mono\ 11,Monospace\ 9
autocmd StdinReadPost * set nomodified
au TerminalWinOpen * setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber
au BufWinEnter * if &buftype == 'terminal' | setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber | endif
autocmd VimEnter * if expand("%") != "" && getcwd() == expand("~") | cd %:h | endif
augroup END
endif
" }}}
" Commands: {{{
if !exists(":DiffOrig")
  command DiffOrig vertical new | setlocal buftype=nofile | r ++edit # |
        \ 0d_ | diffthis | wincmd p | diffthis
endif
command -bar -nargs=? -complete=help HelpCurwin execute s:HelpCurwin(<q-args>)
" }}}
" Menu: {{{
" PlanetVim
function! PlanetSaveExit() abort
  confirm wall
  qa!
endfunction

"TODO: Toggle Editing Menus: Search, Registers, Selection, View, CMark, Go, Marks, Bookmarks, Fold, QF, LL
function! PlanetEditingMenus() abort
  aunmenu Search\ (/)
  aunmenu Registers
  aunmenu Selection
  aunmenu View
  aunmenu CMark
  aunmenu Go
  aunmenu Marks
  aunmenu Bookmarks
  aunmenu Fold(z)
  aunmenu QF
  aunmenu LL
endfunction
"TODO: Toggle Development Menus: LSP, Tags, Build, Run, Debug, Test, Analyze, Terminal, Diff/Patch
function! PlanetDevelopmentMenus() abort
  aunmenu LSP([)
  aunmenu Tags(])
  aunmenu Build
  aunmenu Run
  aunmenu Debug
  aunmenu Test(J)
  aunmenu Analyze
  aunmenu Terminal
  aunmenu Diff/Patch(;)
endfunction
"TODO: Toggle Navigation Menus: Buffers, Args, Windows, Tabs, Session, GUI, Apps
function! PlanetNavigationMenus() abort
  aunmenu Buffers
  aunmenu Args
  aunmenu Windows
  aunmenu Tabs(\.)
  aunmenu Session
  aunmenu GUI(X)
  aunmenu Apps(')
endfunction
function! PlanetFiletypeMenus() abort
  "TODO
endfunction
an 100.10  &PlanetVim.&Insert\ Mode<Tab>:set\ im!           :set im!<CR>
an 100.20  &PlanetVim.--1-- <Nop>
an 100.30  &PlanetVim.&Editing\ Menus                       :call PlanetEditingMenus()<CR>
an 100.40  &PlanetVim.&Development\ Menus                   :call PlanetDevelopmentMenus()<CR>
an 100.50  &PlanetVim.&Navigation\ Menus                    :call PlanetNavigationMenus()<CR>
an 100.60  &PlanetVim.--2-- <Nop>
an 100.70  &PlanetVim.Edit\ &Settings                       :confirm e ~/.vimrc<CR>
an 100.80  &PlanetVim.--3-- <Nop>
an 100.90  &PlanetVim.&Close\ Everything                    :SClose<CR>
an 100.100 &PlanetVim.--4-- <Nop>
an 100.110 &PlanetVim.E&xit\ PlanetVim                      :call PlanetSaveExit()<CR>

" File & vim-uenuch
an 110.10  &File.&New                                       :confirm enew<CR>
an 110.20  &File.New\ &Tab                                  :confirm tabnew<CR>
an 110.30  &File.New\ &Window                               :silent !gvim<CR>
an 110.40  &File.--1-- <Nop>
an 110.50  &File.&Open\ File                                :Clap files<CR>
an 110.60  &File.Open\ &File\ Manager<Tab>-                 :Fern -reveal=% .<CR>
an 110.70  &File.Open\ &Recent                              :Clap history<CR>
an 110.70  &File.Find<Tab>:find                             :find 
an 110.80  &File.--2-- <Nop>
an 110.90  &File.&Save<Tab>:w                               :if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR>
an 110.100 &File.Save\ &As\.\.\.                            :browse confirm saveas<CR>
an 110.110 &File.Save\ A&ll<Tab>:wall                       :confirm wall<CR>
an 110.120 &File.--3-- <Nop>
an 110.130 &File.SudoSave                                   :SudoWrite<CR>
an 110.140 &File.&Rename                                    :browse confirm Rename<CR>
an 110.150 &File.Change\ File\ &Permissions                 :Chmod 0755
an 110.160 &File.&Delete\ From\ Disk                        :Delete!<CR>
an 110.170 &File.--4-- <Nop>
an 110.180 &File.&Mkdir                                     :Mkdir! <C-z>
an 110.180 &File.Cd                                         :cd <C-z>
an 110.180 &File.Tcd                                        :tcd <C-z>
an 110.190 &File.--5-- <Nop>
an 110.200 &File.&Close<Tab>:bdelete                        :bdelete<CR>

" Edit
an 120.10  &Edit.&Undo<Tab>u                                u
an 120.20  &Edit.&Redo<Tab><C-r>                            <C-r>
an 120.30  &Edit.--1-- <Nop>
an 120.40  &Edit.Undo\ &History                             :UndotreeToggle<CR>
an 120.50  &Edit.--2-- <Nop>
an 120.60  &Edit.Cu&t                                       "+dd
an 120.70  &Edit.&Copy                                      "+yy
an 120.80  &Edit.&Paste                                     "+P
an 120.90  &Edit.--3-- <Nop>
an 120.100 &Edit.Choose\ Yank\ History<Tab>:Clap\ yanks     :Clap yanks<CR>
an 120.110 &Edit.--4-- <Nop>
an 120.120 &Edit.Toggle\ Comment<Tab>gcc                    gcc
an 120.130 &Edit.Toggle\ CAPS<Tab>gC<Tab>i_<C-g>c           gC

" Searching
an 130.10  Search\ (&/).C&hoose\ Line<Tab>:Clap\ blines     :Clap blines<CR>
an 130.20  Search\ (&/).--1-- <Nop>
an 130.20  Search\ (&/).Choose\ from\ Hi&story<Tab>:Clap\ search_history :Clap search_history<CR>
an 130.30  Search\ (&/).--2-- <Nop>
an 130.40  Search\ (&/).Current\ Word<Tab>*                 *

" Vim Registers
an 135.10  Reg&isters.C&hoose\ to\ Paste\.\.\.              :Clap registers<CR>
function! s:registers_choose_to_edit() abort
  echohl Question
  echo "Register: " buffest#reg_complete()
  let l:reg_to_edit = nr2char(getchar())
  if l:reg_to_edit == "\<Esc>"
    return
  endif
  echohl None
  execute("silent Regpedit " .. l:reg_to_edit)
  execute("silent normal \<C-w>P")
endfunction
an 135.10  Reg&isters.Choose\ to\ Edit\.\.\.                :call <SID>registers_choose_to_edit()<CR>
"TODO: Add all non-empty registers to this menu

"FIXME: In Insert mode this only works for a SINGLE Normal mode command
an 140.10  &Selection.Select\ All                           ggVG

an 150.10  &View.&Command\ Palette                          :Clap<CR>
an 150.20  &View.&Files\ Side\ Bar                          :Fern . -drawer -reveal=% -toggle<CR>
an 150.30  &View.&LSP\ Side\ Bar<Tab>:Vista\ vim_lsp         :Vista vim_lsp<CR>
an 150.40  &View.&Tags\ Side\ Bar<Tab>:Vista\ ctags         :Vista ctags<CR>

" Cololr highlight words with mark.vim plugin
an 160.10  &CMark.CMark\ &Current                           <Leader>m

an 170.10  &Go.C&hoose\ Jump<Tab>:Clap\ jumps               :Clap jumps<CR>
an 170.20  &Go.--1-- <Nop>
an 170.30  &Go.Back                                         <C-o>
an 170.20  &Go.--2-- <Nop>
an 170.30  &Go.File\ under\ Cursor\ in\ Tab<Tab><C-w>gf     <C-w>gf
an 170.30  &Go.File&&Line\ under\ Cursor\ in\ Tab<Tab><C-w>gF <C-w>gF

" signature.vim (marks & markers)
an 180.10  &Marks.C&hoose<Tab>:Clap\ marks                  :Clap marks<CR>
an 180.20  &Marks.--1-- <Nop>
an 180.30  &Marks.Add                                       m,

an 183.30  Markers.Add :

" Upper-case marks (mA-mZ)
an 185.10  Boo&kmarks.Add                                   m,

an 187.10  Fold(&z).Fold\ Everything<Tab>zM                 zM
an 187.20  Fold(&z).Unfold\ Everything<Tab>zR               zR
an 187.30  Fold(&z).--1-- <Nop>
an 187.40  Fold(&z).Fold\ One\ Level<Tab>zm                 zm
an 187.50  Fold(&z).Unfold\ One\ Level<Tab>zr               zr
an 187.60  Fold(&z).--2-- <Nop>
an 187.70  Fold(&z).Fold\ by\ Syntax                        :set foldmethod=syntax<CR>
an 187.80  Fold(&z).Fold\ by\ Indent                        :set foldmethod=indent<CR>
an 187.90  Fold(&z).Fold\ by\ Expr                          :set foldmethod=expr<CR>
an 187.100 Fold(&z).Fold\ by\ {{{,}}}\ Markers              :set foldmethod=marker<CR>
an 187.110 Fold(&z).Fold\ Manually                          :set foldmethod=manual<CR>
an 187.120 Fold(&z).--3-- <Nop>
an 187.130 Fold(&z).Fold\ Selected                          :

" quickfix
an 190.10  &QF.Sea&rch                                      :Grepper -tool rg -quickfix<CR>
an 190.20  &QF.F&ind<Tab>:Cfind!                            :Cfind! 
an 190.30  &QF.Loc&ate<Tab>:Clocate!                        :Clocate! 
an 190.40  &QF.&Grep<Tab>:grep                              :grep 
an 190.50  &QF.GrepAdd\ (&b)<Tab>:grepadd                   :grepadd 
an 190.60  &QF.&VimGrep<Tab>:vimgrep                        :vimgrep 
an 190.70  &QF.Vi&mGrepAdd<Tab>:vimgrepadd                  :vimgrepadd 
an 190.80  &QF.--1-- <Nop>
an 190.90  &QF.C&hoose<Tab>:Clap\ quickfix                  :Clap quickfix<CR>
an 190.100 &QF.--2-- <Nop>
an 190.110 &QF.N&ext<Tab>]q                                 ]q
an 190.120 &QF.&Next\ File<Tab>:cnfile<Tab>]<C-q>           :cnfile<CR>
an 190.130 &QF.&Last<Tab>:clast<Tab>]Q                      ]Q
an 190.140 &QF.--3-- <Nop>
an 190.150 &QF.&Previous<Tab>[q                             [q
an 190.160 &QF.Previou&s\ File<Tab>:cpfile<Tab>[<C-q>       :cpfile<CR>
an 190.170 &QF.&First<Tab>:cfirst<Tab>[Q                    [Q
an 190.180 &QF.--4-- <Nop>
an 190.190 &QF.E&xecute\ for\ each<Tab>:cdo                 :cdo 
an 190.200 &QF.Execute\ for\ each\ File\ (&z)<Tab>:cfdo     :cfdo 
an 190.210 &QF.--5-- <Nop>
an 190.220 &QF.&Open<Tab>:copen                             :copen<CR>
an 190.230 &QF.Fil&ter<Tab>:Cfilter                         :Cfilter 
an 190.240 &QF.Filter\ O&ut<Tab>:Cfilter!                   :Cfilter! 
an 190.250 &QF.E&dit<Tab>:Qflistsplit<Tab>c\\q              :Qflistsplit<CR>
an 190.260 &QF.Read\ from\ File\ (&w)<Tab>:cgetfile         :cgetfile! 
an 190.270 &QF.Add\ from\ File\ (&y)<Tab>:caddfile          :caddfile! 
an 190.280 &QF.Read\ from\ Buffer\ (&,)<Tab>:cgetbuffer     :cgetbuffer! 
an 190.290 &QF.Add\ from\ Buffer\ (&.)<Tab>:caddbuffer      :caddbuffer! 
an 190.300 &QF.Read\ from\ Expr\ (&;)<Tab>:cgetexpr         :cgetexpr! 
an 190.310 &QF.Add\ from\ Expr\ (&')<Tab>:caddexpr          :caddexpr! 
an 190.320 &QF.&Close<Tab>:cclose<Tab>                      :cclose<CR>
an 190.330 &QF.--6-- <Nop>
an 190.340 &QF.Previous\ LocList\ (&k)<Tab>:colder          :colder<CR>
an 190.350 &QF.Next\ LocList\ (&j)<Tab>:cnewer              :cnewer<CR>
an 190.360 &QF.List\ LocLists\ (&q)<Tab>:chistory           :chistory<CR>
an 190.370 &QF.--7-- <Nop>

" loclist
an 195.10  &LL.Sea&rch                                      :Grepper -tool rg -noquickfix<CR>
an 195.20  &LL.F&ind<Tab>:Lfind!                            :Lfind! 
an 195.30  &LL.Loc&ate<Tab>:Llocate!                        :Llocate! 
an 195.40  &LL.&Grep<Tab>:lgrep                             :lgrep 
an 195.50  &LL.GrepAdd\ (&b)<Tab>:lgrepadd                  :lgrepadd 
an 195.60  &LL.&VimGrep<Tab>:lvimgrep                       :lvimgrep 
an 195.70  &LL.Vi&mGrepAdd<Tab>:lvimgrepadd                 :lvimgrepadd 
an 195.80  &LL.--1-- <Nop>
an 195.90  &LL.C&hoose<Tab>:Clap\ loclist                   :Clap loclist<CR>
an 195.100 &LL.--2-- <Nop>
an 195.110 &LL.N&ext<Tab>]l                                 ]l
an 195.120 &LL.&Next\ File<Tab>:lnfile<Tab>]<C-l>           :lnfile<CR>
an 195.130 &LL.&Last<Tab>:llast<Tab>]L                      ]L
an 195.140 &LL.--3-- <Nop>
an 195.150 &LL.&Previous<Tab>[l                             [l
an 195.160 &LL.Previou&s\ File<Tab>:lpfile<Tab>[<C-l>       :lpfile<CR>
an 195.170 &LL.&First<Tab>:lfirst<Tab>[L                    [L
an 195.180 &LL.--4-- <Nop>
an 195.190 &LL.E&xecute\ for\ each<Tab>:ldo                 :ldo 
an 195.200 &LL.Execute\ for\ each\ File\ (&z)<Tab>:lfdo     :lfdo 
an 195.210 &LL.--5-- <Nop>
an 195.220 &LL.&Open<Tab>:lopen                             :lopen<CR>
an 195.230 &LL.Fil&ter<Tab>:Lfilter                         :Lfilter 
an 195.240 &LL.Filter\ O&ut<Tab>:Lfilter!                   :Lfilter! 
an 195.250 &LL.E&dit<Tab>:Loclistsplit<Tab>c\\l             :Loclistsplit<CR>
an 195.260 &LL.Read\ from\ File\ (&w)<Tab>:lgetfile         :lgetfile! 
an 195.270 &LL.Add\ from\ File\ (&y)<Tab>:laddfile          :laddfile! 
an 195.280 &LL.Read\ from\ Buffer\ (&,)<Tab>:lgetbuffer     :lgetbuffer! 
an 195.290 &LL.Add\ from\ Buffer\ (&.)<Tab>:laddbuffer      :laddbuffer! 
an 195.300 &LL.Read\ from\ Expr\ (&;)<Tab>:lgetexpr         :lgetexpr! 
an 195.310 &LL.Add\ from\ Expr\ (&')<Tab>:laddexpr          :laddexpr! 
an 195.320 &LL.&Close<Tab>:lclose<Tab>                      :lclose<CR>
an 195.330 &LL.--6-- <Nop>
an 195.340 &LL.Previous\ LocList\ (&k)<Tab>:lolder          :lolder<CR>
an 195.350 &LL.Next\ LocList\ (&j)<Tab>:lnewer              :lnewer<CR>
an 195.360 &LL.List\ LocLists\ (&q)<Tab>:lhistory           :lhistory<CR>
an 195.370 &LL.--7-- <Nop>

" vim-lsp
an 200.10  LSP&[.C&hoose\ Symbol<Tab>:Clap\ tags\ vim_lsp   :Clap tags vim_lsp<CR>
an 200.10  LSP&[.Definition                                 :LspDefinition<CR>

an 205.10  Tags&].C&hoose<Tab>:Clap\ tags\ ctags            :Clap tags ctags<CR>
an 205.10  Tags&].&Jump\ to\ Tag<Tab><C-]>                  <C-]>

an 210.10  B&uild.Make                                      :Make<CR>

an 220.10  &Run.Configurations                              :

an 230.10  &Debug.Start\ &Debug                             :Vimspector<CR>

an 240.10  Test(&j).Run                                     :TestFile<CR>

an 250.10  Anal&yze.Check                                   :

an 260.10  &Term.&New                                       :rightbelow terminal ++kill=kill<CR>
an 260.10  &Term.New\ at\ &Bottom                           :botright terminal ++kill=kill<CR>

"an 270.10  C++.Test                                         :

" Open Log in new window
an 280.10  Git(&,).Log                                      :

an 290.10  Df/Pt(&;).DiffOrig                               :DiffOrig<CR>
an 290.20  Df/Pt(&;).Diff\ with\ file\.\.\.                 :browse vert diffsplit<CR>
an 290.30  Df/Pt(&;).Diff\ with\ patch\.\.\.                :browse vert diffpatch<CR>

an 300.10  Spelling(&-).Enable                              :

an 310.10  T&ools.C&hoose\ Colorscheme                      :Clap colors<CR>
an 310.10  T&ools.Colori&ze                                 :ColorToggle<CR>
an 310.10  T&ools.--1-- <Nop>
an 310.10  T&ools.&direnv:\ Run\ \.envrc                    :DirenvExport<CR>
an 310.10  T&ools.dire&nv:\ Edit\ \.envrc                   :EditEnvrc<CR>
an 310.10  T&ools.diren&v:\ Edit\ direnvrc                  :EditDirenvrc<CR>

" Buffers
an 320.10  &Buffers.C&hoose\.\.\.                           :Clap buffers<CR>
an 320.20  &Buffers.--1-- <Nop>
an 320.30  &Buffers.&Alternate                              :b #<CR>
an 320.40  &Buffers.--2-- <Nop>
an 320.50  &Buffers.Buffers\ List <Nop>
an disable &Buffers.Buffers\ List
let planet_buf = 1
"while buf <= bufnr('$')

" Arg List
an 330.10  &Args.&Add                                       :argadd<CR>
an 330.10  &Args.&Delete                                    :argdelete<CR>
an 330.10  &Args.Open\ &Next                                :next<CR>
an 330.10  &Args.Open\ &Previous                            :previous<CR>
an 330.10  &Args.Open\ &First                               :first<CR>
an 330.10  &Args.Open\ &Last                                :last<CR>
an 330.10  &Args.--1-- <Nop>
an 330.10  &Args.Args\ List <Nop>
an disable &Args.Args\ List

an 340.10  &Windows.&Window\ Mode                           :WindowMode<CR>
an 340.20  &Windows.--1-- <Nop>
an 340.30  &Windows.C&hoose<Tab>:Clap\ windows              :Clap windows<CR>
an 340.40  &Windows.--2-- <Nop>
an 340.50  &Windows.Horizontal\ &Split<Tab>:split<Tab>+s    <C-w>s
an 340.60  &Windows.&Vertical\ Split<Tab>:vsplit<Tab>+v     <C-w>v
an 340.70  &Windows.Rotate\ Vertica&lly<Tab>+H              <C-w>H
an 340.80  &Windows.Rotate\ &Horizontally<Tab>+K            <C-w>K
an 340.90  &Windows.S&wap<Tab>+r                            <C-w>r
an 340.100 &Windows.Move\ to\ New\ &Tab<Tab>+T              <C-w>T
an 340.110 &Windows.--3-- <Nop>
an 340.120 &Windows.&Equal\ Size<Tab>+=                     <C-w>=
"FIXME: In Insert mode this only works for a SINGLE Normal mode command (:h :an)
an 340.130 &Windows.&Maximize<Tab>+_+\|                     <C-w>_<C-w>\|
an 340.140 &Windows.--4-- <Nop>
an 340.150 &Windows.&Close<Tab>:close<Tab>+c                <C-w>c
an 340.160 &Windows.Close\ &Other\ Windows<Tab>:only<Tab>+o <C-w>o

" Tabs
an 350.10  Tabs(&\.).&New<Tab>:tabnew                       :tabnew<CR>
an 350.20  Tabs(&\.).--1-- <Nop>
an 350.30  Tabs(&\.).F&ind\ File<Tab>:tabfind               :tabfind 
an 350.40  Tabs(&\.).--2-- <Nop>
an 350.50  Tabs(&\.).&First<Tab>:tabfirst                   :tabfirst<CR>
an 350.60  Tabs(&\.).N&ext<Tab>:tabnext<Tab><C-PgDown><Tab>gt gt
an 350.70  Tabs(&\.).&Previous<tab>:tabprevious<Tab><C-PgUp><Tab>gT gT
an 350.80  Tabs(&\.).&Last<Tab>:tablast                     :tablast<CR>
an 350.90  Tabs(&\.).Last\ &accessed<Tab>g\<Tab\>            g<Tab>
an 350.100 Tabs(&\.).--3-- <Nop>
an 350.110 Tabs(&\.).E&xecute\ in\ each\ Tab<Tab>:tabdo     :tabdo 
an 350.120 Tabs(&\.).--4-- <Nop>
an 350.130 Tabs(&\.).&Close<Tab>:tabclose                   :tabclose<CR>
an 350.140 Tabs(&\.).Close\ all\ &other\ tabs<Tab>:tabonly  :tabonly<CR>

an 360.10  Sessio&n.&Save                                   :SSave!<CR>
an 360.20  Sessio&n.&Open                                   :SLoad<CR>
an 360.30  Sessio&n.&Close                                  :SClose<CR>
an 360.40  Sessio&n.&Delete                                 :SDelete<CR>
an 360.45  Sessio&n.--1-- <Nop>
an 360.60  Sessio&n.Session\ List <Nop>
an disable Sessio&n.Session\ List

" Control GUI window with wmctrl & vim servers
an 370.10  GUI(&X).&Maximize            :silent call system('wmctrl -i -b toggle,maximized_vert,maximized_horz -r' . v:windowid)<CR>
an 370.10  GUI(&X).&Full\ Screen        :silent call system('wmctrl -i -b toggle,fullscreen -r' . v:windowid)<CR>
an 370.10  GUI(&X).Minimi&ze<Tab>:suspend<Tab><C-z>         <C-z>
"TODO: List of GUI windows to focus

" Open in new GUI window
an 380.10  Apps(&').Calendar                                :Calendar<CR>
"Terminal
"FileManager
"Web Browser
"Email
"Calculator
"Codi
"difdiff

" Show current maps (nnoremap, etc.)
an 980.10  Maps(&\\).C&hoose\.\.\.                          :Clap maps<CR>

an 990.10  &Help.&Lookup\ Current\ Word                     K
an 990.20  &Help.Inde&x                                     :h index<CR>
an 990.30  &Help.&QuickRef                                  :h quickref<CR>
an 990.40  &Help.&Plugins\ Documentation                    :h local-additions<CR>
an 990.50  &Help.View\ Log\ Messages<Tab>:messages          :messages<CR>
an 990.60  &Help.--1-- <Nop>
an 990.70  &Help.Join\ PlanetVim\ Chat                      :silent !xdg-open https://matrix.to/...<CR>
an 990.80  &Help.--2-- <Nop>
an 990.90  &Help.Check\ for\ &Updates                       :silent !xdg-open https://github.com/fedorenchik/PlanetVim/releases<CR>
an 990.100 &Help.Report\ PlanetVim\ &Issue                  :silent !xdg-open https://github.com/fedorenchik/PlanetVim/issues/new<CR>
an 990.110 &Help.--3-- <Nop>
an 990.120 &Help.&About                                     :version<CR>
" }}}
" ToolBar: {{{
" }}}
" PopUp Menus: {{{
" }}}
" WinBar Menus: {{{
" }}}
" $VIMRUNTIME/ {{{
" filetype.vim {{{
let g:bash_is_sh = 1
let g:tex_flavor = "latex"
" }}}
" ftplugin/awk.vim {{{
let g:awk_is_gawk = 1
" }}}
" ftplugin/changelog.vim {{{
runtime ftplugin/changelog.vim
" }}}
" ftplugin/man.vim {{{
runtime ftplugin/man.vim
let g:ft_man_folding_enable = 1
set keywordprg=:Man
" }}}
" ftplugin/markdown.vim {{{
let g:markdown_folding = 1
" }}}
" ftplugin/rst.vim {{{
let g:rst_style = 1
" }}}
" ftplugin/rust.vim {{{
let g:rust_fold = 1
" }}}
" ftplugin/spec.vim {{{
let spec_chglog_release_info = 1
" }}}
" ftplugin/sql.vim {{{
let g:ftplugin_sql_statements = 'create,alter'
" }}}
" pack/dist/opt/cfilter/ {{{
packadd! cfilter
" }}}
" pack/dist/opt/justify/ {{{
packadd! justify
" }}}
" pack/dist/opt/matchit/ {{{
if has('syntax') && has('eval')
  packadd! matchit
endif
" }}}
" Do not load following in plugin/*.vim {{{
let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1
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
" plugin/zipPlugin.vim {{{
let g:zipPlugin_ext = '*.zip,*.jar,*.xpi,*.ja,*.war,*.ear,*.celzip,
       \ *.oxt,*.kmz,*.wsz,*.xap,*.docx,*.docm,*.dotx,*.dotm,*.potx,*.potm,
       \ *.ppsx,*.ppsm,*.pptx,*.pptm,*.ppam,*.sldx,*.thmx,*.xlam,*.xlsx,*.xlsm,
       \ *.xlsb,*.xltx,*.xltm,*.xlam,*.crtx,*.vdw,*.glox,*.gcsx,*.gqsx,*.epub'
" }}}
" spell/ {{{
let g:spell_clean_limit = 60 * 60
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
" syntax/javascript.vim {{{
let g:javaScript_fold = 1
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
" syntax/php.vim {{{
let g:php_folding = 1
" }}}
" syntax/python.vim {{{
let python_highlight_all = 1
" }}}
" syntax/r.vim {{{
let g:r_syntax_folding = 1
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
" syntax/tex.vim {{{
let g:tex_fold_enabled = 1
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
let g:asyncomplete_log_file = ''
let g:asyncomplete_auto_completeopt = 0
" }}}
" Plugin: emmet-vim {{{
let g:user_emmet_mode='iv'
let g:user_emmet_leader_key='<C-Z>'
" }}}
" Plugin: FastFold {{{
let g:fastfold_force = 1
let g:fastfold_minlines = 0
" fold text objects
xnoremap iz :<c-u>FastFoldUpdate<cr><esc>:<c-u>normal! ]zv[z<cr>
xnoremap az :<c-u>FastFoldUpdate<cr><esc>:<c-u>normal! ]zV[z<cr>
" }}}
" Plugin: fern.vim {{{
let g:fern#smart_cursor = "hide"
let g:fern#keepalt_on_edit = 1
let g:fern#keepjumps_on_edit = 1
nnoremap <silent> - :Fern -reveal=% .<CR>
nnoremap <silent> <A-f> :Fern . -drawer -reveal=% -toggle<CR>
augroup my-fern
  autocmd!
  autocmd FileType fern setlocal nonumber norelativenumber signcolumn=yes foldcolumn=0
augroup END
" }}}
" Plugin: fern-bookmark.vim {{{
let g:fern#scheme#bookmark#store#file = "~/.vim/fern-bookmark.json"
" }}}
" Plugin: fern-renderer-nerdfont.vim {{{
let g:fern#renderer = "nerdfont"
" }}}
" Plugin: glyph-palette.vim {{{
augroup my-glyph-palette
  autocmd!
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType startify call glyph_palette#apply()
augroup END
" }}}
" Plugin: undotree {{{
let g:undotree_WindowLayout=4
nnoremap SU :UndotreeShow<CR>
nnoremap ZU :UndotreeHide<CR>
" }}}
" Plugin: vim-clap {{{
let g:clap_disable_bottom_top = 1
let g:clap_provider_yanks_history = "~/.vim/clap_yanks.history"
nnoremap <silent> <Space><Space> :Clap providers<CR>
nnoremap <silent> <Space>; :Clap command<CR>
nnoremap <silent> <Space>: :Clap command_history<CR>
nnoremap <silent> <Space>/ :Clap search_history<CR>
nnoremap <silent> <Space>? :Clap help_tags<CR>
nnoremap <silent> <Space>b :Clap buffers<CR>
nnoremap <silent> <Space>C :Clap colors<CR>
nnoremap <silent> <Space>f :Clap files<CR>
nnoremap <silent> <Space>F :Clap filer<CR>
nnoremap <silent> <Space>g :Clap bcommits<CR>
nnoremap <silent> <Space>G :Clap commits<CR>
nnoremap <silent> <Space>j :Clap jumps<CR>
nnoremap <silent> <Space>k :Clap lines<CR>
nnoremap <silent> <Space>l :Clap blines<CR>
nnoremap <silent> <Space>L :Clap loclist<CR>
nnoremap <silent> <Space>m :Clap marks<CR>
nnoremap <silent> <Space>M :Clap maps<CR>
nnoremap <silent> <Space>o :Clap tags vim_lsp<CR>
nnoremap <silent> <Space>q :Clap quickfix<CR>
nnoremap <silent> <Space>r :Clap history<CR>
nnoremap <silent> <Space>s :Clap grep ++query=`expand('<cword>')`<CR>
nnoremap <silent> <Space>S :Clap grep<CR>
nnoremap <silent> <Space>T :Clap filetypes<CR>
nnoremap <silent> <Space>w :Clap windows<CR>
nnoremap <silent> <Space>y :Clap yanks<CR>
nnoremap <silent> <Space>' :Clap marks<CR>
nnoremap <silent> <Space>" :Clap registers<CR>
"TODO: clap provider for :echo serverlist()
"TODO: clap provider for GUI windows with wmctrl
"TODO: clap provider for :args
"TODO: clap provider for tag stack
"TODO: clap provider for :changes
"TODO: clap provider for :lhistory
"TODO: clap provider for :chistory
"TODO: clap provider for :undolist
"TODO: clap provider for :tabs
" }}}
" Plugin: vim-crystalline {{{
function! StatusLine_SearchCount() abort
  try
    const search_count = searchcount({'maxcount': 0, 'timeout': 50})
  catch /^Vim\%((\a\+)\)\=:\%(E486\)\@!/
    return '[?/??]'
  endtry
  if empty(search_count)
    return ''
  endif
  return search_count.total ? search_count.incomplete ? printf('[%d/??]', search_count.current)
        \ : printf('[%d/%d]', search_count.current, search_count.total) : '[0/0]'
endfunction

function! StatusLine(current, width)
  let l:s = ''

  if a:current
    let l:s .= crystalline#mode()
    let l:s .= window_mode#lightlineComponent()
    let l:s .= crystalline#right_mode_sep('')
  else
    let l:s .= '%#CrystallineInactive#'
  endif
  let l:s .= ' %f%h%w%m%r '
  if a:current
    let l:s .= crystalline#right_sep('', 'Fill') . ' %{fugitive#head()}'
  endif

  let l:s .= '%='
  if a:current
    let l:s .= crystalline#left_sep('', 'Fill') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    let l:s .= "%{StatusLine_SearchCount()}"
    let l:s .= "%{exists('*CapsLockStatusline')?CapsLockStatusline():''}"
    let l:s .= ' %{grepper#statusline()}'
    let l:s .= crystalline#left_mode_sep('')
  endif
  if a:width > 80
    let l:s .= ' %{&ft}[%{&fenc!=#""?&fenc:&enc}][%{&ff}] %l/%L %c%V %P '
  else
    let l:s .= ' '
  endif

  return l:s
endfunction

let g:crystalline_enable_sep = 1
let g:crystalline_statusline_fn = 'StatusLine'
let g:crystalline_theme = 'molokai'

set showtabline=2
set laststatus=2
" }}}
" Plugin: vim-flog {{{
augroup Flog
  au FileType floggraph vnoremap <buffer> <silent> D :<C-U>call flog#run_tmp_command("vertical belowright Git diff %(h'>) %(h'<)")<CR>
augroup end
" }}}
" Plugin: vim-grepper {{{
let g:grepper = {}
let g:grepper.tools = ['rg', 'git', 'grep']
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
nnoremap sg :Grepper -tool rg -cword -noprompt<CR>
nnoremap sG :Grepper -tool rg<CR>
nnoremap ss :Grepper -tool git -cword -noprompt<CR>
nnoremap sS :Grepper -tool git<CR>
call SetupCommandAlias("grep", "GrepperGrep")
" }}}
" Plugin: vim-lsp {{{
let g:lsp_use_lua = has('nvim-0.4.0') || (has('lua') && has('patch-8.2.0775'))
let g:lsp_preview_keep_focus = 1
let g:lsp_preview_float = 0
let g:lsp_preview_autoclose = 0
let g:lsp_documentation_float_docked = 0 " disable because it will change focus to documentation window
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_signs_enabled = 1
let g:lsp_signs_priority = 10
let g:lsp_highlights_enabled = 1
let g:lsp_textprop_enabled = 1
" make undercurl work in terminal
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
highlight LspErrorHighlight term=strikethrough cterm=strikethrough ctermul=Red gui=strikethrough guisp=Red
highlight LspWarningHighlight term=undercurl cterm=undercurl ctermul=Yellow gui=undercurl guisp=Orange
highlight LspInformationHighlight term=underline cterm=undercurl ctermul=Blue gui=undercurl guisp=Blue
highlight LspHintHighlight term=underline cterm=undercurl ctermul=Green gui=undercurl guisp=DarkGreen
let g:lsp_peek_alignment = "top"
let g:lsp_show_workspace_edits = 1
let g:lsp_fold_enabled = 1
let g:lsp_hover_conceal = 1
let g:lsp_ignorecase = 1
let g:lsp_log_file = ''
let g:lsp_semantic_enabled = 0
":LspCodeAction
":LspCodeActionSync
":LspCodeLens
":LspCodeLensSync
":LspDocumentDiagnostics
":LspDeclaration
":LspDefinition
":LspDocumentFold
":LspDocumentFoldSync
":LspDocumentFormat
":LspDocumentFormatSync
":LspDocumentRangeFormat
":LspDocumentSymbol
":LspHover
":LspNextDiagnostic [-wrap=0]
":LspNextError [-wrap=0]
":LspNextReference
":LspNextWarning [-wrap=0]
":LspPeekDeclaration
":LspPeekDefinition
":LspPeekImplementation
":LspPeekTypeDefinition
":LspPreviousDiagnostic [-wrap=0]
":LspPreviousError [-wrap=0]
":LspPreviousReference
":LspPreviousWarning [-wrap=0]
":LspImplementation
":LspReferences
":LspRename
":LspSemanticScopes
":LspTypeDefinition
":LspTypeHierarchy
":LspWorkspaceSymbol
":LspStatus
"nnoremap <plug>(lsp-code-action)
"nnoremap <plug>(lsp-code-lens)
"nnoremap <plug>(lsp-declaration)
"nnoremap <plug>(lsp-peek-declaration)
"nnoremap <plug>(lsp-definition)
"nnoremap <plug>(lsp-peek-definition)
"nnoremap <plug>(lsp-document-symbol)
"nnoremap <plug>(lsp-document-diagnostics)
"nnoremap <plug>(lsp-hover)
"nnoremap <plug>(lsp-next-diagnostic)
"nnoremap <plug>(lsp-next-diagnostic-nowrap)
"nnoremap <plug>(lsp-next-error)
"nnoremap <plug>(lsp-next-error-nowrap)
"nnoremap <plug>(lsp-next-reference)
"nnoremap <plug>(lsp-next-warning)
"nnoremap <plug>(lsp-next-warning-nowrap)
"nnoremap <plug>(lsp-preview-close)
"nnoremap <plug>(lsp-preview-focus)
"nnoremap <plug>(lsp-previous-diagnostic)
"nnoremap <plug>(lsp-previous-diagnostic-nowrap)
"nnoremap <plug>(lsp-previous-error)
"nnoremap <plug>(lsp-previous-error-nowrap)
"nnoremap <plug>(lsp-previous-reference)
"nnoremap <plug>(lsp-previous-warning)
"nnoremap <plug>(lsp-previous-warning-nowrap)
"nnoremap <plug>(lsp-references)
"nnoremap <plug>(lsp-rename)
"nnoremap <plug>(lsp-workspace-symbol)
"nnoremap <plug>(lsp-document-format)
"vnoremap <plug>(lsp-document-format)
"nnoremap <plug>(lsp-document-range-format)
"xnoremap <plug>(lsp-document-range-format)
"nnoremap <plug>(lsp-implementation)
"nnoremap <plug>(lsp-peek-implementation)
"nnoremap <plug>(lsp-type-definition)
"nnoremap <plug>(lsp-peek-type-definition)
"nnoremap <plug>(lsp-type-hierarchy)
"nnoremap <plug>(lsp-status)
"nnoremap <plug>(lsp-signature-help)
"nnoremap <plug>(lsp-preview-close)
"nnoremap <plug>(lsp-preview-focus)
let g:lsp_async_completion = 1
autocmd FileType c,cpp,cmake,python,vim setlocal tagfunc=lsp#tagfunc
"TODO: snippets
autocmd FileType python setlocal foldmethod=expr
autocmd FileType python setlocal foldexpr=lsp#ui#vim#folding#foldexpr()
autocmd FileType python setlocal foldtext=lsp#ui#vim#folding#foldtext()
" }}}
" Plugin: vim-mark {{{
let g:mwPalettes = {
\  'mypalette': [
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
\  ]
\}
let g:mwDefaultHighlightingPalette = 'mypalette'
let g:mwAutoLoadMarks = 1
let g:mwAutoSaveMarks = 1
vmap <Leader>m <Plug>MarkSet
vmap <Leader>r <Plug>MarkRegex
xmap <Leader>* <Plug>MarkIWhiteSet
nmap <Leader>M <Plug>MarkToggle
nmap <Leader>N <Plug>MarkConfirmAllClear
" }}}
" Plugin: vim-markdown-preview {{{
let vim_markdown_preview_hotkey='<A-`>'
" }}}
" Plugin: vim-signature {{{
let g:SignatureWrapJumps = 0
let g:SignatureMarkTextHLDynamic = 1
let g:SignatureMarkerTextHLDynamic = 1
let g:SignatureDeleteConfirmation = 1
let g:SignaturePurgeConfirmation = 1
let g:SignatureForceMarkPlacement = 1
let g:SignatureForceMarkerPlacement = 1
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
" Plugin: vim-startify {{{
let g:startify_lists = [
      \ { 'type': 'commands' },
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ ]
let g:startify_bookmarks = [
      \ '~/src',
      \ '~/.vimrc',
      \ '~/.bashrc',
      \ '~/.gitconfig',
      \ ]
let g:startify_commands = [
      \ { 'c': [ 'Terminal', ':terminal ++curwin ++kill=kill']},
      \ { 'f': [ 'File Manager', ':Fern .']},
      \ ]
let g:startify_change_to_vcs_root = 1
let g:startify_fortune_use_unicode = 0
let g:startify_enable_unsafe = 1
let g:startify_session_sort = 1
let g:startify_custom_indices = ['d', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 'u', 'w', 'x', 'y', 'z']
let g:startify_use_env = 1
autocmd User StartifyReady setlocal cursorline
" }}}
" Plugin: vim-test {{{
let test#strategy = "dispatch"
" }}}
" Plugin: vimspector {{{
let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB', 'vscode-bash-debug' ]
" }}}
" Plugin: vista.vim {{{
let g:vista_sidebar_keepalt = 1
let g:vista_stay_on_open = 1
nnoremap <silent> ST :Vista<CR>
nnoremap <silent> ZT :Vista!<CR>
nnoremap <silent> <A-t> :Vista!! vim_lsp<CR>
autocmd FileType markdown nnoremap <silent> <A-t> :Vista!! toc<CR>
" }}}
" }}}
