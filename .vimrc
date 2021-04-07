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
" TODO: add menu to start server
" if empty(v:servername) && exists('*remote_startserver')
"   call remote_startserver('VIM')
" endif
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

func! SetupCommandAlias(input, output) abort
  exec 'cabbrev <expr> '.a:input
        \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:input.'")'
        \ .'? ("'.a:output.'") : ("'.a:input.'"))'
endfunc

let s:did_open_help = v:false
func! s:HelpCurwin(subject) abort
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

"TODO: add mod <Alt> - means search regex, e.g. '\.' when press '.'
"TODO:    (can use getcharmod())
let g:PV_p = '\.'
func! PlanetVim_f()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let g:PV_p = l:c1
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
endfunc

func! PlanetVim_F()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let g:PV_p = l:c1
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
endfunc

func! PlanetVim_t()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c2 = nr2char(l:c)
  let g:PV_p = l:c1 .. l:c2
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
endfunc

func! PlanetVim_T()
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c1 = nr2char(l:c)
  let l:c = getchar()
  if l:c == 27
    return
  end
  let l:c2 = nr2char(l:c)
  let g:PV_p = l:c1 .. l:c2
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
endfunc

func! PlanetVim_l()
  silent! exe "keepp keepj normal /\\V" .. g:PV_p .. "\<CR>"
endfunc

func! PlanetVim_h()
  silent! exe "keepp keepj normal ?\\V" .. g:PV_p .. "\<CR>"
endfunc

func! PlanetVim_j()
  try
    laf
  catch
    silent! lne
  endtry
endfunc

