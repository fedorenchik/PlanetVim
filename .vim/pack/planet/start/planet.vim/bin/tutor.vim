" Runs in a separate clean GVim, so exercises use standard Vim keys and cannot
" change the parent PlanetVim mode, mappings, or files.
set nocompatible nomodeline noswapfile
filetype plugin indent on
syntax on
runtime plugin/tutor.vim
if exists(':Tutor') == 2
  Tutor
else
  let s:lessons = filter([$VIMRUNTIME .. '/tutor/tutor1', $VIMRUNTIME .. '/tutor/tutor'], {_, path -> filereadable(path)})
  enew
  setlocal buftype=nofile bufhidden=wipe noswapfile
  if empty(s:lessons)
    help usr_01.txt
  else
    call setline(1, readfile(s:lessons[0]))
    setlocal nomodified
    normal! gg
  endif
endif
