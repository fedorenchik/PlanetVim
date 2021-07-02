scriptversion 4

func! planet#menu#nav#Update() abort
  if g:PlanetVim_menus_nav
    " Buffers
    an 800.10  📖&b.Buffers <Nop>
    an disable 📖&b.Buffers
    an 800.10  📖&b.C&hoose\.\.\.                           :Clap buffers<CR>
    an 800.10  📖&b.Manager\.\.\.                           :Bufexplorer<CR>
    an 800.10  📖&b.Open<Tab>:b                             :b 
    an 800.10  📖&b.Open\ VSplit<Tab>:vert sb               :vert sb 
    an 800.10  📖&b.Open\ Tab<Tab>:tab sb                   :tab sb 
    an 800.10  📖&b.Open\ All\ Loaded\ VSplit<Tab>:vert unh :vert unh<CR>
    an 800.10  📖&b.Open\ All\ Loaded\ Tab<Tab>:tab unh     :tab unh<CR>
    an 800.10  📖&b.Open\ All\ VSplit<Tab>:vert ba          :vert ba<CR>
    an 800.10  📖&b.Open\ All\ Tab<Tab>:tab ba              :tab ba<CR>
    an 800.20  📖&b.--1-- <Nop>
    an 800.30  📖&b.&Alternate<Tab>:b\ #<Tab><C-@>          <C-^>
    an 800.30  📖&b.&Alternate\ Split<Tab>+^                <C-w>^
    an 800.40  📖&b.--2-- <Nop>
    an 800.30  📖&b.Next\ Modified<Tab>:bm                  :bm<CR>
    an 800.30  📖&b.Next\ Modified\ VSplit<Tab>:vert sbm    :vert sbm<CR>
    an 800.30  📖&b.Next\ Modified\ Tab<Tab>:tab sbm        :tab sbm<CR>
    an 800.40  📖&b.--3-- <Nop>
    an 800.40  📖&b.&First<Tab>[B                           :bf<CR>
    an 800.40  📖&b.&Previous<Tab>[b                        :bp<CR>
    an 800.40  📖&b.&Next<Tab>]b                            :bn<CR>
    an 800.40  📖&b.&Last<Tab>]B                            :bl<CR>
    an 800.40  📖&b.&First\ VSplit<Tab>:vert sbf            :vert sbf<CR>
    an 800.40  📖&b.&Previous\ VSplit<Tab>:vert sbp         :vert sbp<CR>
    an 800.40  📖&b.&Next\ VSplit<Tab>:vert sbn             :vert sbn<CR>
    an 800.40  📖&b.&Last\ VSplit<Tab>:vert sbl             :vert sbl<CR>
    an 800.40  📖&b.&First\ Tab<Tab>:tab sbf                :tab sbf<CR>
    an 800.40  📖&b.&Previous\ Tab<Tab>:tab sbp             :tab sbp<CR>
    an 800.40  📖&b.&Next\ Tab<Tab>:tab sbn                 :tab sbn<CR>
    an 800.40  📖&b.&Last\ Tab<Tab>:tab sbl                 :tab sbl<CR>
    an 800.40  📖&b.--4-- <Nop>
    an 800.40  📖&b.Add<Tab>:badd                           :badd 
    an 800.40  📖&b.Add\ as\ Alternate<Tab>:balt            :balt 
    an 800.40  📖&b.Unload\ (Free\ Memory)                  :bun<CR>
    an 800.40  📖&b.Delete\ (Unload\ &&\ Unlist)            :bd<CR>
    an 800.40  📖&b.Wipeout\ (Delete\ &&\ Clear\ Everything) :bw<CR>
    an 800.40  📖&b.--5-- <Nop>
    an 800.40  📖&b.Delete\ Hidden                          :call planet#buffer#DeleteHidden()<CR>
    an 800.40  📖&b.Delete\ All                             :call planet#buffer#DeleteAll()<CR>
    an 800.40  📖&b.Execute\ in\ Each\ Buffer<Tab>:bufdo    :bufdo 
    an 800.40  📖&b.--6-- <Nop>
    " an 800.50  📖&b.Buffers\ List <Nop>
    " an disable 📖&b.Buffers\ List

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
    an 810.10  🗃️&a.Run\ Each                                  :argdo<CR>
    an 810.10  🗃️&a.--3-- <Nop>
    an 810.10  🗃️&a.Args\ List <Nop>
    an disable 🗃️&a.Args\ List

    " Vim Windows
    an 820.10  🪟&w.Windows <Nop>
    an disable 🪟&w.Windows
    an 820.10  🪟&w.&Window\ Mode                           :WindowMode<CR>
    an 820.10  🪟&w.ChooseWin\ Mode\ (&\\)<Tab>\\           :ChooseWin<CR>
    an 820.10  🪟&w.--1-- <Nop>
    an 820.10  🪟&w.C&hoose<Tab>:Clap\ windows              :Clap windows<CR>
    an 820.10  🪟&w.--2-- <Nop>
    an 820.10  🪟&w.&Vertical\ Split<Tab>:vsplit<Tab>+v     <C-w>v
    an 820.10  🪟&w.Horizontal\ &Split<Tab>:split<Tab>+s    <C-w>s
    an 820.10  🪟&w.VSplit\ Bind                            :call planet#window#SplitBind('v')<CR>
    an 820.10  🪟&w.HSplit\ Bind                            :call planet#window#SplitBind('h')<CR>
    an 820.10  🪟&w.--3-- <Nop>
    an 820.10  🪟&w.Move.Swap\ (&x)<Tab>+x                       <C-w>x
    an 820.10  🪟&w.Move.Rotate\ Up<Tab>R                        <C-w>R
    an 820.10  🪟&w.Move.Rotate\ Down<Tab>r                      <C-w>r
    an 820.10  🪟&w.Move.To\ Left<Tab>+H                   <C-w>H
    an 820.10  🪟&w.Move.To\ Right<Tab>+L                  <C-w>L
    an 820.10  🪟&w.Move.To\ Top<Tab>+K                    <C-w>K
    an 820.10  🪟&w.Move.To\ Bottom<Tab>+J                 <C-w>J
    an 820.10  🪟&w.Move.To\ New\ &Tab<Tab>+T              <C-w>T
    an 820.10  🪟&w.Move.To\ New\ &GUI\ Window             :TODO
    an 820.10  🪟&w.Move.Copy\ To\ New\ Tab<Tab>+s+T             <C-w>s<C-w>T
    an 820.10  🪟&w.Move.Copy\ To\ New\ &GUI\ Window             :TODO
    an 820.10  🪟&w.--4-- <Nop>
    an 820.10  🪟&w.&Equal\ Size<Tab>+=                     <C-w>=
    an 820.10  🪟&w.&Maximize<Tab>+_+\|                     :call planet#window#Maximize()<CR>
    an 820.10  🪟&w.&Unmaximize<Tab>                        :call planet#window#Restore()<CR>
    an 820.10  🪟&w.Resize.Maximize\ &Vertically<Tab>+_     <C-w>_
    an 820.10  🪟&w.Resize.Maximize\ &Horizontally<Tab>+\|  <C-w>\|
    an 820.10  🪟&w.Resize.Increase\ Height<Tab>++          <C-w>+
    an 820.10  🪟&w.Resize.Decrease\ Height<Tab>+-          <C-w>-
    an 820.10  🪟&w.Resize.Increase\ Width<Tab>+>           <C-w>>
    an 820.10  🪟&w.Resize.Decrease\ Width<Tab>+<           <C-w><
    an 820.10  🪟&w.--6-- <Nop>
    an 820.10  🪟&w.Focus.Alternate<Tab>+p                 <C-w>p
    an 820.10  🪟&w.Focus.Preview\ Window<Tab>+P           <C-w>P
    an 820.10  🪟&w.Focus.Previous\ Window<Tab>+W          <C-w>W
    an 820.10  🪟&w.Focus.Next\ Window<Tab>+w              <C-w>w
    an 820.10  🪟&w.Focus.Top\ Window<Tab>+t               <C-w>t
    an 820.10  🪟&w.Focus.Bottom\ Window<Tab>+b            <C-w>b
    an 820.10  🪟&w.Focus.Left<Tab>+h                      :call planet#window#Focus('h')<CR>
    an 820.10  🪟&w.Focus.Right<Tab>+l                     :call planet#window#Focus('l')<CR>
    an 820.10  🪟&w.Focus.Up<Tab>+k                        <C-w>k
    an 820.10  🪟&w.Focus.Down<Tab>+j                      <C-w>j
    an 820.10  🪟&w.--7-- <Nop>
    an 820.10  🪟&w.Set\ Fixed\ Size                        :set winfixheight winfixwidth<CR>
    an 820.10  🪟&w.--8-- <Nop>
    an 820.10  🪟&w.View.Save                               :mkview<CR>
    an 820.10  🪟&w.View.Save\ 1                            :mkview 1<CR>
    an 820.10  🪟&w.View.Save\ 2                            :mkview 2<CR>
    an 820.10  🪟&w.View.Save\ 3                            :mkview 3<CR>
    an 820.10  🪟&w.View.Save\ 4                            :mkview 4<CR>
    an 820.10  🪟&w.View.Save\ 5                            :mkview 5<CR>
    an 820.10  🪟&w.View.Save\ 6                            :mkview 6<CR>
    an 820.10  🪟&w.View.Save\ 7                            :mkview 7<CR>
    an 820.10  🪟&w.View.Save\ 8                            :mkview 8<CR>
    an 820.10  🪟&w.View.Save\ 9\ (AutoSave)                :mkview 9<CR>
    an 820.10  🪟&w.View.--1-- <Nop>
    an 820.10  🪟&w.View.Load                               :loadview<CR>
    an 820.10  🪟&w.View.Load\ 1                            :loadview 1<CR>
    an 820.10  🪟&w.View.Load\ 2                            :loadview 2<CR>
    an 820.10  🪟&w.View.Load\ 3                            :loadview 3<CR>
    an 820.10  🪟&w.View.Load\ 4                            :loadview 4<CR>
    an 820.10  🪟&w.View.Load\ 5                            :loadview 5<CR>
    an 820.10  🪟&w.View.Load\ 6                            :loadview 6<CR>
    an 820.10  🪟&w.View.Load\ 7                            :loadview 7<CR>
    an 820.10  🪟&w.View.Load\ 8                            :loadview 8<CR>
    an 820.10  🪟&w.View.Load\ 9\ (AutoSave)                :loadview 9<CR>
    an 820.10  🪟&w.View.--2-- <Nop>
    an 820.10  🪟&w.View.Toggle\ AutoSave\ Views            :call planet#windowview#ToggleAutoSave()<CR>
    an 820.10  🪟&w.View.--3-- <Nop>
    an 820.10  🪟&w.View.Toggle\ Save\ Local\ Options       :TODO
    an 820.10  🪟&w.Layout.Save                             :let g:PV_layout = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 1                          :let g:PV_layout_1 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 2                          :let g:PV_layout_2 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 3                          :let g:PV_layout_3 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 4                          :let g:PV_layout_4 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 5                          :let g:PV_layout_5 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 6                          :let g:PV_layout_6 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 7                          :let g:PV_layout_7 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 8                          :let g:PV_layout_8 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Save\ 9                          :let g:PV_layout_9 = winrestcmd()<CR>
    an 820.10  🪟&w.Layout.Load                             :exe g:PV_layout<CR>
    an 820.10  🪟&w.Layout.Load\ 1                          :exe g:PV_layout_1<CR>
    an 820.10  🪟&w.Layout.Load\ 2                          :exe g:PV_layout_2<CR>
    an 820.10  🪟&w.Layout.Load\ 3                          :exe g:PV_layout_3<CR>
    an 820.10  🪟&w.Layout.Load\ 4                          :exe g:PV_layout_4<CR>
    an 820.10  🪟&w.Layout.Load\ 5                          :exe g:PV_layout_5<CR>
    an 820.10  🪟&w.Layout.Load\ 6                          :exe g:PV_layout_6<CR>
    an 820.10  🪟&w.Layout.Load\ 7                          :exe g:PV_layout_7<CR>
    an 820.10  🪟&w.Layout.Load\ 8                          :exe g:PV_layout_8<CR>
    an 820.10  🪟&w.Layout.Load\ 9                          :exe g:PV_layout_9<CR>
    an 820.10  🪟&w.Layout.--1-- <Nop>
    an 820.10  🪟&w.--7-- <Nop>
    an 820.10  🪟&w.Execute\ in\ Window\ in\ This\ Tab      :windo 
    an 820.10  🪟&w.Execute\ in\ each\ Window               :tabdo windo 
    an 820.10  🪟&w.--5-- <Nop>
    an 820.10  🪟&w.--9-- <Nop>
    an 820.10  🪟&w.&Close<Tab>:close<Tab>+c                <C-w>c
    an 820.10  🪟&w.Close\ &Other\ Windows<Tab>:only<Tab>+o <C-w>o

    " Tabs
    an 830.10  🗂️&c.Tabs <Tabs>
    an disable 🗂️&c.Tabs
    an 830.10  🗂️&c.N&ew<Tab>:tabnew                       :tabnew<CR>
    an 830.10  🗂️&c.--1-- <Nop>
    an 830.10  🗂️&c.&Alternate<Tab>g\<Tab\>                g<Tab>
    an 830.10  🗂️&c.--2-- <Nop>
    an 830.10  🗂️&c.&First<Tab>:tabfirst                   :tabfirst<CR>
    an 830.10  🗂️&c.&Previous<Tab><C-PgUp><Tab>gT          gT
    an 830.10  🗂️&c.&Next<Tab><C-PgDown><Tab>gt            gt
    an 830.10  🗂️&c.&Last<Tab>:tablast                     :tablast<CR>
    an 830.10  🗂️&c.--3-- <Nop>
    an 830.10  🗂️&c.Move\ First<Tab>:0tabmove              :0tabmove<CR>
    an 830.10  🗂️&c.Move\ Previous<Tab>:-tabmove           :-tabmove<CR>
    an 830.10  🗂️&c.Move\ Next<Tab>:+tabmove               :+tabmove<CR>
    an 830.10  🗂️&c.Move\ Last<Tab>:tabmove                :tabmove<CR>
    an 830.10  🗂️&c.--4-- <Nop>
    an 830.10  🗂️&c.Save\ Current\ Tab                     :call planet#tab#Save()<CR>
    an 830.10  🗂️&c.Open\ Tab\.\.\.                        :call planet#tab#Open()<CR>
    an 830.10  🗂️&c.--5-- <Nop>
    an 830.10  🗂️&c.E&xecute\ in\ each\ Tab<Tab>:tabdo     :tabdo 
    an 830.10  🗂️&c.--6-- <Nop>
    "TODO: autosave tab when close, using autocmds
    an 830.10  🗂️&c.&Close<Tab>:tabclose                   :tabclose<CR>
    an 830.10  🗂️&c.Close\ all\ &other\ tabs<Tab>:tabonly  :tabonly<CR>

    " Sessions
    an 840.10  📚&s.Sessions <Nop>
    an disable 📚&s.Sessions
    an 840.20  📚&s.--1-- <Nop>
    an 840.30  📚&s.&Save                                  <Cmd>call planet#session#Save()<CR>
    an 840.40  📚&s.Save\ &As\.\.\.                        :SSave<CR>
    an 840.50  📚&s.--2-- <Nop>
    an 840.60  📚&s.Advanced\ Save.Save\ with\ Relative\ Paths :TODO"set sessionoptions-=sesdir,+=curdir,v:this_session=dirname
    an 840.70  📚&s.Advanced\ Save.Save\ with\ Local\ Options :TODO"set sessionoptions+=localoptions
    an 840.80  📚&s.Advanced\ Save.Save\ with\ All\ Options :TODO"set sessionoptions+=localoptions,options
    an 840.90  📚&s.Advanced\ Save.Save\ without\ Global\ Vars :TODO"set sessionoptions-=globals
    an 840.100 📚&s.--2-- <Nop>
    an 840.110 📚&s.&Open                                  :SLoad<CR>
    an 840.120 📚&s.Open\ &Last\ Session                   :SLoad!<CR>
    an 840.130 📚&s.&Reopen                                :exe 'SLoad ' .. fnamemodify(v:this_session, ":t")<CR>
    an 840.140 📚&s.--3-- <Nop>
    an 840.150 📚&s.&Close                                 :SClose<CR>
    an 840.160 📚&s.--4-- <Nop>
    an 840.170 📚&s.&Delete                                :SDelete<CR>
    an 840.180 📚&s.--5-- <Nop>

    " Vim Apps: Open in new GUI window
    an 850.10  🗄️&x.Apps <Nop>
    an disable 🗄️&x.Apps
    an 850.10  🗄️&x.Calendar            :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +Calendar<CR>
    an 850.10  🗄️&x.Web\ Browser        :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'W3m https://google.com/'<CR>
    an 850.10  🗄️&x.Calculator          :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +Calculator<CR>
    an 850.10  🗄️&x.Htop                <Cmd>call planet#term#RunCmdTab('htop')<CR>
    an 850.10  🗄️&x.Terminal            :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'terminal ++curwin ++kill=kill'<CR>
    an 850.10  🗄️&x.File\ Manager       :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'Fern .'<CR>
    an 850.10  🗄️&x.Python\ Notebook    :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'Codi python'<CR>
    an 850.10  🗄️&x.C++\ Notebook       :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' -c 'Codi cpp'<CR>
    "TODO: Email
    "TODO: difdiff

    " Control GUI window with wmctrl & vim servers
    an 860.10  🎛️&@.GUI <Nop>
    an disable 🎛️&@.GUI
    an 860.10  🎛️&@.&Maximize            :silent call system('wmctrl -i -b toggle,maximized_vert,maximized_horz -r' . v:windowid)<CR>
    an 860.10  🎛️&@.&Full\ Screen        :silent call system('wmctrl -i -b toggle,fullscreen -r' . v:windowid)<CR>
    an 860.10  🎛️&@.Minimi&ze<Tab>:suspend<Tab><C-z>        <C-z>
    an 860.10  🎛️&@.--1-- <Nop>
    an 860.10  🎛️&@.&Start\ Vim\ Server                     <Cmd>call planet#gui#VimServerStart<CR>
    an 860.100 🎛️&@.--2-- <Nop>
    an 860.600 🎛️&@.Workspaces <Nop>
    an disable 🎛️&@.Workspaces

  else
    silent! aunmenu 📖&b
    silent! aunmenu 🗃️&a
    silent! aunmenu 🪟&w
    silent! aunmenu 🗂️&\.
    silent! aunmenu 📚&h
    silent! aunmenu 🗄️&x
    silent! aunmenu 🎛️&@
  endif
endfunc
