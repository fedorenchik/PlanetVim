scriptversion 4

func! planet#menu#basic#Update() abort
  if g:PlanetVim_menus_basic
    " File
    an 110.10  📁&f.File <Nop>
    an disable 📁&f.File
    an 110.20  📁&f.N&ew<Tab>:enew                             <Cmd>confirm enew<CR>
    an 110.30  📁&f.New\ Split<Tab>:new<Tab>+n                 <C-w>n
    an 110.40  📁&f.New\ &VSplit<Tab>:vnew                     <Cmd>vnew<CR>
    an 110.50  📁&f.New\ &Tab                                  <Cmd>tabnew<CR>
    an 110.60  📁&f.New\ GUI\ &Window                          <Cmd>silent !gvim<CR>
    an 110.60  📁&f.New\ Pro&ject.Vim\ Plugin                  <Cmd>call planet#file#NewProject('vim-plugin')<CR>
    an 110.60  📁&f.New\ Pro&ject.Gtk\ 3\ Builder\ App         <Cmd>call planet#file#NewProject('Gtk3BuilderApp')<CR>
    an 110.60  📁&f.New\ Pro&ject.Vue\ 3\ App                  <Cmd>call planet#file#NewProjectFromScript('vue3')<CR>
    an 110.60  📁&f.New\ Pro&ject.Nuxt\ App                    <Cmd>call planet#file#NewProjectFromScript('nuxt')<CR>
    an 110.60  📁&f.New\ Pro&ject.Electron\ App                <Cmd>call planet#file#NewProjectFromScript('electron')<CR>
    an 110.60  📁&f.New\ Pro&ject.Platformio\ espidf\ Firmware <Cmd>call planet#file#NewProject('pio_idf_fw')<CR>
    an 110.60  📁&f.New\ Pro&ject.Blender\ Addon               :TODO
    an 110.60  📁&f.New\ Pro&ject.Nextcloud\ App               :TODO
    an 110.60  📁&f.New\ Pro&ject.Linux\ OOT\ Kernel\ Module   :TODO"with parameters/proc/debugfs support
    an 110.60  📁&f.New\ Pro&ject.Linux\ OOT\ Device\ Driver   :TODO"with parameters/OF framework support
    an 110.60  📁&f.New\ Pro&ject.Linux\ Device\ Tree          :TODO"device tree definition
    an 110.60  📁&f.New\ Pro&ject.Wordpress\ Plugin            :TODO
    an 110.60  📁&f.New\ Pro&ject.Wordpress\ Theme             :TODO
    an 110.60  📁&f.New\ Pro&ject.Yocto\ System                :TODO
    an 110.60  📁&f.New\ Pro&ject.ROS\ Package                 :TODO
    an 110.60  📁&f.New\ Pro&ject.C++\ DSL                     :TODO"example DSL in C++
    an 110.60  📁&f.New\ Pro&ject.Python\ DSL                  :TODO"example DSL in Python
    an 110.60  📁&f.New\ Pro&ject.LaTex\ Book                  :TODO
    an 110.60  📁&f.New\ Pro&ject.OpenGL.GLFW\ (GLEW,\ C++,\ OpenGL\ 3\.2)\ App <Cmd>call planet#file#NewProject('glfw-app')<CR>
    an 110.60  📁&f.New\ Pro&ject.OpenGL.SDL\ (GLEW,\ C++,\ OpenGL\ 3\.2)\ App <Cmd>call planet#file#NewProject('sdl-app')<CR>
    an 110.60  📁&f.New\ Pro&ject.OpenGL.SFML\ (GLEW,\ C++,\ OpenGL\ 3\.2)\ App <Cmd>call planet#file#NewProject('sfml-app')<CR>
    an 110.60  📁&f.New\ Pro&ject.Basic\ Vulkan                :TODO
    an 110.60  📁&f.New\ Pro&ject.Git\ Clone\.\.\.             <Cmd>call planet#term#RunCmdAskArgs('git clone --recurse-submodules ', 'Repo: ', 'https://github.com/')<CR>
    an 110.60  📁&f.New\ Pro&ject.Git\ Init                    <Cmd>call planet#term#RunCmd('git init && git add --all && git commit -m "Initial Commit"')<CR>
    an 110.60  📁&f.New\ File.Makefile                         :TODO"copy from template
    an 110.60  📁&f.New\ File.C++\ Class                       :TODO"copy from template
    an 110.60  📁&f.New\ File.C++\ Class\ Enum                 :TODO"copy from template
    an 110.60  📁&f.New\ File.C++\ Module                      :TODO"copy from template
    an 110.60  📁&f.New\ File.Python\ App                      :TODO"copy from template
    an 110.60  📁&f.New\ File.Python\ Class                    :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.Qt\ Designer\ Form\ Class     :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.SCXML                         :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.qmodel                        :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.Qt\ Item\ Model               :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.Qt\ Designer\ Form            :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.Qt\ Resource\ File            :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.QML                           :TODO"copy from template
    an 110.60  📁&f.New\ File.Qt.QtQuick\ UI\ (\.ui\.qml)      :TODO"copy from template
    an 110.60  📁&f.New\ File.GLSL.Vertex\ Shader\ (\.vert)    :TODO
    an 110.60  📁&f.New\ File.GLSL.Fragment\ Shader\ (\.frag)  :TODO
    an 110.60  📁&f.New\ File.GLSL.Geometry\ Shader\ (\.geom)  :TODO
    an 110.60  📁&f.New\ File.GLSL.Compute\ Shader\ (\.comp)   :TODO
    an 110.60  📁&f.New\ File.GLSL.Tesselation\ Control\ Shader\ (\.tesc) :TODO
    an 110.60  📁&f.New\ File.GLSL.Tesselation\ Evaluation\ Shader\ (\.tese) :TODO
    an 110.60  📁&f.New\ File.Web.HTML                         :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.CSS                          :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.JavaScript                   :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.TypeScript                   :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.PHP                          :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.Python\ Django               :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.Python\ Flask                :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.Vue\ Component               :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.--1-- <Nop>
    an 110.60  📁&f.New\ File.Web.\.htaccess                   :TODO"copy from template
    an 110.60  📁&f.New\ File.Web.robots\.txt                  :TODO"copy from template
    an 110.60  📁&f.New\ File.LaTex.Article                    :TODO"copy from template
    an 110.60  📁&f.New\ File.LaTex.Chapter                    :TODO"copy from template
    an 110.70  📁&f.--1-- <Nop>
    an 110.80  📁&f.Choose\ File                               <Cmd>Clap files<CR>
    an 110.80  📁&f.Open\ File\ Dialog                         <Cmd>browse confirm e<CR>
    an 110.90  📁&f.Open\ &File\ Manager<Tab>-                 <Cmd>Fern . -reveal=%<CR>
    an 110.100 📁&f.File\ &Manager\ Side\ Bar                  <Cmd>Fern . -reveal=% -drawer -toggle<CR>
    an 110.110 📁&f.Choose\ &Recent                            <Cmd>Clap history<CR>
    an 110.110 📁&f.QF\ &Recent                                <Cmd>call planet#file#OldFilesQF()<CR>
    an 110.120 📁&f.F&ind<Tab>:find                            :find 
    an 110.230 📁&f.Advanced.New\ Temp\ File                   <Cmd>exe "e " .. tempname()<CR>
    an 110.230 📁&f.Advanced.Open\ File\ under\ Cursor<Tab>gF           gF
    an 110.240 📁&f.Advanced.Split\ Open\ File\ under\ Cursor<Tab>+F    <C-w>F
    an 110.250 📁&f.Advanced.Tab\ Open\ File\ under\ Cursor<Tab>+gF     <C-w>gF
    an 110.110 📁&f.Advanced.Open\ Read\ Only                  <Cmd>browse view<CR>
    an 110.110 📁&f.Advanced.Split\ Read\ Only                 <Cmd>browse sview<CR>
    an 110.110 📁&f.Advanced.VSplit\ Read\ Only                <Cmd>browse view<CR>
    an 110.110 📁&f.Advanced.Tab\ Read\ Only                   <Cmd>browse view<CR>
    an 110.110 📁&f.Advanced.Split\ Find                       :sfind 
    an 110.120 📁&f.Advanced.F&ind\ in\ Tab<Tab>:tabfind       :tabfind 
    an 110.130 📁&f.--2-- <Nop>
    an 110.140 📁&f.&Save<Tab>:w                               <Cmd>if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm up<Bar>endif<CR>
    an 110.150 📁&f.Save\ &As\.\.\.<Tab>:saveas                <Cmd>browse confirm saveas<CR>
    an <silent> 110.160 📁&f.Save\ A&ll<Tab>:wall              <Cmd>silent confirm wall<Bar>echohl Directory<Bar>echo "All Saved"<Bar>echohl None<CR>
    an 110.170 📁&f.--3-- <Nop>
    an 110.170 📁&f.Toggle\ AutoSave                           :TODO
    an 110.170 📁&f.--4-- <Nop>
    an 110.180 📁&f.Export\ (Selected)\ as\ HTML               <Cmd>TOhtml<CR>
    an 110.180 📁&f.Convert\ to\ HTML                          <Cmd>runtime syntax/2html.vim<CR>
    an 110.190 📁&f.--5-- <Nop>
    am 110.200 📁&f.&Previous\ in\ Folder<Tab>[f               [f
    am 110.210 📁&f.&Next\ in\ Folder<Tab>]f                   ]f
    an 110.220 📁&f.--6-- <Nop>
    an 110.270 📁&f.SudoSave                                   <Cmd>SudoWrite<CR>
    an 110.280 📁&f.Rename                                     <Cmd>browse confirm Rename<CR>
    an 110.290 📁&f.Change\ File\ Permissions                  :Chmod 0755
    an 110.300 📁&f.Delete\ From\ Disk                         <Cmd>Delete!<CR>
    an 110.310 📁&f.Mkdir                                      :Mkdir! <C-z>
    an 110.330 📁&f.C&d.Cd<Tab>:cd\ ->                         :cd <C-z>
    an 110.330 📁&f.C&d.Tab\ Cd<Tab>:tcd\ ->                   :tcd <C-z>
    an 110.340 📁&f.C&d.Local\ Cd<Tab>:lcd\ ->                 :lcd <C-z>
    an 110.340 📁&f.C&d.Pwd<Tab>:pwd                           <Cmd>verbose pwd<CR>
    an 110.330 📁&f.C&d.--1-- <Nop>
    an 110.330 📁&f.C&d.Cd\ to\ File\ Directory                <Cmd>cd %:h<CR>
    an 110.330 📁&f.C&d.Tcd\ to\ File\ Directory               <Cmd>tcd %:h<CR>
    an 110.330 📁&f.C&d.Lcd\ to\ File\ Directory               <Cmd>lcd %:h<CR>
    an 110.330 📁&f.C&d.--2-- <Nop>
    an 110.330 📁&f.C&d.Temp\ Cd\ to\ Project\ Root\ in\ Window :TODO"lcd to project root, but back to global cwd on au WinLeave <buffer> <once>
    an 110.330 📁&f.C&d.Temp\ Cd\ in\ Window                   :TODO"lcd, but back to global cwd on au WinLeave <buffer> <once>
    an 110.330 📁&f.C&d.--3-- <Nop>
    an 110.320 📁&f.C&d.Cd\ to\ Previous\ Directory<Tab>:cd\ - <Cmd>cd -<CR>
    an 110.330 📁&f.C&d.Tab\ Cd\ to\ Previous\ Directory<Tab>:tcd\ - <Cmd>tcd -<CR>
    an 110.340 📁&f.C&d.Local\ Cd\ to\ Previous\ Directory<Tab>:lcd\ - <Cmd>lcd -<CR>
    an 110.330 📁&f.C&d.--4-- <Nop>
    an 110.330 📁&f.C&d.Cd\ Windows\ in\ Tab<Tab>:windo\ cd    :windo cd <C-z>
    an 110.330 📁&f.C&d.Cd\ All\ Tabs<Tab>:tabdo\ cd           :tabdo cd <C-z>
    an 110.330 📁&f.C&d.Cd\ All\ Windows<Tab>:tabdo\ windo\ cd :tabdo windo cd <C-z>
    an 110.330 📁&f.C&d.--5-- <Nop>
    an 110.330 📁&f.C&d.cd\ \.\.                               <Cmd>cd ..<CR>
    an 110.330 📁&f.C&d.tcd\ \.\.                              <Cmd>tcd ..<CR>
    an 110.330 📁&f.C&d.lcd\ \.\.                              <Cmd>lcd ..<CR>
    an 110.330 📁&f.C&d.--6-- <Nop>
    an 110.330 📁&f.C&d.tcd\ ->\ cd                            <Cmd>call planet#file#TcdToCd()<CR>
    an 110.330 📁&f.C&d.lcd\ ->\ cd                            <Cmd>call planet#file#LcdToCd()<CR>
    an 110.330 📁&f.C&d.--7-- <Nop>
    an 110.330 📁&f.C&d.Clear\ Local\ cd                       <Cmd>call planet#file#ClearLocalCwd('')<CR>
    an 110.330 📁&f.C&d.Clear\ Local\ cd\ in\ Tab              <Cmd>call planet#file#ClearLocalCwd('windo')<CR>
    an 110.330 📁&f.C&d.Clear\ Local\ cd\ Globally             <Cmd>call planet#file#ClearLocalCwd('tabdo windo')<CR>
    an 110.360 📁&f.&Close<Tab>:bdelete                        <Cmd>bdelete<CR>

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
    an 120.90  📝&e.Undo\ &History                             <Cmd>UndotreeToggle<CR>
    an 120.100 📝&e.--3-- <Nop>
    an 120.110 📝&e.Cu&t<Tab>"+d                               <Cmd>d +<CR>
    an 120.120 📝&e.&Copy<Tab>"+y                              <Cmd>y +<CR>
    an 120.130 📝&e.&Paste<Tab>"+p                             "+p
    an 120.140 📝&e.--4-- <Nop>
    an 120.150 📝&e.Paste\ Before<Tab>"+P                      "+P
    an 120.160 📝&e.Paste\ Before,\ Cursor\ After<Tab>"+gP     "+gP
    an 120.170 📝&e.Paste,\ Cursor\ After<Tab>"+gp             "+gp
    an 120.180 📝&e.Indent\ Paste<Tab>"+]p                     "+]p
    an 120.190 📝&e.Indent\ Paste\ Before<Tab>"+[P             "+[P
    an 120.200 📝&e.--5-- <Nop>
    an 120.210 📝&e.Choose\ Yank\ History<Tab>:Clap\ yanks     <Cmd>Clap yanks<CR>
    an 120.220 📝&e.--6-- <Nop>
    am 120.230 📝&e.Swap\ Preious\ Line<Tab>[e                 [e
    am 120.240 📝&e.Swap\ Next\ Line<Tab>]e                    ]e
    an 120.250 📝&e.--7-- <Nop>
    an 120.260 📝&e.Unindent<Tab><                             <Cmd><<CR>
    an 120.270 📝&e.Indent<Tab>>                               <Cmd>><CR>
    an 120.280 📝&e.Auto\ Indent<Tab>=                         =
    an 120.290 📝&e.Auto\ Indent\ File<Tab>gg=G                gg=G
    an 120.290 📝&e.Retab\ File<Tab>:retab!                    <Cmd>retab!<CR>
    an 120.300 📝&e.Auto\ Format\ File                         <Cmd>!clang-format<CR>
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

    " Modify
    an 125.10  ✏️&m.Modify <Nop>
    an disable ✏️&m.Modify
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
    an 125.600 ✏️&m.Read-in\ File\.\.\.<Tab>:r                 :r <C-z>
    an 125.610 ✏️&m.Filter<Tab>:g!/re/d                        <Cmd>call planet#modify#Filter()<CR>
    an 125.620 ✏️&m.Filter\ Out<Tab>:g/re/d                    <Cmd>call planet#modify#FilterOut()<CR>
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
    an 125.660 ✏️&m.Rot13\ Line<Tab>g??<Tab>g?g?              g??
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
    an 130.300 🔎&/.Search\ Dialog<Tab>:promptfind           <Cmd>promptfind<CR>
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
    an 130.340 🔎&/.Substitute\ Dialog<Tab>:promptrepl       <Cmd>promptrepl<CR>

    " Selection
    "FIXME: In Insert mode this only works for a SINGLE Normal mode command
    an 140.10  🖍️&i.Selection <Nop>
    an disable 🖍️&i.Selection
    an 140.10  🖍️&i.Select\ All                             <Cmd>call planet#edit#SelectAll()<CR>
    an 140.10  🖍️&i.Reselect\ Previous\ Area                gv
    an 140.10  🖍️&i.--1-- <Nop>
    an 140.10  🖍️&i.Write\ Selection\ to\ File              <Cmd>call planet#selection#CopySelectionToFile()<CR>
    an 140.10  🖍️&i.Append\ Selection\ to\ File             <Cmd>call planet#selection#CopySelectionToFile(v:false, "a")<CR>
    an 140.10  🖍️&i.Move\ Selection\ and\ Overwrite\ File   <Cmd>call planet#selection#CopySelectionToFile(v:true)<CR>
    an 140.10  🖍️&i.Move\ Selection\ and\ Append\ to\ File  <Cmd>call planet#selection#CopySelectionToFile(v:true, "a")<CR>
    an 140.10  🖍️&i.--2-- <Nop>
    an 140.10  🖍️&i.Visual\ Mode<Tab>v                      v
    an 130.10  🖍️&i.Visual\ Line\ Mode<Tab>V                V
    an 140.10  🖍️&i.Visual\ Block\ Mode<Tab><C-v>           <C-v>
    an 140.10  🖍️&i.--3-- <Nop>
    an 140.10  🖍️&i.Select\ Mode<Tab>gh                     gh
    an 140.10  🖍️&i.Select\ Line\ Mode<Tab>gH               gH
    an 140.10  🖍️&i.Select\ Block\ Mode<Tab>g<C-h>          g<C-H>

    " View
    an 150.10  📺&v.View <Nop>
    an disable 📺&v.View
    an 150.10  📺&v.&Command\ Palette                          <Cmd>Clap<CR>
    an 150.20  📺&v.&Files\ Side\ Bar                          <Cmd>Fern . -drawer -reveal=% -toggle<CR>
    an 150.30  📺&v.&LSP\ Side\ Bar<Tab>:Vista\ vim_lsp        <Cmd>Vista vim_lsp<CR>
    an 150.40  📺&v.&Tags\ Side\ Bar<Tab>:Vista\ ctags         <Cmd>Vista ctags<CR>
    an 150.40  📺&v.QuickFix                                   <Cmd>botright copen<CR>
    an 150.40  📺&v.LocList                                    <Cmd>lopen<CR>
    an 150.50  📺&v.--1-- <Nop>
    an 150.60  📺&v.WinBar <Nop>
    an disable 📺&v.WinBar
    an 150.70  📺&v.Add\ Current                               <Cmd>call PV_WinBar_AddCurrent()<CR>
    an 150.70  📺&v.Remove\ Current                            <Cmd>call PV_WinBar_RemoveCurrent()<CR>
    an 150.70  📺&v.Remove\ Others                             <Cmd>call PV_WinBar_RemoveOthers()<CR>
    an 150.70  📺&v.--1-- <Nop>
    an 150.70  📺&v.Clear                                      <Cmd>unmenu WinBar<CR>
    an 150.70  📺&v.--1-- <Nop>
    an 150.70  📺&v.Colorscheme <Nop>
    an disable 📺&v.Colorscheme
    an 150.70.10  📺&v.Set\ Colorscheme.Dark <Nop>
    an disable    📺&v.Set\ Colorscheme.Dark
    an 150.70.10  📺&v.Set\ Colorscheme.Dracula             <Cmd>set bg=dark<CR><Cmd>colorscheme dracula<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.Gruvbox\ Dark       <Cmd>set bg=dark<CR><Cmd>colorscheme gruvbox<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.Molokai             <Cmd>set bg=dark<CR><Cmd>colorscheme molokai<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.One\ Dark           <Cmd>set bg=dark<CR><Cmd>colorscheme one<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.PaperColor\ Dark    <Cmd>set bg=dark<CR><Cmd>colorscheme PaperColor<CR>
    an 150.70.10  📺&v.Set\ Colorscheme.Solarized\ Dark     <Cmd>set bg=dark<CR><Cmd>colorscheme solarized<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.Light <Nop>
    an disable    📺&v.Set\ Colorscheme.Light
    an 150.70.500 📺&v.Set\ Colorscheme.Gruvbox\ Light      <Cmd>set bg=light<CR><Cmd>colorscheme gruvbox<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.One\ Light          <Cmd>set bg=light<CR><Cmd>colorscheme one<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.PaperColor\ Light   <Cmd>set bg=light<CR><Cmd>colorscheme PaperColor<CR>
    an 150.70.500 📺&v.Set\ Colorscheme.Solarized\ Light    <Cmd>set bg=light<CR><Cmd>colorscheme solarized<CR>
    an 150.70  📺&v.Set\ Dark\ Background<Tab>set\ bg=dark  <Cmd>set bg=dark<CR>
    an 150.70  📺&v.Set\ Light\ Background<Tab>set\ bg=light <Cmd>set bg=light<CR>
    an 150.70  📺&v.Choose\ Colorscheme<Tab>:Clap\ colors   <Cmd>Clap colors<CR>
    an 150.70  📺&v.GUI\ Highlight.Menu                     :h hl-Menu
    an 150.70  📺&v.GUI\ Highlight.Scrollbar                :h hl-Scrollbar
    an 150.70  📺&v.GUI\ Highlight.Tooltip                  :h hl-Tooltip

    " Go
    an 160.10  ↕️&,.Go <Nop>
    an disable ↕️&,.Go
    an 160.10  ↕️&,.C&hoose\ Jump<Tab>:Clap\ jumps               :Clap jumps<CR>
    an 160.10  ↕️&,.--1-- <Nop>
    an 160.10  ↕️&,.Back<Tab><C-o>                               <C-o>
    an 160.10  ↕️&,.Forward<Tab><C-i>                            <C-i>
    an 160.10  ↕️&,.--2-- <Nop>
    an 160.10  ↕️&,.Previous\ section<Tab>[[                     [[
    an 160.10  ↕️&,.Next\ section<Tab>][                         ][
    an 160.10  ↕️&,.Previous\ SECTION<Tab>[]                     []
    an 160.10  ↕️&,.Next\ SECTION<Tab>]]                         ]]
    an 160.10  ↕️&,.--2-- <Nop>
    an 160.10  ↕️&,.Previous\ Change\ Position<Tab>g;            g;
    an 160.10  ↕️&,.Next\ Change\ Position<Tab>g,                g,
    an 160.10  ↕️&,.--3-- <Nop>
    an 160.10  ↕️&,.Start\ of\ File<Tab>gg                       gg
    an 160.10  ↕️&,.Percentage\ in\ File<Tab>{count}%            :TODO:N%
    an 160.10  ↕️&,.End\ of\ File<Tab>G                          G
    an 160.10  ↕️&,.--4-- <Nop>
    an 160.10  ↕️&,.Middle\ of\ Text\ Line<Tab>gm                gM
    an 160.10  ↕️&,.Middle\ of\ Screen\ Line<Tab>gM              gm
    an 160.10  ↕️&,.--4-- <Nop>
    an 160.10  ↕️&,.Sentence\ Backward<Tab>(                     (
    an 160.10  ↕️&,.Sentence\ Forward<Tab>)                      )
    an 160.10  ↕️&,.ftFT\ Backward<Tab>,                         ,
    an 160.10  ↕️&,.ftFT\ Forward<Tab>;                          ;
    an 160.10  ↕️&,.Start\ of\ Selected\ Area<Tab>'<             `<
    an 160.10  ↕️&,.End\ of\ Selected\ Area<Tab>'>               `>
    an 160.10  ↕️&,.Start\ of\ Changed\ Text<Tab>'[              `[
    an 160.10  ↕️&,.End\ of\ Changed\ Text<Tab>']                `]
    an 160.10  ↕️&,.Previous\ Empty\ Line<Tab>{                  {
    an 160.10  ↕️&,.Next\ Empty\ Line<Tab>}                      }
    an 160.10  ↕️&,.Previous\ Enclosing\ {<Tab>[{                [{
    an 160.10  ↕️&,.Next\ Enclosing\ }<Tab>]}                    ]}
    an 160.10  ↕️&,.Next\ MatchIt<Tab>%                          %
    an 160.10  ↕️&,.--4-- <Nop>
    an 160.10  ↕️&,.Previous\ Enclosing\ (<Tab>[(                [(
    an 160.10  ↕️&,.Next\ Enclosing\ (<Tab>])                    ])
    an 160.10  ↕️&,.--4-- <Nop>
    an 160.10  ↕️&,.Scroll\ Left<Tab>zH                          zH
    an 160.10  ↕️&,.Scroll\ Right<Tab>zL                         zL
    an 160.10  ↕️&,.Scroll\ Left<Tab>zh                          zh
    an 160.10  ↕️&,.Scroll\ Right<Tab>zl                         zl
    an 160.10  ↕️&,.Scroll\ Right\ to\ Cursor<Tab>zs             zs
    an 160.10  ↕️&,.Scroll\ Left\ to\ Cursor<Tab>ze              ze

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
    silent! aunmenu 🖍️&i
    silent! aunmenu 📺&v
    silent! aunmenu ↕️&,
    silent! aunmenu 🧭&n
  endif
endfunc
