vim9script noclear
# TODO: $VIMRUNTIME folder
# TODO: Vim help reference
# TODO: VS Code
# TODO: Qt Creator
# TODO: LibreOffice
# TODO: Use $VIMRUNTIME/tools/demoserver.py for controlling Vim
# TODO: Add Buffer Cmdline Window: Input commands and ouput results in
# TODO:    'prompt' buffer.
# TODO: Add sessions inside project dir support
# Custom config file: $HOME/.vim/planetvimrc.vim
#TODO: Add function to follow DE night mode & theme settings (auto switch
#TODO: guioptions+=d when dark theme, auto switch to dark colorscheme variant)

#TODO: add setting 'equalprg' for formatting wih == (clang-format, etc.)
#TODO: Choise between text, emoji, symbols, nerdicons menus
#TODO: Customize tabline-menu when vim bug #7991 is fixed
#TODO: Add prompt buffer to exec viml commands
#TODO: menus:
#TODO:    C++
#TODO:    Python
#TODO:    Arduino
#TODO:    PlatformIO
#TODO:    CMake
#TODO:    Meson
#TODO:    Conan
#TODO:    Qt (uic, moc, rcc, lupdate, lrelease, shiboken)
#TODO:    SWIG,
#TODO:    Latex
#TODO:    Writing
#TODO:    Docker
#TODO:    Yocto
#TODO:    ROS
#TODO:    gdb/lldb
#TODO:    cppcheck/clazy/clang-tidy
#TODO:    indent/astyle/clang-format
#TODO:    LKD: linux kernel development: patches, checkpatch.pl, get-maintainers.sh, send-email
#TODO:    kvm,virsh,qemu cli
#TODO:    chroot,schroot,conan_venv
#TODO:    unreal engine, godot
#TODO: detect 'rtp' based on v:progname ('pvim') (v:progname for PlanetVim
#TODO:    package is 'pvim'

planet#config#Initialize()

# Git is optional for editor startup. Apply this after the user's config and
# before bundled GitGutter loads; explicit preferences remain authoritative.
if !exists('g:gitgutter_enabled')
  g:gitgutter_enabled = executable(get(g:, 'gitgutter_git_executable', 'git'))
endif

planet#menu#Refresh()

# Avoid the ":ptag" when there is no word under the cursor, and a few other
# things. Opens the tag under cursor in Preview window.
hi previewWord term=bold ctermbg=green guibg=green
# Vim 9.1 loses :legacy modifiers when evaluating numeric tag-file addresses.
# A legacy function supplies the required context for this native command only.
function LocalPreviewTag(word) abort
  execute 'ptag ' .. a:word
endfunction

def! g:PreviewWord(): any
  if &previewwindow
    return 0
  endif
  var w: any = expand("<cword>")
  if w =~ '\a'
    try
      LocalPreviewTag(w)
    catch
      return 0
    endtry
    silent! wincmd P
    if &previewwindow
      if has("folding")
        silent! :.foldopen
      endif
      search("$", "b")
      w = substitute(w, '\\', '\\\\', "")
      search('\<\V' .. w .. '\>')
      exe 'match previewWord "\%' .. line(".") .. 'l\%' .. col(".") .. 'c\k*"'
      wincmd p
    endif
  endif
  return 0
enddef

def! g:ListMonths(): any
  var line: any = getline(".")
  var last_word_start_idx: any = match(line, '\w*$')
  var last_word: any = matchstr(line, '\w*$')
  var months: any = ['January', 'February', 'March', 'April', 'May', 'June',  'July', 'August', 'September',  'October', 'November', 'December']
  filter(months, (_, month) => month =~# '^' .. last_word)
  echom 'l:last_word_start_idx = ' .. last_word_start_idx
  echom 'l:last_word = ' .. last_word
  echom 'l:months = ' .. string(months)
  complete(last_word_start_idx + 1, months)
  return ''
enddef
