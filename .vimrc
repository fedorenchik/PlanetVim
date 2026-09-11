vim9script noclear

# Required Vim: {{{
# Approximate compile command:
# ./configure \
#	--enable-option-checking \
#	--enable-fail-if-missing \
#	--prefix=$HOME/.local \
#	--with-features=huge \
#	--enable-luainterp=dynamic \
#	--with-luajit \
#	--disable-mzschemeinterp \
#	--enable-perlinterp=no \
#	--enable-pythoninterp=no \
#	--enable-python3interp=dynamic \
#	--enable-tclinterp=no \
#	--enable-rubyinterp=no \
#	--enable-cscope \
#	--enable-channel \
#	--enable-terminal \
#	--enable-autoservername \
#	--enable-multibyte \
#	--enable-gui=gtk3 \
#	--enable-gtk3-check \
#	--enable-largefile \
#	--enable-acl \
#	--disable-nls \
#	--with-modified-by='Leonid V. Fedorenchik' \
#	--with-compiledby='Leonid V. Fedorenchik' \
#	--with-x
#make
#make install
# version: >= 9.1
# --with-features=huge --enable-luainterp --with-luajit
# --enable-python3interp -enable-cscope --enable-gui=gtk3
# }}}
# External Dependencies Of This Vimrc: {{{
# TODO: add check for installed programs
# ctags - for tags support
# python - for vimspector, codi.vim
# wmctrl - for WM GUI window control
# trash-cli - for fern.vim
# cling, sript - for codi.vim
# rg (ripgrep) - for vim-grepper
# pylint3
# }}}
# Prevent Multiple Sourcing: {{{
if exists("g:loaded_home_vimrc")
  finish
endif
g:loaded_home_vimrc = 1
var script_state: dict<any> = {}
var script_additem: any
var script_fromword: any
var script_ignoreitem: any
var script_suglist: any
runtime plugin/menu_help.vim
# }}}
# Basics: {{{
set nocompatible
set guioptions+=M
if has('autocmd')
  filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
  syntax on
  syntax sync minlines=10000
endif
# }}}
# Colorscheme: {{{
# set colorscheme
if has("gui_running")
  set background=dark
  colorscheme molokai
elseif str2nr(&t_Co) >= 256
  set background=dark
  colorscheme molokai
