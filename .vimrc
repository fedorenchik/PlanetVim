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
  syntax sync minlines=10000
endif
" }}}
" Start Vim Server: {{{
if empty(v:servername) && exists('*remote_startserver')
  call remote_startserver('VIM')
endif
" }}}
" Emoji, Nerdfont: {{{
" only last setcellwidths() call has effect
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
      \
      \ [0x2328, 0x2328, 2],
      \ [0x2699, 0x2699, 2],
      \ [0x2747, 0x2747, 2],
      \ [0x270f, 0x270f, 2],
      \ [0x25b6, 0x25b6, 2],
      \ [0x2b06, 0x2b07, 2],
      \ [0x2195, 0x2195, 2],
      \ [0x1fa9f, 0x1fa9f, 2],
      \ [0x1faa7, 0x1faa7, 2],
      \ ])
" }}}
" Functions: {{{
function! GuiTabLabel() abort
  let l = '[' .. v:lnum .. ']'
  let bufnrlist = tabpagebuflist(v:lnum)

  "TODO: add '!' if has terminal window in tab page
  let m = ' '
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
      let m = '+'
      break
    endif
  endfor
  let l ..= m
  let l ..= ' '

  let f = fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), ':t')
  if empty(f)
    let f = '[No Name]'
  endif
  return l .. f
endfunction

function! GuiTabTooltip() abort
  let l:tooltip = ''
  let l:tooltip ..= '[' .. v:lnum .. '/' .. tabpagenr('$') .. ']'
  let l:tooltip ..= '[#:' .. tabpagewinnr(v:lnum, '$') .. ']'
  if haslocaldir(-1) == 2
    let l:tooltip ..= ' tcd: ' .. getcwd(-1, 0)
  endif

  let l:bufnrlist = tabpagebuflist(v:lnum)
  for bufnr in l:bufnrlist
    let l:tooltip ..= "\n"
    " Prefix
    if getbufvar(bufnr, "&modified")
      let l:tooltip ..= '+ '
    endif
    " Buffer Name
    let l:cur_win = v:false
    if bufnr == bufnrlist[tabpagewinnr(v:lnum) - 1]
      let l:cur_win = v:true
    endif
    if l:cur_win
      let l:tooltip ..= '**'
    endif
    let l:cur_buf_name = bufname(bufnr)
    if empty(l:cur_buf_name)
      let l:cur_buf_name = "[No Name]"
    endif
    let l:tooltip ..= l:cur_buf_name
    if l:cur_win
      let l:tooltip ..= '**'
    endif
    " Suffix
    let l:cur_filetype = getbufvar(bufnr, "&filetype")
    if l:cur_filetype != ''
      let l:tooltip ..= ' [' .. l:cur_filetype .. ']'
    endif
    let l:cur_buftype = getbufvar(bufnr, "&buftype")
    if l:cur_buftype != ''
      let l:tooltip ..= ' [' .. l:cur_buftype .. ']'
    endif
    if haslocaldir(bufwinnr(bufnr)) == 1
      let l:tooltip ..= ' [lcd: ' .. getcwd() .. ']'
    endif
  endfor

  let l:tooltip ..= "\npwd: " .. getcwd(-1)

  return l:tooltip
endfunction

" Avoid the ":ptag" when there is no word under the cursor, and a few other
" things. Opens the tag under cursor in Preview window.
hi previewWord term=bold ctermbg=green guibg=green
func! PreviewWord() abort
  if &previewwindow
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
      call search("$", "b")
      let w = substitute(w, '\\', '\\\\', "")
      call search('\<\V' . w . '\>')
      exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
      wincmd p
    endif
  endif
endfunc

func! ListMonths() abort
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
endfunc

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

func! FocusWindow(direction) abort
  let owmw = &wmw
  let owiw = &wiw
  " TODO: somehow calculate reasonable wiw & wmw values
  set wiw=20 wmw=20
  exe 'wincmd ' .. a:direction
  if empty(&buftype) || &buftype == 'nowrite' || &buftype == 'acwrite'
    let win_width = 80
    if &textwidth > 0
      let win_width = &textwidth
    elseif str2nr(&colorcolumn) > 0
      let win_width = str2nr(&colorcolumn)
    endif
    let win_width += &foldcolumn
    if &number || &relativenumber
      let win_width += &numberwidth
    endif
    if &signcolumn == 'yes' || &signcolumn == 'auto'
      let win_width += 2
    endif
    echo 'win_width=' .. win_width
    if win_width > winwidth(0)
      exe win_width .. 'wincmd |'
    endif
  endif
  let &wmw = owmw
  let &wiw = owiw
endfunc

