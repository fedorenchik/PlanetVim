scriptversion 4

func! planet#menu#dev#update() abort
  if g:PlanetVim_menus_dev
    " LSP
    an 300.10  ❇️&[.LSP <Nop>
    an disable ❇️&[.LSP
    an 300.10  ❇️&[.Choose\ Symbol<Tab>:Clap\ tags\ vim_lsp :Clap tags vim_lsp<CR>
    an 300.10  ❇️&[.Document\ Symbol\ Choose                :LspDocumentSymbolSearch<CR>
    an 300.10  ❇️&[.&Workspace\ Symbols\ Choose             :LspWorkspaceSymbolSearch<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.&Definition                             :LspDefinition<CR>
    an 300.10  ❇️&[.De&claration                            :LspDeclaration<CR>
    an 300.10  ❇️&[.&References                             :LspReferences<CR>
    an 300.10  ❇️&[.&Implementation                         :LspImplementation<CR>
    an 300.10  ❇️&[.&Type\ Definition                       :LspTypeDefinition<CR>
    an 300.10  ❇️&[.Type\ &Hierarchy                        :LspTypeHierarchy<CR>
    an 300.10  ❇️&[.&Incoming\ Call\ Hierarchy              :LspCallHierarchyIncoming<CR>
    an 300.10  ❇️&[.&Outgoing\ Call\ Hierarchy              :LspCallHierarchyOutgoing<CR>
    an 300.10  ❇️&[.Symbol\ Hover                           :LspHover<CR>
    an 300.10  ❇️&[.Document\ Semantic\ Scopes              :LspSemanticScopes<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Preview\ Definition                     :LspPeekDefinition<CR>
    an 300.10  ❇️&[.Preview\ Declaration                    :LspPeekDeclaration<CR>
    an 300.10  ❇️&[.Preview\ Implementation                 :LspPeekImplementation<CR>
    an 300.10  ❇️&[.Preview\ Type\ Definition               :LspPeekTypeDefinition<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Rename                                  :LspRename<CR>
    an 300.10  ❇️&[.Code\ Action\ (LSP\ Quick\ &Fix)        :LspCodeAction<CR>
    an 300.10  ❇️&[.Code\ &Lens                             :LspCodeLens<CR>
    an 300.10  ❇️&[.Format\ Document                        :LspDocumentFormat<CR>
    an 300.10  ❇️&[.Format\ Document\ Selection             :LspDocumentRangeFormat<CR>
    an 300.10  ❇️&[.Update\ Document\ Folds                 :call PlanetVim_LSPUpdateFolds()<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Document\ Symbols                       :LspDocumentSymbol<CR>
    an 300.10  ❇️&[.Workspace\ Symbols                      :LspWorkspaceSymbol<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.&Previous\ Reference                    :LspPreviousReference<CR>
    an 300.10  ❇️&[.&Next\ Reference                        :LspNextReference<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Document\ Diagnostics                   :LspDocumentDiagnostics<CR>
    an 300.10  ❇️&[.Diagnostics\ (all\ buffers)             :LspDocumentDiagnostics --buffers=*<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Previous\ Error                         :LspPreviousError -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Error                             :LspNextError -wrap=0<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Previous\ Warning                       :LspPreviousWarning -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Warning                           :LspNextWarning -wrap=0<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Previous\ Diagnostic                    :LspPreviousDiagnostic -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Diagnostic                        :LspNextDiagnostic -wrap=0<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.Status.LSP\ Status                      :LspStatus<CR>
    an 300.10  ❇️&[.Status.Disable\ LSP                     :LspStopServer<CR>

    " Tags
    an 310.10  🪧&].Tags <Nop>
    an disable 🪧&].Tags
    an 310.10  🪧&].C&hoose<Tab>:Clap\ tags\ ctags           :Clap tags ctags<CR>
    an 310.10  🪧&].&Jump\ to\ Tag<Tab><C-]>                 <C-]>
    an 310.10  🪧&].&Jump\ Back<Tab><C-t>                    <C-t>
    an 310.10  🪧&].&Jump\ or\ Select\ Tag<Tab>g<C-]>        g<C-]>
    an 310.10  🪧&].&Select\ Tag<Tab>g]                      g]
    an 310.10  🪧&].Jump\ Split\ to\ Tag<Tab>+]              <C-w>]
    an 310.10  🪧&].Jump\ or\ Select\ Split\ to\ Tag<Tab>+g<C-]> <C-w>g<C-]>
    an 310.10  🪧&].Select\ Split\ Tag<Tab>+g]               <C-w>g]
    an 310.10  🪧&].Go\ to\ Tag\ VSplit<Tab>:vert stag       :vert stag <cword><CR>
    an 310.10  🪧&].--1-- <Nop>
    an 310.10  🪧&].Preview\ Tag<Tab>+}                      <C-w>}
    an 310.10  🪧&].Select\ Preview\ Tag<Tab>+g}             <C-w>g}
    an 310.10  🪧&].Preview\ Previous\ Tag<Tab>:ppop         :ppop<CR>
    an 310.10  🪧&].Close\ Preview<Tab>+z                    <C-w>z
    an 310.10  🪧&].--2-- <Nop>
    an 310.10  🪧&].Preview\ File<Tab>:pedit                 :pedit 
    an 310.10  🪧&].Preview\ Search<Tab>:psearch             :psearch 
    an 310.10  🪧&].--2-- <Nop>
    am 310.10  🪧&].First<Tab>[T                             [T
    am 310.10  🪧&].Previous<Tab>[t                          [t
    am 310.10  🪧&].Next<Tab>]t                              ]t
    am 310.10  🪧&].Last<Tab>]T                              ]T
    an 310.10  🪧&].--3-- <Nop>
    am 310.10  🪧&].Preview\ Previous<Tab>[<C-t>             [<C-t>
    am 310.10  🪧&].Preview\ Next<Tab>]<C-t>                 ]<C-t>
    an 310.10  🪧&].--4-- <Nop>
    am 310.10  🪧&].Toggle\ AutoPreview\ Tags                :call PlanetVim_TagsAutoPreview_Toggle()<CR>
    an 310.10  🪧&].--4-- <Nop>
    am 310.10  🪧&].Build\ tags\ File                        :!ctags -R .<CR>
    am 310.10  🪧&].Generate\ tags\.vim\ File                 :sp tags<CR>:%s/^\([^	:]*:\)\=\([^	]*\).*/syntax keyword Tag \2/<CR>:wq! tags.vim<CR>/^<CR>
    am 310.10  🪧&].Highlight\ tags\ from\ tags\.vim          :so tags.vim<CR>
    am 310.10  🪧&].Generate\ types\.vim\ File                :!ctags --c-kinds=gstu -o- *.[ch] \| awk 'BEGIN{printf("syntax keyword Type\t")} {printf("%s ", $1)}END{print "")' > types.vim
    am 310.10  🪧&].Highlight\ tags\ from\ types\.vim         :so types.vim<CR>

    " Build
    " Build process:
    " * Setup Libs
    "         * qt
    "         * pkgbuild
    "         * meson-wrapdb
    "         * boost
    " * Package manager
    "         * conan
    "         * pip
    " * Choose Build Generator (CMake)
    "         * Makefile
    "         * Ninja
    " * Choose compiler
    "         * gcc
    "         * clang
    "         * wasm / emcc / emscripten
    " * Set Cross-Compiler (build, host)
    "         * gcc-mingw
    "         * gcc-arm
    "         * etc...
    " * Set env vars: environ(), getenv(), setenv()
    " * Set Canadian-Cross (build, host, target)
    " * Choose debugger
    "         * gdb
    "         * lldb
    " * Select build folder
    "   (search for ./build* and ../build* folders), choose new
    " * Choose Build Target
    " TODO: all targets print to new buffer in special window at bottom with WinBar
    " TODO: buftype=terminal
    " TODO: setlocal bufhidden=hide
    " TODO: call term_setrestore(buf_nr, "NONE") # for non-restorable terminals
    an 500.10  🎚️&{.Project <Nop>
    an disable 🎚️&{.Project
    an 500.10  🎚️&{.Arduino.Choose\ Board           :ArduinoChooseBoard<CR>
    an 500.10  🎚️&{.Arduino.Choose\ Programmer      :ArduinoChooseProgrammer<CR>
    an 500.10  🎚️&{.Arduino.Choose\ Port            :ArduinoChoosePort<CR>
    an 500.10  🎚️&{.Arduino.Verify                  :ArduinoVerify<CR>
    an 500.10  🎚️&{.Arduino.Upload                  :ArduinoUpload<CR>
    an 500.10  🎚️&{.Arduino.Serial                  :ArduinoSerial<CR>
    an 500.10  🎚️&{.Arduino.Upload\ and\ Serial     :ArduinoUploadAndSerial<CR>
    an 500.10  🎚️&{.Arduino.Info                    :ArduinoInfo<CR>
    an 500.10  🎚️&{.Arduino.Set\ Baud               :ArduinoSetBaud<CR>
    an 500.10  🎚️&{.PlatformIO.Edit\ Settings       :e platformio.ini<CR>
    an 500.10  🎚️&{.ROS.Setup                       :TODO
    an 500.10  🎚️&{.Yocto.Setup                     :TODO
    an 500.10  🎚️&{.Configuration <Nop>
    an disable 🎚️&{.Configuration
    an 500.10  🎚️&{.Settings <Nop>
    an disable 🎚️&{.Settings
    an 500.10  🎚️&{.&direnv.&Run\ \.envrc                    :DirenvExport<CR>
    an 500.10  🎚️&{.&direnv.E&dit\ \.envrc                   :EditEnvrc<CR>
    an 500.10  🎚️&{.&direnv.Add\ N&ew                        :TODO
    an 500.10  🎚️&{.&direnv.Edit\ diren&vrc                  :EditDirenvrc<CR>
    an 500.10  🎚️&{.editorconfig.Add\ New                    :TODO
    an 500.10  🎚️&{.editorconfig.Reload                      :EditorConfigReload<CR>
    an 500.10  🎚️&{.editorconfig.Disable\ for\ buffer        :let b:EditorConfig_disable=1<CR>

    an 500.10  📐&}.Dev\ Tools <Nop>
    an disable 📐&}.Dev\ Tools
    an 500.10  📐&}.uic                                      :TODO
    an 500.10  📐&}.moc                                      :TODO
    an 500.10  📐&}.moc-ng                                   :TODO
    an 500.10  📐&}.rcc                                      :TODO
    an 500.10  📐&}.flex                                     :TODO
    an 500.10  📐&}.bison                                    :TODO
    an 500.10  📐&}.Qt\ Designer                             :TODO
    an 500.10  📐&}.Generate\ qt\.conf                       :TODO
    an 500.10  📐&}.Qt\ Tools                                :TODO
    an 500.10  📐&}.Gtk\ Tools                               :TODO
    an 500.10  📐&}.i10n\ &&\ i18n <Nop>
    an disable 📐&}.i10n\ &&\ i18n
    an 500.10  📐&}.lupdate                                  :TODO
    an 500.10  📐&}.lrelease                                 :TODO
    an 500.10  📐&}.auto-translation                         :TODO
    an 500.10  📐&}.gettext                                  :TODO
    an 500.10  📐&}.weblate.org                              :TODO
    an 500.10  📐&}.Documentation <Nop>
    an disable 📐&}.Documentation
    an 500.10  📐&}.doxygen                                  :TODO
    an 500.10  📐&}.Qt\ Doc                                  :TODO
    an 500.10  📐&}.Qt\ Help                                 :TODO
    an 500.10  📐&}.readthedocs                              :TODO
    an 500.10  📐&}.gitbook                                  :TODO

    an 500.10  🔨&u.Build <Nop>
    an disable 🔨&u.Build
    an 500.10  🔨&u.Virtual\ Environments <Nop>
    an disable 🔨&u.Virtual\ Environments
    an 500.10  🔨&u.Schroot.Debootstrap             :!sudo debootstrap --variant=buildd --arch=amd64 buster /var/chroots/debian10_x64 http://ftp.debian.org/debian/<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Check\ Config  :TODO"check $HOME is not mounted!!!
    an 500.10  🔨&u.Schroot.Schroot\ Add\ New       :TODO"create config file in /etc/schroot/chroot.d/ directory
    an 500.10  🔨&u.Schroot.Schroot\ List           :!schroot -l<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Info           :!schroot -i<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Config         :!schroot --config<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Location       :!schroot --location<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Start          :!schroot -c debian10_x64 -u leonid<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Start\ Root    :!schroot -c debian10_x64 -u leonid<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Start\ XNest   :!schroot -c debian10_x64 -u leonid<CR>
    an 500.10  🔨&u.Schroot.Schroot\ Run\ Command   :!schroot -c debian10_x64 -u leonid {cmd}<CR>
    an 500.10  🔨&u.Pipenv.Test                     :TODO
    an 500.10  🔨&u.Conan\ Virtual\ Environment.Test                     :TODO
    an 500.10  🔨&u.systemd-nspawn.Test                     :TODO
    an 500.10  🔨&u.PRoot.Test                     :TODO
    an 500.10  🔨&u.Fakechroot.Test                     :TODO
    an 500.10  🔨&u.Docker.Test                     :TODO
    an 500.10  🔨&u.Vagrant.Test                     :TODO
    an 500.10  🔨&u.QEMU.Test                     :TODO
    an 500.10  🔨&u.Build\ Systems <Nop>
    an disable 🔨&u.Build\ Systems
    an 500.10  🔨&u.&Autotools.Autotools\ Status                  :call planet#util#term#run_script_output('autotools-status')<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoconf                      :!autoconf -f -i<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoreconf                    :!autoreconf -f -i<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoheader                    :!autoheader<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoscan                      :!autoscan<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoupdate                    :!autoupdate<CR>
    an 500.10  🔨&u.&Autotools.Run\ ifnames                       :!ifnames<CR>
    an 500.10  🔨&u.&Autotools.Run\ libtool                       :!libtool<CR>
    an 500.10  🔨&u.&Autotools.Run\ libtoolize                    :!libtoolize<CR>
    an 500.10  🔨&u.&Autotools.Generate\ \./autogen\.sh           :TODO:"generate standard autogen.sh
    an 500.10  🔨&u.&Autotools.Run\ \./autogen\.sh                :!./autogen.sh<CR>
    an 500.10  🔨&u.&Autotools.Run\ \./bootstrap\.sh              :!./bootstrap.sh<CR>
    an 500.10  🔨&u.&Autotools.Run\ \./&configure                  :!./configure<CR>
    an 500.10  🔨&u.&Autotools.Open\ config\.log                  :TODO:"open instead of terminal
    an 500.10  🔨&u.Mak&e.&Make                                    :call planet#util#term#run_cmd_output('make')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &All                               :call planet#util#term#run_cmd_output('make all')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Help                              :call planet#util#term#run_cmd_output('make help')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Clean                             :call planet#util#term#run_cmd_output('make clean')<CR>
    an 500.10  🔨&u.Mak&e.Make\ Distclea&n                         :call planet#util#term#run_cmd_output('make distclean')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Dist                              :call planet#util#term#run_cmd_output('make dist')<CR>
    an 500.10  🔨&u.Mak&e.Make\ Di&stcheck                         :call planet#util#term#run_cmd_output('make distcheck')<CR>
    an 500.10  🔨&u.Mak&e.Make\ Chec&k                             :call planet#util#term#run_cmd_output('make check')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Test                              :call planet#util#term#run_cmd_output('make test')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Install                           :call planet#util#term#run_cmd_output('make install')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Uninstall                         :call planet#util#term#run_cmd_output('make uninstall')<CR>
    an 500.10  🔨&u.Mak&e.Set\ &prefix                             :!make<CR>
    an 500.10  🔨&u.Mak&e.Set\ DESTDI&R                            :!make<CR>
    an 500.10  🔨&u.&KBuild.make\ oldconfig                        :!make<CR>
    an 500.10  🔨&u.&KBuild.make\ menuconfig                       :!make<CR>
    an 500.10  🔨&u.&KBuild.Edit\ \.config                         :!make<CR>
    an 500.10  🔨&u.&KBuild.Set\ DESTDIR                           :!make<CR>
    an 500.10  🔨&u.&CMake.Set\ DESTDIR                            :!make<CR>
    an 500.10  🔨&u.&QMake.Set\ DESTDIR                            :!make<CR>
    an 500.10  🔨&u.Scons.Set\ DESTDIR                             :!make<CR>
    an 500.10  🔨&u.Nin&ja.Set\ DESTDIR                            :!make<CR>
    an 500.10  🔨&u.&Meson.Set\ DESTDIR                            :!make<CR>
    an 500.10  🔨&u.Deploy <Nop>
    an disable 🔨&u.Deploy
    an 500.10  🔨&u.Windeployqt.Build                                    :!make<CR>
    an 500.10  🔨&u.Macdeployqt.Build                                    :!make<CR>
    an 500.10  🔨&u.Linuxdeploy.Build                                    :!make<CR>
    an 500.10  🔨&u.Package <Nop>
    an disable 🔨&u.Package
    an 500.10  🔨&u.fpm.Build                                    :!make<CR>
    an 500.10  🔨&u.pyInstaller.Build                                    :!make<CR>
    an 500.10  🔨&u.CPack.Build                                    :!make<CR>
    an 500.10  🔨&u.AppImage.Build                                    :!make<CR>
    an 500.10  🔨&u.Snap.Build                                    :!make<CR>
    an 500.10  🔨&u.FlatPak.Build                                    :!make<CR>
    an 500.10  🔨&u.pyUpdater.Build                                    :!make<CR>
    an 500.10  🔨&u.Installer <Nop>
    an disable 🔨&u.Installer
    an 500.10  🔨&u.Qt\ Installer\ Framework.Build                                    :!make<CR>
    " an 500.10  🔨&u.Choose\ Make\ Target                      :make <C-z>"TODO
    " an 500.10  🔨&u.Rerun\ Previous\ Make                     :make prev_target
    " an 500.10  🔨&u.--1-- <Nop>
    " an 500.10  🔨&u.Set\ Compiler\ Globally<Tab>:compiler!\ {compiler} :compiler! 
    " an 500.10  🔨&u.Set\ Compiler\ for\ Buffer<Tab>:compiler\ {compiler} :compiler 

    " Run
    an 510.10  ▶️&r.Run <Nop>
    an disable ▶️&r.Run
    an 510.10  ▶️&r.Configurations                              :

    " Debug
    an 520.10  🐞&d.Debug <Nop>
    an disable 🐞&d.Debug
    an 520.10  🐞&d.Start\ &Debug                             :Vimspector<CR>
    an 520.10  🐞&d.Detach\ Debugger                          :Vimspector<CR>
    an 520.10  🐞&d.Stop\ &Debug                              :Vimspector<CR>
    an 520.10  🐞&d.--1-- <Nop>

    " Test
    an 530.10  🧪&j.Test <Nop>
    an disable 🧪&j.Test
    an 530.10  🧪&j.Nearest                                 :TestNearest<CR>
    an 530.10  🧪&j.File                                    :TestFile<CR>
    an 530.10  🧪&j.Suite                                   :TestSuite<CR>
    an 530.10  🧪&j.Last                                    :TestLast<CR>
    an 530.10  🧪&j.Visit                                   :TestVisit<CR>
    an 530.10  🧪&j.Qt\ Test                                :TestVisit<CR>
    an 530.10  🧪&j.Google\ Test                            :TestVisit<CR>
    an 530.10  🧪&j.Boost\ Test                             :TestVisit<CR>
    an 530.10  🧪&j.Catch2\ Test                            :TestVisit<CR>
    an 530.10  🧪&j.Report\ Tools.Screenshot                :TestVisit<CR>
    an 530.10  🧪&j.Report\ Tools.Record\ gif               :TestVisit<CR>
    an 530.10  🧪&j.Report\ Tools.Record\ screen            :TestVisit<CR>

    " Analyze
    an 540.10  🔬&y.Analyze <Nop>
    an disable 🔬&y.Analyze
    an 540.10  🔬&y.Check                                   :
    an 540.10  🔬&y.Clang-Tidy                                :Vimspector<CR>
    an 540.10  🔬&y.Clazy                                     :Vimspector<CR>
    an 540.10  🔬&y.Cppcheck                                  :Vimspector<CR>
    an 540.10  🔬&y.Chrome\ Trace\ Format\ Visualizer         :Vimspector<CR>
    an 540.10  🔬&y.Performance\ Analyzer                     :Vimspector<CR>
    an 540.10  🔬&y.Memcheck                                  :Vimspector<CR>
    an 540.10  🔬&y.Memcheck\ Gdb                             :Vimspector<CR>
    an 540.10  🔬&y.Callgrind                                 :Vimspector<CR>
    an 540.10  🔬&y.QML\ Profiler                             :Vimspector<CR>

    " Terminal
    an 550.10  💻&t.Terminal <Nop>
    an disable 💻&t.Terminal
    an 550.10  💻&t.N&ew                                    :botright terminal ++kill=kill ++rows=10<CR>
    an 550.10  💻&t.New\ &Here                             :terminal ++curwin ++kill=kill<CR>
    an 550.10  💻&t.New\ &VSplit                           :vertical terminal ++kill=kill<CR>
    an 550.10  💻&t.New\ &Tab                              :tab terminal ++kill=kill<CR>
    an 550.10  💻&t.New\ &Below                            :rightbelow terminal ++kill=kill ++rows=10<CR>
    an 550.10  💻&t.--1-- <Nop>
    an 550.10  💻&t.P&ython\ Shell                         :botright terminal ++kill=kill ++rows=10 python<CR>
    an 550.10  💻&t.C&++\ Shell                            :botright terminal ++kill=kill ++rows=10 cling<CR>
    an 550.10  💻&t.Terminal\ List <Nop>
    an disable 💻&t.Terminal\ List
    "TODO: terminal list: call term_list()
  else
    silent! aunmenu ❇️&[
    silent! aunmenu 🪧&]
    silent! aunmenu 🔨&u
    silent! aunmenu ▶️&r
    silent! aunmenu 🐞&d
    silent! aunmenu 🧪&j
    silent! aunmenu 🔬&y
    silent! aunmenu 💻&t
  endif
endfunc