func! PlanetVim_k()
  try
    lbe
  catch
    silent! lp
  endtry
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
set guitablabel=%{g:GuiTabLabel()}
set guitabtooltip=%{g:GuiTabTooltip()}
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
nn ` '
nn ' `
nn <unique> ; q:i
nm + <C-W>
nn <silent> f :call PlanetVim_f()<CR>
nn <silent> F :call PlanetVim_F()<CR>
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
nn <silent> h :call PlanetVim_h()<CR>
nn <silent> j :call PlanetVim_j()<CR>
nn <silent> k :call PlanetVim_k()<CR>
nn <silent> l :call PlanetVim_l()<CR>
nn Q gq
nn s <Nop>
nn sb <Cmd>exe "lvimgrep /^\\s*" .. expand('<cword>') .. "/gj %"<CR>
nn sj :lvimgrep /^.*$/gj %<CR>
nn sk :lvimgrep /{{{/gj %<CR>
" fake marker for previous pattern: }}}
nn sw <Cmd>exe "lvimgrep /" .. expand('<cword>') .. "/gj %"<CR>
nn S <Nop>
nn <silent> t :call PlanetVim_t()<CR>
nn <silent> T :call PlanetVim_T()<CR>
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
nn <C-h> :call planet#window#Focus('h')<CR>
nn <C-j> <C-W>j
nn <C-k> <C-W>k
nn <C-l> :call planet#window#Focus('l')<CR>
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
inoremap <Tab> <Esc>
inoremap <expr> <CR> pumvisible() ? "<C-Y><CR>" : "<CR>"
" Ctrl Key: {{{
inoremap <C-@> <C-^>
inoremap <C-E> <C-R>=pumvisible() ? "\<lt>C-E>" : "\<lt>Esc>"<CR>
"inoremap <C-J> <Nop>
"inoremap <C-L> <Nop>
"inoremap <C-M> <Nop>
inoremap <C-Q> <Nop>
inoremap <C-S> <Nop>
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
autocmd InsertLeave * if empty(&buftype) | pclose | endif
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
" PlanetVim: {{{
" TODO: $VIMRUNTIME folder
" TODO: Vim help reference
" TODO: VS Code
" TODO: Qt Creator
" TODO: LibreOffice
" TODO: Use $VIMRUNTIME/tools/demoserver.py for controlling Vim
" TODO: Add Buffer Cmdline Window: Input commands and ouput results in
" TODO:    'prompt' buffer.
" TODO: Add sessions inside project dir support
" Custom config file: $HOME/.vim/planetvimrc.vim
let g:PV_config = "$HOME/.vim/planetvimrc.vim"
if filereadable(expand(g:PV_config))
  silent exe "source " .. fnameescape(g:PV_config)
endif

func! PlanetVim_AddMenuItem(priority, text, command, tooltip) abort
    an 110.10  &File.&New                                   :confirm enew<CR>
    an a:priority a:text a:command
    tln 110.10  &File.&New                                  :confirm enew<CR>
    no <A-f>n :confirm enew<CR>
    no a:map a:command
    ln <A-f>n :confirm enew<CR>
    tno <A-f>n :confirm enew<CR>
endfunc

func! PlanetVim_ConfigUpdate(conf_var) abort
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
endfunc

"TODO: add session support
func! PlanetVim_MenusBasicToggle() abort
  if g:PlanetVim_menus_basic
    let g:PlanetVim_menus_basic = 0
  else
    let g:PlanetVim_menus_basic = 1
  endif
  call planet#menu#basic#update()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_basic')
  endif
endfunc

func! PlanetVim_MenusEditingToggle() abort
  if g:PlanetVim_menus_editing
    let g:PlanetVim_menus_editing = 0
  else
    let g:PlanetVim_menus_editing = 1
  endif
  call planet#menu#edit#update()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_editing')
  endif
endfunc

func! PlanetVim_MenusDevelopmentToggle() abort
  if g:PlanetVim_menus_dev
    let g:PlanetVim_menus_dev = 0
  else
    let g:PlanetVim_menus_dev = 1
  endif
  call planet#menu#dev#update()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_dev')
  endif
endfunc

func! PlanetVim_MenusToolsToggle() abort
  if g:PlanetVim_menus_tools
    let g:PlanetVim_menus_tools = 0
  else
    let g:PlanetVim_menus_tools = 1
  endif
  call planet#menu#tools#update()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_tools')
  endif
endfunc

func! PlanetVim_MenusNavigationToggle() abort
  if g:PlanetVim_menus_nav
    let g:PlanetVim_menus_nav = 0
  else
    let g:PlanetVim_menus_nav = 1
  endif
  call planet#menu#nav#update()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_nav')
  endif
endfunc

func! PlanetVim_MenusSettingsToggle() abort
  if g:PlanetVim_menus_settings
    let g:PlanetVim_menus_settings = 0
  else
    let g:PlanetVim_menus_settings = 1
  endif
  call planet#menu#settings#update()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_nav')
  endif
endfunc

func! PlanetVim_MenusPlanetToggle() abort
  if g:PlanetVim_menus_planet
    let g:PlanetVim_menus_planet = 0
  else
    let g:PlanetVim_menus_planet = 1
  endif
  call planet#menu#planet#update()
  if empty(v:this_session)
    call PlanetVim_ConfigUpdate('g:PlanetVim_menus_nav')
  endif
endfunc

func! s:registers_choose_to_edit() abort
  echohl Question
  echo "Register: " buffest#reg_complete()
  let l:reg_to_edit = nr2char(getchar())
  if l:reg_to_edit == "\<Esc>"
    return
  endif
  echohl None
  execute("silent Regpedit " .. l:reg_to_edit)
  execute("silent normal \<C-w>P")
endfunc

func! s:SelectAll()
  exe "norm! gg" . (&slm == "" ? "VG" : "gH\<C-O>G")
endfunc

func! s:AutoFoldEnable()
  set foldclose=all
  set foldopen=all
  set foldlevel=0
  set foldlevelstart=0
endfunc

func! s:AutoFoldDisable()
  set foldclose=
  set foldopen=quickfix,tag,undo
  set foldlevel=20
  set foldlevelstart=20
endfunc

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

func! PlanetVim_MenuSessionSetCurrent() abort
  if exists('g:last_session')
    exe 'aun 📚&h.Current:\ ' .. g:last_session
    unlet g:last_session
  endif
  if ! empty(v:this_session)
    exe 'an 840.20  📚&h.Current:\ ' .. fnamemodify(v:this_session, ":t") .. ' <Nop>'
    let g:last_session = fnamemodify(v:this_session, ":t")
  endif
endfunc

func! PlanetVim_MenuSessionList() abort
  for session in startify#session_list('')
    exe 'an 840.500 📚&h.' .. session .. ' :SLoad ' .. session .. '<CR>'
  endfor
endfunc

aug PlanetVim_AugroupSessions
au!
au SessionLoadPost * call PlanetVim_MenuSessionSetCurrent()
au VimEnter * call PlanetVim_MenuSessionList()
aug END

func! PlanetVim_LSPUpdateFolds() abort
  set foldmethod=expr foldexpr=lsp#ui#vim#folding#foldexpr() foldtext=lsp#ui#vim#folding#foldtext()
  LspDocumentFold
endfunc

func! PlanetVim_EmergencyExit() abort
  set noautowrite
  set noautowriteall
  cquit!
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

func! PlanetVim_PrintAutotoolsStatus()
  " TODO
endfunc

"TODO: Add function to follow DE night mode & theme settings (auto switch
"TODO: guioptions+=d when dark theme, auto switch to dark colorscheme variant)

"TODO: add setting 'equalprg' for formatting wih == (clang-format, etc.)
"TODO: Choise between text, emoji, symbols, nerdicons menus
"TODO: Customize tabline-menu when vim bug #7991 is fixed
"TODO: Add prompt buffer to exec viml commands

"BUG: move menu functions into plugin, so no need to packadd first
packadd! planet.vim

if ! exists("g:PlanetVim_menus_basic")
  let g:PlanetVim_menus_basic = 1
endif
call planet#menu#basic#update()
if ! exists("g:PlanetVim_menus_settings")
  let g:PlanetVim_menus_settings = 1
endif
call planet#menu#settings#update()

if ! exists("g:PlanetVim_menus_editing")
  let g:PlanetVim_menus_editing = 1
endif
call planet#menu#edit#update()

if ! exists("g:PlanetVim_menus_dev")
  let g:PlanetVim_menus_dev = 1
endif
call planet#menu#dev#update()

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
an 600.10  ]Writing.Writing <Nop>
an disable ]Writing.Writing
an 600.20  ]Writing.Swap\ Words                   :TODO
an 600.20  ]Writing.Swap\ Words\ After            :TODO
an 600.40  ]Writing.Thesaurus                     :TODO
an 600.50  ]Writing.Generate\ Sample\ Text        :TODO
an 600.50  ]Writing.Left\ Align<Tab>:left         :left<CR>
an 600.50  ]Writing.Center\ Align<Tab>:center     :center<CR>
an 600.50  ]Writing.Right\ Align<Tab>:right       :right<CR>

