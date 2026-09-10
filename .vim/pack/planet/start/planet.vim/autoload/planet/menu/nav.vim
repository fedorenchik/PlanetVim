scriptversion 4

func! planet#menu#nav#Update() abort
  if planet#menu#Visible('nav')
    " Buffers
    PlanetMenu an 800.10  📖&u.Buffers <Nop>
    an disable 📖&u.Buffers
    PlanetMenu an 800.10  📖&u.C&hoose\.\.\.                           :Clap buffers<CR>
    PlanetMenu an 800.10  📖&u.Manager\.\.\.                           :Bufexplorer<CR>
    PlanetMenu an 800.10  📖&u.Open<Tab>:b                             :b<Space>
    PlanetMenu an 800.10  📖&u.Open\ VSplit<Tab>:vert\ sb               :vert sb<Space>
    PlanetMenu an 800.10  📖&u.Open\ Tab<Tab>:tab\ sb                   :tab sb<Space>
    PlanetMenu an 800.10  📖&u.Open\ All\ Loaded\ VSplit<Tab>:vert\ unh :vert unh<CR>
    PlanetMenu an 800.10  📖&u.Open\ All\ Loaded\ Tab<Tab>:tab\ unh     :tab unh<CR>
    PlanetMenu an 800.10  📖&u.Open\ All\ VSplit<Tab>:vert\ ba          :vert ba<CR>
    PlanetMenu an 800.10  📖&u.Open\ All\ Tab<Tab>:tab\ ba              :tab ba<CR>
    PlanetMenu an 800.20  📖&u.--1-- <Nop>
    PlanetMenu an 800.30  📖&u.&Alternate<Tab>:b\ #<Tab><C-@>          <C-^>
    PlanetMenu an 800.30  📖&u.&Alternate\ Split<Tab>+^                <C-w>^
    PlanetMenu an 800.40  📖&u.--2-- <Nop>
    PlanetMenu an 800.30  📖&u.Next\ Modified<Tab>:bm                  :bm<CR>
    PlanetMenu an 800.30  📖&u.Next\ Modified\ VSplit<Tab>:vert\ sbm    :vert sbm<CR>
    PlanetMenu an 800.30  📖&u.Next\ Modified\ Tab<Tab>:tab\ sbm        :tab sbm<CR>
    PlanetMenu an 800.40  📖&u.--3-- <Nop>
    PlanetMenu an 800.40  📖&u.&First<Tab>[B                           :bf<CR>
    PlanetMenu an 800.40  📖&u.&Previous<Tab>[b                        :bp<CR>
    PlanetMenu an 800.40  📖&u.&Next<Tab>]b                            :bn<CR>
    PlanetMenu an 800.40  📖&u.&Last<Tab>]B                            :bl<CR>
    PlanetMenu an 800.40  📖&u.&First\ VSplit<Tab>:vert\ sbf            :vert sbf<CR>
    PlanetMenu an 800.40  📖&u.&Previous\ VSplit<Tab>:vert\ sbp         :vert sbp<CR>
    PlanetMenu an 800.40  📖&u.&Next\ VSplit<Tab>:vert\ sbn             :vert sbn<CR>
    PlanetMenu an 800.40  📖&u.&Last\ VSplit<Tab>:vert\ sbl             :vert sbl<CR>
    PlanetMenu an 800.40  📖&u.&First\ Tab<Tab>:tab\ sbf                :tab sbf<CR>
    PlanetMenu an 800.40  📖&u.&Previous\ Tab<Tab>:tab\ sbp             :tab sbp<CR>
    PlanetMenu an 800.40  📖&u.&Next\ Tab<Tab>:tab\ sbn                 :tab sbn<CR>
    PlanetMenu an 800.40  📖&u.&Last\ Tab<Tab>:tab\ sbl                 :tab sbl<CR>
    PlanetMenu an 800.40  📖&u.--4-- <Nop>
    PlanetMenu an 800.40  📖&u.Add<Tab>:badd                           :badd<Space>
    PlanetMenu an 800.40  📖&u.Add\ as\ Alternate<Tab>:balt            :balt<Space>
    PlanetMenu an 800.40  📖&u.Unload\ (Free\ Memory)                  :bun<CR>
    PlanetMenu an 800.40  📖&u.Delete\ (Unload\ &&\ Unlist)            :bd<CR>
    PlanetMenu an 800.40  📖&u.Wipeout\ (Delete\ &&\ Clear\ Everything) :bw<CR>
    PlanetMenu an 800.40  📖&u.--5-- <Nop>
    PlanetMenu an 800.40  📖&u.Delete\ Hidden                          :call planet#buffer#DeleteHidden()<CR>
    PlanetMenu an 800.40  📖&u.Delete\ All                             :call planet#buffer#DeleteAll()<CR>
    PlanetMenu an 800.40  📖&u.Execute\ in\ Each\ Buffer<Tab>:bufdo    :bufdo<Space>
    PlanetMenu an 800.40  📖&u.--6-- <Nop>

    " Arg List
    PlanetMenu an 810.10  🗃️&a.Args <Nop>
    an disable 🗃️&a.Args
    PlanetMenu an 810.10  🗃️&a.Drop<Tab>:drop                             :drop %<CR>
    PlanetMenu an 810.10  🗃️&a.&Add                                       :argadd<CR>
    PlanetMenu an 810.10  🗃️&a.&Delete                                    :argdelete<CR>
    PlanetMenu an 810.10  🗃️&a.&First<Tab>[A                              :first<CR>
    PlanetMenu an 810.10  🗃️&a.&Previous<Tab>[a                           :previous<CR>
    PlanetMenu an 810.10  🗃️&a.&Next<Tab>]a                               :next<CR>
    PlanetMenu an 810.10  🗃️&a.&Last<Tab>]A                               :last<CR>
    PlanetMenu an 810.10  🗃️&a.&First\ VSplit                      :vert sfirst<CR>
    PlanetMenu an 810.10  🗃️&a.&Previous\ VSplit                   :vert sprevious<CR>
    PlanetMenu an 810.10  🗃️&a.&Next\ VSplit                       :vert snext<CR>
    PlanetMenu an 810.10  🗃️&a.&Last\ VSplit                       :vert slast<CR>
    PlanetMenu an 810.10  🗃️&a.&First\ Tab                         :tab first<CR>
    PlanetMenu an 810.10  🗃️&a.&Previous\ Tab                      :tab previous<CR>
    PlanetMenu an 810.10  🗃️&a.&Next\ Tab                          :tab next<CR>
    PlanetMenu an 810.10  🗃️&a.&Last\ Tab                          :tab last<CR>
    PlanetMenu an 810.10  🗃️&a.All\ VSplit<Tab>:vert\ all                 :tabnew<CR>:vert all<CR>
    PlanetMenu an 810.10  🗃️&a.All\ Tab<Tab>:tab\ all                     :tab all<CR>
    PlanetMenu an 810.10  🗃️&a.--1-- <Nop>
    PlanetMenu an 810.10  🗃️&a.Execute\ in\ Each\ Argument<Tab>:argdo     :argdo<Space>
    PlanetMenu an 810.10  🗃️&a.--1-- <Nop>
    PlanetMenu an 810.10  🗃️&a.Set\ Local                                 :argl<CR>
    PlanetMenu an 810.10  🗃️&a.Set\ Global                                :argg<CR>
    PlanetMenu an 810.10  🗃️&a.--2-- <Nop>
    PlanetMenu an 810.10  🗃️&a.Run\ Each                                  :argdo<Space>
    PlanetMenu an 810.10  🗃️&a.--3-- <Nop>
    PlanetMenu an 810.10  🗃️&a.Args\ List <Nop>
    an disable 🗃️&a.Args\ List

    " Vim Windows
    PlanetMenu an 820.10  🪟&w.Windows <Nop>
    an disable 🪟&w.Windows
    PlanetMenu an 820.10  🪟&w.&Window\ Mode                           <Cmd>WindowMode<CR>
    PlanetMenu an 820.10  🪟&w.ChooseWin\ Mode\ (&\\)<Tab>\\           <Cmd>ChooseWin<CR>
    PlanetMenu an 820.10  🪟&w.--1-- <Nop>
    PlanetMenu an 820.10  🪟&w.C&hoose<Tab>:Clap\ windows              <Cmd>Clap windows<CR>
    PlanetMenu an 820.10  🪟&w.--2-- <Nop>
    PlanetMenu an 820.10  🪟&w.&Vertical\ Split<Tab>:vsplit<Tab>+v     <C-w>v
    PlanetMenu an 820.10  🪟&w.Horizontal\ &Split<Tab>:split<Tab>+s    <C-w>s
    PlanetMenu an 820.10  🪟&w.VSplit\ &Bind                           <Cmd>call planet#window#SplitBind('v')<CR>
    PlanetMenu an 820.10  🪟&w.&HSplit\ Bind                           <Cmd>call planet#window#SplitBind('h')<CR>
    PlanetMenu an 820.10  🪟&w.--3-- <Nop>
    PlanetMenu an 820.10  🪟&w.&Move.&Swap<Tab>+x                      <C-w>x
    PlanetMenu an 820.10  🪟&w.&Move.Rotate\ &Up<Tab>R                 <C-w>R
    PlanetMenu an 820.10  🪟&w.&Move.Rotate\ &Down<Tab>r               <C-w>r
    PlanetMenu an 820.10  🪟&w.&Move.To\ &Left<Tab>+H                  <C-w>H
    PlanetMenu an 820.10  🪟&w.&Move.To\ &Right<Tab>+L                 <C-w>L
    PlanetMenu an 820.10  🪟&w.&Move.To\ T&op<Tab>+K                   <C-w>K
    PlanetMenu an 820.10  🪟&w.&Move.To\ &Bottom<Tab>+J                <C-w>J
    PlanetMenu an 820.10  🪟&w.&Move.To\ New\ &Tab<Tab>+T              <C-w>T
    PlanetMenu an 820.10  🪟&w.&Move.To\ New\ &GUI\ Window             <Cmd>call planet#gui#Transfer(v:true)<CR>
    PlanetMenu an 820.10  🪟&w.&Move.&Copy\ To\ New\ Tab<Tab>+s+T      <C-w>s<C-w>T
    PlanetMenu an 820.10  🪟&w.&Move.Copy\ To\ New\ &GUI\ Window       <Cmd>call planet#gui#Transfer(v:false)<CR>
    PlanetMenu an 820.10  🪟&w.--4-- <Nop>
    PlanetMenu an 820.10  🪟&w.&Equal\ Size<Tab>+=                     <C-w>=
    PlanetMenu an 820.10  🪟&w.Ma&ximize<Tab>+_+\|                     <Cmd>call planet#window#Maximize()<CR>
    PlanetMenu an 820.10  🪟&w.&Unmaximize<Tab>                        <Cmd>call planet#window#Restore()<CR>
    PlanetMenu an 820.10  🪟&w.&Resize.Maximize\ &Vertically<Tab>+_    <C-w>_
    PlanetMenu an 820.10  🪟&w.&Resize.Maximize\ &Horizontally<Tab>+\| <C-w>\|
    PlanetMenu an 820.10  🪟&w.&Resize.Increase\ Height<Tab>++         <C-w>+
    PlanetMenu an 820.10  🪟&w.&Resize.Decrease\ Height<Tab>+-         <C-w>-
    PlanetMenu an 820.10  🪟&w.&Resize.Increase\ Width<Tab>+>          <C-w>>
    PlanetMenu an 820.10  🪟&w.&Resize.Decrease\ Width<Tab>+<          <C-w><
    PlanetMenu an 820.10  🪟&w.--6-- <Nop>
    PlanetMenu an 820.10  🪟&w.&Focus.Alternate<Tab>+p                 <C-w>p
    PlanetMenu an 820.10  🪟&w.&Focus.Preview\ Window<Tab>+P           <C-w>P
    PlanetMenu an 820.10  🪟&w.&Focus.Previous\ Window<Tab>+W          <C-w>W
    PlanetMenu an 820.10  🪟&w.&Focus.Next\ Window<Tab>+w              <C-w>w
    PlanetMenu an 820.10  🪟&w.&Focus.Top\ Window<Tab>+t               <C-w>t
    PlanetMenu an 820.10  🪟&w.&Focus.Bottom\ Window<Tab>+b            <C-w>b
    PlanetMenu an 820.10  🪟&w.&Focus.Left<Tab>+h                      <Cmd>call planet#window#Focus('h')<CR>
    PlanetMenu an 820.10  🪟&w.&Focus.Right<Tab>+l                     <Cmd>call planet#window#Focus('l')<CR>
    PlanetMenu an 820.10  🪟&w.&Focus.Up<Tab>+k                        <C-w>k
    PlanetMenu an 820.10  🪟&w.&Focus.Down<Tab>+j                      <C-w>j
    PlanetMenu an 820.10  🪟&w.--7-- <Nop>
    PlanetMenu an 820.10  🪟&w.Set\ Fixed\ Size                        <Cmd>set winfixheight winfixwidth<CR>
    PlanetMenu an 820.10  🪟&w.--8-- <Nop>
    PlanetMenu an 820.10  🪟&w.V&iew.Save                              <Cmd>call planet#windowview#Save()<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 1                           <Cmd>call planet#windowview#Save(1)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 2                           <Cmd>call planet#windowview#Save(2)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 3                           <Cmd>call planet#windowview#Save(3)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 4                           <Cmd>call planet#windowview#Save(4)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 5                           <Cmd>call planet#windowview#Save(5)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 6                           <Cmd>call planet#windowview#Save(6)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 7                           <Cmd>call planet#windowview#Save(7)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 8                           <Cmd>call planet#windowview#Save(8)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Save\ 9\ (AutoSave)               <Cmd>call planet#windowview#Save(9)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.--1-- <Nop>
    PlanetMenu an 820.10  🪟&w.V&iew.Load                              <Cmd>call planet#windowview#Load()<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 1                           <Cmd>call planet#windowview#Load(1)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 2                           <Cmd>call planet#windowview#Load(2)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 3                           <Cmd>call planet#windowview#Load(3)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 4                           <Cmd>call planet#windowview#Load(4)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 5                           <Cmd>call planet#windowview#Load(5)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 6                           <Cmd>call planet#windowview#Load(6)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 7                           <Cmd>call planet#windowview#Load(7)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 8                           <Cmd>call planet#windowview#Load(8)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.Load\ 9\ (AutoSave)               <Cmd>call planet#windowview#Load(9)<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.--2-- <Nop>
    PlanetMenu an 820.10  🪟&w.V&iew.Toggle\ AutoSave\ Views           <Cmd>call planet#windowview#ToggleAutoSave()<CR>
    PlanetMenu an 820.10  🪟&w.V&iew.--3-- <Nop>
    PlanetMenu an 820.10  🪟&w.V&iew.Toggle\ Save\ Local\ Options      <Cmd>call planet#windowview#ToggleLocalOptions()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save                            <Cmd>let g:PV_layout = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 1                         <Cmd>let g:PV_layout_1 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 2                         <Cmd>let g:PV_layout_2 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 3                         <Cmd>let g:PV_layout_3 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 4                         <Cmd>let g:PV_layout_4 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 5                         <Cmd>let g:PV_layout_5 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 6                         <Cmd>let g:PV_layout_6 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 7                         <Cmd>let g:PV_layout_7 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 8                         <Cmd>let g:PV_layout_8 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Save\ 9                         <Cmd>let g:PV_layout_9 = winrestcmd()<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.--1-- <Nop>
    PlanetMenu an 820.10  🪟&w.&Layout.Load                            <Cmd>exe g:PV_layout<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 1                         <Cmd>exe g:PV_layout_1<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 2                         <Cmd>exe g:PV_layout_2<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 3                         <Cmd>exe g:PV_layout_3<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 4                         <Cmd>exe g:PV_layout_4<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 5                         <Cmd>exe g:PV_layout_5<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 6                         <Cmd>exe g:PV_layout_6<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 7                         <Cmd>exe g:PV_layout_7<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 8                         <Cmd>exe g:PV_layout_8<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.Load\ 9                         <Cmd>exe g:PV_layout_9<CR>
    PlanetMenu an 820.10  🪟&w.&Layout.--1-- <Nop>
    PlanetMenu an 820.10  🪟&w.--7-- <Nop>
    PlanetMenu an 820.10  🪟&w.Execute\ in\ Window\ in\ This\ Tab      :windo<Space>
    PlanetMenu an 820.10  🪟&w.Execute\ in\ each\ Window               :tabdo windo<Space>
    PlanetMenu an 820.10  🪟&w.--5-- <Nop>
    PlanetMenu an 820.10  🪟&w.--9-- <Nop>
    PlanetMenu an 820.10  🪟&w.&Close<Tab>:close<Tab>+c                <C-w>c
    PlanetMenu an 820.10  🪟&w.Close\ &Other\ Windows<Tab>:only<Tab>+o <C-w>o

    " Tabs
    PlanetMenu an 830.10  🗂️&t.Tabs <Nop>
    an disable 🗂️&t.Tabs
    PlanetMenu an 830.10  🗂️&t.Tab\ Manager<Tab>:TMToggle             <Cmd>TMToggle<CR>
    PlanetMenu an 830.10  🗂️&t.N&ew<Tab>:tabnew                       <Cmd>tabnew<CR>
    PlanetMenu an 830.10  🗂️&t.--1-- <Nop>
    PlanetMenu an 830.10  🗂️&t.&Alternate<Tab>g\<Tab\>                g<Tab>
    PlanetMenu an 830.10  🗂️&t.C&hoose<Tab>:Clap\ windows             <Cmd>Clap windows<CR>
    PlanetMenu an 830.10  🗂️&t.--2-- <Nop>
    PlanetMenu an 830.10  🗂️&t.&First<Tab>:tabfirst                   <Cmd>tabfirst<CR>
    PlanetMenu an 830.10  🗂️&t.&Previous<Tab><C-PgUp><Tab>gT          gT
    PlanetMenu an 830.10  🗂️&t.&Next<Tab><C-PgDown><Tab>gt            gt
    PlanetMenu an 830.10  🗂️&t.&Last<Tab>:tablast                     <Cmd>tablast<CR>
    PlanetMenu an 830.10  🗂️&t.--3-- <Nop>
    PlanetMenu an 830.10  🗂️&t.Move\ F&irst<Tab>:0tabmove             <Cmd>0tabmove<CR>
    PlanetMenu an 830.10  🗂️&t.Move\ P&revious<Tab>:-tabmove          <Cmd>-tabmove<CR>
    PlanetMenu an 830.10  🗂️&t.&Move\ Next<Tab>:+tabmove              <Cmd>+tabmove<CR>
    PlanetMenu an 830.10  🗂️&t.Mo&ve\ Last<Tab>:tabmove               <Cmd>tabmove<CR>
    PlanetMenu an 830.10  🗂️&t.--4-- <Nop>
    PlanetMenu an 830.10  🗂️&t.&Save\ Current\ Tab                    <Cmd>call planet#tab#Save()<CR>
    PlanetMenu an 830.10  🗂️&t.Open\ &Tab\.\.\.                       <Cmd>call planet#tab#Open()<CR>
    PlanetMenu an 830.10  🗂️&t.--5-- <Nop>
    PlanetMenu an 830.10  🗂️&t.E&xecute\ in\ each\ Tab<Tab>:tabdo     :tabdo<Space>
    PlanetMenu an 830.10  🗂️&t.--6-- <Nop>
    PlanetMenu an 830.10  🗂️&t.&Close<Tab>:tabclose                   <Cmd>call planet#tab#Close()<CR>
    PlanetMenu an 830.10  🗂️&t.Reopen\ Closed\ Tab                    <Cmd>call planet#tab#Reopen()<CR>
    PlanetMenu an 830.10  🗂️&t.Close\ &Other\ Tabs<Tab>:tabonly       <Cmd>call planet#tab#CloseOthers()<CR>

    " Sessions
    PlanetMenu an 840.10  📚&s.Sessions <Nop>
    an disable 📚&s.Sessions
    PlanetMenu an 840.20  📚&s.--1-- <Nop>
    PlanetMenu an 840.30  📚&s.&Save                                   <Cmd>call planet#session#Save()<CR>
    PlanetMenu an 840.40  📚&s.Save\ &As\.\.\.                         <Cmd>SSave<CR>
    PlanetMenu an 840.60  📚&s.Ad&vanced\ Save.Save\ with\ Relative\ Paths <Cmd>call planet#session#SaveVariant('relative')<CR>
    PlanetMenu an 840.70  📚&s.Ad&vanced\ Save.Save\ with\ Local\ Options <Cmd>call planet#session#SaveVariant('local')<CR>
    PlanetMenu an 840.80  📚&s.Ad&vanced\ Save.Save\ with\ All\ Options <Cmd>call planet#session#SaveVariant('all')<CR>
    PlanetMenu an 840.90  📚&s.Ad&vanced\ Save.Save\ without\ Global\ Vars <Cmd>call planet#session#SaveVariant('no-globals')<CR>
    PlanetMenu an 840.100 📚&s.--2-- <Nop>
    PlanetMenu an 840.100 📚&s.Add\ &Menu\ Entry                       <Cmd>call planet#session#ManageDesktopFile(0, 0)<CR>
    PlanetMenu an 840.100 📚&s.Add\ Des&ktop\ Entry                    <Cmd>call planet#session#ManageDesktopFile(0, 1)<CR>
    PlanetMenu an 840.100 📚&s.--3-- <Nop>
    PlanetMenu an 840.110 📚&s.&Open                                   <Cmd>call planet#session#Load('')<CR>
    PlanetMenu an 840.120 📚&s.Open\ &Last\ Session                    <Cmd>call planet#session#LoadLast()<CR>
    PlanetMenu an 840.130 📚&s.&Reopen                                 <Cmd>call planet#session#OpenPath(v:this_session)<CR>
    PlanetMenu an 840.140 📚&s.--4-- <Nop>
    PlanetMenu an 840.150 📚&s.&Close                                  <Cmd>SClose<CR>
    PlanetMenu an 840.160 📚&s.--5-- <Nop>
    PlanetMenu an 840.160 📚&s.Remove\ Menu\ Entry                       <Cmd>call planet#session#ManageDesktopFile(1, 0)<CR>
    PlanetMenu an 840.160 📚&s.Remove\ Desktop\ Entry                    <Cmd>call planet#session#ManageDesktopFile(1, 1)<CR>
    PlanetMenu an 840.160 📚&s.--6-- <Nop>
    PlanetMenu an 840.170 📚&s.&Delete                                 <Cmd>SDelete<CR>

    " Vim Apps: Open in new GUI window
    PlanetMenu an 850.10  🗄️&x.GUI <Nop>
    an disable 🗄️&x.GUI
    PlanetMenu an 850.10  🗄️&x.&Maximize                               <Cmd>call planet#gui#Window('maximize')<CR>
    PlanetMenu an 850.10  🗄️&x.&Full\ Screen                           <Cmd>call planet#gui#Window('fullscreen')<CR>
    PlanetMenu an 850.10  🗄️&x.Minimi&ze<Tab>:suspend<Tab><C-z>        <C-z>
    PlanetMenu an 850.10  🗄️&x.--1-- <Nop>
    PlanetMenu an 850.10  🗄️&x.&Start\ Vim\ Server                     <Cmd>call planet#gui#VimServerStart()<CR>
    PlanetMenu an 850.100 🗄️&x.--2-- <Nop>

    " Control GUI window with wmctrl & vim servers
    PlanetMenu an 860.10  🎛️&@.Apps <Nop>
    an disable 🎛️&@.Apps
    PlanetMenu an 860.10  🎛️&@.Calendar            <Cmd>call planet#apps#Open('Calendar')<CR>
    PlanetMenu an 860.10  🎛️&@.&Web\ Browser       <Cmd>call planet#apps#Open('W3m https://google.com/', 'w3m')<CR>
    PlanetMenu an 860.10  🎛️&@.Calculator          <Cmd>call planet#apps#Open('Calculator')<CR>
    PlanetMenu an 860.10  🎛️&@.&Htop               <Cmd>call planet#term#RunArgv(['htop'])<CR>
    PlanetMenu an 860.10  🎛️&@.&Terminal           <Cmd>call planet#apps#Open('terminal ++curwin ++kill=kill')<CR>
    PlanetMenu an 860.10  🎛️&@.&File\ Manager      <Cmd>call planet#apps#Open('Fern .')<CR>
    PlanetMenu an 860.10  🎛️&@.&Python\ Notebook   <Cmd>call planet#apps#Open('Codi python')<CR>
    PlanetMenu an 860.10  🎛️&@.C&++\ Notebook      <Cmd>call planet#apps#Open('Codi cpp')<CR>
    PlanetMenu an 860.300 🎛️&@.--1-- <Nop>
    PlanetMenu an 850.500 🗄️&x.--2-- <Nop>
    PlanetMenu an 860.600 🎛️&@.Workspaces <Nop>
    an disable 🎛️&@.Workspaces

    call planet#view#Menus('nav')
    call planet#search#Menus('nav')
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
