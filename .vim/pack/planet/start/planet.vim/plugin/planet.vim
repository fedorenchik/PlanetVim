scriptversion 4

let g:PV_config = "$HOME/.vim/planetvimrc.vim"
if filereadable(expand(g:PV_config))
  silent exe "source " .. fnameescape(g:PV_config)
endif

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

aug AugPv_MenuBuffers
au!
au BufCreate,BufFilePost * call planet#buffer#AddBufferAu()
au BufDelete,BufFilePre * call planet#buffer#RemoveBufferAu()
aug END

aug AugPv_Session
au!
au SessionLoadPost * call planet#session#SetCurrent()
au VimEnter * call planet#session#MenuList()
au VimEnter * call planet#gui#WorkspaceListMenu()
au VimEnter * call planet#gui#MenuListVimServers()
au VimEnter * call planet#gui#MenuListGuiWindows()
au SessionLoadPost * call planet#run#InitRunConfigurations()
aug END

if ! exists("g:PlanetVim_menus_planet")
  let g:PlanetVim_menus_planet = 1
endif
call planet#menu#planet#update()

if ! exists("g:PlanetVim_menus_basic")
  let g:PlanetVim_menus_basic = 1
endif
call planet#menu#basic#update()

if ! exists("g:PlanetVim_menus_editing")
  let g:PlanetVim_menus_editing = 1
endif
call planet#menu#edit#update()

if ! exists("g:PlanetVim_menus_dev")
  let g:PlanetVim_menus_dev = 1
endif
call planet#menu#dev#update()

if ! exists("g:PlanetVim_menus_tools")
  let g:PlanetVim_menus_tools = 1
endif
call planet#menu#tools#update()

if ! exists("g:PlanetVim_menus_nav")
  let g:PlanetVim_menus_nav = 1
endif
call planet#menu#nav#update()

if ! exists("g:PlanetVim_menus_settings")
  let g:PlanetVim_menus_settings = 1
endif
call planet#menu#settings#update()

if ! exists("g:PV_mode")
  let g:PV_mode = 's'
end
if g:PV_mode == 'e'
  call planet#planet#SetEasyMode()
elseif g:PV_mode == 's'
  call planet#planet#SetStandardMode()
elseif g:PV_mode == 'p'
  call planet#planet#SetSuperChargedMode()
end

" Writing
an 600.10  ]Writing.Writing <Nop>
an disable ]Writing.Writing
an 600.20  ]Writing.Swap\ Words                   :TODO
an 600.20  ]Writing.Swap\ Words\ After            :TODO
an 600.40  ]Writing.Thesaurus                     :TODO
an 600.50  ]Writing.Generate\ Sample\ Text        :TODO
an 600.50  ]Writing.Left\ Align<Tab>:left         :left<CR>
an 600.50  ]Writing.Center\ Align<Tab>:center     :center<CR>
an 600.50  ]Writing.Right\ Align<Tab>:right       :right<CR>

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


