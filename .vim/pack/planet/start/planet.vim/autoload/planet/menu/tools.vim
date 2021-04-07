scriptversion 4

func! planet#menu#tools#update() abort
  if g:PlanetVim_menus_tools
    " Git
    " Open Log in new window
    an 700.10  🔀&,.Git <Nop>
    an disable 🔀&,.Git
    an 700.10  🔀&,.&Status                                       :call planet#term#run_cmd_output('git status')<CR>
    an 700.10  🔀&,.--1-- <Nop>
    an 700.10  🔀&,.&Fetch                                        :call planet#term#run_cmd_output('git fetch --all --tags')<CR>
    an 700.10  🔀&,.P&ull                                         :call planet#term#run_cmd_output('git pull --ff-only --all')<CR>
    an 700.10  🔀&,.&Push                                         :call planet#term#run_cmd_output('git push')<CR>
    an 700.10  🔀&,.&Add.This\ &File                              :call planet#term#run_cmd_output('git add ' .. expand('%'))<CR>
    an 700.10  🔀&,.&Add.Current\ &Directory                      :call planet#term#run_cmd_output('git add .')<CR>
    an 700.10  🔀&,.&Add.&All                                     :call planet#term#run_cmd_output('git add --all')<CR>
    an 700.10  🔀&,.&Commit.Commit                                :call planet#git#Commit(v:false, v:false, v:false)<CR>
    an 700.10  🔀&,.&Commit.Commit\ File                          :call planet#git#CommitFile(v:false, v:false)<CR>
    an 700.10  🔀&,.&Commit.Save\ &&\ Commit\ File                :call planet#git#CommitFile(v:true, v:false)<CR>
    an 700.10  🔀&,.&Commit.Commit\ All                           :TODO
    an 700.10  🔀&,.&Commit.Commit\ All\ with\ Untracked          :TODO
    an 700.10  🔀&,.&Commit.--2-- <Nop>
    an 700.10  🔀&,.&Commit.AutoCommit\ File                      :call planet#git#CommitFile(v:false)<CR>
    an 700.10  🔀&,.&Commit.Save\ &&\ AutoCommit\ File            :call planet#git#CommitFile()<CR>
    an 700.10  🔀&,.&Commit.AutoCommit\ File\ &&\ Push            :call planet#git#CommitFile(v:false, v:true, v:true)<CR>
    an 700.10  🔀&,.&Commit.Save\ &&\ AutoCommit\ File\ &&\ Push  :call planet#git#CommitFile(v:true, v:true, v:true)<CR>
    an 700.10  🔀&,.&Commit.AutoCommit                            :call planet#git#Commit(v:false)<CR>
    an 700.10  🔀&,.&Commit.Save\ All\ &&\ AutoCommit             :call planet#git#Commit()<CR>
    an 700.10  🔀&,.&Commit.AutoCommit\ &&\ Push                  :call planet#git#Commit(v:false, v:true, v:true)<CR>
    an 700.10  🔀&,.&Commit.Save\ All\ &&\ AutoCommit\ &&\ Push   :call planet#git#Commit(v:true, v:true, v:true)<CR>
    an 700.10  🔀&,.&Commit.--3-- <Nop>
    an 700.10  🔀&,.&Commit.Enable\ AutoCommit\ on\ File\ Write   :call planet#git#EnableAutoCommit()<CR>
    an 700.10  🔀&,.&Commit.Disable\ AutoCommit\ on\ File\ Write  :call planet#git#DisableAutoCommit()<CR>
    an 700.10  🔀&,.Fetch\ .From\ Specified\ Remote               :call planet#git#FetchCustomRemote()<CR>
    an 700.10  🔀&,.Pull\ .TODO                                   :call planet#git#FetchCustomRemote()<CR>
    an 700.10  🔀&,.Push\ .TODO                                   :call planet#git#FetchCustomRemote()<CR>
    an 700.10  🔀&,.&Log.File\ QF                                 :TODO
    an 700.10  🔀&,.&Log.File\ LL                                 :TODO
    an 700.10  🔀&,.&Log.QF                                       :TODO
    an 700.10  🔀&,.&Log.LL                                       :TODO
    an 700.10  🔀&,.&Log.in\ New\ GWindow                         :TODO
    an 700.10  🔀&,.&Log.Git&k                                    :silent !nohup gitk >/dev/null 2>&1 &<CR>
    an 700.10  🔀&,.Tag.TODO                                      :TODO
    an 700.10  🔀&,.Merge.TODO                                    :TODO
    an 700.10  🔀&,.Rebase.TODO                                   :TODO
    an 700.10  🔀&,.Reflog.TODO                                   :TODO
    an 700.10  🔀&,.Reset.TODO                                    :TODO
    an 700.10  🔀&,.Stash.TODO                                    :TODO
    an 700.10  🔀&,.Notes.TODO                                    :TODO
    an 700.10  🔀&,.Branch.TODO                                   :TODO
    an 700.10  🔀&,.Diff.TODO                                     :TODO
    an 700.10  🔀&,.Worktree.TODO                                 :TODO
    an 700.10  🔀&,.Subrepo\ (&x).Pull                            :call planet#git#SubrepoPull()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Pull\ All                       :call planet#term#run_cmd_output('git subrepo pull --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Push                            :call planet#git#SubrepoPush()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Push\ All                       :call planet#term#run_cmd_output('git subrepo push --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Fetth                           :call planet#git#SubrepoFetch()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Fetch\ All                      :call planet#term#run_cmd_output('git subrepo fetch --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Branch                          :call planet#git#SubrepoBranch()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Branch\ All                     :call planet#term#run_cmd_output('git subrepo branch --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Commit                          :call planet#git#SubrepoCommit()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Status                          :call planet#git#SubrepoStatus()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Status\ All                     :call planet#term#run_cmd_output('git subrepo status --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Status\ All\ Recursively        :call planet#term#run_cmd_output('git subrepo status --ALL')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clean                           :call planet#git#SubrepoClean()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clean\ All                      :call planet#term#run_cmd_output('git subrepo clean --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clean\ All\ Recursively         :call planet#term#run_cmd_output('git subrepo clean --ALL')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Config                          :call planet#git#SubrepoConfig()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clone                           :call planet#git#SubrepoClone()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Init                            :call planet#git#SubrepoInit()<CR>
    an 700.10  🔀&,.Remote.List                                   :call planet#term#run_cmd_output('git remote -a')<CR>
    an 700.10  🔀&,.--5-- <Nop>
    an 700.10  🔀&,.Clone\ Repo                                   :TODO
    an 700.10  🔀&,.Init\ Repo                                    :TODO
    an 700.10  🔀&,.--7-- <Nop>
    an 700.10  🔀&,.Blame                                         :TODO
    " tpope/rhubarb.vim plugin for GitHub
    an 700.10  🔀&,.GitHub <Nop>
    an disable 🔀&,.GitHub

    " Diff/Patch
    an 710.10  ⛏️&;.Diff/Patch <Nop>
    an disable ⛏️&;.Diff/Patch
    an 710.10  ⛏️&;.DiffOrig                          :DiffOrig<CR>
    an 710.20  ⛏️&;.Diff\ with\ file\.\.\.            :browse vert diffsplit<CR>
    an 710.30  ⛏️&;.Diff\ with\ patch\.\.\.           :browse vert diffpatch<CR>
    an 710.40  ⛏️&;.--1-- <Nop>
    an 710.40  ⛏️&;.Previous\ Hunk<Tab>[c             [c
    an 710.40  ⛏️&;.Next\ Hunk<Tab>]c                 ]c
    an 710.40  ⛏️&;.--2-- <Nop>
    am 710.40  ⛏️&;.Previous\ Conflict\ Marker<Tab>[n [n
    am 710.40  ⛏️&;.Next\ Conflict\ Marker<Tab>]n     ]n
    an 710.40  ⛏️&;.--3-- <Nop>
    an 710.40  ⛏️&;.Get\ Diff<Tab>:diffget<Tab>do     do
    an 710.40  ⛏️&;.Put\ Diff<Tab>:diffput<Tab>dp     dp
    an 710.40  ⛏️&;.--4-- <Nop>
    an 710.40  ⛏️&;.Diff\ All\ in\ Tab                :windo diffthis<CR>
    an 710.40  ⛏️&;.Diff\ with\ Alternate\ Winodw     :diffthis<CR>:wincmd p<CR>:diffthis<CR>
    an 710.40  ⛏️&;.--4-- <Nop>
    an 710.40  ⛏️&;.Set\ Context\ Lines               :set diffopt+=context=12<CR>

    " Spelling (& Dictionary & Thesaurus)
    an 720.10  🔠&-.Spelling <Nop>
    an disable 🔠&-.Spelling
    an 720.10  🔠&-.Enable<Tab>:set\ spell                  :set spell<CR>
    an 720.10  🔠&-.Disable<Tab>:set\ nospell               :set nospell<CR>
    am 720.10  🔠&-.Toggle<Tab>yos                          yos
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Previous\ Misspelled<Tab>[s         [s
    an 720.10  🔠&-.Next\ Misspelled<Tab>]s             ]s
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Spelling\ Suggestions<Tab>z=        z=
    an 720.10  🔠&-.Repeat Correction<Tab>:spellrepall  :spellrepall<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Mark\ as\ Correct\ Temp<Tab>zG      zG
    an 720.10  🔠&-.Mark\ as\ Incorrect\ Temp<Tab>zG    zW
    an 720.10  🔠&-.Mark\ as\ Correct<Tab>zg            zg
    an 720.10  🔠&-.Mark\ as\ Incorrect<Tab>zw          zw
    an 720.10  🔠&-.Unmark\ as\ Correct\ Temp<Tab>zG    zuG
    an 720.10  🔠&-.Unmark\ as\ Incorrect\ Temp<Tab>zG  zuW
    an 720.10  🔠&-.Unmark\ as\ Correct<Tab>zg          zug
    an 720.10  🔠&-.Unmark\ as\ Incorrect<Tab>zw        zuw
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Set\ Language\ to\ "en"             :set spl=en spell<CR>

    " Tools
    " TODO: add all '*.prg' options, eg: equalprg, keywordprg, etc.
    an 730.10  🔧&o.Tools <Nop>
    an disable 🔧&o.Tools
    an 730.10  🔧&o.Colori&ze                                 :ColorToggle<CR>
    an 730.10  🔧&o.--1-- <Nop>
    an 730.10  🔧&o.Start\ Local\ Python\ http\.server\ Here  :call planet#term#run_cmd_output('python3 -m http.server 8080')<CR>
    an 730.10  🔧&o.Start\ Public\ ngrok\ Server              :call planet#term#run_cmd_output('ngrok http 3000')<CR>
    an 730.10  🔧&o.--2-- <Nop>
    an 730.10  🔧&o.Edit\ Command<Tab>:                       q:
    an 730.10  🔧&o.Edit\ Search<Tab>q/                       q/
    an 730.10  🔧&o.Edit\ Search\ Backwards<Tab>q?            q?
    an 730.10  🔧&o.--3-- <Nop>
    an 730.10  🔧&o.Convert\ to\ HEX<Tab>:%!xxd             :call <SID>XxdToHex()<CR>
    an 730.10  🔧&o.Convert\ from\ HEX<Tab>:%!xxd\ -r       :call <SID>XxdFromHex()<CR>
  else
    silent! aunmenu 🔀&,
    silent! aunmenu ⛏️&;
    silent! aunmenu 🔤&-
    silent! aunmenu 🔧&o
  endif
endfunc