if ! exists("g:PlanetVim_menus_tools")
  let g:PlanetVim_menus_tools = 1
endif
call planet#menu#tools#update()

if ! exists("g:PlanetVim_menus_nav")
  let g:PlanetVim_menus_nav = 1
endif
call planet#menu#nav#update()

if ! exists("g:PlanetVim_menus_planet")
  let g:PlanetVim_menus_planet = 1
endif
call planet#menu#planet#update()

func! PlanetFiletypeMenus() abort
  "TODO: for arduino, c++, python, etc.
endfunc

func! PlanetSaveExit() abort
  if ! empty(v:this_session)
    exe 'SSave! ' .. fnamemodify(v:this_session, ":t")
  endif
  confirm wall
  qa!
endfunc

func! s:ToggleGuiOption(option)
  " If a:option is already set in guioptions, then we want to remove it
  if match(&guioptions, "\\C" . a:option) > -1
    exec "set go-=" . a:option
  else
    exec "set go+=" . a:option
  endif
endfunc

func! PlanetVim_SetEasyMode() abort
  set im
  set selectmode=mouse,key
  set keymodel=startsel,stopsel
  set guioptions-=c
  set guioptions+=r
  nun h
  nun j
  nun k
  nun l
  nun f
  nun F
  nun t
  nun T
endfunc

func! PlanetVim_SetStandardMode()
  set noim
  set selectmode=
  set keymodel=
  set guioptions+=c
  set guioptions-=r
  nun h
  nun j
  nun k
  nun l
  nun f
  nun F
  nun t
  nun T
endfunc

func! PlanetVim_SetSuperChargedMode()
  set noim
  set selectmode=
  set keymodel=
  set guioptions+=c
  set guioptions-=r
  nn <silent> f :call PlanetVim_f()<CR>
  nn <silent> F :call PlanetVim_F()<CR>
  nn <silent> h :call PlanetVim_h()<CR>
  nn <silent> j :lbel<CR>
  nn <silent> k :lab<CR>
  nn <silent> l :call PlanetVim_l()<CR>
  nn <silent> t :call PlanetVim_t()<CR>
  nn <silent> T :call PlanetVim_T()<CR>
endfunc
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
func! PlanetVim_WinBarFilter(bang) abort
  let m = mode()
  if m == 'n'
    exe "Cfilter" .. a:bang .. " " .. expand('<cword>')
  elseif match("vVsS", m) != -1
    normal! y
    exe 'Cfilter' .. a:bang .. ' <C-r>"'
  endif
endfunc
func! PlanetVim_WinBarQfInit() abort
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
endfunc
" Terminals: Previous, Next, List (popup with choose), New, Close (send Ctrl-D)
" W3m: Back, Forward, History, AddressBar
func! PlanetVim_WinBarTerminalInit() abort
  nnoremenu 1.10  WinBar.⏪ :echo 'TODO'<CR>
  nnoremenu 1.20  WinBar.📙 :echo 'TODO'<CR>
  nnoremenu 1.30  WinBar.⏩ :echo 'TODO'<CR>
  nnoremenu 1.40  WinBar.➕ :terminal ++curwin ++kill=kill<CR>
  nnoremenu 1.100 WinBar.⬇️       z0<CR>
  nnoremenu 1.110 WinBar.↕️       10<C-w>_
  nnoremenu 1.120 WinBar.⬆️       <C-w>_
  nnoremenu 1.130 WinBar.❌       <C-w><C-c>
endfunc
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
" Plugin: vim-choosewin {{{
nmap \ <Plug>(choosewin)
" }}}
" Plugin: vim-crystalline {{{
func! StatusLine_SearchCount() abort
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
endfunc

func! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunc

func! StatusLine(current, width)
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
    let l:s .= "/%{@/}/"
    let l:s .= "|%{g:PV_p}|"
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
endfunc

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
