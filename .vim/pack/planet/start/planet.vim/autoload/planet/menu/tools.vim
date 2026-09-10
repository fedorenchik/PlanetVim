scriptversion 4

func! planet#menu#tools#Update() abort
  if planet#menu#Visible('tools')
    " Git
    " Open Log in new window
    an 700.10  🔀&g.Git <Nop>
    an disable 🔀&g.Git
    an 700.10  🔀&g.&Status                                       <Cmd>call planet#gittools#Run(['status', '--short', '--branch', '--show-stash', '--untracked-files=all'])<CR>
    an 700.10  🔀&g.&Fetch                                        <Cmd>call planet#gittools#Run(['fetch'])<CR>
    an 700.10  🔀&g.P&ull                                         <Cmd>call planet#gittools#Run(['pull', '--ff-only'])<CR>
    an 700.10  🔀&g.&Push                                         <Cmd>call planet#gittools#Run(['push'])<CR>
    an 700.10  🔀&g.Summar&y                                      <Cmd>tab Git<CR>
    an 700.10  🔀&g.&Add.This\ &File                              <Cmd>call planet#gittools#File('add')<CR>
    an 700.10  🔀&g.&Add.Current\ &Directory                      <Cmd>call planet#gittools#Run(['add', '--', getcwd()])<CR>
    an 700.10  🔀&g.&Add.&All                                     <Cmd>call planet#gittools#Run(['add', '--update'])<CR>
    an 700.10  🔀&g.&Add.All\ with\ &Untracked                    <Cmd>call planet#gittools#Run(['add', '--all'])<CR>
    an 700.10  🔀&g.&Add.&Interactively                           <Cmd>tab Git<CR>
    an 700.10  🔀&g.&Add.&Interactive                             <Cmd>call planet#gittools#Run(['add', '--interactive'])<CR>
    an 700.10  🔀&g.&Add.&Patch                                   <Cmd>call planet#gittools#Run(['add', '--patch'])<CR>
    an 700.10  🔀&g.&Add.&Move  <Cmd>call planet#gittools#File('move')<CR>
    an 700.10  🔀&g.&Add.&Remove  <Cmd>call planet#gittools#File('remove')<CR>
    an 700.10  🔀&g.&Add.&Restore  <Cmd>call planet#gittools#File('restore')<CR>
    an 700.10  🔀&g.&Commit.&Commit                               <Cmd>call planet#git#Commit(v:false, v:false, v:false)<CR>
    an 700.10  🔀&g.&Commit.Commit\ &File                         <Cmd>call planet#git#CommitFile(v:false, v:false)<CR>
    an 700.10  🔀&g.&Commit.Commit\ &Tool                         <Cmd>call planet#git#Commit(v:false, v:false, v:false)<CR>
    an 700.10  🔀&g.&Commit.Save\ &&\ Commit\ File                <Cmd>call planet#git#CommitFile(v:true, v:false)<CR>
    an 700.10  🔀&g.&Commit.Commit\ &All                          <Cmd>call planet#gittools#CommitAll(v:false)<CR>
    an 700.10  🔀&g.&Commit.Commit\ All\ with\ Untracked          <Cmd>call planet#gittools#CommitAll(v:true)<CR>
    an 700.10  🔀&g.&Commit.Amend\ Last\ Commit                   <Cmd>call planet#gittools#Command('commit', ['--amend'], '')<CR>
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
    an 700.10  🔀&g.Ch&eckout.&File                               <Cmd>call planet#gittools#File('checkout')<CR>
    an 700.10  🔀&g.Fetch\ .Tags                                  <Cmd>call planet#gittools#Run(['fetch', '--tags'])<CR>
    an 700.10  🔀&g.Fetch\ .All                                   <Cmd>call planet#gittools#Run(['fetch', '--all'])<CR>
    an 700.10  🔀&g.Fetch\ .Prune                                 <Cmd>call planet#gittools#Run(['fetch', '--prune'])<CR>
    an 700.10  🔀&g.Fetch\ .From\ Default\ Remote                 <Cmd>call planet#gittools#Run(['fetch'])<CR>
    an 700.10  🔀&g.Fetch\ .From\ Specified\ Remote               <Cmd>call planet#gittools#Named('fetch', 'Remote name or URL:', [])<CR>
    an 700.10  🔀&g.Pull\ .Custom\ Ref/Repo                       <Cmd>call planet#gittools#Command('pull', ['--ff-only'], '')<CR>
    an 700.10  🔀&g.Push\ .To\ Custom \Remote/Branch              <Cmd>call planet#gittools#Command('push', [], '')<CR>
    an 700.10  🔀&g.&Log.&Log\ (QF)                               :Gclog!<CR>
    an 700.10  🔀&g.&Log.Log\ (LL)                                :Gllog!<CR>
    an 700.10  🔀&g.&Log.File\ (QF)                               :0Gclog!<CR>
    an 700.10  🔀&g.&Log.&File\ (LL)                              :0Gllog!<CR>
    an 700.10  🔀&g.&Log.Log\ (GUI)                               <Cmd>call planet#term#RunCmdGui('Flog -max-count=1000')<CR>
    an 700.10  🔀&g.&Log.Log\ All\ (GUI)                          <Cmd>call planet#term#RunCmdGui('Flog -max-count=1000 -all')<CR>
    " an 700.10  🔀&g.&Log.Log\ (GUI)                               :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +'Flog -max-count=1000' +tabo<CR>
    " an 700.10  🔀&g.&Log.Log\ All\ (GUI)                          :silent !gvim --cmd 'let g:startify_disable_at_vimenter = 1' +'Flog -max-count=1000 -all' +tabo<CR>
    an 700.10  🔀&g.&Tag.List                                     <Cmd>call planet#gittools#Run(['tag', '-l'])<CR>
    an 700.10  🔀&g.&Tag.Add  <Cmd>call planet#gittools#Named('tag', 'Tag name:', [])<CR>
    an 700.10  🔀&g.&Tag.Delete  <Cmd>call planet#gittools#Named('tag', 'Tag name:', ['-d'])<CR>
    an 700.10  🔀&g.&Merge.Fast-Forward\ Only  <Cmd>call planet#gittools#Named('merge', 'Branch or commit to merge:', ['--ff-only'])<CR>
    an 700.10  🔀&g.&Merge.Non\ Fast-Forward\ Only  <Cmd>call planet#gittools#Named('merge', 'Branch or commit to merge:', ['--no-ff'])<CR>
    an 700.10  🔀&g.Rebase.On\ Default\ Branch  <Cmd>call planet#gittools#Command('rebase', [], 'origin/HEAD')<CR>
    an 700.10  🔀&g.Stash\ (&j).Stash                             <Cmd>call planet#gittools#Stash('push')<CR>
    an 700.10  🔀&g.Stash\ (&j).List                              <Cmd>call planet#gittools#Stash('list')<CR>
    an 700.10  🔀&g.Stash\ (&j).Show                              <Cmd>call planet#gittools#Stash('show')<CR>
    an 700.10  🔀&g.Stash\ (&j).Pop                               <Cmd>call planet#gittools#Stash('pop')<CR>
    an 700.10  🔀&g.Stash\ (&j).Apply                             <Cmd>call planet#gittools#Stash('apply')<CR>
    an 700.10  🔀&g.Stash\ (&j).Branch                            <Cmd>call planet#gittools#Stash('branch')<CR>
    an 700.10  🔀&g.Stash\ (&j).Drop                              <Cmd>call planet#gittools#Stash('drop')<CR>
    an 700.10  🔀&g.Stash\ (&j).Clear                             <Cmd>call planet#gittools#Stash('clear')<CR>
    an 700.10  🔀&g.Notes.List  <Cmd>call planet#gittools#Notes('list')<CR>
    an 700.10  🔀&g.Notes.Add  <Cmd>call planet#gittools#Notes('add')<CR>
    an 700.10  🔀&g.Notes.Copy  <Cmd>call planet#gittools#Notes('copy')<CR>
    an 700.10  🔀&g.Notes.Append  <Cmd>call planet#gittools#Notes('append')<CR>
    an 700.10  🔀&g.Notes.Edit  <Cmd>call planet#gittools#Notes('edit')<CR>
    an 700.10  🔀&g.Notes.Show  <Cmd>call planet#gittools#Notes('show')<CR>
    an 700.10  🔀&g.Notes.Merge  <Cmd>call planet#gittools#Notes('merge')<CR>
    an 700.10  🔀&g.Notes.Remove  <Cmd>call planet#gittools#Notes('remove')<CR>
    an 700.10  🔀&g.Notes.Prune  <Cmd>call planet#gittools#Notes('prune')<CR>
    an 700.10  🔀&g.Notes.Get-Ref  <Cmd>call planet#gittools#Notes('get-ref')<CR>
    an 700.10  🔀&g.Notes.Enable\ Push  <Cmd>call planet#gittools#Notes('enable-push')<CR>
    an 700.10  🔀&g.&Branch.List\ Local                           <Cmd>call planet#gittools#Run(['branch'])<CR>
    an 700.10  🔀&g.&Branch.List\ All                             <Cmd>call planet#gittools#Run(['branch', '--all'])<CR>
    an 700.10  🔀&g.&Branch.List\ Remote\ (Local)                 <Cmd>call planet#gittools#Run(['branch', '--remote'])<CR>
    an 700.10  🔀&g.&Branch.List\ Remote\ (Remote)                <Cmd>call planet#gittools#Run(['ls-remote'])<CR>
    an 700.10  🔀&g.&Branch.Checkout  <Cmd>call planet#git#CheckoutBranch()<CR>
    an 700.10  🔀&g.&Branch.Rename                                <Cmd>call planet#gittools#Named('branch', 'New name for the current branch:', ['-m'])<CR>
    an 700.10  🔀&g.&Branch.Delete                                <Cmd>call planet#gittools#Named('branch', 'Merged local branch to delete:', ['-d'])<CR>
    an 700.10  🔀&g.&Diff.&Diff                                   <Cmd>call planet#gittools#Run(['-c', 'color.diff=always', 'diff'])<CR>
    an 700.10  🔀&g.&Diff.&Stat                                   <Cmd>call planet#gittools#Run(['-c', 'color.diff=always', 'diff', '--stat'])<CR>
    an 700.10  🔀&g.&Diff.&Cached\ (Index)                        <Cmd>call planet#gittools#Run(['-c', 'color.diff=always', 'diff', '--staged'])<CR>
    an 700.10  🔀&g.&Diff.Stat\ Cached                            <Cmd>call planet#gittools#Run(['-c', 'color.diff=always', 'diff', '--staged', '--stat'])<CR>
    an 700.10  🔀&g.&Worktree.Add\ Sibling\ Worktree              <Cmd>call planet#gittools#Worktree('sibling')<CR>
    an 700.10  🔀&g.&Worktree.New                                 <Cmd>call planet#gittools#Worktree('add')<CR>
    an 700.10  🔀&g.&Worktree.New\ Detached                       <Cmd>call planet#gittools#Worktree('detached')<CR>
    an 700.10  🔀&g.&Worktree.List                                <Cmd>call planet#gittools#Worktree('list')<CR>
    an 700.10  🔀&g.&Worktree.Lock                                <Cmd>call planet#gittools#Worktree('lock')<CR>
    an 700.10  🔀&g.&Worktree.Unlock                              <Cmd>call planet#gittools#Worktree('unlock')<CR>
    an 700.10  🔀&g.&Worktree.Move                                <Cmd>call planet#gittools#Worktree('move')<CR>
    an 700.10  🔀&g.&Worktree.Remove                              <Cmd>call planet#gittools#Worktree('remove')<CR>
    an 700.10  🔀&g.&Worktree.Prune                               <Cmd>call planet#gittools#Worktree('prune')<CR>
    an 700.10  🔀&g.&Worktree.Repair                              <Cmd>call planet#gittools#Worktree('repair')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Pull                            <Cmd>call planet#gittools#Subrepo('pull')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Pull\ All                       <Cmd>call planet#gittools#Subrepo('pull', '--all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Push                            <Cmd>call planet#gittools#Subrepo('push')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Push\ All                       <Cmd>call planet#gittools#Subrepo('push', '--all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Fetch                           <Cmd>call planet#gittools#Subrepo('fetch')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Fetch\ All                      <Cmd>call planet#gittools#Subrepo('fetch', '--all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Branch                          <Cmd>call planet#gittools#Subrepo('branch')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Branch\ All                     <Cmd>call planet#gittools#Subrepo('branch', '--all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Commit                          <Cmd>call planet#gittools#Subrepo('commit')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Status                          <Cmd>call planet#gittools#Subrepo('status')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Status\ All                     <Cmd>call planet#gittools#Subrepo('status', '--all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Status\ All\ Recursively        <Cmd>call planet#gittools#Subrepo('status', '--ALL')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clean                           <Cmd>call planet#gittools#Subrepo('clean')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clean\ All                      <Cmd>call planet#gittools#Subrepo('clean', '--all')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clean\ All\ Artifacts           <Cmd>call planet#gittools#Subrepo('clean', '--ALL')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Config                          <Cmd>call planet#gittools#Subrepo('config')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Clone                           <Cmd>call planet#gittools#Subrepo('clone')<CR>
    an 700.10  🔀&g.Subrepo\ (&x).Init                            <Cmd>call planet#gittools#Subrepo('init')<CR>
    an 700.10  🔀&g.&Gui.Git&k\ All                               <Cmd>call planet#gittools#Gui(['gitk', '--all'])<CR>
    an 700.10  🔀&g.&Gui.Gitk\ &HEAD                              <Cmd>call planet#gittools#Gui(['gitk'])<CR>
    an 700.10  🔀&g.&Gui.Gui                                      <Cmd>call planet#gittools#Gui(['git', 'citool'])<CR>
    an 700.10  🔀&g.&Gui.Gui&tar                                  <Cmd>call planet#gittools#Gui(['guitar'])<CR>
    an 700.10  🔀&g.&Gui.&Gitg                                    <Cmd>call planet#gittools#Gui(['gitg'])<CR>
    an 700.10  🔀&g.Ui.Git&ui                                     <Cmd>call planet#systemtools#Run(['gitui'])<CR>
    an 700.10  🔀&g.LFS  <Cmd>call planet#gittools#Command('lfs', [], 'status', v:null, v:false, 'Git LFS')<CR>
    an 700.10  🔀&g.New.Cl&one                                    <Cmd>call planet#git#Clone()<CR>
    an 700.10  🔀&g.New.&Init                                     <Cmd>call planet#gittools#Run(['init'])<CR>
    an 700.10  🔀&g.Patch.Am  <Cmd>call planet#gittools#Command('am', [], '')<CR>
    an 700.10  🔀&g.Patch.Format-Patch  <Cmd>call planet#gittools#Command('format-patch', [], '-1 HEAD')<CR>
    an 700.10  🔀&g.Patch.Imap-Send  <Cmd>call planet#gittools#Input('imap-send', [], '')<CR>
    an 700.10  🔀&g.Patch.Quiltimport  <Cmd>call planet#gittools#Command('quiltimport', [], '')<CR>
    an 700.10  🔀&g.Patch.Send-Email  <Cmd>call planet#gittools#Command('send-email', [], '')<CR>
    an 700.10  🔀&g.Patch.Apply  <Cmd>call planet#gittools#Command('apply', [], '')<CR>
    an 700.10  🔀&g.Advanced.Request-Pull  <Cmd>call planet#gittools#Command('request-pull', [], 'HEAD~1 origin HEAD')<CR>
    an 700.10  🔀&g.Advanced.Remote.List                          <Cmd>call planet#gittools#Run(['remote', '-v'])<CR>
    an 700.10  🔀&g.Advanced.Blame  <Cmd>call planet#gittools#File('blame')<CR>
    an 700.10  🔀&g.Advanced.Bisect  <Cmd>call planet#gittools#Command('bisect', [], 'start')<CR>
    an 700.10  🔀&g.Advanced.Submodule.Run  <Cmd>call planet#gittools#Command('submodule', [], '')<CR>
    an 700.10  🔀&g.Advanced.Reflog.List                          <Cmd>call planet#gittools#Run(['reflog'])<CR>
    an 700.10  🔀&g.Advanced.Reset.Soft\ HEAD~1                   <Cmd>call planet#gittools#Command('reset', [], '--soft HEAD~1')<CR>
    an 700.10  🔀&g.Advanced.Reset.Reset\ HEAD~1                  <Cmd>call planet#gittools#Command('reset', [], 'HEAD~1')<CR>
    an 700.10  🔀&g.Advanced.Reset.Hard\ HEAD~1                   <Cmd>call planet#gittools#Command('reset', [], '--hard HEAD~1')<CR>
    an 700.10  🔀&g.Advanced.Cherry-pick.Run  <Cmd>call planet#gittools#Command('cherry-pick', [], '')<CR>
    an 700.10  🔀&g.Advanced.Archive  <Cmd>call planet#gittools#Command('archive', [], '--format=zip --output=archive.zip HEAD')<CR>
    an 700.10  🔀&g.Advanced.Bundle  <Cmd>call planet#gittools#Command('bundle', [], 'create repository.bundle --all')<CR>
    an 700.10  🔀&g.Advanced.Clean  <Cmd>call planet#gittools#Command('clean', [], '--dry-run -d')<CR>
    an 700.10  🔀&g.Advanced.Grep  <Cmd>call planet#gittools#Command('grep', [], '-n "pattern"')<CR>
    an 700.10  🔀&g.Advanced.Switch  <Cmd>call planet#gittools#Command('switch', [], '')<CR>
    an 700.10  🔀&g.Advanced.Hooks  <Cmd>call planet#gittools#Hooks()<CR>
    an 700.10  🔀&g.Advanced.Range\ Diff  <Cmd>call planet#gittools#Command('range-diff', [], 'HEAD~2...HEAD')<CR>
    an 700.10  🔀&g.Advanced.Revert  <Cmd>call planet#gittools#Command('revert', [], '')<CR>
    an 700.10  🔀&g.Advanced.Shortlog  <Cmd>call planet#gittools#Command('shortlog', [], '-sn HEAD')<CR>
    an 700.10  🔀&g.Advanced.Show  <Cmd>call planet#gittools#Command('show', [], 'HEAD')<CR>
    an 700.10  🔀&g.Advanced.Subtree  <Cmd>call planet#gittools#Command('subtree', [], '')<CR>
    an 700.10  🔀&g.Advanced.Config  <Cmd>call planet#gittools#Command('config', [], '--local --list')<CR>
    an 700.10  🔀&g.Advanced.Describe  <Cmd>call planet#gittools#Command('describe', [], '--always --dirty')<CR>
    an 700.10  🔀&g.Advanced.Filter-Branch  <Cmd>call planet#gittools#Command('filter-branch', [], '')<CR>
    an 700.10  🔀&g.Advanced.Rerere  <Cmd>call planet#gittools#Command('rerere', [], 'status')<CR>
    an 700.10  🔀&g.Advanced.Bugreport  <Cmd>call planet#gittools#Command('bugreport', [], '')<CR>
    an 700.10  🔀&g.Advanced.Replace  <Cmd>call planet#gittools#Command('replace', [], '-l')<CR>
    an 700.10  🔀&g.Advanced.Annotate  <Cmd>call planet#gittools#File('annotate')<CR>
    an 700.10  🔀&g.Advanced.Cherry  <Cmd>call planet#gittools#Command('cherry', [], '-v')<CR>
    an 700.10  🔀&g.Advanced.Help  <Cmd>call planet#gittools#Command('help', [], '')<CR>
    an 700.10  🔀&g.Advanced.Instaweb  <Cmd>call planet#gittools#Command('instaweb', [], '--local')<CR>
    an 700.10  🔀&g.Advanced.Merge-Tree  <Cmd>call planet#gittools#Command('merge-tree', [], 'HEAD~1 HEAD')<CR>
    an 700.10  🔀&g.Advanced.Rev\ Parse  <Cmd>call planet#gittools#Command('rev-parse', [], 'HEAD')<CR>
    an 700.10  🔀&g.Advanced.Show-Branch  <Cmd>call planet#gittools#Command('show-branch', [], '--all')<CR>
    an 700.10  🔀&g.Advanced.Verify-Commit  <Cmd>call planet#gittools#Command('verify-commit', [], 'HEAD')<CR>
    an 700.10  🔀&g.Advanced.Verify-Tag  <Cmd>call planet#gittools#Command('verify-tag', [], '')<CR>
    an 700.10  🔀&g.Advanced.Whatchanged  <Cmd>call planet#gittools#Command('whatchanged', [], '-10')<CR>
    an 700.10  🔀&g.Low\ Level.Checkout-Index  <Cmd>call planet#gittools#Command('checkout-index', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Commit-Graph  <Cmd>call planet#gittools#Command('commit-graph', [], 'verify')<CR>
    an 700.10  🔀&g.Low\ Level.Commit-Tree  <Cmd>call planet#gittools#Command('commit-tree', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Hash-Object  <Cmd>call planet#gittools#Command('hash-object', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Merge-File  <Cmd>call planet#gittools#Command('merge-file', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Mktag  <Cmd>call planet#gittools#Input('mktag', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Mktree  <Cmd>call planet#gittools#Input('mktree', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Read-Tree  <Cmd>call planet#gittools#Command('read-tree', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Symbolic-Ref  <Cmd>call planet#gittools#Command('symbolic-ref', [], 'HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.Update-Index  <Cmd>call planet#gittools#Command('update-index', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Update-Ref  <Cmd>call planet#gittools#Command('update-ref', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Write-Tree  <Cmd>call planet#gittools#Command('write-tree', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Cat-File  <Cmd>call planet#gittools#Command('cat-file', [], '-p HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.Diff-Files  <Cmd>call planet#gittools#Command('diff-files', [], '--stat')<CR>
    an 700.10  🔀&g.Low\ Level.Diff-Index  <Cmd>call planet#gittools#Command('diff-index', [], '--stat HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.Diff-Tree  <Cmd>call planet#gittools#Command('diff-tree', [], '--stat HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.For-Each-Ref  <Cmd>call planet#gittools#Command('for-each-ref', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.For-Each-Repo  <Cmd>call planet#gittools#Command('for-each-repo', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Get-Tar-Commit-Id  <Cmd>call planet#gittools#Input('get-tar-commit-id', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Ls-Files  <Cmd>call planet#gittools#Command('ls-files', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Ls-Remote  <Cmd>call planet#gittools#Command('ls-remote', [], 'origin')<CR>
    an 700.10  🔀&g.Low\ Level.Ls-Tree  <Cmd>call planet#gittools#Command('ls-tree', [], 'HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.Merge-Base  <Cmd>call planet#gittools#Command('merge-base', [], 'HEAD HEAD~1')<CR>
    an 700.10  🔀&g.Low\ Level.Name-Rev  <Cmd>call planet#gittools#Command('name-rev', [], 'HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.Rev-List  <Cmd>call planet#gittools#Command('rev-list', [], '--max-count=20 HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.Rev-Parse  <Cmd>call planet#gittools#Command('rev-parse', [], 'HEAD')<CR>
    an 700.10  🔀&g.Low\ Level.Show-Index  <Cmd>call planet#gittools#Input('show-index', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Show-Ref  <Cmd>call planet#gittools#Command('show-ref', [], '')<CR>
    an 700.10  🔀&g.Low\ Level.Var  <Cmd>call planet#gittools#Command('var', [], 'GIT_AUTHOR_IDENT')<CR>
    an 700.10  🔀&g.Maintenance.Gc  <Cmd>call planet#gittools#Command('gc', [], '')<CR>
    an 700.10  🔀&g.Maintenance.Maintenance  <Cmd>call planet#gittools#Command('maintenance', [], 'run')<CR>
    an 700.10  🔀&g.Maintenance.Count-Objects  <Cmd>call planet#gittools#Command('count-objects', [], '-v')<CR>
    an 700.10  🔀&g.Maintenance.Fsck  <Cmd>call planet#gittools#Command('fsck', [], '')<CR>
    an 700.10  🔀&g.Maintenance.Pack-Redundant  <Cmd>call planet#gittools#Command('pack-redundant', [], '--all')<CR>
    an 700.10  🔀&g.Maintenance.Unpack-File  <Cmd>call planet#gittools#Command('unpack-file', [], '')<CR>
    an 700.10  🔀&g.Maintenance.Verify-Pack  <Cmd>call planet#gittools#Command('verify-pack', [], '')<CR>
    an 700.10  🔀&g.Maintenance.Unpack-Objects  <Cmd>call planet#gittools#Input('unpack-objects', [], '')<CR>
    an 700.10  🔀&g.Maintenance.Multi-Pack-Index  <Cmd>call planet#gittools#Command('multi-pack-index', [], 'verify')<CR>
    an 700.10  🔀&g.Maintenance.Pack-Objects  <Cmd>call planet#gittools#Input('pack-objects', [], '')<CR>
    an 700.10  🔀&g.Maintenance.Prune-Packed  <Cmd>call planet#gittools#Command('prune-packed', [], '--dry-run')<CR>
    an 700.10  🔀&g.Maintenance.Index-Pack  <Cmd>call planet#gittools#Command('index-pack', [], '')<CR>
    an 700.10  🔀&g.Maintenance.Pack-Refs  <Cmd>call planet#gittools#Command('pack-refs', [], '--all')<CR>
    an 700.10  🔀&g.Maintenance.Prune  <Cmd>call planet#gittools#Command('prune', [], '--dry-run')<CR>
    an 700.10  🔀&g.Maintenance.Repack  <Cmd>call planet#gittools#Command('repack', [], '')<CR>
    an 700.10  🔀&g.Contrib.Contacts  <Cmd>call planet#gittools#Command('contacts', [], '', v:null, v:false, 'Git contrib scripts')<CR>
    an 700.10  🔀&g.Contrib.Workdir  <Cmd>call planet#gittools#Command('new-workdir', [], '', v:null, v:false, 'Git contrib scripts')<CR>
    an 700.10  🔀&g.Contrib.Resurrect  <Cmd>call planet#gittools#Command('resurrect', [], '', v:null, v:false, 'Git contrib scripts')<CR>
    an 700.10  🔀&g.Contrib.Rerere\ Train  <Cmd>call planet#gittools#Command('rerere-train', [], '', v:null, v:false, 'Git contrib scripts')<CR>
    an 700.10  🔀&g.Other\ VCS.Fast-Export  <Cmd>call planet#gittools#Command('fast-export', [], '--all')<CR>
    an 700.10  🔀&g.Other\ VCS.Fast-Import  <Cmd>call planet#gittools#Input('fast-import')<CR>
    an 700.10  🔀&g.Other\ VCS.Arch  <Cmd>call planet#gittools#Command('archimport', [], '', v:null, v:false, 'Git arch integration')<CR>
    an 700.10  🔀&g.Other\ VCS.CVS  <Cmd>call planet#gittools#Command('cvsimport', [], '', v:null, v:false, 'Git cvs integration')<CR>
    an 700.10  🔀&g.Other\ VCS.SVN  <Cmd>call planet#gittools#Command('svn', [], '', v:null, v:false, 'Git svn integration')<CR>
    an 700.10  🔀&g.Other\ VCS.P4  <Cmd>call planet#gittools#Command('p4', [], '', v:null, v:false, 'Git p4 integration')<CR>
    an 700.10  🔀&g.Other\ VCS.Mercurial  <Cmd>call planet#gittools#Mercurial()<CR>
    an 700.10  🔀&g.Experimental.Sparse-Checkout.Init  <Cmd>call planet#gittools#Command('sparse-checkout', ['init'], '--cone')<CR>
    an 700.10  🔀&g.Extras.Alias  <Cmd>call planet#gittools#Command('alias', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Archive-File  <Cmd>call planet#gittools#Command('archive-file', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Authors  <Cmd>call planet#gittools#Command('authors', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Browse  <Cmd>call planet#gittools#Command('browse', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Brv  <Cmd>call planet#gittools#Command('brv', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Bulk  <Cmd>call planet#gittools#Command('bulk', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Changelog  <Cmd>call planet#gittools#Command('changelog', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Clear  <Cmd>call planet#gittools#Command('clear', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Clear-Soft  <Cmd>call planet#gittools#Command('clear-soft', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Coauthor  <Cmd>call planet#gittools#Command('coauthor', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Commits-Since  <Cmd>call planet#gittools#Command('commits-since', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Contrib  <Cmd>call planet#gittools#Command('contrib', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Count  <Cmd>call planet#gittools#Command('count', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Cp  <Cmd>call planet#gittools#Command('cp', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Create-Branch  <Cmd>call planet#gittools#Command('create-branch', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Delete-Branch  <Cmd>call planet#gittools#Command('delete-branch', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Delete-Merged-Branches  <Cmd>call planet#gittools#Command('delete-merged-branches', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Delete-Submodule  <Cmd>call planet#gittools#Command('delete-submodule', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Delete-Tag  <Cmd>call planet#gittools#Command('delete-tag', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Delta  <Cmd>call planet#gittools#Command('delta', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Effort  <Cmd>call planet#gittools#Command('effort', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Extras  <Cmd>call planet#gittools#Command('extras', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Feature  <Cmd>call planet#gittools#Command('feature', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Force-Clone  <Cmd>call planet#gittools#Command('force-clone', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Fork  <Cmd>call planet#gittools#Command('fork', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Fresh-Branch  <Cmd>call planet#gittools#Command('fresh-branch', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Gh-Pages  <Cmd>call planet#gittools#Command('gh-pages', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Graft  <Cmd>call planet#gittools#Command('graft', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Guilt  <Cmd>call planet#gittools#Command('guilt', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Ignore  <Cmd>call planet#gittools#Command('ignore', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Ignore-Io  <Cmd>call planet#gittools#Command('ignore-io', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Info  <Cmd>call planet#gittools#Command('info', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Local-Commits  <Cmd>call planet#gittools#Command('local-commits', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Lock  <Cmd>call planet#gittools#Command('lock', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Locked  <Cmd>call planet#gittools#Command('locked', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Merge-Into  <Cmd>call planet#gittools#Command('merge-into', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Merge-Repo  <Cmd>call planet#gittools#Command('merge-repo', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Missing  <Cmd>call planet#gittools#Command('missing', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Mr  <Cmd>call planet#gittools#Command('mr', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Obliterate  <Cmd>call planet#gittools#Command('obliterate', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Paste  <Cmd>call planet#gittools#Command('paste', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Pr  <Cmd>call planet#gittools#Command('pr', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Psykorebase  <Cmd>call planet#gittools#Command('psykorebase', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Pull-Request  <Cmd>call planet#gittools#Command('pull-request', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Reauthor  <Cmd>call planet#gittools#Command('reauthor', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Rebase-Patch  <Cmd>call planet#gittools#Command('rebase-patch', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Release  <Cmd>call planet#gittools#Command('release', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Rename-Branch  <Cmd>call planet#gittools#Command('rename-branch', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Rename-Tag  <Cmd>call planet#gittools#Command('rename-tag', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Repl  <Cmd>call planet#gittools#Command('repl', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Reset-File  <Cmd>call planet#gittools#Command('reset-file', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Root  <Cmd>call planet#gittools#Command('root', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Rscp  <Cmd>call planet#gittools#Command('rscp', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Scp  <Cmd>call planet#gittools#Command('scp', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Sed  <Cmd>call planet#gittools#Command('sed', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Setup  <Cmd>call planet#gittools#Command('setup', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Show-Merged-Branches  <Cmd>call planet#gittools#Command('show-merged-branches', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Show-Tree  <Cmd>call planet#gittools#Command('show-tree', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Show-Unmerged-Branches  <Cmd>call planet#gittools#Command('show-unmerged-branches', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Squash  <Cmd>call planet#gittools#Command('squash', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Stamp  <Cmd>call planet#gittools#Command('stamp', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Standup  <Cmd>call planet#gittools#Command('standup', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Summary  <Cmd>call planet#gittools#Command('summary', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Sync  <Cmd>call planet#gittools#Command('sync', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Touch  <Cmd>call planet#gittools#Command('touch', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Undo  <Cmd>call planet#gittools#Command('undo', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Unlock  <Cmd>call planet#gittools#Command('unlock', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Extras.Utimes  <Cmd>call planet#gittools#Command('utimes', [], '', v:null, v:false, 'git-extras')<CR>
    an 700.10  🔀&g.Flow.Command  <Cmd>call planet#gittools#Command('flow', [], 'feature', v:null, v:false, 'git-flow')<CR>
    an 700.10  🔀&g.Extra\ Commands.Run  <Cmd>call planet#gittools#Extra()<CR>

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
    an 710.40  ⛏️&;.Htop                              <Cmd>call planet#systemtools#Run(['htop'])<CR>
    an 710.40  ⛏️&;.Nmap.List\ Up\ Hosts              <Cmd>call planet#systemtools#Nmap()<CR>
    an 710.40  ⛏️&;.--6-- <Nop>
    an 710.40  ⛏️&;.Set\ Context\ Lines               <Cmd>call planet#diff#Context()<CR>

    " Writing
    an 715.10  🔤&\..Writing <Nop>
    an disable 🔤&\..Writing
    an 715.10  🔤&\..Swap\ Words                   <Cmd>call planet#prose#Swap(-1)<CR>
    an 715.10  🔤&\..Swap\ Words\ After            <Cmd>call planet#prose#Swap(1)<CR>
    an 715.10  🔤&\..--1-- <Nop>
    an 715.10  🔤&\..Thesaurus                     <Cmd>call planet#prose#Complete()<CR>
    an 715.10  🔤&\..--2-- <Nop>
    an 715.10  🔤&\..Generate\ Sample\ Text        <Cmd>call planet#prose#Sample()<CR>
    an 715.10  🔤&\..--3-- <Nop>
    an 715.10  🔤&\..Left\ Align<Tab>:left         :left<CR>
    an 715.10  🔤&\..Center\ Align<Tab>:center     :center<CR>
    an 715.10  🔤&\..Right\ Align<Tab>:right       :right<CR>
    an 715.10  🔤&\..--4-- <Nop>
    an 715.10  🔤&\..Enable\ Distraction-Free\ Mode <Cmd>call planet#prose#Focus(v:true)<CR>
    an 715.10  🔤&\..Disable\ Distraction-Free\ Mode <Cmd>call planet#prose#Focus(v:false)<CR>
    an 715.10  🔤&\..--5-- <Nop>
    am 715.10  🔤&\..Proofreading.Weak\ (first\ draft)<Tab>:Wordy\ weak             <Cmd>call planet#prose#Proofread('weak')<CR>
    am 715.10  🔤&\..Proofreading.Redundant<Tab>:Wordy\ redundant                   <Cmd>call planet#prose#Proofread('redundant')<CR>
    am 715.10  🔤&\..Proofreading.Problematic<Tab>:Wordy\ problematic               <Cmd>call planet#prose#Proofread('problematic')<CR>
    am 715.10  🔤&\..Proofreading.Puffery<Tab>:Wordy\ puffery                       <Cmd>call planet#prose#Proofread('puffery')<CR>
    am 715.10  🔤&\..Proofreading.Business\ Jargon<Tab>:Wordy\ business-jargon      <Cmd>call planet#prose#Proofread('business-jargon')<CR>
    am 715.10  🔤&\..Proofreading.Art\ Jargon<Tab>:Wordy\ art-jargon                <Cmd>call planet#prose#Proofread('art-jargon')<CR>
    am 715.10  🔤&\..Proofreading.Manipulative\ Language<Tab>:Wordy\ weasel         <Cmd>call planet#prose#Proofread('weasel')<CR>
    am 715.10  🔤&\..Proofreading.Verb\ 'to\ be'<Tab>:Wordy\ being                  <Cmd>call planet#prose#Proofread('being')<CR>
    am 715.10  🔤&\..Proofreading.Passive\ Voice<Tab>:Wordy\ passive-voice          <Cmd>call planet#prose#Proofread('passive-voice')<CR>
    am 715.10  🔤&\..Proofreading.Colloquialisms<Tab>:Wordy\ colloquial             <Cmd>call planet#prose#Proofread('colloquial')<CR>
    am 715.10  🔤&\..Proofreading.Idioms<Tab>:Wordy\ idiomatic                      <Cmd>call planet#prose#Proofread('idiomatic')<CR>
    am 715.10  🔤&\..Proofreading.Similies<Tab>:Wordy\ similies                     <Cmd>call planet#prose#Proofread('similies')<CR>
    am 715.10  🔤&\..Proofreading.Adjectives<Tab>:Wordy\ adjectives                 <Cmd>call planet#prose#Proofread('adjectives')<CR>
    am 715.10  🔤&\..Proofreading.Adverbs<Tab>:Wordy\ adverbs                       <Cmd>call planet#prose#Proofread('adverbs')<CR>
    am 715.10  🔤&\..Proofreading.'said'<Tab>:Wordy\ said-synonyms                  <Cmd>call planet#prose#Proofread('said-synonyms')<CR>
    am 715.10  🔤&\..Proofreading.Editorializing<Tab>:Wordy\ opinion                <Cmd>call planet#prose#Proofread('opinion')<CR>
    am 715.10  🔤&\..Proofreading.Contractions<Tab>:Wordy\ contractions             <Cmd>call planet#prose#Proofread('contractions')<CR>
    am 715.10  🔤&\..Proofreading.Vague\ Time<Tab>:Wordy\ vague-time                <Cmd>call planet#prose#Proofread('vague-time')<CR>
    am 715.10  🔤&\..Proofreading.Disable<Tab>:NoWordy                              <Cmd>call planet#prose#Proofread('off')<CR>
    am 715.10  🔤&\..Translation.Translate<Tab>:TranslateW                          <Cmd>call planet#translation#Translate('window')<CR>
    am 715.10  🔤&\..Translation.Replace\ with\ Translation<Tab>:TranslateR         <Cmd>call planet#translation#Translate('replace')<CR>
    am 715.10  🔤&\..Translation.Echo\ Translation<Tab>:Translate                   <Cmd>call planet#translation#Translate('echo')<CR>
    am 715.10  🔤&\..Translation.Set\ Source\ Language                              <Cmd>call planet#translation#Language('source')<CR>
    am 715.10  🔤&\..Translation.Set\ Target\ Language                              <Cmd>call planet#translation#Language('target')<CR>
    am 715.10  🔤&\..Translation.Edit\ Translation\ Engines                         <Cmd>call planet#translation#Engines()<CR>
    am 715.10  🔤&\..Translation.Export\ History                                    <Cmd>call planet#translation#ExportHistory()<CR>
    am 715.10  🔤&\..Translation.Show\ Log                                          <Cmd>call planet#translation#Log()<CR>
    am 715.10  🔤&\..Abbreviation.Enable\ AutoCorrect\ Typos                        <Cmd>call planet#prose#AutoCorrect()<CR>

    vnoremenu 715.10 🔤&\..Translation.Translate <Cmd>call planet#translation#Translate('window', v:null, planet#selection#Current())<CR>
    vnoremenu 715.10 🔤&\..Translation.Replace\ with\ Translation <Cmd>call planet#translation#Translate('replace', v:null, planet#selection#Current())<CR>
    vnoremenu 715.10 🔤&\..Translation.Echo\ Translation <Cmd>call planet#translation#Translate('echo', v:null, planet#selection#Current())<CR>

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
    an 720.10  🔠&-.Repeat\ Correction<Tab>:spellrepall  :spellrepall<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Mark\ as\ Correct<Tab>zg            zg
    an 720.10  🔠&-.Mark\ as\ Incorrect<Tab>zw          zw
    an 720.10  🔠&-.Mark\ as\ Rare<Tab>:spellrare       <Cmd>call planet#prose#MarkRare(v:false)<CR>
    an 720.10  🔠&-.--1-- <Nop>
    an 720.10  🔠&-.Mark\ as\ Correct\ Temp<Tab>zG      zG
    an 720.10  🔠&-.Mark\ as\ Incorrect\ Temp<Tab>zW    zW
    an 720.10  🔠&-.Mark\ as\ Rare\ Temp<Tab>:spellrare <Cmd>call planet#prose#MarkRare(v:true)<CR>
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
    am 720.10  🔠&-.Toggle<Tab>yos                          <Cmd>setlocal spell!<CR>
    an 720.10  🔠&-.--1-- <Nop>
    am 720.10  🔠&-.Current\ Spell\ Files<Tab>:spellinfo    :spellinfo<CR>
    am 720.10  🔠&-.Cleanup\ Spell\ File                    :runtime spell/cleanadd.vim<CR>
    an 720.10  🔠&-.Grammar <Nop>
    an disable 🔠&-.Grammar
    am 720.10  🔠&-.Grammar\ Check<Tab>:GrammarousCheck     <Cmd>call planet#prose#Grammar('check')<CR>
    am 720.10  🔠&-.Grammar\ Check\ Comments                <Cmd>call planet#prose#Grammar('comments')<CR>
    am 720.10  🔠&-.Grammar\ Check\ Reset<Tab>:GrammarousReset <Cmd>call planet#prose#Grammar('reset')<CR>
    am 720.10  🔠&-.Grammar\ Check\ Status                  <Cmd>call planet#prose#Grammar('status')<CR>

    " Tools
    an 730.10  🔧&o.External\ Programs.equalprg <Cmd>call planet#systemtools#Program('equalprg')<CR>
    an 730.10  🔧&o.External\ Programs.formatprg <Cmd>call planet#systemtools#Program('formatprg')<CR>
    an 730.10  🔧&o.External\ Programs.keywordprg <Cmd>call planet#systemtools#Program('keywordprg')<CR>
    an 730.10  🔧&o.External\ Programs.makeprg <Cmd>call planet#systemtools#Program('makeprg')<CR>
    an 730.10  🔧&o.External\ Programs.grepprg <Cmd>call planet#systemtools#Program('grepprg')<CR>
    an 730.10  🔧&o.Tools <Nop>
    an disable 🔧&o.Tools
    an 730.10  🔧&o.Colori&ze                                 :ColorToggle<CR>
    an 730.10  🔧&o.--1-- <Nop>
    an 730.10  🔧&o.Set\ Server\ Port                         <Cmd>call planet#systemtools#Port()<CR>
    an 730.10  🔧&o.Start\ Local\ Python\ http\.server\ Here  <Cmd>call planet#systemtools#Http()<CR>
    an 730.10  🔧&o.Start\ Public\ ngrok\ Server              <Cmd>call planet#systemtools#Ngrok()<CR>
    an 730.10  🔧&o.Set\ ngrok\ authtoken                     <Cmd>call planet#systemtools#NgrokToken()<CR>
    an 730.10  🔧&o.--2-- <Nop>
    an 730.10  🔧&o.Edit\ Command<Tab>:                       q:
    an 730.10  🔧&o.Edit\ Search<Tab>q/                       q/
    an 730.10  🔧&o.Edit\ Search\ Backwards<Tab>q?            q?
    an 730.10  🔧&o.--3-- <Nop>
    an 730.10  🔧&o.Convert\ to\ HEX<Tab>:%!xxd             <Cmd>call planet#tools#XxdToHex()<CR>
    an 730.10  🔧&o.Convert\ from\ HEX<Tab>:%!xxd\ -r       <Cmd>call planet#tools#XxdFromHex()<CR>
    an 730.10  🔧&o.--4-- <Nop>
    an 730.10  🔧&o.Nmap.Find\ Hosts\ in\ Local\ Network    <Cmd>call planet#systemtools#Nmap()<CR>
    an 730.10  🔧&o.Serial\ Monitor\ (picocom)              <Cmd>call planet#systemtools#Serial()<CR>
    an 730.10  🔧&o.Multipurpose\ Relay\ (socat)            <Cmd>call planet#systemtools#Socat()<CR>
    an 730.10  🔧&o.--5-- <Nop>
    an 730.10  🔧&o.Make\ dd\ print\ progress               <Cmd>call planet#systemtools#DdProgress()<CR>
    an 730.10  🔧&o.--6-- <Nop>
    an 730.10  🔧&o.Run\ System\ Command                    <Cmd>call planet#term#RunCmdAsk('Command: ')<CR>
    an 730.10  🔧&o.WebSocket\ Client  <Cmd>call planet#systemtools#Websocat()<CR>

    call planet#diff#Menus()
    call planet#input#Menus('tools')
  else
    silent! aunmenu 🔀&g
    silent! aunmenu ⛏️&;
    silent! aunmenu 🔤&\.
    silent! aunmenu 🔠&-
    silent! aunmenu 🔧&o
  endif
endfunc
