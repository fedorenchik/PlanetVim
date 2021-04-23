scriptversion 4

func! planet#menu#basic#update() abort
  if g:PlanetVim_menus_basic
    " File
    an 110.10  📁&f.File <Nop>
    an disable 📁&f.File
    an 110.20  📁&f.N&ew<Tab>:enew                             :confirm enew<CR>
    an 110.30  📁&f.New\ Split<Tab>:new<Tab>+n                 <C-w>n
    an 110.40  📁&f.New\ &VSplit<Tab>:vnew                     :vnew<CR>
    an 110.50  📁&f.New\ &Tab                                  :confirm tabnew<CR>
    an 110.60  📁&f.New\ GUI\ &Window                          :silent !gvim<CR>
    an 110.60  📁&f.New\ Project.Vim\ Plugin                   :TODO
    an 110.60  📁&f.New\ Project.Blender\ Addon                :TODO
    an 110.60  📁&f.New\ Project.Nextcloud\ App                :TODO
    an 110.60  📁&f.New\ Project.Linux\ OOT\ Kernel\ Module    :TODO"with parameters/proc/debugfs support
    an 110.60  📁&f.New\ Project.Linux\ OOT\ Device\ Driver    :TODO"with parameters/OF framework support
    an 110.60  📁&f.New\ Project.Linux\ Device\ Tree           :TODO"device tree definition
    an 110.60  📁&f.New\ Project.Wordpress\ Plugin             :TODO
    an 110.60  📁&f.New\ Project.Yocto\ System                 :TODO
    an 110.60  📁&f.New\ Project.ROS\ Package                  :TODO
    an 110.60  📁&f.New\ Project.C++\ DSL                      :TODO"example DSL in C++
    an 110.60  📁&f.New\ Project.Python\ DSL                   :TODO"example DSL in Python
    an 110.60  📁&f.New\ Project.LaTex\ Book                   :TODO
    an 110.60  📁&f.New\ Project.Git\ Clone\.\.\.              :TODO
    an 110.60  📁&f.New\ Project.Git\ Init\.\.\.               :TODO
    an 110.60  📁&f.New\ File.C++\ Class                       :TODO"copy from template
    an 110.60  📁&f.New\ File.Python\ App                      :TODO"copy from template
    an 110.60  📁&f.New\ File.Python\ Class                    :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt\ Designer\ Form\ Class        :TODO"copy from template
    an 110.60  📁&f.New\ File.SCXML                            :TODO"copy from template
    an 110.60  📁&f.New\ File.qmodel                           :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt\ Item\ Model                  :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt\ Designer\ Form               :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt\ Resource\ File               :TODO"copy from template
    an 110.60  📁&f.New\ File.QML                              :TODO"copy from template
    an 110.60  📁&f.New\ File.QtQuick\ UI\ (\.ui\.qml)         :TODO"copy from template
    an 110.60  📁&f.New\ File.JS                               :TODO"copy from template
    an 110.60  📁&f.New\ File.LaTex\ Article                   :TODO"copy from template
    an 110.60  📁&f.New\ File.LaTex\ Chapter                   :TODO"copy from template
    an 110.70  📁&f.--1-- <Nop>
    an 110.80  📁&f.&Open\ File                                :Clap files<CR>
    an 110.80  📁&f.Open\ File\ Dialog                         :browse confirm e<CR>
    an 110.90  📁&f.Open\ &File\ Manager<Tab>-                 :Fern . -reveal=%<CR>
    an 110.100 📁&f.File\ &Manager\ Side\ Bar                  :Fern . -reveal=% -drawer -toggle<CR>
    an 110.110 📁&f.Open\ &Recent                              :Clap history<CR>
    an 110.110 📁&f.QF\ &Recent                                :call planet#file#OldFilesQF()<CR>
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
    an <silent> 110.160 📁&f.Save\ A&ll<Tab>:wall              :silent confirm wall<Bar>echohl Todo<Bar>echo "All Saved"<Bar>echohl None<CR>
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
    an 110.270 📁&f.SudoSave                                   :SudoWrite<CR>
    an 110.280 📁&f.Rename                                     :browse confirm Rename<CR>
    an 110.290 📁&f.Change\ File\ Permissions                  :Chmod 0755
    an 110.300 📁&f.Delete\ From\ Disk                         :Delete!<CR>
    an 110.300 📁&f.--7-- <Nop>
    an 110.310 📁&f.Mkdir                                      :Mkdir! <C-z>
    an 110.320 📁&f.Cd<Tab>:cd                                 :cd <C-z>
    an 110.330 📁&f.Other\ Cd.Temp\ Cd\ to\ Project\ Root\ in\ Window :TODO"lcd to project root, but back to global cwd on au WinLeave <buffer> <once>
    an 110.330 📁&f.Other\ Cd.Temp\ Cd\ in\ Window             :TODO"lcd, but back to global cwd on au WinLeave <buffer> <once>
    an 110.330 📁&f.Other\ Cd.Cd\ in\ Tab<Tab>:tcd             :tcd <C-z>
    an 110.340 📁&f.Other\ Cd.Cd\ in\ Window<Tab>:lcd          :lcd <C-z>
    an 110.320 📁&f.Other\ Cd.Cd\ to\ Previous\ Directory<Tab>:cd\ - :cd -<CR>
    an 110.330 📁&f.Other\ Cd.Cd\ to\ Previous\ Directory\ in\ Tab<Tab>:tcd\ - :tcd -<CR>
    an 110.340 📁&f.Other\ Cd.Cd\ to\ Previous\ Directory\ in\ Window<Tab>:lcd\ - :lcd -<CR>
    an 110.330 📁&f.Other\ Cd.Cd\ Windows\ in\ Tab<Tab>:windo\ cd :windo cd <C-z>
    an 110.330 📁&f.Other\ Cd.Cd\ All\ Tabs<Tab>:tabdo\ cd     :tabdo cd <C-z>
    an 110.330 📁&f.Other\ Cd.Cd\ All\ Windows<Tab>:tabdo\ windo\ cd :tabdo windo cd <C-z>
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
    an 120.290 📝&e.Retab\ File<Tab>:retab!                    <Cmd>retab!<CR>
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
    an 130.300 🔎&/.Search\ Dialog<Tab>:promptfind           :promptfind<CR>
    an 130.320 🔎&/.Substitute <Nop>
    an disable 🔎&/.Substitute
    an 130.330 🔎&/.Substitute\ Selection                    :TODO...
    an 130.280 🔎&/.--8-- <Nop>
    an 130.330 🔎&/.Repeat\ on\ Line<Tab>&                   &
    an 130.330 🔎&/.Repeat\ on\ Line\ keep\ Flags<Tab>:&&    <Cmd>&&<CR>
    an 130.340 🔎&/.Repeat\ on\ File<Tab>g&                  g&
    an 130.280 🔎&/.--9-- <Nop>
    an 130.340 🔎&/.Repeat\ with\ Search\ Pattern<Tab>:~     <Cmd>~<CR>
    an 130.340 🔎&/.Repeat\ with\ Search\ Pattern\ keep\ Flags<Tab>:~& <Cmd>~&<CR>
    an 130.280 🔎&/.--10-- <Nop>
    an 130.340 🔎&/.Substitute\ Dialog<Tab>:promptrepl       :promptrepl<CR>

    " Selection
    "FIXME: In Insert mode this only works for a SINGLE Normal mode command
    an 140.10  🖍️&s.Selection <Nop>
    an disable 🖍️&s.Selection
    an 140.10  🖍️&s.Select\ All                             :call planet#edit#SelectAll()<CR>
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
    an 150.70  📺&v.GUI\ Highlight.Menu                     :h hl-Menu
    an 150.70  📺&v.GUI\ Highlight.Scrollbar                :h hl-Scrollbar
    an 150.70  📺&v.GUI\ Highlight.Tooltip                  :h hl-Tooltip

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
  else
    silent! aunmenu 📁&f
    silent! aunmenu 📝&e
    silent! aunmenu ✏️&m
    silent! aunmenu 🔎&/
    silent! aunmenu 🖍️&s
    silent! aunmenu 📺&v
    silent! aunmenu ↕️&g
    silent! aunmenu 🧭&n
  endif
endfunc
