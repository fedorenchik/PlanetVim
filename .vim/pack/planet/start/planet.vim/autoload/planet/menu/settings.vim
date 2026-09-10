vim9script

export def Update(): number
  if planet#menu#Visible('settings')
    planet#display#Menus('settings')
    # Settings (Options) (unimpaired settings)
    PlanetMenu an 970.10  ⚙️&\\.Settings <Nop>
    an disable ⚙️&\\.Settings
    PlanetMenu an 970.10  ⚙️&\\.Tabs:\ &2<Tab>:set\ et\ ts=2\ sw=2           :set et ts=2 sw=2<CR>
    PlanetMenu an 970.10  ⚙️&\\.Tabs:\ &4<Tab>:set\ et\ ts=4\ sw=4           :set et ts=4 sw=4<CR>
    PlanetMenu an 970.10  ⚙️&\\.Tabs:\ &8<Tab>:set\ noet\ ts=8\ sw=8         :set noet ts=8 sw=8<CR>
    PlanetMenu an 970.10  ⚙️&\\.--1-- <Nop>
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'cursorline'<Tab>yoc           yoc
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'hlsearch'<Tab>yoh             yoh
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'ignorecase'<Tab>yoi           yoi
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'number'<Tab>yon               yon
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'relativenumber'<Tab>yor       yor
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'cursorcolumn'<Tab>you         you
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'virtualedit'<Tab>yov          yov
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'wrap'<Tab>yow                 yow
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ word\ wrap                     :set lbr! lbr?<CR>
    PlanetMenu am 970.10  ⚙️&\\.Toggle\ 'cursorline'\ &&\ 'cursorcolumn'<Tab>yox yox
    PlanetMenu an 970.10  ⚙️&\\.--2-- <Nop>
    PlanetMenu am 970.10  ⚙️&\\.'cmdheight':\ 2                        :set cmdheight=2<CR>
    PlanetMenu an 970.10  ⚙️&\\.--3-- <Nop>
    PlanetMenu am 970.10  ⚙️&\\.'scrolloff':\ 0                        :set so=0<CR>
    PlanetMenu am 970.10  ⚙️&\\.'scrolloff':\ 2\ (default)             :set so=2<CR>
    PlanetMenu am 970.10  ⚙️&\\.'scrolloff':\ 1000                     :set so=1000<CR>
    PlanetMenu an 970.10  ⚙️&\\.--4-- <Nop>
    PlanetMenu an 970.10  ⚙️&\\.Set\ Text\ Width                       :call planet#settings#SetTextWidth()<CR>
    PlanetMenu an <silent> 970.10  ⚙️&\\.Set\ Line\ Endings\ ('fileformat') :call planet#settings#SetLineEndings()<CR>
    PlanetMenu an 970.10  ⚙️&\\.--5-- <Nop>
    PlanetMenu an 970.10  ⚙️&\\.Set\ 'path'                            :call planet#settings#SetPath()<CR>
    PlanetMenu an 970.10  ⚙️&\\.Set\ 'tags'                            :call planet#settings#SetTags()<CR>
    for option in ['makeprg', 'grepprg', 'formatprg', 'equalprg', 'keywordprg', 'dictionary', 'thesaurus', 'include', 'define', 'suffixesadd']
      execute 'PlanetMenu an 970.10 ⚙️&\\.Buffer\ Options.' .. option
            \ .. ' <Cmd>call planet#settings#EditOption(' .. string(option) .. ')<CR>'
    endfor
    PlanetMenu an 970.10  ⚙️&\\.--6-- <Nop>
    PlanetMenu an 970.10  ⚙️&\\.Set\ GUI\ Dialogs                      :call planet#planet#SetGuiDialogs()<CR>
    PlanetMenu an 970.10  ⚙️&\\.Set\ Text\ Dialogs                     :call planet#planet#SetTextDialogs()<CR>
    PlanetMenu an 970.10  ⚙️&\\.--7-- <Nop>
    if has("win32") || has("gui_gtk")
      PlanetMenu an 970.10 ⚙️&\\.Select\ Fo&nt\.\.\.                   :set guifont=*<CR>
    endif
    PlanetMenu an 970.10  ⚙️&\\.--8-- <Nop>
    PlanetMenu an 970.10  ⚙️&\\.Set\ Window-Local\ Syntax<Tab>:ownsyntax\ {syn} q:iownsyntax <C-x><C-v>
    PlanetMenu an 970.10  ⚙️&\\.--9-- <Nop>
    PlanetMenu an 970.10  ⚙️&\\.Toggle\ Verbosity<Tab>=oV              :VerbosityToggle<CR>
    PlanetMenu an 970.10  ⚙️&\\.Open\ Verbosity\ Log<Tab>goV           :VerbosityOpenLast<CR>
    PlanetMenu an 970.10  ⚙️&\\.--10-- <Nop>
    PlanetMenu an 970.10  ⚙️&\\.Settings\ Buffer<Tab>:options          :options<CR>

    # Show current maps (nnoremap, etc.)
    PlanetMenu an 980.10  ⌨️&\|.Maps <Nop>
    an disable ⌨️&\|.Maps
    PlanetMenu an 980.10  ⌨️&\|.C&hoose\.\.\.                          :Clap maps<CR>
    PlanetMenu an 980.10  ⌨️&\|.Information <Nop>
    an disable ⌨️&\|.Information
    PlanetMenu an 980.10  ⌨️&\|.Cursor\ Filename<Tab><C-g>             <C-g>
    PlanetMenu an 980.10  ⌨️&\|.Cursor\ Position<Tab>g<C-g>            g<C-g>
    PlanetMenu an 980.10  ⌨️&\|.Character\ under\ Cursor<Tab>g8        g8
    PlanetMenu an 980.10  ⌨️&\|.Ascii\ under\ Cursor<Tab>ga            ga
    PlanetMenu an 980.10  ⌨️&\|.Output\ of\ previous\ Command<Tab>g<   g<
    PlanetMenu an 980.10  ⌨️&\|.List\ All\ QF                          :clist!<CR>
    PlanetMenu an 980.10  ⌨️&\|.List\ All\ LL                          :llist!<CR>
    PlanetMenu an 980.10  ⌨️&\|.List\ QF\ Lists                        :chistory<CR>
    PlanetMenu an 980.10  ⌨️&\|.List\ LL\ Lists                        :lhistory<CR>
    PlanetMenu an 980.10  ⌨️&\|.Current\ Colorscheme                   :colorscheme<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Clear\ Buffer\ Syntax<Tab>:syn\ clear :syn clear<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.On\ (Reset\ Highlight)<Tab>:syn\ on :syn on<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Enable\ (Keep\ Highlight)<Tab>:syn\ enable :syn enable<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Toggle                       :if exists("g:syntax_on") \| syntax off \| else \| syntax enable \| endif<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Default<Tab>:syn\ default    :syn default<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Manual<Tab>:syn\ manual      :syn manual<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Off<Tab>:syn\ off            :syn off<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Reset<Tab>:syn\ reset        :syn reset<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.List<Tab>:syn\ list          :syn list<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Case<Tab>:syn\ case          :syn case<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Foldlevel<Tab>:syn\ foldlevel :syn foldlevel<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Spell<Tab>:syn\ spell        :syn spell<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.iskeyword<Tab>:syn\ iskeyword :syn iskeyword<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.conceal<Tab>:syn\ conceal    :syn conceal<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Sync\ List<Tab>:syn\ sync    :syn sync<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Sync\ FromStart<Tab>:syn\ sync\ fromstart :syn sync fromstart<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Sync\ Ccomment<Tab>:syn\ sync\ ccomment :syn sync ccomment<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Sync\ Minlines<Tab>:syn\ sync\ minlines=50 :syn sync minlines=50<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Sync\ Clear<Tab>:syn\ sync\ clear :syn sync clear<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Highlight\ List<Tab>:hi              :hi<CR>
    PlanetMenu an 980.10  ⌨️&\|.Syntax.Highlight\ Clear<Tab>:hi\ clear      :hi clear<CR>
    PlanetMenu an 980.10  ⌨️&\|.Co&lor\ Test                           :sp $VIMRUNTIME/syntax/colortest.vim<Bar>so %<CR>
    PlanetMenu an 980.10  ⌨️&\|.&Highlight\ Test                       :runtime syntax/hitest.vim<CR>
    PlanetMenu an 980.10  ⌨️&\|.&Spell\ Dump<Tab>:spelldump            :spelldump<CR>
    PlanetMenu an 980.10  ⌨️&\|.Run\ Vim\ Script                       :browse so<CR>
    PlanetMenu an 980.10  ⌨️&\|.Source\ Current\ Vim\ Script           :so %<CR>
    PlanetMenu an 980.10  ⌨️&\|.Ex\ Vim\ Mode\ (Dangerous!)<Tab>gX     gQ
    PlanetMenu an 980.10  ⌨️&\|.Ex\ Mode\ (Dangerous!)<Tab>Q           Q
    PlanetMenu an 980.10  ⌨️&\|.Open\ $VIMRUNTIME\ Folder              :tabnew<CR>:Fern $VIMRUNTIME<CR>
    PlanetMenu an 980.10  ⌨️&\|.Debug <Nop>
    an disable ⌨️&\|.Debug
    PlanetMenu an 980.10  ⌨️&\|.Profile\ Syntax.Start\ measuring\ syntax\ times<Tab>:syntime\ on :syntime on<CR>
    PlanetMenu an 980.10  ⌨️&\|.Profile\ Syntax.Stop\ measuring\ syntax\ times<Tab>:syntime\ off :syntime off<CR>
    PlanetMenu an 980.10  ⌨️&\|.Profile\ Syntax.Restart\ measuring\ syntax\ times<Tab>:syntime\ clear :syntime clear<CR>
    PlanetMenu an 980.10  ⌨️&\|.Profile\ Syntax.Report\ syntax\ times<Tab>:syntime\ report :syntime report<CR>
    PlanetMenu an 980.10  ⌨️&\|.WinBar.Set\ for\ QF/LL                  <Cmd>call planet#winbar#Preset('quickfix')<CR>
    PlanetMenu an 980.10  ⌨️&\|.WinBar.Set\ for\ Terminal               <Cmd>call planet#winbar#Preset('terminal')<CR>
    PlanetMenu an 980.10  ⌨️&\|.WinBar.Set\ for\ Output                 <Cmd>call planet#winbar#Preset('terminal')<CR>
    PlanetMenu an 980.10  ⌨️&\|.WinBar.Clear                           <Cmd>call planet#winbar#Change('clear')<CR>

    # Help
    PlanetMenu an 990.10  ❔&?.Help <Nop>
    an disable ❔&?.Help
    PlanetMenu an 990.10  ❔&?.Help\ Contents                             <Cmd>h<CR>
    PlanetMenu an 990.10  ❔&?.&Lookup\ Word\ under\ Cursor<Tab>K         K
    PlanetMenu an 990.10  ❔&?.&TLDR\ Word\ under\ Cursor                 <Cmd>call planet#term#RunArgv(['tldr', expand('<cword>')])<CR>
    PlanetMenu an 990.20  ❔&?.Inde&x                                     <Cmd>h index<CR>
    PlanetMenu an 990.30  ❔&?.&QuickRef                                  <Cmd>h quickref<CR>
    PlanetMenu an 990.40  ❔&?.&Plugins\ Documentation                    <Cmd>h local-additions<CR>
    PlanetMenu an 990.50  ❔&?.View\ Log\ Messages<Tab>:messages          <Cmd>messages<CR>
    PlanetMenu an 990.60  ❔&?.--1-- <Nop>
    PlanetMenu an 990.70  ❔&?.View\ &PlanetVim\ Community                <Cmd>call planet#gui#OpenUrl('https://matrix.to/#/+planetvim:matrix.org')<CR>
    PlanetMenu an 990.70  ❔&?.&Join\ PlanetVim\ Chat                     <Cmd>call planet#gui#OpenUrl('https://matrix.to/#/#planetvim_discussion:matrix.org?via=matrix.org')<CR>
    PlanetMenu an 990.80  ❔&?.--2-- <Nop>
    PlanetMenu an 990.90  ❔&?.Check\ for\ &Updates                       <Cmd>call planet#gui#OpenUrl('https://github.com/fedorenchik/PlanetVim/releases')<CR>
    PlanetMenu an 990.100 ❔&?.Add\ Feature\ Request                      <Cmd>call planet#gui#OpenUrl('https://github.com/fedorenchik/PlanetVim/issues/new?labels=enhancement&template=feature_request.md')<CR>
    PlanetMenu an 990.100 ❔&?.Report\ PlanetVim\ &Issue                  <Cmd>call planet#gui#OpenUrl('https://github.com/fedorenchik/PlanetVim/issues/new?template=bug_report.md')<CR>
    PlanetMenu an 990.110 ❔&?.--3-- <Nop>
    PlanetMenu an 990.110 ❔&?.Others.Emergency\ Exit                     <Cmd>call planet#planet#EmergencyExit()<CR>
    PlanetMenu an 990.110 ❔&?.Others.Restore\ PlanetVim\ Menu            <Cmd>call planet#planet#PlanetToggle()<CR>
    PlanetMenu an 990.110 ❔&?.--4-- <Nop>
    PlanetMenu an 990.110 ❔&?.&Close\ Help\ Window                       <Cmd>helpclose<CR>
    PlanetMenu an 990.110 ❔&?.--5-- <Nop>
    PlanetMenu an 990.120 ❔&?.&About                                     <Cmd>version<CR>
    planet#completion#Menus('settings')
    planet#buffer_options#Menus('settings')
    planet#input#Menus('settings')
    planet#appearance#Menus()
    planet#learn#Menus()
  else
    silent! aunmenu ⚙️&\\
    silent! aunmenu ⌨️&\|
    silent! aunmenu ❔&?
  endif
  return 0
enddef
