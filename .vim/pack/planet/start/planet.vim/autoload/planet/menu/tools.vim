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
    an 700.10  🔀&,.&Add.&Move                                    :TODO
    an 700.10  🔀&,.&Add.&Remove                                  :TODO
    an 700.10  🔀&,.&Add.&Restore                                 :TODO
    an 700.10  🔀&,.&Commit.&Commit                               :call planet#git#Commit(v:false, v:false, v:false)<CR>
    an 700.10  🔀&,.&Commit.Commit\ &File                         :call planet#git#CommitFile(v:false, v:false)<CR>
    an 700.10  🔀&,.&Commit.Save\ &&\ Commit\ File                :call planet#git#CommitFile(v:true, v:false)<CR>
    an 700.10  🔀&,.&Commit.Commit\ &All                          :TODO
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
    an 700.10  🔀&,.Ch&eckout.Branch                              :call planet#git#CheckoutBranch()<CR>
    an 700.10  🔀&,.Ch&eckout.File                                :call planet#git#CheckoutFile()<CR>
    an 700.10  🔀&,.Fetch\ .From\ Specified\ Remote               :call planet#git#FetchCustomRemote()<CR>
    an 700.10  🔀&,.Pull\ .TODO                                   :call planet#git#FetchCustomRemote()<CR>
    an 700.10  🔀&,.Push\ .TODO                                   :call planet#git#FetchCustomRemote()<CR>
    an 700.10  🔀&,.&Log.&Log\ (QF)                               :Gclog!<CR>
    an 700.10  🔀&,.&Log.Log\ (LL)                                :Gllog!<CR>
    an 700.10  🔀&,.&Log.File\ (QF)                               :0Gclog!<CR>
    an 700.10  🔀&,.&Log.&File\ (LL)                              :0Gllog!<CR>
    an 700.10  🔀&,.&Log.in\ New\ GWindow                         :TODO
    an 700.10  🔀&,.&Log.Git&k                                    :silent !nohup gitk >/dev/null 2>&1 &<CR>
    an 700.10  🔀&,.&Tag.TODO                                     :TODO
    an 700.10  🔀&,.&Merge.TODO                                   :TODO
    an 700.10  🔀&,.Rebase.TODO                                   :TODO
    an 700.10  🔀&,.Reflog.TODO                                   :TODO
    an 700.10  🔀&,.Reset.TODO                                    :TODO
    an 700.10  🔀&,.Stash\ (&j).TODO                              :TODO
    an 700.10  🔀&,.Notes.TODO                                    :TODO
    an 700.10  🔀&,.&Branch.List\ Local                           :call planet#term#run_cmd_output('git branch')<CR>
    an 700.10  🔀&,.&Branch.List\ All                             :call planet#term#run_cmd_output('git branch --all')<CR>
    an 700.10  🔀&,.&Branch.List\ Local-Remote                    :call planet#term#run_cmd_output('git branch --remote')<CR>
    an 700.10  🔀&,.&Branch.List\ Remote-Remote                   :call planet#term#run_cmd_output('git ls-remote')<CR>
    an 700.10  🔀&,.&Branch.Checkout                              :TODO
    an 700.10  🔀&,.&Branch.Rename                                :call planet#git#BranchRename()<CR>
    an 700.10  🔀&,.&Branch.Delete                                :call planet#git#BranchDelete()<CR>
    an 700.10  🔀&,.&Diff.&Diff                                   :call planet#term#run_cmd_output('git --no-pager diff')<CR>
    an 700.10  🔀&,.&Diff.&Stat                                   :call planet#term#run_cmd_output('git --no-pager diff --stat')<CR>
    an 700.10  🔀&,.&Diff.&Cached\ (Index)                        :call planet#term#run_cmd_output('git --no-pager diff --staged')<CR>
    an 700.10  🔀&,.&Diff.Stat\ Cached                            :call planet#term#run_cmd_output('git --no-pager diff --staged --stat')<CR>
    an 700.10  🔀&,.Cherry-pick.TODO                              :TODO
    an 700.10  🔀&,.&Worktree.TODO                                :TODO
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
    an 700.10  🔀&,.Cl&one                                        :TODO
    an 700.10  🔀&,.&Init                                         :call planet#term#run_cmd_output('git init')<CR>
    an 700.10  🔀&,.--7-- <Nop>
    an 700.10  🔀&,.LFS                                           :TODO
    an 700.10  🔀&,.Blame                                         :TODO
    an 700.10  🔀&,.Bisect                                        :TODO
    an 700.10  🔀&,.Experimental.Sparse-Checkout.Init             :TODO
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
    an 720.10  🔠&-.Spell\ Check <Nop>
    an disable 🔠&-.Spell\ Check
    an 720.10  🔠&-.Previous\ Misspelled<Tab>[S         [S
    an 720.10  🔠&-.&Previous\ Misspelled,\ Rare\ or\ Regional<Tab>[s [s
    an 720.10  🔠&-.&Next\ Misspelled,\ Rare\ or\ Regional<Tab>]s ]s
    an 720.10  🔠&-.Next\ Misspelled<Tab>]S             ]S
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Suggest\ Spelling<Tab>z=            z=
    an 720.10  🔠&-.Apply\ First\ Suggestion<Tab>1z=    1z=
    an 720.10  🔠&-.Repeat Correction<Tab>:spellrepall  :spellrepall<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Mark\ as\ Correct<Tab>zg            zg
    an 720.10  🔠&-.Mark\ as\ Incorrect<Tab>zw          zw
    an 720.10  🔠&-.Mark\ as\ Rare<Tab>:spellrare       :exe ':spellrare ' .. expand('<cWORD>')<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Mark\ as\ Correct\ Temp<Tab>zG      zG
    an 720.10  🔠&-.Mark\ as\ Incorrect\ Temp<Tab>zG    zW
    an 720.10  🔠&-.Mark\ as\ Rare\ Temp<Tab>:spellrare :exe ':spellrare! ' .. expand('<cWORD>')<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Unmark\ as\ Correct<Tab>zug         zug
    an 720.10  🔠&-.Unmark\ as\ Incorrect\ or\ Rare<Tab>zuw zuw
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Unmark\ as\ Correct\ Temp<Tab>zuG   zuG
    an 720.10  🔠&-.Unmark\ as\ Incorrect\ or\ Rare\ Temp<Tab>zuW zuW
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Set\ Language\ to\ "en"             :set spl=en spell<CR>
    an 720.10  🔠&-.Clear\ Internal\ Wordlist           :let &enc = &enc<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Enable<Tab>:set\ spell                  :set spell<CR>
    an 720.10  🔠&-.Disable<Tab>:set\ nospell               :set nospell<CR>
    am 720.10  🔠&-.Toggle<Tab>yos                          yos
    an 720.10  🔠&-.--1-- <Nop>
    am 720.10  🔠&-.Current\ Spell\ Files<Tab>:spellinfo    :spellinfo<CR>
    am 720.10  🔠&-.Cleanup\ Spell\ File                    :runtime spell/cleanadd.vim<CR>
    an 720.10  🔠&-.Grammar <Nop>
    an disable 🔠&-.Grammar
    am 720.10  🔠&-.Grammar\ Check<Tab>:GrammarousCheck     :GrammarousCheck<CR>
    am 720.10  🔠&-.Grammar\ Check\ Comments                :GrammarousCheck --comments-only<CR>
    am 720.10  🔠&-.Grammar\ Check\ Reset<Tab>:GrammarousReset :GrammarousReset<CR>
    am 720.10  🔠&-.Grammar\ Check\ Status                  :GrammarousCheck --help<CR>
    an 720.10  🔠&-.Proofreading <Nop>
    an disable 🔠&-.Proofreading
    am 720.10  🔠&-.Proofread.Weak\ (first\ draft)<Tab>:Wordy\ weak             :Wordy weak<CR>
    am 720.10  🔠&-.Proofread.Redundant<Tab>:Wordy\ redundant                   :Wordy redundant<CR>
    am 720.10  🔠&-.Proofread.Problematic<Tab>:Wordy\ problematic               :Wordy problematic<CR>
    am 720.10  🔠&-.Proofread.Puffery<Tab>:Wordy\ puffery                       :Wordy puffery<CR>
    am 720.10  🔠&-.Proofread.Business\ Jargon<Tab>:Wordy\ business-jargon      :Wordy business-jargon<CR>
    am 720.10  🔠&-.Proofread.Art\ Jargon<Tab>:Wordy\ art-jargon                :Wordy art-jargon<CR>
    am 720.10  🔠&-.Proofread.Manipulative\ Language<Tab>:Wordy\ weasel         :Wordy weasel<CR>
    am 720.10  🔠&-.Proofread.Verb\ 'to\ be'<Tab>:Wordy\ being                  :Wordy being<CR>
    am 720.10  🔠&-.Proofread.Passive\ Voice<Tab>:Wordy\ passive-voice          :Wordy passive-voice<CR>
    am 720.10  🔠&-.Proofread.Colloquialisms<Tab>:Wordy\ colloquial             :Wordy colloquial<CR>
    am 720.10  🔠&-.Proofread.Idioms<Tab>:Wordy\ idiomatic                      :Wordy idiomatic<CR>
    am 720.10  🔠&-.Proofread.Similies<Tab>:Wordy\ similies                     :Wordy similies<CR>
    am 720.10  🔠&-.Proofread.Adjectives<Tab>:Wordy\ adjectives                 :Wordy adjectives<CR>
    am 720.10  🔠&-.Proofread.Adverbs<Tab>:Wordy\ adverbs                       :Wordy adverbs<CR>
    am 720.10  🔠&-.Proofread.'said'<Tab>:Wordy\ said-synonyms                  :Wordy said-synonyms<CR>
    am 720.10  🔠&-.Proofread.Editorializing<Tab>:Wordy\ opinion                :Wordy opinion<CR>
    am 720.10  🔠&-.Proofread.Contractions<Tab>:Wordy\ contractions             :Wordy contractions<CR>
    am 720.10  🔠&-.Proofread.Vague\ Time<Tab>:Wordy\ vague-time                :Wordy vague-time<CR>
    am 720.10  🔠&-.Proofread.Disable<Tab>:NoWordy                              :NoWordy<CR>
    an 720.10  🔠&-.Translation <Nop>
    an disable 🔠&-.Translation
    am 720.10  🔠&-.Translate.Translate<Tab>:TranslateW                         :TranslateW
    am 720.10  🔠&-.Translate.Set\ Source\ Language                             :TODO
    am 720.10  🔠&-.Translate.Set\ Target\ Language                             :TODO

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
