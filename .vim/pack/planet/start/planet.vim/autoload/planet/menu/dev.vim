vim9script

export def Update(): number
  if planet#menu#Visible('dev')
    # LSP
    PlanetMenu an 300.10  ❇️&[.LSP <Nop>
    an disable ❇️&[.LSP
    PlanetMenu an 300.10  ❇️&[.Choose\ Symbol<Tab>:Clap\ tags\ vim_lsp :Clap tags vim_lsp<CR>
    PlanetMenu an 300.10  ❇️&[.--1-- <Nop>
    PlanetMenu an 300.10  ❇️&[.&Definition                             <Cmd>LspDefinition<CR>
    PlanetMenu an 300.10  ❇️&[.De&claration                            <Cmd>LspDeclaration<CR>
    PlanetMenu an 300.10  ❇️&[.&References                             <Cmd>LspReferences<CR>
    PlanetMenu an 300.10  ❇️&[.&Implementation                         <Cmd>LspImplementation<CR>
    PlanetMenu an 300.10  ❇️&[.&Type\ Definition                       <Cmd>LspTypeDefinition<CR>
    PlanetMenu an 300.10  ❇️&[.Type\ &Hierarchy                        <Cmd>LspTypeHierarchy<CR>
    PlanetMenu an 300.10  ❇️&[.&Incoming\ Call\ Hierarchy              <Cmd>LspCallHierarchyIncoming<CR>
    PlanetMenu an 300.10  ❇️&[.&Outgoing\ Call\ Hierarchy              <Cmd>LspCallHierarchyOutgoing<CR>
    PlanetMenu an 300.10  ❇️&[.Document\ Semantic\ Scopes              <Cmd>PlanetSemanticScopes<CR>
    PlanetMenu an 300.10  ❇️&[.--2-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Preview.Hover                           <Cmd>LspHover<CR>
    PlanetMenu an 300.10  ❇️&[.Preview.Hover\ in\ Popup                <Cmd>LspHover --ui=float<CR>
    PlanetMenu an 300.10  ❇️&[.Preview.Hover\ in\ Preview              <Cmd>LspHover --ui=preview<CR>
    PlanetMenu an 300.10  ❇️&[.Preview.Definition                      <Cmd>LspPeekDefinition<CR>
    PlanetMenu an 300.10  ❇️&[.Preview.Declaration                     <Cmd>LspPeekDeclaration<CR>
    PlanetMenu an 300.10  ❇️&[.Preview.Implementation                  <Cmd>LspPeekImplementation<CR>
    PlanetMenu an 300.10  ❇️&[.Preview.Type\ Definition                <Cmd>LspPeekTypeDefinition<CR>
    PlanetMenu an 300.10  ❇️&[.--3-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Rena&me                                 <Cmd>LspRename<CR>
    PlanetMenu an 300.10  ❇️&[.Code\ Action\ (LSP\ Quick\ &Fix)        <Cmd>LspCodeAction<CR>
    PlanetMenu an 300.10  ❇️&[.Code\ &Lens                             <Cmd>LspCodeLens<CR>
    PlanetMenu an 300.10  ❇️&[.Format\ Document                        <Cmd>LspDocumentFormat<CR>
    PlanetMenu an 300.10  ❇️&[.Format\ Document\ Selection             <Cmd>call planet#editing#FormatSelection()<CR>
    PlanetMenu an 300.10  ❇️&[.Update\ Document\ Folds                 <Cmd>LspDocumentFold<CR>
    PlanetMenu an 300.10  ❇️&[.--4-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Document\ Symbols                       <Cmd>LspDocumentSymbol<CR>
    PlanetMenu an 300.10  ❇️&[.Document\ Symbol\ Search                <Cmd>LspDocumentSymbolSearch<CR>
    PlanetMenu an 300.10  ❇️&[.Workspace\ Symbols                      <Cmd>LspWorkspaceSymbol<CR>
    PlanetMenu an 300.10  ❇️&[.Workspace\ Symbol\ Search               <Cmd>LspWorkspaceSymbolSearch<CR>
    PlanetMenu an 300.10  ❇️&[.--5-- <Nop>
    PlanetMenu an 300.10  ❇️&[.&Previous\ Reference                    <Cmd>LspPreviousReference<CR>
    PlanetMenu an 300.10  ❇️&[.&Next\ Reference                        <Cmd>LspNextReference<CR>
    PlanetMenu an 300.10  ❇️&[.--6-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Document\ Diagnostics                   <Cmd>LspDocumentDiagnostics<CR>
    PlanetMenu an 300.10  ❇️&[.Diagnostics\ (all\ buffers)             <Cmd>LspDocumentDiagnostics --buffers=*<CR>
    PlanetMenu an 300.10  ❇️&[.--7-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Previous\ Error                         <Cmd>LspPreviousError -wrap=0<CR>
    PlanetMenu an 300.10  ❇️&[.Next\ Error                             <Cmd>LspNextError -wrap=0<CR>
    PlanetMenu an 300.10  ❇️&[.--8-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Previous\ Warning                       <Cmd>LspPreviousWarning -wrap=0<CR>
    PlanetMenu an 300.10  ❇️&[.Next\ Warning                           <Cmd>LspNextWarning -wrap=0<CR>
    PlanetMenu an 300.10  ❇️&[.--9-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Previous\ Diagnostic                    <Cmd>LspPreviousDiagnostic -wrap=0<CR>
    PlanetMenu an 300.10  ❇️&[.Next\ Diagnostic                        <Cmd>LspNextDiagnostic -wrap=0<CR>
    PlanetMenu an 300.10  ❇️&[.--10-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Status.LSP\ Status                      <Cmd>LspStatus<CR>
    PlanetMenu an 300.10  ❇️&[.Status.--1-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Status.Restart\ LSP                     <Cmd>call lsp#disable()<CR><Cmd>call lsp#enable()<CR>
    PlanetMenu an 300.10  ❇️&[.Status.Enable\ LSP                      <Cmd>call lsp#enable()<CR>
    PlanetMenu an 300.10  ❇️&[.Status.Disable\ LSP                     <Cmd>call lsp#disable()<CR>
    PlanetMenu an 300.10  ❇️&[.Status.Stop\ Server                     <Cmd>LspStopServer<CR>
    PlanetMenu an 300.10  ❇️&[.Status.--2-- <Nop>
    PlanetMenu an 300.10  ❇️&[.Status.Enable\ Diagnostics              <Cmd>call lsp#enable_diagnostics_for_buffer()<CR>
    PlanetMenu an 300.10  ❇️&[.Status.Disable\ Diagnostics             <Cmd>call lsp#disable_diagnostics_for_buffer()<CR>

    # Tags
    PlanetMenu an 310.10  🪧&].Tags <Nop>
    an disable 🪧&].Tags
    PlanetMenu an 310.10  🪧&].C&hoose<Tab>:Clap\ tags\ ctags          <Cmd>Clap tags ctags<CR>
    PlanetMenu an 310.10  🪧&].&Jump\ to\ Tag<Tab><C-]>                <C-]>
    PlanetMenu an 310.10  🪧&].&Jump\ Back<Tab><C-t>                   <C-t>
    PlanetMenu an 310.10  🪧&].&Jump\ or\ Select\ Tag<Tab>g<C-]>       g<C-]>
    PlanetMenu an 310.10  🪧&].&Select\ Tag<Tab>g]                     g]
    PlanetMenu an 310.10  🪧&].Jump\ Split\ to\ Tag<Tab>+]             <C-w>]
    PlanetMenu an 310.10  🪧&].Jump\ or\ Select\ Split\ to\ Tag<Tab>+g<C-]> <C-w>g<C-]>
    PlanetMenu an 310.10  🪧&].Select\ Split\ Tag<Tab>+g]              <C-w>g]
    PlanetMenu an 310.10  🪧&].Go\ to\ Tag\ VSplit<Tab>:vert\ stag     <Cmd>vert stag <cword><CR>
    PlanetMenu an 310.10  🪧&].--1-- <Nop>
    PlanetMenu an 310.10  🪧&].Preview\ Tag<Tab>+}                     <C-w>}
    PlanetMenu an 310.10  🪧&].Select\ Preview\ Tag<Tab>+g}            <C-w>g}
    PlanetMenu an 310.10  🪧&].Preview\ Previous\ Tag<Tab>:ppop        <Cmd>ppop<CR>
    PlanetMenu an 310.10  🪧&].Close\ Preview<Tab>+z                   <C-w>z
    PlanetMenu an 310.10  🪧&].--2-- <Nop>
    PlanetMenu an 310.10  🪧&].Preview\ File<Tab>:pedit                :pedit<Space>
    PlanetMenu an 310.10  🪧&].Preview\ Search<Tab>:psearch            :psearch<Space>
    PlanetMenu an 310.10  🪧&].--2-- <Nop>
    PlanetMenu am 310.10  🪧&].First<Tab>[T                            [T
    PlanetMenu am 310.10  🪧&].Previous<Tab>[t                         [t
    PlanetMenu am 310.10  🪧&].Next<Tab>]t                             ]t
    PlanetMenu am 310.10  🪧&].Last<Tab>]T                             ]T
    PlanetMenu an 310.10  🪧&].--3-- <Nop>
    PlanetMenu am 310.10  🪧&].Preview\ Previous<Tab>[<C-t>            [<C-t>
    PlanetMenu am 310.10  🪧&].Preview\ Next<Tab>]<C-t>                ]<C-t>
    PlanetMenu an 310.10  🪧&].--4-- <Nop>
    PlanetMenu am 310.10  🪧&].Toggle\ AutoPreview\ Tags               <Cmd>call planet#tags#ToggleAutoPreview()<CR>
    PlanetMenu an 310.10  🪧&].--5-- <Nop>
    PlanetMenu am 310.10  🪧&].Build\ tags\ File                       <Cmd>call planet#integrations#Command(['ctags', '-R', '.'])<CR>
    PlanetMenu am 310.10  🪧&].Generate\ tags\.vim\ File  <Cmd>call planet#integrations#Tags('tags')<CR>
    PlanetMenu am 310.10  🪧&].Highlight\ tags\ from\ tags\.vim        <Cmd>so tags.vim<CR>
    PlanetMenu am 310.10  🪧&].Generate\ types\.vim\ File  <Cmd>call planet#integrations#Tags('types')<CR>
    PlanetMenu am 310.10  🪧&].Highlight\ tags\ from\ types\.vim       <Cmd>so types.vim<CR>

    PlanetMenu an 500.10  🎚️&{.Virtual\ Environments <Nop>
    an disable 🎚️&{.Virtual\ Environments
    PlanetMenu an 500.10  🎚️&{.&Docker.CLI\ UI\ (lazydocker)           <Cmd>call planet#term#RunCmdTab(['lazydocker'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Docker.--1-- <Nop>
    PlanetMenu an 500.10  🎚️&{.&Docker.List\ Running\ Containers       <Cmd>call planet#integrations#Command(['docker', 'container', 'ls'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Docker.List\ All\ Containers           <Cmd>call planet#integrations#Command(['docker', 'container', 'ls', '-a'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Docker.--2-- <Nop>
    PlanetMenu an 500.10  🎚️&{.&Docker.List\ Images                    <Cmd>call planet#integrations#Command(['docker', 'image', 'ls'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Start\ Shell                    <Cmd>call planet#integrations#Command(['pipenv', 'shell'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Run\ python\ main\.py           <Cmd>call planet#integrations#Command(['pipenv', 'run', 'python', './main.py'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Run\ python\ app\.py            <Cmd>call planet#integrations#Command(['pipenv', 'run', 'python', './app.py'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Run\ Command\.\.\.              <Cmd>call planet#integrations#Ask(['pipenv', 'run'], 'Command: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Update\ Pipfile\.lock           <Cmd>call planet#integrations#Command(['pipenv', 'lock'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.--1-- <Nop>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.New\ Project                    <Cmd>call planet#integrations#Command(['pipenv', '--python', '3'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.New\ Project\ with\ Python      <Cmd>call planet#integrations#Ask(['pipenv', '--python'], 'Python Version: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Install\ Run\ &&\ Dev\ Deps     <Cmd>call planet#integrations#Command(['pipenv', 'install', '--dev'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Install\ Run\ Deps              <Cmd>call planet#integrations#Command(['pipenv', 'install'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Install\ Packages\.\.\.         <Cmd>call planet#integrations#Ask(['pipenv', 'install'], 'Packages: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Install\ Dev\ Packages\.\.\.    <Cmd>call planet#integrations#Ask(['pipenv', 'install', '--dev'], 'Packages: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Update\ (Lock\ &&\ Sync)        <Cmd>call planet#integrations#Command(['pipenv', 'update'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Sync\ with\ Pipfile\.lock       <Cmd>call planet#integrations#Command(['pipenv', 'sync'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.--2-- <Nop>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Uninstall\ Extra\ Packages      <Cmd>call planet#integrations#Command(['pipenv', 'clean'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Uninstall\ Packages\.\.\.       <Cmd>call planet#integrations#Ask(['pipenv', 'uninstall'], 'Packages: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Uninstall\ Dev\ Packages        <Cmd>call planet#integrations#Command(['pipenv', 'uninstall', '--all-dev'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Uninstall\ All                  <Cmd>call planet#integrations#Command(['pipenv', 'uninstall', '--all'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Remove\ Project's\ VEnv         <Cmd>call planet#integrations#Command(['pipenv', '--rm'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install      <Cmd>call planet#integrations#Command(['pipenv', 'install', '-r', 'requirements.txt'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Install\ Dev <Cmd>call planet#integrations#Command(['pipenv', 'install', '-r', 'dev-requirements.txt', '--dev'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export  <Cmd>call planet#integrations#ExportRequirements()<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.requirements\.t&xt.Export\ Dev  <Cmd>call planet#integrations#ExportRequirements(v:true)<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.--3-- <Nop>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Open\ Module\.\.\.              <Cmd>call planet#integrations#Ask(['pipenv', 'open'], 'Module: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Security\ Check                 <Cmd>call planet#integrations#Command(['pipenv', 'check'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Dependency\ Graph               <Cmd>call planet#integrations#Command(['pipenv', 'graph'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Reverse\ Dependency\ Graph      <Cmd>call planet#integrations#Command(['pipenv', 'graph', '--reverse'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Enable\ Site\ Packages          <Cmd>call planet#integrations#Command(['pipenv', '--site-packages'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Disable\ Site\ Packages         <Cmd>call planet#integrations#Command(['pipenv', '--no-site-packages'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Print\ Project\ Root            <Cmd>call planet#integrations#Command(['pipenv', '--where'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Print\ VEnv\ Dir                <Cmd>call planet#integrations#Command(['pipenv', '--venv'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Print\ Env\ Vars                <Cmd>call planet#integrations#Command(['pipenv', '--envs'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Edit\ \.env                     <Cmd>e .env<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Print\ Version                  <Cmd>call planet#integrations#Command(['pipenv', '--version'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Clear\ Caches                   <Cmd>call planet#integrations#Command(['pipenv', '--clear'])<CR>
    PlanetMenu an 500.10  🎚️&{.&Pipenv.Install\ Pipenv                 <Cmd>call planet#integrations#Command(['pip', 'install', '--user', 'pipenv'])<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Activate\.\.\.  <Cmd>call planet#integrations#Conda()<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Install\ from\ requirements\.txt <Cmd>call planet#integrations#Command(['conda', 'install', '--file', 'requirements.txt'])<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Create\ from\ environment\.yml   <Cmd>call planet#integrations#Command(['conda', 'env', 'create', '-f', 'environment.yml'])<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Deactivate  <Cmd>call planet#integrations#RestoreEnvironment()<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Create\ New\ Environment\.\.\.   <Cmd>call planet#integrations#Ask(['conda', 'create', '--name'], 'Name: ', ['conda'])<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Activate\ Anaconda  <Cmd>call planet#integrations#Conda('base')<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Deactivate\ Anaconda  <Cmd>call planet#integrations#RestoreEnvironment()<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Conda\ Init  <Cmd>call planet#integrations#Command(['conda', 'init'])<CR>
    PlanetMenu an 500.10  🎚️&{.C&onda.Conda\ Info                      <Cmd>call planet#integrations#Command(['conda', 'info'])<CR>
    PlanetMenu an 500.10  🎚️&{.Android.Download\ System\ Image  <Cmd>call planet#integrations#Run('sdk-image')<CR>
    PlanetMenu an 500.10  🎚️&{.Android.Create\ AVD  <Cmd>call planet#integrations#Run('sdk-avd')<CR>
    PlanetMenu an 500.10  🎚️&{.Vagrant.Test  <Cmd>call planet#integrations#Run('vagrant')<CR>
    PlanetMenu an 500.10  🎚️&{.QEMU.Test  <Cmd>call planet#integrations#Run('qemu')<CR>
    PlanetMenu an 500.10  🎚️&{.QEMU\ Schroot.qemu-debootstrap  <Cmd>call planet#integrations#Run('qemu-debootstrap')<CR>
    PlanetMenu an 500.10  🎚️&{.Configuration <Nop>
    an disable 🎚️&{.Configuration
    PlanetMenu an 500.10  🎚️&{.Install\ Qt.Set\ $QTDIR                 <Cmd>call planet#env#SetEnvVar('QTDIR')<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version        <Cmd>call planet#integrations#QtInstall('desktop', v:false)<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Modules <Cmd>call planet#integrations#QtInstall('desktop', v:true)<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Android <Cmd>call planet#integrations#QtInstall('android', v:false)<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Android\ Modules <Cmd>call planet#integrations#QtInstall('android', v:true)<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Wasm  <Cmd>call planet#integrations#QtInstall('wasm', v:false)<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ Qt.Install\ Qt\ Version\ Wasm\ Modules <Cmd>call planet#integrations#QtInstall('wasm', v:true)<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ Conan\ Pkg.Install  <Cmd>call planet#integrations#Run('conan')<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ pip\ Pkg.PySide6               <Cmd>call planet#integrations#Command(['pip', 'install', 'PySide6'])<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ pip\ Pkg.Jupyter\ Notebook     <Cmd>call planet#integrations#Command(['pip', 'install', 'notebook'])<CR>
    PlanetMenu an 500.10  🎚️&{.Install\ pip\ Pkg.JupyterLab            <Cmd>call planet#integrations#Command(['pip', 'install', 'jupyterlab'])<CR>
    PlanetMenu an 500.10  🎚️&{.Npm.Start\ App\ for\ Development        <Cmd>call planet#integrations#Command(['npm', 'run', 'dev'])<CR>
    PlanetMenu an 500.10  🎚️&{.Npm.Start\ Build                        <Cmd>call planet#integrations#Command(['npm', 'run', 'build'])<CR>
    PlanetMenu an 500.10  🎚️&{.Npm.Start\ App                          <Cmd>call planet#integrations#Command(['npm', 'run', 'serve'])<CR>
    PlanetMenu an 500.10  🎚️&{.Npm.Install\ Project\ Packages          <Cmd>call planet#integrations#Command(['npm', 'install'])<CR>
    PlanetMenu an 500.10  🎚️&{.Npm.Install\ Packages\.\.\.             <Cmd>call planet#integrations#Ask(['npm', 'install'], 'Packages: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.Npm.Install\ Packages\ Globally\.\.\.   <Cmd>call planet#integrations#Ask(['npm', 'install', '-g'], 'Packages: ', [])<CR>
    PlanetMenu an 500.10  🎚️&{.Npm.Install\ create-nuxt            <Cmd>call planet#integrations#Command(['npm', 'install', '-g', 'create-nuxt@3.37.0'])<CR>
    PlanetMenu an 500.10  🎚️&{.--1-- <Nop>
    PlanetMenu an 500.10  🎚️&{.Set\ Compiler.gcc  <Cmd>call planet#integrations#Compiler('gcc')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Compiler.clang  <Cmd>call planet#integrations#Compiler('clang')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Compiler.emcc\ (wasm,\ emscripten)  <Cmd>call planet#integrations#Compiler('emcc')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.Raspberry\ Pi  <Cmd>call planet#integrations#Compiler('raspberry')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.ESP32  <Cmd>call planet#integrations#Compiler('esp32')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.Arduino  <Cmd>call planet#integrations#Compiler('arduino')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.Jetson\ Nano  <Cmd>call planet#integrations#Compiler('jetson')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.BeagleBone\ Black  <Cmd>call planet#integrations#Compiler('beaglebone')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.Coral  <Cmd>call planet#integrations#Compiler('coral')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.HiKey970  <Cmd>call planet#integrations#Compiler('hikey')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.--1-- <Nop>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.Host  <Cmd>call planet#integrations#ConfigureValue('host')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.Target  <Cmd>call planet#integrations#ConfigureValue('target')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compilation.Sysroot  <Cmd>call planet#integrations#ConfigureValue('sysroot')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Build  <Cmd>call planet#integrations#ConfigureValue('build')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Host  <Cmd>call planet#integrations#ConfigureValue('host')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Target  <Cmd>call planet#integrations#ConfigureValue('target')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Canadian\ Cross-Compilation.Sysroot  <Cmd>call planet#integrations#ConfigureValue('sysroot')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-mingw  <Cmd>call planet#integrations#Compiler('mingw')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-arm  <Cmd>call planet#integrations#Compiler('arm')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-aarch64  <Cmd>call planet#integrations#Compiler('aarch64')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Cross-Compiler.gcc-avr  <Cmd>call planet#integrations#Compiler('avr')<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Installed    <Cmd>call planet#integrations#Command(['pyenv', 'versions'])<CR>
    PlanetMenu an 500.10  🎚️&{.Set\ Python\ (PyEnv).List\ Available    <Cmd>call planet#integrations#Command(['pyenv', 'install', '--list'])<CR>
    PlanetMenu an 500.10  🎚️&{.Settings <Nop>
    an disable 🎚️&{.Settings
    PlanetMenu an 500.10  🎚️&{.&Env.&Source\ \.env                     <Cmd>Dotenv .env<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.&Source\ File\.\.\.                :Dotenv <C-z>
    PlanetMenu an 500.10  🎚️&{.&Env.Set\ Env\ &Var                     <Cmd>call planet#env#NewEnvVar()<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.Edit\ &\.env                       <Cmd>e .env<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.Edit\ E&nv\ in\ Buffer             <Cmd>call planet#env#BufferFromCmd('env')<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.Set\ $&DESTDIR                     <Cmd>call planet#env#SetEnvVar('DESTDIR')<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.Set\ $P&YTHONPATH                  <Cmd>call planet#env#SetEnvVar('PYTHONPATH')<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.Set\ $&PATH                        <Cmd>call planet#env#SetEnvVar('PATH')<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.Set\ $&ARCH                        <Cmd>call planet#env#SetEnvVar('ARCH')<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.Set\ $&CROSS_COMPILE               <Cmd>call planet#env#SetEnvVar('CROSS_COMPILE')<CR>
    PlanetMenu an 500.10  🎚️&{.&Env.P&rint\ Env                        <Cmd>call planet#env#PrintEnv()<CR>
    PlanetMenu an 500.10  🎚️&{.D&irenv.&Edit\ (or\ Create)\ \.envrc    <Cmd>EditEnvrc<CR>
    PlanetMenu an 500.10  🎚️&{.D&irenv.&Allow\ Here                    <Cmd>call planet#integrations#Command(['direnv', 'allow'])<CR>
    PlanetMenu an 500.10  🎚️&{.D&irenv.&Run\ \.envrc                   <Cmd>DirenvExport<CR>
    PlanetMenu an 500.10  🎚️&{.D&irenv.E&dit\ \.direnvrc               <Cmd>EditDirenvrc<CR>
    PlanetMenu an 500.10  🎚️&{.D&irenv.De&ny\ Here                     <Cmd>call planet#integrations#Command(['direnv', 'deny'])<CR>
    PlanetMenu an 500.10  🎚️&{.D&irenv.P&rune\ Old\ Files              <Cmd>call planet#integrations#Command(['direnv', 'prune'])<CR>
    PlanetMenu an 500.10  🎚️&{.Editor&Config.&Add\ New                 <Cmd>e .editorconfig<CR>
    PlanetMenu an 500.10  🎚️&{.Editor&Config.&Reload                   <Cmd>EditorConfigReload<CR>
    PlanetMenu an 500.10  🎚️&{.Editor&Config.Disable\ for\ &buffer     <Cmd>let b:EditorConfig_disable=1<CR>
    PlanetMenu an 500.10  🎚️&{.Editor&Config.--1-- <Nop>
    PlanetMenu an 500.10  🎚️&{.Editor&Config.&Enable                   <Cmd>EditorConfigEnable<CR>
    PlanetMenu an 500.10  🎚️&{.Editor&Config.&Disable                  <Cmd>EditorConfigDisable<CR>

    PlanetMenu an 500.10  📐&}.Dev\ Tools <Nop>
    an disable 📐&}.Dev\ Tools
    PlanetMenu an 500.10  📐&}.Parser\ Generators.flex  <Cmd>call planet#integrations#Run('flex')<CR>
    PlanetMenu an 500.10  📐&}.Parser\ Generators.bison  <Cmd>call planet#integrations#Run('bison')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.Qt\ Creator                  <Cmd>call planet#integrations#Command(['qtcreator', expand('%:p')], #{qt:v:true})<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.Designer                     <Cmd>call planet#integrations#Command(['designer', expand('%:p')], #{qt:v:true})<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.Assistant                    <Cmd>call planet#term#RunGuiApp(['assistant'])<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.PixelTool                    <Cmd>call planet#term#RunGuiApp(['pixeltool'])<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.QDbusViewer                  <Cmd>call planet#term#RunGuiApp(['qdbusviewer'])<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.pyside6-uic  <Cmd>call planet#integrations#Run('pyside6-uic')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.pyside6-rcc  <Cmd>call planet#integrations#Run('pyside6-rcc')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.Generate\ qt\.conf  <Cmd>call planet#integrations#Write('qt-conf')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.androidtestrunner  <Cmd>call planet#integrations#Run('androidtestrunner')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.balsam  <Cmd>call planet#integrations#Run('balsam')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.moc  <Cmd>call planet#integrations#Run('moc')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.moc-ng  <Cmd>call planet#integrations#Run('moc-ng')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qdbus  <Cmd>call planet#integrations#Run('qdbus')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qdbuscpp2xml  <Cmd>call planet#integrations#Run('qdbuscpp2xml')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qdbusxml2cpp  <Cmd>call planet#integrations#Run('qdbusxml2cpp')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.QLALR  <Cmd>call planet#integrations#Run('qlalr')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qsb  <Cmd>call planet#integrations#Run('qsb')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qtattributionsscanner  <Cmd>call planet#integrations#Run('qtattributionsscanner')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qt-cmake  <Cmd>call planet#integrations#Run('qt-cmake')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qt-configure-module  <Cmd>call planet#integrations#Run('qt-configure-module')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qtdiag  <Cmd>call planet#integrations#Run('qtdiag')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qtpaths  <Cmd>call planet#integrations#Run('qtpaths')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qtplugininfo  <Cmd>call planet#integrations#Run('qtplugininfo')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qtwaylandscanner  <Cmd>call planet#integrations#Run('qtwaylandscanner')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.qvkgen  <Cmd>call planet#integrations#Run('qvkgen')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.rcc  <Cmd>call planet#integrations#Run('rcc')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.shadergen  <Cmd>call planet#integrations#Run('shadergen')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.syncqt\.pl  <Cmd>call planet#integrations#Run('syncqt.pl')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.tracegen  <Cmd>call planet#integrations#Run('tracegen')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.uic  <Cmd>call planet#integrations#Run('uic')<CR>
    PlanetMenu an 500.10  📐&}.&Qt\ Tools.SCXML  <Cmd>call planet#integrations#Run('scxml')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qml  <Cmd>call planet#integrations#Run('qml')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmlcachegen  <Cmd>call planet#integrations#Run('qmlcachegen')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmleasing  <Cmd>call planet#integrations#Run('qmleasing')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmlformat  <Cmd>call planet#integrations#Run('qmlformat')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmlimportscanner  <Cmd>call planet#integrations#Run('qmlimportscanner')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmllint  <Cmd>call planet#integrations#Run('qmllint')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmlplugindump  <Cmd>call planet#integrations#Run('qmlplugindump')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmlpreview  <Cmd>call planet#integrations#Run('qmlpreview')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmlprofiler  <Cmd>call planet#integrations#Run('qmlprofiler')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmlscene  <Cmd>call planet#integrations#Run('qmlscene')<CR>
    PlanetMenu an 500.10  📐&}.Qml.testrunner  <Cmd>call planet#integrations#Run('qmltestrunner')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmltime  <Cmd>call planet#integrations#Run('qmltime')<CR>
    PlanetMenu an 500.10  📐&}.Qml.qmltyperegistrar  <Cmd>call planet#integrations#Run('qmltyperegistrar')<CR>
    PlanetMenu an 500.10  📐&}.Gtk\ Tools.Glade                        <Cmd>call planet#integrations#Command(['glade', expand('%:p')])<CR>
    PlanetMenu an 500.10  📐&}.Gtk\ Tools.Glade\ Previewer             <Cmd>call planet#integrations#Command(['glade-previewer', '--filename', expand('%:p')])<CR>
    PlanetMenu an 500.10  📐&}.Gtk\ Tools.Devhelp                      <Cmd>call planet#integrations#Command(['devhelp', '--search=' .. expand('<cword>')])<CR>
    PlanetMenu an 500.10  📐&}.Gtk\ Tools.Devhelp\ Assistant           <Cmd>call planet#integrations#Command(['devhelp', '--search-assistant=' .. expand('<cword>')])<CR>
    PlanetMenu an 500.10  📐&}.Kernel.Check\ &Patch  <Cmd>call planet#integrations#Run('kernel-checkpatch')<CR>
    PlanetMenu an 500.10  📐&}.Kernel.Get\ Maintainers  <Cmd>call planet#integrations#Run('kernel-maintainer')<CR>
    PlanetMenu an 500.10  📐&}.Kernel.Device\ Tree\ Compiler  <Cmd>call planet#integrations#Run('kernel-dtc')<CR>
    PlanetMenu an 500.10  📐&}.Kernel.--1-- <Nop>
    PlanetMenu an 500.10  📐&}.Kernel.&Generate\ compile_commands\.json  <Cmd>call planet#integrations#Run('kernel-compdb')<CR>
    PlanetMenu an 500.10  📐&}.Kernel.&Generate\ tags                  <Cmd>call planet#integrations#Command(['make', 'tags'])<CR>
    PlanetMenu an 500.10  📐&}.Kernel.&Generate\ GTAGS                 <Cmd>call planet#integrations#Command(['make', 'gtags'])<CR>
    PlanetMenu an 500.10  📐&}.Kernel.&Generate\ cscope\.out           <Cmd>call planet#integrations#Command(['make', 'cscope'])<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Run\ Command\ in\ New\ Instance  <Cmd>call planet#integrations#Run('xvfb-command')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).--1-- <Nop>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Run\ Command  <Cmd>call planet#integrations#Ask([], 'Command using current DISPLAY')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).View  <Cmd>call planet#integrations#Run('xvfb-view')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Take\ Screenshot  <Cmd>call planet#integrations#Run('xvfb-screenshot')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).--2-- <Nop>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Start  <Cmd>call planet#integrations#XDisplay('start')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Stop  <Cmd>call planet#integrations#XDisplay('stop')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).--3-- <Nop>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 0<Tab>$DISPLAY=:80  <Cmd>call planet#integrations#XDisplay('set', ':80')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 1<Tab>$DISPLAY=:81  <Cmd>call planet#integrations#XDisplay('set', ':81')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 2<Tab>$DISPLAY=:82  <Cmd>call planet#integrations#XDisplay('set', ':82')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 3<Tab>$DISPLAY=:83  <Cmd>call planet#integrations#XDisplay('set', ':83')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 4<Tab>$DISPLAY=:84  <Cmd>call planet#integrations#XDisplay('set', ':84')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 5<Tab>$DISPLAY=:85  <Cmd>call planet#integrations#XDisplay('set', ':85')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 6<Tab>$DISPLAY=:86  <Cmd>call planet#integrations#XDisplay('set', ':86')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 7<Tab>$DISPLAY=:87  <Cmd>call planet#integrations#XDisplay('set', ':87')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 8<Tab>$DISPLAY=:88  <Cmd>call planet#integrations#XDisplay('set', ':88')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Set\ Current\ to\ 9<Tab>$DISPLAY=:89  <Cmd>call planet#integrations#XDisplay('set', ':89')<CR>
    PlanetMenu an 500.10  📐&}.Virtual\ Display\ (Xvfb).Specify\ Custom\ $DISPLAY  <Cmd>call planet#integrations#XDisplay('set')<CR>
    PlanetMenu an 500.10  📐&}.Vue.Start                          <Cmd>call planet#integrations#Command(['npm', 'run', 'serve'])<CR>
    PlanetMenu an 500.10  📐&}.Vue.Build                          <Cmd>call planet#integrations#Command(['npm', 'run', 'build'])<CR>
    PlanetMenu an 500.10  📐&}.Vue.Lint                           <Cmd>call planet#integrations#Command(['npm', 'run', 'lint'])<CR>
    PlanetMenu an 500.10  📐&}.Vue.Add\ vue-router                <Cmd>call planet#integrations#Command(['npm', 'install', 'vue-router'])<CR>
    PlanetMenu an 500.10  📐&}.Vue.Add\ vuex                      <Cmd>call planet#integrations#Command(['npm', 'install', 'vuex'])<CR>
    PlanetMenu an 500.10  📐&}.Vue.Create\.\.\.                   <Cmd>call planet#integrations#Ask(['npm', 'create', 'vue@latest'], 'Name of new project: ', ['vue-app'])<CR>
    PlanetMenu an 500.10  📐&}.Nuxt.Run\ Dev                           <Cmd>call planet#integrations#Command(['npm', 'run', 'dev'])<CR>
    PlanetMenu an 500.10  📐&}.Nuxt.Build                              <Cmd>call planet#integrations#Command(['npm', 'run', 'build'])<CR>
    PlanetMenu an 500.10  📐&}.Nuxt.Start                              <Cmd>call planet#integrations#Command(['npm', 'run', 'preview'])<CR>
    PlanetMenu an 500.10  📐&}.Nuxt.Generate                           <Cmd>call planet#integrations#Command(['npm', 'run', 'generate'])<CR>
    PlanetMenu an 500.10  📐&}.Web\ Tools.Download\ URL  <Cmd>call planet#integrations#Run('download')<CR>
    PlanetMenu an 500.10  📐&}.Vulkan.Compile\ Shader  <Cmd>call planet#integrations#Run('glslc')<CR>
    PlanetMenu an 500.10  📐&}.Open\ GL.glxinfo                        <Cmd>call planet#integrations#Command(['glxinfo'])<CR>
    PlanetMenu an 500.10  📐&}.Blender.Print\ Blender\ PYTHONPATH      <Cmd>call planet#integrations#Command(['blender', '--background', '--python-expr', 'import os,sys; print("PYTHONPATH=" + os.pathsep.join(sys.path))'])<CR>
    PlanetMenu an 500.10  📐&}.Node.Run\ with\ node                    <Cmd>call planet#integrations#Command(['node', expand('%:p')])<CR>
    PlanetMenu an 500.10  📐&}.Node.Start\ node\ REPL                  <Cmd>call planet#integrations#Command(['node'])<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.Emscripten\ Install  <Cmd>call planet#integrations#Emsdk('install')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.Emscripten\ Activate  <Cmd>call planet#integrations#Emsdk('activate')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.Emscripten\ Update  <Cmd>call planet#integrations#Emsdk('update')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.emcc\ version  <Cmd>call planet#integrations#Command(['emcc', '--version'])<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ html  <Cmd>call planet#integrations#Run('emcc-html')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ js  <Cmd>call planet#integrations#Run('emcc-js')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.emcc\ compile\ to\ wasm  <Cmd>call planet#integrations#Run('emcc-wasm')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.emcc\ compile\ bind  <Cmd>call planet#integrations#Run('emcc-bind')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.emrun\ file                 <Cmd>call planet#integrations#Command(['emrun', expand('%:p:r') .. '.html'])<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.DisWebAssemble\ to\ js  <Cmd>call planet#integrations#Run('wasm2js')<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.Configure                   <Cmd>call planet#integrations#Command(['emconfigure', './configure'])<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.Cmake  <Cmd>call planet#integrations#Command(['emcmake', 'cmake', '-S', planet#run#Project().root, '-B', planet#run#Project().root .. '/build-wasm'])<CR>
    PlanetMenu an 500.10  📐&}.WebAssembly.Emmake\ make                <Cmd>call planet#integrations#Command(['emmake', 'make'])<CR>
    PlanetMenu an 500.10  📐&}.Python.JupyterLab                       <Cmd>call planet#integrations#Command(['jupyter-lab'])<CR>
    PlanetMenu an 500.10  📐&}.Python.Jupyter\ Notebook                <Cmd>call planet#integrations#Command(['jupyter-notebook'])<CR>
    PlanetMenu an 500.10  📐&}.i10n\ &&\ i18n <Nop>
    an disable 📐&}.i10n\ &&\ i18n
    PlanetMenu an 500.10  📐&}.lupdate  <Cmd>call planet#integrations#Run('lupdate')<CR>
    PlanetMenu an 500.10  📐&}.lrelease  <Cmd>call planet#integrations#Run('lrelease')<CR>
    PlanetMenu an 500.10  📐&}.lconvert  <Cmd>call planet#integrations#Run('lconvert')<CR>
    PlanetMenu an 500.10  📐&}.Qt\ Linguist  <Cmd>call planet#integrations#Run('linguist')<CR>
    PlanetMenu an 500.10  📐&}.lprodump  <Cmd>call planet#integrations#Run('lprodump')<CR>
    PlanetMenu an 500.10  📐&}.lrelease-pro  <Cmd>call planet#integrations#Run('lrelease-pro')<CR>
    PlanetMenu an 500.10  📐&}.lupdate-pro  <Cmd>call planet#integrations#Run('lupdate-pro')<CR>
    PlanetMenu an 500.10  📐&}.auto-translation  <Cmd>call planet#integrations#Run('auto-translation')<CR>
    PlanetMenu an 500.10  📐&}.gettext  <Cmd>call planet#integrations#Run('gettext')<CR>
    PlanetMenu an 500.10  📐&}.weblate\.org  <Cmd>call planet#gui#OpenUrl('https://hosted.weblate.org/')<CR>
    PlanetMenu an 500.10  📐&}.Documentation <Nop>
    an disable 📐&}.Documentation
    PlanetMenu an 500.10  📐&}.doxygen  <Cmd>call planet#integrations#Run('doxygen')<CR>
    PlanetMenu an 500.10  📐&}.QDoc  <Cmd>call planet#integrations#Run('qdoc')<CR>
    PlanetMenu an 500.10  📐&}.QHelp\ Generator  <Cmd>call planet#integrations#Run('qhelpgenerator')<CR>
    PlanetMenu an 500.10  📐&}.readthedocs  <Cmd>call planet#integrations#Run('readthedocs')<CR>
    PlanetMenu an 500.10  📐&}.gitbook  <Cmd>call planet#integrations#Run('gitbook')<CR>

    PlanetMenu an 500.10  🔨&b.Build <Nop>
    an disable 🔨&b.Build
    PlanetMenu an 500.10  🔨&b.&Autotools.Autotools\ Status            <Cmd>call planet#integrations#AutotoolsStatus()<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ autoconf                <Cmd>call planet#integrations#Command(['autoconf', '--force'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ autoreconf              <Cmd>call planet#integrations#Command(['autoreconf', '-f', '-i'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ autoheader              <Cmd>call planet#integrations#Command(['autoheader'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ autoscan                <Cmd>call planet#integrations#Command(['autoscan'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ autoupdate              <Cmd>call planet#integrations#Command(['autoupdate'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ ifnames                 <Cmd>call planet#integrations#Command(['ifnames'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ libtool                 <Cmd>call planet#integrations#Command(['libtool'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ libtoolize              <Cmd>call planet#integrations#Command(['libtoolize'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Generate\ \./autogen\.sh  <Cmd>call planet#integrations#Write('autogen')<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Generate\ \./configure\.ac   <Cmd>call planet#project#CopyFile('autotools/configure.ac')<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ \./autogen\.sh          <Cmd>call planet#integrations#Command(['./autogen.sh'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ \./bootstrap\.sh        <Cmd>call planet#integrations#Command(['./bootstrap.sh'])<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Run\ \./&configure           <Cmd>call planet#integrations#Configure()<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Rerun\ \./&configure         <Cmd>call planet#term#RunCmdFind('config.status', '--recheck')<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ \./configure\ Options  <Cmd>call planet#integrations#ConfigureOptions()<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Open\ config\.log            <Cmd>find config.log<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ $CC                     <Cmd>call planet#env#SetEnvVar("CC")<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ $CFLAGS                 <Cmd>call planet#env#SetEnvVar("CFLAGS")<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ $CXX                    <Cmd>call planet#env#SetEnvVar("CXX")<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ $CXXFLAGS               <Cmd>call planet#env#SetEnvVar("CXXFLAGS")<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ $LDFLAGS                <Cmd>call planet#env#SetEnvVar("LDFLAGS")<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ $CPPFLAGS               <Cmd>call planet#env#SetEnvVar("CPPFLAGS")<CR>
    PlanetMenu an 500.10  🔨&b.&Autotools.Set\ $DESTDIR                <Cmd>call planet#env#SetEnvVar("DESTDIR")<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.&Make                             <Cmd>call planet#integrations#Command(['make'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ &All                        <Cmd>call planet#integrations#Command(['make', 'all'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ &Help                       <Cmd>call planet#integrations#Command(['make', 'help'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ &Clean                      <Cmd>call planet#integrations#Command(['make', 'clean'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ Distclea&n                  <Cmd>call planet#integrations#Command(['make', 'distclean'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ &Dist                       <Cmd>call planet#integrations#Command(['make', 'dist'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ Di&stcheck                  <Cmd>call planet#integrations#Command(['make', 'distcheck'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ Chec&k                      <Cmd>call planet#integrations#Command(['make', 'check'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ &Test                       <Cmd>call planet#integrations#Command(['make', 'test'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ &Install                    <Cmd>call planet#integrations#Command(['make', 'install'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Make\ &Uninstall                  <Cmd>call planet#integrations#Command(['make', 'uninstall'])<CR>
    PlanetMenu an 500.10  🔨&b.Mak&e.Set\ $MAKEFLAGS                   <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &oldconfig                <Cmd>call planet#term#RunCmd("yes '' \| make oldconfig")<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &menuconfig               <Cmd>call planet#term#RunCmdTab(['make', 'menuconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.ma&ke                           <Cmd>call planet#integrations#Command(['make'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.ma&ke\ Target\.\.\.             <Cmd>call planet#integrations#Ask(['make'], 'Target: ', [])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.&Edit\ \.config                 <Cmd>e .config<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.&Edit\ $MAKEFLAGS               <Cmd>call planet#env#SetEnvVar('MAKEFLAGS')<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ c&lean                    <Cmd>call planet#integrations#Command(['make', 'clean'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ mr&proper                 <Cmd>call planet#integrations#Command(['make', 'mrproper'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ dis&tclean                <Cmd>call planet#integrations#Command(['make', 'distclean'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &help                     <Cmd>call planet#integrations#Command(['make', 'help'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &config                   <Cmd>call planet#integrations#Command(['make', 'config'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ allyesconfig              <Cmd>call planet#integrations#Command(['make', 'allyesconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ allnoconfig               <Cmd>call planet#integrations#Command(['make', 'allnoconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ defconfig                 <Cmd>call planet#integrations#Command(['make', 'defconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ install                   <Cmd>call planet#integrations#Command(['make', 'install'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ uninstall                 <Cmd>call planet#integrations#Command(['make', 'uninstall'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ randconfig                <Cmd>call planet#integrations#Command(['make', 'randconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ allmodconfig              <Cmd>call planet#integrations#Command(['make', 'allmodconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &nconfig                  <Cmd>call planet#integrations#Command(['make', 'nconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &xconfig                  <Cmd>call planet#integrations#Command(['make', 'xconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &gconfig                  <Cmd>call planet#integrations#Command(['make', 'gconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&KBuild.make\ &tags                     <Cmd>call planet#integrations#Command(['make', 'tags'])<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Select\ Build\ Dir               <Cmd>call planet#build#SelectBuildDir()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Create\ &In-Tree\ Build\ Dir     <Cmd>call planet#build#NewInTreeBuildDir()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Create\ &OOT\ Build\ Dir         <Cmd>call planet#build#NewOOTBuildDir()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Browse\ Build\ Directory         <Cmd>call planet#build#Browse()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.--1-- <Nop>
    PlanetMenu an 500.10  🔨&b.&CMake.&Configure                       <Cmd>call planet#integrations#CmakeConfigure()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Configure\ &Tui                  <Cmd>call planet#build#ConfigureTui()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Configure\ &Gui                  <Cmd>call planet#build#ConfigureGui()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Configure\ Android\ armv7        <Cmd>call planet#integrations#AndroidCmake('armeabi-v7a')<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Configure\ Android\ x86          <Cmd>call planet#integrations#AndroidCmake('x86')<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.--2-- <Nop>
    PlanetMenu an 500.10  🔨&b.&CMake.&Build                           <Cmd>call planet#build#Build()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.&Rebuild                         <Cmd>call planet#build#Rebuild()<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.Clean                            <Cmd>call planet#build#Build('clean')<CR>
    PlanetMenu an 500.10  🔨&b.&CMake.--3-- <Nop>
    PlanetMenu an 500.10  🔨&b.&CMake.Generate\ compile_commands\.json <Cmd>call planet#integrations#CmakeConfigure(v:true)<CR>
    PlanetMenu an 500.10  🔨&b.&Meson.Set\ DESTDIR  <Cmd>call planet#integrations#Set('DESTDIR')<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Verify                          <Cmd>ArduinoVerify<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Upload                          <Cmd>ArduinoUpload<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Upload\ and\ Serial             <Cmd>ArduinoUploadAndSerial<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Serial                          <Cmd>ArduinoSerial<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Set\ Baud                       <Cmd>call planet#arduino#Baud()<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.--2-- <Nop>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Choose\ Board                   <Cmd>ArduinoChooseBoard<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Choose\ Programmer              <Cmd>ArduinoChooseProgrammer<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Choose\ Port                    <Cmd>ArduinoChoosePort<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.--1-- <Nop>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Info                            <Cmd>ArduinoInfo<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Set\ Arduino\ Dir  <Cmd>call planet#integrations#Set('arduino_dir', v:null, v:true)<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Set\ Build\ Dir  <Cmd>call planet#integrations#Set('arduino_build_path', v:null, v:true)<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Use\ Arduino\ IDE               <Cmd>let g:arduino_use_cli = 0<CR>
    PlanetMenu an 500.10  🔨&b.Ar&duino.Use\ arduino-cli                <Cmd>let g:arduino_use_cli = 1<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.&Build                       <Cmd>call planet#integrations#Command(['pio', 'run'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.&Upload                      <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'upload'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.Serial\ &Monitor             <Cmd>call planet#integrations#Command(['pio', 'device', 'monitor'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.Serial\ &Monitor\ in\ Tab    <Cmd>call planet#term#RunCmdTab(['pio', 'device', 'monitor'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.Build\ FS\ &Image            <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'buildfs'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.Upload\ &FS\ Image           <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'uploadfs'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.Me&nuconfig                  <Cmd>call planet#term#RunCmdTab(['pio', 'run', '-t', 'menuconfig'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.&Clean                       <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'clean'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.&Generate\ Compilation\ Database  <Cmd>call planet#integrations#Command(['pio', 'run', '-t', 'compiledb'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.&Activate  <Cmd>call planet#integrations#Environment('platformio')<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.&Web\ UI                     <Cmd>call planet#integrations#Command(['pio', 'home'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.Up&date\ Packages            <Cmd>call planet#integrations#Command(['pio', 'update'])<CR>
    PlanetMenu an 500.10  🔨&b.&PlatformIO.Upg&rade\ PlatformIO         <Cmd>call planet#integrations#Command(['pio', 'upgrade'])<CR>
    PlanetMenu an 500.10  🔨&b.&ROS.Build\ Workspace  <Cmd>call planet#integrations#Run('ros-build')<CR>
    PlanetMenu an 500.10  🔨&b.&ROS.roslaunch  <Cmd>call planet#integrations#Run('roslaunch')<CR>
    PlanetMenu an 500.10  🔨&b.&ROS.rosrun  <Cmd>call planet#integrations#Run('rosrun')<CR>
    PlanetMenu an 500.10  🔨&b.&ROS.Install\ Container.Kinetic  <Cmd>call planet#integrations#Run('ros-install-kinetic')<CR>
    PlanetMenu an 500.10  🔨&b.&ROS.Install\ Container.Melodic  <Cmd>call planet#integrations#Run('ros-install-melodic')<CR>
    PlanetMenu an 500.10  🔨&b.&ROS.Install\ Container.Noetic  <Cmd>call planet#integrations#Run('ros-install-noetic')<CR>
    PlanetMenu an 500.10  🔨&b.&ROS\ 2.Setup  <Cmd>call planet#integrations#Environment('ros2')<CR>
    PlanetMenu an 500.10  🔨&b.&Yocto.Setup  <Cmd>call planet#integrations#Environment('yocto')<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Doctor                          <Cmd>call planet#integrations#Command(['flutter', 'doctor'])<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Set\ Android\ Sdk\ Location  <Cmd>call planet#integrations#Flutter('sdk')<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Accept\ Android\ Licenses       <Cmd>call planet#integrations#Command(['flutter', 'doctor', '--android-licenses'])<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Create\ Project  <Cmd>call planet#integrations#Flutter('create')<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Run                             <Cmd>FlutterRun<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Hot\ Reload                     <Cmd>FlutterHotReload<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Hot\ Restart                    <Cmd>FlutterHotRestart<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Stop\ App                       <Cmd>FlutterQuit<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Devices                         <Cmd>FlutterDevices<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Output                          <Cmd>FlutterSplit<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Emulators                       <Cmd>FlutterEmulators<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Launch\ Emulators               <Cmd>FlutterEmulatorsLaunch<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Toggle\ Visual\ Debug           <Cmd>FlutterVisualDebug<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Add\ Desktop\ Linux\ Build      <Cmd>call planet#integrations#Command(['flutter', 'config', '--enable-linux-desktop'])<CR>
    PlanetMenu an 500.10  🔨&b.&Flutter.Add\ Desktop\ Windows\ Build    <Cmd>call planet#integrations#Command(['flutter', 'config', '--enable-windows-desktop'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.List\ Project\ Deps            <Cmd>call planet#integrations#Command(['npm', 'list', '--depth=0'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.--1-- <Nop>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Run\ App                       <Cmd>call planet#integrations#Command(['electron', '.'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Run\ with\ npm                 <Cmd>call planet#integrations#Command(['npm', 'start'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Run\ with\ auto\ reload        <Cmd>call planet#integrations#Command(['nodemon', '--exec', 'electron', '.'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Npm\ run\ with\ auto\ reload   <Cmd>call planet#integrations#Command(['npm', 'run', 'watch'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.--2-- <Nop>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Start\ Debug                   <Cmd>call planet#integrations#Command(['electron', '--inspect=5858', '.'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Break\ on\ Start               <Cmd>call planet#integrations#Command(['electron', '--inspect-brk=5858', '.'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.--3-- <Nop>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Rebuild\ Native\ Package\.\.\. <Cmd>call planet#integrations#Ask(['electron-rebuild'], 'Package name: ', [])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.--4-- <Nop>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Linux\ AppImage         <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'AppImage'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Linux\ snap             <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'snap'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Linux\ deb              <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'deb'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Linux\ tar\.gz          <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'tar.gz'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Linux\ apk              <Cmd>call planet#integrations#Command(['electron-builder', '--linux', 'apk'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Windows\ self-signed-cert <Cmd>call planet#integrations#Command(['electron-builder', 'create-self-signed-cert'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Windows\ nsis           <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'nsis'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Windows\ Portable\ App  <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'portable'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Windows\ Appx           <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'appx'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Build\ Windows\ zip            <Cmd>call planet#integrations#Command(['electron-builder', '--windows', 'zip'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.--5-- <Nop>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Install\ as\ Local\ Dep        <Cmd>call planet#integrations#Command(['npm', 'i', '-D', 'electron@latest'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Install\ Project\ Deps         <Cmd>call planet#integrations#Command(['npm', 'i'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Add\ electron-builder          <Cmd>call planet#integrations#Command(['npm', 'i', '-D', 'electron-builder'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Add\ electron-updater          <Cmd>call planet#integrations#Command(['npm', 'i', 'electron-updater'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Install\ electron-rebuild      <Cmd>call planet#integrations#Command(['npm', 'install', '-g', 'electron-rebuild'])<CR>
    PlanetMenu an 500.10  🔨&b.Elec&tron.Install\ electron-builder      <Cmd>call planet#integrations#Command(['npm', 'install', '-g', 'electron-builder'])<CR>
    PlanetMenu an 500.10  🔨&b.&Other.&Ninja.Set\ DESTDIR  <Cmd>call planet#integrations#Set('DESTDIR')<CR>
    PlanetMenu an 500.10  🔨&b.&Other.&QMake.Set\ DESTDIR  <Cmd>call planet#integrations#QmakeDestdir()<CR>
    PlanetMenu an 500.10  🔨&b.&Other.&Scons.Run\ Target\.\.\.          <Cmd>call planet#integrations#Ask(['scons'], 'scons: ', ['-j8', '.'])<CR>
    PlanetMenu an 500.10  🔨&b.Deploy <Nop>
    an disable 🔨&b.Deploy
    PlanetMenu an 500.10  🔨&b.Windeployqt.Deploy  <Cmd>call planet#integrations#Run('windeployqt')<CR>
    PlanetMenu an 500.10  🔨&b.Linuxdeploy.Deploy  <Cmd>call planet#integrations#Run('linuxdeploy')<CR>
    PlanetMenu an 500.10  🔨&b.Androiddeployqt.Deploy  <Cmd>call planet#integrations#Run('androiddeployqt')<CR>
    PlanetMenu an 500.10  🔨&b.Package <Nop>
    an disable 🔨&b.Package
    PlanetMenu an 500.10  🔨&b.fpm.Build  <Cmd>call planet#integrations#Run('fpm')<CR>
    PlanetMenu an 500.10  🔨&b.PyInstaller.Build\ app\.spec             <Cmd>call planet#integrations#Command(['pyinstaller', 'app.spec'])<CR>
    PlanetMenu an 500.10  🔨&b.PyInstaller.Basic\ Build\ app\.py        <Cmd>call planet#integrations#Command(['pyinstaller', '--windowed', 'app.py'])<CR>
    PlanetMenu an 500.10  🔨&b.PyInstaller.Install                      <Cmd>call planet#integrations#Command(['pip', 'install', 'PyInstaller', 'pyinstaller-hooks-contrib'])<CR>
    PlanetMenu an 500.10  🔨&b.PyInstaller.Update\ PyInstaller          <Cmd>call planet#integrations#Command(['pip', 'install', '--upgrade', 'PyInstaller', 'pyinstaller-hooks-contrib'])<CR>
    PlanetMenu an 500.10  🔨&b.CPack.Build  <Cmd>call planet#integrations#Run('cpack')<CR>
    PlanetMenu an 500.10  🔨&b.AppImage.Build  <Cmd>call planet#integrations#Run('appimage')<CR>
    PlanetMenu an 500.10  🔨&b.Snap.Build  <Cmd>call planet#integrations#Run('snap')<CR>
    PlanetMenu an 500.10  🔨&b.FlatPak.Build  <Cmd>call planet#integrations#Run('flatpak')<CR>
    PlanetMenu an 500.10  🔨&b.pyUpdater.Build  <Cmd>call planet#integrations#Run('pyupdater')<CR>
    PlanetMenu an 500.10  🔨&b.Installer <Nop>
    an disable 🔨&b.Installer
    PlanetMenu an 500.10  🔨&b.Qt\ Installer\ Framework.Build  <Cmd>call planet#integrations#Run('qt-installer')<CR>

    # Run
    PlanetMenu an 510.10  ▶️&r.Run <Nop>
    an disable ▶️&r.Run
    PlanetMenu an 510.500 ▶️&r.--1-- <Nop>
    PlanetMenu an 510.500 ▶️&r.Add\ Run\ Configuration                 <Cmd>call planet#run#AddConfig()<CR>
    PlanetMenu an 510.500 ▶️&r.Edit\ Run\ Configurations               <Cmd>call planet#run#EditConfig()<CR>

    # Debug
    PlanetMenu an 520.10  🐞&d.Debug <Nop>
    an disable 🐞&d.Debug
    PlanetMenu an 520.10  🐞&d.Start\ &Debug  <Cmd>PlanetDebug launch<CR>
    PlanetMenu an 520.10  🐞&d.Detach\ Debugger  <Cmd>PlanetDebug detach<CR>
    PlanetMenu an 520.10  🐞&d.Stop\ &Debug  <Cmd>PlanetDebug stop<CR>
    PlanetMenu an 520.10  🐞&d.--1-- <Nop>
    PlanetMenu an 520.10  🐞&d.Setup\ GDB  <Cmd>PlanetDebugSetup cpp<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ GDB\ Dashboard  <Cmd>call planet#debugtools#Run('gdb-dashboard')<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ GDB\ for\ Unreal  <Cmd>call planet#debugtools#Run('gdb-unreal')<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ GDB\ Pretty\ Printers  <Cmd>call planet#debugtools#Run('gdb-pretty-printers')<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ LLDB  <Cmd>call planet#debugtools#Run('lldb')<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ rr  <Cmd>call planet#debugtools#Run('rr')<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ LiveRecorder  <Cmd>call planet#debugtools#Run('live-recorder')<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ radare2  <Cmd>call planet#debugtools#Run('radare2')<CR>
    PlanetMenu an 520.10  🐞&d.Setup\ cutter  <Cmd>call planet#debugtools#Run('cutter')<CR>
    PlanetMenu an 520.10  🐞&d.--1-- <Nop>
    PlanetMenu an 520.10  🐞&d.Debug\ Kernel <Nop>
    an disable 🐞&d.Debug\ Kernel
    PlanetMenu an 520.10  🐞&d.Setup\ GDB\ for\ Kernel  <Cmd>call planet#debugtools#Run('gdb-kernel-setup')<CR>
    PlanetMenu an 520.10  🐞&d.gdb\ kernel  <Cmd>call planet#debugtools#Run('gdb-kernel')<CR>
    PlanetMenu an 520.10  🐞&d.kgdb  <Cmd>call planet#debugtools#Run('kgdb')<CR>
    PlanetMenu an 520.10  🐞&d.kdb  <Cmd>call planet#debugtools#Run('kdb')<CR>
    PlanetMenu an 520.10  🐞&d.debugfs  <Cmd>call planet#debugtools#Run('debugfs')<CR>

    # Test
    PlanetMenu an 530.10  🧪&j.Test <Nop>
    an disable 🧪&j.Test
    PlanetMenu an 530.10  🧪&j.Nearest  <Cmd>PlanetTest nearest<CR>
    PlanetMenu an 530.10  🧪&j.File  <Cmd>PlanetTest file<CR>
    PlanetMenu an 530.10  🧪&j.Suite  <Cmd>PlanetTest suite<CR>
    PlanetMenu an 530.10  🧪&j.Last  <Cmd>PlanetTest last<CR>
    PlanetMenu an 530.10  🧪&j.Visit  <Cmd>PlanetTest visit<CR>
    PlanetMenu an 530.10  🧪&j.Qt\ Test  <Cmd>call planet#testtools#Run('qt')<CR>
    PlanetMenu an 530.10  🧪&j.Google\ Test  <Cmd>call planet#testtools#Run('google')<CR>
    PlanetMenu an 530.10  🧪&j.Boost\ Test  <Cmd>call planet#testtools#Run('boost')<CR>
    PlanetMenu an 530.10  🧪&j.Catch2\ Test  <Cmd>call planet#testtools#Run('catch2')<CR>
    PlanetMenu an 530.10  🧪&j.CTest  <Cmd>call planet#testtools#Run('ctest')<CR>
    PlanetMenu an 530.10  🧪&j.CDash  <Cmd>call planet#testtools#Run('cdash')<CR>
    PlanetMenu an 530.10  🧪&j.Report\ Tools.Screenshot  <Cmd>call planet#testtools#Run('screenshot')<CR>
    PlanetMenu an 530.10  🧪&j.Report\ Tools.Record\ gif  <Cmd>call planet#testtools#Run('record-gif')<CR>
    PlanetMenu an 530.10  🧪&j.Report\ Tools.Record\ screen  <Cmd>call planet#testtools#Run('record-screen')<CR>
    PlanetMenu an 530.10  🧪&j.Test\ Kernel <Nop>
    an disable 🧪&j.Test\ Kernel
    PlanetMenu an 530.10  🧪&j.KUnit  <Cmd>call planet#testtools#Run('kunit')<CR>
    PlanetMenu an 530.10  🧪&j.kselftest  <Cmd>call planet#testtools#Run('kselftest')<CR>

    # Analyze
    PlanetMenu an 540.10  🔬&y.Analyze <Nop>
    an disable 🔬&y.Analyze
    PlanetMenu an 540.10  🔬&y.Check  <Cmd>PlanetDiagnostics<CR>
    PlanetMenu an 540.10  🔬&y.Clang-Tidy  <Cmd>call planet#integrations#Run('clang-tidy')<CR>
    PlanetMenu an 540.10  🔬&y.Clazy  <Cmd>call planet#integrations#Run('clazy')<CR>
    PlanetMenu an 540.10  🔬&y.Cppcheck  <Cmd>call planet#integrations#Run('cppcheck')<CR>
    PlanetMenu an 540.10  🔬&y.Chrome\ Trace\ Format\ Visualizer  <Cmd>call planet#integrations#Trace()<CR>
    PlanetMenu an 540.10  🔬&y.Performance\ Analyzer  <Cmd>call planet#integrations#Run('perf')<CR>
    PlanetMenu an 540.10  🔬&y.Memcheck  <Cmd>call planet#integrations#Run('memcheck')<CR>
    PlanetMenu an 540.10  🔬&y.Memcheck\ Gdb  <Cmd>call planet#integrations#Run('memcheck-gdb')<CR>
    PlanetMenu an 540.10  🔬&y.Callgrind  <Cmd>call planet#integrations#Run('callgrind')<CR>
    PlanetMenu an 540.10  🔬&y.QML\ Profiler  <Cmd>call planet#integrations#Run('qmlprofiler')<CR>
    PlanetMenu an 540.10  🔬&y.ASAN  <Cmd>call planet#integrations#Run('asan')<CR>
    PlanetMenu an 540.10  🔬&y.ThreadSanitizer  <Cmd>call planet#integrations#Run('tsan')<CR>
    PlanetMenu an 540.10  🔬&y.LeakSanitizer  <Cmd>call planet#integrations#Run('lsan')<CR>
    PlanetMenu an 540.10  🔬&y.UBSAN  <Cmd>call planet#integrations#Run('ubsan')<CR>
    PlanetMenu an 540.10  🔬&y.Sanitizers  <Cmd>call planet#integrations#Run('sanitizers')<CR>
    PlanetMenu an 540.10  🔬&y.Coverity  <Cmd>call planet#integrations#Run('coverity')<CR>
    PlanetMenu an 540.10  🔬&y.ltrace  <Cmd>call planet#integrations#Run('ltrace')<CR>
    PlanetMenu an 540.10  🔬&y.strace  <Cmd>call planet#integrations#Run('strace')<CR>
    PlanetMenu an 540.10  🔬&y.ptrace  <Cmd>call planet#integrations#Run('ptrace')<CR>
    PlanetMenu an 540.10  🔬&y.pstree\ $PID  <Cmd>call planet#integrations#Run('pstree')<CR>
    PlanetMenu an 540.10  🔬&y.Open\ /proc/$PID\ Folder  <Cmd>call planet#integrations#Browse('/proc/PID')<CR>
    PlanetMenu an 540.10  🔬&y.Analyze\ Kernel <Nop>
    an disable 🔬&y.Analyze\ Kernel
    PlanetMenu an 540.10  🔬&y.Coccinelle  <Cmd>call planet#integrations#Run('coccinelle')<CR>
    PlanetMenu an 540.10  🔬&y.Sparse  <Cmd>call planet#integrations#Run('sparse')<CR>
    PlanetMenu an 540.10  🔬&y.kcov  <Cmd>call planet#integrations#Run('kcov')<CR>
    PlanetMenu an 540.10  🔬&y.gcov\ with\ kernel  <Cmd>call planet#integrations#Run('gcov')<CR>
    PlanetMenu an 540.10  🔬&y.KASAN  <Cmd>call planet#integrations#Run('kasan')<CR>
    PlanetMenu an 540.10  🔬&y.KUBSAN  <Cmd>call planet#integrations#Run('kubsan')<CR>
    PlanetMenu an 540.10  🔬&y.Kernel\ Memory\ Leak\ Detector  <Cmd>call planet#integrations#Run('kmemleak')<CR>
    PlanetMenu an 540.10  🔬&y.KCSAN  <Cmd>call planet#integrations#Run('kcsan')<CR>
    PlanetMenu an 540.10  🔬&y.Kernel\ Electric-Fence\ (KFENCE)  <Cmd>call planet#integrations#Run('kfence')<CR>
    PlanetMenu an 540.10  🔬&y.ftrace  <Cmd>call planet#integrations#Run('ftrace')<CR>
    PlanetMenu an 540.10  🔬&y.tracefs  <Cmd>call planet#integrations#Browse('/sys/kernel/tracing')<CR>

    # Terminal
    PlanetMenu an 550.10  💻&c.Terminal <Nop>
    an disable 💻&c.Terminal
    PlanetMenu an 550.10  💻&c.N&ew                                    <Cmd>botright terminal ++kill=kill ++rows=10<CR>
    PlanetMenu an 550.10  💻&c.New\ &Here                              <Cmd>terminal ++curwin ++kill=kill<CR>
    PlanetMenu an 550.10  💻&c.New\ &VSplit                            <Cmd>vertical terminal ++kill=kill<CR>
    PlanetMenu an 550.10  💻&c.New\ &Tab                               <Cmd>tab terminal ++kill=kill<CR>
    PlanetMenu an 550.10  💻&c.--1-- <Nop>
    PlanetMenu an 550.10  💻&c.&Run\ Command\.\.\.                     <Cmd>call planet#term#RunCmdAsk('Command: ')<CR>
    PlanetMenu an 550.10  💻&c.&Watch\ Command\.\.\.                   <Cmd>call planet#integrations#Ask(['watch', '-n0'], 'Command: ', [])<CR>
    PlanetMenu an 550.10  💻&c.--2-- <Nop>
    PlanetMenu an 550.10  💻&c.P&ython\ Shell                          <Cmd>botright terminal ++kill=kill ++rows=10 python<CR>
    PlanetMenu an 550.10  💻&c.&IPython\ Shell                         <Cmd>botright terminal ++kill=kill ++rows=10 ipython<CR>
    PlanetMenu an 550.10  💻&c.&bpython\ Shell                         <Cmd>botright terminal ++kill=kill ++rows=10 bpython<CR>
    PlanetMenu an 550.10  💻&c.C&++\ Shell                             <Cmd>botright terminal ++kill=kill ++rows=10 cling<CR>
    PlanetMenu an 550.10  💻&c.&Octave\ CLI                            <Cmd>botright terminal ++kill=kill ++rows=10 octave-cli<CR>
    PlanetMenu an 550.10  💻&c.Calculator\ (&bc)                       <Cmd>botright terminal ++kill=kill ++rows=10 bc<CR>
    PlanetMenu an 550.10  💻&c.--3-- <Nop>
    PlanetMenu an 550.10  💻&c.&Close\ Output                          <Cmd>call planet#term#CloseOutputWindow()<CR>
    PlanetMenu an 550.10  💻&c.Terminal\ List <Nop>
    an disable 💻&c.Terminal\ List
    PlanetMenu an 550.10  💻&c.Output\ List <Nop>
    an disable 💻&c.Output\ List
    planet#lsp_display#Menus()
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
  return 0
enddef
