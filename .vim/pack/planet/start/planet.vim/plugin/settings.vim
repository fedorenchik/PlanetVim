vim9script noclear
if exists('g:loaded_planet_vim_settings')
  finish
endif
g:loaded_planet_vim_settings = 1

# Fix the string encoding before assigning any Unicode filesystem options.
set encoding=utf-8

set autoindent
set autoread
set noautowrite
set noautowriteall
set bs=start
set backup
&backupdir = escape(planet#paths#State('backup'), ',') .. '//'
#TODO: set & show baloons
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
set completeopt=menuone,noinsert,noselect
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
&directory = escape(planet#paths#State('swap'), ',') .. '//'
set display=lastline,uhex
set noedcompatible
set emoji
set noequalalways
set noerrorbells
set esckeys
set noexpandtab
set noexrc
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
set fsync
set nogdefault
set grepprg=grep\ -nH\ $*
#TODO: Colorize cursor in different modes.
#set guicursor+=a:blinkon0
if has('win32')
  # Font availability differs between Windows installations and Wine.
  # Keep GVim's usable default if none of the preferred fonts is installed.
  for script_font in ['Consolas:h10', 'Liberation_Mono:h10', 'Courier_New:h10']
    try
      &guifont = script_font
      break
    catch /^Vim\%((\a\+)\)\=:E596/
    endtry
  endfor
else
  set guifont=Monospace\ 10
endif
set guiheadroom=0
# Adding '!' to guioptions causes too much redraw & 'hit enter' prompts (vim bug)
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
set isfname+=@-@,128-255
# On Windows, adding apostrophe changes how fnameescape() backslashes are
# interpreted and breaks :source/:edit for quoted paths. Keep native rules.
if !has('win32')
  set isfname+=39
endif
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
set patchmode=
set path+=.,,./include,../include,../*/include,*/include,*,../*,/usr/include,**
set nopreserveindent
set previewheight=6
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
set sessionoptions=blank,buffers,curdir,folds,globals,help,skiprtp,resize,slash,tabpages,terminal,unix,winpos,winsize
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/bin/bash
endif
set shiftround
set shiftwidth=8
set shortmess=I
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
# Ordinary buffers share a private dictionary; writing buffers can override it.
planet#writing#SetSpellFile(escape(planet#paths#Config('spell') .. '/personal.utf-8.add', ','), v:false)
set spelllang+=cjk
set spelloptions=camel
set spellsuggest=best,10
set nosplitbelow
set nosplitright
set nostartofline
set suffixes-=.h
set swapfile
set swapsync=
set switchbuf=uselast
set synmaxcol=1000
if str2nr(&t_Co) == 8 && $TERM !~# '^linux\|^Eterm'
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
var script_thesaurus = planet#paths#Config('thesaurus') .. '/words.txt'
if filereadable(script_thesaurus)
  &thesaurus = escape(script_thesaurus, ',')
endif
set notildeop
set notimeout
set timeoutlen=400
set title
set titleold=$PWD
set titlestring=%{g:TitleString()}
set ttimeout
set ttimeoutlen=10
set ttyfast
if has('persistent_undo')
  &undodir = escape(planet#paths#State('undo'), ',') .. '//'
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
set writebackup

&viewdir = planet#paths#State('views')
&viminfofile = planet#paths#State() .. '/viminfo'
