scriptversion 4

func! planet#menu#settings#Update() abort
  if g:PlanetVim_menus_settings
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
    an 970.10  ⚙️&\\.Set\ Text\ Width                       :call planet#settings#SetTextWidth()<CR>
    an <silent> 970.10  ⚙️&\\.Set\ Line\ Endings\ ('fileformat')     :call planet#settings#SetLineEndings()<CR>
    an 970.10  ⚙️&\\.--5-- <Nop>
    an 970.10  ⚙️&\\.Set\ 'path'                            :call planet#settings#SetPath()<CR>
    an 970.10  ⚙️&\\.Set\ 'tags'                            :call planet#settings#SetTags()<CR>
    "TODO: add set *prg
    "TODO: add set *path
    an 970.10  ⚙️&\\.--6-- <Nop>
    if has("win32") || has("gui_gtk") || has("gui_mac")
      an 970.10 ⚙️&\\.Select\ Fo&nt\.\.\.                   :set guifont=*<CR>
    endif
    an 970.10  ⚙️&\\.--7-- <Nop>
    an 970.10  ⚙️&\\.Set\ Window-Local\ Syntax<Tab>:ownsyntax\ {syn} q:iownsyntax <C-x><C-v>
    an 970.10  ⚙️&\\.--8-- <Nop>
    an 970.10  ⚙️&\\.Toggle\ Verbosity<Tab>=oV              :VerbosityToggle<CR>
    an 970.10  ⚙️&\\.Open\ Verbosity\ Log<Tab>goV           :VerbosityOpenLast<CR>
    an 970.10  ⚙️&\\.--9-- <Nop>
    an 970.10  ⚙️&\\.Settings\ Buffer<Tab>:options          :options<CR>

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
    an 980.10  ⌨️&\|.Current\ Colorscheme                   :colorscheme<CR>
    an 980.10  ⌨️&\|.Syntax.Clear\ Buffer\ Syntax<Tab>:syn\ clear :syn clear<Tab>
    an 980.10  ⌨️&\|.Syntax.On\ (Reset\ Highlight)<Tab>:syn\ on :syn on<CR>
    an 980.10  ⌨️&\|.Syntax.Enable\ (Keep\ Highlight)<Tab>:syn\ enable :syn enable<CR>
    an 980.10  ⌨️&\|.Syntax.Toggle                       :if exists("g:syntax_on") \| syntax off \| else \| syntax enable \| endif<CR>
    an 980.10  ⌨️&\|.Syntax.Default<Tab>:syn\ default    :syn default<CR>
    an 980.10  ⌨️&\|.Syntax.Manual<Tab>:syn\ manual      :syn manual<CR>
    an 980.10  ⌨️&\|.Syntax.Off<Tab>:syn\ off            :syn off<CR>
    an 980.10  ⌨️&\|.Syntax.Reset<Tab>:syn\ reset        :syn reset<CR>
    an 980.10  ⌨️&\|.Syntax.List<Tab>:syn\ list          :syn list<CR>
    an 980.10  ⌨️&\|.Syntax.Case<Tab>:syn\ case          :syn case<CR>
    an 980.10  ⌨️&\|.Syntax.Foldlevel<Tab>:syn\ foldlevel :syn foldlevel<CR>
    an 980.10  ⌨️&\|.Syntax.Spell<Tab>:syn\ spell        :syn spell<CR>
    an 980.10  ⌨️&\|.Syntax.iskeyword<Tab>:syn\ iskeyword :syn iskeyword<CR>
    an 980.10  ⌨️&\|.Syntax.conceal<Tab>:syn\ conceal    :syn conceal<CR>
    an 980.10  ⌨️&\|.Syntax.Sync\ List<Tab>:syn\ sync    :syn sync<CR>
    an 980.10  ⌨️&\|.Syntax.Sync\ FromStart<Tab>:syn\ sync\ fromstart :syn sync fromstart<CR>
    an 980.10  ⌨️&\|.Syntax.Sync\ Ccomment<Tab>:syn\ sync\ ccomment :syn sync ccomment<CR>
    an 980.10  ⌨️&\|.Syntax.Sync\ Minlines<Tab>:syn\ sync\ minlines=50 :syn sync minlines=50<CR>
    an 980.10  ⌨️&\|.Syntax.Sync\ Clear<Tab>:syn\ sync\ clear :syn sync clear<CR>
    an 980.10  ⌨️&\|.Syntax.Highlight\ List<Tab>:hi              :hi<CR>
    an 980.10  ⌨️&\|.Syntax.Highlight\ Clear<Tab>:hi\ clear      :hi clear<CR>
    an 980.10  ⌨️&\|.Co&lor\ Test                           :sp $VIMRUNTIME/syntax/colortest.vim<Bar>so %<CR>
    an 980.10  ⌨️&\|.&Highlight\ Test                       :runtime syntax/hitest.vim<CR>
    an 980.10  ⌨️&\|.&Spell\ Dump<Tab>:spelldump            :spelldump<CR>
    an 980.10  ⌨️&\|.Run\ Vim\ Script                       :browse so<CR>
    an 980.10  ⌨️&\|.Source\ Current\ Vim\ Script           :so %<CR>
    an 980.10  ⌨️&\|.Ex\ Vim\ Mode\ (Dangerous!)<Tab>gX     gQ
    an 980.10  ⌨️&\|.Ex\ Mode\ (Dangerous!)<Tab>Q           Q
    an 980.10  ⌨️&\|.Open\ $VIMRUNTIME\ Folder              :tabnew<CR>:Fern $VIMRUNTIME<CR>
    an 980.10  ⌨️&\|.Debug <Nop>
    an disable ⌨️&\|.Debug
    an 980.10  ⌨️&\|.Profile\ Syntax.Start\ measuring\ syntax\ times<Tab>:syntime\ on :syntime on<CR>
    an 980.10  ⌨️&\|.Profile\ Syntax.Stop\ measuring\ syntax\ times<Tab>:syntime\ off :syntime off<CR>
    an 980.10  ⌨️&\|.Profile\ Syntax.Restart\ measuring\ syntax\ times<Tab>:syntime\ clear :syntime clear<CR>
    an 980.10  ⌨️&\|.Profile\ Syntax.Report\ syntax\ times<Tab>:syntime\ report :syntime report<CR>
    an 980.10  ⌨️&\|.WinBar.Set\ for QF/LL                  <Cmd>call planet#winbar()<CR>
    an 980.10  ⌨️&\|.WinBar.Set\ for Terminal               <Cmd>call planet#winbar()<CR>
    an 980.10  ⌨️&\|.WinBar.Set\ for Output                 <Cmd>call planet#winbar()<CR>
    an 980.10  ⌨️&\|.WinBar.Clear                           <Cmd>unmenu WinBar<CR>

    " Help
    an 990.10  ❔&?.Help <Nop>
    an disable ❔&?.Help
    an 990.10  ❔&?.&Lookup\ Word\ under\ Cursor<Tab>K         K
    an 990.10  ❔&?.&TLDR\ Word\ under\ Cursor                 :call planet#term#RunCmd('tldr ' .. expand('<cword>'))<CR>
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
    an 990.110 ❔&?.Others.Emergency\ Exit                     <Cmd>call planet#planet#EmergencyExit()<CR>
    an 990.110 ❔&?.Others.Restore\ PlanetVim\ Menu            <Cmd>call planet#planet#PlanetToggle()<CR>
    an 990.110 ❔&?.--4-- <Nop>
    an 990.110 ❔&?.&Close\ Help\ Window                       :helpclose<CR>
    an 990.110 ❔&?.--5-- <Nop>
    an 990.120 ❔&?.&About                                     :version<CR>
  else
    silent! aunmenu ⚙️&\\
    silent! aunmenu ⌨️&\|
    silent! aunmenu ❔&h
  endif
endfunc
