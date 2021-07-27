scriptversion 4

func! planet#menu#tools#Update() abort
  if g:PlanetVim_menus_tools
    " Git
    " Open Log in new window
    an 700.10  🔀&g.Git <Nop>
    an disable 🔀&g.Git
    an 700.10  🔀&g.&Status                                       <Cmd>call planet#term#RunCmd('git status --short --branch --show-stash --untracked-files=all')<CR>
    an 700.10  🔀&g.&Fetch                                        <Cmd>call planet#term#RunCmd('git fetch')<CR>
    an 700.10  🔀&g.P&ull                                         <Cmd>call planet#term#RunCmd('git pull --ff-only')<CR>
    an 700.10  🔀&g.&Push                                         <Cmd>call planet#term#RunCmd('git push')<CR>
    an 700.10  🔀&g.Summar&y                                      <Cmd>tab Gstatus<CR>
    an 700.10  🔀&g.&Add.This\ &File                              <Cmd>call planet#term#RunCmd('git add ' .. expand('%'))<CR>
    an 700.10  🔀&g.&Add.Current\ &Directory                      <Cmd>call planet#term#RunCmd('git add .')<CR>
    an 700.10  🔀&g.&Add.&All                                     <Cmd>call planet#term#RunCmd('git add --update')<CR>
    an 700.10  🔀&g.&Add.All\ with\ &Untracked                    <Cmd>call planet#term#RunCmd('git add --all')<CR>
    an 700.10  🔀&g.&Add.&Interactively                           <Cmd>tab Gstatus<CR>
    an 700.10  🔀&g.&Add.&Interactive                             <Cmd>call planet#term#RunCmdTab('git add --interactive')<CR>
    an 700.10  🔀&g.&Add.&Patch                                   <Cmd>call planet#term#RunCmdTab('git add --patch')<CR>
    an 700.10  🔀&g.&Add.&Move                                    :TODO
    an 700.10  🔀&g.&Add.&Remove                                  :TODO
    an 700.10  🔀&g.&Add.&Restore                                 :TODO
    an 700.10  🔀&g.&Commit.&Commit                               <Cmd>call planet#git#Commit(v:false, v:false, v:false)<CR>
    an 700.10  🔀&g.&Commit.Commit\ &File                         <Cmd>call planet#git#CommitFile(v:false, v:false)<CR>
    an 700.10  🔀&g.&Commit.Commit\ &Tool                         <Cmd>call planet#term#RunCmdBg('git commit')<CR>
    an 700.10  🔀&g.&Commit.Save\ &&\ Commit\ File                <Cmd>call planet#git#CommitFile(v:true, v:false)<CR>
    an 700.10  🔀&g.&Commit.Commit\ &All                          <Cmd>call planet#term#RunCmdAskArgs('git commit -a -m ', 'Commit message:', '')<CR>
    an 700.10  🔀&g.&Commit.Commit\ All\ with\ Untracked          <Cmd>call planet#term#RunCmdAskArgs('git add --all && git commit -m ', 'Commit message:', '')<CR>
    an 700.10  🔀&g.&Commit.Amend\ Last\ Commit                   <Cmd>call planet#term#RunCmdBg('git commit --amend')<CR>
    an 700.10  🔀&g.&Commit.--2-- <Nop>
    an 700.10  🔀&g.&Commit.AutoCommit\ File                      <Cmd>call planet#git#CommitFile(v:false)<CR>
    an 700.10  🔀&g.&Commit.Save\ &&\ AutoCommit\ File            <Cmd>call planet#git#CommitFile()<CR>
    an 700.10  🔀&g.&Commit.AutoCommit\ File\ &&\ Push            <Cmd>call planet#git#CommitFile(v:false, v:true, v:true)<CR>
    an 700.10  🔀&g.&Commit.Save\ &&\ AutoCommit\ File\ &&\ Push  <Cmd>call planet#git#CommitFile(v:true, v:true, v:true)<CR>
    an 700.10  🔀&g.&Commit.AutoCommit                            <Cmd>call planet#git#Commit(v:false)<CR>
    an 700.10  🔀&g.&Commit.Save\ All\ &&\ AutoCommit             <Cmd>call planet#git#Commit()<CR>
    an 700.10  🔀&g.&Commit.AutoCommit\ &&\ Push                  <Cmd>call planet#git#Commit(v:false, v:true, v:true)<CR>
    an 700.10  🔀&g.&Commit.Save\ All\ &&\ AutoCommit\ &&\ Push   <Cmd>call planet#git#Commit(v:true, v:true, v:true)<CR>
    an 700.10  🔀&g.&Commit.--3-- <Nop>
    an 700.10  🔀&g.&Commit.Enable\ AutoCommit\ on\ File\ Write   <Cmd>call planet#git#EnableAutoCommit()<CR>
    an 700.10  🔀&g.&Commit.Disable\ AutoCommit\ on\ File\ Write  <Cmd>call planet#git#DisableAutoCommit()<CR>
    an 700.10  🔀&g.Ch&eckout.&Branch                             <Cmd>call planet#git#CheckoutBranch()<CR>
    an 700.10  🔀&g.Ch&eckout.&File                               <Cmd>call planet#git#CheckoutFile()<CR>
    an 700.10  🔀&g.Fetch\ .Tags                                  <Cmd>call planet#term#RunCmd('git fetch --tags')<CR>
    an 700.10  🔀&g.Fetch\ .All                                   <Cmd>call planet#term#RunCmd('git fetch --all')<CR>
    an 700.10  🔀&g.Fetch\ .Prune                                 <Cmd>call planet#term#RunCmd('git fetch --prune')<CR>
    an 700.10  🔀&g.Fetch\ .From\ Default\ Remote                 <Cmd>call planet#term#RunCmd('git fetch')<CR>
    an 700.10  🔀&g.Fetch\ .From\ Specified\ Remote               <Cmd>call planet#git#FetchCustomRemote()<CR>
    an 700.10  🔀&g.Pull\ .Custom\ Ref/Repo                       <Cmd>call planet#term#RunCmdAskArgs('git pull', 'git pull: ')<CR>
    an 700.10  🔀&g.Push\ .To\ Custom \Remote/Branch              <Cmd>call planet#term#RunCmdAskArgs('git push', 'git push: ')<CR>
    an 700.10  🔀&g.&Log.&Log\ (QF)                               :Gclog!<CR>
    an 700.10  🔀&g.&Log.Log\ (LL)                                :Gllog!<CR>
    an 700.10  🔀&g.&Log.File\ (QF)                               :0Gclog!<CR>
    an 700.10  🔀&g.&Log.&File\ (LL)                              :0Gllog!<CR>
    an 700.10  🔀&g.&Log.Log\ (GUI)                               <Cmd>call planet#term#RunCmdGui('Flog -max-count=1000')<CR>
    an 700.10  🔀&g.&Log.Log\ All\ (GUI)                          <Cmd>call planet#term#RunCmdGui('Flog -max-count=1000 -all')<CR>
    " an 700.10  🔀&g.&Log.Log\ (GUI)                               :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +'Flog -max-count=1000' +tabo<CR>
    " an 700.10  🔀&g.&Log.Log\ All\ (GUI)                          :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +'Flog -max-count=1000 -all' +tabo<CR>
    an 700.10  🔀&g.&Tag.List                                     <Cmd>call planet#term#RunCmd('git tag -l')<CR>
    an 700.10  🔀&g.&Tag.Add                                      :TODO
    an 700.10  🔀&g.&Tag.Delete                                   :TODO
    an 700.10  🔀&g.&Merge.Fast-Forward\ Only                     :TODO
    an 700.10  🔀&g.&Merge.Non\ Fast-Forward\ Only                :TODO
    an 700.10  🔀&g.Rebase.On\ Default\ Branch                    :TODO
    an 700.10  🔀&g.Stash\ (&j).Stash                             <Cmd>call planet#term#RunCmd('git stash')<CR>
    an 700.10  🔀&g.Stash\ (&j).List                              <Cmd>call planet#term#RunCmd('git stash list')<CR>
    an 700.10  🔀&g.Stash\ (&j).Show                              <Cmd>call planet#term#RunCmd('git stash show')<CR>
    an 700.10  🔀&g.Stash\ (&j).Pop                               <Cmd>call planet#term#RunCmd('git stash pop')<CR>
    an 700.10  🔀&g.Stash\ (&j).Apply                             <Cmd>call planet#term#RunCmd('git stash apply')<CR>
    an 700.10  🔀&g.Stash\ (&j).Branch                            <Cmd>call planet#term#RunCmd('git stash branch')<CR>
    an 700.10  🔀&g.Stash\ (&j).Drop                              <Cmd>call planet#term#RunCmd('git stash drop')<CR>
    an 700.10  🔀&g.Stash\ (&j).Clear                             <Cmd>call planet#term#RunCmd('git stash clear')<CR>
    an 700.10  🔀&g.Notes.List                                    :TODO
    an 700.10  🔀&g.Notes.Add                                     :TODO
    an 700.10  🔀&g.Notes.Copy                                    :TODO
    an 700.10  🔀&g.Notes.Append                                  :TODO
    an 700.10  🔀&g.Notes.Edit                                    :TODO
    an 700.10  🔀&g.Notes.Show                                    :TODO
    an 700.10  🔀&g.Notes.Merge                                   :TODO
    an 700.10  🔀&g.Notes.Remove                                  :TODO
    an 700.10  🔀&g.Notes.Prune                                   :TODO
    an 700.10  🔀&g.Notes.Get-Ref                                 :TODO
    an 700.10  🔀&g.Notes.Enable\ Push                            :TODO
    an 700.10  🔀&g.&Branch.List\ Local                           <Cmd>call planet#term#RunCmd('git --no-pager branch')<CR>
    an 700.10  🔀&g.&Branch.List\ All                             <Cmd>call planet#term#RunCmd('git --no-pager branch --all')<CR>
    an 700.10  🔀&g.&Branch.List\ Remote\ (Local)                 <Cmd>call planet#term#RunCmd('git --no-pager branch --remote')<CR>
    an 700.10  🔀&g.&Branch.List\ Remote\ (Remote)                <Cmd>call planet#term#RunCmd('git --no-pager ls-remote')<CR>
    an 700.10  🔀&g.&Branch.Checkout                              :TODO
    an 700.10  🔀&g.&Branch.Rename                                <Cmd>call planet#git#BranchRename()<CR>
    an 700.10  🔀&g.&Branch.Delete                                <Cmd>call planet#git#BranchDelete()<CR>
    an 700.10  🔀&g.&Diff.&Diff                                   <Cmd>call planet#term#RunCmdTab('git -c color.diff=always diff \| less -RX')<CR>
    an 700.10  🔀&g.&Diff.&Stat                                   <Cmd>call planet#term#RunCmdTab('git -c color.diff diff --stat \| less -RX')<CR>
    an 700.10  🔀&g.&Diff.&Cached\ (Index)                        <Cmd>call planet#term#RunCmdTab('git -c color.diff diff --staged \| less -RX')<CR>
    an 700.10  🔀&g.&Diff.Stat\ Cached                            <Cmd>call planet#term#RunCmdTab('git -c color.diff diff --staged --stat \| less -RX')<CR>
    an 700.10  🔀&g.&Worktree.New                                 <Cmd>call planet#term#RunCmd('git worktree add')<CR>
    an 700.10  🔀&g.&Worktree.New\ Detached                       <Cmd>call planet#term#RunCmd('git worktree add --detach')<CR>
    an 700.10  🔀&g.&Worktree.List                                <Cmd>call planet#term#RunCmd('git worktree list')<CR>
    an 700.10  🔀&g.&Worktree.Lock                                <Cmd>call planet#term#RunCmd('git worktree lock')<CR>
    an 700.10  🔀&g.&Worktree.Unlock                              <Cmd>call planet#term#RunCmd('git worktree unlock')<CR>
    an 700.10  🔀&g.&Worktree.Move                                <Cmd>call planet#term#RunCmd('git worktree move')<CR>
    an 700.10  🔀&g.&Worktree.Remove                              <Cmd>call planet#term#RunCmd('git worktree remove')<CR>
    an 700.10  🔀&g.&Worktree.Prune                               <Cmd>call planet#term#RunCmd('git worktree prune')<CR>
    an 700.10  🔀&g.&Worktree.Repair                              <Cmd>call planet#term#RunCmd('git worktree repair')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Pull                            <Cmd>call planet#git#SubrepoPull()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Pull\ All                       <Cmd>call planet#term#RunCmd('git subrepo pull --all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Push                            <Cmd>call planet#git#SubrepoPush()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Push\ All                       <Cmd>call planet#term#RunCmd('git subrepo push --all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Fetth                           <Cmd>call planet#git#SubrepoFetch()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Fetch\ All                      <Cmd>call planet#term#RunCmd('git subrepo fetch --all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Branch                          <Cmd>call planet#git#SubrepoBranch()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Branch\ All                     <Cmd>call planet#term#RunCmd('git subrepo branch --all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Commit                          <Cmd>call planet#git#SubrepoCommit()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Status                          <Cmd>call planet#git#SubrepoStatus()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Status\ All                     <Cmd>call planet#term#RunCmd('git subrepo status --all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Status\ All\ Recursively        <Cmd>call planet#term#RunCmd('git subrepo status --ALL')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clean                           <Cmd>call planet#git#SubrepoClean()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clean\ All                      <Cmd>call planet#term#RunCmd('git subrepo clean --all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clean\ All\ Recursively         <Cmd>call planet#term#RunCmd('git subrepo clean --ALL')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Config                          <Cmd>call planet#git#SubrepoConfig()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clone                           <Cmd>call planet#git#SubrepoClone()<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Init                            <Cmd>call planet#git#SubrepoInit()<CR>
    an 700.10  🔀&g.&Gui.Git&k\ All                               :silent !nohup gitk --all >/dev/null 2>&1 &<CR>
    an 700.10  🔀&g.&Gui.Gitk\ &HEAD                              :silent !nohup gitk >/dev/null 2>&1 &<CR>
    an 700.10  🔀&g.&Gui.Gui                                      :silent !nohup git citool >/dev/null 2>&1 &<CR>
    an 700.10  🔀&g.&Gui.Gui&tar                                  :silent !nohup guitar >/dev/null 2>&1 &<CR>
    an 700.10  🔀&g.&Gui.&Gitg                                    :silent !nohup gitg >/dev/null 2>&1 &<CR>
    an 700.10  🔀&g.Ui.Git&ui                                     <Cmd>call planet#term#RunCmdTab('gitui')<CR>
    an 700.10  🔀&g.LFS                                           :TODO
    an 700.10  🔀&g.New.Cl&one                                    <Cmd>call planet#git#Clone()<CR>
    an 700.10  🔀&g.New.&Init                                     <Cmd>call planet#term#RunCmd('git init')<CR>
    an 700.10  🔀&g.Patch.Am                                      :TODO
    an 700.10  🔀&g.Patch.Format-Patch                            :TODO
    an 700.10  🔀&g.Patch.Imap-Send                               :TODO
    an 700.10  🔀&g.Patch.Quiltimport                             :TODO
    an 700.10  🔀&g.Patch.Send-Email                              :TODO
    an 700.10  🔀&g.Patch.Apply                                   :TODO
    an 700.10  🔀&g.Advanced.Request-Pull                         :TODO
    an 700.10  🔀&g.Advanced.Remote.List                          <Cmd>call planet#term#RunCmd('git remote -a')<CR>
    an 700.10  🔀&g.Advanced.Blame                                :TODO
    an 700.10  🔀&g.Advanced.Bisect                               :TODO
    an 700.10  🔀&g.Advanced.Submodule.TODO                       :TODO
    an 700.10  🔀&g.Advanced.Reflog.List                          <Cmd>call planet#term#RunCmd('git reflog')<CR>
    an 700.10  🔀&g.Advanced.Reset.Soft\ HEAD~1                   <Cmd>call planet#term#RunCmd('git reset --soft HEAD~1')<CR>
    an 700.10  🔀&g.Advanced.Reset.Reset\ HEAD~1                  <Cmd>call planet#term#RunCmd('git reset HEAD~1')<CR>
    an 700.10  🔀&g.Advanced.Reset.Hard\ HEAD~1                   <Cmd>call planet#term#RunCmd('git reset --hard HEAD~1')<CR>
    an 700.10  🔀&g.Advanced.Cherry-pick.TODO                     :TODO
    an 700.10  🔀&g.Advanced.Archive                              :TODO
    an 700.10  🔀&g.Advanced.Bundle                               :TODO
    an 700.10  🔀&g.Advanced.Clean                                :TODO
    an 700.10  🔀&g.Advanced.Grep                                 :TODO
    an 700.10  🔀&g.Advanced.Switch                               :TODO
    an 700.10  🔀&g.Advanced.Hooks                                :TODO
    an 700.10  🔀&g.Advanced.Range\ Diff                          :TODO
    an 700.10  🔀&g.Advanced.Revert                               :TODO
    an 700.10  🔀&g.Advanced.Shortlog                             :TODO
    an 700.10  🔀&g.Advanced.Show                                 :TODO
    an 700.10  🔀&g.Advanced.Subtree                              :TODO
    an 700.10  🔀&g.Advanced.Config                               :TODO
    an 700.10  🔀&g.Advanced.Describe                             :TODO
    an 700.10  🔀&g.Advanced.Filter-Branch                        :TODO
    an 700.10  🔀&g.Advanced.Rerere                               :TODO
    an 700.10  🔀&g.Advanced.Bugreport                            :TODO
    an 700.10  🔀&g.Advanced.Replace                              :TODO
    an 700.10  🔀&g.Advanced.Annotate                             :TODO
    an 700.10  🔀&g.Advanced.Cherry                               :TODO
    an 700.10  🔀&g.Advanced.Help                                 :TODO
    an 700.10  🔀&g.Advanced.Instaweb                             :TODO
    an 700.10  🔀&g.Advanced.Merge-Tree                           :TODO
    an 700.10  🔀&g.Advanced.Rev\ Parse                           :TODO
    an 700.10  🔀&g.Advanced.Show-Branch                          :TODO
    an 700.10  🔀&g.Advanced.Verify-Commit                        :TODO
    an 700.10  🔀&g.Advanced.Verify-Tag                           :TODO
    an 700.10  🔀&g.Advanced.Whatchanged                          :TODO
    an 700.10  🔀&g.Low\ Level.Checkout-Index                       :TODO
    an 700.10  🔀&g.Low\ Level.Commit-Graph                         :TODO
    an 700.10  🔀&g.Low\ Level.Commit-Tree                          :TODO
    an 700.10  🔀&g.Low\ Level.Hash-Object                          :TODO
    an 700.10  🔀&g.Low\ Level.Merge-File                           :TODO
    an 700.10  🔀&g.Low\ Level.Mktag                                :TODO
    an 700.10  🔀&g.Low\ Level.Mktree                               :TODO
    an 700.10  🔀&g.Low\ Level.Read-Tree                            :TODO
    an 700.10  🔀&g.Low\ Level.Symbolic-Ref                         :TODO
    an 700.10  🔀&g.Low\ Level.Update-Index                         :TODO
    an 700.10  🔀&g.Low\ Level.Update-Ref                           :TODO
    an 700.10  🔀&g.Low\ Level.Write-Tree                           :TODO
    an 700.10  🔀&g.Low\ Level.Cat-File                             :TODO
    an 700.10  🔀&g.Low\ Level.Diff-Files                           :TODO
    an 700.10  🔀&g.Low\ Level.Diff-Index                           :TODO
    an 700.10  🔀&g.Low\ Level.Diff-Tree                            :TODO
    an 700.10  🔀&g.Low\ Level.For-Each-Ref                         :TODO
    an 700.10  🔀&g.Low\ Level.For-Each-Repo                        :TODO
    an 700.10  🔀&g.Low\ Level.Get-Tar-Commit-Id                    :TODO
    an 700.10  🔀&g.Low\ Level.Ls-Files                             :TODO
    an 700.10  🔀&g.Low\ Level.Ls-Remote                            :TODO
    an 700.10  🔀&g.Low\ Level.Ls-Tree                              :TODO
    an 700.10  🔀&g.Low\ Level.Merge-Base                           :TODO
    an 700.10  🔀&g.Low\ Level.Name-Rev                             :TODO
    an 700.10  🔀&g.Low\ Level.Rev-List                             :TODO
    an 700.10  🔀&g.Low\ Level.Rev-Parse                            :TODO
    an 700.10  🔀&g.Low\ Level.Show-Index                           :TODO
    an 700.10  🔀&g.Low\ Level.Show-Ref                             :TODO
    an 700.10  🔀&g.Low\ Level.Var                                  :TODO
    an 700.10  🔀&g.Maintenance.Gc                                :TODO
    an 700.10  🔀&g.Maintenance.Maintenance                       :TODO
    an 700.10  🔀&g.Maintenance.Count-Objects                     :TODO
    an 700.10  🔀&g.Maintenance.Fsck                              :TODO
    an 700.10  🔀&g.Maintenance.Pack-Redundant                    :TODO
    an 700.10  🔀&g.Maintenance.Unpack-File                       :TODO
    an 700.10  🔀&g.Maintenance.Verify-Pack                       :TODO
    an 700.10  🔀&g.Maintenance.Unpack-Objects                    :TODO
    an 700.10  🔀&g.Maintenance.Multi-Pack-Index                  :TODO
    an 700.10  🔀&g.Maintenance.Pack-Objects                      :TODO
    an 700.10  🔀&g.Maintenance.Prune-Packed                      :TODO
    an 700.10  🔀&g.Maintenance.Index-Pack                        :TODO
    an 700.10  🔀&g.Maintenance.Pack-Refs                         :TODO
    an 700.10  🔀&g.Maintenance.Prune                             :TODO
    an 700.10  🔀&g.Maintenance.Repack                            :TODO
    an 700.10  🔀&g.Contrib.Contacts                              :TODO
    an 700.10  🔀&g.Contrib.Workdir                               :TODO
    an 700.10  🔀&g.Contrib.Resurrect                             :TODO
    an 700.10  🔀&g.Contrib.Rerere\ Train                         :TODO
    an 700.10  🔀&g.Other\ VCS.Fast-Export                        :TODO
    an 700.10  🔀&g.Other\ VCS.Fast-Import                        :TODO
    an 700.10  🔀&g.Other\ VCS.Arch                               :TODO
    an 700.10  🔀&g.Other\ VCS.CVS                                :TODO
    an 700.10  🔀&g.Other\ VCS.SVN                                :TODO
    an 700.10  🔀&g.Other\ VCS.P4                                 :TODO
    an 700.10  🔀&g.Other\ VCS.Mercurial                          :TODO
    an 700.10  🔀&g.Experimental.Sparse-Checkout.Init             :TODO
    an 700.10  🔀&g.Extras.Alias                                  :TODO
    an 700.10  🔀&g.Extras.Archive-File                           :TODO
    an 700.10  🔀&g.Extras.Authors                                :TODO
    an 700.10  🔀&g.Extras.Browse                                 :TODO
    an 700.10  🔀&g.Extras.Brv                                    :TODO
    an 700.10  🔀&g.Extras.Bulk                                   :TODO
    an 700.10  🔀&g.Extras.Changelog                              :TODO
    an 700.10  🔀&g.Extras.Clear                                  :TODO
    an 700.10  🔀&g.Extras.Clear-Soft                             :TODO
    an 700.10  🔀&g.Extras.Coauthor                               :TODO
    an 700.10  🔀&g.Extras.Commits-Since                          :TODO
    an 700.10  🔀&g.Extras.Contrib                                :TODO
    an 700.10  🔀&g.Extras.Count                                  :TODO
    an 700.10  🔀&g.Extras.Cp                                     :TODO
    an 700.10  🔀&g.Extras.Create-Branch                          :TODO
    an 700.10  🔀&g.Extras.Delete-Branch                          :TODO
    an 700.10  🔀&g.Extras.Delete-Merged-Branches                 :TODO
    an 700.10  🔀&g.Extras.Delete-Submodule                       :TODO
    an 700.10  🔀&g.Extras.Delete-Tag                             :TODO
    an 700.10  🔀&g.Extras.Delta                                  :TODO
    an 700.10  🔀&g.Extras.Effort                                 :TODO
    an 700.10  🔀&g.Extras.Extras                                 :TODO
    an 700.10  🔀&g.Extras.Feature                                :TODO
    an 700.10  🔀&g.Extras.Force-Clone                            :TODO
    an 700.10  🔀&g.Extras.Fork                                   :TODO
    an 700.10  🔀&g.Extras.Fresh-Branch                           :TODO
    an 700.10  🔀&g.Extras.Gh-Pages                               :TODO
    an 700.10  🔀&g.Extras.Graft                                  :TODO
    an 700.10  🔀&g.Extras.Guilt                                  :TODO
    an 700.10  🔀&g.Extras.Ignore                                 :TODO
    an 700.10  🔀&g.Extras.Ignore-Io                              :TODO
    an 700.10  🔀&g.Extras.Info                                   :TODO
    an 700.10  🔀&g.Extras.Local-Commits                          :TODO
    an 700.10  🔀&g.Extras.Lock                                   :TODO
    an 700.10  🔀&g.Extras.Locked                                 :TODO
    an 700.10  🔀&g.Extras.Merge-Into                             :TODO
    an 700.10  🔀&g.Extras.Merge-Repo                             :TODO
    an 700.10  🔀&g.Extras.Missing                                :TODO
    an 700.10  🔀&g.Extras.Mr                                     :TODO
    an 700.10  🔀&g.Extras.Obliterate                             :TODO
    an 700.10  🔀&g.Extras.Paste                                  :TODO
    an 700.10  🔀&g.Extras.Pr                                     :TODO
    an 700.10  🔀&g.Extras.Psykorebase                            :TODO
    an 700.10  🔀&g.Extras.Pull-Request                           :TODO
    an 700.10  🔀&g.Extras.Reauthor                               :TODO
    an 700.10  🔀&g.Extras.Rebase-Patch                           :TODO
    an 700.10  🔀&g.Extras.Release                                :TODO
    an 700.10  🔀&g.Extras.Rename-Branch                          :TODO
    an 700.10  🔀&g.Extras.Rename-Tag                             :TODO
    an 700.10  🔀&g.Extras.Repl                                   :TODO
    an 700.10  🔀&g.Extras.Reset-File                             :TODO
    an 700.10  🔀&g.Extras.Root                                   :TODO
    an 700.10  🔀&g.Extras.Rscp                                   :TODO
    an 700.10  🔀&g.Extras.Scp                                    :TODO
    an 700.10  🔀&g.Extras.Sed                                    :TODO
    an 700.10  🔀&g.Extras.Setup                                  :TODO
    an 700.10  🔀&g.Extras.Show-Merged-Branches                   :TODO
    an 700.10  🔀&g.Extras.Show-Tree                              :TODO
    an 700.10  🔀&g.Extras.Show-Unmerged-Branches                 :TODO
    an 700.10  🔀&g.Extras.Squash                                 :TODO
    an 700.10  🔀&g.Extras.Stamp                                  :TODO
    an 700.10  🔀&g.Extras.Standup                                :TODO
    an 700.10  🔀&g.Extras.Summary                                :TODO
    an 700.10  🔀&g.Extras.Sync                                   :TODO
    an 700.10  🔀&g.Extras.Touch                                  :TODO
    an 700.10  🔀&g.Extras.Undo                                   :TODO
    an 700.10  🔀&g.Extras.Unlock                                 :TODO
    an 700.10  🔀&g.Extras.Utimes                                 :TODO
    an 700.10  🔀&g.Flow.TODO                                     :TODO
    an 700.10  🔀&g.Extra\ Commands.TODO                          :TODO

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
    an 710.40  ⛏️&;.--5-- <Nop>
    an 710.40  ⛏️&;.Htop                              <Cmd>call planet#term#RunCmdTab('htop')<CR>
    an 710.40  ⛏️&;.Nmap.List\ Up\ Hosts              :call planet#term#RunCmdTab('nmap ...')
    an 710.40  ⛏️&;.--6-- <Nop>
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
    an 730.10  🔧&o.Set\ Server\ Port                         <Cmd>call planet#planet#EditVimVar('g:PV_server_port')<CR>
    an 730.10  🔧&o.Start\ Local\ Python\ http\.server\ Here  <Cmd>call planet#term#RunCmd('python3 -m http.server ' .. g:PV_server_port)<CR>
    an 730.10  🔧&o.Start\ Public\ ngrok\ Server              <Cmd>call planet#term#RunCmd('ngrok http ' .. g:PV_server_port)<CR>
    an 730.10  🔧&o.Set\ ngrok\ authtoken                     <Cmd>call planet#term#RunCmdAskArgs('ngrok authtoken', 'Please input your authtoken: ')<CR>
    an 730.10  🔧&o.--2-- <Nop>
    an 730.10  🔧&o.Edit\ Command<Tab>:                       q:
    an 730.10  🔧&o.Edit\ Search<Tab>q/                       q/
    an 730.10  🔧&o.Edit\ Search\ Backwards<Tab>q?            q?
    an 730.10  🔧&o.--3-- <Nop>
    an 730.10  🔧&o.Convert\ to\ HEX<Tab>:%!xxd             <Cmd>call <SID>XxdToHex()<CR>
    an 730.10  🔧&o.Convert\ from\ HEX<Tab>:%!xxd\ -r       <Cmd>call <SID>XxdFromHex()<CR>
    an 730.10  🔧&o.--4-- <Nop>
    an 730.10  🔧&o.Nmap.Find\ Hosts\ in\ Local\ Network    <Cmd>TODO<CR>
    an 730.10  🔧&o.Serial\ Monitor\ (picocom)              <Cmd>call planet#term#run_command_output('picocom -b 115200 /dev/ttyUSB0')<CR>
    an 730.10  🔧&o.Multipurpose\ Relay\ (socat)            :call planet#term#run_command_output('socat ...TODO')<CR>
    an 730.10  🔧&o.--5-- <Nop>
    an 730.10  🔧&o.Make\ dd\ print\ progress               :call planet#term#RunScript('TODO...print progress of all dd')
    an 730.10  🔧&o.--6-- <Nop>
    an 730.10  🔧&o.Run\ System\ Command                    <Cmd>call planet#term#RunCmdAsk('Command: ')<CR>
    "TODO: add websocat
    "TODO: add nmap
  else
    silent! aunmenu 🔀&g
    silent! aunmenu ⛏️&;
    silent! aunmenu 🔤&-
    silent! aunmenu 🔧&o
  endif
endfunc