endif
highlight lCursor guifg=NONE guibg=Cyan
# }}}
# Keymap: {{{
set keymap=russian-dvp
# }}}
# Leaders: {{{
# should be before any mappings: it affects only mappings below
g:mapleader = ","
g:maplocalleader = "_"
# }}}
# Mappings: {{{
# Keys Limitations: {{{
# Shifted cursor keys are not available on all terminals (but available in GUI).
# Cannot distinguish between <Tab> and <C-I>.
# Cannot distinguish between <Enter> and <C-M>.
# Remap <CR> is too troublesome (inconvenient in quickfix and plugins), so
# do not do it.
# }}}
# Alt: make <A-...> work in terminal {{{
for char_code in range(32, 126)
  var alt_char = nr2char(char_code)
  if index([' ', '"', '>', '[', '\', ']', '|'], alt_char) < 0
    execute "set <A-"  ..  alt_char  ..  ">=\e"  ..  alt_char
    execute "map \e"  ..  alt_char  ..  " <A-"  ..  alt_char  ..  ">"
    execute "map! \e"  ..  alt_char  ..  " <A-"  ..  alt_char  ..  ">"
  endif
endfor
# }}}
# Normal (Command) Mode: {{{
# Normal Keys: {{{
nn ` '
nn ' `
nn <unique> ; :
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
nn gx <Cmd>call planet#gui#OpenUrl(expand('<cWORD>'))<CR>
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
# }}}
# Ctrl Key: {{{
# Ctrl-Shift modifier does not work neither in terminal nor in GUI.
# Uppercase/lowercase distinction is not available with <Ctrl-...> modifier.
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
# }}}
# Alt Key: {{{
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
# }}}
# Mouse Keys: {{{
# Mousekeys: <LeftMouse> <MiddleMouse> <RightMouse> <X1Mouse> <X2Mouse>
# <ScrollWheelDown> <ScrollWheelUp> <ScrollWheelLeft> <ScrollWheelRight>
# When remap mousekeys, they send key events to the active window.
# (by default, they send key events to the window under mouse cursor).
# }}}
# }}}
# Insert Mode: {{{
inoremap <Tab> <Esc>
inoremap <expr> <CR> pumvisible() ? "<C-Y><CR>" : "<CR>"
# Ctrl Key: {{{
inoremap <C-@> <C-^>
inoremap <C-E> <C-R>=pumvisible() ? "\<lt>C-E>" : "\<lt>Esc>"<CR>
# }}}
# }}}
# Visual Mode: {{{
# Subcommands & submodes: Ctrl-\, a, g, i.
vnoremap <Tab> <Esc>
xnoremap ; :
xnoremap / /\v
xnoremap gy "+y
# make p in visual mode replace selected text with the yank register
xnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
xnoremap X y/<C-R>"<CR>
vnoremap / y/\V<C-R>"<CR>
vnoremap ? y/\V\<<C-R>"\><CR>
vnoremap * y/\V\<<C-R>"<CR>
vnoremap # y/\V<C-R>"\><CR>
# }}}
# Command-line (Cmdline) Mode: {{{
# Subcommands & submodes: Ctrl-R, Ctrl-\
cnoremap <expr> <C-u> ((getcmdtype() is# ":" && getcmdline() is# "") ? ("<Esc>") : ("<C-u>"))
cnoremap <expr> <Tab> ((getcmdtype() is# ":" && getcmdline() is# "") ? ("<Esc>") : ("<C-z>"))
# }}}
# Terminal Window: {{{
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
# }}}
# Operator-pending Mode: {{{
onoremap <Tab> <Esc>
# }}}
# Lang-Arg Mode: {{{
lnoremap <Tab> <Esc>
# }}}
# }}}
# Abbreviations: {{{
inoreabbrev teh the
def g:SetupCommandAlias(input: any, output: any): any
  exec 'cabbrev <expr> ' .. input   .. ' ((getcmdtype() is# ":" && getcmdline() is# "' .. input .. '")'   .. '? ("' .. output .. '") : ("' .. input .. '"))'
  return 0
enddef
g:SetupCommandAlias("f", "find")
# }}}
# Autocommands: {{{
if has("autocmd")
aug vimrc
au!
au BufReadPre *.asm g:asmsyntax = "fasm"
au BufReadPre *.[sS] g:asmsyntax = "asm"
au BufReadPost */linux/*.h setfiletype c
au BufReadPost */linux/*.h setlocal colorcolumn=100
au BufReadPost *.log normal G
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit' | exe "normal! g`\"" | endif
au CmdWinEnter : noremap <buffer> <S-CR> <CR>q:
au CmdWinEnter : noremap! <buffer> <S-CR> <CR>q:
au CmdWinEnter : noremap <buffer> <C-c> <C-w>c
au CmdWinEnter : noremap! <buffer> <C-c> <C-\><C-n><C-w>c
au CmdWinEnter / noremap <buffer> <S-CR> <CR>q/
au CmdWinEnter ? noremap <buffer> <S-CR> <CR>q?
au CursorHold * if win_gettype() == "" | checktime | endif
au CursorHoldI * if win_gettype() == "" | checktime | endif
# Filetype-specific behavior lives in planet.vim/plugin/filetypes.vim.
au GUIEnter * set t_vb=
au InsertLeave * if empty(&buftype) | pclose | endif
au SessionLoadPost * call planet#planet#SetPerSessionOptions()
au StdinReadPost * set nomodified
au TerminalWinOpen * setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber winfixheight winfixwidth
au BufWinEnter * if &buftype == 'terminal' | setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber winfixheight winfixwidth | endif
au VimEnter * if expand("%") != "" && getcwd() == expand("~") | cd %:h | endif
au VimLeavePre * call planet#planet#CheckExitSaveSession()
aug END
endif
# }}}
# Commands: {{{
if !exists(":DiffOrig")
  command DiffOrig vertical new | setlocal buftype=nofile | r ++edit %% | :0d_ | diffthis | wincmd p | diffthis
endif
command -bar -nargs=? -complete=help HelpCurwin execute planet#help#Curwin(<q-args>)
# }}}
# PopUp Menus: {{{

#TODO: <RightMouse>, <C-RightMouse>, <S-RightMouse>, <A-RightMouse> menus
#TODO: <C-MiddleMouse>, <S-MiddleMouse>, <A-MiddleMouse> menus
if has("spell")
  # Spell suggestions in the popup menu.  Note that this will slow down the
  # appearance of the menu!
def LocalSpellPopup(): any
  var curcol: any
  var w: any
  var a: any
  var pri: any
  var cpo_save: any
  if has_key(script_state, 'changeitem') && script_state.changeitem != ''
    LocalSpellDel()
  endif

  # Return quickly if spell checking is not enabled.
  if !&spell || &spelllang == ''
    return 0
  endif

  curcol = col('.')
  [w, a] = spellbadword()
  if col('.') > curcol	# don't use word after the cursor
    w = ''
  endif
  if w != ''
    if a == 'caps'
      script_suglist = [substitute(w, '.*', '\u&', '')]
    else
      script_suglist = spellsuggest(w, 10)
    endif
    if len(script_suglist) > 0
      if !exists("g:menutrans_spell_change_ARG_to")
        g:menutrans_spell_change_ARG_to = 'Change\ "%s"\ to'
      endif
      script_state.changeitem = printf(g:menutrans_spell_change_ARG_to, escape(w, ' .'))
      script_fromword = w
      pri = 1
      # set 'cpo' to include the <CR>
      cpo_save = &cpo
      set cpo&vim
      for sug in script_suglist
        exe 'PlanetMenu anoremenu 1.5.'  ..  pri  ..  ' PopUp.'  ..  script_state.changeitem  ..  '.'  ..  escape(sug, ' .')   ..  ' :call <SID>LocalSpellReplace('  ..  pri  ..  ')<CR>'
        pri += 1
      endfor

      if !exists("g:menutrans_spell_add_ARG_to_word_list")
        g:menutrans_spell_add_ARG_to_word_list = 'Add\ "%s"\ to\ Word\ List'
      endif
      script_additem = printf(g:menutrans_spell_add_ARG_to_word_list, escape(w, ' .'))
      exe 'PlanetMenu anoremenu 1.6 PopUp.'  ..  script_additem  ..  ' :spellgood '  ..  w  ..  '<CR>'

      if !exists("g:menutrans_spell_ignore_ARG")
        g:menutrans_spell_ignore_ARG = 'Ignore\ "%s"'
      endif
      script_ignoreitem = printf(g:menutrans_spell_ignore_ARG, escape(w, ' .'))
      exe 'PlanetMenu anoremenu 1.7 PopUp.'  ..  script_ignoreitem  ..  ' :spellgood! '  ..  w  ..  '<CR>'

      PlanetMenu anoremenu 1.8 PopUp.-SpellSep- :
      &cpo = cpo_save
    endif
  endif
  cursor(0, curcol)	# put the cursor back where it was
  return 0
enddef

def LocalSpellReplace(n: any): any
  var l: any
  l = getline('.')
  # Move the cursor to the start of the word.
  spellbadword()
  setline('.', strpart(l, 0, col('.') - 1)  ..  script_suglist[n - 1]   ..  strpart(l, col('.') + len(script_fromword) - 1))
  return 0
enddef

def LocalSpellDel(): any
  exe "aunmenu PopUp."  ..  script_state.changeitem
  exe "aunmenu PopUp."  ..  script_additem
  exe "aunmenu PopUp."  ..  script_ignoreitem
  aunmenu PopUp.-SpellSep-
  script_state.changeitem = ''
  return 0
enddef

  augroup SpellPopupMenu
    au! MenuPopup * call LocalSpellPopup()
  augroup END
endif

# Normal Mode:
PlanetMenu nnoremenu 1.10 PopUp.&Paste                  "+gP
PlanetMenu nnoremenu 1.10 PopUp.Close                   <C-w>c
# Operator Pending Mode: text objects
PlanetMenu onoremenu PopUp.Word                         w
# Visual:
PlanetMenu vnoremenu 1.10 PopUp.Cu&t                    "+x
PlanetMenu vnoremenu 1.10 PopUp.&Copy                   "+y
PlanetMenu vnoremenu 1.10 PopUp.&Yank                   y
PlanetMenu vnoremenu 1.10 PopUp.&Replace                "_x"+gP
PlanetMenu vnoremenu 1.10 PopUp.&Paste                  "_x"+gP
PlanetMenu vnoremenu 1.10 PopUp.&Delete                 "_x
# Select Mode:
PlanetMenu snoremenu 1.10 PopUp.Cut                     "+d
# Insert Mode:
PlanetMenu inoremenu 1.10 PopUp.&Paste                  <C-o>"+gP
PlanetMenu inoremenu 1.10 PopUp.Close                   <Cmd>close<CR>
# Cmdline Mode: cmdline completion
PlanetMenu cnoremenu 1.10 PopUp.&Copy                  <Cmd>call setreg("+", getcmdline())<CR>
PlanetMenu cnoremenu 1.10 PopUp.&Paste                 <C-r>+
# Terminal Mode:
PlanetMenu tlnoremenu 1.10 PopUp.Close                  <C-w><C-c>
# }}}
# WinBar Menus: {{{
# TODO: Auto for LL, QF, Terminals, W3m
# QF, LL: colder, cnewer, chistory popup, merge with prev, filter, filter-out,
# min size, std size(10lines), max size
def g:PlanetVim_WinBarFilter(bang: any): any
  planet#winbar#Filter(bang ==# '!')
  return 0
enddef
def g:PlanetVim_WinBarQfInit(): any
  PlanetMenu nnoremenu 1.10 WinBar.⏪ <Cmd>colder<CR>
  #TODO: turn :chistory into popup menu
  PlanetMenu nnoremenu 1.20 WinBar.📙 <Cmd>chistory<CR>
  PlanetMenu nnoremenu 1.30 WinBar.⏩ <Cmd>cnewer<CR>
  PlanetMenu nnoremenu 1.40 WinBar.✅ <CR>
  PlanetMenu nnoremenu 1.50 WinBar.📤 <Cmd>call PlanetVim_WinBarFilter('!')<CR>
  PlanetMenu nnoremenu 1.60 WinBar.📥 <Cmd>call PlanetVim_WinBarFilter('')<CR>
  PlanetMenu nnoremenu 1.100 WinBar.⬇️ z0<CR>
  PlanetMenu nnoremenu 1.110 WinBar.↕️ 10<C-w>_
  PlanetMenu nnoremenu 1.120 WinBar.⬆️ <C-w>_
  PlanetMenu nnoremenu 1.130 WinBar.❌ <Cmd>close<CR>
  return 0
enddef
# Terminals: Previous, Next, List (popup with choose), New, Close (send Ctrl-D)
# W3m: Back, Forward, History, AddressBar
def g:PlanetVim_WinBarTerminalInit(): any
  PlanetMenu nnoremenu 1.10  WinBar.⏪ <Cmd>call planet#winbar#Terminal(-1)<CR>
  PlanetMenu nnoremenu 1.20  WinBar.📙 <Cmd>call planet#term#PopupOutputsMenu()<CR>
  PlanetMenu nnoremenu 1.30  WinBar.⏩ <Cmd>call planet#winbar#Terminal(1)<CR>
  PlanetMenu nnoremenu 1.40  WinBar.➕ <Cmd>terminal ++curwin ++kill=kill<CR>
  PlanetMenu nnoremenu 1.100 WinBar.⬇️       z0<CR>
  PlanetMenu nnoremenu 1.110 WinBar.↕️       10<C-w>_
  PlanetMenu nnoremenu 1.120 WinBar.⬆️       <C-w>_
  PlanetMenu nnoremenu 1.130 WinBar.❌       <C-w><C-c>
  return 0
enddef
aug PlanetVim_AugroupWinBar
au!
au BufWinEnter * if &buftype == 'quickfix' | call planet#winbar#Preset('quickfix') | endif
au BufWinLeave * if &buftype == 'quickfix' | nunmenu WinBar | endif
au TerminalWinOpen * call PlanetVim_WinBarTerminalInit()
au BufWinEnter * if &buftype == 'terminal' | call PlanetVim_WinBarTerminalInit() | endif
aug END
# }}}
# $VIMRUNTIME/ {{{
# filetype.vim {{{
g:bash_is_sh = 1
g:tex_flavor = "latex"
# }}}
# ftplugin/awk.vim {{{
g:awk_is_gawk = 1
# }}}
# ftplugin/changelog.vim {{{
g:no_changelog_maps = v:true
runtime ftplugin/changelog.vim
# }}}
# ftplugin/man.vim {{{
runtime ftplugin/man.vim
g:ft_man_folding_enable = 1
set keywordprg=:Man
# }}}
# ftplugin/markdown.vim {{{
g:markdown_folding = 1
# }}}
# ftplugin/rst.vim {{{
g:rst_style = 1
# }}}
# ftplugin/rust.vim {{{
g:rust_fold = 1
# }}}
# ftplugin/spec.vim {{{
g:spec_chglog_release_info = 1
# }}}
# ftplugin/sql.vim {{{
g:ftplugin_sql_statements = 'create,alter'
# }}}
# pack/dist/opt/cfilter/ {{{
packadd! cfilter
# }}}
# pack/dist/opt/justify/ {{{
packadd! justify
# }}}
# pack/dist/opt/matchit/ {{{
if has('syntax') && has('eval')
  packadd! matchit
endif
# }}}
# Do not load following in plugin/*.vim {{{
g:loaded_getscript = 1
g:loaded_getscriptPlugin = 1
g:loaded_netrw = 1
g:loaded_netrwPlugin = 1
g:loaded_vimball = 1
g:loaded_vimballPlugin = 1
# }}}
# plugin/tarPlugin.vim {{{
g:tar_secure = "--"
# }}}
# plugin/tohtml.vim {{{
g:html_number_lines = 1
g:html_use_css = 1
g:html_ignore_conceal = 0
g:html_dynamic_folds = 1
g:html_no_foldcolumn = 0
g:html_prevent_copy = "fn"
g:html_hover_unfold = 0
g:html_pre_wrap = 1
# }}}
# plugin/zipPlugin.vim {{{
g:zipPlugin_ext = '*.zip,*.jar,*.xpi,*.ja,*.war,*.ear,*.celzip,  *.oxt,*.kmz,*.wsz,*.xap,*.docx,*.docm,*.dotx,*.dotm,*.potx,*.potm,  *.ppsx,*.ppsm,*.pptx,*.pptm,*.ppam,*.sldx,*.thmx,*.xlam,*.xlsx,*.xlsm,  *.xlsb,*.xltx,*.xltm,*.xlam,*.crtx,*.vdw,*.glox,*.gcsx,*.gqsx,*.epub'
# }}}
# spell/ {{{
g:spell_clean_limit = 60 * 60
# }}}
# syntax/c.vim {{{
g:c_gnu = 1
g:c_comment_strings = 1
g:c_space_errors = 1
# }}}
# syntax/diff.vim {{{
g:diff_translations = 0
# }}}
# syntax/doxygen.vim {{{
g:load_doxygen_syntax = 1
g:doxygen_enhanced_color = 1
# }}}
# syntax/javascript.vim {{{
g:javaScript_fold = 1
# }}}
# syntax/lisp.vim {{{
g:lisp_rainbow = 1
# }}}
# syntax/perl.vim {{{
g:perl_fold = 1
g:perl_fold_blocks = 1
g:perl_nofold_subs = 1
g:perl_fold_anonymous_subs = 1
g:perl_nofold_packages = 1
# }}}
# syntax/php.vim {{{
g:php_folding = 1
# }}}
# syntax/python.vim {{{
g:python_highlight_all = 1
# }}}
# syntax/r.vim {{{
g:r_syntax_folding = 1
# }}}
# syntax/readline.vim {{{
g:readline_has_bash = 1
# }}}
# syntax/ruby.vim {{{
g:ruby_operators = 1
g:ruby_space_errors = 1
g:ruby_fold = 1
g:ruby_spellcheck_strings = 1
# }}}
# syntax/sed.vim {{{
g:highlight_sedtabs = 1
# }}}
# syntax/sh.vim {{{
g:is_bash = 1
g:sh_fold_enabled = 7
# }}}
# syntax/synload.vim {{{
g:load_doxygen_syntax = 1
# }}}
# syntax/tex.vim {{{
g:tex_fold_enabled = 1
# }}}
# syntax/vim.vim {{{
g:vimsyn_embed = "lmpPrt"
g:vimsyn_folding = "aflmpPrt"
# }}}
# syntax/xml.vim {{{
g:xml_syntax_folding = 1
# }}}
# }}}
# Built-in EditorConfig package (enabled by the startup entry point).
g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
# External Plugins: {{{
# Plugin: asyncomplete.vim {{{
g:asyncomplete_auto_completeopt = 0
# }}}
# Plugin: emmet-vim {{{
g:user_emmet_mode = 'iv'
g:user_emmet_leader_key = '<C-Z>'
# }}}
# Plugin: FastFold {{{
g:fastfold_fold_command_suffixes = []
g:fastfold_fold_movement_commands = []
g:fastfold_force = 1
g:fastfold_fdmhook = 1
g:fastfold_minlines = 0
# fold text objects
xnoremap iz :<c-u>FastFoldUpdate<cr><esc>:<c-u>normal! ]zv[z<cr>
xnoremap az :<c-u>FastFoldUpdate<cr><esc>:<c-u>normal! ]zV[z<cr>
# }}}
# Plugin: fern.vim {{{
g:fern#keepalt_on_edit = 1
g:fern#keepjumps_on_edit = 1
g:fern#disable_default_mappings = 1
g:fern#default_hidden = 1

nnoremap <silent> - :Fern -reveal=% .<CR>

def LocalInitFern(): any
  nmap <buffer><expr> o  fern#smart#drawer(  fern#smart#leaf(  "<Plug>(fern-action-open)<C-w>p",  "<Plug>(fern-action-expand:stay)",  "<Plug>(fern-action-collapse)"  ),  fern#smart#leaf(  "<Plug>(fern-action-open)",  "<Plug>(fern-action-expand:stay)",  "<Plug>(fern-action-collapse)"  )  )
  nmap <buffer><expr> <CR>  fern#smart#leaf(  "<Plug>(fern-action-open)",  "<Plug>(fern-action-expand:stay)",  "<Plug>(fern-action-collapse)"  )
  nmap <buffer><expr> x  fern#smart#leaf(  "<Nop>",  "<Plug>(fern-action-expand:stay)",  "<Plug>(fern-action-collapse)"  )
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
  return 0
enddef

augroup planetvim-fern
  autocmd! *
  autocmd FileType fern setlocal nonumber norelativenumber signcolumn=yes foldcolumn=0
  autocmd FileType fern call LocalInitFern()
augroup END
# }}}
# Plugin: fern-bookmark.vim {{{
g:fern#scheme#bookmark#store#file = planet#paths#State()  ..  '/fern-bookmark.json'
# }}}
# Plugin: fern-renderer-nerdfont.vim {{{
g:fern#renderer = get(g:, 'PV_fern_renderer', 'default')
# }}}
# Plugin: glyph-palette.vim {{{
augroup my-glyph-palette
  autocmd!
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType startify call glyph_palette#apply()
augroup END
# }}}
# Plugin: python-syntax {{{
g:python_highlight_all = 1
# }}}
# Plugin: spelunker.vim {{{
g:enable_spelunker_vim = 0
# }}}
# Plugin: tabman.vim {{{
g:tabman_toggle = '<leader>gt'
g:tabman_focus = '<leader>gf'
g:tabman_specials = 1
# }}}
# Plugin: undotree {{{
g:undotree_WindowLayout = 4
nnoremap SU :UndotreeShow<CR>
nnoremap ZU :UndotreeHide<CR>
# }}}
# Plugin: vim-arduino {{{
g:arduino_dir = '/usr/share/arduino'
# }}}
# Plugin: vim-capslock {{{
# Edit → Complete → Whole lines sends native CTRL-X CTRL-L without remapping.
# This avoids CapsLock's standalone CTRL-L toggle; vendor mappings stay intact.
# }}}
# Plugin: vim-clap {{{
g:clap_provider_tags_force_vista = 1
g:clap_disable_bottom_top = 1
g:clap_provider_yanks_history = planet#paths#State()  ..  '/clap_yanks.history'
g:clap_provider_colors_ignore_default = v:true
g:clap_preview_direction = 'UD'
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
nnoremap <silent> <Space>s :Clap grep --query=`expand('<cword>')`<CR>
nnoremap <silent> <Space>S :Clap grep<CR>
nnoremap <silent> <Space>T :Clap filetypes<CR>
nnoremap <silent> <Space>w :Clap windows<CR>
nnoremap <silent> <Space>y :Clap yanks<CR>
nnoremap <silent> <Space>' :Clap marks<CR>
nnoremap <silent> <Space>" :Clap registers<CR>
#TODO: clap provider for :echo serverlist()
#TODO: clap provider for GUI windows with wmctrl
#TODO: clap provider for :args
#TODO: clap provider for tag stack
#TODO: clap provider for :changes
#TODO: clap provider for :lhistory
#TODO: clap provider for :chistory
#TODO: clap provider for :undolist
#TODO: clap provider for :tabs
# }}}
# Plugin: vim-choosewin {{{
nmap \ <Plug>(choosewin)
# }}}
# Plugin: vim-crystalline {{{
def g:StatusLine_SearchCount(): any
  var search_count: dict<number>
  try
    search_count = searchcount({'maxcount':  0, 'timeout':  50})
  catch /^Vim\%((\a\+)\)\=:\%(E486\)\@!/
    return '[?/??]'
  endtry
  if empty(search_count)
    return ''
  endif
  return search_count.total != 0 ? search_count.incomplete != 0 ? printf('[%d/??]', search_count.current)  :  printf('[%d/%d]', search_count.current, search_count.total) :  '[0/0]'
enddef

def g:NearestMethodOrFunction(): any
  return get(b:, 'vista_nearest_method_or_function', '')
enddef

def g:StatusLine(current: any, width: any): any
  var e: any
  var s: any = ''

  if current
    s ..= crystalline#ModeHiItem('') .. crystalline#ModeLabel()
    #FIXME: not immediately updated (use :redrawstatus or fix window_mode)
    s ..= window_mode#lightlineComponent()
    s ..= crystalline#Sep(0, crystalline#ModeGroup(''), 'A')
  else
    s ..= crystalline#HiItem('InactiveFill')
  endif
  s ..= ' %f%h%w%m%r '
  if current
    s ..= crystalline#Sep(0, 'A', 'Fill')  ..  ' %{FugitiveHead()}'
  endif

  s ..= '%='
  if current
    s ..= ' %{NearestMethodOrFunction()}'
    s ..= crystalline#Sep(1, 'Fill', 'A')  ..  ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    if g:PV_mode == 'p'
      s ..= "|%{g:PV_p}"
      s ..= "|%{g:PV_pp}|"
    endif
    s ..= "/%{@/}/"
    s ..= "%{StatusLine_SearchCount()}"
    s ..= "%{exists('*CapsLockStatusline')?CapsLockStatusline():''}"
    s ..= ' %{grepper#statusline()}'
    s ..= crystalline#Sep(1, 'A', crystalline#ModeGroup(''))
  endif
  if width > 80
    s ..= ' %{&ft}'
    e = &fenc !=# "" ? &fenc : &enc
    if e != 'utf-8'
      s ..= '[%{&fenc!=#""?&fenc:&enc}]'
    endif
    if &ff != 'unix'
      s ..= '[%{&ff}]'
    endif
    s ..= ' %l/%L %c%V %P '
  else
    s ..= ' '
  endif

  return s
enddef

g:crystalline_enable_sep = 1
def g:CrystallineStatuslineFn(window: number): string
  return g:StatusLine(window == winnr(), winwidth(window))
enddef
g:crystalline_theme = 'molokai'

set showtabline=2
set laststatus=2
# }}}
# Plugin: vim-dispatch {{{
g:dispatch_no_maps = 1
# }}}
# Plugin: vim-flog {{{
# Avoid an interactive Fugitive job before the graph has opened. Its cache
# can be built explicitly from Git > Log; Git maintenance also manages it.
g:flog_write_commit_graph = get(g:, 'flog_write_commit_graph', 0)
augroup Flog
  au FileType floggraph vnoremap <buffer> <silent> D :<C-U>call flog#ExecTmp(flog#Format("vertical belowright Git diff %(h'>) %(h'<)"))<CR>
augroup end
# }}}
# Plugin: vim-grammarous {{{
g:grammarous#use_vim_spelllang = 1
g:grammarous#languagetool_cmd = 'languagetool'
g:grammarous#show_first_error = 1
g:grammarous#use_location_list = 1
# }}}
# Plugin: vim-grepper {{{
g:grepper = {}
g:grepper.tools = ['rg', 'git', 'grep']
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
nnoremap sg :Grepper -tool rg -cword -noprompt<CR>
nnoremap sG :Grepper -tool rg<CR>
nnoremap ss :Grepper -tool git -cword -noprompt<CR>
nnoremap sS :Grepper -tool git<CR>
g:SetupCommandAlias("grep", "GrepperGrep")
# }}}
# Plugin: vim-lsp {{{
g:lsp_use_lua = 0
g:lsp_settings = get(g:, 'lsp_settings', {})
for script_server in ['clangd', 'pyls-all', 'pyls', 'pyls-ms', 'pyright-langserver', 'jedi-language-server']
  g:lsp_settings[script_server] = extend(get(g:lsp_settings, script_server, {}), {'disabled':  1}, 'keep')
endfor
g:lsp_preview_keep_focus = 1
g:lsp_preview_float = 1
g:lsp_preview_autoclose = 1
g:lsp_diagnostics_echo_cursor = 1
# Request diagnostics from servers that advertise the pull protocol.
g:lsp_diagnostics_pull_enabled = get(g:, 'lsp_diagnostics_pull_enabled', 1)
# XXX: evaluate
g:lsp_diagnostics_float_cursor = 0
g:lsp_format_sync_timeout = 5000
# make undercurl work in terminal
highlight LspErrorHighlight term=strikethrough cterm=strikethrough ctermul=Red gui=strikethrough guisp=Red
highlight LspWarningHighlight term=undercurl cterm=undercurl ctermul=Yellow gui=undercurl guisp=Orange
highlight LspInformationHighlight term=underline cterm=undercurl ctermul=Blue gui=undercurl guisp=Blue
highlight LspHintHighlight term=underline cterm=undercurl ctermul=Green gui=undercurl guisp=DarkGreen
g:lsp_show_workspace_edits = 1
g:lsp_fold_enabled = 1
g:lsp_hover_conceal = 1
g:lsp_ignorecase = 1
g:lsp_log_file = ''
g:lsp_semantic_enabled = 0

g:lsp_async_completion = 1
# autocmd FileType c,cpp,cmake,python,vim setlocal tagfunc=lsp#tagfunc
#TODO: snippets
# }}}
# Plugin: vim-mark {{{
g:mwPalettes = {
    'mypalette': [
     { 'ctermbg': 'Cyan',       'ctermfg': 'Black', 'guibg': '#8CCBEA', 'guifg': 'Black' },
     { 'ctermbg': 'Green',      'ctermfg': 'Black', 'guibg': '#A4E57E', 'guifg': 'Black' },
     { 'ctermbg': 'Yellow',     'ctermfg': 'Black', 'guibg': '#FFDB72', 'guifg': 'Black' },
     { 'ctermbg': 'Magenta',    'ctermfg': 'Black', 'guibg': '#FFB3FF', 'guifg': 'Black' },
     { 'ctermbg': 'Blue',       'ctermfg': 'Black', 'guibg': '#9999FF', 'guifg': 'Black' },
     { 'ctermfg': 'Black',      'ctermbg': '202',   'guifg': 'Black',   'guibg': '#ff5f00' },
     { 'ctermfg': 'Black',      'ctermbg': '204',   'guifg': 'Black',   'guibg': '#ff5f87' },
     { 'ctermfg': 'Black',      'ctermbg': '209',   'guifg': 'Black',   'guibg': '#ff875f' },
     { 'ctermfg': 'Black',      'ctermbg': '212',   'guifg': 'Black',   'guibg': '#ff87d7' },
     { 'ctermfg': 'Black',      'ctermbg': '215',   'guifg': 'Black',   'guibg': '#ffaf5f' },
     { 'ctermfg': 'Black',      'ctermbg': '220',   'guifg': 'Black',   'guibg': '#ffd700' },
     { 'ctermfg': 'Black',      'ctermbg': '224',   'guifg': 'Black',   'guibg': '#ffd7d7' },
     { 'ctermfg': 'Black',      'ctermbg': '228',   'guifg': 'Black',   'guibg': '#ffff87' },
     {                                            'guifg': 'Black',   'guibg': '#b3dcff' },
     {                                            'guifg': 'Black',   'guibg': '#99cbd6' },
     {                                            'guifg': 'Black',   'guibg': '#7afff0' },
     {                                            'guifg': 'Black',   'guibg': '#a6ffd2' },
     {                                            'guifg': 'Black',   'guibg': '#a2de9e' },
     {                                            'guifg': 'Black',   'guibg': '#bcff80' },
     {                                            'guifg': 'Black',   'guibg': '#e7ff8c' },
     {                                            'guifg': 'Black',   'guibg': '#f2e19d' },
     {                                            'guifg': 'Black',   'guibg': '#ffcc73' },
     {                                            'guifg': 'Black',   'guibg': '#f7af83' },
     {                                            'guifg': 'Black',   'guibg': '#fcb9b1' },
     {                                            'guifg': 'Black',   'guibg': '#ff8092' },
     {                                            'guifg': 'Black',   'guibg': '#ff73bb' },
     {                                            'guifg': 'Black',   'guibg': '#fc97ef' },
     {                                            'guifg': 'Black',   'guibg': '#c8a3d9' },
     {                                            'guifg': 'Black',   'guibg': '#ac98eb' },
     {                                            'guifg': 'Black',   'guibg': '#6a6feb' },
     {                                            'guifg': 'Black',   'guibg': '#8caeff' },
     { 'ctermfg': 'Black',      'ctermbg': '166',   'guifg': 'Black',   'guibg': '#d75f00' },
     { 'ctermfg': 'Black',      'ctermbg': '169',   'guifg': 'Black',   'guibg': '#d75faf' },
     { 'ctermfg': 'Black',      'ctermbg': '174',   'guifg': 'Black',   'guibg': '#d78787' },
     { 'ctermfg': 'Black',      'ctermbg': '175',   'guifg': 'Black',   'guibg': '#d787af' },
     { 'ctermfg': 'Black',      'ctermbg': '186',   'guifg': 'Black',   'guibg': '#d7d787' },
     { 'ctermfg': 'Black',      'ctermbg': '190',   'guifg': 'Black',   'guibg': '#d7ff00' },
     { 'ctermfg': 'Black',      'ctermbg': '133',   'guifg': 'Black',   'guibg': '#af5faf' },
     { 'ctermfg': 'Black',      'ctermbg': '138',   'guifg': 'Black',   'guibg': '#af8787' },
     { 'ctermfg': 'Black',      'ctermbg': '142',   'guifg': 'Black',   'guibg': '#afaf00' },
     { 'ctermfg': 'Black',      'ctermbg': '152',   'guifg': 'Black',   'guibg': '#afd7d7' },
     {                                            'guifg': 'Black',   'guibg': '#70b9fa' },
     { 'ctermfg': 'Black',      'ctermbg': '101',   'guifg': 'Black',   'guibg': '#87875f' },
     { 'ctermfg': 'Black',      'ctermbg': '107',   'guifg': 'Black',   'guibg': '#87af5f' },
     { 'ctermfg': 'Black',      'ctermbg': '114',   'guifg': 'Black',   'guibg': '#87d787' },
     { 'ctermfg': 'Black',      'ctermbg': '117',   'guifg': 'Black',   'guibg': '#87d7ff' },
     { 'ctermfg': 'Black',      'ctermbg': '118',   'guifg': 'Black',   'guibg': '#87ff00' },
     { 'ctermfg': 'Black',      'ctermbg': '122',   'guifg': 'Black',   'guibg': '#87ffd7' },
     { 'ctermfg': 'Black',      'ctermbg': '66',    'guifg': 'Black',   'guibg': '#5f8787' },
     { 'ctermfg': 'Black',      'ctermbg': '72',    'guifg': 'Black',   'guibg': '#5faf87' },
     { 'ctermfg': 'Black',      'ctermbg': '74',    'guifg': 'Black',   'guibg': '#5fafd7' },
     { 'ctermfg': 'Black',      'ctermbg': '78',    'guifg': 'Black',   'guibg': '#5fd787' },
     { 'ctermfg': 'Black',      'ctermbg': '79',    'guifg': 'Black',   'guibg': '#5fd7af' },
     { 'ctermfg': 'Black',      'ctermbg': '85',    'guifg': 'Black',   'guibg': '#5fffaf' },
     { 'ctermfg': 'White',      'ctermbg': '22',    'guifg': 'White',   'guibg': '#005f00' },
     { 'ctermfg': 'White',      'ctermbg': '23',    'guifg': 'White',   'guibg': '#005f5f' },
     { 'ctermfg': 'White',      'ctermbg': '27',    'guifg': 'White',   'guibg': '#005fff' },
     { 'ctermfg': 'White',      'ctermbg': '29',    'guifg': 'White',   'guibg': '#00875f' },
     { 'ctermfg': 'White',      'ctermbg': '34',    'guifg': 'White',   'guibg': '#00af00' },
     { 'ctermfg': 'Black',      'ctermbg': '37',    'guifg': 'Black',   'guibg': '#00afaf' },
     { 'ctermfg': 'Black',      'ctermbg': '43',    'guifg': 'Black',   'guibg': '#00d7af' },
     { 'ctermfg': 'Black',      'ctermbg': '47',    'guifg': 'Black',   'guibg': '#00ff5f' },
     { 'ctermfg': 'White',      'ctermbg': '53',    'guifg': 'White',   'guibg': '#5f005f' },
     { 'ctermfg': 'White',      'ctermbg': '58',    'guifg': 'White',   'guibg': '#5f5f00' },
     { 'ctermfg': 'White',      'ctermbg': '60',    'guifg': 'White',   'guibg': '#5f5f87' },
     { 'ctermfg': 'White',      'ctermbg': '64',    'guifg': 'White',   'guibg': '#5f8700' },
     { 'ctermfg': 'White',      'ctermbg': '65',    'guifg': 'White',   'guibg': '#5f875f' },
     { 'ctermfg': 'White',      'ctermbg': '90',    'guifg': 'White',   'guibg': '#870087' },
     { 'ctermfg': 'White',      'ctermbg': '95',    'guifg': 'White',   'guibg': '#875f5f' },
     { 'ctermfg': 'White',      'ctermbg': '96',    'guifg': 'White',   'guibg': '#875f87' },
     { 'ctermfg': 'White',      'ctermbg': '130',   'guifg': 'White',   'guibg': '#af5f00' },
     { 'ctermfg': 'White',      'ctermbg': '131',   'guifg': 'White',   'guibg': '#af5f5f' },
     { 'ctermfg': 'White',      'ctermbg': '17',    'guifg': 'White',   'guibg': '#00005f' },
     { 'ctermbg': 'Red',        'ctermfg': 'Black', 'guibg': '#FF7272', 'guifg': 'Black' },
     { 'ctermfg': 'White',      'ctermbg': '52',    'guifg': 'White',   'guibg': '#5f0000' },
     { 'ctermfg': 'White',      'ctermbg': '160',   'guifg': 'White',   'guibg': '#d70000' },
     { 'ctermfg': 'White',      'ctermbg': '198',   'guifg': 'White',   'guibg': '#ff0087' },
    ]
  }
g:mwDefaultHighlightingPalette = 'mypalette'
g:mwAutoLoadMarks = 1
g:mwAutoSaveMarks = 1
g:mw_no_mappings = 1
nmap <Leader>m <Plug>MarkSet
nmap <Leader>n <Plug>MarkClear
nmap <Leader>r <Plug>MarkRegex
nmap <Leader>M <Plug>MarkToggle
nmap <Leader>N <Plug>MarkConfirmAllClear
vmap <Leader>m <Plug>MarkSet
vmap <Leader>r <Plug>MarkRegex
xmap <Leader>* <Plug>MarkIWhiteSet
# }}}
# Plugin: vim-markdown-preview {{{
g:vim_markdown_preview_hotkey = '<A-`>'
g:vim_markdown_preview_toggle = -1
# }}}
# Plugin: vim-qf {{{
g:qf_mapping_ack_style = 1
g:qf_loclist_window_bottom = 0
g:qf_auto_open_quickfix = 0
g:qf_auto_open_loclist = 0
g:qf_auto_resize = 0
g:qf_save_win_view = 0
g:qf_shorten_path = 0
# }}}
# Plugin: vim-signature {{{
g:SignatureIncludeMarkers = '=!@#$%^&*-'
g:SignatureWrapJumps = 0
g:SignatureMarkTextHLDynamic = 1
g:SignatureMarkerTextHLDynamic = 1
g:SignatureDeleteConfirmation = 0
#XXX: Change to Purge=1 when bug with text dialogs fixed
g:SignaturePurgeConfirmation = 0
g:SignatureForceMarkPlacement = 1
g:SignatureForceMarkerPlacement = 1
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
# }}}
# Plugin: vim-startify {{{
g:startify_lists = [
   { 'type': 'commands' },
   { 'type': 'sessions',  'header': ['   Sessions']       },
   { 'type': 'dir',       'header': ['   MRU ' .. getcwd()] },
   { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
   ]
g:startify_bookmarks = [
   '~/src',
   '~/.vimrc',
   '~/.bashrc',
   '~/.gitconfig',
   ]
g:startify_commands = [
   { 'c': [ 'Terminal', ':terminal ++curwin ++kill=kill']},
   { 'f': [ 'File Manager', ':Fern .']},
   ]
g:startify_change_to_vcs_root = 1
g:startify_fortune_use_unicode = 1
g:startify_enable_unsafe = 0
g:startify_session_dir = planet#paths#State('sessions')
g:startify_session_sort = 1
g:startify_custom_indices = ['d', 'g', 'h', 'l', 'm', 'n', 'p', 'r', 'u', 'w', 'x', 'y', 'z']
g:startify_use_env = 1
aug PlanetVim_Startify
au!
autocmd User StartifyReady setlocal cursorline
autocmd User Startified nmap <buffer> I i
autocmd User Startified nmap <buffer> o i
autocmd User Startified nmap <buffer> O i
autocmd User Startified nmap <buffer> a i
autocmd User Startified nmap <buffer> A i
aug END
# }}}
# Plugin: vim-test {{{
g:test#strategy = 'planet'
# }}}
# Plugin: vimspector {{{
g:vimspector_enable_mappings = 'HUMAN'
g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB', 'vscode-bash-debug' ]
# }}}
# Plugin: vista.vim {{{
g:vista_sidebar_keepalt = 1
g:vista_stay_on_open = 1
nnoremap <silent> ST :Vista<CR>
nnoremap <silent> ZT :Vista!<CR>
nnoremap <silent> <A-t> :Vista!! vim_lsp<CR>
# Nearest-symbol status is useful for a file after the user pauses, not for
# an empty startup buffer. Explicit :Vista actions remain immediately usable.
autocmd CursorHold * call planet#startup#NearestSymbol()
# }}}
# }}}
