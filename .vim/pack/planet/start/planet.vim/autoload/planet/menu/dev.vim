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
    an 310.10  🪧&].C&hoose<Tab>:Clap\ tags\ ctags          :Clap tags ctags<CR>
    an 310.10  🪧&].&Jump\ to\ Tag<Tab><C-]>                <C-]>
    an 310.10  🪧&].&Jump\ Back<Tab><C-t>                   <C-t>
    an 310.10  🪧&].&Jump\ or\ Select\ Tag<Tab>g<C-]>       g<C-]>
    an 310.10  🪧&].&Select\ Tag<Tab>g]                     g]
    an 310.10  🪧&].Jump\ Split\ to\ Tag<Tab>+]             <C-w>]
    an 310.10  🪧&].Jump\ or\ Select\ Split\ to\ Tag<Tab>+g<C-]> <C-w>g<C-]>
    an 310.10  🪧&].Select\ Split\ Tag<Tab>+g]              <C-w>g]
    an 310.10  🪧&].Go\ to\ Tag\ VSplit<Tab>:vert stag      :vert stag <cword><CR>
    an 310.10  🪧&].--1-- <Nop>
    an 310.10  🪧&].Preview\ Tag<Tab>+}                     <C-w>}
    an 310.10  🪧&].Select\ Preview\ Tag<Tab>+g}            <C-w>g}
    an 310.10  🪧&].Preview\ Previous\ Tag<Tab>:ppop        :ppop<CR>
    an 310.10  🪧&].Close\ Preview<Tab>+z                   <C-w>z
    an 310.10  🪧&].--2-- <Nop>
    an 310.10  🪧&].Preview\ File<Tab>:pedit                :pedit 
    an 310.10  🪧&].Preview\ Search<Tab>:psearch            :psearch 
    an 310.10  🪧&].--2-- <Nop>
    am 310.10  🪧&].First<Tab>[T                            [T
    am 310.10  🪧&].Previous<Tab>[t                         [t
    am 310.10  🪧&].Next<Tab>]t                             ]t
    am 310.10  🪧&].Last<Tab>]T                             ]T
    an 310.10  🪧&].--3-- <Nop>
    am 310.10  🪧&].Preview\ Previous<Tab>[<C-t>            [<C-t>
    am 310.10  🪧&].Preview\ Next<Tab>]<C-t>                ]<C-t>
    an 310.10  🪧&].--4-- <Nop>
    am 310.10  🪧&].Toggle\ AutoPreview\ Tags               :call PlanetVim_TagsAutoPreview_Toggle()<CR>
    an 310.10  🪧&].--4-- <Nop>
    am 310.10  🪧&].Build\ tags\ File                       :call planet#term#RunCmd('ctags -R .')<CR>
    am 310.10  🪧&].Generate\ tags\.vim\ File               :sp tags<CR>:%s/^\([^	:]*:\)\=\([^	]*\).*/syntax keyword Tag \2/<CR>:wq! tags.vim<CR>/^<CR>
    am 310.10  🪧&].Highlight\ tags\ from\ tags\.vim        :so tags.vim<CR>
    am 310.10  🪧&].Generate\ types\.vim\ File              :!ctags --c-kinds=gstu -o- *.[ch] \| awk 'BEGIN{printf("syntax keyword Type\t")} {printf("%s ", $1)}END{print "")' > types.vim
    am 310.10  🪧&].Highlight\ tags\ from\ types\.vim       :so types.vim<CR>

    an 500.10  🎚️&{.Virtual\ Environments <Nop>
    an disable 🎚️&{.Virtual\ Environments
    an 500.10  🎚️&{.&Docker.Test                            :TODO
    an 500.10  🎚️&{.&Pipenv.Start\ Shell                    :call planet#term#RunCmd('pipenv shell')<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ python\ main\.py           :call planet#term#RunCmd('pipenv run python ./main.py')<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ python\ app\.py            :call planet#term#RunCmd('pipenv run python ./app.py')<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ Command                    :call planet#term#RunCmd('pipenv run ...TODO')<CR>
    an 500.10  🎚️&{.&Pipenv.Update\ Pipfile\.lock           :call planet#term#RunCmd('pipenv lock')<CR>
    an 500.10  🎚️&{.&Pipenv.--1-- <Nop>
    an 500.10  🎚️&{.&Pipenv.New\ Project                    :call planet#term#RunCmd('pipenv --three')<CR>
    an 500.10  🎚️&{.&Pipenv.New\ Project\ with\ Python      :call planet#term#RunCmd('pipenv --python ...TODO')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Run\ &&\ Dev\ Deps     :call planet#term#RunCmd('pipenv install --dev')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Run\ Deps              :call planet#term#RunCmd('pipenv install')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Package                :call planet#term#RunCmd('pipenv install ...TODO')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Dev\ Package           :call planet#term#RunCmd('pipenv install --dev ...TODO')<CR>
    an 500.10  🎚️&{.&Pipenv.Update\ (Lock\ &&\ Sync)        :call planet#term#RunCmd('pipenv update')<CR>
    an 500.10  🎚️&{.&Pipenv.Sync\ with\ Pipfile\.lock       :call planet#term#RunCmd('pipenv sync')<CR>
    an 500.10  🎚️&{.&Pipenv.--1-- <Nop>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Leftover\ Packages   :call planet#term#RunCmd('pipenv clean')<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Package              :call planet#term#RunCmd('pipenv uninstall ...TODO')<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Dev                  :call planet#term#RunCmd('pipenv uninstall --all-dev')<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ All                  :call planet#term#RunCmd('pipenv uninstall --all')<CR>
    an 500.10  🎚️&{.&Pipenv.Remove\ Project's\ VEnv         :call planet#term#RunCmd('pipenv --rm')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install      :call planet#term#RunCmd('pipenv install -r requirements.txt')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install\ Dev :call planet#term#RunCmd('pipenv install -r dev-requirements.txt --dev')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export       :call planet#term#RunCmd('pipenv lock -r > requirements.txt')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export\ Dev  :call planet#term#RunCmd('pipenv lock -r -d > dev-requirements.txt')<CR>
    an 500.10  🎚️&{.&Pipenv.--1-- <Nop>
    an 500.10  🎚️&{.&Pipenv.Open\ Specified\ Module         :call planet#term#RunCmd('pipenv open ...TODO')<CR>
    an 500.10  🎚️&{.&Pipenv.Security\ Check                 :call planet#term#RunCmd('pipenv check')<CR>
    an 500.10  🎚️&{.&Pipenv.Dependency\ Graph               :call planet#term#RunCmd('pipenv graph')<CR>
    an 500.10  🎚️&{.&Pipenv.Reverse\ Dependency\ Graph      :call planet#term#RunCmd('pipenv graph --reverse')<CR>
    an 500.10  🎚️&{.&Pipenv.Enable\ Site\ Packages          :call planet#term#RunCmd('pipenv --site-packages')<CR>
    an 500.10  🎚️&{.&Pipenv.Disable\ Site\ Packages         :call planet#term#RunCmd('pipenv --no-site-packages')<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Project\ Root            :call planet#term#RunCmd('pipenv --where')<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ VEnv\ Dir                :call planet#term#RunCmd('pipenv --venv')<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Env\ Vars                :call planet#term#RunCmd('pipenv --envs')<CR>
    an 500.10  🎚️&{.&Pipenv.Edit\ \.env                     :e .env<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Version                  :call planet#term#RunCmd('pipenv --version')<CR>
    an 500.10  🎚️&{.&Pipenv.Clear\ Caches                   :call planet#term#RunCmd('pipenv --clear')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Pipenv                 :call planet#term#RunCmd('pip install --user pipenv')<CR>
    an 500.10  🎚️&{.C&onda.Activate                         :call planet#term#RunCmd('conda activate <venv-name>TODO')
    an 500.10  🎚️&{.C&onda.Install\ from\ requirements\.txt :call planet#term#RunCmd('conda install --file requirements.txt')<CR>
    an 500.10  🎚️&{.C&onda.Create\ from\ environment\.yml   :call planet#term#RunCmd('conda env create -f environment.yml')<CR>
    an 500.10  🎚️&{.C&onda.Deactivate                       :call planet#term#RunCmd('conda deactivate')<CR>
    an 500.10  🎚️&{.C&onda.Create\ venv                     :call planet#term#RunCmd('conda create -n <venv-name>')
    an 500.10  🎚️&{.C&onda.Activate\ Anaconda               :call planet#term#RunCmd('source /opt/anaconda/bin/activate')<CR>
    an 500.10  🎚️&{.C&onda.Deactivate\ Anaconda             :call planet#term#RunCmd('source /opt/anaconda/bin/deactivate')<CR>
    an 500.10  🎚️&{.Vagrant.Test                            :TODO
    an 500.10  🎚️&{.QEMU.Test                               :TODO
    an 500.10  🎚️&{.QEMU\ Schroot.qemu-debootstrap          :TODO
    "TODO:
    " an 500.10  🎚️&{.Schroot.Debootstrap                    :!sudo debootstrap --variant=buildd --arch=amd64 buster /var/chroots/debian10_x64 http://ftp.debian.org/debian/<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Check\ Config         :TODO"check $HOME is not mounted!!!
    " an 500.10  🎚️&{.Schroot.Schroot\ Add\ New              :TODO"create config file in /etc/schroot/chroot.d/ directory
    " an 500.10  🎚️&{.Schroot.Schroot\ List                  :!schroot -l<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Info                  :!schroot -i<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Config                :!schroot --config<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Location              :!schroot --location<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Start                 :!schroot -c debian10_x64 -u leonid<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Start\ Root           :!schroot -c debian10_x64 -u leonid<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Start\ XNest          :!schroot -c debian10_x64 -u leonid<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Run\ Command          :!schroot -c debian10_x64 -u leonid {cmd}<CR>
    " an 500.10  🎚️&{.Conan\ Virtual\ Environment.Test       :TODO
    " an 500.10  🎚️&{.systemd-nspawn.Test                    :TODO
    " an 500.10  🎚️&{.PRoot.Test                             :TODO
    " an 500.10  🎚️&{.Fakechroot.Test                        :TODO
    an 500.10  🎚️&{.Configuration <Nop>
    an disable 🎚️&{.Configuration
    an 500.10  🎚️&{.Install\ Qt.Set\ $QTDIR                 <Cmd>call planet#env#SetEnvVar('QTDIR')<CR>
    an 500.10  🎚️&{.Install\ Qt.Choose\ Version             :aqtinstall ...
    an 500.10  🎚️&{.Install\ Conan\ Pkg.TODO                :TODO
    an 500.10  🎚️&{.Install\ pip\ Pkg.TODO                  :TODO
    an 500.10  🎚️&{.Set\ Compiler.gcc                       :TODO
    an 500.10  🎚️&{.Set\ Compiler.clang                     :TODO
    an 500.10  🎚️&{.Set\ Compiler.emcc\ (wasm,\ emscripten) :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.Raspberry\ Pi    :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.ESP32            :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.Arduino          :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.Jetson\ Nano     :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.BeagleBone\ Black :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.Coral            :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.HiKey970         :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.--1-- <Nop>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Host             :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.Target           :TODO
    an 500.10  🎚️&{.Set\ Cross-Compilation.Sysroot          :TODO
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Build  :TODO
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Host   :TODO
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Target :TODO
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Sysroot :TODO
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-mingw           :TODO
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-arm             :TODO
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-aarch64         :TODO
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-avr             :TODO
    an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Installed    :call planet#term#RunCmd('pyenv versions')<CR>
    an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Available    :call planet#term#RunCmd('pyenv install --list')<CR>
    an 500.10  🎚️&{.Settings <Nop>
    an disable 🎚️&{.Settings
    an 500.10  🎚️&{.&Env.Print\ Env                         <Cmd>call planet#env#PrintEnv()<CR>
    an 500.10  🎚️&{.&Env.Set\ $DESTDIR                      <Cmd>call planet#env#SetEnvVar('DESTDIR')<CR>
    an 500.10  🎚️&{.&Env.Set\ $PYTHONPATH                   <Cmd>call planet#env#SetEnvVar('PYTHONPATH')<CR>
    an 500.10  🎚️&{.&Env.Set\ $PATH                         <Cmd>call planet#env#SetEnvVar('PATH')<CR>
    an 500.10  🎚️&{.&Env.Set\ $ARCH                         <Cmd>call planet#env#SetEnvVar('ARCH')<CR>
    an 500.10  🎚️&{.&Env.Set\ $CROSS_COMPILE                <Cmd>call planet#env#SetEnvVar('CROSS_COMPILE')<CR>
    an 500.10  🎚️&{.&Env.Set\ Env\ Var                      <Cmd>call planet#env#NewEnvVar()<CR>
    an 500.10  🎚️&{.&Env.Edit\ Env\ in\ Buffer              <Cmd>call planet#env#BufferFromCmd('env')<CR>
    an 500.10  🎚️&{.&Env.Edit\ \.env                        <Cmd>e .env<CR>
    an 500.10  🎚️&{.&Env.Source\ \.env                      <Cmd>Dotenv .env<CR>
    an 500.10  🎚️&{.&Direnv.&Edit\ (or\ Create)\ \.envrc    <Cmd>EditEnvrc<CR>
    an 500.10  🎚️&{.&Direnv.&Allow\ Here                    <Cmd>call planet#term#RunCmd('direnv allow')<CR>
    an 500.10  🎚️&{.&Direnv.&Run\ \.envrc                   <Cmd>DirenvExport<CR>
    an 500.10  🎚️&{.&Direnv.E&dit\ \.direnvrc               <Cmd>EditDirenvrc<CR>
    an 500.10  🎚️&{.EditorConfig.Add\ New                   <Cmd>e .editorconfig<CR>
    an 500.10  🎚️&{.EditorConfig.Reload                     <Cmd>EditorConfigReload<CR>
    an 500.10  🎚️&{.EditorConfig.Disable\ for\ buffer       <Cmd>let b:EditorConfig_disable=1<CR>

    an 500.10  📐&}.Dev\ Tools <Nop>
    an disable 📐&}.Dev\ Tools
    an 500.10  📐&}.Parser\ Generators.flex                 :TODO
    an 500.10  📐&}.Parser\ Generators.bison                :TODO
    an 500.10  📐&}.&Qt\ Tools.Qt\ Creator                  <Cmd>call planet#term#RunGuiApp('qtcreator ' .. expand('%'))<CR>
    an 500.10  📐&}.&Qt\ Tools.Designer                     <Cmd>call planet#term#RunGuiApp('designer ' .. expand('%'))<CR>
    an 500.10  📐&}.&Qt\ Tools.Assistant                    <Cmd>call planet#term#RunGuiApp('assistant')<CR>
    an 500.10  📐&}.&Qt\ Tools.PixelTool                    <Cmd>call planet#term#RunGuiApp('pixeltool')<CR>
    an 500.10  📐&}.&Qt\ Tools.QDbusViewer                  <Cmd>call planet#term#RunGuiApp('qdbusviewer')<CR>
    an 500.10  📐&}.&Qt\ Tools.Generate\ qt\.conf           :TODO
    an 500.10  📐&}.&Qt\ Tools.androidtestrunner            :TODO
    an 500.10  📐&}.&Qt\ Tools.balsam                       :TODO
    an 500.10  📐&}.&Qt\ Tools.moc                          :TODO
    an 500.10  📐&}.&Qt\ Tools.moc-ng                       :TODO
    an 500.10  📐&}.&Qt\ Tools.qdbus                        :TODO
    an 500.10  📐&}.&Qt\ Tools.qdbuscpp2xml                 :TODO
    an 500.10  📐&}.&Qt\ Tools.qdbusxml2cpp                 :TODO
    an 500.10  📐&}.&Qt\ Tools.QLALR                        :TODO
    an 500.10  📐&}.&Qt\ Tools.qsb                          :TODO
    an 500.10  📐&}.&Qt\ Tools.qtattributionsscanner        :TODO
    an 500.10  📐&}.&Qt\ Tools.qt-cmake                     :TODO
    an 500.10  📐&}.&Qt\ Tools.qt-configure-module          :TODO
    an 500.10  📐&}.&Qt\ Tools.qtdiag                       :TODO
    an 500.10  📐&}.&Qt\ Tools.qtpaths                      :TODO
    an 500.10  📐&}.&Qt\ Tools.qtplugininfo                 :TODO
    an 500.10  📐&}.&Qt\ Tools.qtwaylandscanner             :TODO
    an 500.10  📐&}.&Qt\ Tools.qvkgen                       :TODO
    an 500.10  📐&}.&Qt\ Tools.rcc                          :TODO
    an 500.10  📐&}.&Qt\ Tools.shadergen                    :TODO
    an 500.10  📐&}.&Qt\ Tools.syncqt\.pl                   :TODO
    an 500.10  📐&}.&Qt\ Tools.tracegen                     :TODO
    an 500.10  📐&}.&Qt\ Tools.uic                          :TODO
    an 500.10  📐&}.&Qt\ Tools.SCXML                        :TODO
    an 500.10  📐&}.Qml.qml                                 :TODO
    an 500.10  📐&}.Qml.qmlcachegen                         :TODO
    an 500.10  📐&}.Qml.qmleasing                           :TODO
    an 500.10  📐&}.Qml.qmlformat                           :TODO
    an 500.10  📐&}.Qml.qmlimportscanner                    :TODO
    an 500.10  📐&}.Qml.qmllint                             :TODO
    an 500.10  📐&}.Qml.qmlplugindump                       :TODO
    an 500.10  📐&}.Qml.qmlpreview                          :TODO
    an 500.10  📐&}.Qml.qmlprofiler                         :TODO
    an 500.10  📐&}.Qml.qmlscene                            :TODO
    an 500.10  📐&}.Qml.testrunner                          :TODO
    an 500.10  📐&}.Qml.qmltime                             :TODO
    an 500.10  📐&}.Qml.qmltyperegistrar                    :TODO
    an 500.10  📐&}.Gtk\ Tools.Glade                        :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Run\ Command\ in\ New\ Instance :call planet#term#RunCmdBg('xvfb-run ...')
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).--1-- <Nop>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Run\ Command   :call planet#term#RunCmdBg('DISPLAY=$1 cmd...')
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).View           :call planet#term#RunGuiApp('x11vnc -display $1 -bg -nopw -listen -localhost -xkb && vncviewer -encodings "copyrect tight zrle hextile" localhost:59$1')
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Take\ Screenshot :call planet#term#RunCmd('import -display $1 -window -root screenshot.png')
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).--2-- <Nop>
    "TODO: use Xming on windows
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Start          :call planet#term#RunCmdBg('Xvfb $1 &')
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Stop           :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).--3-- <Nop>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 0<Tab>$DISPLAY=:80 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 1<Tab>$DISPLAY=:81 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 2<Tab>$DISPLAY=:82 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 3<Tab>$DISPLAY=:83 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 4<Tab>$DISPLAY=:84 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 5<Tab>$DISPLAY=:85 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 6<Tab>$DISPLAY=:86 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 7<Tab>$DISPLAY=:87 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 8<Tab>$DISPLAY=:88 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 9<Tab>$DISPLAY=:89 :TODO
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Specify\ Custom\ $DISPLAY :TODO
    an 500.10  📐&}.i10n\ &&\ i18n <Nop>
    an disable 📐&}.i10n\ &&\ i18n
    an 500.10  📐&}.lupdate                                 :TODO
    an 500.10  📐&}.lrelease                                :TODO
    an 500.10  📐&}.lconvert                                :TODO
    an 500.10  📐&}.Qt\ Linguist                            :TODO
    an 500.10  📐&}.lprodump                                :TODO
    an 500.10  📐&}.lrelease-pro                            :TODO
    an 500.10  📐&}.lupdate-pro                             :TODO
    an 500.10  📐&}.auto-translation                        :TODO
    an 500.10  📐&}.gettext                                 :TODO
    an 500.10  📐&}.weblate\.org                            :TODO
    an 500.10  📐&}.Documentation <Nop>
    an disable 📐&}.Documentation
    an 500.10  📐&}.doxygen                                 :TODO
    an 500.10  📐&}.QDoc                                    :TODO
    an 500.10  📐&}.QHelp\ Generator                        :TODO
    an 500.10  📐&}.readthedocs                             :TODO
    an 500.10  📐&}.gitbook                                 :TODO

    an 500.10  🔨&u.Build <Nop>
    an disable 🔨&u.Build
    an 500.10  🔨&u.&Autotools.Autotools\ Status            :call planet#term#RunScript('autotools-status')<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoconf                :call planet#term#RunCmd('autoconf -f -i')<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoreconf              :call planet#term#RunCmd('autoreconf -f -i')<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoheader              :call planet#term#RunCmd('autoheader')<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoscan                :call planet#term#RunCmd('autoscan')<CR>
    an 500.10  🔨&u.&Autotools.Run\ autoupdate              :call planet#term#RunCmd('autoupdate')<CR>
    an 500.10  🔨&u.&Autotools.Run\ ifnames                 :call planet#term#RunCmd('ifnames')<CR>
    an 500.10  🔨&u.&Autotools.Run\ libtool                 :call planet#term#RunCmd('libtool')<CR>
    an 500.10  🔨&u.&Autotools.Run\ libtoolize              :call planet#term#RunCmd('libtoolize')<CR>
    an 500.10  🔨&u.&Autotools.Generate\ \./autogen\.sh     :TODO:"generate standard autogen.sh
    an 500.10  🔨&u.&Autotools.Generate\ \./configure\.ac   :call planet#project#CopyFile('autotools/configure.ac')<CR>
    an 500.10  🔨&u.&Autotools.Run\ \./autogen\.sh          :call planet#term#RunCmd('./autogen.sh')<CR>
    an 500.10  🔨&u.&Autotools.Run\ \./bootstrap\.sh        :call planet#term#RunCmd('./bootstrap.sh')<CR>
    an 500.10  🔨&u.&Autotools.Run\ \./&configure           :call planet#term#RunCmd('./configure')<CR>
    an 500.10  🔨&u.&Autotools.Rerun\ \./&configure         :call planet#term#RunCmdFind('config.status', '--recheck')<CR>
    an 500.10  🔨&u.&Autotools.Set\ \./configure\ Options   :TODO"print ./configure --help & set options in buffer
    an 500.10  🔨&u.&Autotools.Open\ config\.log            <Cmd>find config.log<CR>
    an 500.10  🔨&u.&Autotools.Set\ $CC                     <Cmd>call planet#env#SenEnvVar("CC")<CR>
    an 500.10  🔨&u.&Autotools.Set\ $CFLAGS                 <Cmd>call planet#env#SenEnvVar("CFLAGS")<CR>
    an 500.10  🔨&u.&Autotools.Set\ $CXX                    <Cmd>call planet#env#SenEnvVar("CXX")<CR>
    an 500.10  🔨&u.&Autotools.Set\ $CXXFLAGS               <Cmd>call planet#env#SenEnvVar("CXXFLAGS")<CR>
    an 500.10  🔨&u.&Autotools.Set\ $LDFLAGS                <Cmd>call planet#env#SenEnvVar("LDFLAGS")<CR>
    an 500.10  🔨&u.&Autotools.Set\ $CPPFLAGS               <Cmd>call planet#env#SenEnvVar("CPPFLAGS")<CR>
    an 500.10  🔨&u.&Autotools.Set\ $DESTDIR                <Cmd>call planet#env#SenEnvVar("DESTDIR")<CR>
    an 500.10  🔨&u.Mak&e.&Make                             <Cmd>call planet#term#RunCmd('make')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &All                        <Cmd>call planet#term#RunCmd('make all')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Help                       <Cmd>call planet#term#RunCmd('make help')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Clean                      <Cmd>call planet#term#RunCmd('make clean')<CR>
    an 500.10  🔨&u.Mak&e.Make\ Distclea&n                  <Cmd>call planet#term#RunCmd('make distclean')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Dist                       <Cmd>call planet#term#RunCmd('make dist')<CR>
    an 500.10  🔨&u.Mak&e.Make\ Di&stcheck                  <Cmd>call planet#term#RunCmd('make distcheck')<CR>
    an 500.10  🔨&u.Mak&e.Make\ Chec&k                      <Cmd>call planet#term#RunCmd('make check')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Test                       <Cmd>call planet#term#RunCmd('make test')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Install                    <Cmd>call planet#term#RunCmd('make install')<CR>
    an 500.10  🔨&u.Mak&e.Make\ &Uninstall                  <Cmd>call planet#term#RunCmd('make uninstall')<CR>
    an 500.10  🔨&u.Mak&e.Set\ $MAKEFLAGS                   <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    an 500.10  🔨&u.&KBuild.make\ &oldconfig                <Cmd>call planet#term#RunCmd("yes '' \| make oldconfig")<CR>
    an 500.10  🔨&u.&KBuild.make\ &menuconfig               <Cmd>call planet#term#RunCmdTab('make menuconfig')<CR>
    an 500.10  🔨&u.&KBuild.ma&ke                           <Cmd>call planet#term#RunCmd('make')<CR>
    an 500.10  🔨&u.&KBuild.ma&ke\ Custom\ Target           <Cmd>call planet#term#RunCmdAskArgs('make', 'Target: ')<CR>
    an 500.10  🔨&u.&KBuild.&Edit\ \.config                 <Cmd>e .config<CR>
    an 500.10  🔨&u.&KBuild.&Edit\ $MAKEFLAGS               <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    an 500.10  🔨&u.&KBuild.make\ c&lean                    <Cmd>call planet#term#RunCmd('make clean')<CR>
    an 500.10  🔨&u.&KBuild.make\ mr&proper                 <Cmd>call planet#term#RunCmd('make mrproper')<CR>
    an 500.10  🔨&u.&KBuild.make\ dis&tclean                <Cmd>call planet#term#RunCmd('make distclean')<CR>
    an 500.10  🔨&u.&KBuild.make\ &help                     <Cmd>call planet#term#RunCmd('make help')<CR>
    an 500.10  🔨&u.&KBuild.make\ &config                   <Cmd>call planet#term#RunCmd('make config')<CR>
    an 500.10  🔨&u.&KBuild.make\ allyesconfig              <Cmd>call planet#term#RunCmd('make allyesconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ allnoconfig               <Cmd>call planet#term#RunCmd('make allnoconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ defconfig                 <Cmd>call planet#term#RunCmd('make defconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ install                   <Cmd>call planet#term#RunCmd('make install')<CR>
    an 500.10  🔨&u.&KBuild.make\ uninstall                 <Cmd>call planet#term#RunCmd('make uninstall')<CR>
    an 500.10  🔨&u.&KBuild.make\ randconfig                <Cmd>call planet#term#RunCmd('make randconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ allmodconfig              <Cmd>call planet#term#RunCmd('make allmodconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ &nconfig                  <Cmd>call planet#term#RunCmd('make nconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ &xconfig                  <Cmd>call planet#term#RunCmd('make xconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ &gconfig                  <Cmd>call planet#term#RunCmd('make gconfig')<CR>
    an 500.10  🔨&u.&KBuild.make\ &tags                     <Cmd>call planet#term#RunCmd('make tags')<CR>
    an 500.10  🔨&u.&CMake.&Build                           <Cmd>call planet#term#RunCmd('cmake --build .', v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&u.&CMake.Generate\ compile_commands\.json <Cmd>call planet#env#SenEnvVarValue('CMAKE_EXPORT_COMPILE_COMMANDS=ON')<CR><Cmd>call planet#term#RunCmd('cmake ..', v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&u.&CMake.&Configure                       <Cmd>call planet#term#RunCmd('cmake ' .. getcwd(), v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&u.&CMake.Configure\ &Tui                  <Cmd>call planet#term#RunCmdTab('ccmake ..', g:PV_build_dir)<CR>
    an 500.10  🔨&u.&CMake.Configure\ &Gui                  <Cmd>call planet#term#RunGuiApp('cmake-gui ..', g:PV_build_dir)<CR>
    an 500.10  🔨&u.&CMake.&Rebuild                         <Cmd>call planet#term#RunCmd('cmake --build . --target clean && cmake --build .', v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&u.&CMake.Clean                            <Cmd>call planet#term#RunCmd('cmake --build . --target clean', v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&u.&CMake.Create\ &In-Tree\ Build\ Dir     <Cmd>call planet#build#NewInTreeBuildDir()<CR>
    an 500.10  🔨&u.&CMake.Create\ &OOT\ Build\ Dir         <Cmd>call planet#build#NewOOTBuildDir()<CR>
    an 500.10  🔨&u.&CMake.Select\ Build\ Dir               <Cmd>call planet#build#SelectBuildDir()<CR>
    an 500.10  🔨&u.&CMake.Browse\ Build\ Directory         <Cmd>exe 'Fern ' .. g:PV_build_dir<CR>
    an 500.10  🔨&u.&QMake.Set\ DESTDIR                     :!make<CR>
    an 500.10  🔨&u.Scons.Run\ Custom\ Target               <Cmd>call planet#term#RunCmdAskArgs('scons', 'scons: ', ' -j8 .')<CR>
    an 500.10  🔨&u.Nin&ja.Set\ DESTDIR                     :!make<CR>
    an 500.10  🔨&u.&Meson.Set\ DESTDIR                     :!make<CR>
    an 500.10  🔨&u.Arduino.Verify                          :ArduinoVerify<CR>
    an 500.10  🔨&u.Arduino.Upload                          :ArduinoUpload<CR>
    an 500.10  🔨&u.Arduino.Upload\ and\ Serial             :ArduinoUploadAndSerial<CR>
    an 500.10  🔨&u.Arduino.Serial                          :ArduinoSerial<CR>
    an 500.10  🔨&u.Arduino.Set\ Baud                       :ArduinoSetBaud<CR>
    an 500.10  🔨&u.Arduino.--2-- <Nop>
    an 500.10  🔨&u.Arduino.Choose\ Board                   :ArduinoChooseBoard<CR>
    an 500.10  🔨&u.Arduino.Choose\ Programmer              :ArduinoChooseProgrammer<CR>
    an 500.10  🔨&u.Arduino.Choose\ Port                    :ArduinoChoosePort<CR>
    an 500.10  🔨&u.Arduino.--1-- <Nop>
    an 500.10  🔨&u.Arduino.Info                            :ArduinoInfo<CR>
    an 500.10  🔨&u.Arduino.Set\ Arduino\ Dir               :let g:arduino_dir = 'TODO'
    an 500.10  🔨&u.Arduino.Set\ Build\ Dir                 :let g:arduino_build_path = 'TODO'
    an 500.10  🔨&u.PlatformIO.Edit\ Settings               :e platformio.ini<CR>
    an 500.10  🔨&u.ROS.Setup                               :TODO
    an 500.10  🔨&u.Yocto.Setup                             :TODO
    an 500.10  🔨&u.Flutter.Doctor                          <Cmd>call planet#term#RunCmd('flutter doctor')<CR>
    an 500.10  🔨&u.Flutter.Set\ Android\ Sdk\ Location     <Cmd>call planet#term#RunCmd('flutter config --android-sdk')<CR>
    an 500.10  🔨&u.Flutter.Accept\ Android\ Licenses       <Cmd>call planet#term#RunCmd('flutter doctor --android-licenses')<CR>
    an 500.10  🔨&u.Flutter.Create\ Project                 <Cmd>call planet#term#RunCmd('flutter create new_project')<CR>
    an 500.10  🔨&u.Flutter.Run                             <Cmd>call planet#term#RunCmd('flutter run')<CR>
    an 500.10  🔨&u.Deploy <Nop>
    an disable 🔨&u.Deploy
    an 500.10  🔨&u.Windeployqt.Deploy                      :!make<CR>
    an 500.10  🔨&u.Macdeployqt.Deploy                      :!make<CR>
    an 500.10  🔨&u.Linuxdeploy.Deploy                      :!make<CR>
    an 500.10  🔨&u.Androiddeployqt.Deploy                  :!make<CR>
    an 500.10  🔨&u.Package <Nop>
    an disable 🔨&u.Package
    an 500.10  🔨&u.fpm.Build                               :!make<CR>
    an 500.10  🔨&u.pyInstaller.Build                       :!make<CR>
    an 500.10  🔨&u.CPack.Build                             :!make<CR>
    an 500.10  🔨&u.AppImage.Build                          :!make<CR>
    an 500.10  🔨&u.Snap.Build                              :!make<CR>
    an 500.10  🔨&u.FlatPak.Build                           :!make<CR>
    an 500.10  🔨&u.pyUpdater.Build                         :!make<CR>
    an 500.10  🔨&u.Installer <Nop>
    an disable 🔨&u.Installer
    an 500.10  🔨&u.Qt\ Installer\ Framework.Build          :!make<CR>
    " an 500.10  🔨&u.Choose\ Make\ Target                    :make <C-z>"TODO
    " an 500.10  🔨&u.Rerun\ Previous\ Make                   :make prev_target
    " an 500.10  🔨&u.--1-- <Nop>
    " an 500.10  🔨&u.Set\ Compiler\ Globally<Tab>:compiler!\ {compiler} :compiler! 
    " an 500.10  🔨&u.Set\ Compiler\ for\ Buffer<Tab>:compiler\ {compiler} :compiler 

    " Run
    an 510.10  ▶️&r.Run <Nop>
    an disable ▶️&r.Run
    an 510.500 ▶️&r.--1-- <Nop>
    an 510.500 ▶️&r.Add\ Run\ Config                        <Cmd>call planet#run#AddConfig()<CR>

    " Debug
    an 520.10  🐞&d.Debug <Nop>
    an disable 🐞&d.Debug
    an 520.10  🐞&d.Start\ &Debug                           :Vimspector<CR>
    an 520.10  🐞&d.Detach\ Debugger                        :Vimspector<CR>
    an 520.10  🐞&d.Stop\ &Debug                            :Vimspector<CR>
    an 520.10  🐞&d.--1-- <Nop>
    an 520.10  🐞&d.Setup\ GDB                              :Vimspector<CR>
    an 520.10  🐞&d.Setup\ GDB\ Dashboard                   :Vimspector<CR>
    an 520.10  🐞&d.Setup\ GDB\ for\ Unreal                 :Vimspector<CR>
    an 520.10  🐞&d.Setup\ GDB\ Pretty\ Printers            :Vimspector<CR>
    an 520.10  🐞&d.Setup\ LLDB                             :Vimspector<CR>
    an 520.10  🐞&d.Setup\ rr                               :Vimspector<CR>
    an 520.10  🐞&d.Setup\ LiveRecorder                     :Vimspector<CR>
    an 520.10  🐞&d.Setup\ radare2                          :Vimspector<CR>
    an 520.10  🐞&d.Setup\ cutter                           :Vimspector<CR>
    an 520.10  🐞&d.--1-- <Nop>
    an 520.10  🐞&d.Debug\ Kernel <Nop>
    an disable 🐞&d.Debug\ Kernel
    an 520.10  🐞&d.Setup\ GDB\ for\ Kernel                 :Vimspector<CR>
    an 520.10  🐞&d.gdb\ kernel                             :Vimspector<CR>
    an 520.10  🐞&d.kgdb                                    :Vimspector<CR>
    an 520.10  🐞&d.kdb                                     :Vimspector<CR>
    an 520.10  🐞&d.debugfs                                 :Vimspector<CR>

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
    an 530.10  🧪&j.CTest                                   :TestVisit<CR>
    an 530.10  🧪&j.CDash                                   :TestVisit<CR>
    an 530.10  🧪&j.Report\ Tools.Screenshot                :TestVisit<CR>
    an 530.10  🧪&j.Report\ Tools.Record\ gif               :TestVisit<CR>
    an 530.10  🧪&j.Report\ Tools.Record\ screen            :TestVisit<CR>
    an 530.10  🧪&j.Test\ Kernel <Nop>
    an disable 🧪&j.Test\ Kernel
    an 530.10  🧪&j.KUnit                                   :TODO
    an 530.10  🧪&j.kselftest                               :TODO

    " Analyze
    an 540.10  🔬&y.Analyze <Nop>
    an disable 🔬&y.Analyze
    an 540.10  🔬&y.Check                                   :
    an 540.10  🔬&y.Clang-Tidy                              :Vimspector<CR>
    an 540.10  🔬&y.Clazy                                   :Vimspector<CR>
    an 540.10  🔬&y.Cppcheck                                :Vimspector<CR>
    an 540.10  🔬&y.Chrome\ Trace\ Format\ Visualizer       :Vimspector<CR>
    an 540.10  🔬&y.Performance\ Analyzer                   :Vimspector<CR>
    an 540.10  🔬&y.Memcheck                                :Vimspector<CR>
    an 540.10  🔬&y.Memcheck\ Gdb                           :Vimspector<CR>
    an 540.10  🔬&y.Callgrind                               :Vimspector<CR>
    an 540.10  🔬&y.QML\ Profiler                           :Vimspector<CR>
    an 540.10  🔬&y.ASAN                                    :Vimspector<CR>
    an 540.10  🔬&y.ThreadSanitizer                         :Vimspector<CR>
    an 540.10  🔬&y.LeakSanitizer                           :Vimspector<CR>
    an 540.10  🔬&y.UBSAN                                   :Vimspector<CR>
    an 540.10  🔬&y.Sanitizers                              :Vimspector<CR>
    an 540.10  🔬&y.Sanitizers                              :Vimspector<CR>
    an 540.10  🔬&y.Coverity                                :Vimspector<CR>
    an 540.10  🔬&y.ltrace                                  :Vimspector<CR>
    an 540.10  🔬&y.strace                                  :Vimspector<CR>
    an 540.10  🔬&y.ptrace                                  :Vimspector<CR>
    an 540.10  🔬&y.pstree\ $PID                            :Vimspector<CR>
    an 540.10  🔬&y.Open\ /proc/$PID\ Folder                :Fern /proc/$PID...TODO
    an 540.10  🔬&y.Analyze\ Kernel <Nop>
    an disable 🔬&y.Analyze\ Kernel
    an 540.10  🔬&y.Coccinelle                              :Vimspector<CR>
    an 540.10  🔬&y.Sparse                                  :Vimspector<CR>
    an 540.10  🔬&y.kcov                                    :Vimspector<CR>
    an 540.10  🔬&y.gcov\ with\ kernel                      :Vimspector<CR>
    an 540.10  🔬&y.KASAN                                   :Vimspector<CR>
    an 540.10  🔬&y.KUBSAN                                  :Vimspector<CR>
    an 540.10  🔬&y.Kernel\ Memory\ Leak\ Detector          :Vimspector<CR>
    an 540.10  🔬&y.KCSAN                                   :Vimspector<CR>
    an 540.10  🔬&y.Kernel\ Electric-Fence\ (KFENCE)        :Vimspector<CR>
    an 540.10  🔬&y.ftrace                                  :Vimspector<CR>
    an 540.10  🔬&y.tracefs                                 :Vimspector<CR>

    " Terminal
    an 550.10  💻&t.Terminal <Nop>
    an disable 💻&t.Terminal
    "TODO: set winfixheight winfixwidth
    an 550.10  💻&t.N&ew                                    :botright terminal ++kill=kill ++rows=10<CR>
    an 550.10  💻&t.New\ &Here                              :terminal ++curwin ++kill=kill<CR>
    an 550.10  💻&t.New\ &VSplit                            :vertical terminal ++kill=kill<CR>
    an 550.10  💻&t.New\ &Tab                               :tab terminal ++kill=kill<CR>
    an 550.10  💻&t.--1-- <Nop>
    an 550.10  💻&t.P&ython\ Shell                          :botright terminal ++kill=kill ++rows=10 python<CR>
    an 550.10  💻&t.C&++\ Shell                             :botright terminal ++kill=kill ++rows=10 cling<CR>
    an 550.10  💻&t.--2-- <Nop>
    an 550.10  💻&t.&Close\ Output                          :call planet#term#CloseOutputWindow()<CR>
    an 550.10  💻&t.Terminal\ List <Nop>
    an disable 💻&t.Terminal\ List
    an 550.10  💻&t.Output\ List <Nop>
    an disable 💻&t.Output\ List
  else
    silent! aunmenu ❇️&[
    silent! aunmenu 🪧&]
    silent! aunmenu 🎚️&{
    silent! aunmenu 📐&}
    silent! aunmenu 🔨&u
    silent! aunmenu ▶️&r
    silent! aunmenu 🐞&d
    silent! aunmenu 🧪&j
    silent! aunmenu 🔬&y
    silent! aunmenu 💻&t
  endif
endfunc
