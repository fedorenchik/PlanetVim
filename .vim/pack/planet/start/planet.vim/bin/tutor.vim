vim9script

# Run exercises in a separate clean GVim with standard Vim keys.
def Run()
  set nocompatible nomodeline noswapfile
  filetype plugin indent on
  syntax on
  runtime plugin/tutor.vim
  if exists(':Tutor') == 2
    execute 'Tutor'
  else
    var lessons = filter([$VIMRUNTIME .. '/tutor/tutor1', $VIMRUNTIME .. '/tutor/tutor'],
        (_, path) => filereadable(path))
    enew
    setlocal buftype=nofile bufhidden=wipe noswapfile
    if empty(lessons)
      help usr_01.txt
    else
      setline(1, readfile(lessons[0]))
      setlocal nomodified
      normal! gg
    endif
  endif
enddef
Run()
