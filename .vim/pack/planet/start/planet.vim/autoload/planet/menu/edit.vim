scriptversion 4

func! planet#menu#edit#update() abort
  if g:PlanetVim_menus_editing
    " Vim Registers
    an 200.10  📋&i.Registers <Nop>
    an disable 📋&i.Registers
    an 200.10  📋&i.C&hoose\ to\ Paste\.\.\.              :Clap registers<CR>
    an 200.10  📋&i.Select\ to\ Edit\.\.\.                :call <SID>registers_choose_to_edit()<CR>
    an 200.10  📋&i.Select\ for\ Operator<Tab>"<a-z>      "
    an 200.10  📋&i.Macros <Nop>
    an disable 📋&i.Macros
    an 200.10  📋&i.Start/Stop\ Record<Tab>q{0-9a-z"}     q
    an 200.10  📋&i.Execute<Tab>@{a-z}                    @
    an 200.10  📋&i.Repeat\ Execute<Tab>@@                @@
    "TODO: Add all non-empty registers to this menu

    " signature.vim (marks)
    an 210.10  🔖&'.Marks <Nop>
    an disable 🔖&'.Marks
    an 210.10  🔖&'.C&hoose<Tab>:Clap\ marks                  :Clap marks<CR>
    an 210.10  🔖&'.Select<Tab>'{a-z}                         '
    an 210.10  🔖&'.Open\ LocList<Tab>m/                      m/
    an 210.20  🔖&'.--1-- <Nop>
    an 210.30  🔖&'.Add<Tab>m,                                m,
    an 210.40  🔖&'.Toggle<Tab>m\.                            m.
    an 210.50  🔖&'.Delete<Tab>m-                             m-
    an 210.60  🔖&'.Delete\ All<Tab>m<Space>                  m<Space>
    an 210.70  🔖&'.--2-- <Nop>
    an 210.90  🔖&'.Previous<Tab>['                           [`
    an 210.80  🔖&'.Next<Tab>]'                               ]`
    an 210.100 🔖&'.Next\ Alphabetically<Tab>`]               `]
    an 210.110 🔖&'.Previous\ Alphabetically<Tab>`]           `[
    an 210.120 🔖&'.--3-- <Nop>
    an 210.110 🔖&'.Previous\ Jump<Tab>''                     ``
    an 210.110 🔖&'.Go\ to\ Mark<Tab>'{a-z}                   `
    an 210.120 🔖&'.--3-- <Nop>
    an 210.110 🔖&'.Set\ Mark<Tab>m{a-z}                      m

    " markers
    "TODO: maybe change to subsubmenus for groups: add, delete, next, prev
    am 220.10  🏷️&".Markers <Nop>
    am disable 🏷️&".Markers
    am 220.10  🏷️&".Add\ &1                              m1
    am 220.20  🏷️&".Add\ &2                              m2
    am 220.30  🏷️&".Add\ &3                              m3
    am 220.40  🏷️&".Add\ &4                              m4
    am 220.50  🏷️&".Add\ &5                              m5
    am 220.60  🏷️&".Add\ &6                              m6
    am 220.70  🏷️&".Add\ &7                              m7
    am 220.80  🏷️&".Add\ &8                              m8
    am 220.90  🏷️&".Add\ &9                              m9
    am 220.100 🏷️&".Add\ &0                              m0
    am 220.110 🏷️&".--1-- <Nop>
    am 220.120 🏷️&".Remove\ 1\ (&!)                      m!
    am 220.130 🏷️&".Remove\ 2\ (&@)                      m@
    am 220.140 🏷️&".Remove\ 3\ (&#)                      m#
    am 220.150 🏷️&".Remove\ 4\ (&$)                      m$
    am 220.160 🏷️&".Remove\ 5\ (&%)                      m%
    am 220.170 🏷️&".Remove\ 6\ (&^)                      m^
    am 220.180 🏷️&".Remove\ 7\ (&&)                      m&
    am 220.190 🏷️&".Remove\ 8\ (&*)                      m*
    am 220.200 🏷️&".Remove\ 9\ (&()                      m(
    am 220.210 🏷️&".Remove\ 0\ (&))                      m)
    am 220.220 🏷️&".--2-- <Nop>
    am 220.230 🏷️&".To\ &Next\ of\ Same\ Group<Tab>]-    ]-
    am 220.240 🏷️&".To\ &Previous\ of\ Same\ Group<Tab>[- [-
    am 220.250 🏷️&".To\ N&ext\ of\ Any\ Group<Tab>]=     ]=
    am 220.260 🏷️&".To\ Previous\ of\ Any\ Group<Tab>[=  [=
    am 220.270 🏷️&".--3-- <Nop>
    am 220.280 🏷️&".Open\ &LocList<Tab>m?                m?
    am 220.290 🏷️&".--4-- <Nop>
    am 220.290 🏷️&".Toggle\ All                          :SignatureToggleSigns<CR>
    am 220.290 🏷️&".--4-- <Nop>
    am 220.300 🏷️&".&Remove\ All<Tab>m<BS>               m<BS>

    " Cololr highlight words with mark.vim plugin
    an 230.10  🖌️&c.CMarks <Nop>
    an disable 🖌️&c.CMarks
    an 230.10  🖌️&c.CMark\ &Current<Tab>,m                   <Leader>m
    an 230.10  🖌️&c.CMark\ &Regex<Tab>,r                     <Leader>r
    an 230.10  🖌️&c.List\ All                                :Marks<CR>
    an 230.10  🖌️&c.Toggle\ All<Tab>,M                       <Leader>M
    an 230.10  🖌️&c.Delete\ All<Tab>,N                       :MarkClear<CR>
    an 230.10  🖌️&c.--1-- <Nop>
    an 230.10  🖌️&c.Matches <Nop>
    an disable 🖌️&c.Matches
    an 230.10  🖌️&c.Add\ Match\ Regex                        :call matchadd(highlight_group, pattern)<CR>
    " Add Match Position is useful when editing binary/hex files
    an 230.10  🖌️&c.Add\ Match\ Position                     :call matchaddpos(highlight_group, visual_position)<CR>
    an 230.10  🖌️&c.Delete\ Match                            :call matchdelete(id)<CR>
    an 230.10  🖌️&c.Clear\ All\ Matches                      :call clearmatches()<CR>
    an 230.10  🖌️&c.TextProp <Nop>
    an disable 🖌️&c.TextProp

    " Bookmarks: Upper-case marks (mA-mZ)
    an 240.10  📎&k.Bookmarks <Nop>
    an disable 📎&k.Bookmarks
    an 240.10  📎&k.Open\ LocList                         :SignatureListGlobalMarks<CR>

    " Folds
    an 250.10  📜&z.Folds <Nop>
    an disable 📜&z.Folds
    an 250.20  📜&z.Fold\ by\ &Syntax<Tab><A-z>s            :setlocal foldmethod=syntax<CR>
    an 250.30  📜&z.Fold\ by\ &Indent<Tab><A-z>i            :setlocal foldmethod=indent<CR>
    an 250.40  📜&z.Fold\ by\ E&xpr<Tab><A-z>x              :setlocal foldmethod=expr<CR>
    an 250.50  📜&z.Fold\ by\ Mar&kers<Tab><A-z>k           :setlocal foldmethod=marker<CR>
    an 250.100 📜&z.Manua&l<Tab><A-z>l                      :setlocal foldmethod=manual<CR>
    an 250.110 📜&z.--1-- <Nop>
    an 250.120 📜&z.&Open<Tab>zo                            zo
    an 250.130 📜&z.&Close<Tab>zc                           zc
    an 250.140 📜&z.Toggle\ (&a)<Tab>za                     za
    an 250.150 📜&z.Open\ One\ Level\ (&w)<Tab>zr           zr
    an 250.160 📜&z.Close\ One\ Level\ (&b)<Tab>zm          zm
    an 250.170 📜&z.Open\ All\ (&r)<Tab>zR                  zR
    an 250.180 📜&z.Close\ All\ (&m)<Tab>zM                 zM
    an 250.190 📜&z.--2-- <Nop>
    an 250.200 📜&z.Open\ till\ Cursor\ &Visible<Tab>zv     zv
    an 250.200 📜&z.Open\ only\ Cursor\ Line<Tab>zMzx       zMzx
    an 250.210 📜&z.Open\ All\ at\ Cursor\ (&g)<Tab>zO      zO
    an 250.220 📜&z.Close\ All\ at\ Cursor\ (&h)<Tab>zC     zC
    an 250.230 📜&z.Toggle\ All\ at\ Cursor\ (&z)<Tab>zA    zA
    an 250.240 📜&z.Apply\ 'foldlevel'\ &&\ Open\ at\ Cursor\ (&j)<Tab>zx zx
    an 250.250 📜&z.Apply\ 'foldlevel'\ (&q)<Tab>zX         zX
    an 250.260 📜&z.--3-- <Nop>
    an 250.270 📜&z.&Previous<Tab>zk                        zk
    an 250.280 📜&z.&Next<Tab>zj                            zj
    an 250.290 📜&z.--4-- <Nop>
    an 250.300 📜&z.Cr&eate<Tab>zf                          zf
    an 250.320 📜&z.--5-- <Nop>
    an 250.330 📜&z.&Delete<Tab>zd                          zd
    an 250.340 📜&z.Delete\ All\ at\ Cursor\ (&@)<Tab>zD    zD
    an 250.350 📜&z.Delete\ All\ (&\\)<Tab>zE               zE
    an 250.360 📜&z.--6-- <Nop>
    an 250.370 📜&z.Update\ All\ Folds\ (&')<Tab>zuz        zuz
    an 250.380 📜&z.--7-- <Nop>
    an 250.390 📜&z.Advanced\ (&\.).&Enable<Tab>zN          zN
    an 250.400 📜&z.Advanced\ (&\.).&Disable<Tab>zn         zn
    an 250.410 📜&z.Advanced\ (&\.).&Toggle\ Enable<Tab>zi  zi
    an 250.410 📜&z.Advanced\ (&\.).--8-- <Nop>
    an 250.410 📜&z.Advanced\ (&\.).&Increase\ 'foldcolumn' :set foldcolumn+=1<CR>
    an 250.410 📜&z.Advanced\ (&\.).Dec&rease\ 'foldcolumn' :set foldcolumn-=1<CR>
    an 250.410 📜&z.Advanced\ (&\.).--9-- <Nop>
    an 250.410 📜&z.Advanced\ (&\.).Run\ Command\ on\ &Visible\ Lines :folddoopen 
    an 250.410 📜&z.Advanced\ (&\.).Run\ Command\ on\ &Folded\ Lines  :folddoclosed 
    an 250.410 📜&z.AutoFold <Nop>
    an disable 📜&z.AutoFold
    an 250.410 📜&z.Enable\ Au&toFold                       :call planet#fold#EnableAuto()<CR>
    an 250.410 📜&z.Increase\ 'foldlevel'\ (&y)             :setlocal foldlevel+=1<CR>
    an 250.410 📜&z.Decrease\ '&foldlevel'                  :setlocal foldlevel-=1<CR>
    an 250.410 📜&z.Disable\ A&utoFold                      :call planet#fold#DisableAuto()<CR>

    " quickfix
    " TODO: set 'errorfile' 'makeef' 'errorformat' 'makeprg' 'grepprg'
    " TODO: 'grepformat'
    " TODO: Add copy to LL, merge with previous, choose list, delete current,
    " TODO: delete all
    an 260.10  &QF.QuickFix <Nop>
    an disable &QF.QuickFix
    an 260.20  &QF.Sea&rch                                      :Grepper -tool rg -quickfix<CR>
    an 260.30  &QF.Search\ Add                                  :Grepper -tool rg -quickfix -append<CR>
    an 260.40  &QF.Search\ Side                                 :Grepper -tool rg -quickfix -side<CR>
    an 260.50  &QF.F&ind<Tab>:Cfind!                            :Cfind! 
    an 260.60  &QF.Loc&ate<Tab>:Clocate!                        :Clocate! 
    an 260.70  &QF.&Grep<Tab>:grep                              :grep 
    an 260.80  &QF.GrepAdd\ (&b)<Tab>:grepadd                   :grepadd 
    an 260.90  &QF.&VimGrep<Tab>:vimgrep                        :vimgrep 
    an 260.100 &QF.Vi&mGrepAdd<Tab>:vimgrepadd                  :vimgrepadd 
    an 260.110 &QF.TODO                                         :Grepper -quickfix -noprompt -tool rg -query -E '(TODO\|FIXME\|XXX):'
    an 260.120 &QF.--1-- <Nop>
    an 260.130 &QF.C&hoose<Tab>:Clap\ quickfix                  :Clap quickfix<CR>
    an 260.140 &QF.--2-- <Nop>
    am 260.150 &QF.&First<Tab>:cfirst<Tab>[Q                    [Q
    an 260.160 &QF.Previou&s\ File<Tab>:cpfile<Tab>[<C-q>       :cpfile<CR>
    am 260.170 &QF.&Previous<Tab>[q                             [q
    am 260.180 &QF.&Next<Tab>]q                                 ]q
    an 260.190 &QF.N&ext\ File<Tab>:cnfile<Tab>]<C-q>           :cnfile<CR>
    am 260.200 &QF.&Last<Tab>:clast<Tab>]Q                      ]Q
    an 260.210 &QF.--3-- <Nop>
    an 260.220 &QF.E&xecute\ for\ each<Tab>:cdo                 :cdo 
    an 260.230 &QF.Execute\ for\ each\ File\ (&z)<Tab>:cfdo     :cfdo 
    an 260.240 &QF.--4-- <Nop>
    an 260.250 &QF.&Open<Tab>:copen                             :copen<CR>
    an 260.260 &QF.Fil&ter<Tab>:Cfilter                         :Cfilter 
    an 260.270 &QF.Filter\ O&ut<Tab>:Cfilter!                   :Cfilter! 
    an 260.280 &QF.E&dit<Tab>:Qflistsplit<Tab>c\\q              :Qflistsplit<CR>
    an 260.290 &QF.Read\ from\ File\ (&w)<Tab>:cgetfile         :cgetfile! 
    an 260.300 &QF.Add\ from\ File\ (&y)<Tab>:caddfile          :caddfile! 
    an 260.310 &QF.Read\ from\ Buffer\ (&,)<Tab>:cgetbuffer     :cgetbuffer! 
    an 260.320 &QF.Add\ from\ Buffer\ (&\.)<Tab>:caddbuffer     :caddbuffer! 
    an 260.330 &QF.Read\ from\ Expr\ (&;)<Tab>:cgetexpr         :cgetexpr! 
    an 260.340 &QF.Add\ from\ Expr\ (&')<Tab>:caddexpr          :caddexpr! 
    an 260.350 &QF.&Close<Tab>:cclose<Tab>                      :cclose<CR>
    an 260.360 &QF.--5-- <Nop>
    an 260.370 &QF.Previous\ QuickFix\ (&k)<Tab>:colder         :colder<CR>
    an 260.380 &QF.Next\ QuickFix\ (&j)<Tab>:cnewer             :cnewer<CR>
    an 260.390 &QF.List\ QuickFixes\ (&q)<Tab>:chistory         :chistory<CR>
    an 260.390 &QF.Delete\ All\ QuickFixes                      :call setqflist([], 'f')<CR>

    " loclist
    an 270.10  &LL.LocList <Nop>
    an disable &LL.LocList
    an 270.20  &LL.Sea&rch                                      :Grepper -tool rg -noquickfix<CR>
    an 270.30  &LL.Search\ Add                                  :Grepper -tool rg -noquickfix -append<CR>
    an 270.40  &LL.Search\ Side                                 :Grepper -tool rg -noquickfix -side<CR>
    an 270.50  &LL.F&ind<Tab>:Lfind!                            :Lfind! 
    an 270.60  &LL.Loc&ate<Tab>:Llocate!                        :Llocate! 
    an 270.70  &LL.&Grep<Tab>:lgrep                             :lgrep 
    an 270.80  &LL.GrepAdd\ (&b)<Tab>:lgrepadd                  :lgrepadd 
    an 270.90  &LL.&VimGrep<Tab>:lvimgrep                       :lvimgrep 
    an 270.100 &LL.Vi&mGrepAdd<Tab>:lvimgrepadd                 :lvimgrepadd 
    an 270.110 &LL.TODO                                         :Grepper -noquickfix -noprompt -tool rg -query -E '(TODO\|FIXME\|XXX):'
    an 270.120 &LL.--1-- <Nop>
    an 270.130 &LL.C&hoose<Tab>:Clap\ loclist                   :Clap loclist<CR>
    an 270.140 &LL.--2-- <Nop>
    am 270.150 &LL.&First<Tab>:lfirst<Tab>[L                    [L
    an 270.160 &LL.Previou&s\ File<Tab>:lpfile<Tab>[<C-l>       :lpfile<CR>
    am 270.170 &LL.&Previous<Tab>[l                             [l
    am 270.180 &LL.&Next<Tab>]l                                 ]l
    an 270.190 &LL.N&ext\ File<Tab>:lnfile<Tab>]<C-l>           :lnfile<CR>
    am 270.200 &LL.&Last<Tab>:llast<Tab>]L                      ]L
    an 270.210 &LL.--3-- <Nop>
    an 270.220 &LL.E&xecute\ for\ each<Tab>:ldo                 :ldo 
    an 270.230 &LL.Execute\ for\ each\ File\ (&z)<Tab>:lfdo     :lfdo 
    an 270.240 &LL.--4-- <Nop>
    an 270.250 &LL.&Open<Tab>:lopen                             :lopen<CR>
    an 270.260 &LL.Fil&ter<Tab>:Lfilter                         :Lfilter 
    an 270.270 &LL.Filter\ O&ut<Tab>:Lfilter!                   :Lfilter! 
    an 270.280 &LL.E&dit<Tab>:Loclistsplit<Tab>c\\l             :Loclistsplit<CR>
    an 270.290 &LL.Read\ from\ File\ (&w)<Tab>:lgetfile         :lgetfile! 
    an 270.300 &LL.Add\ from\ File\ (&y)<Tab>:laddfile          :laddfile! 
    an 270.310 &LL.Read\ from\ Buffer\ (&,)<Tab>:lgetbuffer     :lgetbuffer! 
    an 270.320 &LL.Add\ from\ Buffer\ (&\.)<Tab>:laddbuffer     :laddbuffer! 
    an 270.330 &LL.Read\ from\ Expr\ (&;)<Tab>:lgetexpr         :lgetexpr! 
    an 270.340 &LL.Add\ from\ Expr\ (&')<Tab>:laddexpr          :laddexpr! 
    an 270.350 &LL.&Close<Tab>:lclose<Tab>                      :lclose<CR>
    an 270.360 &LL.--5-- <Nop>
    an 270.370 &LL.Previous\ LocList\ (&k)<Tab>:lolder          :lolder<CR>
    an 270.380 &LL.Next\ LocList\ (&j)<Tab>:lnewer              :lnewer<CR>
    an 270.390 &LL.List\ LocLists\ (&q)<Tab>:lhistory           :lhistory<CR>
    an 270.390 &LL.Delete\ All\ LocLists\ in\ Window            :call setloclist(0, [], 'f')<CR>
    an 270.390 &LL.Delete\ All\ LocLists\ in\ Tab               :windo call setloclist(0, [], 'f')<CR>
    an 270.390 &LL.Delete\ All\ LocLists\ in\ All\ Tabs         :tabdo windo call setloclist(0, [], 'f')<CR>
  else
    silent! aunmenu 📋&i
    silent! aunmenu 🔖&'
    silent! aunmenu 🏷️&"
    silent! aunmenu 🖌️&c
    silent! aunmenu 📎&k
    silent! aunmenu 📜&z
    silent! aunmenu &QF
    silent! aunmenu &LL
  endif
endfunc
