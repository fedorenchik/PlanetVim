scriptversion 4

func! planet#git#CommitFile(save = v:true, auto = v:true, push = v:false) abort
  if a:save
    w
  endif
  let commit_msg = ''
  if a:auto
    let commit_msg = expand('%:t') .. ': Update at ' .. system('date')
  else
    let commit_msg = inputdialog('Commit Message: ')
  endif
  let l:push_cmd = ''
  if a:push
    let l:push_cmd = ' && git push'
  endif
  call planet#term#RunCmd('git commit -m \""' .. commit_msg .. '"\" -- ' .. expand('%') .. l:push_cmd .. ' ; git status')
endfunc

func! planet#git#Commit(save = v:true, auto = v:true, push = v:false) abort
  if a:save
    confirm wa
  endif
  let commit_msg = ''
  if a:auto
    let commit_msg = 'Update at ' .. system('date')
  else
    let commit_msg = inputdialog('Commit Message: ')
  endif
  let l:push_cmd = ''
  if a:push
    let l:push_cmd = ' && git push'
  endif
  call planet#term#RunCmd('git commit -m \""' .. commit_msg .. '"\"' .. l:push_cmd .. ' ; git status')
endfunc

func! planet#git#EnableAutoCommit() abort
  aug AugPv_AutoCommit
    au!
    au FileWritePost * call planet#git#CommitFile(v:false, v:true)
  aug END
endfunc

func! planet#git#DisableAutoCommit() abort
  aug AugPv_AutoCommit
    au!
  aug END
endfunc

func! planet#git#CheckoutBranch() abort
  let l:branch = input("Branch: ")
  if ! empty(l:branch)
    call planet#term#RunCmd('git checkout ' .. l:branch)
  end
endfunc

func! planet#git#Clone() abort
  let l:git_clone_args = input("git clone: ")
  if ! empty(l:git_clone_args)
    call planet#term#RunCmd('git clone ' .. l:git_clone_args)
  end
endfunc
