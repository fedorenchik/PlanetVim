scriptversion 4

" TODO: $VIMRUNTIME folder
" TODO: Vim help reference
" TODO: VS Code
" TODO: Qt Creator
" TODO: LibreOffice
" TODO: Use $VIMRUNTIME/tools/demoserver.py for controlling Vim
" TODO: Add Buffer Cmdline Window: Input commands and ouput results in
" TODO:    'prompt' buffer.
" TODO: Add sessions inside project dir support
" Custom config file: $HOME/.vim/planetvimrc.vim
"TODO: Add function to follow DE night mode & theme settings (auto switch
"TODO: guioptions+=d when dark theme, auto switch to dark colorscheme variant)

"TODO: add setting 'equalprg' for formatting wih == (clang-format, etc.)
"TODO: Choise between text, emoji, symbols, nerdicons menus
"TODO: Customize tabline-menu when vim bug #7991 is fixed
"TODO: Add prompt buffer to exec viml commands
"TODO: menus:
"TODO:    C++
"TODO:    Python
"TODO:    Arduino
"TODO:    PlatformIO
"TODO:    CMake
"TODO:    Meson
"TODO:    Conan
"TODO:    Qt (uic, moc, rcc, lupdate, lrelease, shiboken)
"TODO:    SWIG, 
"TODO:    Latex
"TODO:    Writing
"TODO:    Docker
"TODO:    Yocto
"TODO:    ROS
"TODO:    gdb/lldb
"TODO:    cppcheck/clazy/clang-tidy
"TODO:    indent/astyle/clang-format
"TODO:    LKD: linux kernel development: patches, checkpatch.pl, get-maintainers.sh, send-email
"TODO:    kvm,virsh,qemu cli
"TODO:    chroot,schroot,conan_venv
"TODO:    unreal engine, godot
"TODO: detect 'rtp' based on v:progname ('pvim') (v:progname for PlanetVim
"TODO:    package is 'pvim'

runtime! START globals.vim

if filereadable(expand(g:PV_config))
  silent exe "source " .. fnameescape(g:PV_config)
endif

call planet#menu#planet#Update()
call planet#menu#basic#Update()
call planet#menu#edit#Update()
call planet#menu#dev#Update()
call planet#menu#tools#Update()
call planet#menu#nav#Update()
call planet#menu#settings#Update()

if g:PV_mode == 'e'
  call planet#planet#SetEasyMode()
elseif g:PV_mode == 's'
  call planet#planet#SetStandardMode()
elseif g:PV_mode == 'p'
  call planet#planet#SetSuperChargedMode()
end

" Avoid the ":ptag" when there is no word under the cursor, and a few other
" things. Opens the tag under cursor in Preview window.
hi previewWord term=bold ctermbg=green guibg=green
func! PreviewWord() abort
  if &previewwindow
    return
  endif
  let w = expand("<cword>")
  if w =~ '\a'
    try
      exe "ptag " . w
    catch
      return
    endtry
    silent! wincmd P
    if &previewwindow
      if has("folding")
        silent! .foldopen
      endif
      call search("$", "b")
      let w = substitute(w, '\\', '\\\\', "")
      call search('\<\V' . w . '\>')
      exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
      wincmd p
    endif
  endif
endfunc

func! ListMonths() abort
  let l:line = getline(".")
  let l:last_word_start_idx = match(l:line, '\w*$')
  let l:last_word = matchstr(l:line, '\w*$')
  let l:months = ['January', 'February', 'March', 'April', 'May', 'June',
        \ 'July', 'August', 'September',
        \ 'October', 'November', 'December']
  call filter(l:months, 'v:val =~ "^' . l:last_word . '"')
  echom 'l:last_word_start_idx = ' . l:last_word_start_idx
  echom 'l:last_word = ' . l:last_word
  echom 'l:months = ' . string(l:months)
  call complete(l:last_word_start_idx + 1, l:months)
  return ''
endfunc
