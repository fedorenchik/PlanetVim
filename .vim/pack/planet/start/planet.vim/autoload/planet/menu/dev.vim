scriptversion 4

func! planet#menu#dev#Update() abort
  if g:PlanetVim_menus_dev
    " LSP
    an 300.10  ❇️&[.LSP <Nop>
    an disable ❇️&[.LSP
    an 300.10  ❇️&[.Choose\ Symbol<Tab>:Clap\ tags\ vim_lsp :Clap tags vim_lsp<CR>
    an 300.10  ❇️&[.--1-- <Nop>
    an 300.10  ❇️&[.&Definition                             <Cmd>LspDefinition<CR>
    an 300.10  ❇️&[.De&claration                            <Cmd>LspDeclaration<CR>
    an 300.10  ❇️&[.&References                             <Cmd>LspReferences<CR>
    an 300.10  ❇️&[.&Implementation                         <Cmd>LspImplementation<CR>
    an 300.10  ❇️&[.&Type\ Definition                       <Cmd>LspTypeDefinition<CR>
    an 300.10  ❇️&[.Type\ &Hierarchy                        <Cmd>LspTypeHierarchy<CR>
    an 300.10  ❇️&[.&Incoming\ Call\ Hierarchy              <Cmd>LspCallHierarchyIncoming<CR>
    an 300.10  ❇️&[.&Outgoing\ Call\ Hierarchy              <Cmd>LspCallHierarchyOutgoing<CR>
    an 300.10  ❇️&[.Document\ Semantic\ Scopes              <Cmd>LspSemanticScopes<CR>
    an 300.10  ❇️&[.--2-- <Nop>
    an 300.10  ❇️&[.Preview.Hover                           <Cmd>LspHover<CR>
    an 300.10  ❇️&[.Preview.Hover\ in\ Popup                <Cmd>LspHover --ui=float<CR>
    an 300.10  ❇️&[.Preview.Hover\ in\ Preview              <Cmd>LspHover --ui=preview<CR>
    an 300.10  ❇️&[.Preview.Definition                      <Cmd>LspPeekDefinition<CR>
    an 300.10  ❇️&[.Preview.Declaration                     <Cmd>LspPeekDeclaration<CR>
    an 300.10  ❇️&[.Preview.Implementation                  <Cmd>LspPeekImplementation<CR>
    an 300.10  ❇️&[.Preview.Type\ Definition                <Cmd>LspPeekTypeDefinition<CR>
    an 300.10  ❇️&[.--3-- <Nop>
    an 300.10  ❇️&[.Rena&me                                 <Cmd>LspRename<CR>
    an 300.10  ❇️&[.Code\ Action\ (LSP\ Quick\ &Fix)        <Cmd>LspCodeAction<CR>
    an 300.10  ❇️&[.Code\ &Lens                             <Cmd>LspCodeLens<CR>
    an 300.10  ❇️&[.Format\ Document                        <Cmd>LspDocumentFormat<CR>
    an 300.10  ❇️&[.Format\ Document\ Selection             <Cmd>LspDocumentRangeFormat<CR>
    an 300.10  ❇️&[.Update\ Document\ Folds                 <Cmd>LspDocumentFold<CR>
    an 300.10  ❇️&[.--4-- <Nop>
    an 300.10  ❇️&[.Document\ Symbols                       <Cmd>LspDocumentSymbol<CR>
    an 300.10  ❇️&[.Document\ Symbol\ Search                <Cmd>LspDocumentSymbolSearch<CR>
    an 300.10  ❇️&[.Workspace\ Symbols                      <Cmd>LspWorkspaceSymbol<CR>
    an 300.10  ❇️&[.Workspace\ Symbol\ Search               <Cmd>LspWorkspaceSymbolSearch<CR>
    an 300.10  ❇️&[.--5-- <Nop>
    an 300.10  ❇️&[.&Previous\ Reference                    <Cmd>LspPreviousReference<CR>
    an 300.10  ❇️&[.&Next\ Reference                        <Cmd>LspNextReference<CR>
    an 300.10  ❇️&[.--6-- <Nop>
    an 300.10  ❇️&[.Document\ Diagnostics                   <Cmd>LspDocumentDiagnostics<CR>
    an 300.10  ❇️&[.Diagnostics\ (all\ buffers)             <Cmd>LspDocumentDiagnostics --buffers=*<CR>
    an 300.10  ❇️&[.--7-- <Nop>
    an 300.10  ❇️&[.Previous\ Error                         <Cmd>LspPreviousError -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Error                             <Cmd>LspNextError -wrap=0<CR>
    an 300.10  ❇️&[.--8-- <Nop>
    an 300.10  ❇️&[.Previous\ Warning                       <Cmd>LspPreviousWarning -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Warning                           <Cmd>LspNextWarning -wrap=0<CR>
    an 300.10  ❇️&[.--9-- <Nop>
    an 300.10  ❇️&[.Previous\ Diagnostic                    <Cmd>LspPreviousDiagnostic -wrap=0<CR>
    an 300.10  ❇️&[.Next\ Diagnostic                        <Cmd>LspNextDiagnostic -wrap=0<CR>
    an 300.10  ❇️&[.--10-- <Nop>
    an 300.10  ❇️&[.Status.LSP\ Status                      <Cmd>LspStatus<CR>
    an 300.10  ❇️&[.Status.--1-- <Nop>
    an 300.10  ❇️&[.Status.Restart\ LSP                     <Cmd>call lsp#disable()<CR><Cmd>call lsp#enable()<CR>
    an 300.10  ❇️&[.Status.Enable\ LSP                      <Cmd>call lsp#enable()<CR>
    an 300.10  ❇️&[.Status.Disable\ LSP                     <Cmd>call lsp#disable()<CR>
    an 300.10  ❇️&[.Status.Stop\ Server                     <Cmd>LspStopServer<CR>
    an 300.10  ❇️&[.Status.--2-- <Nop>
    an 300.10  ❇️&[.Status.Enable\ Diagnostics              <Cmd>call lsp#enable_diagnostics_for_buffer()<CR>
    an 300.10  ❇️&[.Status.Disable\ Diagnostics             <Cmd>call lsp#disable_diagnostics_for_buffer()<CR>

    " Tags
    an 310.10  🪧&].Tags <Nop>
    an disable 🪧&].Tags
    an 310.10  🪧&].C&hoose<Tab>:Clap\ tags\ ctags          <Cmd>Clap tags ctags<CR>
    an 310.10  🪧&].&Jump\ to\ Tag<Tab><C-]>                <C-]>
    an 310.10  🪧&].&Jump\ Back<Tab><C-t>                   <C-t>
    an 310.10  🪧&].&Jump\ or\ Select\ Tag<Tab>g<C-]>       g<C-]>
    an 310.10  🪧&].&Select\ Tag<Tab>g]                     g]
    an 310.10  🪧&].Jump\ Split\ to\ Tag<Tab>+]             <C-w>]
    an 310.10  🪧&].Jump\ or\ Select\ Split\ to\ Tag<Tab>+g<C-]> <C-w>g<C-]>
    an 310.10  🪧&].Select\ Split\ Tag<Tab>+g]              <C-w>g]
    an 310.10  🪧&].Go\ to\ Tag\ VSplit<Tab>:vert\ stag     <Cmd>vert stag <cword><CR>
    an 310.10  🪧&].--1-- <Nop>
    an 310.10  🪧&].Preview\ Tag<Tab>+}                     <C-w>}
    an 310.10  🪧&].Select\ Preview\ Tag<Tab>+g}            <C-w>g}
    an 310.10  🪧&].Preview\ Previous\ Tag<Tab>:ppop        <Cmd>ppop<CR>
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
    am 310.10  🪧&].Toggle\ AutoPreview\ Tags               <Cmd>call PlanetVim_TagsAutoPreview_Toggle()<CR>
    an 310.10  🪧&].--5-- <Nop>
    am 310.10  🪧&].Build\ tags\ File                       <Cmd>call planet#term#RunCmd('ctags -R .')<CR>
    am 310.10  🪧&].Generate\ tags\.vim\ File               <Cmd>sp tags<CR>:%s/^\([^	:]*:\)\=\([^	]*\).*/syntax keyword Tag \2/<CR>:wq! tags.vim<CR>/^<CR>
    am 310.10  🪧&].Highlight\ tags\ from\ tags\.vim        <Cmd>so tags.vim<CR>
    am 310.10  🪧&].Generate\ types\.vim\ File              :!ctags --c-kinds=gstu -o- *.[ch] \| awk 'BEGIN{printf("syntax keyword Type\t")} {printf("%s ", $1)}END{print "")' > types.vim
    am 310.10  🪧&].Highlight\ tags\ from\ types\.vim       <Cmd>so types.vim<CR>

    an 500.10  🎚️&{.Virtual\ Environments <Nop>
    an disable 🎚️&{.Virtual\ Environments
    an 500.10  🎚️&{.&Docker.CLI\ UI\ (lazydocker)           <Cmd>call planet#term#RunCmdTab('lazydocker')<CR>
    an 500.10  🎚️&{.&Docker.--1-- <Nop>
    an 500.10  🎚️&{.&Docker.List\ Running\ Containers       <Cmd>call planet#term#RunCmd('docker container ls')<CR>
    an 500.10  🎚️&{.&Docker.List\ All\ Containers           <Cmd>call planet#term#RunCmd('docker container ls -a')<CR>
    an 500.10  🎚️&{.&Docker.--2-- <Nop>
    an 500.10  🎚️&{.&Docker.List\ Images                    <Cmd>call planet#term#RunCmd('docker image ls')<CR>
    an 500.10  🎚️&{.&Pipenv.Start\ Shell                    <Cmd>call planet#term#RunCmd('pipenv shell')<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ python\ main\.py           <Cmd>call planet#term#RunCmd('pipenv run python ./main.py')<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ python\ app\.py            <Cmd>call planet#term#RunCmd('pipenv run python ./app.py')<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ Command\.\.\.              <Cmd>call planet#term#RunCmdAskArgs('pipenv run', 'Command: ')<CR>
    an 500.10  🎚️&{.&Pipenv.Update\ Pipfile\.lock           <Cmd>call planet#term#RunCmd('pipenv lock')<CR>
    an 500.10  🎚️&{.&Pipenv.--1-- <Nop>
    an 500.10  🎚️&{.&Pipenv.New\ Project                    <Cmd>call planet#term#RunCmd('pipenv --three')<CR>
    an 500.10  🎚️&{.&Pipenv.New\ Project\ with\ Python      <Cmd>call planet#term#RunCmdAskArgs('pipenv --python', 'Python Version: ')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Run\ &&\ Dev\ Deps     <Cmd>call planet#term#RunCmd('pipenv install --dev')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Run\ Deps              <Cmd>call planet#term#RunCmd('pipenv install')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Packages\.\.\.         <Cmd>call planet#term#RunCmdAskArgs('pipenv install', 'Packages: ')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Dev\ Packages\.\.\.    <Cmd>call planet#term#RunCmdAskArgs('pipenv install --dev', 'Packages: ')<CR>
    an 500.10  🎚️&{.&Pipenv.Update\ (Lock\ &&\ Sync)        <Cmd>call planet#term#RunCmd('pipenv update')<CR>
    an 500.10  🎚️&{.&Pipenv.Sync\ with\ Pipfile\.lock       <Cmd>call planet#term#RunCmd('pipenv sync')<CR>
    an 500.10  🎚️&{.&Pipenv.--2-- <Nop>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Extra\ Packages      <Cmd>call planet#term#RunCmd('pipenv clean')<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Packages\.\.\.       <Cmd>call planet#term#RunCmdAskArgs('pipenv uninstall', 'Packages: ')<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Dev\ Packages        <Cmd>call planet#term#RunCmd('pipenv uninstall --all-dev')<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ All                  <Cmd>call planet#term#RunCmd('pipenv uninstall --all')<CR>
    an 500.10  🎚️&{.&Pipenv.Remove\ Project's\ VEnv         <Cmd>call planet#term#RunCmd('pipenv --rm')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install      <Cmd>call planet#term#RunCmd('pipenv install -r requirements.txt')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install\ Dev <Cmd>call planet#term#RunCmd('pipenv install -r dev-requirements.txt --dev')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export       <Cmd>call planet#term#RunCmd('pipenv lock -r > requirements.txt')<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export\ Dev  <Cmd>call planet#term#RunCmd('pipenv lock -r -d > dev-requirements.txt')<CR>
    an 500.10  🎚️&{.&Pipenv.--3-- <Nop>
    an 500.10  🎚️&{.&Pipenv.Open\ Module\.\.\.              <Cmd>call planet#term#RunCmdAskArgs('pipenv open', 'Module: ')<CR>
    an 500.10  🎚️&{.&Pipenv.Security\ Check                 <Cmd>call planet#term#RunCmd('pipenv check')<CR>
    an 500.10  🎚️&{.&Pipenv.Dependency\ Graph               <Cmd>call planet#term#RunCmd('pipenv graph')<CR>
    an 500.10  🎚️&{.&Pipenv.Reverse\ Dependency\ Graph      <Cmd>call planet#term#RunCmd('pipenv graph --reverse')<CR>
    an 500.10  🎚️&{.&Pipenv.Enable\ Site\ Packages          <Cmd>call planet#term#RunCmd('pipenv --site-packages')<CR>
    an 500.10  🎚️&{.&Pipenv.Disable\ Site\ Packages         <Cmd>call planet#term#RunCmd('pipenv --no-site-packages')<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Project\ Root            <Cmd>call planet#term#RunCmd('pipenv --where')<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ VEnv\ Dir                <Cmd>call planet#term#RunCmd('pipenv --venv')<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Env\ Vars                <Cmd>call planet#term#RunCmd('pipenv --envs')<CR>
    an 500.10  🎚️&{.&Pipenv.Edit\ \.env                     <Cmd>e .env<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Version                  <Cmd>call planet#term#RunCmd('pipenv --version')<CR>
    an 500.10  🎚️&{.&Pipenv.Clear\ Caches                   <Cmd>call planet#term#RunCmd('pipenv --clear')<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Pipenv                 <Cmd>call planet#term#RunCmd('pip install --user pipenv')<CR>
    an 500.10  🎚️&{.C&onda.Activate\.\.\.                   <Cmd>call planet#term#RunCmdAskArgs('conda activate', 'Conda Environment: ')<CR>
    an 500.10  🎚️&{.C&onda.Install\ from\ requirements\.txt <Cmd>call planet#term#RunCmd('conda install --file requirements.txt')<CR>
    an 500.10  🎚️&{.C&onda.Create\ from\ environment\.yml   <Cmd>call planet#term#RunCmd('conda env create -f environment.yml')<CR>
    an 500.10  🎚️&{.C&onda.Deactivate                       <Cmd>call planet#term#RunCmd('conda deactivate')<CR>
    an 500.10  🎚️&{.C&onda.Create\ New\ Environment\.\.\.   <Cmd>call planet#term#RunCmdAskArgs('conda create --name', 'Name: ', 'conda')<CR>
    an 500.10  🎚️&{.C&onda.Activate\ Anaconda               <Cmd>call planet#term#RunCmd('source /opt/anaconda/bin/activate')<CR>
    an 500.10  🎚️&{.C&onda.Deactivate\ Anaconda             <Cmd>call planet#term#RunCmd('source /opt/anaconda/bin/deactivate')<CR>
    an 500.10  🎚️&{.C&onda.Conda\ Init                      <Cmd>call planet#term#RunCmd('conda-init')<CR>
    an 500.10  🎚️&{.C&onda.Conda\ Info                      <Cmd>call planet#term#RunCmd('conda info')<CR>
    an 500.10  🎚️&{.Android.Download\ System\ Image         <Cmd>call planet#term#RunCmd('$ANDROID_SDK/tools/bin/sdkmanager "system-images;android-27;google_apis;x86"')<CR>
    an 500.10  🎚️&{.Android.Create\ AVD                     <Cmd>call planet#term#RunCmd('$ANDROID_SDK/tools/bin/avdmanager create avd -n virtualAndroid -k "system-images;android-27;google_apis;x86"')<CR>
    an 500.10  🎚️&{.Vagrant.Test                            :TODO
    an 500.10  🎚️&{.QEMU.Test                               :TODO
    an 500.10  🎚️&{.QEMU\ Schroot.qemu-debootstrap          :TODO
    "TODO:
    " an 500.10  🎚️&{.Schroot.Debootstrap                    <Cmd>!sudo debootstrap --variant=buildd --arch=amd64 buster /var/chroots/debian10_x64 http://ftp.debian.org/debian/<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Check\ Config         :TODO"check $HOME is not mounted!!!
    " an 500.10  🎚️&{.Schroot.Schroot\ Add\ New              :TODO"create config file in /etc/schroot/chroot.d/ directory
    " an 500.10  🎚️&{.Schroot.Schroot\ List                  <Cmd>!schroot -l<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Info                  <Cmd>!schroot -i<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Config                <Cmd>!schroot --config<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Location              <Cmd>!schroot --location<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Start                 <Cmd>!schroot -c debian10_x64 -u leonid<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Start\ Root           <Cmd>!schroot -c debian10_x64 -u leonid<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Start\ XNest          <Cmd>!schroot -c debian10_x64 -u leonid<CR>
    " an 500.10  🎚️&{.Schroot.Schroot\ Run\ Command          <Cmd>!schroot -c debian10_x64 -u leonid {cmd}<CR>
    " an 500.10  🎚️&{.Conan\ Virtual\ Environment.Test       :TODO
    " an 500.10  🎚️&{.systemd-nspawn.Test                    :TODO
    " an 500.10  🎚️&{.PRoot.Test                             :TODO
    " an 500.10  🎚️&{.Fakechroot.Test                        :TODO
    an 500.10  🎚️&{.Configuration <Nop>
    an disable 🎚️&{.Configuration
    an 500.10  🎚️&{.Install\ Qt.Set\ $QTDIR                 <Cmd>call planet#env#SetEnvVar('QTDIR')<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ 6\.2\.3        <Cmd>call planet#term#RunCmd('aqt install-qt linux desktop 6.2.3 gcc_64')<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ 6\.2\.3\ Modules <Cmd>call planet#term#RunCmd('aqt install-qt linux desktop 6.2.3 gcc_64 -m all')<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ 6\.2\.3\ Android <Cmd>call planet#term#RunCmd('aqt install-qt linux android 6.2.3 android_arm64_v8a')<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ 6\.2\.3\ Android\ Modules <Cmd>call planet#term#RunCmd('aqt install-qt linux android 6.2.3 android_arm64_v8a -m all')<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ 6\.2\.3\ Wasm  <Cmd>call planet#term#RunCmd('aqt install-qt linux desktop 6.2.3 wasm_32')<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ 6\.2\.3\ Wasm\ Modules <Cmd>call planet#term#RunCmd('aqt install-qt linux desktop 6.2.3 wasm_32 -m all')<CR>
    an 500.10  🎚️&{.Install\ Conan\ Pkg.TODO                :TODO
    an 500.10  🎚️&{.Install\ pip\ Pkg.PySide6               <Cmd>call planet#term#RunCmd('pip install PySide6')<CR>TODO
    an 500.10  🎚️&{.Install\ pip\ Pkg.Jupyter\ Notebook     <Cmd>call planet#term#RunCmd('pip install notebook')<CR>TODO
    an 500.10  🎚️&{.Install\ pip\ Pkg.JupyterLab            <Cmd>call planet#term#RunCmd('pip install jupyterlab')<CR>TODO
    an 500.10  🎚️&{.Npm.Start\ App\ for\ Development        <Cmd>call planet#term#RunCmd('npm run dev')<CR>
    an 500.10  🎚️&{.Npm.Start\ Build                        <Cmd>call planet#term#RunCmd('npm run build')<CR>
    an 500.10  🎚️&{.Npm.Start\ App                          <Cmd>call planet#term#RunCmd('npm run serve')<CR>
    an 500.10  🎚️&{.Npm.Install\ Project\ Packages          <Cmd>call planet#term#RunCmd('npm install')<CR>
    an 500.10  🎚️&{.Npm.Install\ Packages\.\.\.             <Cmd>call planet#term#RunCmdAskArgs('npm install', 'Packages: ')<CR>
    an 500.10  🎚️&{.Npm.Install\ Packages\ Globally\.\.\.   <Cmd>call planet#term#RunCmdAskArgs('sudo npm install -g', 'Packages: ')<CR>
    an 500.10  🎚️&{.Npm.Install\ create-nuxt-app            <Cmd>call planet#term#RunCmd('sudo npm install -g create-nuxt-app')<CR>
    an 500.10  🎚️&{.--1-- <Nop>
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
    an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Installed    <Cmd>call planet#term#RunCmd('pyenv versions')<CR>
    an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Available    <Cmd>call planet#term#RunCmd('pyenv install --list')<CR>
    an 500.10  🎚️&{.Settings <Nop>
    an disable 🎚️&{.Settings
    an 500.10  🎚️&{.&Env.&Source\ \.env                     <Cmd>Dotenv .env<CR>
    an 500.10  🎚️&{.&Env.&Source\ File\.\.\.                :Dotenv <C-z>
    an 500.10  🎚️&{.&Env.Set\ Env\ &Var                     <Cmd>call planet#env#NewEnvVar()<CR>
    an 500.10  🎚️&{.&Env.Edit\ &\.env                       <Cmd>e .env<CR>
    an 500.10  🎚️&{.&Env.Edit\ E&nv\ in\ Buffer             <Cmd>call planet#env#BufferFromCmd('env')<CR>
    an 500.10  🎚️&{.&Env.Set\ $&DESTDIR                     <Cmd>call planet#env#SetEnvVar('DESTDIR')<CR>
    an 500.10  🎚️&{.&Env.Set\ $P&YTHONPATH                  <Cmd>call planet#env#SetEnvVar('PYTHONPATH')<CR>
    an 500.10  🎚️&{.&Env.Set\ $&PATH                        <Cmd>call planet#env#SetEnvVar('PATH')<CR>
    an 500.10  🎚️&{.&Env.Set\ $&ARCH                        <Cmd>call planet#env#SetEnvVar('ARCH')<CR>
    an 500.10  🎚️&{.&Env.Set\ $&CROSS_COMPILE               <Cmd>call planet#env#SetEnvVar('CROSS_COMPILE')<CR>
    an 500.10  🎚️&{.&Env.P&rint\ Env                        <Cmd>call planet#env#PrintEnv()<CR>
    an 500.10  🎚️&{.D&irenv.&Edit\ (or\ Create)\ \.envrc    <Cmd>EditEnvrc<CR>
    an 500.10  🎚️&{.D&irenv.&Allow\ Here                    <Cmd>call planet#term#RunCmd('direnv allow')<CR>
    an 500.10  🎚️&{.D&irenv.&Run\ \.envrc                   <Cmd>DirenvExport<CR>
    an 500.10  🎚️&{.D&irenv.E&dit\ \.direnvrc               <Cmd>EditDirenvrc<CR>
    an 500.10  🎚️&{.D&irenv.De&ny\ Here                     <Cmd>call planet#term#RunCmd('direnv deny')<CR>
    an 500.10  🎚️&{.D&irenv.P&rune\ Old\ Files              <Cmd>call planet#term#RunCmd('direnv prune')<CR>
    an 500.10  🎚️&{.Editor&Config.&Add\ New                 <Cmd>e .editorconfig<CR>
    an 500.10  🎚️&{.Editor&Config.&Reload                   <Cmd>EditorConfigReload<CR>
    an 500.10  🎚️&{.Editor&Config.Disable\ for\ &buffer     <Cmd>let b:EditorConfig_disable=1<CR>
    an 500.10  🎚️&{.Editor&Config.--1-- <Nop>
    an 500.10  🎚️&{.Editor&Config.&Enable                   <Cmd>EditorConfigEnable<CR>
    an 500.10  🎚️&{.Editor&Config.&Disable                  <Cmd>EditorConfigDisable<CR>

    an 500.10  📐&}.Dev\ Tools <Nop>
    an disable 📐&}.Dev\ Tools
    an 500.10  📐&}.Parser\ Generators.flex                 :TODO
    an 500.10  📐&}.Parser\ Generators.bison                :TODO
    an 500.10  📐&}.&Qt\ Tools.Qt\ Creator                  <Cmd>call planet#term#RunGuiApp('qtcreator ' .. expand('%'))<CR>
    an 500.10  📐&}.&Qt\ Tools.Designer                     <Cmd>call planet#term#RunGuiApp('designer ' .. expand('%'))<CR>
    an 500.10  📐&}.&Qt\ Tools.Assistant                    <Cmd>call planet#term#RunGuiApp('assistant')<CR>
    an 500.10  📐&}.&Qt\ Tools.PixelTool                    <Cmd>call planet#term#RunGuiApp('pixeltool')<CR>
    an 500.10  📐&}.&Qt\ Tools.QDbusViewer                  <Cmd>call planet#term#RunGuiApp('qdbusviewer')<CR>
    an 500.10  📐&}.&Qt\ Tools.pyside6-uic                  <Cmd>call planet#term#RunCmd('pyside6-uic ' .. expand('%') .. ' -o Ui_' .. expand('%:r') .. '.py')<CR>
    an 500.10  📐&}.&Qt\ Tools.pyside6-rcc                  <Cmd>call planet#term#RunCmd('pyside6-rcc ' .. expand('%') .. ' -o ' .. expand('%:r') .. '_rc.py')<CR>
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
    an 500.10  📐&}.Gtk\ Tools.Glade                        <Cmd>call planet#term#RunGuiApp('glade ' .. expand('%'))<CR>
    an 500.10  📐&}.Gtk\ Tools.Glade\ Previewer             <Cmd>call planet#term#RunGuiApp('glade-previewer --filename ' .. expand('%'))<CR>
    an 500.10  📐&}.Gtk\ Tools.Devhelp                      <Cmd>call planet#term#RunGuiApp('devhelp --search=' .. expand('<cword>'))<CR>
    an 500.10  📐&}.Gtk\ Tools.Devhelp\ Assistant           <Cmd>call planet#term#RunGuiApp('devhelp --search-assistant=' .. expand('<cword>'))<CR>
    an 500.10  📐&}.Kernel.Check\ &Patch                    <Cmd>call planet#term#RunCmd('./scripts/checkpatch.pl')<CR>
    an 500.10  📐&}.Kernel.Get\ Maintainers                 <Cmd>call planet#term#RunCmd('./scripts/get_maintainer.pl')<CR>
    an 500.10  📐&}.Kernel.Device\ Tree\ Compiler           <Cmd>call planet#term#RunCmd('./scripts/dtc/dtc')<CR>
    an 500.10  📐&}.Kernel.--1-- <Nop>
    an 500.10  📐&}.Kernel.&Generate\ compile_commands\.json <Cmd>call planet#term#RunCmd('./scripts/clang-tools/get_compile_commands.py')<CR>
    an 500.10  📐&}.Kernel.&Generate\ tags                  <Cmd>call planet#term#RunCmd('make tags')<CR>
    an 500.10  📐&}.Kernel.&Generate\ GTAGS                 <Cmd>call planet#term#RunCmd('make gtags')<CR>
    an 500.10  📐&}.Kernel.&Generate\ cscope\.out           <Cmd>call planet#term#RunCmd('make cscope')<CR>
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
    an 500.10  📐&}.Vue\ CLI.Start                          <Cmd>call planet#term#RunCmd('npm run serve')<CR>
    an 500.10  📐&}.Vue\ CLI.Build                          <Cmd>call planet#term#RunCmd('npm run build')<CR>
    an 500.10  📐&}.Vue\ CLI.Lint                           <Cmd>call planet#term#RunCmd('npm run lint')<CR>
    an 500.10  📐&}.Vue\ CLI.Add\ vue-router                <Cmd>call planet#term#RunCmd('npm install vue-router')<CR>
    an 500.10  📐&}.Vue\ CLI.Add\ vuex                      <Cmd>call planet#term#RunCmd('npm install vuex')<CR>
    an 500.10  📐&}.Vue\ CLI.Create\.\.\.                   <Cmd>call planet#term#RunCmdAskArgs('vue create', 'Name of new project: ', 'vue-app')<CR>
    an 500.10  📐&}.Nuxt.Run\ Dev                           <Cmd>call planet#term#RunCmd('npm run dev')<CR>
    an 500.10  📐&}.Nuxt.Build                              <Cmd>call planet#term#RunCmd('npm run build')<CR>
    an 500.10  📐&}.Nuxt.Start                              <Cmd>call planet#term#RunCmd('npm run start')<CR>
    an 500.10  📐&}.Nuxt.Generate                           <Cmd>call planet#term#RunCmd('npm run generate')<CR>
    an 500.10  📐&}.Web\ Tools.TODO                         <Cmd>call planet#term#RunCmd('wget ...TODO')<CR>
    an 500.10  📐&}.Vulkan.Compile\ Shader                  <Cmd>call planet#term#RunCmd('glslc file.ext -o file.ext.spv')<CR>
    an 500.10  📐&}.Open\ GL.glxinfo                        <Cmd>call planet#term#RunCmd('glxinfo')<CR>
    an 500.10  📐&}.Blender.Print\ Blender\ PYTHONPATH      <Cmd>call planet#term#RunCmd('blender --background --python-expr ''print(\"PYTHONPATH=\"+\":\".join(__import__(\"sys\").path))'' 2>/dev/null \\| grep -F \"PYTHONPATH=\"')<CR>
    an 500.10  📐&}.Node.Run\ with\ node                    <Cmd>call planet#term#RunCmd('node ' .. expand('%'))<CR>
    an 500.10  📐&}.Node.Start\ node\ REPL                  <Cmd>call planet#term#RunCmd('node')<CR>
    an 500.10  📐&}.WebAssembly.Emscripten\ Install         <Cmd>call planet#term#RunScript('emsdk-install')<CR>
    an 500.10  📐&}.WebAssembly.Emscripten\ Activate        <Cmd>call planet#term#RunScript('emsdk-activate')<CR>
    an 500.10  📐&}.WebAssembly.Emscripten\ Update          <Cmd>call planet#term#RunScript('emsdk-update')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ version               <Cmd>call planet#term#RunCmd('emcc --version; emcc -v')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ html     <Cmd>call planet#term#RunCmd('emcc ' .. expand('%') .. ' -o ' .. expand('%:r') .. '.html --emrun')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ js       <Cmd>call planet#term#RunCmd('emcc ' .. expand('%') .. ' -o ' .. expand('%:r') .. '.js --emrun')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ wasm     <Cmd>call planet#term#RunCmd('emcc ' .. expand('%') .. ' -o ' .. expand('%:r') .. '.wasm --emrun')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ bind         <Cmd>call planet#term#RunCmd('emcc ' .. expand('%') .. ' -o ' .. expand('%:r') .. '_wasm.js --emrun --bind')<CR>
    an 500.10  📐&}.WebAssembly.emrun\ file                 <Cmd>call planet#term#RunCmd('emrun ' .. expand('%:r') .. '.html')<CR>
    an 500.10  📐&}.WebAssembly.DisWebAssemble\ to\ js      <Cmd>call planet#term#RunCmd('$EMSDK/upstream/bin/wasm2js ' .. expand('%:r') .. '.wasm -o ' .. expand('%:r') .. '.js')<CR>
    an 500.10  📐&}.WebAssembly.Configure                   <Cmd>call planet#term#RunCmd('emconfigure ./configure')<CR>
    an 500.10  📐&}.WebAssembly.Cmake                       <Cmd>call planet#term#RunCmd('emconfigure cmake ..')<CR>
    an 500.10  📐&}.WebAssembly.Emmake\ make                <Cmd>call planet#term#RunCmd('emmake make')<CR>
    an 500.10  📐&}.Python.JupyterLab                       <Cmd>call planet#term#RunCmd('jupyter-lab')<CR>
    an 500.10  📐&}.Python.Jupyter\ Notebook                <Cmd>call planet#term#RunCmd('jupyter-notebook')<CR>
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

    an 500.10  🔨&b.Build <Nop>
    an disable 🔨&b.Build
    an 500.10  🔨&b.&Autotools.Autotools\ Status            <Cmd>call planet#term#RunScript('autotools-status')<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoconf                <Cmd>call planet#term#RunCmd('autoconf -f -i')<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoreconf              <Cmd>call planet#term#RunCmd('autoreconf -f -i')<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoheader              <Cmd>call planet#term#RunCmd('autoheader')<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoscan                <Cmd>call planet#term#RunCmd('autoscan')<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoupdate              <Cmd>call planet#term#RunCmd('autoupdate')<CR>
    an 500.10  🔨&b.&Autotools.Run\ ifnames                 <Cmd>call planet#term#RunCmd('ifnames')<CR>
    an 500.10  🔨&b.&Autotools.Run\ libtool                 <Cmd>call planet#term#RunCmd('libtool')<CR>
    an 500.10  🔨&b.&Autotools.Run\ libtoolize              <Cmd>call planet#term#RunCmd('libtoolize')<CR>
    an 500.10  🔨&b.&Autotools.Generate\ \./autogen\.sh     :TODO:"generate standard autogen.sh
    an 500.10  🔨&b.&Autotools.Generate\ \./configure\.ac   <Cmd>call planet#project#CopyFile('autotools/configure.ac')<CR>
    an 500.10  🔨&b.&Autotools.Run\ \./autogen\.sh          <Cmd>call planet#term#RunCmd('./autogen.sh')<CR>
    an 500.10  🔨&b.&Autotools.Run\ \./bootstrap\.sh        <Cmd>call planet#term#RunCmd('./bootstrap.sh')<CR>
    an 500.10  🔨&b.&Autotools.Run\ \./&configure           <Cmd>call planet#term#RunCmd('./configure')<CR>
    an 500.10  🔨&b.&Autotools.Rerun\ \./&configure         <Cmd>call planet#term#RunCmdFind('config.status', '--recheck')<CR>
    an 500.10  🔨&b.&Autotools.Set\ \./configure\ Options   :TODO"print ./configure --help & set options in buffer
    an 500.10  🔨&b.&Autotools.Open\ config\.log            <Cmd>find config.log<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CC                     <Cmd>call planet#env#SenEnvVar("CC")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CFLAGS                 <Cmd>call planet#env#SenEnvVar("CFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CXX                    <Cmd>call planet#env#SenEnvVar("CXX")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CXXFLAGS               <Cmd>call planet#env#SenEnvVar("CXXFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $LDFLAGS                <Cmd>call planet#env#SenEnvVar("LDFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CPPFLAGS               <Cmd>call planet#env#SenEnvVar("CPPFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $DESTDIR                <Cmd>call planet#env#SenEnvVar("DESTDIR")<CR>
    an 500.10  🔨&b.Mak&e.&Make                             <Cmd>call planet#term#RunCmd('make')<CR>
    an 500.10  🔨&b.Mak&e.Make\ &All                        <Cmd>call planet#term#RunCmd('make all')<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Help                       <Cmd>call planet#term#RunCmd('make help')<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Clean                      <Cmd>call planet#term#RunCmd('make clean')<CR>
    an 500.10  🔨&b.Mak&e.Make\ Distclea&n                  <Cmd>call planet#term#RunCmd('make distclean')<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Dist                       <Cmd>call planet#term#RunCmd('make dist')<CR>
    an 500.10  🔨&b.Mak&e.Make\ Di&stcheck                  <Cmd>call planet#term#RunCmd('make distcheck')<CR>
    an 500.10  🔨&b.Mak&e.Make\ Chec&k                      <Cmd>call planet#term#RunCmd('make check')<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Test                       <Cmd>call planet#term#RunCmd('make test')<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Install                    <Cmd>call planet#term#RunCmd('make install')<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Uninstall                  <Cmd>call planet#term#RunCmd('make uninstall')<CR>
    an 500.10  🔨&b.Mak&e.Set\ $MAKEFLAGS                   <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    an 500.10  🔨&b.&KBuild.make\ &oldconfig                <Cmd>call planet#term#RunCmd("yes '' \| make oldconfig")<CR>
    an 500.10  🔨&b.&KBuild.make\ &menuconfig               <Cmd>call planet#term#RunCmdTab('make menuconfig')<CR>
    an 500.10  🔨&b.&KBuild.ma&ke                           <Cmd>call planet#term#RunCmd('make')<CR>
    an 500.10  🔨&b.&KBuild.ma&ke\ Target\.\.\.             <Cmd>call planet#term#RunCmdAskArgs('make', 'Target: ')<CR>
    an 500.10  🔨&b.&KBuild.&Edit\ \.config                 <Cmd>e .config<CR>
    an 500.10  🔨&b.&KBuild.&Edit\ $MAKEFLAGS               <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    an 500.10  🔨&b.&KBuild.make\ c&lean                    <Cmd>call planet#term#RunCmd('make clean')<CR>
    an 500.10  🔨&b.&KBuild.make\ mr&proper                 <Cmd>call planet#term#RunCmd('make mrproper')<CR>
    an 500.10  🔨&b.&KBuild.make\ dis&tclean                <Cmd>call planet#term#RunCmd('make distclean')<CR>
    an 500.10  🔨&b.&KBuild.make\ &help                     <Cmd>call planet#term#RunCmd('make help')<CR>
    an 500.10  🔨&b.&KBuild.make\ &config                   <Cmd>call planet#term#RunCmd('make config')<CR>
    an 500.10  🔨&b.&KBuild.make\ allyesconfig              <Cmd>call planet#term#RunCmd('make allyesconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ allnoconfig               <Cmd>call planet#term#RunCmd('make allnoconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ defconfig                 <Cmd>call planet#term#RunCmd('make defconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ install                   <Cmd>call planet#term#RunCmd('make install')<CR>
    an 500.10  🔨&b.&KBuild.make\ uninstall                 <Cmd>call planet#term#RunCmd('make uninstall')<CR>
    an 500.10  🔨&b.&KBuild.make\ randconfig                <Cmd>call planet#term#RunCmd('make randconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ allmodconfig              <Cmd>call planet#term#RunCmd('make allmodconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ &nconfig                  <Cmd>call planet#term#RunCmd('make nconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ &xconfig                  <Cmd>call planet#term#RunCmd('make xconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ &gconfig                  <Cmd>call planet#term#RunCmd('make gconfig')<CR>
    an 500.10  🔨&b.&KBuild.make\ &tags                     <Cmd>call planet#term#RunCmd('make tags')<CR>
    an 500.10  🔨&b.&CMake.Select\ Build\ Dir               <Cmd>call planet#build#SelectBuildDir()<CR>
    an 500.10  🔨&b.&CMake.Create\ &In-Tree\ Build\ Dir     <Cmd>call planet#build#NewInTreeBuildDir()<CR>
    an 500.10  🔨&b.&CMake.Create\ &OOT\ Build\ Dir         <Cmd>call planet#build#NewOOTBuildDir()<CR>
    an 500.10  🔨&b.&CMake.Browse\ Build\ Directory         <Cmd>exe 'Fern ' .. g:PV_build_dir<CR>
    an 500.10  🔨&b.&CMake.--1-- <Nop>
    an 500.10  🔨&b.&CMake.&Configure                       <Cmd>call planet#term#RunCmd('cmake ' .. getcwd(), v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&b.&CMake.Configure\ &Tui                  <Cmd>call planet#term#RunCmdTab('ccmake ' .. getcwd(), g:PV_build_dir)<CR>
    an 500.10  🔨&b.&CMake.Configure\ &Gui                  <Cmd>call planet#term#RunGuiApp('cmake-gui ' .. getcwd(), g:PV_build_dir)<CR>
    an 500.10  🔨&b.&CMake.Configure\ Android\ armv7        <Cmd>call planet#term#RunScript('configure-cmake-android-armv7')<CR>
    an 500.10  🔨&b.&CMake.Configure\ Android\ x86          <Cmd>call planet#term#RunScript('configure-cmake-android-x86')<CR>
    an 500.10  🔨&b.&CMake.--2-- <Nop>
    an 500.10  🔨&b.&CMake.&Build                           <Cmd>call planet#term#RunCmd('cmake --build .', v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&b.&CMake.&Rebuild                         <Cmd>call planet#term#RunCmd('cmake --build . --target clean && cmake --build .', v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&b.&CMake.Clean                            <Cmd>call planet#term#RunCmd('cmake --build . --target clean', v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&b.&CMake.--3-- <Nop>
    an 500.10  🔨&b.&CMake.Generate\ compile_commands\.json <Cmd>call planet#env#SetEnvVarValue('CMAKE_EXPORT_COMPILE_COMMANDS=ON')<CR><Cmd>call planet#term#RunCmd('cmake ' .. getcwd(), v:false, v:false, v:false, g:PV_build_dir)<CR>
    an 500.10  🔨&b.&Meson.Set\ DESTDIR                     <Cmd>!make<CR>
    an 500.10  🔨&b.Ar&duino.Verify                          <Cmd>ArduinoVerify<CR>
    an 500.10  🔨&b.Ar&duino.Upload                          <Cmd>ArduinoUpload<CR>
    an 500.10  🔨&b.Ar&duino.Upload\ and\ Serial             <Cmd>ArduinoUploadAndSerial<CR>
    an 500.10  🔨&b.Ar&duino.Serial                          <Cmd>ArduinoSerial<CR>
    an 500.10  🔨&b.Ar&duino.Set\ Baud                       <Cmd>ArduinoSetBaud<CR>
    an 500.10  🔨&b.Ar&duino.--2-- <Nop>
    an 500.10  🔨&b.Ar&duino.Choose\ Board                   <Cmd>ArduinoChooseBoard<CR>
    an 500.10  🔨&b.Ar&duino.Choose\ Programmer              <Cmd>ArduinoChooseProgrammer<CR>
    an 500.10  🔨&b.Ar&duino.Choose\ Port                    <Cmd>ArduinoChoosePort<CR>
    an 500.10  🔨&b.Ar&duino.--1-- <Nop>
    an 500.10  🔨&b.Ar&duino.Info                            <Cmd>ArduinoInfo<CR>
    an 500.10  🔨&b.Ar&duino.Set\ Arduino\ Dir               :let g:arduino_dir = 'TODO'
    an 500.10  🔨&b.Ar&duino.Set\ Build\ Dir                 :let g:arduino_build_path = 'TODO'
    an 500.10  🔨&b.Ar&duino.Use\ Arduino\ IDE               :let g:arduino_use_cli = 0
    an 500.10  🔨&b.Ar&duino.Use\ arduino-cli                :let g:arduino_use_cli = 1
    an 500.10  🔨&b.&PlatformIO.&Build                       <Cmd>call planet#term#RunCmd('pio run')<CR>
    an 500.10  🔨&b.&PlatformIO.&Upload                      <Cmd>call planet#term#RunCmd('pio run -t upload')<CR>
    an 500.10  🔨&b.&PlatformIO.Serial\ &Monitor             <Cmd>call planet#term#RunCmd('pio device monitor')<CR>
    an 500.10  🔨&b.&PlatformIO.Serial\ &Monitor\ in\ Tab    <Cmd>call planet#term#RunCmdTab('pio device monitor')<CR>
    an 500.10  🔨&b.&PlatformIO.Build\ FS\ &Image            <Cmd>call planet#term#RunCmd('pio run -t buildfs')<CR>
    an 500.10  🔨&b.&PlatformIO.Upload\ &FS\ Image           <Cmd>call planet#term#RunCmd('pio run -t uploadfs')<CR>
    an 500.10  🔨&b.&PlatformIO.Me&nuconfig                  <Cmd>call planet#term#RunCmdTab('pio run -t menuconfig')<CR>
    an 500.10  🔨&b.&PlatformIO.&Clean                       <Cmd>call planet#term#RunCmd('pio run -t clean')<CR>
    an 500.10  🔨&b.&PlatformIO.&Generate\ Compilation\ Database <Cmd>call planet#term#RunScript('pio-gen-compile-db')<CR>
    an 500.10  🔨&b.&PlatformIO.&Activate                    <Cmd>Dotenv $HOME/.platformio/penv/bin/activate<CR>
    an 500.10  🔨&b.&PlatformIO.&Web\ UI                     <Cmd>call planet#term#RunCmd('pio home')<CR>
    an 500.10  🔨&b.&PlatformIO.Up&date\ Packages            <Cmd>call planet#term#RunCmd('pio update')<CR>
    an 500.10  🔨&b.&PlatformIO.Upg&rade\ PlatformIO         <Cmd>call planet#term#RunCmd('pio upgrade')<CR>
    an 500.10  🔨&b.&ROS.Build\ Workspace                    :TODO
    an 500.10  🔨&b.&ROS.roslaunch                           :TODO
    an 500.10  🔨&b.&ROS.rosrun                              :TODO
    an 500.10  🔨&b.&ROS.Install.Kinetic                     :TODO
    an 500.10  🔨&b.&ROS.Install.Melodic                     :TODO
    an 500.10  🔨&b.&ROS.Install.Noetic                      :TODO
    an 500.10  🔨&b.&ROS\ 2.Setup                            :TODO
    an 500.10  🔨&b.&Yocto.Setup                             :TODO
    an 500.10  🔨&b.&Flutter.Doctor                          <Cmd>call planet#term#RunCmd('flutter doctor')<CR>
    an 500.10  🔨&b.&Flutter.Set\ Android\ Sdk\ Location     <Cmd>call planet#term#RunCmd('flutter config --android-sdk')<CR>
    an 500.10  🔨&b.&Flutter.Accept\ Android\ Licenses       <Cmd>call planet#term#RunCmd('flutter doctor --android-licenses')<CR>
    an 500.10  🔨&b.&Flutter.Create\ Project                 <Cmd>call planet#term#RunCmd('flutter create new_project')<CR>
    an 500.10  🔨&b.&Flutter.Run                             <Cmd>FlutterRun<CR>
    an 500.10  🔨&b.&Flutter.Hot\ Reload                     <Cmd>FlutterHotReload<CR>
    an 500.10  🔨&b.&Flutter.Hot\ Restart                    <Cmd>FlutterHotRestart<CR>
    an 500.10  🔨&b.&Flutter.Stop\ App                       <Cmd>FlutterQuit<CR>
    an 500.10  🔨&b.&Flutter.Devices                         <Cmd>FlutterDevices<CR>
    an 500.10  🔨&b.&Flutter.Output                          <Cmd>FlutterSplit<CR>
    an 500.10  🔨&b.&Flutter.Emulators                       <Cmd>FlutterEmulators<CR>
    an 500.10  🔨&b.&Flutter.Launch\ Emulators               <Cmd>FlutterEmulatorsLaunch<CR>
    an 500.10  🔨&b.&Flutter.Toggle\ Visual\ Debug           <Cmd>FlutterVisualDebug<CR>
    an 500.10  🔨&b.&Flutter.Add\ Desktop\ Linux\ Build      <Cmd>call planet#term#RunCmd('flutter config --enable-linux-desktop')<CR>
    an 500.10  🔨&b.&Flutter.Add\ Desktop\ Macos\ Build      <Cmd>call planet#term#RunCmd('flutter config --enable-macos-desktop')<CR>
    an 500.10  🔨&b.&Flutter.Add\ Desktop\ Windows\ Build    <Cmd>call planet#term#RunCmd('flutter config --enable-windows-desktop')<CR>
    an 500.10  🔨&b.Elec&tron.List\ Project\ Deps            <Cmd>call planet#term#RunCmd('npm list --depth=0')<CR>
    an 500.10  🔨&b.Elec&tron.--1-- <Nop>
    an 500.10  🔨&b.Elec&tron.Run\ App                       <Cmd>call planet#term#RunCmd('electron .')<CR>
    an 500.10  🔨&b.Elec&tron.Run\ with\ npm                 <Cmd>call planet#term#RunCmd('npm start')<CR>
    an 500.10  🔨&b.Elec&tron.Run\ with\ auto\ reload        <Cmd>call planet#term#RunCmd('nodemon --exec electron .')<CR>
    an 500.10  🔨&b.Elec&tron.Npm\ run\ with\ auto\ reload   <Cmd>call planet#term#RunCmd('npm run watch')<CR>
    an 500.10  🔨&b.Elec&tron.--2-- <Nop>
    an 500.10  🔨&b.Elec&tron.Start\ Debug                   <Cmd>call planet#term#RunCmd('electron --inspect=5858 .')<CR>
    an 500.10  🔨&b.Elec&tron.Break\ on\ Start               <Cmd>call planet#term#RunCmd('electron --inspect-brk=5858 .')<CR>
    an 500.10  🔨&b.Elec&tron.--3-- <Nop>
    an 500.10  🔨&b.Elec&tron.Rebuild\ Native\ Package\.\.\. <Cmd>call planet#term#RunCmdAskArgs('electron-rebuild', 'Package name: ')<CR>
    an 500.10  🔨&b.Elec&tron.--4-- <Nop>
    an 500.10  🔨&b.Elec&tron.Bulid\ Linux\ AppImage         <Cmd>call planet#term#RunCmd('electron-builder --linux AppImage')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Linux\ snap             <Cmd>call planet#term#RunCmd('electron-builder --linux snap')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Linux\ deb              <Cmd>call planet#term#RunCmd('electron-builder --linux deb')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Linux\ tar\.gz          <Cmd>call planet#term#RunCmd('electron-builder --linux tar.gz')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Linux\ apk              <Cmd>call planet#term#RunCmd('electron-builder --linux apk')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Mac\ dmg                <Cmd>call planet#term#RunCmd('electron-builder --mac default')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Mac\ App\ Store         <Cmd>call planet#term#RunCmd('electron-builder --mac mas')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Mac\ tar\.gz            <Cmd>call planet#term#RunCmd('electron-builder --mac tar.gz')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Windows\ self-signed-cert <Cmd>call planet#term#RunCmd('electron-builder create-self-signed-cert')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Windows\ nsis           <Cmd>call planet#term#RunCmd('electron-builder --windows nsis')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Windows\ Portable\ App  <Cmd>call planet#term#RunCmd('electron-builder --windows portable')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Windows\ Appx           <Cmd>call planet#term#RunCmd('electron-builder --windows appx')<CR>
    an 500.10  🔨&b.Elec&tron.Bulid\ Windows\ zip            <Cmd>call planet#term#RunCmd('electron-builder --windows zip')<CR>
    an 500.10  🔨&b.Elec&tron.--5-- <Nop>
    an 500.10  🔨&b.Elec&tron.Install\ as\ Local\ Dep        <Cmd>call planet#term#RunCmd('npm i -D electron@latest')<CR>
    an 500.10  🔨&b.Elec&tron.Install\ Project\ Deps         <Cmd>call planet#term#RunCmd('npm i')<CR>
    an 500.10  🔨&b.Elec&tron.Add\ electron-builder          <Cmd>call planet#term#RunCmd('npm i -D electron-builder')<CR>
    an 500.10  🔨&b.Elec&tron.Add\ electron-updater          <Cmd>call planet#term#RunCmd('npm i electron-updater')<CR>
    an 500.10  🔨&b.Elec&tron.Install\ electron-rebuild      <Cmd>call planet#term#RunCmd('sudo npm install -g electron-rebuild')<CR>
    an 500.10  🔨&b.Elec&tron.Install\ electron-builder      <Cmd>call planet#term#RunCmd('sudo npm install -g electron-builder')<CR>
    an 500.10  🔨&b.&Other.&Ninja.Set\ DESTDIR               <Cmd>!ninja<CR>
    an 500.10  🔨&b.&Other.&QMake.Set\ DESTDIR               <Cmd>!qmake<CR>
    an 500.10  🔨&b.&Other.&Scons.Run\ Target\.\.\.          <Cmd>call planet#term#RunCmdAskArgs('scons', 'scons: ', ' -j8 .')<CR>
    an 500.10  🔨&b.Deploy <Nop>
    an disable 🔨&b.Deploy
    an 500.10  🔨&b.Windeployqt.Deploy                      :!make<CR>
    an 500.10  🔨&b.Macdeployqt.Deploy                      :!make<CR>
    an 500.10  🔨&b.Linuxdeploy.Deploy                      :!make<CR>
    an 500.10  🔨&b.Androiddeployqt.Deploy                  :!make<CR>
    an 500.10  🔨&b.Package <Nop>
    an disable 🔨&b.Package
    an 500.10  🔨&b.fpm.Build                               :!make<CR>
    an 500.10  🔨&b.PyInstaller.Build\ app\.spec             <Cmd>call planet#term#RunCmd('pyinstaller app.spec')<CR>
    an 500.10  🔨&b.PyInstaller.Basic\ Build\ app\.py        <Cmd>call planet#term#RunCmd('pyinstaller --windowed app.py')<CR>
    an 500.10  🔨&b.PyInstaller.Install                      <Cmd>call planet#term#RunCmd('pip install PyInstaller pyinstaller-hooks-contrib')<CR>
    an 500.10  🔨&b.PyInstaller.Update\ PyInstaller          <Cmd>call planet#term#RunCmd('pip install --upgrade PyInstaller pyinstaller-hooks-contrib')<CR>
    an 500.10  🔨&b.CPack.Build                             :!make<CR>
    an 500.10  🔨&b.AppImage.Build                          :!make<CR>
    an 500.10  🔨&b.Snap.Build                              :!make<CR>
    an 500.10  🔨&b.FlatPak.Build                           :!make<CR>
    an 500.10  🔨&b.pyUpdater.Build                         :!make<CR>
    an 500.10  🔨&b.Installer <Nop>
    an disable 🔨&b.Installer
    an 500.10  🔨&b.Qt\ Installer\ Framework.Build          :!make<CR>
    " an 500.10  🔨&b.Choose\ Make\ Target                    :make <C-z>"TODO
    " an 500.10  🔨&b.Rerun\ Previous\ Make                   :make prev_target
    " an 500.10  🔨&b.--1-- <Nop>
    " an 500.10  🔨&b.Set\ Compiler\ Globally<Tab>:compiler!\ {compiler} :compiler! 
    " an 500.10  🔨&b.Set\ Compiler\ for\ Buffer<Tab>:compiler\ {compiler} :compiler 

    " Run
    an 510.10  ▶️&r.Run <Nop>
    an disable ▶️&r.Run
    an 510.500 ▶️&r.--1-- <Nop>
    an 510.500 ▶️&r.Add\ Run\ Configuration                 <Cmd>call planet#run#AddConfig()<CR>
    an 510.500 ▶️&r.Edit\ Run\ Configurations               <Cmd>call planet#run#EditConfig()<CR>

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
    an 550.10  💻&c.Terminal <Nop>
    an disable 💻&c.Terminal
    an 550.10  💻&c.N&ew                                    <Cmd>botright terminal ++kill=kill ++rows=10<CR>
    an 550.10  💻&c.New\ &Here                              <Cmd>terminal ++curwin ++kill=kill<CR>
    an 550.10  💻&c.New\ &VSplit                            <Cmd>vertical terminal ++kill=kill<CR>
    an 550.10  💻&c.New\ &Tab                               <Cmd>tab terminal ++kill=kill<CR>
    an 550.10  💻&c.--1-- <Nop>
    an 550.10  💻&c.&Run\ Command\.\.\.                     <Cmd>call planet#term#RunCmdAsk('Command: ')<CR>
    an 550.10  💻&c.&Watch\ Command\.\.\.                   <Cmd>call planet#term#RunCmdAskArgs('watch -n0', 'Command: ')<CR>
    an 550.10  💻&c.--2-- <Nop>
    an 550.10  💻&c.P&ython\ Shell                          <Cmd>botright terminal ++kill=kill ++rows=10 python<CR>
    an 550.10  💻&c.&IPython\ Shell                         <Cmd>botright terminal ++kill=kill ++rows=10 ipython<CR>
    an 550.10  💻&c.&bpython\ Shell                         <Cmd>botright terminal ++kill=kill ++rows=10 bpython<CR>
    an 550.10  💻&c.C&++\ Shell                             <Cmd>botright terminal ++kill=kill ++rows=10 cling<CR>
    an 550.10  💻&c.&Octave\ CLI                            <Cmd>botright terminal ++kill=kill ++rows=10 octave-cli<CR>
    an 550.10  💻&c.Calculator\ (&bc)                       <Cmd>botright terminal ++kill=kill ++rows=10 bc<CR>
    an 550.10  💻&c.--3-- <Nop>
    an 550.10  💻&c.&Close\ Output                          <Cmd>call planet#term#CloseOutputWindow()<CR>
    an 550.10  💻&c.Terminal\ List <Nop>
    an disable 💻&c.Terminal\ List
    an 550.10  💻&c.Output\ List <Nop>
    an disable 💻&c.Output\ List
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
    silent! aunmenu 💻&c
  endif
endfunc
