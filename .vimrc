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
" TODO: add check for installed programs
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
nn <unique> ; :
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
nn G G$
nn Q gq
nn s <Nop>
nn sb <Cmd>exe "lvimgrep /^\\s*" .. expand('<cword>') .. "/gj %"<CR>
nn sj <Cmd>lvimgrep /^/gj %<CR>
nn sk <Cmd>lvimgrep /\v\{\{\{/gj %<CR>
nn sw <Cmd>exe "lvimgrep /" .. expand('<cword>') .. "/gj %"<CR>
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
" Ctrl-Shift modifier does not work neither in terminal nor in GUI.
" Uppercase/lowercase distinction is not available with <Ctrl-...> modifier.
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
nn <A-:> 1gt
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
tno <C-j> <C-w><C-j>
tno <C-k> <C-w><C-k>
tno <C-l> <C-w><C-l>
tno <C-h> <C-w><C-h>
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
func! SetupCommandAlias(input, output) abort
  exec 'cabbrev <expr> '.a:input
        \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:input.'")'
        \ .'? ("'.a:output.'") : ("'.a:input.'"))'
endfunc
call SetupCommandAlias("f", "find")
" }}}
" Autocommands: {{{
if has("autocmd")
aug vimrc
au!
au BufReadPre *.asm let g:asmsyntax = "fasm"
au BufReadPre *.[sS] let g:asmsyntax = "asm"
au BufReadPost */linux/*.h setfiletype c
au BufReadPost */linux/*.h setlocal colorcolumn=100
au BufReadPost *.log normal G
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit' | exe "normal! g`\"" | end
au CmdWinEnter : noremap <buffer> <S-CR> <CR>q:
au CmdWinEnter : noremap! <buffer> <S-CR> <CR>q:
au CmdWinEnter : noremap <buffer> <C-c> <C-w>c
au CmdWinEnter : noremap! <buffer> <C-c> <C-\><C-n><C-w>c
au CmdWinEnter / noremap <buffer> <S-CR> <CR>q/
au CmdWinEnter ? noremap <buffer> <S-CR> <CR>q?
au CursorHold * if win_gettype() == "" | checktime | end
au CursorHoldI * if win_gettype() == "" | checktime | end
au FileType cmake setlocal keywordprg=:CMakeHelpPopup
au FileType cmake nmap <buffer> <leader>k <plug>(cmake-help-online)
au FileType cmake nmap <buffer> <leader>K <plug>(cmake-help)
au FileType cmake setlocal ballooneval
au FileType cmake setlocal balloonevalterm
au FileType cmake setlocal balloonexpr=cmakehelp#balloonexpr()
au FileType c,cpp setlocal foldmethod=syntax
au FileType c,cpp inoreabbrev #e #endif 
au FileType c,cpp inoreabbrev #d #define 
au FileType c,cpp inoreabbrev #i #include 
au FileType c,cpp inoreabbrev #n #ifndef 
au FileType c,cpp inoreabbrev ,, <<
au FileType c,cpp inoreabbrev ;b std::begin
au FileType c,cpp inoreabbrev ;c std::cout
au FileType c,cpp inoreabbrev ;e std::end
au FileType c,cpp inoreabbrev ;m std::map
au FileType c,cpp inoreabbrev ;s std::string
au FileType c,cpp inoreabbrev ;v std::vector
au FileType c,cpp inoremap ;; ::
au FileType c setlocal colorcolumn=80
au FileType cpp setlocal path+=/usr/include/c++/7
au FileType cpp setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
au FileType cpp setlocal colorcolumn=120
au FileType dockerfile,python,qmake setlocal expandtab
au FileType dockerfile,python,qmake setlocal tabstop=4
au FileType dockerfile,python,qmake setlocal shiftwidth=4
au FileType help,markdown,text setlocal colorcolumn=+0
au FileType markdown setlocal foldmethod=expr
au FileType python setlocal makeprg=pylint3\ --reports=n\ --msg-template=\"{path}:{line}:\ {msg_id}\ {symbol},\ {obj}\ {msg}\"\ %:p
au FileType python setlocal errorformat=%f:%l:\ %m
au FileType sh setlocal formatoptions+=croql
au FileType sh setlocal include=^\\s*\\%(\\.\\\|source\\)\\s
au FileType sh setlocal define=\\<\\%(\\i\\+\\s*()\\)\\@=
au FileType text setlocal textwidth=72 linebreak breakindent
au FileType text setlocal complete+=k,s
au FileType text setlocal spell
au FileType text,markdown setlocal formatoptions+=t
au FileType vim setlocal foldmethod=marker foldlevelstart=0 foldlevel=0
au FileType * if &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | end
au FileType * if &completefunc == "" | setlocal completefunc=syntaxcomplete#Complete | end
au GUIEnter * set t_vb=
au GUIEnter * set guifont=DejaVu\ Sans\ Mono\ 9,Monospace\ 9
au GUIEnter * silent call system('wmctrl -i -b add,maximized_vert,maximized_horz -r' . v:windowid)
au InsertLeave * if empty(&buftype) | pclose | end
au SessionLoadPost * call planet#planet#SetPerSessionOptions()
au StdinReadPost * set nomodified
au TerminalWinOpen * setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber winfixheight winfixwidth
au BufWinEnter * if &buftype == 'terminal' | setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber winfixheight winfixwidth | end
au VimEnter * if expand("%") != "" && getcwd() == expand("~") | cd %:h | end
au VimLeavePre * call planet#planet#CheckExitSaveSession()
aug END
end
" }}}
" Commands: {{{
if !exists(":DiffOrig")
  command DiffOrig vertical new | setlocal buftype=nofile | r ++edit # |
        \ 0d_ | diffthis | wincmd p | diffthis
endif
command -bar -nargs=? -complete=help HelpCurwin execute planet#help#Curwin(<q-args>)
" }}}
" PopUp Menus: {{{

"TODO: <RightMouse>, <C-RightMouse>, <S-RightMouse>, <A-RightMouse> menus
"TODO: <C-MiddleMouse>, <S-MiddleMouse>, <A-MiddleMouse> menus
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
  nnoremenu 1.10 WinBar.⏪ <Cmd>colder<CR>
  "TODO: turn :chistory into popup menu
  nnoremenu 1.20 WinBar.📙 <Cmd>chistory<CR>
  nnoremenu 1.30 WinBar.⏩ <Cmd>cnewer<CR>
  nnoremenu 1.40 WinBar.✅ <CR>
  nnoremenu 1.50 WinBar.📤 <Cmd>call PlanetVim_WinBarFilter('!')<CR>
  nnoremenu 1.60 WinBar.📥 <Cmd>call PlanetVim_WinBarFilter('')<CR>
  nnoremenu 1.100 WinBar.⬇️ z0<CR>
  nnoremenu 1.110 WinBar.↕️ 10<C-w>_
  nnoremenu 1.120 WinBar.⬆️ <C-w>_
  nnoremenu 1.130 WinBar.❌ <Cmd>close<CR>
endfunc
" Terminals: Previous, Next, List (popup with choose), New, Close (send Ctrl-D)
" W3m: Back, Forward, History, AddressBar
func! PlanetVim_WinBarTerminalInit() abort
  nnoremenu 1.10  WinBar.⏪ <Cmd>echo 'TODO'<CR>
  nnoremenu 1.20  WinBar.📙 <Cmd>call planet#term#PopupOutputsMenu()<CR>
  nnoremenu 1.30  WinBar.⏩ <Cmd>echo 'TODO'<CR>
  nnoremenu 1.40  WinBar.➕ <Cmd>terminal ++curwin ++kill=kill<CR>
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
let no_changelog_maps = v:true
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
let g:asyncomplete_auto_completeopt = 0
" }}}
" Plugin: editorconfig-vim {{{
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
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
let g:fern#keepalt_on_edit = 1
let g:fern#keepjumps_on_edit = 1
let g:fern#disable_default_mappings = 1

nnoremap <silent> - :Fern -reveal=% .<CR>

func! s:InitFern() abort
  nmap <buffer><expr> o
        \ fern#smart#drawer(
              \ fern#smart#leaf(
                    \ "<Plug>(fern-action-open)<C-w>p",
                    \ "<Plug>(fern-action-expand:stay)",
                    \ "<Plug>(fern-action-collapse)"
              \ ),
              \ fern#smart#leaf(
                    \ "<Plug>(fern-action-open)",
                    \ "<Plug>(fern-action-expand:stay)",
                    \ "<Plug>(fern-action-collapse)"
              \ )
        \ )
  nmap <buffer><expr> <CR>
        \ fern#smart#leaf(
              \ "<Plug>(fern-action-open)",
              \ "<Plug>(fern-action-expand:stay)",
              \ "<Plug>(fern-action-collapse)"
        \ )
  nmap <buffer><expr> x
        \ fern#smart#leaf(
              \ "<Nop>",
              \ "<Plug>(fern-action-expand:stay)",
              \ "<Plug>(fern-action-collapse)"
        \ )
  nmap <buffer> C <Plug>(fern-action-enter)
  nmap <buffer> u <Plug>(fern-action-leave)
  nmap <buffer> q :<C-u>quit<CR>
  nmap <buffer> . <Plug>(fern-action-hidden:toggle)
  nmap <buffer> I <Plug>(fern-action-hidden:toggle)
  nmap <buffer> r <Plug>(fern-action-reload:cursor)
  nmap <buffer> R <Plug>(fern-action-reload:all)
  nmap <buffer> <C-t> <Plug>(fern-action-open:tabedit)
  nmap <buffer> g<C-t> <Plug>(fern-action-open:tabedit)gT
  nmap <buffer> <C-n> <Plug>(fern-action-new-path)
  nmap <buffer> <C-k> <Plug>(fern-action-mark:toggle)
  nmap <buffer> <C-f> <Plug>(fern-action-new-file)
  nmap <buffer> <C-d> <Plug>(fern-action-new-dir)
  nmap <buffer> d <Plug>(fern-action-trash)
  nmap <buffer> D <Plug>(fern-action-remove)
  nmap <buffer> <C-y> <Plug>(fern-action-move)
  nmap <buffer> <C-p> <Plug>(fern-action-copy)
  nmap <buffer> <C-/> <Plug>(fern-action-grep)
  nmap <buffer> <C-r> <Plug>(fern-action-rename)
  nmap <buffer> <C-o> <Plug>(fern-action-open:system)
  nmap <buffer> <C-t> <Plug>(fern-action-terminal:bottom)

  nmap <buffer> i <Plug>(fern-action-open:split)
  nmap <buffer> gi <Plug>(fern-action-open:split)<C-w>p
  nmap <buffer> <C-s> <Plug>(fern-action-open:vsplit)
  nmap <buffer> gs <Plug>(fern-action-open:vsplit)<C-w>p
  nmap <buffer> P gg
  nmap <buffer> cd <Plug>(fern-action-cd)
endfunc

augroup planetvim-fern
  autocmd! *
  autocmd FileType fern setlocal nonumber norelativenumber signcolumn=yes foldcolumn=0
  autocmd FileType fern call s:InitFern()
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
" Plugin: python-syntax {{{
let g:python_highlight_all = 1
" }}}
" Plugin: spelunker.vim {{{
let g:enable_spelunker_vim = 0
" }}}
" Plugin: undotree {{{
let g:undotree_WindowLayout=4
nnoremap SU :UndotreeShow<CR>
nnoremap ZU :UndotreeHide<CR>
" }}}
" Plugin: vim-arduino {{{
let g:arduino_dir = '/usr/share/arduino'
" }}}
" Plugin: vim-capslock {{{
"FIXME: cannot use <C-L> to complete lines ???
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
    let l:s .= crystalline#right_sep('', 'Fill') . ' %{FugitiveHead()}'
  endif

  let l:s .= '%='
  if a:current
    let l:s .= ' %{NearestMethodOrFunction()}'
    let l:s .= crystalline#left_sep('', 'Fill') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    if g:PV_mode == 'p'
      let l:s .= "|%{g:PV_p}"
      let l:s .= "|%{g:PV_pp}|"
    end
    let l:s .= "/%{@/}/"
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
" Plugin: vim-grammarous {{{
let g:grammarous#use_vim_spelllang = 1
let g:grammarous#languagetool_cmd = 'languagetool'
let g:grammarous#show_first_error = 1
let g:grammarous#use_location_list = 1
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
let g:lsp_preview_float = 1
let g:lsp_preview_autoclose = 1
let g:lsp_diagnostics_echo_cursor = 1
" XXX: evaluate
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_format_sync_timeout = 1000
" make undercurl work in terminal
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
highlight LspErrorHighlight term=strikethrough cterm=strikethrough ctermul=Red gui=strikethrough guisp=Red
highlight LspWarningHighlight term=undercurl cterm=undercurl ctermul=Yellow gui=undercurl guisp=Orange
highlight LspInformationHighlight term=underline cterm=undercurl ctermul=Blue gui=undercurl guisp=Blue
highlight LspHintHighlight term=underline cterm=undercurl ctermul=Green gui=undercurl guisp=DarkGreen
let g:lsp_show_workspace_edits = 1
let g:lsp_fold_enabled = 1
let g:lsp_hover_conceal = 1
let g:lsp_ignorecase = 1
let g:lsp_log_file = ''
let g:lsp_semantic_enabled = 0

let g:lsp_async_completion = 1
" autocmd FileType c,cpp,cmake,python,vim setlocal tagfunc=lsp#tagfunc
autocmd User lsp_buffer_enabled setlocal tagfunc=lsp#tagfunc
autocmd User lsp_buffer_enabled setlocal omnifunc=lsp#complete
"TODO: snippets
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
" Plugin: vim-qf {{{
let g:qf_mapping_ack_style = 1
let g:qf_loclist_window_bottom = 0
let g:qf_auto_open_quickfix = 0
let g:qf_auto_open_loclist = 0
let g:qf_auto_resize = 0
let g:qf_save_win_view = 0
let g:qf_shorten_path = 0
" }}}
" Plugin: vim-signature {{{
let g:SignatureIncludeMarkers = '=!@#$%^&*-'
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