func! PlanetVim_QF_OldFiles()
  call setqflist([], ' ', {'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})
endfunc

func QfOldFiles(info)
  let items = getqflist({'id' : a:info.id, 'items' : 1}).items
  let l = []
  for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
    call add(l, fnamemodify(bufname(items[idx].bufnr), ':p:.'))
  endfor
  return l
endfunc

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
"TODO: set & show baloons
set ballooneval
set balloonevalterm
set belloff=all,backspace,cursor,complete,copy,ctrlg,error,esc,ex,insertmode,lang,mess,showmatch,operator,register,shell,spell,wildmode
set nobomb
set nobreakindent
set browsedir=buffer
set cindent
set cinoptions=:0,l1,g0,N-s,E-s,t0,U1,j1,J1
set cinwords-=switch
set clipboard=autoselect,autoselectml,exclude:cons\|linux
set cmdheight=2
set cmdwinheight=1
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
set foldcolumn=1
set foldlevel=20
set foldlevelstart=20
set foldmethod=syntax
set foldminlines=0
set foldnestmax=5
set foldopen=quickfix,tag,undo
set formatoptions-=t
set formatoptions+=1jMmn
set nofsync
set nogdefault
set grepprg=grep\ -nH\ $*
"TODO: Colorize cursor in different modes.
"set guicursor+=a:blinkon0
if has("gui")
  set guifont=DejaVu\ Sans\ Mono\ 9,Monospace\ 9
endif
set guiheadroom=0
"XXX: add '!' to guioptions when startify bug will be fixed
" Adding '!' to guioptions causes too much redraw & 'hit enter' prompts (vim bug)
set guioptions=aAcdeimMgpk
set guipty
set guitablabel=%{GuiTabLabel()}
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
set makeencoding=char
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
set nonumber
set numberwidth=3
set patchmode=".orig"
set path+=.,,./include,../include,../*/include,*/include,*,../*,/usr/include,**
set nopreserveindent
set previewheight=12
set printencoding=utf-8
set printfont=&guifont
set printmbcharset=ISO10646
set printmbfont=r:WenQuanYi\ Zen\ Hei,a:yes
set prompt
set pumheight=10
set pyxversion=3
set redrawtime=10000
set norelativenumber
set ruler
set noscrollbind
set scrollfocus
set scrolljump=2
set scrolloff=2
set scrollopt=ver,hor,jump
set secure
set sessionoptions=blank,buffers,curdir,folds,globals,help,resize,slash,tabpages,terminal,unix,winpos,winsize
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/bin/bash
endif
set shiftround
set shiftwidth=8
set shortmess="I"
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
set t_vb=
set tabpagemax=20
set tabstop=8
set tagbsearch
set tagcase=followscs
set tagrelative
set tags=tags;
set tagstack
set termguicolors
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
set virtualedit=block
set visualbell
set warn
set whichwrap=
set wildcharm=<C-Z>
set nowildignorecase
set wildmenu
set wildmode=longest:full,list:full
set wildoptions=tagfile
set winaltkeys=menu
set winminheight=0
set winminwidth=0
set winwidth=1
set nowrap
set nowrapscan
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
" Normal Keys: {{{
" TODO: f/F - search 1 char
" TODO: t/T - search 2 chars
" TODO: l/h - repeat last f/F/t/T
nn ` '
nn ' `
nn <unique> ; q:i
nm + <C-W>
nn gA :args<CR>
nn gb :tselect<CR>
nn gB :tags<CR>
nn gg gg0
nn gG :changes<CR>
nn gl :llist<CR>
nn gL :lhistory<CR>
nn gm gM
nn gM gm
nn gO :jumps<CR>
nn gq :clist<CR>
nn gQ :chistory<CR>
nn gS ^vg_y:execute @@<CR>:echo 'Sourced: ' . @@<CR>
nn gW Q
nn gx :silent !xdg-open <cWORD><CR>
nn gX gQ
nn gy :%y+<CR>
nn gY :undolist<CR>
nn gz :buffers<CR>
nn gZ :tabs<CR>
nn g: :history<CR>
nn g. :marks<CR>
nn g" :registers<CR>
nn g= :tabnew<CR>
nn G G$
nn h F
nn j :lne<CR>
nn k :lp<CR>
nn l f
nn Q gq
nn s <Nop>
nn S <Nop>
nn Y y$
nn <silent> zr zr:<c-u>setlocal foldlevel?<CR>
nn <silent> zm zm:<c-u>setlocal foldlevel?<CR>
nn <silent> zR zR:<c-u>setlocal foldlevel?<CR>
nn <silent> zM zM:<c-u>setlocal foldlevel?<CR>
nn z{ 0
nn z} zLzL
nn z( zHzH
nn z) zLzL
nn z@ z^
nn [C :colder<CR>
nn [O :lolder<CR>
nn ]C :cnewer<CR>
nn ]O :lnewer<CR>
" }}}
" Ctrl Key: {{{
" XXX: Ctrl-Shift modifier does not work neither in terminal nor in GUI.
" XXX: Uppercase/lowercase distinction is not available with <Ctrl-...> modifier.
nn <C-'> :tag<CR>
nn <C-@> <C-^>
nn <C-b> :colder<CR>
nn <C-d> :lnewer<CR>
nn <C-e> :cnext<CR>
nn <C-f> :cnewer<CR>
nn <C-h> :call FocusWindow('h')<CR>
nn <C-j> <C-W>j
nn <C-k> <C-W>k
nn <C-l> :call FocusWindow('l')<CR>
nn <C-s> :emenu <C-Z>
nn <C-u> :lolder<CR>
nn <C-W>V :botright vsplit<CR>
nn <C-y> :cprevious<CR>
" }}}
" Alt Key: {{{
nn <A-Left> <C-o>
nn <A-Right> <C-i>
nn <A-<> gT
nn <A->> gt
nn <A-1> 1gt
nn <A-2> 2gt
nn <A-3> 3gt
nn <A-4> 4gt
nn <A-5> 5gt
nn <A-6> 6gt
nn <A-7> 7gt
nn <A-8> 8gt
nn <A-9> 9gt
nn <A-0> 10gt
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
inoremap <A-c> <C-X><C-N>
inoremap <A-C> <C-X><C-P>
inoremap <A-d> <C-X><C-D>
inoremap <expr> <A-e> pumvisible() ? "<C-E>" : "<Esc>u"
inoremap <A-f> <C-X><C-F>
inoremap <A-i> <C-X><C-I>
inoremap <A-k> <C-X><C-K>
inoremap <A-l> <C-X><C-L>
inoremap <A-m> <C-R>=ListMonths()<CR>
inoremap <A-o> <C-X><C-O>
inoremap <A-s> <C-X><C-S>
inoremap <A-t> <C-X><C-T>
inoremap <A-u> <C-X><C-U>
inoremap <A-v> <C-X><C-V>
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
cnoremap <expr> <C-u> ((getcmdtype() is# ":" && getcmdline() is# "") ? ("<Esc>") : ("<C-u>"))
cnoremap <expr> <Tab> ((getcmdtype() is# ":" && getcmdline() is# "") ? ("<Esc>") : ("<C-z>"))
" }}}
" Terminal Window: {{{
tno <Esc> <C-w>N
tno <C-e> <Tab>
tno <C-j> <C-w><C-j>
tno <C-k> <C-w><C-k>
tno <C-l> <C-w><C-l>
tno <C-h> <C-w><C-h>
if has('nvim')
  tno <Esc> <C-\><C-n>
  tno <C-v><Esc> <Esc>
endif
tno <A-<> <C-w>gT
tno <A->> <C-w>gt
tno <A-1> <C-w>:1tabn<CR>
tno <A-2> <C-w>:2tabn<CR>
tno <A-3> <C-w>:3tabn<CR>
tno <A-4> <C-w>:4tabn<CR>
tno <A-5> <C-w>:5tabn<CR>
tno <A-6> <C-w>:6tabn<CR>
tno <A-7> <C-w>:7tabn<CR>
tno <A-8> <C-w>:8tabn<CR>
tno <A-9> <C-w>:9tabn<CR>
tno <A-0> <C-w>:10tabn<CR>
tno <ScrollWheelUp> <C-w>N
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
"cnoreabbrev f find
call SetupCommandAlias("f", "find")
" }}}
" Autocommands: {{{
if has("autocmd")
aug vimrc
autocmd!
autocmd BufReadPre *.asm let g:asmsyntax = "fasm"
autocmd BufReadPre *.[sS] let g:asmsyntax = "asm"
autocmd BufReadPost */linux/*.h setfiletype c
autocmd BufReadPost */linux/*.h setlocal colorcolumn=100
autocmd BufReadPost *.log normal G
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit' | exe "normal! g`\"" | endif
autocmd CmdWinEnter : noremap <buffer> <S-CR> <CR>q:
autocmd CmdWinEnter : noremap! <buffer> <S-CR> <CR>q:
autocmd CmdWinEnter : noremap <buffer> <C-c> <C-w>c
autocmd CmdWinEnter : noremap! <buffer> <C-c> <C-\><C-n><C-w>c
autocmd CmdWinEnter / noremap <buffer> <S-CR> <CR>q/
autocmd CmdWinEnter ? noremap <buffer> <S-CR> <CR>q?
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
autocmd FileType c setlocal colorcolumn=80
autocmd FileType cpp setlocal path+=/usr/include/c++/7
autocmd FileType cpp setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
autocmd FileType cpp setlocal colorcolumn=120
autocmd FileType dockerfile,python,qmake setlocal expandtab
autocmd FileType dockerfile,python,qmake setlocal tabstop=4
autocmd FileType dockerfile,python,qmake setlocal shiftwidth=4
autocmd FileType help,markdown,text setlocal colorcolumn=+0
autocmd FileType markdown setlocal foldmethod=expr
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
"autocmd FocusLost * wa
autocmd GUIEnter * set t_vb=
autocmd GUIEnter * set guifont=DejaVu\ Sans\ Mono\ 9,Monospace\ 9
autocmd GUIEnter * silent call system('wmctrl -i -b add,maximized_vert,maximized_horz -r' . v:windowid)
autocmd SessionLoadPost * exe "set viminfofile=~/.vim/viminfo/" .. fnamemodify(v:this_session, ":t") .. ".viminfo"
autocmd SessionLoadPost * silent! rviminfo!
"TODO: auto-save and auto-load quickfix/loclist files (up to 10 of each, loclists: for each window)
autocmd StdinReadPost * set nomodified
au TerminalWinOpen * setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber
au BufWinEnter * if &buftype == 'terminal' | setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber | endif
autocmd VimEnter * if expand("%") != "" && getcwd() == expand("~") | cd %:h | endif
aug END
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
" TODO: $VIMRUNTIME folder
" TODO: Vim help reference
" TODO: VS Code
" TODO: Qt Creator
" TODO: LibreOffice
" Custom config file: $HOME/.vim/planetvimrc.vim
let g:PV_config = "$HOME/.vim/planetvimrc.vim"
if filereadable(expand(g:PV_config))
  silent exe "source " .. fnameescape(g:PV_config)
endif

function! PlanetVim_AddMenuItem(priority, text, command, tooltip) abort
    an 110.10  &File.&New                                   :confirm enew<CR>
    an a:priority a:text a:command
    tln 110.10  &File.&New                                  :confirm enew<CR>
    no <A-f>n :confirm enew<CR>
    no a:map a:command
    ln <A-f>n :confirm enew<CR>
    tno <A-f>n :confirm enew<CR>
endfunction

function! PlanetVim_ConfigUpdate(conf_var) abort
  if empty(v:this_session) && filewritable(expand(g:PV_config))
    silent call system('grep "let ' .. a:conf_var .. ' =" ' .. g:PV_config)
    if ! v:shell_error
      silent call system('sed -i -e "s/^let ' .. a:conf_var .. ' = .*$/let ' .. a:conf_var .. ' = ' .. eval(a:conf_var) .. '/" ' .. g:PV_config)
    else
      silent call system('echo "let ' .. a:conf_var .. ' = ' .. eval(a:conf_var) .. '" >> ' .. g:PV_config)
    endif
  else
    silent call system('echo "let ' .. a:conf_var .. ' = ' .. eval(a:conf_var) .. '" > ' .. g:PV_config)
  endif
endfunction

"TODO: add session support
function! PlanetVim_MenusBasicToggle() abort
  if g:PlanetVim_menus_basic
    let g:PlanetVim_menus_basic = 0
  else
    let g:PlanetVim_menus_basic = 1
  endif
  call PlanetVim_MenusBasicUpdate()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_basic')
  endif
endfunction

function! PlanetVim_MenusEditingToggle() abort
  if g:PlanetVim_menus_editing
    let g:PlanetVim_menus_editing = 0
  else
    let g:PlanetVim_menus_editing = 1
  endif
  call PlanetVim_MenusEditingUpdate()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_editing')
  endif
endfunction

function! PlanetVim_MenusDevelopmentToggle() abort
  if g:PlanetVim_menus_dev
    let g:PlanetVim_menus_dev = 0
  else
    let g:PlanetVim_menus_dev = 1
  endif
  call PlanetVim_MenusDevelopmentUpdate()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_dev')
  endif
endfunction

function! PlanetVim_MenusToolsToggle() abort
  if g:PlanetVim_menus_tools
    let g:PlanetVim_menus_tools = 0
  else
    let g:PlanetVim_menus_tools = 1
  endif
  call PlanetVim_MenusToolsUpdate()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_tools')
  endif
endfunction

function! PlanetVim_MenusNavigationToggle() abort
  if g:PlanetVim_menus_nav
    let g:PlanetVim_menus_nav = 0
  else
    let g:PlanetVim_menus_nav = 1
  endif
  call PlanetVim_MenusNavigationUpdate()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_nav')
  endif
endfunction

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

function! s:SelectAll()
  exe "norm! gg" . (&slm == "" ? "VG" : "gH\<C-O>G")
endfunction

function! s:AutoFoldEnable()
  set foldclose=all
  set foldopen=all
  set foldlevel=0
  set foldlevelstart=0
endfunction

function! s:AutoFoldDisable()
  set foldclose=
  set foldopen=quickfix,tag,undo
  set foldlevel=20
  set foldlevelstart=20
endfunction

fun! s:SetPath()
  if !exists("g:menutrans_path_dialog")
    let g:menutrans_path_dialog = "Enter search path for files.\nSeparate directory names with a comma."
  endif
  let n = inputdialog(g:menutrans_path_dialog, substitute(&path, '\\ ', ' ', 'g'))
  if n != ""
    let &path = substitute(n, ' ', '\\ ', 'g')
  endif
endfun

fun! s:SetTags()
  if !exists("g:menutrans_tags_dialog")
    let g:menutrans_tags_dialog = "Enter names of tag files.\nSeparate the names with a comma."
  endif
  let n = inputdialog(g:menutrans_tags_dialog, substitute(&tags, '\\ ', ' ', 'g'))
  if n != ""
    let &tags = substitute(n, ' ', '\\ ', 'g')
  endif
endfun

fun! s:SetTextWidth()
  if !exists("g:menutrans_textwidth_dialog")
    let g:menutrans_textwidth_dialog = "Enter new text width (0 to disable formatting): "
  endif
  let n = inputdialog(g:menutrans_textwidth_dialog, &tw)
  if n != ""
    " Remove leading zeros to avoid it being used as an octal number.
    " But keep a zero by itself.
    let tw = substitute(n, "^0*", "", "")
    let &tw = tw == '' ? 0 : tw
  endif
endfun

fun! s:SetLineEndings()
  if !exists("g:menutrans_fileformat_dialog")
    let g:menutrans_fileformat_dialog = "Select line endings for file"
  endif
  if !exists("g:menutrans_fileformat_choices")
    let g:menutrans_fileformat_choices = "&Linux/Mac/Unix/Windows\nOld &Windows/Dos\nOld &Mac\n&Cancel"
  endif
  if &ff == "dos"
    let def = 2
  elseif &ff == "mac"
    let def = 3
  else
    let def = 1
  endif
  let n = confirm(g:menutrans_fileformat_dialog, g:menutrans_fileformat_choices, def, "Question")
  if n == 1
    set ff=unix
  elseif n == 2
    set ff=dos
  elseif n == 3
    set ff=mac
  endif
endfun

func s:XxdToHex()
  let mod = &mod
  if has("vms")
    %!mc vim:xxd
  else
    call s:XxdFind()
    exe '%!' . g:xxdprogram
  endif
  if getline(1) =~ "^0000000:"		" only if it worked
    set ft=xxd
  endif
  let &mod = mod
endfun

func s:XxdFromHex()
  let mod = &mod
  if has("vms")
    %!mc vim:xxd -r
  else
    call s:XxdFind()
    exe '%!' . g:xxdprogram . ' -r'
  endif
  set ft=
  doautocmd filetypedetect BufReadPost
  let &mod = mod
endfun

func s:XxdFind()
  if !exists("g:xxdprogram")
    " On the PC xxd may not be in the path but in the install directory
    if has("win32") && !executable("xxd")
      let g:xxdprogram = $VIMRUNTIME . (&shellslash ? '/' : '\') . "xxd.exe"
      if g:xxdprogram =~ ' '
        let g:xxdprogram = '"' .. g:xxdprogram .. '"'
      endif
    else
      let g:xxdprogram = "xxd"
    endif
  endif
endfun

function! PlanetVim_BufferIsNormal(name, num)
    if !bufexists(a:num)
      return 0
    endif
    if isdirectory(a:name) || !buflisted(a:num)
      return 0
    endif
    let type = getbufvar(a:num, '&buftype')
    if type != '' && type != 'nofile' && type != 'nowrite'
      return 0
    endif
    return 1
endfunction

func! PlanetVim_MenuName(name)
  let menu_name = a:name
  if empty(menu_name)
    let menu_name = "[No Name]"
  endif
  let menu_name = escape(menu_name, "\\. \t|")
  let menu_name = substitute(menu_name, "&", "&&", "g")
  let menu_name = substitute(menu_name, "\n", "^@", "g")
  return menu_name
endfunc

func! PlanetVim_MenuBufers_AddBuffer(name, num)
  if PlanetVim_BufferIsNormal(a:name, a:num)
    let menu_name = PlanetVim_MenuName(a:name)
    exe 'an 800.500 📖&b.' .. menu_name .. ' :confirm b ' .. a:num .. '<CR>'
  endif
endfunc

func! PlanetVim_MenuBuffers_AddBufferAu()
  let name = expand("<afile>")
  let num = expand("<abuf>") + 0
  call PlanetVim_MenuBufers_AddBuffer(name, num)
endfunc

func! PlanetVim_MenuBuffers_RemoveBufferAu()
  let name = expand("<afile>")
  let menu_name = PlanetVim_MenuName(name)
  if ! empty(menu_name)
    exe 'silent! aun 800.500 📖&b.' .. menu_name
  endif
endfunc

function! PlanetVim_AddBuffers()
  let buf = 1
  while buf <= bufnr('$')
    let name = bufname(buf)
    call PlanetVim_MenuBufers_AddBuffer(name, num)
    let buf += 1
  endwhile
endfunction

aug PlanetVim_AugMenuBuffers
au!
au BufCreate,BufFilePost * call PlanetVim_MenuBuffers_AddBufferAu()
au BufDelete,BufFilePre * call PlanetVim_MenuBuffers_RemoveBufferAu()
aug END

function! PlanetVim_MenuSessionSetCurrent() abort
  if exists('g:last_session')
    exe 'aun 📚&h.Current:\ ' .. g:last_session
    unlet g:last_session
  endif
  if ! empty(v:this_session)
    exe 'an 840.20  📚&h.Current:\ ' .. fnamemodify(v:this_session, ":t") .. ' <Nop>'
    let g:last_session = fnamemodify(v:this_session, ":t")
  endif
endfunction

function! PlanetVim_MenuSessionList() abort
  for session in startify#session_list('')
    exe 'an 840.500 📚&h.' .. session .. ' :SLoad ' .. session .. '<CR>'
  endfor
endfunction

aug PlanetVim_AugroupSessions
au!
au SessionLoadPost * call PlanetVim_MenuSessionSetCurrent()
au VimEnter * call PlanetVim_MenuSessionList()
aug END

function! PlanetVim_LSPUpdateFolds() abort
  set foldmethod=expr foldexpr=lsp#ui#vim#folding#foldexpr() foldtext=lsp#ui#vim#folding#foldtext()
  LspDocumentFold
endfunction

function! PlanetVim_EmergencyExit() abort
  set noautowrite
  set noautowriteall
  cquit!
endfunction

func! PlanetVim_Window_Maximize() abort
  let g:PV_win_restore_cmd = winrestcmd()
  wincmd _
  wincmd |
endfunc

func! PlanetVim_Window_Restore() abort
  if exists('g:PV_win_restore_cmd')
    exe g:PV_win_restore_cmd
    "FIXME: Remove second exe call after vim bug #7988 is fixed
    exe g:PV_win_restore_cmd
  endif
endfunc

func! PlanetVim_View_ToggleAutosave() abort
  if exists('g:PV_view_autosave')
    let g:PV_view_autosave = ! g:PV_view_autosave
  else
    let g:PV_view_autosave = v:true
  endif
  if g:PV_view_autosave
    aug PlanetVim_augroup_autosave_views
      au!
      au BufWinLeave * mkview 9
      au BufWinEnter * silent loadview 9
    aug END
    echo "AutoSave Views"
  else
    aug PlanetVim_augroup_autosave_views
      au!
    aug END
    echo "Do not AutoSave Views"
  endif
endfunc

func! PlanetVim_DeleteBuffers()
  let buf = 1
  while buf <= bufnr('$')
    if !buflisted(buf) && !bufloaded(buf)
      continue
    endif
    bdelete buf
    let buf += 1
  endwhile
endfunc

func! PlanetVim_TagsAutoPreview_Toggle() abort
  if exists('g:PV_tags_auto_preview')
    let g:PV_tags_auto_preview = ! g:PV_tags_auto_preview
  else
    let g:PV_tags_auto_preview = v:true
  endif
  if g:PV_tags_auto_preview
    aug AUG_PV_TagsPreview
      au!
      au! CursorHold * ++nested call PreviewWord()
    aug END
    echo "AutoPreview Tags"
  else
    aug AUG_PV_TagsPreview
      au!
    aug END
    echo "Do not AutoPreview Tags"
  endif
endfunc

"TODO: Add function to follow DE night mode & theme settings (auto switch
"TODO: guioptions+=d when dark theme, auto switch to dark colorscheme variant)

"TODO: add setting 'equalprg' for formatting wih == (clang-format, etc.)
"TODO: Choise between text, emoji, symbols, nerdicons menus
"TODO: Customize tabline-menu when vim bug #7991 is fixed
if ! exists("g:PlanetVim_menus_basic")
  let g:PlanetVim_menus_basic = 1
endif
function! PlanetVim_MenusBasicUpdate() abort
  if g:PlanetVim_menus_basic
    " File & vim-uenuch
    an 110.10  📁&f.File <Nop>
    an disable 📁&f.File
    an 110.20  📁&f.N&ew<Tab>:enew                             :confirm enew<CR>
    an 110.30  📁&f.New\ Split<Tab>:new<Tab>+n                 <C-w>n
    an 110.40  📁&f.New\ &VSplit<Tab>:vnew                     :vnew<CR>
    an 110.50  📁&f.New\ &Tab                                  :confirm tabnew<CR>
    an 110.60  📁&f.New\ GUI\ &Window                          :silent !gvim<CR>
    an 110.70  📁&f.--1-- <Nop>
    an 110.60  📁&f.New\ Project.Vim\ Plugin                   :TODO
    an 110.60  📁&f.New\ Project.Blender\ Addon                :TODO
    an 110.60  📁&f.New\ Project.Nextcloud\ App                :TODO
    an 110.60  📁&f.New\ Project.Linux\ Kernel\ Module         :TODO
    an 110.60  📁&f.New\ Project.Wordpress\ Plugin             :TODO
    an 110.60  📁&f.New\ Project.Yocto\ System                 :TODO
    an 110.60  📁&f.New\ Project.ROS\ Package                  :TODO
    an 110.70  📁&f.--1-- <Nop>
    an 110.80  📁&f.&Open\ File                                :Clap files<CR>
    an 110.80  📁&f.Open\ File\ Dialog                         :browse confirm e<CR>
    an 110.90  📁&f.Open\ &File\ Manager<Tab>-                 :Fern . -reveal=%<CR>
    an 110.100 📁&f.File\ &Manager\ Side\ Bar                  :Fern . -reveal=% -drawer -toggle<CR>
    an 110.110 📁&f.Open\ &Recent                              :Clap history<CR>
    an 110.110 📁&f.QF\ &Recent                                :call PlanetVim_QF_OldFiles()<CR>
    an 110.120 📁&f.F&ind<Tab>:find                            :find 
    an 110.120 📁&f.F&ind\ in\ Tab<Tab>:tabfind                :tabfind 
    an 110.110 📁&f.Advanced.Open\ Read\ Only                  :browse view<CR>
    an 110.110 📁&f.Advanced.Split\ Read\ Only                 :browse sview<CR>
    an 110.110 📁&f.Advanced.VSplit\ Read\ Only                :browse view<CR>
    an 110.110 📁&f.Advanced.Tab\ Read\ Only                   :browse view<CR>
    an 110.110 📁&f.Advanced.Split\ Find                       :sfind<CR>
    an 110.130 📁&f.--2-- <Nop>
    an 110.140 📁&f.&Save<Tab>:w                               :if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm up<Bar>endif<CR>
    an 110.150 📁&f.Save\ &As\.\.\.<Tab>:saveas                :browse confirm saveas<CR>
    an 110.160 📁&f.Save\ A&ll<Tab>:wall                       :silent confirm wall<CR>
    an 110.170 📁&f.--3-- <Nop>
    an 110.180 📁&f.Export\ (Selected)\ as\ HTML               :TOhtml<CR>
    an 110.180 📁&f.Convert\ to\ HTML                          :runtime syntax/2html.vim<CR>
    an 110.190 📁&f.--4-- <Nop>
    am 110.200 📁&f.&Previous\ in\ Folder<Tab>[f               [f
    am 110.210 📁&f.&Next\ in\ Folder<Tab>]f                   ]f
    an 110.220 📁&f.--5-- <Nop>
    an 110.230 📁&f.Open\ File\ under\ Cursor<Tab>gF           gF
    an 110.240 📁&f.Split\ Open\ File\ under\ Cursor<Tab>+F    <C-w>F
    an 110.250 📁&f.Tab\ Open\ File\ under\ Cursor<Tab>+gF     <C-w>gF
    an 110.260 📁&f.--6-- <Nop>
    an 110.270 📁&f.SudoSave                                  :SudoWrite<CR>
    an 110.280 📁&f.Rename                                     :browse confirm Rename<CR>
    an 110.290 📁&f.Change\ File\ Permissions                  :Chmod 0755
    an 110.300 📁&f.Delete\ From\ Disk                        :Delete!<CR>
    an 110.300 📁&f.--7-- <Nop>
    an 110.310 📁&f.Mkdir                                   :Mkdir! <C-z>
    an 110.320 📁&f.Cd<Tab>:cd                              :cd <C-z>
    an 110.330 📁&f.Cd\ in\ Tab<Tab>:tcd                    :tcd <C-z>
    an 110.340 📁&f.Cd\ in\ Window<Tab>:lcd                 :lcd <C-z>
    an 110.320 📁&f.Cd\ to\ Previous\ Directory<Tab>:cd\ -  :cd -<CR>
    an 110.330 📁&f.Cd\ to\ Previous\ Directory\ in\ Tab<Tab>:tcd\ - :tcd -<CR>
    an 110.340 📁&f.Cd\ to\ Previous\ Directory\ in\ Window<Tab>:lcd\ - :lcd -<CR>
    an 110.350 📁&f.--8-- <Nop>
    an 110.360 📁&f.&Close<Tab>:bdelete                        :bdelete<CR>

    " Edit
    an 120.10  📝&e.Edit <Nop>
    an disable 📝&e.Edit
    an 120.20  📝&e.&Undo<Tab>u<Tab>g-                         u
    an 120.30  📝&e.&Redo<Tab><C-r><Tab>g+                     <C-r>
    an 120.40  📝&e.--1-- <Nop>
    an 120.50  📝&e.Repeat\ Edit<Tab>\.                        .
    an 120.60  📝&e.Repeat\ Command<Tab>@:                     @:
    an 120.70  📝&e.Repeat\ Macro<Tab>@@                       @@
    an 120.80  📝&e.--2-- <Nop>
    an 120.90  📝&e.Undo\ &History                             :UndotreeToggle<CR>
    an 120.100 📝&e.--3-- <Nop>
    an 120.110 📝&e.Cu&t<Tab>"+d                               "+d
    an 120.120 📝&e.&Copy<Tab>"+y                              "+y
    an 120.130 📝&e.&Paste<Tab>"+p                             "+p
    an 120.140 📝&e.--4-- <Nop>
    an 120.150 📝&e.Paste\ Before<Tab>"+P                     "+P
    an 120.160 📝&e.Paste\ Before<Tab>"+gP                    "+gP
    an 120.170 📝&e.Paste\ &&\ Cursor\ After<Tab>"+gp         "+gp
    an 120.180 📝&e.Paste\ with\ Indent<Tab>"+]p               "+]p
    an 120.190 📝&e.Paste\ Before\ with\ Indent<Tab>"+[P       "+[P
    an 120.200 📝&e.--5-- <Nop>
    an 120.210 📝&e.Choose\ Yank\ History<Tab>:Clap\ yanks     :Clap yanks<CR>
    an 120.220 📝&e.--6-- <Nop>
    am 120.230 📝&e.Swap\ Preious\ Line<Tab>[e                 [e
    am 120.240 📝&e.Swap\ Next\ Line<Tab>]e                    ]e
    an 120.250 📝&e.--7-- <Nop>
    an 120.260 📝&e.Unindent<Tab><                             <
    an 120.270 📝&e.Indent<Tab>>                               >
    an 120.280 📝&e.Auto\ Indent<Tab>=                         =
    an 120.290 📝&e.Auto\ Indent\ File<Tab>gg=G                gg=G
    an 120.300 📝&e.Auto\ Format\ File                         :!clang-format<CR>
    an 120.310 📝&e.--8-- <Nop>
    an 120.320 📝&e.Insert<Tab>i                               i
    an 120.330 📝&e.Continue\ Insert<Tab>gi                    gi
    an 120.340 📝&e.Insert\ at\ First\ Non-blank<Tab>I         I
    an 120.350 📝&e.Insert\ at\ Beginning\ of\ Line<Tab>gI     gI
    an 120.360 📝&e.Insert\ New\ Line\ Before<Tab>O            O
    an 120.370 📝&e.Insert\ New\ Line\ After<Tab>o             o
    an 120.380 📝&e.Append<Tab>a                               a
    an 120.390 📝&e.Append\ at\ End\ of\ Line<Tab>A            A
    an 120.400 📝&e.Replace\ Line<Tab>cc                       cc
    an 120.410 📝&e.Replace\ to\ the\ End\ of\ Line<Tab>C      C
    an 120.420 📝&e.--9-- <Nop>
    an 120.430 📝&e.Replace\ Mode<Tab>R                        R
    an 120.440 📝&e.Virtual\ Replace\ Mode<Tab>gR              gR

    " Advanced Edit (Modify)
    an 125.10  ✏️&m.Advanced\ Edit <Nop>
    an disable ✏️&m.Advanced\ Edit
    an 125.310 ✏️&m.--8-- <Nop>
    an 125.320 ✏️&m.Format\ Text<Tab>gq                       gq
    an 125.330 ✏️&m.Format\ Text\ Keep\ Cursor<Tab>gw         gw
    an 125.340 ✏️&m.--9-- <Nop>
    an 125.350 ✏️&m.Toggle\ Comment<Tab>gcc                    gcc
    an 125.360 ✏️&m.Toggle\ Caps\ Lock<Tab>gC<Tab>i_<C-g>c     gC
    an 125.370 ✏️&m.To\ lower<Tab>gu                           gu
    an 125.380 ✏️&m.To\ UPPER<Tab>gU                           gU
    an 125.390 ✏️&m.Swap\ Case<Tab>g~                          g~
    an 125.400 ✏️&m.--10-- <Nop>
    an 125.410 ✏️&m.Join\ Lines<Tab>J                          J
    an 125.420 ✏️&m.Join\ Lines\ without\ Whitespace<Tab>gJ    gJ
    an 125.570 ✏️&m.--13-- <Nop>
    an 125.580 ✏️&m.Remove\ Trailing\ Whitespace               :TODO
    an 125.590 ✏️&m.--14-- <Nop>
    an 125.600 ✏️&m.Call\ 'operatorfunc'<Tab>g@                g@
    an 125.610 ✏️&m.Filter<Tab>:g!/re/p                        :g!/re/d<CR>
    an 125.620 ✏️&m.Filter\ Out<Tab>:g/re/p                    :g/re/d<CR>
    an 125.630 ✏️&m.Sort<Tab>!sort                             !sort<CR>
    an 125.640 ✏️&m.Reverse<Tab>!tac                           !tac<CR>
    an 125.650 ✏️&m.Uniq<Tab>!uniq                             !uniq<CR>
    an 125.660 ✏️&m.Filter\ by\ Program<Tab>!<cmd>             !
    an 125.660 ✏️&m.--2-- <Nop>
    am 125.660 ✏️&m.XML\ Encode<Tab>[x{motion}                [x
    am 125.660 ✏️&m.XML\ Decode<Tab>]x{motion}                ]x
    am 125.660 ✏️&m.URL\ Encode<Tab>[u{motion}                [u
    am 125.660 ✏️&m.URL\ Decode<Tab>]u{motion}                ]u
    am 125.660 ✏️&m.C\ String\ Encode<Tab>[y{motion}          [y
    am 125.660 ✏️&m.C\ String\ Decode<Tab>]y{motion}          ]y
    an 125.660 ✏️&m.--4-- <Nop>
    an 125.660 ✏️&m.Rot13\ Operator<Tab>g?                    g?
    an 125.660 ✏️&m.Rot13\ Line<Tab>g??<Tab>g?g?     g??
    an 125.660 ✏️&m.--4-- <Nop>
    am 125.660 ✏️&m.Empty\ Line\ Before<Tab>[<Space>          [<Space>
    am 125.660 ✏️&m.Empty\ Line\ After<Tab>]<Space>           ]<Space>
    an 125.670 ✏️&m.Snippets <Nop>
    an disable ✏️&m.Snippets
    an 125.680 ✏️&m.Emmet <Nop>
    an disable ✏️&m.Emmet

    " Search
    an 130.10  🔎&/.Search <Nop>
    an disable 🔎&/.Search
    an 130.20  🔎&/.C&hoose\ Line<Tab>:Clap\ blines     :Clap blines<CR>
    an 130.30  🔎&/.--1-- <Nop>
    an 130.40  🔎&/.Choose\ from\ Hi&story<Tab>:Clap\ search_history :Clap search_history<CR>
    an 130.50  🔎&/.--2-- <Nop>
    an 130.60  🔎&/.Previous<Tab>N                           N
    an 130.70  🔎&/.Next<Tab>n                               n
    an 130.80  🔎&/.--3-- <Nop>
    an 130.90  🔎&/.Select\ Previous<Tab>gN                  gN
    an 130.100 🔎&/.Select\ Next<Tab>gn                      gn
    an 130.110 🔎&/.--4-- <Nop>
    an 130.120 🔎&/.Repeat\ Search<Tab>/<CR>                   /<CR>
    an 130.130 🔎&/.Repeat\ Search\ Backwards<Tab>?<CR>        ?<CR>
    an 130.140 🔎&/.--5-- <Nop>
    an 130.150 🔎&/.First\ Identifier<Tab>[<C-i>              [<C-i>
    an 130.160 🔎&/.Next\ Identifier<Tab>]<C-i>               ]<C-i>
    an 130.170 🔎&/.List\ All\ Identifier<Tab>[I              [I
    an 130.180 🔎&/.List\ Next\ Identifier<Tab>]I             ]I
    an 130.190 🔎&/.Show\ First\ Identifier<Tab>[i            [i
    an 130.200 🔎&/.Show\ Next\ Identifier<Tab>]i             ]i
    an 130.210 🔎&/.Previous\ #if/#else/#endif<Tab>[#         [#
    an 130.220 🔎&/.Next\ #if/#else/#endif<Tab>]#             ]#
    an 130.230 🔎&/.--6-- <Nop>
    an 130.240 🔎&/.Current\ Word<Tab>*                      *
    an 130.250 🔎&/.Current\ Word\ Backwards<Tab>#           #
    an 130.260 🔎&/.Current\ \<word\><Tab>g*                 g*
    an 130.270 🔎&/.Current\ \<word\>\ Backwards<Tab>g#      g#
    an 130.280 🔎&/.--7-- <Nop>
    an 130.290 🔎&/.Previous\ &\ Select<Tab>gN               <Tab>gN
    an 130.300 🔎&/.Next\ &\ Select<Tab>gn                   <Tab>gn
    an 130.310 🔎&/.--8-- <Nop>
    an 130.300 🔎&/.Search\ Dialog<Tab>:promptfind           :promptfind<CR>
    an 130.320 🔎&/.Substitute <Nop>
    an disable 🔎&/.Substitute
    an 130.330 🔎&/.Repeat\ on\ Line<Tab>&                   &
    an 130.340 🔎&/.Repeat\ on\ File<Tab>g&                  g&
    an 130.340 🔎&/.Substitute\ Dialog<Tab>:promptrepl       :promptrepl<CR>

    " Selection
    "FIXME: In Insert mode this only works for a SINGLE Normal mode command
    an 140.10  🖍️&s.Selection <Nop>
    an disable 🖍️&s.Selection
    an 140.10  🖍️&s.Select\ All                             :<C-U>call <SID>SelectAll()<CR>
    an 140.10  🖍️&s.Reselect\ Previous\ Area                gv
    an 140.10  🖍️&s.--1-- <Nop>
    an 140.10  🖍️&s.Visual\ Mode<Tab>v                      v
    an 130.10  🖍️&s.Visual\ Line\ Mode<Tab>V                V
    an 140.10  🖍️&s.Visual\ Block\ Mode<Tab><C-v>           <C-v>
    an 140.10  🖍️&s.--2-- <Nop>
    an 140.10  🖍️&s.Select\ Mode<Tab>gh                     gh
    an 140.10  🖍️&s.Select\ Line\ Mode<Tab>gH               gH
    an 140.10  🖍️&s.Select\ Block\ Mode<Tab>g<C-h>          g<C-H>

    " View
    "TODO: add 'scrollbind' file in split
    an 150.10  📺&v.View <Nop>
    an disable 📺&v.View
    an 150.10  📺&v.&Command\ Palette                          :Clap<CR>
    an 150.20  📺&v.&Files\ Side\ Bar                          :Fern . -drawer -reveal=% -toggle<CR>
    an 150.30  📺&v.&LSP\ Side\ Bar<Tab>:Vista\ vim_lsp        :Vista vim_lsp<CR>
    an 150.40  📺&v.&Tags\ Side\ Bar<Tab>:Vista\ ctags         :Vista ctags<CR>
    an 150.40  📺&v.QuickFix                                   :botright copen<CR>
    an 150.40  📺&v.LocList                                    :lopen<CR>
    an 150.50  📺&v.--1-- <Nop>
    an 150.60  📺&v.WinBar <Nop>
    an disable 📺&v.WinBar
    an 150.70  📺&v.Add\ Current                               :call PV_WinBar_AddCurrent()<CR>
    an 150.70  📺&v.Remove\ Current                            :call PV_WinBar_RemoveCurrent()<CR>
    an 150.70  📺&v.Remove\ Others                             :call PV_WinBar_RemoveOthers()<CR>
    an 150.70  📺&v.--1-- <Nop>
    an 150.70  📺&v.Clear                                      :unmenu WinBar<CR>
    an 150.70  📺&v.--1-- <Nop>
    an 150.70  📺&v.Colorscheme <Nop>
    an disable 📺&v.Colorscheme
    an 150.70.10  📺&v.Set\ Colorscheme.Dark <Nop>
    an disable    📺&v.Set\ Colorscheme.Dark
    an 150.70.10  📺&v.Set\ Colorscheme.Dracula             :set bg=dark<CR>:colorscheme dracula<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.Gruvbox\ Dark       :set bg=dark<CR>:colorscheme gruvbox<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.Molokai             :set bg=dark<CR>:colorscheme molokai<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.One\ Dark           :set bg=dark<CR>:colorscheme one<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.PaperColor\ Dark    :set bg=dark<CR>:colorscheme PaperColor<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.Solarized\ Dark     :set bg=dark<CR>:colorscheme solarized<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.Light <Nop>
    an disable    📺&v.Set\ Colorscheme.Light
    an 150.70.500 📺&v.Set\ Colorscheme.Gruvbox\ Light      :set bg=light<CR>:colorscheme gruvbox<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.One\ Light          :set bg=light<CR>:colorscheme one<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.PaperColor\ Light   :set bg=light<CR>:colorscheme PaperColor<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.Solarized\ Light    :set bg=light<CR>:colorscheme solarized<CR>
    an 150.70  📺&v.Set\ Dark\ Background<Tab>set\ bg=dark  :set bg=dark<CR>
    an 150.70  📺&v.Set\ Light\ Background<Tab>set\ bg=light :set bg=light<CR>
    an 150.70  📺&v.Choose\ Colorscheme<Tab>:Clap\ colors   :Clap colors<CR>

    " Go
    an 160.10  ↕️&g.Go <Nop>
    an disable ↕️&g.Go
    an 160.10  ↕️&g.C&hoose\ Jump<Tab>:Clap\ jumps               :Clap jumps<CR>
    an 160.10  ↕️&g.--1-- <Nop>
    an 160.10  ↕️&g.Back<Tab><C-o>                               <C-o>
    an 160.10  ↕️&g.Forward<Tab><C-i>                            <C-i>
    an 160.10  ↕️&g.--2-- <Nop>
    an 160.10  ↕️&g.Previous\ section<Tab>[[                     [[
    an 160.10  ↕️&g.Next\ section<Tab>][                         ][
    an 160.10  ↕️&g.Previous\ SECTION<Tab>[]                     []
    an 160.10  ↕️&g.Next\ SECTION<Tab>]]                         ]]
    an 160.10  ↕️&g.--2-- <Nop>
    an 160.10  ↕️&g.Previous\ Change\ Position<Tab>g;            g;
    an 160.10  ↕️&g.Next\ Change\ Position<Tab>g,                g,
    an 160.10  ↕️&g.--3-- <Nop>
    an 160.10  ↕️&g.Start\ of\ File<Tab>gg                       gg
    an 160.10  ↕️&g.Percentage\ in\ File<Tab>{count}%            :TODO:N%
    an 160.10  ↕️&g.End\ of\ File<Tab>G                          G
    an 160.10  ↕️&g.--4-- <Nop>
    an 160.10  ↕️&g.Middle\ of\ Text\ Line<Tab>gm                gM
    an 160.10  ↕️&g.Middle\ of\ Screen\ Line<Tab>gM              gm
    an 160.10  ↕️&g.--4-- <Nop>
    an 160.10  ↕️&g.Sentence\ Backward<Tab>(                     (
    an 160.10  ↕️&g.Sentence\ Forward<Tab>)                      )
    an 160.10  ↕️&g.ftFT\ Backward<Tab>,                         ,
    an 160.10  ↕️&g.ftFT\ Forward<Tab>;                          ;
    an 160.10  ↕️&g.Start\ of\ Selected\ Area<Tab>'<             `<
    an 160.10  ↕️&g.End\ of\ Selected\ Area<Tab>'>               `>
    an 160.10  ↕️&g.Start\ of\ Changed\ Text<Tab>'[              `[
    an 160.10  ↕️&g.End\ of\ Changed\ Text<Tab>']                `]
    an 160.10  ↕️&g.Previous\ Empty\ Line<Tab>{                  {
    an 160.10  ↕️&g.Next\ Empty\ Line<Tab>}                      }
    an 160.10  ↕️&g.Previous\ Enclosing\ {<Tab>[{                [{
    an 160.10  ↕️&g.Next\ Enclosing\ }<Tab>]}                    ]}
    an 160.10  ↕️&g.Next\ MatchIt<Tab>%                          %
    an 160.10  ↕️&g.--4-- <Nop>
    an 160.10  ↕️&g.Previous\ Enclosing\ (<Tab>[(                [(
    an 160.10  ↕️&g.Next\ Enclosing\ (<Tab>])                    ])
    an 160.10  ↕️&g.--4-- <Nop>
    an 160.10  ↕️&g.Scroll\ Left<Tab>zH                          zH
    an 160.10  ↕️&g.Scroll\ Right<Tab>zL                         zL
    an 160.10  ↕️&g.Scroll\ Left<Tab>zh                          zh
    an 160.10  ↕️&g.Scroll\ Right<Tab>zl                         zl
    an 160.10  ↕️&g.Scroll\ Right\ to\ Cursor<Tab>zs             zs
    an 160.10  ↕️&g.Scroll\ Left\ to\ Cursor<Tab>ze              ze

    " Navigation
    an 165.10  🧭&n.Navigation <Nop>
    an disable 🧭&n.Navigation
    an 160.10  🧭&n.Definition\ in\ Scope<Tab>gd                 gd
    an 160.10  🧭&n.Definition\ in\ File<Tab>gD                  gD
    an 160.10  🧭&n.Definition\ Split<Tab>+d                     <C-w>d
    an 160.10  🧭&n.Declaration\ Split<Tab>+i                    <C-w>i
    an 160.10  🧭&n.First\ #define<Tab>[<C-d>                    [<C-d>
    an 160.10  🧭&n.Next\ #define<Tab>]<C-d>                     ]<C-d>
    an 160.10  🧭&n.List\ All\ #define<Tab>[D                    [D
    an 160.10  🧭&n.List\ Next\ #define<Tab>]D                   ]D
    an 160.10  🧭&n.Show\ First\ #define<Tab>[d                  [d
    an 160.10  🧭&n.Show\ Next\ #define<Tab>]d                   ]d
    an 160.10  🧭&n.First\ keyword<Tab>[<C-i>                    [<C-i>
    an 160.10  🧭&n.Next\ keyword<Tab>]<C-i>                     ]<C-i>
    an 160.10  🧭&n.--4-- <Nop>
    an 160.10  🧭&n.File\ under\ Cursor\ in\ Tab<Tab><C-w>gF     <C-w>gF
    an 160.10  🧭&n.Previous\ Start\ of\ Function<Tab>[m         [m
    an 160.10  🧭&n.Next\ Start\ of\ Function<Tab>[m             [m
    an 160.10  🧭&n.Previous\ End\ of\ Function<Tab>[M           [M
    an 160.10  🧭&n.Next\ End\ of\ Function<Tab>]M               ]M
    an 160.10  🧭&n.Previous\ comment<Tab>[*<Tab>[/              [/
    an 160.10  🧭&n.Next\ comment<Tab>]*<Tab>]/                  ]/

    " Settings (Options) (unimpaired settings)
    an 970.10  ⚙️&\\.Settings <Nop>
    an disable ⚙️&\\.Settings
    an 970.10  ⚙️&\\.Tabs:\ &2<Tab>et\ ts=2\ sw=2           :set et ts=2 sw=2<CR>
    an 970.10  ⚙️&\\.Tabs:\ &4<Tab>et\ ts=4\ sw=4           :set et ts=4 sw=4<CR>
    an 970.10  ⚙️&\\.Tabs:\ &8<Tab>noet\ ts=8\ sw=8         :set noet ts=8 sw=8<CR>
    an 970.10  ⚙️&\\.--1-- <Nop>
    am 970.10  ⚙️&\\.Toggle\ 'cursorline'<Tab>yoc           yoc
    am 970.10  ⚙️&\\.Toggle\ 'hlsearch'<Tab>yoh             yoh
    am 970.10  ⚙️&\\.Toggle\ 'ignorecase'<Tab>yoi           yoi
    am 970.10  ⚙️&\\.Toggle\ 'number'<Tab>yon               yon
    am 970.10  ⚙️&\\.Toggle\ 'relativenumber'<Tab>yor       yor
    am 970.10  ⚙️&\\.Toggle\ 'cursorcolumn'<Tab>you         you
    am 970.10  ⚙️&\\.Toggle\ 'virtualedit'<Tab>yov          yov
    am 970.10  ⚙️&\\.Toggle\ 'wrap'<Tab>yow                 yow
    am 970.10  ⚙️&\\.Toggle\ word\ wrap                     :set lbr! lbr?<CR>
    am 970.10  ⚙️&\\.Toggle\ 'cursorline'\ &&\ 'cursorcolumn'<Tab>yox yox
    an 970.10  ⚙️&\\.--2-- <Nop>
    am 970.10  ⚙️&\\.'cmdheight':\ 2                        :set cmdheight=2<CR>
    an 970.10  ⚙️&\\.--3-- <Nop>
    am 970.10  ⚙️&\\.'scrolloff':\ 0                        :set so=0<CR>
    am 970.10  ⚙️&\\.'scrolloff':\ 2\ (default)             :set so=2<CR>
    am 970.10  ⚙️&\\.'scrolloff':\ 1000                     :set so=1000<CR>
    an 970.10  ⚙️&\\.--4-- <Nop>
    an 970.10  ⚙️&\\.Set\ Text\ Width                       :call <SID>SetTextWidth()<CR>
    an <silent> 970.10  ⚙️&\\.Set\ Line\ Endings\ ('fileformat')     :call <SID>SetLineEndings()<CR>
    an 970.10  ⚙️&\\.--5-- <Nop>
    an 970.10  ⚙️&\\.Set\ 'path'                            :call <SID>SetPath()<CR>
    an 970.10  ⚙️&\\.Set\ 'tags'                            :call <SID>SetTags()<CR>
    "TODO: add set *prg
    "TODO: add set *path
    an 970.10  ⚙️&\\.--6-- <Nop>
    if has("win32") || has("gui_gtk") || has("gui_mac")
      an 970.10 ⚙️&\\.Select\ Fo&nt\.\.\.                   :set guifont=*<CR>
    endif
    an 970.10  ⚙️&\\.--7-- <Nop>
    an 970.10.10  ⚙️&\\.Syntax.On                           :syn on<CR>
    an 970.10.10  ⚙️&\\.Syntax.Manual                       :syn manual<CR>
    an 970.10.10  ⚙️&\\.Syntax.Off                          :syn off<CR>
    an 970.10  ⚙️&\\.--8-- <Nop>
    an 970.10  ⚙️&\\.Toggle\ Verbosity<Tab>=oV              :VerbosityToggle<CR>
    an 970.10  ⚙️&\\.Open\ Verbosity\ Log<Tab>goV           :VerbosityOpenLast<CR>
    an 970.10  ⚙️&\\.--9-- <Nop>
    an 970.10  ⚙️&\\.Settings\ Buffer<Tab>:options          :options<CR>
    an 970.10  ⚙️&\\.Open\ $VIMRUNTIME\ Folder              :tabnew<CR>:Fern $VIMRUNTIME<CR>

    " Show current maps (nnoremap, etc.)
    an 980.10  ⌨️&\|.Maps <Nop>
    an disable ⌨️&\|.Maps
    an 980.10  ⌨️&\|.C&hoose\.\.\.                          :Clap maps<CR>
    an 980.10  ⌨️&\|.Information <Nop>
    an disable ⌨️&\|.Information
    an 980.10  ⌨️&\|.Cursor\ Filename<Tab><C-g>             <C-g>
    an 980.10  ⌨️&\|.Cursor\ Position<Tab>g<C-g>            g<C-g>
    an 980.10  ⌨️&\|.Character\ under\ Cursor<Tab>g8        g8
    an 980.10  ⌨️&\|.Ascii\ under\ Cursor<Tab>ga            ga
    an 980.10  ⌨️&\|.Output\ of\ previous\ Command<Tab>g<   g<
    an 980.10  ⌨️&\|.List\ All\ QF                          :clist!<CR>
    an 980.10  ⌨️&\|.List\ All\ LL                          :llist!<CR>
    an 980.10  ⌨️&\|.List\ QF\ Lists                        :chistory<CR>
    an 980.10  ⌨️&\|.List\ LL\ Lists                        :lhistory<CR>
    an 980.10  ⌨️&\|.Co&lor\ Test                           :sp $VIMRUNTIME/syntax/colortest.vim<Bar>so %<CR>
    an 980.10  ⌨️&\|.&Highlight\ Test                       :runtime syntax/hitest.vim<CR>
    an 980.10  ⌨️&\|.Run\ Vim\ Script                       :browse so<CR>
    an 980.10  ⌨️&\|.Ex\ Vim\ Mode\ (Dangerous!)<Tab>gX     gQ
    an 980.10  ⌨️&\|.Ex\ Mode\ (Dangerous!)<Tab>Q           Q

    " Help
    an 990.10  ❔&?.Help <Nop>
    an disable ❔&?.Help
    an 990.10  ❔&?.&Lookup\ Word\ under\ Cursor<Tab>K         K
    an 990.20  ❔&?.Inde&x                                     :h index<CR>
    an 990.30  ❔&?.&QuickRef                                  :h quickref<CR>
    an 990.40  ❔&?.&Plugins\ Documentation                    :h local-additions<CR>
    an 990.50  ❔&?.View\ Log\ Messages<Tab>:messages          :messages<CR>
    an 990.60  ❔&?.--1-- <Nop>
    an 990.70  ❔&?.View\ &PlanetVim\ Community                :silent !xdg-open https://matrix.to/\#/+planetvim:matrix.org<CR>
    an 990.70  ❔&?.&Join\ PlanetVim\ Chat                     :silent !xdg-open https://matrix.to/\#/\#planetvim_discussion:matrix.org?via=matrix.org<CR>
    an 990.80  ❔&?.--2-- <Nop>
    an 990.90  ❔&?.Check\ for\ &Updates                       :silent !xdg-open https://github.com/fedorenchik/PlanetVim/releases<CR>
    an 990.100 ❔&?.Add\ Feature\ Request                      :silent !xdg-open 'https://github.com/fedorenchik/PlanetVim/issues/new?assignees=&labels=enhancement&template=feature_request.md&title='<CR>
    an 990.100 ❔&?.Report\ PlanetVim\ &Issue                  :silent !xdg-open 'https://github.com/fedorenchik/PlanetVim/issues/new?assignees=&labels=&template=bug_report.md&title'=<CR>
    an 990.110 ❔&?.--3-- <Nop>
    an 990.110 ❔&?.Others.Emergency\ Exit                     :call PlanetVim_EmergencyExit()<CR>
    an 990.110 ❔&?.--4-- <Nop>
    an 990.110 ❔&?.&Close\ Help\ Window                       :helpclose<CR>
    an 990.110 ❔&?.--5-- <Nop>
    an 990.120 ❔&?.&About                                     :version<CR>
  else
    silent! aunmenu 📁&f
    silent! aunmenu 📝&e
    silent! aunmenu ✏️&m
    silent! aunmenu 🔎&/
    silent! aunmenu 🖍️&s
    silent! aunmenu 📺&v
    silent! aunmenu ↕️&g
    silent! aunmenu 🧭&n
    silent! aunmenu ⌨️&\\
    silent! aunmenu ⚙️&\|
    silent! aunmenu ❔&h
  endif
endfunction
call PlanetVim_MenusBasicUpdate()

if ! exists("g:PlanetVim_menus_editing")
  let g:PlanetVim_menus_editing = 1
endif
function! PlanetVim_MenusEditingUpdate() abort
  if g:PlanetVim_menus_editing
    " Vim Registers
    an 200.10  📋&i.Registers <Nop>
    an disable 📋&i.Registers
    an 200.10  📋&i.C&hoose\ to\ Paste\.\.\.              :Clap registers<CR>
    an 200.10  📋&i.Select\ to\ Edit\.\.\.                :call <SID>registers_choose_to_edit()<CR>
    an 200.10  📋&i.Select\ for\ Operator<Tab>"<a-z>      "
    an 200.10  📋&i.Macros <Nop>
    an disable 📋&i.Macros
    an 200.10  📋&i.Start/Stop\ Record<Tab>q{0-9a-z"}     q
    an 200.10  📋&i.Execute<Tab>@{a-z}                    @
    an 200.10  📋&i.Repeat\ Execute<Tab>@@                @@
    "TODO: Add all non-empty registers to this menu

    " signature.vim (marks)
    an 210.10  🔖&'.Marks <Nop>
    an disable 🔖&'.Marks
    an 210.10  🔖&'.C&hoose<Tab>:Clap\ marks                  :Clap marks<CR>
    an 210.10  🔖&'.Select<Tab>'{a-z}                         '
    an 210.10  🔖&'.Open\ LocList<Tab>m/                      m/
    an 210.20  🔖&'.--1-- <Nop>
    an 210.30  🔖&'.Add<Tab>m,                                m,
    an 210.40  🔖&'.Toggle<Tab>m\.                            m.
    an 210.50  🔖&'.Delete<Tab>m-                             m-
    an 210.60  🔖&'.Delete\ All<Tab>m<Space>                  m<Space>
    an 210.70  🔖&'.--2-- <Nop>
    an 210.90  🔖&'.Previous<Tab>['                           [`
    an 210.80  🔖&'.Next<Tab>]'                               ]`
    an 210.100 🔖&'.Next\ Alphabetically<Tab>`]               `]
    an 210.110 🔖&'.Previous\ Alphabetically<Tab>`]           `[
    an 210.120 🔖&'.--3-- <Nop>
    an 210.110 🔖&'.Previous\ Jump<Tab>''                     ``
    an 210.110 🔖&'.Go\ to\ Mark<Tab>'{a-z}                   `
    an 210.120 🔖&'.--3-- <Nop>
    an 210.110 🔖&'.Set\ Mark<Tab>m{a-z}                      m

    " markers
    "TODO: maybe change to subsubmenus for groups: add, delete, next, prev
    am 220.10  🏷️&".Markers <Nop>
    am disable 🏷️&".Markers
    am 220.10  🏷️&".Add\ &1                              m1
    am 220.20  🏷️&".Add\ &2                              m2
    am 220.30  🏷️&".Add\ &3                              m3
    am 220.40  🏷️&".Add\ &4                              m4
    am 220.50  🏷️&".Add\ &5                              m5
    am 220.60  🏷️&".Add\ &6                              m6
    am 220.70  🏷️&".Add\ &7                              m7
    am 220.80  🏷️&".Add\ &8                              m8
    am 220.90  🏷️&".Add\ &9                              m9
    am 220.100 🏷️&".Add\ &0                              m0
    am 220.110 🏷️&".--1-- <Nop>
    am 220.120 🏷️&".Remove\ 1\ (&!)                      m!
    am 220.130 🏷️&".Remove\ 2\ (&@)                      m@
    am 220.140 🏷️&".Remove\ 3\ (&#)                      m#
    am 220.150 🏷️&".Remove\ 4\ (&$)                      m$
    am 220.160 🏷️&".Remove\ 5\ (&%)                      m%
    am 220.170 🏷️&".Remove\ 6\ (&^)                      m^
    am 220.180 🏷️&".Remove\ 7\ (&&)                      m&
    am 220.190 🏷️&".Remove\ 8\ (&*)                      m*
    am 220.200 🏷️&".Remove\ 9\ (&()                      m(
    am 220.210 🏷️&".Remove\ 0\ (&))                      m)
    am 220.220 🏷️&".--2-- <Nop>
    am 220.230 🏷️&".To\ &Next\ of\ Same\ Group<Tab>]-    ]-
    am 220.240 🏷️&".To\ &Previous\ of\ Same\ Group<Tab>[- [-
    am 220.250 🏷️&".To\ N&ext\ of\ Any\ Group<Tab>]=     ]=
    am 220.260 🏷️&".To\ Previous\ of\ Any\ Group<Tab>[=  [=
    am 220.270 🏷️&".--3-- <Nop>
    am 220.280 🏷️&".Open\ &LocList<Tab>m?                m?
    am 220.290 🏷️&".--4-- <Nop>
    am 220.290 🏷️&".Toggle\ All                          :SignatureToggleSigns<CR>
    am 220.290 🏷️&".--4-- <Nop>
    am 220.300 🏷️&".&Remove\ All<Tab>m<BS>               m<BS>

    " Cololr highlight words with mark.vim plugin
    an 230.10  🖌️&c.CMarks <Nop>
    an disable 🖌️&c.CMarks
    an 230.10  🖌️&c.CMark\ &Current<Tab>,m                   <Leader>m
    an 230.10  🖌️&c.CMark\ &Regex<Tab>,r                     <Leader>r
    an 230.10  🖌️&c.List\ All                                :Marks<CR>
    an 230.10  🖌️&c.Toggle\ All<Tab>,M                       <Leader>M
    an 230.10  🖌️&c.Delete\ All<Tab>,N                       :MarkClear<CR>
    an 230.10  🖌️&c.--1-- <Nop>
    an 230.10  🖌️&c.Matches <Nop>
    an disable 🖌️&c.Matches
    an 230.10  🖌️&c.Add\ Match\ Regex                        :call matchadd(highlight_group, pattern)<CR>
    " Add Match Position is useful when editing binary/hex files
    an 230.10  🖌️&c.Add\ Match\ Position                     :call matchaddpos(highlight_group, visual_position)<CR>
    an 230.10  🖌️&c.Delete\ Match                            :call matchdelete(id)<CR>
    an 230.10  🖌️&c.Clear\ All\ Matches                      :call clearmatches()<CR>

    " Bookmarks: Upper-case marks (mA-mZ)
    an 240.10  📎&k.Bookmarks <Nop>
    an disable 📎&k.Bookmarks
    an 240.10  📎&k.Open\ LocList                         :SignatureListGlobalMarks<CR>

    " Folds
    an 250.10  📜&z.Folds <Nop>
    an disable 📜&z.Folds
    an 250.20  📜&z.Fold\ by\ &Syntax<Tab><A-z>s            :setlocal foldmethod=syntax<CR>
    an 250.30  📜&z.Fold\ by\ &Indent<Tab><A-z>i            :setlocal foldmethod=indent<CR>
    an 250.40  📜&z.Fold\ by\ E&xpr<Tab><A-z>x              :setlocal foldmethod=expr<CR>
    an 250.50  📜&z.Fold\ by\ Mar&kers<Tab><A-z>k           :setlocal foldmethod=marker<CR>
    an 250.100 📜&z.Manua&l<Tab><A-z>l                      :setlocal foldmethod=manual<CR>
    an 250.110 📜&z.--1-- <Nop>
    an 250.120 📜&z.&Open<Tab>zo                            zo
    an 250.130 📜&z.&Close<Tab>zc                           zc
    an 250.140 📜&z.Toggle\ (&a)<Tab>za                     za
    an 250.150 📜&z.Open\ One\ Level\ (&w)<Tab>zr           zr
    an 250.160 📜&z.Close\ One\ Level\ (&b)<Tab>zm          zm
    an 250.170 📜&z.Open\ All\ (&r)<Tab>zR                  zR
    an 250.180 📜&z.Close\ All\ (&m)<Tab>zM                 zM
    an 250.190 📜&z.--2-- <Nop>
    an 250.200 📜&z.Open\ till\ Cursor\ &Visible<Tab>zv     zv
    an 250.200 📜&z.Open\ only\ Cursor\ Line<Tab>zMzx       zMzx
    an 250.210 📜&z.Open\ All\ at\ Cursor\ (&g)<Tab>zO      zO
    an 250.220 📜&z.Close\ All\ at\ Cursor\ (&h)<Tab>zC     zC
    an 250.230 📜&z.Toggle\ All\ at\ Cursor\ (&z)<Tab>zA    zA
    an 250.240 📜&z.Apply\ 'foldlevel'\ &&\ Open\ at\ Cursor\ (&j)<Tab>zx zx
    an 250.250 📜&z.Apply\ 'foldlevel'\ (&q)<Tab>zX         zX
    an 250.260 📜&z.--3-- <Nop>
    an 250.270 📜&z.&Previous<Tab>zk                        zk
    an 250.280 📜&z.&Next<Tab>zj                            zj
    an 250.290 📜&z.--4-- <Nop>
    an 250.300 📜&z.Cr&eate<Tab>zf                          zf
    an 250.320 📜&z.--5-- <Nop>
    an 250.330 📜&z.&Delete<Tab>zd                          zd
    an 250.340 📜&z.Delete\ All\ at\ Cursor\ (&@)<Tab>zD    zD
    an 250.350 📜&z.Delete\ All\ (&\\)<Tab>zE               zE
    an 250.360 📜&z.--6-- <Nop>
    an 250.370 📜&z.Update\ All\ Folds\ (&')<Tab>zuz        zuz
    an 250.380 📜&z.--7-- <Nop>
    an 250.390 📜&z.Advanced\ (&\.).&Enable<Tab>zN          zN
    an 250.400 📜&z.Advanced\ (&\.).&Disable<Tab>zn         zn
    an 250.410 📜&z.Advanced\ (&\.).&Toggle\ Enable<Tab>zi  zi
    an 250.410 📜&z.Advanced\ (&\.).--8-- <Nop>
    an 250.410 📜&z.Advanced\ (&\.).&Increase\ 'foldcolumn' :set foldcolumn+=1<CR>
    an 250.410 📜&z.Advanced\ (&\.).Dec&rease\ 'foldcolumn' :set foldcolumn-=1<CR>
    an 250.410 📜&z.Advanced\ (&\.).--9-- <Nop>
    an 250.410 📜&z.Advanced\ (&\.).Run\ Command\ on\ &Visible\ Lines :folddoopen 
    an 250.410 📜&z.Advanced\ (&\.).Run\ Command\ on\ &Folded\ Lines  :folddoclosed 
    an 250.410 📜&z.AutoFold <Nop>
    an disable 📜&z.AutoFold
    an 250.410 📜&z.Enable\ Au&toFold                       :call <SID>AutoFoldEnable()<CR>
    an 250.410 📜&z.Increase\ 'foldlevel'\ (&y)             :setlocal foldlevel+=1<CR>
    an 250.410 📜&z.Decrease\ '&foldlevel'                  :setlocal foldlevel-=1<CR>
    an 250.410 📜&z.Disable\ A&utoFold                      :call <SID>AutoFoldDisable()<CR>

    " quickfix
    " TODO: set 'errorfile' 'makeef' 'errorformat' 'makeprg' 'grepprg'
    " TODO: 'grepformat'
    " TODO: Add copy to LL, merge with previous, choose list, delete current,
    " TODO: delete all
    an 260.10  &QF.QuickFix <Nop>
    an disable &QF.QuickFix
    an 260.20  &QF.Sea&rch                                      :Grepper -tool rg -quickfix<CR>
    an 260.30  &QF.Search\ Add                                  :Grepper -tool rg -quickfix -append<CR>
    an 260.40  &QF.Search\ Side                                 :Grepper -tool rg -quickfix -side<CR>
    an 260.50  &QF.F&ind<Tab>:Cfind!                            :Cfind! 
    an 260.60  &QF.Loc&ate<Tab>:Clocate!                        :Clocate! 
    an 260.70  &QF.&Grep<Tab>:grep                              :grep 
    an 260.80  &QF.GrepAdd\ (&b)<Tab>:grepadd                   :grepadd 
    an 260.90  &QF.&VimGrep<Tab>:vimgrep                        :vimgrep 
    an 260.100 &QF.Vi&mGrepAdd<Tab>:vimgrepadd                  :vimgrepadd 
    an 260.110 &QF.TODO                                         :Grepper -quickfix -noprompt -tool rg -query -E '(TODO\|FIXME\|XXX):'
    an 260.120 &QF.--1-- <Nop>
    an 260.130 &QF.C&hoose<Tab>:Clap\ quickfix                  :Clap quickfix<CR>
    an 260.140 &QF.--2-- <Nop>
    am 260.150 &QF.&First<Tab>:cfirst<Tab>[Q                    [Q
    an 260.160 &QF.Previou&s\ File<Tab>:cpfile<Tab>[<C-q>       :cpfile<CR>
    am 260.170 &QF.&Previous<Tab>[q                             [q
    am 260.180 &QF.&Next<Tab>]q                                 ]q
    an 260.190 &QF.N&ext\ File<Tab>:cnfile<Tab>]<C-q>           :cnfile<CR>
    am 260.200 &QF.&Last<Tab>:clast<Tab>]Q                      ]Q
    an 260.210 &QF.--3-- <Nop>
    an 260.220 &QF.E&xecute\ for\ each<Tab>:cdo                 :cdo 
    an 260.230 &QF.Execute\ for\ each\ File\ (&z)<Tab>:cfdo     :cfdo 
    an 260.240 &QF.--4-- <Nop>
    an 260.250 &QF.&Open<Tab>:copen                             :copen<CR>
    an 260.260 &QF.Fil&ter<Tab>:Cfilter                         :Cfilter 
    an 260.270 &QF.Filter\ O&ut<Tab>:Cfilter!                   :Cfilter! 
    an 260.280 &QF.E&dit<Tab>:Qflistsplit<Tab>c\\q              :Qflistsplit<CR>
    an 260.290 &QF.Read\ from\ File\ (&w)<Tab>:cgetfile         :cgetfile! 
    an 260.300 &QF.Add\ from\ File\ (&y)<Tab>:caddfile          :caddfile! 
    an 260.310 &QF.Read\ from\ Buffer\ (&,)<Tab>:cgetbuffer     :cgetbuffer! 
    an 260.320 &QF.Add\ from\ Buffer\ (&\.)<Tab>:caddbuffer     :caddbuffer! 
    an 260.330 &QF.Read\ from\ Expr\ (&;)<Tab>:cgetexpr         :cgetexpr! 
    an 260.340 &QF.Add\ from\ Expr\ (&')<Tab>:caddexpr          :caddexpr! 
    an 260.350 &QF.&Close<Tab>:cclose<Tab>                      :cclose<CR>
    an 260.360 &QF.--5-- <Nop>
    an 260.370 &QF.Previous\ LocList\ (&k)<Tab>:colder          :colder<CR>
    an 260.380 &QF.Next\ LocList\ (&j)<Tab>:cnewer              :cnewer<CR>
    an 260.390 &QF.List\ LocLists\ (&q)<Tab>:chistory           :chistory<CR>

    " loclist
    an 270.10  &LL.LocList <Nop>
    an disable &LL.LocList
    an 270.20  &LL.Sea&rch                                      :Grepper -tool rg -noquickfix<CR>
    an 270.30  &LL.Search\ Add                                  :Grepper -tool rg -noquickfix -append<CR>
    an 270.40  &LL.Search\ Side                                 :Grepper -tool rg -noquickfix -side<CR>
    an 270.50  &LL.F&ind<Tab>:Lfind!                            :Lfind! 
    an 270.60  &LL.Loc&ate<Tab>:Llocate!                        :Llocate! 
    an 270.70  &LL.&Grep<Tab>:lgrep                             :lgrep 
    an 270.80  &LL.GrepAdd\ (&b)<Tab>:lgrepadd                  :lgrepadd 
    an 270.90  &LL.&VimGrep<Tab>:lvimgrep                       :lvimgrep 
    an 270.100 &LL.Vi&mGrepAdd<Tab>:lvimgrepadd                 :lvimgrepadd 
    an 270.110 &LL.TODO                                         :Grepper -noquickfix -noprompt -tool rg -query -E '(TODO\|FIXME\|XXX):'
    an 270.120 &LL.--1-- <Nop>
    an 270.130 &LL.C&hoose<Tab>:Clap\ loclist                   :Clap loclist<CR>
    an 270.140 &LL.--2-- <Nop>
    am 270.150 &LL.&First<Tab>:lfirst<Tab>[L                    [L
    an 270.160 &LL.Previou&s\ File<Tab>:lpfile<Tab>[<C-l>       :lpfile<CR>
    am 270.170 &LL.&Previous<Tab>[l                             [l
    am 270.180 &LL.&Next<Tab>]l                                 ]l
    an 270.190 &LL.N&ext\ File<Tab>:lnfile<Tab>]<C-l>           :lnfile<CR>
    am 270.200 &LL.&Last<Tab>:llast<Tab>]L                      ]L
    an 270.210 &LL.--3-- <Nop>
    an 270.220 &LL.E&xecute\ for\ each<Tab>:ldo                 :ldo 
    an 270.230 &LL.Execute\ for\ each\ File\ (&z)<Tab>:lfdo     :lfdo 
    an 270.240 &LL.--4-- <Nop>
    an 270.250 &LL.&Open<Tab>:lopen                             :lopen<CR>
    an 270.260 &LL.Fil&ter<Tab>:Lfilter                         :Lfilter 
    an 270.270 &LL.Filter\ O&ut<Tab>:Lfilter!                   :Lfilter! 
    an 270.280 &LL.E&dit<Tab>:Loclistsplit<Tab>c\\l             :Loclistsplit<CR>
    an 270.290 &LL.Read\ from\ File\ (&w)<Tab>:lgetfile         :lgetfile! 
    an 270.300 &LL.Add\ from\ File\ (&y)<Tab>:laddfile          :laddfile! 
    an 270.310 &LL.Read\ from\ Buffer\ (&,)<Tab>:lgetbuffer     :lgetbuffer! 
    an 270.320 &LL.Add\ from\ Buffer\ (&\.)<Tab>:laddbuffer     :laddbuffer! 
    an 270.330 &LL.Read\ from\ Expr\ (&;)<Tab>:lgetexpr         :lgetexpr! 
    an 270.340 &LL.Add\ from\ Expr\ (&')<Tab>:laddexpr          :laddexpr! 
    an 270.350 &LL.&Close<Tab>:lclose<Tab>                      :lclose<CR>
    an 270.360 &LL.--5-- <Nop>
    an 270.370 &LL.Previous\ LocList\ (&k)<Tab>:lolder          :lolder<CR>
    an 270.380 &LL.Next\ LocList\ (&j)<Tab>:lnewer              :lnewer<CR>
    an 270.390 &LL.List\ LocLists\ (&q)<Tab>:lhistory           :lhistory<CR>
  else
    silent! aunmenu 📋&i
    silent! aunmenu 🔖&'
    silent! aunmenu 🏷️&"
    silent! aunmenu 🖌️&c
    silent! aunmenu 📎&k
    silent! aunmenu 📜&z
    silent! aunmenu &QF
    silent! aunmenu &LL
  endif
endfunction
call PlanetVim_MenusEditingUpdate()

if ! exists("g:PlanetVim_menus_dev")
  let g:PlanetVim_menus_dev = 1
endif
function! PlanetVim_MenusDevelopmentUpdate() abort
  if g:PlanetVim_menus_dev
    " LSP
    an 300.10  ❇️&[.LSP <Nop>
    an disable ❇️&[.LSP
    an 300.10  ❇️&[.Choose\ Symbol<Tab>:Clap\ tags\ vim_lsp :Clap tags vim_lsp<CR>
    an 300.10  ❇️&[.Document\ Symbol\ Choose                :LspDocumentSymbolSearch<CR>
    an 300.10  ❇️&[.&Workspace\ Symbols\ Choose             :LspWorkspaceSymbolSearch<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.&Definition                             :LspDefinition<CR>
    an 300.10  ❇️&[.De&claration                            :LspDeclaration<CR>
    an 300.10  ❇️&[.&References                             :LspReferences<CR>
    an 300.10  ❇️&[.&Implementation                         :LspImplementation<CR>
    an 300.10  ❇️&[.&Type\ Definition                       :LspTypeDefinition<CR>
    an 300.10  ❇️&[.Type\ &Hierarchy                        :LspTypeHierarchy<CR>
    an 300.10  ❇️&[.&Incoming\ Call\ Hierarchy              :LspCallHierarchyIncoming<CR>
    an 300.10  ❇️&[.&Outgoing\ Call\ Hierarchy              :LspCallHierarchyOutgoing<CR>
    an 300.10  ❇️&[.Symbol\ Hover                           :LspHover<CR>
    an 300.10  ❇️&[.Document\ Semantic\ Scopes              :LspSemanticScopes<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Preview\ Definition                     :LspPeekDefinition<CR>
    an 300.10  ❇️&[.Preview\ Declaration                    :LspPeekDeclaration<CR>
    an 300.10  ❇️&[.Preview\ Implementation                 :LspPeekImplementation<CR>
    an 300.10  ❇️&[.Preview\ Type\ Definition               :LspPeekTypeDefinition<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Rename                                  :LspRename<CR>
    an 300.10  ❇️&[.Code\ Action\ (LSP\ Quick\ &Fix)        :LspCodeAction<CR>
    an 300.10  ❇️&[.Code\ &Lens                             :LspCodeLens<CR>
    an 300.10  ❇️&[.Format\ Document                        :LspDocumentFormat<CR>
    an 300.10  ❇️&[.Format\ Document\ Selection             :LspDocumentRangeFormat<CR>
    an 300.10  ❇️&[.Update\ Document\ Folds                 :call PlanetVim_LSPUpdateFolds()<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Document\ Symbols                       :LspDocumentSymbol<CR>
    an 300.10  ❇️&[.Workspace\ Symbols                      :LspWorkspaceSymbol<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.&Previous\ Reference                    :LspPreviousReference<CR>
    an 300.10  ❇️&[.&Next\ Reference                        :LspNextReference<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Document\ Diagnostics                   :LspDocumentDiagnostics<CR>
    an 300.10  ❇️&[.Diagnostics\ (all\ buffers)             :LspDocumentDiagnostics --buffers=*<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Previous\ Error                         :LspPreviousError -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Error                             :LspNextError -wrap=0<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Previous\ Warning                       :LspPreviousWarning -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Warning                           :LspNextWarning -wrap=0<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Previous\ Diagnostic                    :LspPreviousDiagnostic -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Diagnostic                        :LspNextDiagnostic -wrap=0<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Status.LSP\ Status                      :LspStatus<CR>
    an 300.10  ❇️&[.Status.Disable\ LSP                     :LspStopServer<CR>

    " Tags
    an 310.10  🪧&].Tags <Nop>
    an disable 🪧&].Tags
    an 310.10  🪧&].C&hoose<Tab>:Clap\ tags\ ctags           :Clap tags ctags<CR>
    an 310.10  🪧&].&Jump\ to\ Tag<Tab><C-]>                 <C-]>
    an 310.10  🪧&].&Jump\ Back<Tab><C-t>                    <C-t>
    an 310.10  🪧&].&Jump\ or\ Select\ Tag<Tab>g<C-]>        g<C-]>
    an 310.10  🪧&].&Select\ Tag<Tab>g]                      g]
    an 310.10  🪧&].Jump\ Split\ to\ Tag<Tab>+]              <C-w>]
    an 310.10  🪧&].Jump\ or\ Select\ Split\ to\ Tag<Tab>+g<C-]> <C-w>g<C-]>
    an 310.10  🪧&].Select\ Split\ Tag<Tab>+g]               <C-w>g]
    an 310.10  🪧&].Go\ to\ Tag\ VSplit<Tab>:vert stag       :vert stag <cword><CR>
    an 310.10  🪧&].--1-- <Nop>
    an 310.10  🪧&].Preview\ Tag<Tab>+}                      <C-w>}
    an 310.10  🪧&].Select\ Preview\ Tag<Tab>+g}             <C-w>g}
    an 310.10  🪧&].Preview\ Previous\ Tag<Tab>:ppop         :ppop<CR>
    an 310.10  🪧&].Close\ Preview<Tab>+z                    <C-w>z
    an 310.10  🪧&].--2-- <Nop>
    an 310.10  🪧&].Preview\ File<Tab>:pedit                 :pedit 
    an 310.10  🪧&].Preview\ Search<Tab>:psearch             :psearch 
    an 310.10  🪧&].--2-- <Nop>
    am 310.10  🪧&].First<Tab>[T                             [T
    am 310.10  🪧&].Previous<Tab>[t                          [t
    am 310.10  🪧&].Next<Tab>]t                              ]t
    am 310.10  🪧&].Last<Tab>]T                              ]T
    an 310.10  🪧&].--3-- <Nop>
    am 310.10  🪧&].Preview\ Previous<Tab>[<C-t>             [<C-t>
    am 310.10  🪧&].Preview\ Next<Tab>]<C-t>                 ]<C-t>
    an 310.10  🪧&].--4-- <Nop>
    am 310.10  🪧&].Toggle\ AutoPreview\ Tags                :call PlanetVim_TagsAutoPreview_Toggle()<CR>
    an 310.10  🪧&].--4-- <Nop>
    am 310.10  🪧&].Build\ tags\ File                        :!ctags -R .<CR>

    " Build
    " Build process:
    " * Project Settings
    "         * direnv
    "         * editorconfig
    "         * arduino
    "         * platformio
    " * Setup Libs
    "         * qt
    "         * pkgbuild
    "         * meson-wrapdb
    "         * boost
    " * Package manager
    "         * conan
    "         * pip
    " * virtual envs
    "         * pipenv
    "         * conan virtual env
    "         * docker
    "         * vagrant
    " * Choose build system
    "         * Make
    "         * Autotools
    "         * CMake
    "         * Meson
    "         * QMake
    "         * qbs
    "         * scons
    "         * KBuild
    "         * gradle
    " * Choose Build Generator
    "         * Makefile
    "         * Ninja
    " * Choose compiler
    "         * gcc
    "         * clang
    "         * wasm / emcc / emscripten
    " * Set Cross-Compiler (build, host)
    "         * gcc-mingw
    "         * gcc-arm
    "         * etc...
    " * Set Canadian-Cross (build, host, target)
    " * Choose debugger
    "         * gdb
    "         * lldb
    " * Select build folder
    "   (search for ./build* and ../build* folders), choose new
    " * Configure
    "         * ./autotools
    "         * cmake ..
    "         * meson ..
    " * Build
    "         * cmake --build .
    "         * meson --build
    "         * make
    "         * ninja
    " * Run
    " * Debug
    " * Test
    "         * Qt Test
    "         * Google Test
    "         * Boost Test
    "         * Catch2
    " * Analyze
    "         * clang-tidy
    "         * clazy
    "         * cppcheck
    "         * performance analyzer (qtcreator)
    "         * valgrind memcheck
    "         * valgrind memcheck gdb
    "         * valgrind function profiler (qtcreator)
    "         * QML profiler (qtcreator)
    " * Package
    "         * fpm
    "         * pyinstaller
    "         * cpack
    "         * appimage
    "         * snap
    "         * deb
    "         * rpm
    "         * flatpak
    " * Deploy
    "         * winqtdeploy
    "         * macqtdeploy
    "         * linuxdeploy
    " * l10n & i18n:
    "         * qt tools: lupdate / lrelease (+ auto-translation)
    "         * gettext
    "         * weblate.org
    " * Documentation
    "         * doxygen
    "         * qt doc
    "         * qt help
    "         * readthedocs
    " * Create installer
    "         * qt-installer
    " * Tools
    "         * uic
    "         * moc
    "         * rcc
    "         * flex / lex
    "         * bison /yacc
    "         * `$QMAKE -query QT_INSTALL_BINS`/designer
    "         * qt.conf support (generate, update)
    " * Choose Build Target
    " Menus:
    " Build
    " Run
    " Debug
    " Test
    " Analyze
    an 500.10  🔨&u.Build <Nop>
    an disable 🔨&u.Build
    an 500.10  🔨&u.Choose\ Make\ Target                      :make <C-z>"TODO
    an 500.10  🔨&u.Rerun\ Previous\ Make                     :make prev_target
    an 500.10  🔨&u.Make                                      :Make<CR>
    an 500.10  🔨&u.Make!                                     :Make<CR>
    an 500.10  🔨&u.Copen                                     :Make<CR>
    an 500.10  🔨&u.Copen!                                    :Make<CR>
    an 500.10  🔨&u.Dispatch!                                 :Make<CR>
    an 500.10  🔨&u.FocusDispatch!                            :Make<CR>
    an 500.10  🔨&u.AbortDispatch                             :Make<CR>
    an 500.10  🔨&u.Start                                     :Make<CR>
    an 500.10  🔨&u.Spawn                                     :Make<CR>
    an 500.10  🔨&u.--1-- <Nop>
    an 500.10  🔨&u.Set\ Compiler\ Globally<Tab>:compiler!\ {compiler} :compiler! 
    an 500.10  🔨&u.Set\ Compiler\ for\ Buffer<Tab>:compiler\ {compiler} :compiler 

    " Run
    an 510.10  ▶️&r.Run <Nop>
    an disable ▶️&r.Run
    an 510.10  ▶️&r.Configurations                              :

    " Debug
    an 520.10  🐞&d.Debug <Nop>
    an disable 🐞&d.Debug
    an 520.10  🐞&d.Start\ &Debug                             :Vimspector<CR>
    an 520.10  🐞&d.Detach\ Debugger                          :Vimspector<CR>
    an 520.10  🐞&d.Stop\ &Debug                              :Vimspector<CR>
    an 520.10  🐞&d.--1-- <Nop>

    " Test
    an 530.10  🧪&j.Test <Nop>
    an disable 🧪&j.Test
    an 530.10  🧪&j.Nearest                                 :TestNearest<CR>
    an 530.10  🧪&j.File                                    :TestFile<CR>
    an 530.10  🧪&j.Suite                                   :TestSuite<CR>
    an 530.10  🧪&j.Last                                    :TestLast<CR>
    an 530.10  🧪&j.Visit                                   :TestVisit<CR>

    " Analyze
    an 540.10  🔬&y.Analyze <Nop>
    an disable 🔬&y.Analyze
    an 540.10  🔬&y.Check                                   :
    an 540.10  🔬&y.Clang-Tidy                                :Vimspector<CR>
    an 540.10  🔬&y.Clazy                                     :Vimspector<CR>
    an 540.10  🔬&y.Cppcheck                                  :Vimspector<CR>
    an 540.10  🔬&y.Chrome\ Trace\ Format\ Visualizer         :Vimspector<CR>
    an 540.10  🔬&y.Performance\ Analyzer                     :Vimspector<CR>
    an 540.10  🔬&y.Memcheck                                  :Vimspector<CR>
    an 540.10  🔬&y.Callgrind                                 :Vimspector<CR>

    " Terminal
    an 550.10  💻&t.Terminal <Nop>
    an disable 💻&t.Terminal
    an 550.10  💻&t.N&ew\ Here                             :terminal ++curwin ++kill=kill<CR>
    an 550.10  💻&t.N&ew\ VSplit                           :vertical terminal ++kill=kill<CR>
    an 550.10  💻&t.N&ew\ Tab                              :tab terminal ++kill=kill<CR>
    an 550.10  💻&t.&New\ Below                            :rightbelow terminal ++kill=kill ++rows=10<CR>
    an 550.10  💻&t.New\ at\ &Bottom                       :botright terminal ++kill=kill ++rows=10<CR>
    an 550.10  💻&t.--1-- <Nop>
    an 550.10  💻&t.P&ython\ Shell                         :botright terminal ++kill=kill ++rows=10 python<CR>
    an 550.10  💻&t.C&++\ Shell                            :botright terminal ++kill=kill ++rows=10 cling<CR>
    an 550.10  💻&t.Terminal\ List <Nop>
    an disable 💻&t.Terminal\ List
  else
    silent! aunmenu ❇️&[
    silent! aunmenu 🪧&]
    silent! aunmenu 🔨&u
    silent! aunmenu ▶️&r
    silent! aunmenu 🐞&d
    silent! aunmenu 🧪&j
    silent! aunmenu 🔬&y
    silent! aunmenu 💻&t
  endif
endfunction
call PlanetVim_MenusDevelopmentUpdate()

"TODO: menus:
"C++
"Python
"Arduino
"PlatformIO
"CMake
"Meson
"Conan
"Qt (uic, moc, rcc, lupdate, lrelease, shiboken)
"SWIG, 
"Latex
"Writing
"Docker
"Yocto
"ROS
"gdb/lldb
"cppcheck/clazy/clang-tidy
"indent/astyle/clang-format
"LKD: linux kernel development: patches, checkpatch.pl, get-maintainers.sh, send-email
"kvm,virsh,qemu cli
"chroot,schroot,conan_venv
"unreal engine, godot

" Writing
an 720.10  ]Writing.Writing <Nop>
an disable ]Writing.Writing
an 720.20  ]Writing.Swap\ Words                   :TODO
an 720.20  ]Writing.Swap\ Words\ After            :TODO
an 720.40  ]Writing.Thesaurus                     :TODO
an 720.50  ]Writing.Generate\ Sample\ Text        :TODO
an 720.50  ]Writing.Left\ Align<Tab>:left         :left<CR>
an 720.50  ]Writing.Center\ Align<Tab>:center     :center<CR>
an 720.50  ]Writing.Right\ Align<Tab>:right       :right<CR>

if ! exists("g:PlanetVim_menus_tools")
  let g:PlanetVim_menus_tools = 1
endif
function! PlanetVim_MenusToolsUpdate() abort
  if g:PlanetVim_menus_tools
    " Git
    " Open Log in new window
    an 700.10  🔀&,.Git <Nop>
    an disable 🔀&,.Git
    an 700.10  🔀&,.AutoCommit\ File                      :TODO
    an 700.10  🔀&,.AutoCommit\ File\ &&\ Push            :TODO
    an 700.10  🔀&,.AutoCommit\ All                       :TODO
    an 700.10  🔀&,.AutoCommit\ &&\ Push                  :TODO
    an 700.10  🔀&,.Set\ AutoCommit\ on\ File\ Write      :TODO
    an 700.10  🔀&,.Stop\ AutoCommit\ on\ File\ Write     :TODO
    an 700.10  🔀&,.--1-- <Nop>
    an 700.10  🔀&,.Log\ File\ QF                         :TODO
    an 700.10  🔀&,.Log\ File\ LL                         :TODO
    an 700.10  🔀&,.Log\ QF                               :TODO
    an 700.10  🔀&,.Log\ LL                               :TODO
    an 700.10  🔀&,.Log\ in\ New\ GWindow                 :TODO
    an 700.10  🔀&,.Status                                :TODO
    an 700.10  🔀&,.Commit\ All                           :TODO
    an 700.10  🔀&,.Commit\ File                          :TODO
    an 700.10  🔀&,.Commit\ File                          :TODO
    an 700.10  🔀&,.Clone\ Project                        :TODO
    an 700.10  🔀&,.Init\ Project                         :TODO
    an 700.10  🔀&,.Blame                                 :TODO
    " tpope/rhubarb.vim plugin for GitHub
    an 700.10  🔀&,.GitHub <Nop>
    an disable 🔀&,.GitHub

    " Diff/Patch
    an 710.10  ⛏️&;.Diff/Patch <Nop>
    an disable ⛏️&;.Diff/Patch
    an 710.10  ⛏️&;.DiffOrig                          :DiffOrig<CR>
    an 710.20  ⛏️&;.Diff\ with\ file\.\.\.            :browse vert diffsplit<CR>
    an 710.30  ⛏️&;.Diff\ with\ patch\.\.\.           :browse vert diffpatch<CR>
    an 710.40  ⛏️&;.--1-- <Nop>
    an 710.40  ⛏️&;.Previous\ Hunk<Tab>[c             [c
    an 710.40  ⛏️&;.Next\ Hunk<Tab>]c                 ]c
    an 710.40  ⛏️&;.--2-- <Nop>
    am 710.40  ⛏️&;.Previous\ Conflict\ Marker<Tab>[n [n
    am 710.40  ⛏️&;.Next\ Conflict\ Marker<Tab>]n     ]n
    an 710.40  ⛏️&;.--3-- <Nop>
    an 710.40  ⛏️&;.Get\ Diff<Tab>:diffget<Tab>do     do
    an 710.40  ⛏️&;.Put\ Diff<Tab>:diffput<Tab>dp     dp
    an 710.40  ⛏️&;.--4-- <Nop>
    an 710.40  ⛏️&;.Diff\ All\ in\ Tab                :windo diffthis<CR>
    an 710.40  ⛏️&;.Diff\ with\ Alternate\ Winodw     :diffthis<CR>:wincmd p<CR>:diffthis<CR>
    an 710.40  ⛏️&;.--4-- <Nop>
    an 710.40  ⛏️&;.Set\ Context\ Lines               :set diffopt+=context=12<CR>

    " Spelling (& Dictionary & Thesaurus)
    an 720.10  🔠&-.Spelling <Nop>
    an disable 🔠&-.Spelling
    an 720.10  🔠&-.Enable<Tab>:set\ spell                  :set spell<CR>
    an 720.10  🔠&-.Disable<Tab>:set\ nospell               :set nospell<CR>
    am 720.10  🔠&-.Toggle<Tab>yos                          yos
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Previous\ Misspelled<Tab>[s         [s
    an 720.10  🔠&-.Next\ Misspelled<Tab>]s             ]s
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Spelling\ Suggestions<Tab>z=        z=
    an 720.10  🔠&-.Repeat Correction<Tab>:spellrepall  :spellrepall<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Mark\ as\ Correct\ Temp<Tab>zG      zG
    an 720.10  🔠&-.Mark\ as\ Incorrect\ Temp<Tab>zG    zW
    an 720.10  🔠&-.Mark\ as\ Correct<Tab>zg            zg
    an 720.10  🔠&-.Mark\ as\ Incorrect<Tab>zw          zw
    an 720.10  🔠&-.Unmark\ as\ Correct\ Temp<Tab>zG    zuG
    an 720.10  🔠&-.Unmark\ as\ Incorrect\ Temp<Tab>zG  zuW
    an 720.10  🔠&-.Unmark\ as\ Correct<Tab>zg          zug
    an 720.10  🔠&-.Unmark\ as\ Incorrect<Tab>zw        zuw
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Set\ Language\ to\ "en"             :set spl=en spell<CR>

    " Tools
    " TODO: add all '*.prg' options, eg: equalprg, keywordprg, etc.
    an 730.10  🔧&o.Tools <Nop>
    an disable 🔧&o.Tools
    an 730.10  🔧&o.Colori&ze                                 :ColorToggle<CR>
    an 730.10  🔧&o.--1-- <Nop>
    an 730.10  🔧&o.&direnv:\ Run\ \.envrc                    :DirenvExport<CR>
    an 730.10  🔧&o.dire&nv:\ Edit\ \.envrc                   :EditEnvrc<CR>
    an 730.10  🔧&o.diren&v:\ Edit\ direnvrc                  :EditDirenvrc<CR>
    an 730.10  🔧&o.--5-- <Nop>
    an 730.10  🔧&o.Edit\ Command<Tab>:                       q:
    an 730.10  🔧&o.Edit\ Search<Tab>q/                       q/
    an 730.10  🔧&o.Edit\ Search\ Backwards<Tab>q?            q?
    an 730.10  🔧&o.--5-- <Nop>
    an 730.10  🔧&o.Convert\ to\ HEX<Tab>:%!xxd             :call <SID>XxdToHex()<CR>
    an 730.10  🔧&o.Convert\ from\ HEX<Tab>:%!xxd\ -r       :call <SID>XxdFromHex()<CR>
  else
    silent! aunmenu 🔀&,
    silent! aunmenu ⛏️&;
    silent! aunmenu 🔤&-
    silent! aunmenu 🔧&o
  endif
endfunction
call PlanetVim_MenusToolsUpdate()

if ! exists("g:PlanetVim_menus_nav")
  let g:PlanetVim_menus_nav = 1
endif
function! PlanetVim_MenusNavigationUpdate() abort
  if g:PlanetVim_menus_nav
    " Buffers
    an 800.10  📖&b.Buffers <Nop>
    an disable 📖&b.Buffers
    an 800.10  📖&b.C&hoose\.\.\.                           :Clap buffers<CR>
    an 800.10  📖&b.Manager\.\.\.                           :Bufexplorer<CR>
    an 800.10  📖&b.Open<Tab>:b                             :b 
    an 800.10  📖&b.Open\ VSplit<Tab>:vert sb               :vert sb 
    an 800.10  📖&b.Open\ Tab<Tab>:tab sb                   :tab sb 
    an 800.10  📖&b.Open\ All\ Loaded\ VSplit<Tab>:vert unh :vert unh<CR>
    an 800.10  📖&b.Open\ All\ Loaded\ Tab<Tab>:tab unh     :tab unh<CR>
    an 800.10  📖&b.Open\ All\ VSplit<Tab>:vert ba          :vert ba<CR>
    an 800.10  📖&b.Open\ All\ Tab<Tab>:tab ba              :tab ba<CR>
    an 800.20  📖&b.--1-- <Nop>
    an 800.30  📖&b.&Alternate<Tab>:b\ #<Tab><C-@>          <C-^>
    an 800.30  📖&b.&Alternate\ Split<Tab>+^                <C-w>^
    an 800.40  📖&b.--2-- <Nop>
    an 800.30  📖&b.Next\ Modified<Tab>:bm                  :bm<CR>
    an 800.30  📖&b.Next\ Modified\ VSplit<Tab>:vert sbm    :vert sbm<CR>
    an 800.30  📖&b.Next\ Modified\ Tab<Tab>:tab sbm        :tab sbm<CR>
    an 800.40  📖&b.--3-- <Nop>
    an 800.40  📖&b.&First<Tab>[B                           :bf<CR>
    an 800.40  📖&b.&Previous<Tab>[b                        :bp<CR>
    an 800.40  📖&b.&Next<Tab>]b                            :bn<CR>
    an 800.40  📖&b.&Last<Tab>]B                            :bl<CR>
    an 800.40  📖&b.&First\ VSplit<Tab>:vert sbf            :vert sbf<CR>
    an 800.40  📖&b.&Previous\ VSplit<Tab>:vert sbp         :vert sbp<CR>
    an 800.40  📖&b.&Next\ VSplit<Tab>:vert sbn             :vert sbn<CR>
    an 800.40  📖&b.&Last\ VSplit<Tab>:vert sbl             :vert sbl<CR>
    an 800.40  📖&b.&First\ Tab<Tab>:tab sbf                :tab sbf<CR>
    an 800.40  📖&b.&Previous\ Tab<Tab>:tab sbp             :tab sbp<CR>
    an 800.40  📖&b.&Next\ Tab<Tab>:tab sbn                 :tab sbn<CR>
    an 800.40  📖&b.&Last\ Tab<Tab>:tab sbl                 :tab sbl<CR>
    an 800.40  📖&b.--4-- <Nop>
    an 800.40  📖&b.Add<Tab>:badd                           :badd 
    an 800.40  📖&b.Add\ as\ Alternate<Tab>:balt            :balt 
    an 800.40  📖&b.Unload\ (Free\ Memory)                  :bun<CR>
    an 800.40  📖&b.Delete\ (Unload\ &&\ Unlist)            :bd<CR>
    an 800.40  📖&b.Wipeout\ (Delete\ &&\ Clear\ Everything) :bw<CR>
    an 800.40  📖&b.--5-- <Nop>
    an 800.40  📖&b.Delete\ All\ Hidden\ Buffers            :call PlanetVim_DeleteBuffers()<CR>
    an 800.40  📖&b.Execute\ in\ Each\ Buffer<Tab>:bufdo    :bufdo 
    an 800.50  📖&b.Buffers\ List <Nop>
    an disable 📖&b.Buffers\ List

    " Arg List
    an 810.10  🗃️&a.Args <Nop>
    an disable 🗃️&a.Args
    an 810.10  🗃️&a.Drop<Tab>:drop                             :drop %<CR>
    an 810.10  🗃️&a.&Add                                       :argadd<CR>
    an 810.10  🗃️&a.&Delete                                    :argdelete<CR>
    an 810.10  🗃️&a.&First<Tab>[A                              :first<CR>
    an 810.10  🗃️&a.&Previous<Tab>[a                           :previous<CR>
    an 810.10  🗃️&a.&Next<Tab>]a                               :next<CR>
    an 810.10  🗃️&a.&Last<Tab>]A                               :last<CR>
    an 810.10  🗃️&a.&First\ VSplit<Tab>[A                      :vert sfirst<CR>
    an 810.10  🗃️&a.&Previous\ VSplit<Tab>[a                   :vert sprevious<CR>
    an 810.10  🗃️&a.&Next\ VSplit<Tab>]a                       :vert snext<CR>
    an 810.10  🗃️&a.&Last\ VSplit<Tab>]A                       :vert slast<CR>
    an 810.10  🗃️&a.&First\ Tab<Tab>[A                         :tab first<CR>
    an 810.10  🗃️&a.&Previous\ Tab<Tab>[a                      :tab previous<CR>
    an 810.10  🗃️&a.&Next\ Tab<Tab>]a                          :tab next<CR>
    an 810.10  🗃️&a.&Last\ Tab<Tab>]A                          :tab last<CR>
    an 810.10  🗃️&a.All\ VSplit<Tab>:vert\ all                 :tabnew<CR>:vert all<CR>
    an 810.10  🗃️&a.All\ Tab<Tab>:tab\ all                     :tab all<CR>
    an 810.10  🗃️&a.--1-- <Nop>
    an 810.10  🗃️&a.Execute\ in\ Each\ Argument<Tab>:argdo     :argdo 
    an 810.10  🗃️&a.--1-- <Nop>
    an 810.10  🗃️&a.Set\ Local                                 :argl<CR>
    an 810.10  🗃️&a.Set\ Global                                :argg<CR>
    an 810.10  🗃️&a.--2-- <Nop>
    an 810.10  🗃️&a.Run\ Each                                  :argdo<CR>
    an 810.10  🗃️&a.--3-- <Nop>
    an 810.10  🗃️&a.Args\ List <Nop>
    an disable 🗃️&a.Args\ List

    " Vim Windows
    an 820.10  🪟&w.Windows <Nop>
    an disable 🪟&w.Windows
    an 820.10  🪟&w.&Window\ Mode                           :WindowMode<CR>
    an 820.10  🪟&w.--1-- <Nop>
    an 820.10  🪟&w.C&hoose<Tab>:Clap\ windows              :Clap windows<CR>
    an 820.10  🪟&w.--2-- <Nop>
    an 820.10  🪟&w.&Vertical\ Split<Tab>:vsplit<Tab>+v     <C-w>v
    an 820.10  🪟&w.Horizontal\ &Split<Tab>:split<Tab>+s    <C-w>s
    an 820.10  🪟&w.--3-- <Nop>
    an 820.10  🪟&w.Swap\ (&x)<Tab>+x                       <C-w>x
    an 820.10  🪟&w.Rotate\ Up<Tab>R                        <C-w>R
    an 820.10  🪟&w.Rotate\ Down<Tab>r                      <C-w>r
    an 820.10  🪟&w.Move\ to\ Left<Tab>+H                   <C-w>H
    an 820.10  🪟&w.Move\ to\ Right<Tab>+L                  <C-w>L
    an 820.10  🪟&w.Move\ to\ Top<Tab>+K                    <C-w>K
    an 820.10  🪟&w.Move\ to\ Bottom<Tab>+J                 <C-w>J
    an 820.10  🪟&w.Move\ to\ New\ &Tab<Tab>+T              <C-w>T
    an 820.10  🪟&w.Move\ to\ New\ &GUI\ Window             :TODO
    an 820.10  🪟&w.Copy\ to\ New\ Tab<Tab>+s+T             <C-w>s<C-w>T
    an 820.10  🪟&w.--4-- <Nop>
    an 820.10  🪟&w.&Equal\ Size<Tab>+=                     <C-w>=
    an 820.10  🪟&w.&Maximize<Tab>+_+\|                     :call PlanetVim_Window_Maximize()<CR>
    an 820.10  🪟&w.&Unmaximize<Tab>                        :call PlanetVim_Window_Restore()<CR>
    an 820.10  🪟&w.Resize.Maximize\ &Vertically<Tab>+_     <C-w>_
    an 820.10  🪟&w.Resize.Maximize\ &Horizontally<Tab>+\|  <C-w>\|
    an 820.10  🪟&w.Resize.Increase\ Height<Tab>++          <C-w>+
    an 820.10  🪟&w.Resize.Decrease\ Height<Tab>+-          <C-w>-
    an 820.10  🪟&w.Resize.Increase\ Width<Tab>+>           <C-w>>
    an 820.10  🪟&w.Resize.Decrease\ Width<Tab>+<           <C-w><
    an 820.10  🪟&w.--6-- <Nop>
    an 820.10  🪟&w.Focus\ Alternate<Tab>+p                 <C-w>p
    an 820.10  🪟&w.Focus\ Preview\ Window<Tab>+P           <C-w>P
    an 820.10  🪟&w.Focus\ Previous\ Window<Tab>+W          <C-w>W
    an 820.10  🪟&w.Focus\ Next\ Window<Tab>+w              <C-w>w
    an 820.10  🪟&w.Focus\ Top\ Window<Tab>+t               <C-w>t
    an 820.10  🪟&w.Focus\ Bottom\ Window<Tab>+b            <C-w>b
    an 820.10  🪟&w.Focus\ Left<Tab>+h                      :call FocusWindow('h')<CR>
    an 820.10  🪟&w.Focus\ Right<Tab>+l                     :call FocusWindow('l')<CR>
    an 820.10  🪟&w.Focus\ Up<Tab>+k                        <C-w>k
    an 820.10  🪟&w.Focus\ Down<Tab>+j                      <C-w>j
    an 820.10  🪟&w.--8-- <Nop>
    an 820.10  🪟&w.View.Save                               :mkview<CR>
    an 820.10  🪟&w.View.Save\ 1                            :mkview 1<CR>
    an 820.10  🪟&w.View.Save\ 2                            :mkview 2<CR>
    an 820.10  🪟&w.View.Save\ 3                            :mkview 3<CR>
    an 820.10  🪟&w.View.Save\ 4                            :mkview 4<CR>
    an 820.10  🪟&w.View.Save\ 5                            :mkview 5<CR>
    an 820.10  🪟&w.View.Save\ 6                            :mkview 6<CR>
    an 820.10  🪟&w.View.Save\ 7                            :mkview 7<CR>
    an 820.10  🪟&w.View.Save\ 8                            :mkview 8<CR>
    an 820.10  🪟&w.View.Save\ 9\ (AutoSave)                :mkview 9<CR>
    an 820.10  🪟&w.View.--1-- <Nop>
    an 820.10  🪟&w.View.Load                               :loadview<CR>
    an 820.10  🪟&w.View.Load\ 1                            :loadview 1<CR>
    an 820.10  🪟&w.View.Load\ 2                            :loadview 2<CR>
    an 820.10  🪟&w.View.Load\ 3                            :loadview 3<CR>
    an 820.10  🪟&w.View.Load\ 4                            :loadview 4<CR>
    an 820.10  🪟&w.View.Load\ 5                            :loadview 5<CR>
    an 820.10  🪟&w.View.Load\ 6                            :loadview 6<CR>
    an 820.10  🪟&w.View.Load\ 7                            :loadview 7<CR>
    an 820.10  🪟&w.View.Load\ 8                            :loadview 8<CR>
    an 820.10  🪟&w.View.Load\ 9\ (AutoSave)                :loadview 9<CR>
    an 820.10  🪟&w.View.--2-- <Nop>
    an 820.10  🪟&w.View.Toggle\ AutoSave\ Views            :call PlanetVim_View_ToggleAutosave()<CR>
    an 820.10  🪟&w.View.--2-- <Nop>
    an 820.10  🪟&w.View.Toggle\ Save\ Local\ Options       :TODO
    an 820.10  🪟&w.--7-- <Nop>
    an 820.10  🪟&w.Execute\ in\ Window\ in\ This\ Tab      :windo 
    an 820.10  🪟&w.Execute\ in\ each\ Window               :tabdo windo 
    an 820.10  🪟&w.--5-- <Nop>
    an 820.10  🪟&w.--9-- <Nop>
    an 820.10  🪟&w.&Close<Tab>:close<Tab>+c                <C-w>c
    an 820.10  🪟&w.Close\ &Other\ Windows<Tab>:only<Tab>+o <C-w>o

    " Tabs
    an 830.10  🗂️&\..Tabs <Tabs>
    an disable 🗂️&\..Tabs
    an 830.10  🗂️&\..N&ew<Tab>:tabnew                       :tabnew<CR>
    an 830.10  🗂️&\..--1-- <Nop>
    an 830.10  🗂️&\..&Alternate<Tab>g\<Tab\>                g<Tab>
    an 830.10  🗂️&\..--2-- <Nop>
    an 830.10  🗂️&\..&First<Tab>:tabfirst                   :tabfirst<CR>
    an 830.10  🗂️&\..&Previous<Tab><C-PgUp><Tab>gT          gT
    an 830.10  🗂️&\..&Next<Tab><C-PgDown><Tab>gt            gt
    an 830.10  🗂️&\..&Last<Tab>:tablast                     :tablast<CR>
    an 830.10  🗂️&\..--3-- <Nop>
    an 830.10  🗂️&\..Move\ First<Tab>:0tabmove              :0tabmove<CR>
    an 830.10  🗂️&\..Move\ Previous<Tab>:-tabmove           :-tabmove<CR>
    an 830.10  🗂️&\..Move\ Next<Tab>:+tabmove               :+tabmove<CR>
    an 830.10  🗂️&\..Move\ Last<Tab>:tabmove                :tabmove<CR>
    an 830.10  🗂️&\..--4-- <Nop>
    an 830.10  🗂️&\..Save\ Current\ Tab                     :TODO"save session without tabpages (as .vimtab file)(set sessionoptions-=tabpages,winpos)
    an 830.10  🗂️&\..Open\ Tab\.\.\.                        :TODO"open (source) .vimtab file in new tab
    an 830.10  🗂️&\..--5-- <Nop>
    an 830.10  🗂️&\..E&xecute\ in\ each\ Tab<Tab>:tabdo     :tabdo 
    an 830.10  🗂️&\..--6-- <Nop>
    an 830.10  🗂️&\..&Close<Tab>:tabclose                   :tabclose<CR>
    an 830.10  🗂️&\..Close\ all\ &other\ tabs<Tab>:tabonly  :tabonly<CR>

    " Sessions
    an 840.10  📚&h.Sessions <Nop>
    an disable 📚&h.Sessions
    "TODO: add autocmd SessionLoadPost to update current session
    "an 840.10  📚&h.Current:\ v:this_session               <Nop>
    an 840.40  📚&h.--1-- <Nop>
    an 840.50  📚&h.&Save                                  :exe 'SSave! ' .. fnamemodify(v:this_session, ":t")<CR>
    an 840.60  📚&h.Save\ &As\.\.\.                        :SSave<CR>
    an 840.70  📚&h.--2-- <Nop>
    an 840.50  📚&h.Advanced\ Save.Save\ with\ Relative\ Paths :TODO"set sessionoptions-=sesdir,+=curdir,v:this_session=dirname
    an 840.50  📚&h.Advanced\ Save.Save\ with\ Local\ Options :TODO"set sessionoptions+=localoptions
    an 840.50  📚&h.Advanced\ Save.Save\ with\ All\ Options :TODO"set sessionoptions+=localoptions,options
    an 840.50  📚&h.Advanced\ Save.Save\ without\ Global\ Vars :TODO"set sessionoptions-=globals
    an 840.70  📚&h.--2-- <Nop>
    an 840.80  📚&h.&Open                                  :SLoad<CR>
    an 840.90  📚&h.Open\ &Last\ Session                   :SLoad!<CR>
    an 840.100 📚&h.&Reopen                                :exe 'SLoad ' .. fnamemodify(v:this_session, ":t")<CR>
    an 840.110 📚&h.--3-- <Nop>
    an 840.120 📚&h.&Close                                 :SClose<CR>
    an 840.130 📚&h.--4-- <Nop>
    an 840.140 📚&h.&Delete                                :SDelete<CR>
    an 840.500 📚&h.Session\ List <Nop>
    an disable 📚&h.Session\ List

    " Control GUI window with wmctrl & vim servers
    an 850.10  🔰&x.GUI <Nop>
    an disable 🔰&x.GUI
    an 850.10  🔰&x.&Maximize            :silent call system('wmctrl -i -b toggle,maximized_vert,maximized_horz -r' . v:windowid)<CR>
    an 850.10  🔰&x.&Full\ Screen        :silent call system('wmctrl -i -b toggle,fullscreen -r' . v:windowid)<CR>
    an 850.10  🔰&x.Minimi&ze<Tab>:suspend<Tab><C-z>         <C-z>
    an 850.10  🔰&x.--1-- <Nop>
    an 850.10  🔰&x.Vim\ Servers <Nop>
    an disable 🔰&x.Vim\ Servers
    an 850.10  🔰&x.GUI\ Windows <Nop>
    an disable 🔰&x.GUI\ Windows
    "TODO: List of GUI windows to focus

    " Vim Apps: Open in new GUI window
    an 860.10  🎛️&@.Apps <Nop>
    an disable 🎛️&@.Apps
    an 860.10  🎛️&@.Calendar            :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +Calendar<CR>
    an 860.10  🎛️&@.Web\ Browser        :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'W3m https://google.com/'<CR>
    an 860.10  🎛️&@.Calculator          :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +Calculator<CR>
    an 860.10  🎛️&@.Terminal            :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'terminal ++curwin ++kill=kill'<CR>
    an 860.10  🎛️&@.File\ Manager       :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'Fern .'<CR>
    an 860.10  🎛️&@.Python\ Notebook    :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'Codi python'<CR>
    an 860.10  🎛️&@.C++\ Notebook       :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'Codi cpp'<CR>
    "TODO: Email
    "TODO: difdiff
  else
    silent! aunmenu 📖&b
    silent! aunmenu 🗃️&a
    silent! aunmenu 🪟&w
    silent! aunmenu 🗂️&\.
    silent! aunmenu 📚&h
    silent! aunmenu 🔰&x
    silent! aunmenu 🎛️&@
  endif
endfunction
call PlanetVim_MenusNavigationUpdate()

function! PlanetFiletypeMenus() abort
  "TODO: for arduino, c++, python, etc.
endfunction

function! PlanetSaveExit() abort
  if ! empty(v:this_session)
    exe 'SSave! ' .. fnamemodify(v:this_session, ":t")
  endif
  confirm wall
  qa!
endfunction

fun! s:ToggleGuiOption(option)
    " If a:option is already set in guioptions, then we want to remove it
    if match(&guioptions, "\\C" . a:option) > -1
      exec "set go-=" . a:option
    else
      exec "set go+=" . a:option
    endif
endfun

function! PlanetVim_ModelessToggle() abort
  set im!
  set sm!
  if empty(&selectmode)
    set selectmode=mouse,key
  else
    set selectmode=
  endif
  if empty(&keymodel)
    set keymodel=startsel,stopsel
  else
    set keymodel=
  endif
  call <SID>ToggleGuiOption('c')
  call <SID>ToggleGuiOption('r')
endfunction

an 100.10  🌐&P.PlanetVim <Nop>
an disable 🌐&P.PlanetVim
an 100.10  🌐&P.New\ &PlanetVim                             :silent !gvim<CR>
an 100.20  🌐&P.--1-- <Nop>
an 100.10  🌐&P.&Toggle\ Modeless                           :call PlanetVim_ModelessToggle()<CR>
an 100.10  🌐&P.&Toggle\ HJKL                               :call PlanetVim_HJKLToggle()<CR>
an 100.20  🌐&P.--2-- <Nop>
an 100.30  🌐&P.&Basic\ Menus                         :call PlanetVim_MenusBasicToggle()<CR>
an 100.40  🌐&P.&Editing\ Menus                       :call PlanetVim_MenusEditingToggle()<CR>
an 100.50  🌐&P.&Development\ Menus                   :call PlanetVim_MenusDevelopmentToggle()<CR>
an 100.60  🌐&P.&Tools\ Menus                         :call PlanetVim_MenusToolsToggle()<CR>
an 100.70  🌐&P.&Navigation\ Menus                    :call PlanetVim_MenusNavigationToggle()<CR>
an 100.80  🌐&P.--3-- <Nop>
an 100.90  🌐&P.Edit\ &Settings                       :tabedit ~/.vim/planetvimrc.vim<CR>
an 100.100 🌐&P.--4-- <Nop>
an 100.110 🌐&P.&Close\ Everything                    :cd<CR>:SClose<CR>
an 100.120 🌐&P.--5-- <Nop>
an 100.130 🌐&P.Save\ &&\ E&xit\ PlanetVim            :call PlanetSaveExit()<CR>
" }}}
" PopUp Menus: {{{

if has("spell")
  " Spell suggestions in the popup menu.  Note that this will slow down the
  " appearance of the menu!
  func s:SpellPopup()
    if exists("s:changeitem") && s:changeitem != ''
      call <SID>SpellDel()
    endif

    " Return quickly if spell checking is not enabled.
    if !&spell || &spelllang == ''
      return
    endif

    let curcol = col('.')
    let [w, a] = spellbadword()
    if col('.') > curcol		" don't use word after the cursor
      let w = ''
    endif
    if w != ''
      if a == 'caps'
	let s:suglist = [substitute(w, '.*', '\u&', '')]
      else
	let s:suglist = spellsuggest(w, 10)
      endif
      if len(s:suglist) > 0
	if !exists("g:menutrans_spell_change_ARG_to")
	  let g:menutrans_spell_change_ARG_to = 'Change\ "%s"\ to'
	endif
	let s:changeitem = printf(g:menutrans_spell_change_ARG_to, escape(w, ' .'))
	let s:fromword = w
	let pri = 1
	" set 'cpo' to include the <CR>
	let cpo_save = &cpo
	set cpo&vim
	for sug in s:suglist
	  exe 'anoremenu 1.5.' . pri . ' PopUp.' . s:changeitem . '.' . escape(sug, ' .')
		\ . ' :call <SID>SpellReplace(' . pri . ')<CR>'
	  let pri += 1
	endfor

	if !exists("g:menutrans_spell_add_ARG_to_word_list")
	  let g:menutrans_spell_add_ARG_to_word_list = 'Add\ "%s"\ to\ Word\ List'
	endif
	let s:additem = printf(g:menutrans_spell_add_ARG_to_word_list, escape(w, ' .'))
	exe 'anoremenu 1.6 PopUp.' . s:additem . ' :spellgood ' . w . '<CR>'

	if !exists("g:menutrans_spell_ignore_ARG")
	  let g:menutrans_spell_ignore_ARG = 'Ignore\ "%s"'
	endif
	let s:ignoreitem = printf(g:menutrans_spell_ignore_ARG, escape(w, ' .'))
	exe 'anoremenu 1.7 PopUp.' . s:ignoreitem . ' :spellgood! ' . w . '<CR>'

	anoremenu 1.8 PopUp.-SpellSep- :
	let &cpo = cpo_save
      endif
    endif
    call cursor(0, curcol)	" put the cursor back where it was
  endfunc

  func s:SpellReplace(n)
    let l = getline('.')
    " Move the cursor to the start of the word.
    call spellbadword()
    call setline('.', strpart(l, 0, col('.') - 1) . s:suglist[a:n - 1]
	  \ . strpart(l, col('.') + len(s:fromword) - 1))
  endfunc

  func s:SpellDel()
    exe "aunmenu PopUp." . s:changeitem
    exe "aunmenu PopUp." . s:additem
    exe "aunmenu PopUp." . s:ignoreitem
    aunmenu PopUp.-SpellSep-
    let s:changeitem = ''
  endfun

  augroup SpellPopupMenu
    au! MenuPopup * call <SID>SpellPopup()
  augroup END
endif

" Normal Mode:
nnoremenu 1.10 PopUp.&Paste                  "+gP
nnoremenu 1.10 PopUp.Close                   <C-w>c
" Operator Pending Mode: text objects
onoremenu PopUp.Word                         w
" Visual:
vnoremenu 1.10 PopUp.Cu&t                    "+x
vnoremenu 1.10 PopUp.&Copy                   "+y
vnoremenu 1.10 PopUp.&Yank                   y
vnoremenu 1.10 PopUp.&Replace                "_x"+gP
vnoremenu 1.10 PopUp.&Paste                  "_x"+gP
vnoremenu 1.10 PopUp.&Delete                 "_x
" Select Mode:
snoremenu 1.10 PopUp.Cut                     "+d
" Insert Mode:
inoremenu 1.10 PopUp.&Paste                  <C-o>"+gP
inoremenu 1.10 PopUp.Close                   <C-w>c
" Cmdline Mode: cmdline completion
cnoremenu 1.10 PopUp.&Copy                  <C-y>
cnoremenu 1.10 PopUp.&Paste                 <C-r>+
" Terminal Mode:
tlnoremenu 1.10 PopUp.Close                  <C-w><C-c>
" }}}
" WinBar Menus: {{{
" TODO: Auto for LL, QF, Terminals, W3m
" QF, LL: colder, cnewer, chistory popup, merge with prev, filter, filter-out,
" min size, std size(10lines), max size
function! PlanetVim_WinBarFilter(bang) abort
  let m = mode()
  if m == 'n'
    exe "Cfilter" .. a:bang .. " " .. expand('<cword>')
  elseif match("vVsS", m) != -1
    normal! y
    exe 'Cfilter' .. a:bang .. ' <C-r>"'
  endif
endfunction
function! PlanetVim_WinBarQfInit() abort
  nnoremenu 1.10 WinBar.⏪ :colder<CR>
  "TODO: turn :chistory into popup menu
  nnoremenu 1.20 WinBar.📙 :chistory<CR>
  nnoremenu 1.30 WinBar.⏩ :cnewer<CR>
  nnoremenu 1.40 WinBar.✅ <CR>
  nnoremenu 1.50 WinBar.📤 :call PlanetVim_WinBarFilter('!')<CR>
  nnoremenu 1.60 WinBar.📥 :call PlanetVim_WinBarFilter('')<CR>
  nnoremenu 1.100 WinBar.⬇️ z0<CR>
  nnoremenu 1.110 WinBar.↕️ 10<C-w>_
  nnoremenu 1.120 WinBar.⬆️ <C-w>_
  nnoremenu 1.130 WinBar.❌ :cclose<CR>
endfunction
" Terminals: Previous, Next, List (popup with choose), New, Close (send Ctrl-D)
" W3m: Back, Forward, History, AddressBar
function! PlanetVim_WinBarTerminalInit() abort
  nnoremenu 1.10  WinBar.⏪ :echo 'TODO'<CR>
  nnoremenu 1.20  WinBar.📙 :echo 'TODO'<CR>
  nnoremenu 1.30  WinBar.⏩ :echo 'TODO'<CR>
  nnoremenu 1.40  WinBar.➕ :terminal ++curwin ++kill=kill<CR>
  nnoremenu 1.100 WinBar.⬇️       z0<CR>
  nnoremenu 1.110 WinBar.↕️       10<C-w>_
  nnoremenu 1.120 WinBar.⬆️       <C-w>_
  nnoremenu 1.130 WinBar.❌       <C-w><C-c>
endfunction
aug PlanetVim_AugroupWinBar
au!
au BufWinEnter * if &buftype == 'quickfix' | call PlanetVim_WinBarQfInit() | endif
au BufWinLeave * if &buftype == 'quickfix' | nunmenu WinBar | endif
au TerminalWinOpen * call PlanetVim_WinBarTerminalInit()
au BufWinEnter * if &buftype == 'terminal' | call PlanetVim_WinBarTerminalInit() | endif
aug END
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
let g:fastfold_fold_command_suffixes = []
let g:fastfold_fold_movement_commands = []
let g:fastfold_force = 1
let g:fastfold_fdmhook = 1
let g:fastfold_minlines = 0
" fold text objects
xnoremap iz :<c-u>FastFoldUpdate<cr><esc>:<c-u>normal! ]zv[z<cr>
xnoremap az :<c-u>FastFoldUpdate<cr><esc>:<c-u>normal! ]zV[z<cr>
" }}}
" Plugin: fern.vim {{{
let g:fern#hide_cursor = 1
let g:fern#keepalt_on_edit = 1
let g:fern#keepjumps_on_edit = 1
let g:fern#drawer_width = 40
nnoremap <silent> - :Fern -reveal=% .<CR>
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
let g:clap_provider_colors_ignore_default = v:true
let g:clap_preview_direction = 'UD'
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

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

function! StatusLine(current, width)
  let l:s = ''

  if a:current
    let l:s .= crystalline#mode()
    "FIXME: not immediately updated (use :redrawstatus or fix window_mode)
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
    let l:s .= ' %{NearestMethodOrFunction()}'
    let l:s .= crystalline#left_sep('', 'Fill') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    let l:s .= "%{StatusLine_SearchCount()}"
    let l:s .= "%{exists('*CapsLockStatusline')?CapsLockStatusline():''}"
    let l:s .= ' %{grepper#statusline()}'
    let l:s .= crystalline#left_mode_sep('')
  endif
  if a:width > 80
    let l:s .= ' %{&ft}'
    let l:e = &fenc!=#""?&fenc:&enc
    if l:e != 'utf-8'
      let l:s .= '[%{&fenc!=#""?&fenc:&enc}]'
    endif
    if &ff != 'unix'
      let l:s .= '[%{&ff}]'
    endif
    let l:s .= ' %l/%L %c%V %P '
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
" Plugin: vim-dispatch {{{
let g:dispatch_no_maps = 1
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
let g:SignatureDeleteConfirmation = 0
"XXX: Change to Purge=1 when bug with text dialogs fixed
let g:SignaturePurgeConfirmation = 0
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
let g:startify_fortune_use_unicode = 1
let g:startify_enable_unsafe = 1
let g:startify_session_sort = 1
let g:startify_custom_indices = ['d', 'g', 'h', 'l', 'm', 'n', 'p', 'r', 'u', 'w', 'x', 'y', 'z']
let g:startify_use_env = 1
aug PlanetVim_Startify
au!
autocmd User StartifyReady setlocal cursorline
autocmd User Startified nmap <buffer> I i
autocmd User Startified nmap <buffer> o i
autocmd User Startified nmap <buffer> O i
autocmd User Startified nmap <buffer> a i
autocmd User Startified nmap <buffer> A i
aug END
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
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
" }}}
" }}}
