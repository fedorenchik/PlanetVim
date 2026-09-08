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
    am 310.10  🪧&].Build\ tags\ File                       <Cmd>call planet#integrations#Command(['ctags', '-R', '.'])<CR>
    am 310.10  🪧&].Generate\ tags\.vim\ File  <Cmd>call planet#integrations#Tags('tags')<CR>
    am 310.10  🪧&].Highlight\ tags\ from\ tags\.vim        <Cmd>so tags.vim<CR>
    am 310.10  🪧&].Generate\ types\.vim\ File  <Cmd>call planet#integrations#Tags('types')<CR>
    am 310.10  🪧&].Highlight\ tags\ from\ types\.vim       <Cmd>so types.vim<CR>

    an 500.10  🎚️&{.Virtual\ Environments <Nop>
    an disable 🎚️&{.Virtual\ Environments
    an 500.10  🎚️&{.&Docker.CLI\ UI\ (lazydocker)           <Cmd>call planet#term#RunCmdTab(['lazydocker'])<CR>
    an 500.10  🎚️&{.&Docker.--1-- <Nop>
    an 500.10  🎚️&{.&Docker.List\ Running\ Containers       <Cmd>call planet#integrations#Command(['docker', 'container', 'ls'])<CR>
    an 500.10  🎚️&{.&Docker.List\ All\ Containers           <Cmd>call planet#integrations#Command(['docker', 'container', 'ls', '-a'])<CR>
    an 500.10  🎚️&{.&Docker.--2-- <Nop>
    an 500.10  🎚️&{.&Docker.List\ Images                    <Cmd>call planet#integrations#Command(['docker', 'image', 'ls'])<CR>
    an 500.10  🎚️&{.&Pipenv.Start\ Shell                    <Cmd>call planet#integrations#Command(['pipenv', 'shell'])<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ python\ main\.py           <Cmd>call planet#integrations#Command(['pipenv', 'run', 'python', './main.py'])<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ python\ app\.py            <Cmd>call planet#integrations#Command(['pipenv', 'run', 'python', './app.py'])<CR>
    an 500.10  🎚️&{.&Pipenv.Run\ Command\.\.\.              <Cmd>call planet#integrations#Ask(['pipenv', 'run'], 'Command: ', [])<CR>
    an 500.10  🎚️&{.&Pipenv.Update\ Pipfile\.lock           <Cmd>call planet#integrations#Command(['pipenv', 'lock'])<CR>
    an 500.10  🎚️&{.&Pipenv.--1-- <Nop>
    an 500.10  🎚️&{.&Pipenv.New\ Project                    <Cmd>call planet#integrations#Command(['pipenv', '--python', '3'])<CR>
    an 500.10  🎚️&{.&Pipenv.New\ Project\ with\ Python      <Cmd>call planet#integrations#Ask(['pipenv', '--python'], 'Python Version: ', [])<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Run\ &&\ Dev\ Deps     <Cmd>call planet#integrations#Command(['pipenv', 'install', '--dev'])<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Run\ Deps              <Cmd>call planet#integrations#Command(['pipenv', 'install'])<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Packages\.\.\.         <Cmd>call planet#integrations#Ask(['pipenv', 'install'], 'Packages: ', [])<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Dev\ Packages\.\.\.    <Cmd>call planet#integrations#Ask(['pipenv', 'install', '--dev'], 'Packages: ', [])<CR>
    an 500.10  🎚️&{.&Pipenv.Update\ (Lock\ &&\ Sync)        <Cmd>call planet#integrations#Command(['pipenv', 'update'])<CR>
    an 500.10  🎚️&{.&Pipenv.Sync\ with\ Pipfile\.lock       <Cmd>call planet#integrations#Command(['pipenv', 'sync'])<CR>
    an 500.10  🎚️&{.&Pipenv.--2-- <Nop>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Extra\ Packages      <Cmd>call planet#integrations#Command(['pipenv', 'clean'])<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Packages\.\.\.       <Cmd>call planet#integrations#Ask(['pipenv', 'uninstall'], 'Packages: ', [])<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ Dev\ Packages        <Cmd>call planet#integrations#Command(['pipenv', 'uninstall', '--all-dev'])<CR>
    an 500.10  🎚️&{.&Pipenv.Uninstall\ All                  <Cmd>call planet#integrations#Command(['pipenv', 'uninstall', '--all'])<CR>
    an 500.10  🎚️&{.&Pipenv.Remove\ Project's\ VEnv         <Cmd>call planet#integrations#Command(['pipenv', '--rm'])<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install      <Cmd>call planet#integrations#Command(['pipenv', 'install', '-r', 'requirements.txt'])<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install\ Dev <Cmd>call planet#integrations#Command(['pipenv', 'install', '-r', 'dev-requirements.txt', '--dev'])<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export  <Cmd>call planet#integrations#ExportRequirements()<CR>
    an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export\ Dev  <Cmd>call planet#integrations#ExportRequirements(v:true)<CR>
    an 500.10  🎚️&{.&Pipenv.--3-- <Nop>
    an 500.10  🎚️&{.&Pipenv.Open\ Module\.\.\.              <Cmd>call planet#integrations#Ask(['pipenv', 'open'], 'Module: ', [])<CR>
    an 500.10  🎚️&{.&Pipenv.Security\ Check                 <Cmd>call planet#integrations#Command(['pipenv', 'check'])<CR>
    an 500.10  🎚️&{.&Pipenv.Dependency\ Graph               <Cmd>call planet#integrations#Command(['pipenv', 'graph'])<CR>
    an 500.10  🎚️&{.&Pipenv.Reverse\ Dependency\ Graph      <Cmd>call planet#integrations#Command(['pipenv', 'graph', '--reverse'])<CR>
    an 500.10  🎚️&{.&Pipenv.Enable\ Site\ Packages          <Cmd>call planet#integrations#Command(['pipenv', '--site-packages'])<CR>
    an 500.10  🎚️&{.&Pipenv.Disable\ Site\ Packages         <Cmd>call planet#integrations#Command(['pipenv', '--no-site-packages'])<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Project\ Root            <Cmd>call planet#integrations#Command(['pipenv', '--where'])<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ VEnv\ Dir                <Cmd>call planet#integrations#Command(['pipenv', '--venv'])<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Env\ Vars                <Cmd>call planet#integrations#Command(['pipenv', '--envs'])<CR>
    an 500.10  🎚️&{.&Pipenv.Edit\ \.env                     <Cmd>e .env<CR>
    an 500.10  🎚️&{.&Pipenv.Print\ Version                  <Cmd>call planet#integrations#Command(['pipenv', '--version'])<CR>
    an 500.10  🎚️&{.&Pipenv.Clear\ Caches                   <Cmd>call planet#integrations#Command(['pipenv', '--clear'])<CR>
    an 500.10  🎚️&{.&Pipenv.Install\ Pipenv                 <Cmd>call planet#integrations#Command(['pip', 'install', '--user', 'pipenv'])<CR>
    an 500.10  🎚️&{.C&onda.Activate\.\.\.  <Cmd>call planet#integrations#Conda()<CR>
    an 500.10  🎚️&{.C&onda.Install\ from\ requirements\.txt <Cmd>call planet#integrations#Command(['conda', 'install', '--file', 'requirements.txt'])<CR>
    an 500.10  🎚️&{.C&onda.Create\ from\ environment\.yml   <Cmd>call planet#integrations#Command(['conda', 'env', 'create', '-f', 'environment.yml'])<CR>
    an 500.10  🎚️&{.C&onda.Deactivate  <Cmd>call planet#integrations#RestoreEnvironment()<CR>
    an 500.10  🎚️&{.C&onda.Create\ New\ Environment\.\.\.   <Cmd>call planet#integrations#Ask(['conda', 'create', '--name'], 'Name: ', ['conda'])<CR>
    an 500.10  🎚️&{.C&onda.Activate\ Anaconda  <Cmd>call planet#integrations#Conda('base')<CR>
    an 500.10  🎚️&{.C&onda.Deactivate\ Anaconda  <Cmd>call planet#integrations#RestoreEnvironment()<CR>
    an 500.10  🎚️&{.C&onda.Conda\ Init  <Cmd>call planet#integrations#Command(['conda', 'init'])<CR>
    an 500.10  🎚️&{.C&onda.Conda\ Info                      <Cmd>call planet#integrations#Command(['conda', 'info'])<CR>
    an 500.10  🎚️&{.Android.Download\ System\ Image  <Cmd>call planet#integrations#Run('sdk-image')<CR>
    an 500.10  🎚️&{.Android.Create\ AVD  <Cmd>call planet#integrations#Run('sdk-avd')<CR>
    an 500.10  🎚️&{.Vagrant.Test  <Cmd>call planet#integrations#Run('vagrant')<CR>
    an 500.10  🎚️&{.QEMU.Test  <Cmd>call planet#integrations#Run('qemu')<CR>
    an 500.10  🎚️&{.QEMU\ Schroot.qemu-debootstrap  <Cmd>call planet#integrations#Run('qemu-debootstrap')<CR>
    an 500.10  🎚️&{.Configuration <Nop>
    an disable 🎚️&{.Configuration
    an 500.10  🎚️&{.Install\ Qt.Set\ $QTDIR                 <Cmd>call planet#env#SetEnvVar('QTDIR')<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version        <Cmd>call planet#integrations#QtInstall('desktop', v:false)<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Modules <Cmd>call planet#integrations#QtInstall('desktop', v:true)<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Android <Cmd>call planet#integrations#QtInstall('android', v:false)<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Android\ Modules <Cmd>call planet#integrations#QtInstall('android', v:true)<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Wasm  <Cmd>call planet#integrations#QtInstall('wasm', v:false)<CR>
    an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Wasm\ Modules <Cmd>call planet#integrations#QtInstall('wasm', v:true)<CR>
    an 500.10  🎚️&{.Install\ Conan\ Pkg.Install  <Cmd>call planet#integrations#Run('conan')<CR>
    an 500.10  🎚️&{.Install\ pip\ Pkg.PySide6               <Cmd>call planet#integrations#Command(['pip', 'install', 'PySide6'])<CR>
    an 500.10  🎚️&{.Install\ pip\ Pkg.Jupyter\ Notebook     <Cmd>call planet#integrations#Command(['pip', 'install', 'notebook'])<CR>
    an 500.10  🎚️&{.Install\ pip\ Pkg.JupyterLab            <Cmd>call planet#integrations#Command(['pip', 'install', 'jupyterlab'])<CR>
    an 500.10  🎚️&{.Npm.Start\ App\ for\ Development        <Cmd>call planet#integrations#Command(['npm', 'run', 'dev'])<CR>
    an 500.10  🎚️&{.Npm.Start\ Build                        <Cmd>call planet#integrations#Command(['npm', 'run', 'build'])<CR>
    an 500.10  🎚️&{.Npm.Start\ App                          <Cmd>call planet#integrations#Command(['npm', 'run', 'serve'])<CR>
    an 500.10  🎚️&{.Npm.Install\ Project\ Packages          <Cmd>call planet#integrations#Command(['npm', 'install'])<CR>
    an 500.10  🎚️&{.Npm.Install\ Packages\.\.\.             <Cmd>call planet#integrations#Ask(['npm', 'install'], 'Packages: ', [])<CR>
    an 500.10  🎚️&{.Npm.Install\ Packages\ Globally\.\.\.   <Cmd>call planet#integrations#Ask(['npm', 'install', '-g'], 'Packages: ', [])<CR>
    an 500.10  🎚️&{.Npm.Install\ create-nuxt-app            <Cmd>call planet#integrations#Command(['npm', 'install', '-g', 'create-nuxt-app'])<CR>
    an 500.10  🎚️&{.--1-- <Nop>
    an 500.10  🎚️&{.Set\ Compiler.gcc  <Cmd>call planet#integrations#Compiler('gcc')<CR>
    an 500.10  🎚️&{.Set\ Compiler.clang  <Cmd>call planet#integrations#Compiler('clang')<CR>
    an 500.10  🎚️&{.Set\ Compiler.emcc\ (wasm,\ emscripten)  <Cmd>call planet#integrations#Compiler('emcc')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Raspberry\ Pi  <Cmd>call planet#integrations#Compiler('raspberry')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.ESP32  <Cmd>call planet#integrations#Compiler('esp32')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Arduino  <Cmd>call planet#integrations#Compiler('arduino')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Jetson\ Nano  <Cmd>call planet#integrations#Compiler('jetson')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.BeagleBone\ Black  <Cmd>call planet#integrations#Compiler('beaglebone')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Coral  <Cmd>call planet#integrations#Compiler('coral')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.HiKey970  <Cmd>call planet#integrations#Compiler('hikey')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.--1-- <Nop>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Host  <Cmd>call planet#integrations#ConfigureValue('host')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Target  <Cmd>call planet#integrations#ConfigureValue('target')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compilation.Sysroot  <Cmd>call planet#integrations#ConfigureValue('sysroot')<CR>
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Build  <Cmd>call planet#integrations#ConfigureValue('build')<CR>
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Host  <Cmd>call planet#integrations#ConfigureValue('host')<CR>
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Target  <Cmd>call planet#integrations#ConfigureValue('target')<CR>
    an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Sysroot  <Cmd>call planet#integrations#ConfigureValue('sysroot')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-mingw  <Cmd>call planet#integrations#Compiler('mingw')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-arm  <Cmd>call planet#integrations#Compiler('arm')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-aarch64  <Cmd>call planet#integrations#Compiler('aarch64')<CR>
    an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-avr  <Cmd>call planet#integrations#Compiler('avr')<CR>
    an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Installed    <Cmd>call planet#integrations#Command(['pyenv', 'versions'])<CR>
    an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Available    <Cmd>call planet#integrations#Command(['pyenv', 'install', '--list'])<CR>
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
    an 500.10  🎚️&{.D&irenv.&Allow\ Here                    <Cmd>call planet#integrations#Command(['direnv', 'allow'])<CR>
    an 500.10  🎚️&{.D&irenv.&Run\ \.envrc                   <Cmd>DirenvExport<CR>
    an 500.10  🎚️&{.D&irenv.E&dit\ \.direnvrc               <Cmd>EditDirenvrc<CR>
    an 500.10  🎚️&{.D&irenv.De&ny\ Here                     <Cmd>call planet#integrations#Command(['direnv', 'deny'])<CR>
    an 500.10  🎚️&{.D&irenv.P&rune\ Old\ Files              <Cmd>call planet#integrations#Command(['direnv', 'prune'])<CR>
    an 500.10  🎚️&{.Editor&Config.&Add\ New                 <Cmd>e .editorconfig<CR>
    an 500.10  🎚️&{.Editor&Config.&Reload                   <Cmd>EditorConfigReload<CR>
    an 500.10  🎚️&{.Editor&Config.Disable\ for\ &buffer     <Cmd>let b:EditorConfig_disable=1<CR>
    an 500.10  🎚️&{.Editor&Config.--1-- <Nop>
    an 500.10  🎚️&{.Editor&Config.&Enable                   <Cmd>EditorConfigEnable<CR>
    an 500.10  🎚️&{.Editor&Config.&Disable                  <Cmd>EditorConfigDisable<CR>

    an 500.10  📐&}.Dev\ Tools <Nop>
    an disable 📐&}.Dev\ Tools
    an 500.10  📐&}.Parser\ Generators.flex  <Cmd>call planet#integrations#Run('flex')<CR>
    an 500.10  📐&}.Parser\ Generators.bison  <Cmd>call planet#integrations#Run('bison')<CR>
    an 500.10  📐&}.&Qt\ Tools.Qt\ Creator                  <Cmd>call planet#integrations#Command(['qtcreator', expand('%:p')], #{qt:v:true})<CR>
    an 500.10  📐&}.&Qt\ Tools.Designer                     <Cmd>call planet#integrations#Command(['designer', expand('%:p')], #{qt:v:true})<CR>
    an 500.10  📐&}.&Qt\ Tools.Assistant                    <Cmd>call planet#term#RunGuiApp(['assistant'])<CR>
    an 500.10  📐&}.&Qt\ Tools.PixelTool                    <Cmd>call planet#term#RunGuiApp(['pixeltool'])<CR>
    an 500.10  📐&}.&Qt\ Tools.QDbusViewer                  <Cmd>call planet#term#RunGuiApp(['qdbusviewer'])<CR>
    an 500.10  📐&}.&Qt\ Tools.pyside6-uic  <Cmd>call planet#integrations#Run('pyside6-uic')<CR>
    an 500.10  📐&}.&Qt\ Tools.pyside6-rcc  <Cmd>call planet#integrations#Run('pyside6-rcc')<CR>
    an 500.10  📐&}.&Qt\ Tools.Generate\ qt\.conf  <Cmd>call planet#integrations#Write('qt-conf')<CR>
    an 500.10  📐&}.&Qt\ Tools.androidtestrunner  <Cmd>call planet#integrations#Run('androidtestrunner')<CR>
    an 500.10  📐&}.&Qt\ Tools.balsam  <Cmd>call planet#integrations#Run('balsam')<CR>
    an 500.10  📐&}.&Qt\ Tools.moc  <Cmd>call planet#integrations#Run('moc')<CR>
    an 500.10  📐&}.&Qt\ Tools.moc-ng  <Cmd>call planet#integrations#Run('moc-ng')<CR>
    an 500.10  📐&}.&Qt\ Tools.qdbus  <Cmd>call planet#integrations#Run('qdbus')<CR>
    an 500.10  📐&}.&Qt\ Tools.qdbuscpp2xml  <Cmd>call planet#integrations#Run('qdbuscpp2xml')<CR>
    an 500.10  📐&}.&Qt\ Tools.qdbusxml2cpp  <Cmd>call planet#integrations#Run('qdbusxml2cpp')<CR>
    an 500.10  📐&}.&Qt\ Tools.QLALR  <Cmd>call planet#integrations#Run('qlalr')<CR>
    an 500.10  📐&}.&Qt\ Tools.qsb  <Cmd>call planet#integrations#Run('qsb')<CR>
    an 500.10  📐&}.&Qt\ Tools.qtattributionsscanner  <Cmd>call planet#integrations#Run('qtattributionsscanner')<CR>
    an 500.10  📐&}.&Qt\ Tools.qt-cmake  <Cmd>call planet#integrations#Run('qt-cmake')<CR>
    an 500.10  📐&}.&Qt\ Tools.qt-configure-module  <Cmd>call planet#integrations#Run('qt-configure-module')<CR>
    an 500.10  📐&}.&Qt\ Tools.qtdiag  <Cmd>call planet#integrations#Run('qtdiag')<CR>
    an 500.10  📐&}.&Qt\ Tools.qtpaths  <Cmd>call planet#integrations#Run('qtpaths')<CR>
    an 500.10  📐&}.&Qt\ Tools.qtplugininfo  <Cmd>call planet#integrations#Run('qtplugininfo')<CR>
    an 500.10  📐&}.&Qt\ Tools.qtwaylandscanner  <Cmd>call planet#integrations#Run('qtwaylandscanner')<CR>
    an 500.10  📐&}.&Qt\ Tools.qvkgen  <Cmd>call planet#integrations#Run('qvkgen')<CR>
    an 500.10  📐&}.&Qt\ Tools.rcc  <Cmd>call planet#integrations#Run('rcc')<CR>
    an 500.10  📐&}.&Qt\ Tools.shadergen  <Cmd>call planet#integrations#Run('shadergen')<CR>
    an 500.10  📐&}.&Qt\ Tools.syncqt\.pl  <Cmd>call planet#integrations#Run('syncqt.pl')<CR>
    an 500.10  📐&}.&Qt\ Tools.tracegen  <Cmd>call planet#integrations#Run('tracegen')<CR>
    an 500.10  📐&}.&Qt\ Tools.uic  <Cmd>call planet#integrations#Run('uic')<CR>
    an 500.10  📐&}.&Qt\ Tools.SCXML  <Cmd>call planet#integrations#Run('scxml')<CR>
    an 500.10  📐&}.Qml.qml  <Cmd>call planet#integrations#Run('qml')<CR>
    an 500.10  📐&}.Qml.qmlcachegen  <Cmd>call planet#integrations#Run('qmlcachegen')<CR>
    an 500.10  📐&}.Qml.qmleasing  <Cmd>call planet#integrations#Run('qmleasing')<CR>
    an 500.10  📐&}.Qml.qmlformat  <Cmd>call planet#integrations#Run('qmlformat')<CR>
    an 500.10  📐&}.Qml.qmlimportscanner  <Cmd>call planet#integrations#Run('qmlimportscanner')<CR>
    an 500.10  📐&}.Qml.qmllint  <Cmd>call planet#integrations#Run('qmllint')<CR>
    an 500.10  📐&}.Qml.qmlplugindump  <Cmd>call planet#integrations#Run('qmlplugindump')<CR>
    an 500.10  📐&}.Qml.qmlpreview  <Cmd>call planet#integrations#Run('qmlpreview')<CR>
    an 500.10  📐&}.Qml.qmlprofiler  <Cmd>call planet#integrations#Run('qmlprofiler')<CR>
    an 500.10  📐&}.Qml.qmlscene  <Cmd>call planet#integrations#Run('qmlscene')<CR>
    an 500.10  📐&}.Qml.testrunner  <Cmd>call planet#integrations#Run('qmltestrunner')<CR>
    an 500.10  📐&}.Qml.qmltime  <Cmd>call planet#integrations#Run('qmltime')<CR>
    an 500.10  📐&}.Qml.qmltyperegistrar  <Cmd>call planet#integrations#Run('qmltyperegistrar')<CR>
    an 500.10  📐&}.Gtk\ Tools.Glade                        <Cmd>call planet#integrations#Command(['glade', expand('%:p')])<CR>
    an 500.10  📐&}.Gtk\ Tools.Glade\ Previewer             <Cmd>call planet#integrations#Command(['glade-previewer', '--filename', expand('%:p')])<CR>
    an 500.10  📐&}.Gtk\ Tools.Devhelp                      <Cmd>call planet#integrations#Command(['devhelp', '--search=' .. expand('<cword>')])<CR>
    an 500.10  📐&}.Gtk\ Tools.Devhelp\ Assistant           <Cmd>call planet#integrations#Command(['devhelp', '--search-assistant=' .. expand('<cword>')])<CR>
    an 500.10  📐&}.Kernel.Check\ &Patch  <Cmd>call planet#integrations#Run('kernel-checkpatch')<CR>
    an 500.10  📐&}.Kernel.Get\ Maintainers  <Cmd>call planet#integrations#Run('kernel-maintainer')<CR>
    an 500.10  📐&}.Kernel.Device\ Tree\ Compiler  <Cmd>call planet#integrations#Run('kernel-dtc')<CR>
    an 500.10  📐&}.Kernel.--1-- <Nop>
    an 500.10  📐&}.Kernel.&Generate\ compile_commands\.json  <Cmd>call planet#integrations#Run('kernel-compdb')<CR>
    an 500.10  📐&}.Kernel.&Generate\ tags                  <Cmd>call planet#integrations#Command(['make', 'tags'])<CR>
    an 500.10  📐&}.Kernel.&Generate\ GTAGS                 <Cmd>call planet#integrations#Command(['make', 'gtags'])<CR>
    an 500.10  📐&}.Kernel.&Generate\ cscope\.out           <Cmd>call planet#integrations#Command(['make', 'cscope'])<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Run\ Command\ in\ New\ Instance  <Cmd>call planet#integrations#Run('xvfb-command')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).--1-- <Nop>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Run\ Command  <Cmd>call planet#integrations#Ask([], 'Command using current DISPLAY')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).View  <Cmd>call planet#integrations#Run('xvfb-view')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Take\ Screenshot  <Cmd>call planet#integrations#Run('xvfb-screenshot')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).--2-- <Nop>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Start  <Cmd>call planet#integrations#XDisplay('start')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Stop  <Cmd>call planet#integrations#XDisplay('stop')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).--3-- <Nop>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 0<Tab>$DISPLAY=:80  <Cmd>call planet#integrations#XDisplay('set', ':80')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 1<Tab>$DISPLAY=:81  <Cmd>call planet#integrations#XDisplay('set', ':81')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 2<Tab>$DISPLAY=:82  <Cmd>call planet#integrations#XDisplay('set', ':82')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 3<Tab>$DISPLAY=:83  <Cmd>call planet#integrations#XDisplay('set', ':83')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 4<Tab>$DISPLAY=:84  <Cmd>call planet#integrations#XDisplay('set', ':84')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 5<Tab>$DISPLAY=:85  <Cmd>call planet#integrations#XDisplay('set', ':85')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 6<Tab>$DISPLAY=:86  <Cmd>call planet#integrations#XDisplay('set', ':86')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 7<Tab>$DISPLAY=:87  <Cmd>call planet#integrations#XDisplay('set', ':87')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 8<Tab>$DISPLAY=:88  <Cmd>call planet#integrations#XDisplay('set', ':88')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 9<Tab>$DISPLAY=:89  <Cmd>call planet#integrations#XDisplay('set', ':89')<CR>
    an 500.10  📐&}.Virtual\ Display\ (Xvfb).Specify\ Custom\ $DISPLAY  <Cmd>call planet#integrations#XDisplay('set')<CR>
    an 500.10  📐&}.Vue\ CLI.Start                          <Cmd>call planet#integrations#Command(['npm', 'run', 'serve'])<CR>
    an 500.10  📐&}.Vue\ CLI.Build                          <Cmd>call planet#integrations#Command(['npm', 'run', 'build'])<CR>
    an 500.10  📐&}.Vue\ CLI.Lint                           <Cmd>call planet#integrations#Command(['npm', 'run', 'lint'])<CR>
    an 500.10  📐&}.Vue\ CLI.Add\ vue-router                <Cmd>call planet#integrations#Command(['npm', 'install', 'vue-router'])<CR>
    an 500.10  📐&}.Vue\ CLI.Add\ vuex                      <Cmd>call planet#integrations#Command(['npm', 'install', 'vuex'])<CR>
    an 500.10  📐&}.Vue\ CLI.Create\.\.\.                   <Cmd>call planet#integrations#Ask(['vue', 'create'], 'Name of new project: ', ['vue-app'])<CR>
    an 500.10  📐&}.Nuxt.Run\ Dev                           <Cmd>call planet#integrations#Command(['npm', 'run', 'dev'])<CR>
    an 500.10  📐&}.Nuxt.Build                              <Cmd>call planet#integrations#Command(['npm', 'run', 'build'])<CR>
    an 500.10  📐&}.Nuxt.Start                              <Cmd>call planet#integrations#Command(['npm', 'run', 'start'])<CR>
    an 500.10  📐&}.Nuxt.Generate                           <Cmd>call planet#integrations#Command(['npm', 'run', 'generate'])<CR>
    an 500.10  📐&}.Web\ Tools.Download\ URL  <Cmd>call planet#integrations#Run('download')<CR>
    an 500.10  📐&}.Vulkan.Compile\ Shader  <Cmd>call planet#integrations#Run('glslc')<CR>
    an 500.10  📐&}.Open\ GL.glxinfo                        <Cmd>call planet#integrations#Command(['glxinfo'])<CR>
    an 500.10  📐&}.Blender.Print\ Blender\ PYTHONPATH      <Cmd>call planet#integrations#Command(['blender', '--background', '--python-expr', 'import os,sys; print("PYTHONPATH=" + os.pathsep.join(sys.path))'])<CR>
    an 500.10  📐&}.Node.Run\ with\ node                    <Cmd>call planet#integrations#Command(['node', expand('%:p')])<CR>
    an 500.10  📐&}.Node.Start\ node\ REPL                  <Cmd>call planet#integrations#Command(['node'])<CR>
    an 500.10  📐&}.WebAssembly.Emscripten\ Install  <Cmd>call planet#integrations#Emsdk('install')<CR>
    an 500.10  📐&}.WebAssembly.Emscripten\ Activate  <Cmd>call planet#integrations#Emsdk('activate')<CR>
    an 500.10  📐&}.WebAssembly.Emscripten\ Update  <Cmd>call planet#integrations#Emsdk('update')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ version  <Cmd>call planet#integrations#Command(['emcc', '--version'])<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ html  <Cmd>call planet#integrations#Run('emcc-html')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ js  <Cmd>call planet#integrations#Run('emcc-js')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ wasm  <Cmd>call planet#integrations#Run('emcc-wasm')<CR>
    an 500.10  📐&}.WebAssembly.emcc\ compile\ bind  <Cmd>call planet#integrations#Run('emcc-bind')<CR>
    an 500.10  📐&}.WebAssembly.emrun\ file                 <Cmd>call planet#integrations#Command(['emrun', expand('%:p:r') .. '.html'])<CR>
    an 500.10  📐&}.WebAssembly.DisWebAssemble\ to\ js  <Cmd>call planet#integrations#Run('wasm2js')<CR>
    an 500.10  📐&}.WebAssembly.Configure                   <Cmd>call planet#integrations#Command(['emconfigure', './configure'])<CR>
    an 500.10  📐&}.WebAssembly.Cmake  <Cmd>call planet#integrations#Command(['emcmake', 'cmake', '-S', planet#run#Project().root, '-B', planet#run#Project().root .. '/build-wasm'])<CR>
    an 500.10  📐&}.WebAssembly.Emmake\ make                <Cmd>call planet#integrations#Command(['emmake', 'make'])<CR>
    an 500.10  📐&}.Python.JupyterLab                       <Cmd>call planet#integrations#Command(['jupyter-lab'])<CR>
    an 500.10  📐&}.Python.Jupyter\ Notebook                <Cmd>call planet#integrations#Command(['jupyter-notebook'])<CR>
    an 500.10  📐&}.i10n\ &&\ i18n <Nop>
    an disable 📐&}.i10n\ &&\ i18n
    an 500.10  📐&}.lupdate  <Cmd>call planet#integrations#Run('lupdate')<CR>
    an 500.10  📐&}.lrelease  <Cmd>call planet#integrations#Run('lrelease')<CR>
    an 500.10  📐&}.lconvert  <Cmd>call planet#integrations#Run('lconvert')<CR>
    an 500.10  📐&}.Qt\ Linguist  <Cmd>call planet#integrations#Run('linguist')<CR>
    an 500.10  📐&}.lprodump  <Cmd>call planet#integrations#Run('lprodump')<CR>
    an 500.10  📐&}.lrelease-pro  <Cmd>call planet#integrations#Run('lrelease-pro')<CR>
    an 500.10  📐&}.lupdate-pro  <Cmd>call planet#integrations#Run('lupdate-pro')<CR>
    an 500.10  📐&}.auto-translation  <Cmd>call planet#integrations#Run('auto-translation')<CR>
    an 500.10  📐&}.gettext  <Cmd>call planet#integrations#Run('gettext')<CR>
    an 500.10  📐&}.weblate\.org  <Cmd>call planet#gui#OpenUrl('https://hosted.weblate.org/')<CR>
    an 500.10  📐&}.Documentation <Nop>
    an disable 📐&}.Documentation
    an 500.10  📐&}.doxygen  <Cmd>call planet#integrations#Run('doxygen')<CR>
    an 500.10  📐&}.QDoc  <Cmd>call planet#integrations#Run('qdoc')<CR>
    an 500.10  📐&}.QHelp\ Generator  <Cmd>call planet#integrations#Run('qhelpgenerator')<CR>
    an 500.10  📐&}.readthedocs  <Cmd>call planet#integrations#Run('readthedocs')<CR>
    an 500.10  📐&}.gitbook  <Cmd>call planet#integrations#Run('gitbook')<CR>

    an 500.10  🔨&b.Build <Nop>
    an disable 🔨&b.Build
    an 500.10  🔨&b.&Autotools.Autotools\ Status            <Cmd>call planet#integrations#AutotoolsStatus()<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoconf                <Cmd>call planet#integrations#Command(['autoconf', '--force'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoreconf              <Cmd>call planet#integrations#Command(['autoreconf', '-f', '-i'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoheader              <Cmd>call planet#integrations#Command(['autoheader'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoscan                <Cmd>call planet#integrations#Command(['autoscan'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ autoupdate              <Cmd>call planet#integrations#Command(['autoupdate'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ ifnames                 <Cmd>call planet#integrations#Command(['ifnames'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ libtool                 <Cmd>call planet#integrations#Command(['libtool'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ libtoolize              <Cmd>call planet#integrations#Command(['libtoolize'])<CR>
    an 500.10  🔨&b.&Autotools.Generate\ \./autogen\.sh  <Cmd>call planet#integrations#Write('autogen')<CR>
    an 500.10  🔨&b.&Autotools.Generate\ \./configure\.ac   <Cmd>call planet#project#CopyFile('autotools/configure.ac')<CR>
    an 500.10  🔨&b.&Autotools.Run\ \./autogen\.sh          <Cmd>call planet#integrations#Command(['./autogen.sh'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ \./bootstrap\.sh        <Cmd>call planet#integrations#Command(['./bootstrap.sh'])<CR>
    an 500.10  🔨&b.&Autotools.Run\ \./&configure           <Cmd>call planet#integrations#Configure()<CR>
    an 500.10  🔨&b.&Autotools.Rerun\ \./&configure         <Cmd>call planet#term#RunCmdFind('config.status', '--recheck')<CR>
    an 500.10  🔨&b.&Autotools.Set\ \./configure\ Options  <Cmd>call planet#integrations#ConfigureOptions()<CR>
    an 500.10  🔨&b.&Autotools.Open\ config\.log            <Cmd>find config.log<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CC                     <Cmd>call planet#env#SetEnvVar("CC")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CFLAGS                 <Cmd>call planet#env#SetEnvVar("CFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CXX                    <Cmd>call planet#env#SetEnvVar("CXX")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CXXFLAGS               <Cmd>call planet#env#SetEnvVar("CXXFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $LDFLAGS                <Cmd>call planet#env#SetEnvVar("LDFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $CPPFLAGS               <Cmd>call planet#env#SetEnvVar("CPPFLAGS")<CR>
    an 500.10  🔨&b.&Autotools.Set\ $DESTDIR                <Cmd>call planet#env#SetEnvVar("DESTDIR")<CR>
    an 500.10  🔨&b.Mak&e.&Make                             <Cmd>call planet#integrations#Command(['make'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ &All                        <Cmd>call planet#integrations#Command(['make', 'all'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Help                       <Cmd>call planet#integrations#Command(['make', 'help'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Clean                      <Cmd>call planet#integrations#Command(['make', 'clean'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ Distclea&n                  <Cmd>call planet#integrations#Command(['make', 'distclean'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Dist                       <Cmd>call planet#integrations#Command(['make', 'dist'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ Di&stcheck                  <Cmd>call planet#integrations#Command(['make', 'distcheck'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ Chec&k                      <Cmd>call planet#integrations#Command(['make', 'check'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Test                       <Cmd>call planet#integrations#Command(['make', 'test'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Install                    <Cmd>call planet#integrations#Command(['make', 'install'])<CR>
    an 500.10  🔨&b.Mak&e.Make\ &Uninstall                  <Cmd>call planet#integrations#Command(['make', 'uninstall'])<CR>
    an 500.10  🔨&b.Mak&e.Set\ $MAKEFLAGS                   <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    an 500.10  🔨&b.&KBuild.make\ &oldconfig                <Cmd>call planet#term#RunCmd("yes '' \| make oldconfig")<CR>
    an 500.10  🔨&b.&KBuild.make\ &menuconfig               <Cmd>call planet#term#RunCmdTab(['make', 'menuconfig'])<CR>
    an 500.10  🔨&b.&KBuild.ma&ke                           <Cmd>call planet#integrations#Command(['make'])<CR>
    an 500.10  🔨&b.&KBuild.ma&ke\ Target\.\.\.             <Cmd>call planet#integrations#Ask(['make'], 'Target: ', [])<CR>
    an 500.10  🔨&b.&KBuild.&Edit\ \.config                 <Cmd>e .config<CR>
    an 500.10  🔨&b.&KBuild.&Edit\ $MAKEFLAGS               <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    an 500.10  🔨&b.&KBuild.make\ c&lean                    <Cmd>call planet#integrations#Command(['make', 'clean'])<CR>
    an 500.10  🔨&b.&KBuild.make\ mr&proper                 <Cmd>call planet#integrations#Command(['make', 'mrproper'])<CR>
    an 500.10  🔨&b.&KBuild.make\ dis&tclean                <Cmd>call planet#integrations#Command(['make', 'distclean'])<CR>
    an 500.10  🔨&b.&KBuild.make\ &help                     <Cmd>call planet#integrations#Command(['make', 'help'])<CR>
    an 500.10  🔨&b.&KBuild.make\ &config                   <Cmd>call planet#integrations#Command(['make', 'config'])<CR>
    an 500.10  🔨&b.&KBuild.make\ allyesconfig              <Cmd>call planet#integrations#Command(['make', 'allyesconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ allnoconfig               <Cmd>call planet#integrations#Command(['make', 'allnoconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ defconfig                 <Cmd>call planet#integrations#Command(['make', 'defconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ install                   <Cmd>call planet#integrations#Command(['make', 'install'])<CR>
    an 500.10  🔨&b.&KBuild.make\ uninstall                 <Cmd>call planet#integrations#Command(['make', 'uninstall'])<CR>
    an 500.10  🔨&b.&KBuild.make\ randconfig                <Cmd>call planet#integrations#Command(['make', 'randconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ allmodconfig              <Cmd>call planet#integrations#Command(['make', 'allmodconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ &nconfig                  <Cmd>call planet#integrations#Command(['make', 'nconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ &xconfig                  <Cmd>call planet#integrations#Command(['make', 'xconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ &gconfig                  <Cmd>call planet#integrations#Command(['make', 'gconfig'])<CR>
    an 500.10  🔨&b.&KBuild.make\ &tags                     <Cmd>call planet#integrations#Command(['make', 'tags'])<CR>
    an 500.10  🔨&b.&CMake.Select\ Build\ Dir               <Cmd>call planet#build#SelectBuildDir()<CR>
    an 500.10  🔨&b.&CMake.Create\ &In-Tree\ Build\ Dir     <Cmd>call planet#build#NewInTreeBuildDir()<CR>
    an 500.10  🔨&b.&CMake.Create\ &OOT\ Build\ Dir         <Cmd>call planet#build#NewOOTBuildDir()<CR>
    an 500.10  🔨&b.&CMake.Browse\ Build\ Directory         <Cmd>call planet#build#Browse()<CR>
    an 500.10  🔨&b.&CMake.--1-- <Nop>
    an 500.10  🔨&b.&CMake.&Configure                       <Cmd>call planet#integrations#CmakeConfigure()<CR>
    an 500.10  🔨&b.&CMake.Configure\ &Tui                  <Cmd>call planet#build#ConfigureTui()<CR>
    an 500.10  🔨&b.&CMake.Configure\ &Gui                  <Cmd>call planet#build#ConfigureGui()<CR>
    an 500.10  🔨&b.&CMake.Configure\ Android\ armv7        <Cmd>call planet#integrations#AndroidCmake('armeabi-v7a')<CR>
    an 500.10  🔨&b.&CMake.Configure\ Android\ x86          <Cmd>call planet#integrations#AndroidCmake('x86')<CR>
    an 500.10  🔨&b.&CMake.--2-- <Nop>
    an 500.10  🔨&b.&CMake.&Build                           <Cmd>call planet#build#Build()<CR>
    an 500.10  🔨&b.&CMake.&Rebuild                         <Cmd>call planet#build#Rebuild()<CR>
    an 500.10  🔨&b.&CMake.Clean                            <Cmd>call planet#build#Build('clean')<CR>
    an 500.10  🔨&b.&CMake.--3-- <Nop>
    an 500.10  🔨&b.&CMake.Generate\ compile_commands\.json <Cmd>call planet#integrations#CmakeConfigure(v:true)<CR>
    an 500.10  🔨&b.&Meson.Set\ DESTDIR  <Cmd>call planet#integrations#Set('DESTDIR')<CR>
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
    an 500.10  🔨&b.Ar&duino.Set\ Arduino\ Dir  <Cmd>call planet#integrations#Set('arduino_dir', v:null, v:true)<CR>
    an 500.10  🔨&b.Ar&duino.Set\ Build\ Dir  <Cmd>call planet#integrations#Set('arduino_build_path', v:null, v:true)<CR>
    an 500.10  🔨&b.Ar&duino.Use\ Arduino\ IDE               <Cmd>let g:arduino_use_cli = 0<CR>
    an 500.10  🔨&b.Ar&duino.Use\ arduino-cli                <Cmd>let g:arduino_use_cli = 1<CR>
    an 500.10  🔨&b.&PlatformIO.&Build                       <Cmd>call planet#integrations#Command(['pio', 'run'])<CR>
    an 500.10  🔨&b.&PlatformIO.&Upload                      <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'upload'])<CR>
    an 500.10  🔨&b.&PlatformIO.Serial\ &Monitor             <Cmd>call planet#integrations#Command(['pio', 'device', 'monitor'])<CR>
    an 500.10  🔨&b.&PlatformIO.Serial\ &Monitor\ in\ Tab    <Cmd>call planet#term#RunCmdTab(['pio', 'device', 'monitor'])<CR>
    an 500.10  🔨&b.&PlatformIO.Build\ FS\ &Image            <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'buildfs'])<CR>
    an 500.10  🔨&b.&PlatformIO.Upload\ &FS\ Image           <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'uploadfs'])<CR>
    an 500.10  🔨&b.&PlatformIO.Me&nuconfig                  <Cmd>call planet#term#RunCmdTab(['pio', 'run', '-t', 'menuconfig'])<CR>
    an 500.10  🔨&b.&PlatformIO.&Clean                       <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'clean'])<CR>
    an 500.10  🔨&b.&PlatformIO.&Generate\ Compilation\ Database  <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'compiledb'])<CR>
    an 500.10  🔨&b.&PlatformIO.&Activate  <Cmd>call planet#integrations#Environment('platformio')<CR>
    an 500.10  🔨&b.&PlatformIO.&Web\ UI                     <Cmd>call planet#integrations#Command(['pio', 'home'])<CR>
    an 500.10  🔨&b.&PlatformIO.Up&date\ Packages            <Cmd>call planet#integrations#Command(['pio', 'update'])<CR>
    an 500.10  🔨&b.&PlatformIO.Upg&rade\ PlatformIO         <Cmd>call planet#integrations#Command(['pio', 'upgrade'])<CR>
    an 500.10  🔨&b.&ROS.Build\ Workspace  <Cmd>call planet#integrations#Run('ros-build')<CR>
    an 500.10  🔨&b.&ROS.roslaunch  <Cmd>call planet#integrations#Run('roslaunch')<CR>
    an 500.10  🔨&b.&ROS.rosrun  <Cmd>call planet#integrations#Run('rosrun')<CR>
    an 500.10  🔨&b.&ROS.Install\ Container.Kinetic  <Cmd>call planet#integrations#Run('ros-install-kinetic')<CR>
    an 500.10  🔨&b.&ROS.Install\ Container.Melodic  <Cmd>call planet#integrations#Run('ros-install-melodic')<CR>
    an 500.10  🔨&b.&ROS.Install\ Container.Noetic  <Cmd>call planet#integrations#Run('ros-install-noetic')<CR>
    an 500.10  🔨&b.&ROS\ 2.Setup  <Cmd>call planet#integrations#Environment('ros2')<CR>
    an 500.10  🔨&b.&Yocto.Setup  <Cmd>call planet#integrations#Environment('yocto')<CR>
    an 500.10  🔨&b.&Flutter.Doctor                          <Cmd>call planet#integrations#Command(['flutter', 'doctor'])<CR>
    an 500.10  🔨&b.&Flutter.Set\ Android\ Sdk\ Location  <Cmd>call planet#integrations#Flutter('sdk')<CR>
    an 500.10  🔨&b.&Flutter.Accept\ Android\ Licenses       <Cmd>call planet#integrations#Command(['flutter', 'doctor', '--android-licenses'])<CR>
    an 500.10  🔨&b.&Flutter.Create\ Project  <Cmd>call planet#integrations#Flutter('create')<CR>
    an 500.10  🔨&b.&Flutter.Run                             <Cmd>FlutterRun<CR>
    an 500.10  🔨&b.&Flutter.Hot\ Reload                     <Cmd>FlutterHotReload<CR>
    an 500.10  🔨&b.&Flutter.Hot\ Restart                    <Cmd>FlutterHotRestart<CR>
    an 500.10  🔨&b.&Flutter.Stop\ App                       <Cmd>FlutterQuit<CR>
    an 500.10  🔨&b.&Flutter.Devices                         <Cmd>FlutterDevices<CR>
    an 500.10  🔨&b.&Flutter.Output                          <Cmd>FlutterSplit<CR>
    an 500.10  🔨&b.&Flutter.Emulators                       <Cmd>FlutterEmulators<CR>
    an 500.10  🔨&b.&Flutter.Launch\ Emulators               <Cmd>FlutterEmulatorsLaunch<CR>
    an 500.10  🔨&b.&Flutter.Toggle\ Visual\ Debug           <Cmd>FlutterVisualDebug<CR>
    an 500.10  🔨&b.&Flutter.Add\ Desktop\ Linux\ Build      <Cmd>call planet#integrations#Command(['flutter', 'config', '--enable-linux-desktop'])<CR>
    an 500.10  🔨&b.&Flutter.Add\ Desktop\ Windows\ Build    <Cmd>call planet#integrations#Command(['flutter', 'config', '--enable-windows-desktop'])<CR>
    an 500.10  🔨&b.Elec&tron.List\ Project\ Deps            <Cmd>call planet#integrations#Command(['npm', 'list', '--depth=0'])<CR>
    an 500.10  🔨&b.Elec&tron.--1-- <Nop>
    an 500.10  🔨&b.Elec&tron.Run\ App                       <Cmd>call planet#integrations#Command(['electron', '.'])<CR>
    an 500.10  🔨&b.Elec&tron.Run\ with\ npm                 <Cmd>call planet#integrations#Command(['npm', 'start'])<CR>
    an 500.10  🔨&b.Elec&tron.Run\ with\ auto\ reload        <Cmd>call planet#integrations#Command(['nodemon', '--exec', 'electron', '.'])<CR>
    an 500.10  🔨&b.Elec&tron.Npm\ run\ with\ auto\ reload   <Cmd>call planet#integrations#Command(['npm', 'run', 'watch'])<CR>
    an 500.10  🔨&b.Elec&tron.--2-- <Nop>
    an 500.10  🔨&b.Elec&tron.Start\ Debug                   <Cmd>call planet#integrations#Command(['electron', '--inspect=5858', '.'])<CR>
    an 500.10  🔨&b.Elec&tron.Break\ on\ Start               <Cmd>call planet#integrations#Command(['electron', '--inspect-brk=5858', '.'])<CR>
    an 500.10  🔨&b.Elec&tron.--3-- <Nop>
    an 500.10  🔨&b.Elec&tron.Rebuild\ Native\ Package\.\.\. <Cmd>call planet#integrations#Ask(['electron-rebuild'], 'Package name: ', [])<CR>
    an 500.10  🔨&b.Elec&tron.--4-- <Nop>
    an 500.10  🔨&b.Elec&tron.Build\ Linux\ AppImage         <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'AppImage'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Linux\ snap             <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'snap'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Linux\ deb              <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'deb'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Linux\ tar\.gz          <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'tar.gz'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Linux\ apk              <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'apk'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Windows\ self-signed-cert <Cmd>call planet#integrations#Command(['electron-builder', 'create-self-signed-cert'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Windows\ nsis           <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'nsis'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Windows\ Portable\ App  <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'portable'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Windows\ Appx           <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'appx'])<CR>
    an 500.10  🔨&b.Elec&tron.Build\ Windows\ zip            <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'zip'])<CR>
    an 500.10  🔨&b.Elec&tron.--5-- <Nop>
    an 500.10  🔨&b.Elec&tron.Install\ as\ Local\ Dep        <Cmd>call planet#integrations#Command(['npm', 'i', '-D', 'electron@latest'])<CR>
    an 500.10  🔨&b.Elec&tron.Install\ Project\ Deps         <Cmd>call planet#integrations#Command(['npm', 'i'])<CR>
    an 500.10  🔨&b.Elec&tron.Add\ electron-builder          <Cmd>call planet#integrations#Command(['npm', 'i', '-D', 'electron-builder'])<CR>
    an 500.10  🔨&b.Elec&tron.Add\ electron-updater          <Cmd>call planet#integrations#Command(['npm', 'i', 'electron-updater'])<CR>
    an 500.10  🔨&b.Elec&tron.Install\ electron-rebuild      <Cmd>call planet#integrations#Command(['npm', 'install', '-g', 'electron-rebuild'])<CR>
    an 500.10  🔨&b.Elec&tron.Install\ electron-builder      <Cmd>call planet#integrations#Command(['npm', 'install', '-g', 'electron-builder'])<CR>
    an 500.10  🔨&b.&Other.&Ninja.Set\ DESTDIR  <Cmd>call planet#integrations#Set('DESTDIR')<CR>
    an 500.10  🔨&b.&Other.&QMake.Set\ DESTDIR  <Cmd>call planet#integrations#QmakeDestdir()<CR>
    an 500.10  🔨&b.&Other.&Scons.Run\ Target\.\.\.          <Cmd>call planet#integrations#Ask(['scons'], 'scons: ', ['-j8', '.'])<CR>
    an 500.10  🔨&b.Deploy <Nop>
    an disable 🔨&b.Deploy
    an 500.10  🔨&b.Windeployqt.Deploy  <Cmd>call planet#integrations#Run('windeployqt')<CR>
    an 500.10  🔨&b.Linuxdeploy.Deploy  <Cmd>call planet#integrations#Run('linuxdeploy')<CR>
    an 500.10  🔨&b.Androiddeployqt.Deploy  <Cmd>call planet#integrations#Run('androiddeployqt')<CR>
    an 500.10  🔨&b.Package <Nop>
    an disable 🔨&b.Package
    an 500.10  🔨&b.fpm.Build  <Cmd>call planet#integrations#Run('fpm')<CR>
    an 500.10  🔨&b.PyInstaller.Build\ app\.spec             <Cmd>call planet#integrations#Command(['pyinstaller', 'app.spec'])<CR>
    an 500.10  🔨&b.PyInstaller.Basic\ Build\ app\.py        <Cmd>call planet#integrations#Command(['pyinstaller', '--windowed', 'app.py'])<CR>
    an 500.10  🔨&b.PyInstaller.Install                      <Cmd>call planet#integrations#Command(['pip', 'install', 'PyInstaller', 'pyinstaller-hooks-contrib'])<CR>
    an 500.10  🔨&b.PyInstaller.Update\ PyInstaller          <Cmd>call planet#integrations#Command(['pip', 'install', '--upgrade', 'PyInstaller', 'pyinstaller-hooks-contrib'])<CR>
    an 500.10  🔨&b.CPack.Build  <Cmd>call planet#integrations#Run('cpack')<CR>
    an 500.10  🔨&b.AppImage.Build  <Cmd>call planet#integrations#Run('appimage')<CR>
    an 500.10  🔨&b.Snap.Build  <Cmd>call planet#integrations#Run('snap')<CR>
    an 500.10  🔨&b.FlatPak.Build  <Cmd>call planet#integrations#Run('flatpak')<CR>
    an 500.10  🔨&b.pyUpdater.Build  <Cmd>call planet#integrations#Run('pyupdater')<CR>
    an 500.10  🔨&b.Installer <Nop>
    an disable 🔨&b.Installer
    an 500.10  🔨&b.Qt\ Installer\ Framework.Build  <Cmd>call planet#integrations#Run('qt-installer')<CR>

    " Run
    an 510.10  ▶️&r.Run <Nop>
    an disable ▶️&r.Run
    an 510.500 ▶️&r.--1-- <Nop>
    an 510.500 ▶️&r.Add\ Run\ Configuration                 <Cmd>call planet#run#AddConfig()<CR>
    an 510.500 ▶️&r.Edit\ Run\ Configurations               <Cmd>call planet#run#EditConfig()<CR>

    " Debug
    an 520.10  🐞&d.Debug <Nop>
    an disable 🐞&d.Debug
    an 520.10  🐞&d.Start\ &Debug  <Cmd>PlanetDebug launch<CR>
    an 520.10  🐞&d.Detach\ Debugger  <Cmd>PlanetDebug detach<CR>
    an 520.10  🐞&d.Stop\ &Debug  <Cmd>PlanetDebug stop<CR>
    an 520.10  🐞&d.--1-- <Nop>
    an 520.10  🐞&d.Setup\ GDB  <Cmd>PlanetDebugSetup cpp<CR>
    an 520.10  🐞&d.Setup\ GDB\ Dashboard  <Cmd>call planet#debugtools#Run('gdb-dashboard')<CR>
    an 520.10  🐞&d.Setup\ GDB\ for\ Unreal  <Cmd>call planet#debugtools#Run('gdb-unreal')<CR>
    an 520.10  🐞&d.Setup\ GDB\ Pretty\ Printers  <Cmd>call planet#debugtools#Run('gdb-pretty-printers')<CR>
    an 520.10  🐞&d.Setup\ LLDB  <Cmd>call planet#debugtools#Run('lldb')<CR>
    an 520.10  🐞&d.Setup\ rr  <Cmd>call planet#debugtools#Run('rr')<CR>
    an 520.10  🐞&d.Setup\ LiveRecorder  <Cmd>call planet#debugtools#Run('live-recorder')<CR>
    an 520.10  🐞&d.Setup\ radare2  <Cmd>call planet#debugtools#Run('radare2')<CR>
    an 520.10  🐞&d.Setup\ cutter  <Cmd>call planet#debugtools#Run('cutter')<CR>
    an 520.10  🐞&d.--1-- <Nop>
    an 520.10  🐞&d.Debug\ Kernel <Nop>
    an disable 🐞&d.Debug\ Kernel
    an 520.10  🐞&d.Setup\ GDB\ for\ Kernel  <Cmd>call planet#debugtools#Run('gdb-kernel-setup')<CR>
    an 520.10  🐞&d.gdb\ kernel  <Cmd>call planet#debugtools#Run('gdb-kernel')<CR>
    an 520.10  🐞&d.kgdb  <Cmd>call planet#debugtools#Run('kgdb')<CR>
    an 520.10  🐞&d.kdb  <Cmd>call planet#debugtools#Run('kdb')<CR>
    an 520.10  🐞&d.debugfs  <Cmd>call planet#debugtools#Run('debugfs')<CR>

    " Test
    an 530.10  🧪&j.Test <Nop>
    an disable 🧪&j.Test
    an 530.10  🧪&j.Nearest  <Cmd>PlanetTest nearest<CR>
    an 530.10  🧪&j.File  <Cmd>PlanetTest file<CR>
    an 530.10  🧪&j.Suite  <Cmd>PlanetTest suite<CR>
    an 530.10  🧪&j.Last  <Cmd>PlanetTest last<CR>
    an 530.10  🧪&j.Visit  <Cmd>PlanetTest visit<CR>
    an 530.10  🧪&j.Qt\ Test  <Cmd>call planet#testtools#Run('qt')<CR>
    an 530.10  🧪&j.Google\ Test  <Cmd>call planet#testtools#Run('google')<CR>
    an 530.10  🧪&j.Boost\ Test  <Cmd>call planet#testtools#Run('boost')<CR>
    an 530.10  🧪&j.Catch2\ Test  <Cmd>call planet#testtools#Run('catch2')<CR>
    an 530.10  🧪&j.CTest  <Cmd>call planet#testtools#Run('ctest')<CR>
    an 530.10  🧪&j.CDash  <Cmd>call planet#testtools#Run('cdash')<CR>
    an 530.10  🧪&j.Report\ Tools.Screenshot  <Cmd>call planet#testtools#Run('screenshot')<CR>
    an 530.10  🧪&j.Report\ Tools.Record\ gif  <Cmd>call planet#testtools#Run('record-gif')<CR>
    an 530.10  🧪&j.Report\ Tools.Record\ screen  <Cmd>call planet#testtools#Run('record-screen')<CR>
    an 530.10  🧪&j.Test\ Kernel <Nop>
    an disable 🧪&j.Test\ Kernel
    an 530.10  🧪&j.KUnit  <Cmd>call planet#testtools#Run('kunit')<CR>
    an 530.10  🧪&j.kselftest  <Cmd>call planet#testtools#Run('kselftest')<CR>

    " Analyze
    an 540.10  🔬&y.Analyze <Nop>
    an disable 🔬&y.Analyze
    an 540.10  🔬&y.Check  <Cmd>ALELint<CR>
    an 540.10  🔬&y.Clang-Tidy  <Cmd>call planet#integrations#Run('clang-tidy')<CR>
    an 540.10  🔬&y.Clazy  <Cmd>call planet#integrations#Run('clazy')<CR>
    an 540.10  🔬&y.Cppcheck  <Cmd>call planet#integrations#Run('cppcheck')<CR>
    an 540.10  🔬&y.Chrome\ Trace\ Format\ Visualizer  <Cmd>call planet#integrations#Trace()<CR>
    an 540.10  🔬&y.Performance\ Analyzer  <Cmd>call planet#integrations#Run('perf')<CR>
    an 540.10  🔬&y.Memcheck  <Cmd>call planet#integrations#Run('memcheck')<CR>
    an 540.10  🔬&y.Memcheck\ Gdb  <Cmd>call planet#integrations#Run('memcheck-gdb')<CR>
    an 540.10  🔬&y.Callgrind  <Cmd>call planet#integrations#Run('callgrind')<CR>
    an 540.10  🔬&y.QML\ Profiler  <Cmd>call planet#integrations#Run('qmlprofiler')<CR>
    an 540.10  🔬&y.ASAN  <Cmd>call planet#integrations#Run('asan')<CR>
    an 540.10  🔬&y.ThreadSanitizer  <Cmd>call planet#integrations#Run('tsan')<CR>
    an 540.10  🔬&y.LeakSanitizer  <Cmd>call planet#integrations#Run('lsan')<CR>
    an 540.10  🔬&y.UBSAN  <Cmd>call planet#integrations#Run('ubsan')<CR>
    an 540.10  🔬&y.Sanitizers  <Cmd>call planet#integrations#Run('sanitizers')<CR>
    an 540.10  🔬&y.Coverity  <Cmd>call planet#integrations#Run('coverity')<CR>
    an 540.10  🔬&y.ltrace  <Cmd>call planet#integrations#Run('ltrace')<CR>
    an 540.10  🔬&y.strace  <Cmd>call planet#integrations#Run('strace')<CR>
    an 540.10  🔬&y.ptrace  <Cmd>call planet#integrations#Run('ptrace')<CR>
    an 540.10  🔬&y.pstree\ $PID  <Cmd>call planet#integrations#Run('pstree')<CR>
    an 540.10  🔬&y.Open\ /proc/$PID\ Folder  <Cmd>call planet#integrations#Browse('/proc/PID')<CR>
    an 540.10  🔬&y.Analyze\ Kernel <Nop>
    an disable 🔬&y.Analyze\ Kernel
    an 540.10  🔬&y.Coccinelle  <Cmd>call planet#integrations#Run('coccinelle')<CR>
    an 540.10  🔬&y.Sparse  <Cmd>call planet#integrations#Run('sparse')<CR>
    an 540.10  🔬&y.kcov  <Cmd>call planet#integrations#Run('kcov')<CR>
    an 540.10  🔬&y.gcov\ with\ kernel  <Cmd>call planet#integrations#Run('gcov')<CR>
    an 540.10  🔬&y.KASAN  <Cmd>call planet#integrations#Run('kasan')<CR>
    an 540.10  🔬&y.KUBSAN  <Cmd>call planet#integrations#Run('kubsan')<CR>
    an 540.10  🔬&y.Kernel\ Memory\ Leak\ Detector  <Cmd>call planet#integrations#Run('kmemleak')<CR>
    an 540.10  🔬&y.KCSAN  <Cmd>call planet#integrations#Run('kcsan')<CR>
    an 540.10  🔬&y.Kernel\ Electric-Fence\ (KFENCE)  <Cmd>call planet#integrations#Run('kfence')<CR>
    an 540.10  🔬&y.ftrace  <Cmd>call planet#integrations#Run('ftrace')<CR>
    an 540.10  🔬&y.tracefs  <Cmd>call planet#integrations#Browse('/sys/kernel/tracing')<CR>

    " Terminal
    an 550.10  💻&c.Terminal <Nop>
    an disable 💻&c.Terminal
    an 550.10  💻&c.N&ew                                    <Cmd>botright terminal ++kill=kill ++rows=10<CR>
    an 550.10  💻&c.New\ &Here                              <Cmd>terminal ++curwin ++kill=kill<CR>
    an 550.10  💻&c.New\ &VSplit                            <Cmd>vertical terminal ++kill=kill<CR>
    an 550.10  💻&c.New\ &Tab                               <Cmd>tab terminal ++kill=kill<CR>
    an 550.10  💻&c.--1-- <Nop>
    an 550.10  💻&c.&Run\ Command\.\.\.                     <Cmd>call planet#term#RunCmdAsk('Command: ')<CR>
    an 550.10  💻&c.&Watch\ Command\.\.\.                   <Cmd>call planet#integrations#Ask(['watch', '-n0'], 'Command: ', [])<CR>
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
    silent! aunmenu 🔨&b
    silent! aunmenu ▶️&r
    silent! aunmenu 🐞&d
    silent! aunmenu 🧪&j
    silent! aunmenu 🔬&y
    silent! aunmenu 💻&c
  endif
endfunc
