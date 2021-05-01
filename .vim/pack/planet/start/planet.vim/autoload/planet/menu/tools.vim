scriptversion 4

func! planet#menu#tools#update() abort
  if g:PlanetVim_menus_tools
    " Git
    " Open Log in new window
    an 700.10  🔀&,.Git <Nop>
    an disable 🔀&,.Git
    an 700.10  🔀&,.&Status                                       :call planet#term#RunCmd('git status --short --branch --show-stash --untracked-files=all')<CR>
    an 700.10  🔀&,.--1-- <Nop>
    an 700.10  🔀&,.&Fetch                                        :call planet#term#RunCmd('git fetch --all --tags')<CR>
    an 700.10  🔀&,.P&ull                                         :call planet#term#RunCmd('git pull --ff-only --all')<CR>
    an 700.10  🔀&,.&Push                                         :call planet#term#RunCmd('git push')<CR>
    an 700.10  🔀&,.&Add.This\ &File                              :call planet#term#RunCmd('git add ' .. expand('%'))<CR>
    an 700.10  🔀&,.&Add.Current\ &Directory                      :call planet#term#RunCmd('git add .')<CR>
    an 700.10  🔀&,.&Add.&All                                     :call planet#term#RunCmd('git add --update')<CR>
    an 700.10  🔀&,.&Add.All\ with\ &Untracked                    :call planet#term#RunCmd('git add --all')<CR>
    an 700.10  🔀&,.&Add.&Interactive                             :call planet#term#RunCmd('git add --interactive')<CR>
    an 700.10  🔀&,.&Add.&Patch                                   :call planet#term#RunCmd('git add --patch')<CR>
    an 700.10  🔀&,.&Add.&Move                                    :TODO
    an 700.10  🔀&,.&Add.&Remove                                  :TODO
    an 700.10  🔀&,.&Add.&Restore                                 :TODO
    an 700.10  🔀&,.&Commit.&Commit                               :call planet#git#Commit(v:false, v:false, v:false)<CR>
    an 700.10  🔀&,.&Commit.Commit\ &Tool                         :call planet#term#RunCmdBg('git commit')<CR>
    an 700.10  🔀&,.&Commit.Commit\ &File                         :call planet#git#CommitFile(v:false, v:false)<CR>
    an 700.10  🔀&,.&Commit.Save\ &&\ Commit\ File                :call planet#git#CommitFile(v:true, v:false)<CR>
    an 700.10  🔀&,.&Commit.Commit\ &All                          :TODO
    an 700.10  🔀&,.&Commit.Commit\ All\ with\ Untracked          :TODO
    "TODO: commit with default editor
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
    an 700.10  🔀&,.&Log.Log\ (GUI)                               :call planet#term#RunCmdGui('Flog -max-count=1000')<CR>
    an 700.10  🔀&,.&Log.Log\ All\ (GUI)                          :call planet#term#RunCmdGui('Flog -max-count=1000 -all')<CR>
    " an 700.10  🔀&,.&Log.Log\ (GUI)                               :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +'Flog -max-count=1000' +tabo<CR>
    " an 700.10  🔀&,.&Log.Log\ All\ (GUI)                          :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +'Flog -max-count=1000 -all' +tabo<CR>
    an 700.10  🔀&,.&Tag.List                                     :call planet#term#RunCmd('git tag -l')<CR>
    an 700.10  🔀&,.&Tag.Add                                      :TODO
    an 700.10  🔀&,.&Tag.Delete                                   :TODO
    an 700.10  🔀&,.&Merge.Fast-Forward\ Only                     :TODO
    an 700.10  🔀&,.&Merge.Non\ Fast-Forward\ Only                :TODO
    an 700.10  🔀&,.Rebase.On\ Default\ Branch                    :TODO
    an 700.10  🔀&,.Reflog.List                                   :call planet#term#RunCmd('git reflog')<CR>
    an 700.10  🔀&,.Reset.Soft                                    :call planet#term#RunCmd('git reset --soft HEAD~1')<CR>
    an 700.10  🔀&,.Reset.Reset                                   :call planet#term#RunCmd('git reset HEAD~1')<CR>
    an 700.10  🔀&,.Reset.Hard                                    :call planet#term#RunCmd('git reset --hard HEAD~1')<CR>
    an 700.10  🔀&,.Stash\ (&j).Stash                             :call planet#term#RunCmd('git stash')<CR>
    an 700.10  🔀&,.Stash\ (&j).List                              :call planet#term#RunCmd('git stash list')<CR>
    an 700.10  🔀&,.Stash\ (&j).Show                              :call planet#term#RunCmd('git stash show')<CR>
    an 700.10  🔀&,.Stash\ (&j).Pop                               :call planet#term#RunCmd('git stash pop')<CR>
    an 700.10  🔀&,.Stash\ (&j).Apply                             :call planet#term#RunCmd('git stash apply')<CR>
    an 700.10  🔀&,.Stash\ (&j).Branch                            :call planet#term#RunCmd('git stash branch')<CR>
    an 700.10  🔀&,.Stash\ (&j).Drop                              :call planet#term#RunCmd('git stash drop')<CR>
    an 700.10  🔀&,.Stash\ (&j).Clear                             :call planet#term#RunCmd('git stash clear')<CR>
    an 700.10  🔀&,.Notes.List                                    :TODO
    an 700.10  🔀&,.Notes.Add                                     :TODO
    an 700.10  🔀&,.Notes.Copy                                    :TODO
    an 700.10  🔀&,.Notes.Append                                  :TODO
    an 700.10  🔀&,.Notes.Edit                                    :TODO
    an 700.10  🔀&,.Notes.Show                                    :TODO
    an 700.10  🔀&,.Notes.Merge                                   :TODO
    an 700.10  🔀&,.Notes.Remove                                  :TODO
    an 700.10  🔀&,.Notes.Prune                                   :TODO
    an 700.10  🔀&,.Notes.Get-Ref                                 :TODO
    an 700.10  🔀&,.Notes.Enable\ Push                            :TODO
    an 700.10  🔀&,.&Branch.List\ Local                           :call planet#term#RunCmd('git --no-pager branch')<CR>
    an 700.10  🔀&,.&Branch.List\ All                             :call planet#term#RunCmd('git --no-pager branch --all')<CR>
    an 700.10  🔀&,.&Branch.List\ Remote\ (Local)                 :call planet#term#RunCmd('git --no-pager branch --remote')<CR>
    an 700.10  🔀&,.&Branch.List\ Remote\ (Remote)                :call planet#term#RunCmd('git --no-pager ls-remote')<CR>
    an 700.10  🔀&,.&Branch.Checkout                              :TODO
    an 700.10  🔀&,.&Branch.Rename                                :call planet#git#BranchRename()<CR>
    an 700.10  🔀&,.&Branch.Delete                                :call planet#git#BranchDelete()<CR>
    an 700.10  🔀&,.&Diff.&Diff                                   :call planet#term#RunCmd('git --no-pager diff')<CR>
    an 700.10  🔀&,.&Diff.&Stat                                   :call planet#term#RunCmd('git --no-pager diff --stat')<CR>
    an 700.10  🔀&,.&Diff.&Cached\ (Index)                        :call planet#term#RunCmd('git --no-pager diff --staged')<CR>
    an 700.10  🔀&,.&Diff.Stat\ Cached                            :call planet#term#RunCmd('git --no-pager diff --staged --stat')<CR>
    an 700.10  🔀&,.Cherry-pick.TODO                              :TODO
    an 700.10  🔀&,.&Worktree.New                                 :call planet#term#RunCmd('git worktree add')<CR>
    an 700.10  🔀&,.&Worktree.New\ Detached                       :call planet#term#RunCmd('git worktree add --detach')<CR>
    an 700.10  🔀&,.&Worktree.List                                :call planet#term#RunCmd('git worktree list')<CR>
    an 700.10  🔀&,.&Worktree.Lock                                :call planet#term#RunCmd('git worktree lock')<CR>
    an 700.10  🔀&,.&Worktree.Unlock                              :call planet#term#RunCmd('git worktree unlock')<CR>
    an 700.10  🔀&,.&Worktree.Move                                :call planet#term#RunCmd('git worktree move')<CR>
    an 700.10  🔀&,.&Worktree.Remove                              :call planet#term#RunCmd('git worktree remove')<CR>
    an 700.10  🔀&,.&Worktree.Prune                               :call planet#term#RunCmd('git worktree prune')<CR>
    an 700.10  🔀&,.&Worktree.Repair                              :call planet#term#RunCmd('git worktree repair')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Pull                            :call planet#git#SubrepoPull()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Pull\ All                       :call planet#term#RunCmd('git subrepo pull --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Push                            :call planet#git#SubrepoPush()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Push\ All                       :call planet#term#RunCmd('git subrepo push --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Fetth                           :call planet#git#SubrepoFetch()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Fetch\ All                      :call planet#term#RunCmd('git subrepo fetch --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Branch                          :call planet#git#SubrepoBranch()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Branch\ All                     :call planet#term#RunCmd('git subrepo branch --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Commit                          :call planet#git#SubrepoCommit()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Status                          :call planet#git#SubrepoStatus()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Status\ All                     :call planet#term#RunCmd('git subrepo status --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Status\ All\ Recursively        :call planet#term#RunCmd('git subrepo status --ALL')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clean                           :call planet#git#SubrepoClean()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clean\ All                      :call planet#term#RunCmd('git subrepo clean --all')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clean\ All\ Recursively         :call planet#term#RunCmd('git subrepo clean --ALL')<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Config                          :call planet#git#SubrepoConfig()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Clone                           :call planet#git#SubrepoClone()<CR>
    an 700.10  🔀&,.Subrepo\ (&x).Init                            :call planet#git#SubrepoInit()<CR>
    an 700.10  🔀&,.Submodule.TODO                                :TODO
    an 700.10  🔀&,.Remote.List                                   :call planet#term#RunCmd('git remote -a')<CR>
    an 700.10  🔀&,.&Gui.Git&k\ All                               :silent !nohup gitk --all >/dev/null 2>&1 &<CR>
    an 700.10  🔀&,.&Gui.Gitk\ &HEAD                              :silent !nohup gitk >/dev/null 2>&1 &<CR>
    an 700.10  🔀&,.&Gui.Gui                                      :silent !nohup git citool >/dev/null 2>&1 &<CR>
    an 700.10  🔀&,.&Gui.Gui&tar                                  :silent !nohup guitar >/dev/null 2>&1 &<CR>
    an 700.10  🔀&,.&Gui.&Gitg                                    :silent !nohup gitg >/dev/null 2>&1 &<CR>
    an 700.10  🔀&,.Ui.Git&ui                                     :tab call planet#term#RunCmd('gitui')<CR>
    an 700.10  🔀&,.--5-- <Nop>
    an 700.10  🔀&,.Cl&one                                        :TODO
    an 700.10  🔀&,.&Init                                         :call planet#term#RunCmd('git init')<CR>
    an 700.10  🔀&,.--7-- <Nop>
    an 700.10  🔀&,.LFS                                           :TODO
    an 700.10  🔀&,.Blame                                         :TODO
    an 700.10  🔀&,.Bisect                                        :TODO
    an 700.10  🔀&,.Patch.Am                                      :TODO
    an 700.10  🔀&,.Patch.Format-Patch                            :TODO
    an 700.10  🔀&,.Advanced.Archive                              :TODO
    an 700.10  🔀&,.Advanced.Bundle                               :TODO
    an 700.10  🔀&,.Advanced.Clean                                :TODO
    an 700.10  🔀&,.Maintenance.Gc                                :TODO
    an 700.10  🔀&,.Maintenance.Maintenance                       :TODO
    an 700.10  🔀&,.Advanced.Grep                                 :TODO
    an 700.10  🔀&,.Advanced.Switch                               :TODO
    an 700.10  🔀&,.Advanced.Hooks                                :TODO
    an 700.10  🔀&,.Advanced.Range\ Diff                          :TODO
    an 700.10  🔀&,.Advanced.Revert                               :TODO
    an 700.10  🔀&,.Advanced.Shortlog                             :TODO
    an 700.10  🔀&,.Advanced.Show                                 :TODO
    an 700.10  🔀&,.Advanced.Subtree                              :TODO
    an 700.10  🔀&,.Advanced.Config                               :TODO
    an 700.10  🔀&,.Advanced.Describe                             :TODO
    an 700.10  🔀&,.Advanced.Filter-Branch                        :TODO
    an 700.10  🔀&,.Maintenance.Pack-Refs                         :TODO
    an 700.10  🔀&,.Maintenance.Prune                             :TODO
    an 700.10  🔀&,.Maintenance.Repack                            :TODO
    an 700.10  🔀&,.Advanced.Rerere                               :TODO
    an 700.10  🔀&,.Advanced.Bugreport                            :TODO
    an 700.10  🔀&,.Advanced.Replace                              :TODO
    an 700.10  🔀&,.Advanced.Annotate                             :TODO
    an 700.10  🔀&,.Advanced.Cherry                               :TODO
    an 700.10  🔀&,.Maintenance.Count-Objects                     :TODO
    an 700.10  🔀&,.Maintenance.Fsck                              :TODO
    an 700.10  🔀&,.Advanced.Help                                 :TODO
    an 700.10  🔀&,.Advanced.Instaweb                             :TODO
    an 700.10  🔀&,.Advanced.Merge-Tree                           :TODO
    an 700.10  🔀&,.Advanced.Rev\ Parse                           :TODO
    an 700.10  🔀&,.Advanced.Show-Branch                          :TODO
    an 700.10  🔀&,.Advanced.Verify-Commit                        :TODO
    an 700.10  🔀&,.Advanced.Verify-Tag                           :TODO
    an 700.10  🔀&,.Advanced.Whatchanged                          :TODO
    an 700.10  🔀&,.Patch.Imap-Send                               :TODO
    an 700.10  🔀&,.Patch.Quiltimport                             :TODO
    an 700.10  🔀&,.Advanced.Request-Pull                         :TODO
    an 700.10  🔀&,.Patch.Send-Email                              :TODO
    an 700.10  🔀&,.Patch.Apply                                   :TODO
    an 700.10  🔀&,.Advanced.Checkout-Index                       :TODO
    an 700.10  🔀&,.Advanced.Commit-Graph                         :TODO
    an 700.10  🔀&,.Advanced.Commit-Tree                          :TODO
    an 700.10  🔀&,.Advanced.Hash-Object                          :TODO
    an 700.10  🔀&,.Maintenance.Index-Pack                           :TODO
    an 700.10  🔀&,.Advanced.Merge-File                           :TODO
    an 700.10  🔀&,.Advanced.Mktag                                :TODO
    an 700.10  🔀&,.Advanced.Mktree                               :TODO
    an 700.10  🔀&,.Maintenance.Multi-Pack-Index                     :TODO
    an 700.10  🔀&,.Maintenance.Pack-Objects                         :TODO
    an 700.10  🔀&,.Maintenance.Prune-Packed                         :TODO
    an 700.10  🔀&,.Advanced.Read-Tree                            :TODO
    an 700.10  🔀&,.Advanced.Symbolic-Ref                         :TODO
    an 700.10  🔀&,.Maintenance.Unpack-Objects                       :TODO
    an 700.10  🔀&,.Advanced.Update-Index                         :TODO
    an 700.10  🔀&,.Advanced.Update-Ref                           :TODO
    an 700.10  🔀&,.Advanced.Write-Tree                           :TODO
    an 700.10  🔀&,.Advanced.Cat-File                             :TODO
    an 700.10  🔀&,.Advanced.Diff-Files                           :TODO
    an 700.10  🔀&,.Advanced.Diff-Index                           :TODO
    an 700.10  🔀&,.Advanced.Diff-Tree                            :TODO
    an 700.10  🔀&,.Advanced.For-Each-Ref                         :TODO
    an 700.10  🔀&,.Advanced.For-Each-Repo                        :TODO
    an 700.10  🔀&,.Advanced.Get-Tar-Commit-Id                    :TODO
    an 700.10  🔀&,.Advanced.Ls-Files                             :TODO
    an 700.10  🔀&,.Advanced.Ls-Remote                            :TODO
    an 700.10  🔀&,.Advanced.Ls-Tree                              :TODO
    an 700.10  🔀&,.Advanced.Merge-Base                           :TODO
    an 700.10  🔀&,.Advanced.Name-Rev                             :TODO
    an 700.10  🔀&,.Maintenance.Pack-Redundant                    :TODO
    an 700.10  🔀&,.Advanced.Rev-List                             :TODO
    an 700.10  🔀&,.Advanced.Rev-Parse                            :TODO
    an 700.10  🔀&,.Advanced.Show-Index                           :TODO
    an 700.10  🔀&,.Advanced.Show-Ref                             :TODO
    an 700.10  🔀&,.Maintenance.Unpack-File                       :TODO
    an 700.10  🔀&,.Advanced.Var                                  :TODO
    an 700.10  🔀&,.Maintenance.Verify-Pack                       :TODO
    an 700.10  🔀&,.Contrib.Contacts                              :TODO
    an 700.10  🔀&,.Contrib.Workdir                               :TODO
    an 700.10  🔀&,.Contrib.Resurrect                             :TODO
    an 700.10  🔀&,.Contrib.Rerere\ Train                         :TODO
    an 700.10  🔀&,.Other\ VCS.Fast-Export                        :TODO
    an 700.10  🔀&,.Other\ VCS.Fast-Import                        :TODO
    an 700.10  🔀&,.Other\ VCS.Arch                               :TODO
    an 700.10  🔀&,.Other\ VCS.CVS                                :TODO
    an 700.10  🔀&,.Other\ VCS.SVN                                :TODO
    an 700.10  🔀&,.Other\ VCS.P4                                 :TODO
    an 700.10  🔀&,.Other\ VCS.Mercurial                          :TODO
    an 700.10  🔀&,.Experimental.Sparse-Checkout.Init             :TODO
    an 700.10  🔀&,.Extras.Alias                                  :TODO
    an 700.10  🔀&,.Extras.Archive-File                           :TODO
    an 700.10  🔀&,.Extras.Authors                                :TODO
    an 700.10  🔀&,.Extras.Browse                                 :TODO
    an 700.10  🔀&,.Extras.Brv                                    :TODO
    an 700.10  🔀&,.Extras.Bulk                                   :TODO
    an 700.10  🔀&,.Extras.Changelog                              :TODO
    an 700.10  🔀&,.Extras.Clear                                  :TODO
    an 700.10  🔀&,.Extras.Clear-Soft                             :TODO
    an 700.10  🔀&,.Extras.Coauthor                               :TODO
    an 700.10  🔀&,.Extras.Commits-Since                          :TODO
    an 700.10  🔀&,.Extras.Contrib                                :TODO
    an 700.10  🔀&,.Extras.Count                                  :TODO
    an 700.10  🔀&,.Extras.Cp                                     :TODO
    an 700.10  🔀&,.Extras.Create-Branch                          :TODO
    an 700.10  🔀&,.Extras.Delete-Branch                          :TODO
    an 700.10  🔀&,.Extras.Delete-Merged-Branches                 :TODO
    an 700.10  🔀&,.Extras.Delete-Submodule                       :TODO
    an 700.10  🔀&,.Extras.Delete-Tag                             :TODO
    an 700.10  🔀&,.Extras.Delta                                  :TODO
    an 700.10  🔀&,.Extras.Effort                                 :TODO
    an 700.10  🔀&,.Extras.Extras                                 :TODO
    an 700.10  🔀&,.Extras.Feature                                :TODO
    an 700.10  🔀&,.Extras.Force-Clone                            :TODO
    an 700.10  🔀&,.Extras.Fork                                   :TODO
    an 700.10  🔀&,.Extras.Fresh-Branch                           :TODO
    an 700.10  🔀&,.Extras.Gh-Pages                               :TODO
    an 700.10  🔀&,.Extras.Graft                                  :TODO
    an 700.10  🔀&,.Extras.Guilt                                  :TODO
    an 700.10  🔀&,.Extras.Ignore                                 :TODO
    an 700.10  🔀&,.Extras.Ignore-Io                              :TODO
    an 700.10  🔀&,.Extras.Info                                   :TODO
    an 700.10  🔀&,.Extras.Local-Commits                          :TODO
    an 700.10  🔀&,.Extras.Lock                                   :TODO
    an 700.10  🔀&,.Extras.Locked                                 :TODO
    an 700.10  🔀&,.Extras.Merge-Into                             :TODO
    an 700.10  🔀&,.Extras.Merge-Repo                             :TODO
    an 700.10  🔀&,.Extras.Missing                                :TODO
    an 700.10  🔀&,.Extras.Mr                                     :TODO
    an 700.10  🔀&,.Extras.Obliterate                             :TODO
    an 700.10  🔀&,.Extras.Paste                                  :TODO
    an 700.10  🔀&,.Extras.Pr                                     :TODO
    an 700.10  🔀&,.Extras.Psykorebase                            :TODO
    an 700.10  🔀&,.Extras.Pull-Request                           :TODO
    an 700.10  🔀&,.Extras.Reauthor                               :TODO
    an 700.10  🔀&,.Extras.Rebase-Patch                           :TODO
    an 700.10  🔀&,.Extras.Release                                :TODO
    an 700.10  🔀&,.Extras.Rename-Branch                          :TODO
    an 700.10  🔀&,.Extras.Rename-Tag                             :TODO
    an 700.10  🔀&,.Extras.Repl                                   :TODO
    an 700.10  🔀&,.Extras.Reset-File                             :TODO
    an 700.10  🔀&,.Extras.Root                                   :TODO
    an 700.10  🔀&,.Extras.Rscp                                   :TODO
    an 700.10  🔀&,.Extras.Scp                                    :TODO
    an 700.10  🔀&,.Extras.Sed                                    :TODO
    an 700.10  🔀&,.Extras.Setup                                  :TODO
    an 700.10  🔀&,.Extras.Show-Merged-Branches                   :TODO
    an 700.10  🔀&,.Extras.Show-Tree                              :TODO
    an 700.10  🔀&,.Extras.Show-Unmerged-Branches                 :TODO
    an 700.10  🔀&,.Extras.Squash                                 :TODO
    an 700.10  🔀&,.Extras.Stamp                                  :TODO
    an 700.10  🔀&,.Extras.Standup                                :TODO
    an 700.10  🔀&,.Extras.Summary                                :TODO
    an 700.10  🔀&,.Extras.Sync                                   :TODO
    an 700.10  🔀&,.Extras.Touch                                  :TODO
    an 700.10  🔀&,.Extras.Undo                                   :TODO
    an 700.10  🔀&,.Extras.Unlock                                 :TODO
    an 700.10  🔀&,.Extras.Utimes                                 :TODO
    an 700.10  🔀&,.Flow.TODO                                     :TODO
    an 700.10  🔀&,.Extra\ Commands.TODO                          :TODO

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
    am 720.10  🔠&-.Abbreviations.Enable\ AutoCorrect\ Common\ Typos            :TODO

    " Tools
    " TODO: add all '*.prg' options, eg: equalprg, keywordprg, etc.
    an 730.10  🔧&o.Tools <Nop>
    an disable 🔧&o.Tools
    an 730.10  🔧&o.Colori&ze                                 :ColorToggle<CR>
    an 730.10  🔧&o.--1-- <Nop>
    an 730.10  🔧&o.Start\ Local\ Python\ http\.server\ Here  :call planet#term#RunCmd('python3 -m http.server 8080')<CR>
    an 730.10  🔧&o.Start\ Public\ ngrok\ Server              :call planet#term#RunCmd('ngrok http 3000')<CR>
    an 730.10  🔧&o.--2-- <Nop>
    an 730.10  🔧&o.Edit\ Command<Tab>:                       q:
    an 730.10  🔧&o.Edit\ Search<Tab>q/                       q/
    an 730.10  🔧&o.Edit\ Search\ Backwards<Tab>q?            q?
    an 730.10  🔧&o.--3-- <Nop>
    an 730.10  🔧&o.Convert\ to\ HEX<Tab>:%!xxd             :call <SID>XxdToHex()<CR>
    an 730.10  🔧&o.Convert\ from\ HEX<Tab>:%!xxd\ -r       :call <SID>XxdFromHex()<CR>
    an 730.10  🔧&o.--4-- <Nop>
    an 730.10  🔧&o.Serial\ Monitor\ (picocom)              :call planet#term#run_command_output('picocom -b 115200 /dev/ttyUSB0')<CR>
    an 730.10  🔧&o.Multipurpose\ Relay\ (socat)            :call planet#term#run_command_output('socat ...TODO')<CR>
    an 730.10  🔧&o.--5-- <Nop>
    an 730.10  🔧&o.Make\ dd\ print\ progress               :call planet#term#RunScript('TODO...print progress of all dd')
    "TODO: add websocat
    "TODO: add nmap
  else
    silent! aunmenu 🔀&,
    silent! aunmenu ⛏️&;
    silent! aunmenu 🔤&-
    silent! aunmenu 🔧&o
  endif
endfunc
