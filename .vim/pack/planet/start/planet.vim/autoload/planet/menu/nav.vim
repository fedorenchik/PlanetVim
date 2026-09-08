scriptversion 4

func! planet#menu#nav#Update() abort
  if g:PlanetVim_menus_nav
    " Buffers
    an 800.10  📖&u.Buffers <Nop>
    an disable 📖&u.Buffers
    an 800.10  📖&u.C&hoose\.\.\.                           :Clap buffers<CR>
    an 800.10  📖&u.Manager\.\.\.                           :Bufexplorer<CR>
    an 800.10  📖&u.Open<Tab>:b                             :b 
    an 800.10  📖&u.Open\ VSplit<Tab>:vert sb               :vert sb 
    an 800.10  📖&u.Open\ Tab<Tab>:tab sb                   :tab sb 
    an 800.10  📖&u.Open\ All\ Loaded\ VSplit<Tab>:vert unh :vert unh<CR>
    an 800.10  📖&u.Open\ All\ Loaded\ Tab<Tab>:tab unh     :tab unh<CR>
    an 800.10  📖&u.Open\ All\ VSplit<Tab>:vert ba          :vert ba<CR>
    an 800.10  📖&u.Open\ All\ Tab<Tab>:tab ba              :tab ba<CR>
    an 800.20  📖&u.--1-- <Nop>
    an 800.30  📖&u.&Alternate<Tab>:b\ #<Tab><C-@>          <C-^>
    an 800.30  📖&u.&Alternate\ Split<Tab>+^                <C-w>^
    an 800.40  📖&u.--2-- <Nop>
    an 800.30  📖&u.Next\ Modified<Tab>:bm                  :bm<CR>
    an 800.30  📖&u.Next\ Modified\ VSplit<Tab>:vert sbm    :vert sbm<CR>
    an 800.30  📖&u.Next\ Modified\ Tab<Tab>:tab sbm        :tab sbm<CR>
    an 800.40  📖&u.--3-- <Nop>
    an 800.40  📖&u.&First<Tab>[B                           :bf<CR>
    an 800.40  📖&u.&Previous<Tab>[b                        :bp<CR>
    an 800.40  📖&u.&Next<Tab>]b                            :bn<CR>
    an 800.40  📖&u.&Last<Tab>]B                            :bl<CR>
    an 800.40  📖&u.&First\ VSplit<Tab>:vert sbf            :vert sbf<CR>
    an 800.40  📖&u.&Previous\ VSplit<Tab>:vert sbp         :vert sbp<CR>
    an 800.40  📖&u.&Next\ VSplit<Tab>:vert sbn             :vert sbn<CR>
    an 800.40  📖&u.&Last\ VSplit<Tab>:vert sbl             :vert sbl<CR>
    an 800.40  📖&u.&First\ Tab<Tab>:tab sbf                :tab sbf<CR>
    an 800.40  📖&u.&Previous\ Tab<Tab>:tab sbp             :tab sbp<CR>
    an 800.40  📖&u.&Next\ Tab<Tab>:tab sbn                 :tab sbn<CR>
    an 800.40  📖&u.&Last\ Tab<Tab>:tab sbl                 :tab sbl<CR>
    an 800.40  📖&u.--4-- <Nop>
    an 800.40  📖&u.Add<Tab>:badd                           :badd 
    an 800.40  📖&u.Add\ as\ Alternate<Tab>:balt            :balt 
    an 800.40  📖&u.Unload\ (Free\ Memory)                  :bun<CR>
    an 800.40  📖&u.Delete\ (Unload\ &&\ Unlist)            :bd<CR>
    an 800.40  📖&u.Wipeout\ (Delete\ &&\ Clear\ Everything) :bw<CR>
    an 800.40  📖&u.--5-- <Nop>
    an 800.40  📖&u.Delete\ Hidden                          :call planet#buffer#DeleteHidden()<CR>
    an 800.40  📖&u.Delete\ All                             :call planet#buffer#DeleteAll()<CR>
    an 800.40  📖&u.Execute\ in\ Each\ Buffer<Tab>:bufdo    :bufdo 
    an 800.40  📖&u.--6-- <Nop>

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
    an 810.10  🗃️&a.Run\ Each                                  :argdo<Space>
    an 810.10  🗃️&a.--3-- <Nop>
    an 810.10  🗃️&a.Args\ List <Nop>
    an disable 🗃️&a.Args\ List

    " Vim Windows
    an 820.10  🪟&w.Windows <Nop>
    an disable 🪟&w.Windows
    an 820.10  🪟&w.&Window\ Mode                           <Cmd>WindowMode<CR>
    an 820.10  🪟&w.ChooseWin\ Mode\ (&\\)<Tab>\\           <Cmd>ChooseWin<CR>
    an 820.10  🪟&w.--1-- <Nop>
    an 820.10  🪟&w.C&hoose<Tab>:Clap\ windows              <Cmd>Clap windows<CR>
    an 820.10  🪟&w.--2-- <Nop>
    an 820.10  🪟&w.&Vertical\ Split<Tab>:vsplit<Tab>+v     <C-w>v
    an 820.10  🪟&w.Horizontal\ &Split<Tab>:split<Tab>+s    <C-w>s
    an 820.10  🪟&w.VSplit\ &Bind                           <Cmd>call planet#window#SplitBind('v')<CR>
    an 820.10  🪟&w.&HSplit\ Bind                           <Cmd>call planet#window#SplitBind('h')<CR>
    an 820.10  🪟&w.--3-- <Nop>
    an 820.10  🪟&w.&Move.&Swap<Tab>+x                      <C-w>x
    an 820.10  🪟&w.&Move.Rotate\ &Up<Tab>R                 <C-w>R
    an 820.10  🪟&w.&Move.Rotate\ &Down<Tab>r               <C-w>r
    an 820.10  🪟&w.&Move.To\ &Left<Tab>+H                  <C-w>H
    an 820.10  🪟&w.&Move.To\ &Right<Tab>+L                 <C-w>L
    an 820.10  🪟&w.&Move.To\ T&op<Tab>+K                   <C-w>K
    an 820.10  🪟&w.&Move.To\ &Bottom<Tab>+J                <C-w>J
    an 820.10  🪟&w.&Move.To\ New\ &Tab<Tab>+T              <C-w>T
    an 820.10  🪟&w.&Move.To\ New\ &GUI\ Window             <Cmd>call planet#gui#Transfer(v:true)<CR>
    an 820.10  🪟&w.&Move.&Copy\ To\ New\ Tab<Tab>+s+T      <C-w>s<C-w>T
    an 820.10  🪟&w.&Move.Copy\ To\ New\ &GUI\ Window       <Cmd>call planet#gui#Transfer(v:false)<CR>
    an 820.10  🪟&w.--4-- <Nop>
    an 820.10  🪟&w.&Equal\ Size<Tab>+=                     <C-w>=
    an 820.10  🪟&w.Ma&ximize<Tab>+_+\|                     <Cmd>call planet#window#Maximize()<CR>
    an 820.10  🪟&w.&Unmaximize<Tab>                        <Cmd>call planet#window#Restore()<CR>
    an 820.10  🪟&w.&Resize.Maximize\ &Vertically<Tab>+_    <C-w>_
    an 820.10  🪟&w.&Resize.Maximize\ &Horizontally<Tab>+\| <C-w>\|
    an 820.10  🪟&w.&Resize.Increase\ Height<Tab>++         <C-w>+
    an 820.10  🪟&w.&Resize.Decrease\ Height<Tab>+-         <C-w>-
    an 820.10  🪟&w.&Resize.Increase\ Width<Tab>+>          <C-w>>
    an 820.10  🪟&w.&Resize.Decrease\ Width<Tab>+<          <C-w><
    an 820.10  🪟&w.--6-- <Nop>
    an 820.10  🪟&w.&Focus.Alternate<Tab>+p                 <C-w>p
    an 820.10  🪟&w.&Focus.Preview\ Window<Tab>+P           <C-w>P
    an 820.10  🪟&w.&Focus.Previous\ Window<Tab>+W          <C-w>W
    an 820.10  🪟&w.&Focus.Next\ Window<Tab>+w              <C-w>w
    an 820.10  🪟&w.&Focus.Top\ Window<Tab>+t               <C-w>t
    an 820.10  🪟&w.&Focus.Bottom\ Window<Tab>+b            <C-w>b
    an 820.10  🪟&w.&Focus.Left<Tab>+h                      <Cmd>call planet#window#Focus('h')<CR>
    an 820.10  🪟&w.&Focus.Right<Tab>+l                     <Cmd>call planet#window#Focus('l')<CR>
    an 820.10  🪟&w.&Focus.Up<Tab>+k                        <C-w>k
    an 820.10  🪟&w.&Focus.Down<Tab>+j                      <C-w>j
    an 820.10  🪟&w.--7-- <Nop>
    an 820.10  🪟&w.Set\ Fixed\ Size                        <Cmd>set winfixheight winfixwidth<CR>
    an 820.10  🪟&w.--8-- <Nop>
    an 820.10  🪟&w.V&iew.Save                              <Cmd>call planet#windowview#Save()<CR>
    an 820.10  🪟&w.V&iew.Save\ 1                           <Cmd>call planet#windowview#Save(1)<CR>
    an 820.10  🪟&w.V&iew.Save\ 2                           <Cmd>call planet#windowview#Save(2)<CR>
    an 820.10  🪟&w.V&iew.Save\ 3                           <Cmd>call planet#windowview#Save(3)<CR>
    an 820.10  🪟&w.V&iew.Save\ 4                           <Cmd>call planet#windowview#Save(4)<CR>
    an 820.10  🪟&w.V&iew.Save\ 5                           <Cmd>call planet#windowview#Save(5)<CR>
    an 820.10  🪟&w.V&iew.Save\ 6                           <Cmd>call planet#windowview#Save(6)<CR>
    an 820.10  🪟&w.V&iew.Save\ 7                           <Cmd>call planet#windowview#Save(7)<CR>
    an 820.10  🪟&w.V&iew.Save\ 8                           <Cmd>call planet#windowview#Save(8)<CR>
    an 820.10  🪟&w.V&iew.Save\ 9\ (AutoSave)               <Cmd>call planet#windowview#Save(9)<CR>
    an 820.10  🪟&w.V&iew.--1-- <Nop>
    an 820.10  🪟&w.V&iew.Load                              <Cmd>call planet#windowview#Load()<CR>
    an 820.10  🪟&w.V&iew.Load\ 1                           <Cmd>call planet#windowview#Load(1)<CR>
    an 820.10  🪟&w.V&iew.Load\ 2                           <Cmd>call planet#windowview#Load(2)<CR>
    an 820.10  🪟&w.V&iew.Load\ 3                           <Cmd>call planet#windowview#Load(3)<CR>
    an 820.10  🪟&w.V&iew.Load\ 4                           <Cmd>call planet#windowview#Load(4)<CR>
    an 820.10  🪟&w.V&iew.Load\ 5                           <Cmd>call planet#windowview#Load(5)<CR>
    an 820.10  🪟&w.V&iew.Load\ 6                           <Cmd>call planet#windowview#Load(6)<CR>
    an 820.10  🪟&w.V&iew.Load\ 7                           <Cmd>call planet#windowview#Load(7)<CR>
    an 820.10  🪟&w.V&iew.Load\ 8                           <Cmd>call planet#windowview#Load(8)<CR>
    an 820.10  🪟&w.V&iew.Load\ 9\ (AutoSave)               <Cmd>call planet#windowview#Load(9)<CR>
    an 820.10  🪟&w.V&iew.--2-- <Nop>
    an 820.10  🪟&w.V&iew.Toggle\ AutoSave\ Views           <Cmd>call planet#windowview#ToggleAutoSave()<CR>
    an 820.10  🪟&w.V&iew.--3-- <Nop>
    an 820.10  🪟&w.V&iew.Toggle\ Save\ Local\ Options      <Cmd>call planet#windowview#ToggleLocalOptions()<CR>
    an 820.10  🪟&w.&Layout.Save                            <Cmd>let g:PV_layout = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 1                         <Cmd>let g:PV_layout_1 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 2                         <Cmd>let g:PV_layout_2 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 3                         <Cmd>let g:PV_layout_3 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 4                         <Cmd>let g:PV_layout_4 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 5                         <Cmd>let g:PV_layout_5 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 6                         <Cmd>let g:PV_layout_6 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 7                         <Cmd>let g:PV_layout_7 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 8                         <Cmd>let g:PV_layout_8 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.Save\ 9                         <Cmd>let g:PV_layout_9 = winrestcmd()<CR>
    an 820.10  🪟&w.&Layout.--1-- <Nop>
    an 820.10  🪟&w.&Layout.Load                            <Cmd>exe g:PV_layout<CR>
    an 820.10  🪟&w.&Layout.Load\ 1                         <Cmd>exe g:PV_layout_1<CR>
    an 820.10  🪟&w.&Layout.Load\ 2                         <Cmd>exe g:PV_layout_2<CR>
    an 820.10  🪟&w.&Layout.Load\ 3                         <Cmd>exe g:PV_layout_3<CR>
    an 820.10  🪟&w.&Layout.Load\ 4                         <Cmd>exe g:PV_layout_4<CR>
    an 820.10  🪟&w.&Layout.Load\ 5                         <Cmd>exe g:PV_layout_5<CR>
    an 820.10  🪟&w.&Layout.Load\ 6                         <Cmd>exe g:PV_layout_6<CR>
    an 820.10  🪟&w.&Layout.Load\ 7                         <Cmd>exe g:PV_layout_7<CR>
    an 820.10  🪟&w.&Layout.Load\ 8                         <Cmd>exe g:PV_layout_8<CR>
    an 820.10  🪟&w.&Layout.Load\ 9                         <Cmd>exe g:PV_layout_9<CR>
    an 820.10  🪟&w.&Layout.--1-- <Nop>
    an 820.10  🪟&w.--7-- <Nop>
    an 820.10  🪟&w.Execute\ in\ Window\ in\ This\ Tab      :windo 
    an 820.10  🪟&w.Execute\ in\ each\ Window               :tabdo windo 
    an 820.10  🪟&w.--5-- <Nop>
    an 820.10  🪟&w.--9-- <Nop>
    an 820.10  🪟&w.&Close<Tab>:close<Tab>+c                <C-w>c
    an 820.10  🪟&w.Close\ &Other\ Windows<Tab>:only<Tab>+o <C-w>o

    " Tabs
    an 830.10  🗂️&t.Tabs <Tabs>
    an disable 🗂️&t.Tabs
    an 830.10  🗂️&t.Tab\ Manager<Tab>:TMToggle             <Cmd>TMToggle<CR>
    an 830.10  🗂️&t.N&ew<Tab>:tabnew                       <Cmd>tabnew<CR>
    an 830.10  🗂️&t.--1-- <Nop>
    an 830.10  🗂️&t.&Alternate<Tab>g\<Tab\>                g<Tab>
    an 830.10  🗂️&t.C&hoose<Tab>:Clap\ windows             <Cmd>Clap windows<CR>
    an 830.10  🗂️&t.--2-- <Nop>
    an 830.10  🗂️&t.&First<Tab>:tabfirst                   <Cmd>tabfirst<CR>
    an 830.10  🗂️&t.&Previous<Tab><C-PgUp><Tab>gT          gT
    an 830.10  🗂️&t.&Next<Tab><C-PgDown><Tab>gt            gt
    an 830.10  🗂️&t.&Last<Tab>:tablast                     <Cmd>tablast<CR>
    an 830.10  🗂️&t.--3-- <Nop>
    an 830.10  🗂️&t.Move\ F&irst<Tab>:0tabmove             <Cmd>0tabmove<CR>
    an 830.10  🗂️&t.Move\ P&revious<Tab>:-tabmove          <Cmd>-tabmove<CR>
    an 830.10  🗂️&t.&Move\ Next<Tab>:+tabmove              <Cmd>+tabmove<CR>
    an 830.10  🗂️&t.Mo&ve\ Last<Tab>:tabmove               <Cmd>tabmove<CR>
    an 830.10  🗂️&t.--4-- <Nop>
    an 830.10  🗂️&t.&Save\ Current\ Tab                    <Cmd>call planet#tab#Save()<CR>
    an 830.10  🗂️&t.Open\ &Tab\.\.\.                       <Cmd>call planet#tab#Open()<CR>
    an 830.10  🗂️&t.--5-- <Nop>
    an 830.10  🗂️&t.E&xecute\ in\ each\ Tab<Tab>:tabdo     :tabdo 
    an 830.10  🗂️&t.--6-- <Nop>
    an 830.10  🗂️&t.&Close<Tab>:tabclose                   <Cmd>call planet#tab#Close()<CR>
    an 830.10  🗂️&t.Reopen\ Closed\ Tab                    <Cmd>call planet#tab#Reopen()<CR>
    an 830.10  🗂️&t.Close\ &Other\ Tabs<Tab>:tabonly       <Cmd>call planet#tab#CloseOthers()<CR>

    " Sessions
    an 840.10  📚&s.Sessions <Nop>
    an disable 📚&s.Sessions
    an 840.20  📚&s.--1-- <Nop>
    an 840.30  📚&s.&Save                                   <Cmd>call planet#session#Save()<CR>
    an 840.40  📚&s.Save\ &As\.\.\.                         <Cmd>SSave<CR>
    an 840.60  📚&s.Ad&vanced\ Save.Save\ with\ Relative\ Paths <Cmd>call planet#session#SaveVariant('relative')<CR>
    an 840.70  📚&s.Ad&vanced\ Save.Save\ with\ Local\ Options <Cmd>call planet#session#SaveVariant('local')<CR>
    an 840.80  📚&s.Ad&vanced\ Save.Save\ with\ All\ Options <Cmd>call planet#session#SaveVariant('all')<CR>
    an 840.90  📚&s.Ad&vanced\ Save.Save\ without\ Global\ Vars <Cmd>call planet#session#SaveVariant('no-globals')<CR>
    an 840.100 📚&s.--2-- <Nop>
    an 840.100 📚&s.Add\ &Menu\ Entry                       <Cmd>call planet#session#ManageDesktopFile(0, 0)<CR>
    an 840.100 📚&s.Add\ Des&ktop\ Entry                    <Cmd>call planet#session#ManageDesktopFile(0, 1)<CR>
    an 840.100 📚&s.--3-- <Nop>
    an 840.110 📚&s.&Open                                   <Cmd>call planet#session#Load('')<CR>
    an 840.120 📚&s.Open\ &Last\ Session                    <Cmd>call planet#session#LoadLast()<CR>
    an 840.130 📚&s.&Reopen                                 <Cmd>call planet#session#OpenPath(v:this_session)<CR>
    an 840.140 📚&s.--4-- <Nop>
    an 840.150 📚&s.&Close                                  <Cmd>SClose<CR>
    an 840.160 📚&s.--5-- <Nop>
    an 840.160 📚&s.Remove\ Menu\ Entry                       <Cmd>call planet#session#ManageDesktopFile(1, 0)<CR>
    an 840.160 📚&s.Remove\ Desktop\ Entry                    <Cmd>call planet#session#ManageDesktopFile(1, 1)<CR>
    an 840.160 📚&s.--6-- <Nop>
    an 840.170 📚&s.&Delete                                 <Cmd>SDelete<CR>

    " Vim Apps: Open in new GUI window
    an 850.10  🗄️&x.GUI <Nop>
    an disable 🗄️&x.GUI
    an 850.10  🗄️&x.&Maximize                               <Cmd>call planet#gui#Window('maximize')<CR>
    an 850.10  🗄️&x.&Full\ Screen                           <Cmd>call planet#gui#Window('fullscreen')<CR>
    an 850.10  🗄️&x.Minimi&ze<Tab>:suspend<Tab><C-z>        <C-z>
    an 850.10  🗄️&x.--1-- <Nop>
    an 850.10  🗄️&x.&Start\ Vim\ Server                     <Cmd>call planet#gui#VimServerStart()<CR>
    an 850.100 🗄️&x.--2-- <Nop>

    " Control GUI window with wmctrl & vim servers
    an 860.10  🎛️&@.Apps <Nop>
    an disable 🎛️&@.Apps
    an 860.10  🎛️&@.Calendar            <Cmd>call planet#apps#Open('Calendar')<CR>
    an 860.10  🎛️&@.&Web\ Browser       <Cmd>call planet#apps#Open('W3m https://google.com/', 'w3m')<CR>
    an 860.10  🎛️&@.Calculator          <Cmd>call planet#apps#Open('Calculator')<CR>
    an 860.10  🎛️&@.&Htop               <Cmd>call planet#term#RunArgv(['htop'])<CR>
    an 860.10  🎛️&@.&Terminal           <Cmd>call planet#apps#Open('terminal ++curwin ++kill=kill')<CR>
    an 860.10  🎛️&@.&File\ Manager      <Cmd>call planet#apps#Open('Fern .')<CR>
    an 860.10  🎛️&@.&Python\ Notebook   <Cmd>call planet#apps#Open('Codi python')<CR>
    an 860.10  🎛️&@.C&++\ Notebook      <Cmd>call planet#apps#Open('Codi cpp')<CR>
    an 860.300 🎛️&@.--1-- <Nop>
    an 850.500 🗄️&x.--2-- <Nop>
    an 860.600 🎛️&@.Workspaces <Nop>
    an disable 🎛️&@.Workspaces

  else
    silent! aunmenu 📖&u
    silent! aunmenu 🗃️&a
    silent! aunmenu 🪟&w
    silent! aunmenu 🗂️&t
    silent! aunmenu 📚&s
    silent! aunmenu 🗄️&x
    silent! aunmenu 🎛️&@
  endif
endfunc
