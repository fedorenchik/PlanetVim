scriptversion 4

func! planet#util#git#CommitFile(save = v:true, auto = v:true, push = v:false) abort
  if a:save
    w
  endif
  let commit_msg = ''
  if a:auto
    let commit_msg = 'Automatic Commit at ' .. system('date')
  else
    let commit_msg = inputdialog('Commit Message: ')
  endif
  exe '!git commit -m "' .. commit_msg .. '" ' .. expand('%')
  if a:push
    exe '!git push'
  endif
endfunc

func! planet#util#git#Commit(save = v:true, auto = v:true, push = v:false) abort
  if a:save
    confirm wa
  endif
  let commit_msg = ''
  if a:auto
    let commit_msg = 'Automatic Commit at ' .. system('date')
  else
    let commit_msg = inputdialog('Commit Message: ')
  endif
  exe '!git commit -m "' .. commit_msg .. '" ' .. expand('%')
  if a:push
    exe '!git push'
  endif
endfunc

func! planet#util#git#EnableAutoCommit() abort
  aug AugPv_AutoCommit
    au!
    au FileWritePost * call planet#util#git#CommitFile(v:false, v:true)
  aug END
endfunc

func! planet#util#git#DisableAutoCommit() abort
  aug AugPv_AutoCommit
    au!
  aug END
endfunc
