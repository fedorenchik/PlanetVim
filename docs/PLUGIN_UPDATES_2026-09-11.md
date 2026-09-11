# Plugin upgrade — 2026-09-11

Audited all **118 upstream packages**: **68 updated**, **50 already at the selected
revision**. The four first-party packages remain owned by PlanetVim. Each upstream
import has its own commit and matching inventory fingerprint.

Subsequent follow-up: the bundled `editorconfig-vim` snapshot was removed in
favor of Vim's distributed EditorConfig package. The audit below records the
completed upgrade; [plugins.json](plugins.json) tracks the current 117 upstream
packages plus four first-party packages.

## Selection and provenance

Prefer the latest numeric stable version tag. If a plugin has no such tag, pin
its maintained default branch. If its last version tag predates the bundled
revision, advance the default branch instead of downgrading to the older tag.
Branch snapshots are not described as published stable releases. In particular,
Vimspector publishes experimental/prerelease builds; this update pins its
maintained source, not a fabricated stable release. Published releases associated
with the 18 selected version tags were checked for draft/prerelease status;
several projects publish tags without GitHub release objects.

The [machine-readable ledger](plugin-updates-2026-09-11.json) records every old
and new commit, selection reason, and final snapshot hash. Every tracked upstream
file, executable mode, symlink, and gitlink was compared with the selected Git
object. All 118 snapshots match exactly, excluding generated `.gitrepo` metadata.
The original snapshots also matched their original pins. No local patches were
made to third-party source. Imports use the official git-subrepo 0.4.9 workflow.

## Compatibility changes

- **GVim 9.1.0016 is now the minimum**. VimTeX v2.18 uses `matchstrlist()`
  (added in 9.1.0009) and gates loading at 9.1.0016.
- Vimspector needs embedded **Python 3.10+**. PlanetVim imports its session manager
  before log initialization, passes session IDs during cleanup, and inspects the
  active session's threads when detaching. Generated GDB configurations start
  with exception filters off; existing project JSON is preserved.
- Crystalline's new callback and separator/highlight APIs replace the removed
  settings. Its module is preloaded with a temporarily scoped POSIX shell when
  Fish is selected, so installations containing apostrophes also start correctly.
- Clap search arguments now use `--query`. Its optional Maple binary remains
  optional: first-party provider hooks handle source palettes/files/buffers;
  asynchronous ripgrep JSON handles content search, cancellation, precise file
  selection, and invalid-regex feedback. Search displays up to 2,000 matches per
  query; refine the query to narrow a larger result set. The provider palette
  routes through the same fallback dispatch. Tags retain the Vista backend.
- Flog 3 needs **LuaJIT 2.1**. Selected-commit diff uses `flog#Format()` and
  `flog#ExecTmp()`. Automatic commit-graph cache writing is off by default: the
  initial interactive Fugitive job blocked graph creation in GUI acceptance.
  Git → Log → Build Commit Graph Cache performs that operation explicitly.
- vim-lsp's updated FileType handling needs an explicit buffer flush when a named
  buffer acquires its filetype after BufRead. Its duplicate GUI menus are removed
  after loading; all their actions are present in PlanetVim's existing LSP group.
  The upstream `LspShowSignature` menu typo is replaced by `LspSignatureHelp`.
- Direnv keeps manual commands but starts automatic exports only if its executable
  is available, unless the user explicitly configures `g:direnv_auto`.

## New discoverable actions

- **LSP:** document links, open link at cursor, signature help, stop all servers.
  Pull diagnostics are enabled for servers advertising the protocol; the user's
  `g:lsp_diagnostics_pull_enabled` setting takes precedence.
- **Debug:** continue/pause/steps, disassembly and instruction stepping, data
  breakpoints, exception filters, and independent session creation/switching/
  renaming/closing. Adapter-dependent actions report unsupported capabilities.
- **Writing → LaTeX:** continuous/single-shot/selected-line compilation, PDF
  viewer, errors, table of contents, list-environment toggle (`tse`), starred
  environment toggle (`tss`), and command line-break toggle (`tsb`). Compiler and
  viewer backends still require their separately installed tools.
- **File → File Manager Actions:** preview a selected file, recursively expand or
  collapse a tree, and paste with confirmation using Fern's action mappings.
- **Git → Log:** history in the current window layout through `Flogsplit`, plus
  explicit commit-graph cache generation.

Existing workflows also receive upstream improvements without extra menu rows:
new vim-test runners (including Node and Zig), language/syntax updates in vim-go,
C++, Flutter and Godot, completion fixes, and updated themes/icons.

Menu labels and tips use PlanetVim's existing teaching/hint system, including
emoji/plain/descriptive root styles and the single-group descriptive layout.

## Validation

- Actual Linux GUI suite: **74/74 files passed, zero skips**, on both the exact
  **9.1.0016** build and system **9.2.0849**, using private Xvfb displays and
  disposable profiles. The minimum build uses official Vim commit
  `124371c5a149a8c0c75c04b6c90ac11e71a0aa97`, GTK3 and embedded Python 3.12.
- `make test`: **105 Python tests passed, one skipped** (missing SFML development
  packages); **66/74 engine files passed**, with eight GUI-only files skipped.
  All eight run in the complete GUI suites above. The engine harness now starts
  in Normal mode so live Visual/Select callbacks report their actual mode.
  The seven fixtures affected by Ex-mode limitations also passed on 9.1.0016;
  the selection assertion was rechecked in the minimum GUI after that change.
- Debug acceptance uses real **debugpy 1.8.21** and **GDB DAP**, covering Python,
  C++, paused/running detach, sessions and assembly instruction stepping.
  A separate real **clangd + pylsp** integration passed. The LSP protocol fixture
  verifies pull diagnostics and document links with the actual bundled client.
- Integration checks exercise Flog graph creation and selected-commit diff,
  Fern preview/recursive expansion, VimTeX list/star/line-break edits and table
  of contents, and Clap files/buffers/provider palettes/content search without
  Maple. Search checks include opening a spaced filename at the exact column,
  invalid regex feedback, cleared filters and custom provider preservation.
- Private and default-home installation/startup/restore checks passed, including
  quoted and Unicode installation paths. All first-party Vim9 functions compile.
  Inventory: **122/122 package records match**, and all **118 upstream snapshots**
  match their selected Git objects exactly.

Maple acceleration and an external TeX compiler/PDF viewer were not exercised;
the core fallback pickers and VimTeX editing/navigation were. Optional SDKs and
adapters remain dependent on their external tools. Windows execution was outside
scope; its existing CI minimum archive was only refreshed to match the new
requirement. The hosted CI matrix has not been run by this local validation.

### Startup

Five interleaved warm-cache pairs on the same GVim 9.2.0849/Xvfb display measured
first-screen medians of **1.307 s before** and **1.344 s after** (about **+37 ms,
+2.8%**). Each revision used a separate menu cache, one excluded warmup, and a
fresh GVim process for every sample; pair order alternated. This host did not
demonstrate the 1.0-second target during these runs. Earlier unpaired batches
varied substantially, so they should not be treated as a controlled regression
comparison. The measured runtime is commit `10b17da63`; pending changes were docs.

Five updated runs with an empty PlanetVim cache measured **1.463 s** median to
the first screen. This empties the menu cache, not the operating system file
cache. The raw `last_vim_error` field retains the pre-existing suppressed default
menu cleanup message in both revisions; the benchmark checks visible messages,
exit status and the completed first-screen marker.

Raw measurements: [initial baseline](benchmarks/plugins-2026-09-11-before.json),
[initial updated batch](benchmarks/plugins-2026-09-11-after.json),
[interleaved comparison](benchmarks/plugins-2026-09-11-paired.json),
[empty menu cache](benchmarks/plugins-2026-09-11-empty-cache.json).

## Selected snapshots

Each link identifies the exact source object; the ledger above includes full old
commits and why a branch or release was selected.

- **asyncomplete-buffer.vim** — master, [`a7afcf4f1f`](https://github.com/prabirshrestha/asyncomplete-buffer.vim/tree/a7afcf4f1f0ee8beaec4b3a20d814160ab097d8d); updated.
- **asyncomplete-emmet.vim** — master, [`5c65b7693a`](https://github.com/prabirshrestha/asyncomplete-emmet.vim/tree/5c65b7693a1fc75f1b596e2763d27ca95a749da9); unchanged.
- **asyncomplete-emoji.vim** — master, [`a2856274cc`](https://github.com/prabirshrestha/asyncomplete-emoji.vim/tree/a2856274cc719c61f09884ab1eeafffb487c67ea); unchanged.
- **asyncomplete-file.vim** — master, [`770772daf1`](https://github.com/prabirshrestha/asyncomplete-file.vim/tree/770772daf1ff6ae29193bed02f8a7907913415d3); unchanged.
- **asyncomplete-gitcommit** — master, [`68b35a7537`](https://github.com/laixintao/asyncomplete-gitcommit/tree/68b35a7537326d5b21bb61c7cf5d981d425d2f5f); unchanged.
- **asyncomplete-look** — master, [`61a3f69bd6`](https://github.com/htlsne/asyncomplete-look/tree/61a3f69bd67f808fbfa6f1e96cb2886eb0977955); unchanged.
- **asyncomplete-lsp.vim** — master, [`7cf65e7661`](https://github.com/prabirshrestha/asyncomplete-lsp.vim/tree/7cf65e7661a6047f02bd1848ad30581d040896e5); updated.
- **asyncomplete-necosyntax.vim** — master, [`1bd7345ec5`](https://github.com/prabirshrestha/asyncomplete-necosyntax.vim/tree/1bd7345ec5408b2c7d926b85148dc96e207eaf8c); unchanged.
- **asyncomplete-necovim.vim** — master, [`e45d586731`](https://github.com/prabirshrestha/asyncomplete-necovim.vim/tree/e45d58673100b5653d9c2dc823f914190c64aaa0); unchanged.
- **asyncomplete-neoinclude.vim** — master, [`26c6767110`](https://github.com/kyouryuukunn/asyncomplete-neoinclude.vim/tree/26c676711087e3bd80e398a49f9cb6692b2799e8); unchanged.
- **asyncomplete-omni.vim** — master, [`f13986b671`](https://github.com/yami-beta/asyncomplete-omni.vim/tree/f13986b671a37d6320476af6bc066697e71463c1); unchanged.
- **asyncomplete-tabnine.vim** — master, [`a2c09959f9`](https://github.com/kitagry/asyncomplete-tabnine.vim/tree/a2c09959f9f9fd23a3475cd4756c68cd7a29ae80); unchanged.
- **asyncomplete-tags.vim** — master, [`e458dc448b`](https://github.com/prabirshrestha/asyncomplete-tags.vim/tree/e458dc448b40d69eb1d4722fa30ce848521bd3d0); updated.
- **asyncomplete-user.vim** — master, [`960496266b`](https://github.com/jsit/asyncomplete-user.vim/tree/960496266b1dd8218efd83785dd22b3221c1ddd7); unchanged.
- **asyncomplete.vim** — master, [`17b654a87a`](https://github.com/prabirshrestha/asyncomplete.vim/tree/17b654a87a834d4e835fb7467e562b4421ad9310); updated.
- **auto-git-diff** — master, [`8d5ba42521`](https://github.com/hotwatermorning/auto-git-diff/tree/8d5ba425218912db0d960ba0bd0a1b39d14082b7); updated.
- **calculator.vim** — v1.0, [`7725539706`](https://github.com/fedorenchik/calculator.vim/tree/7725539706f60960365c7b1861c9bda28ed48f3e); unchanged.
- **calendar.vim** — master, [`2ef5b0a271`](https://github.com/itchyny/calendar.vim/tree/2ef5b0a2717d8a2ea24c55d11e426f25e6243282); updated.
- **caw.vim** — master, [`748f15cde4`](https://github.com/tyru/caw.vim/tree/748f15cde4e9ba9ce4723fddf48703d2e97790de); updated.
- **codi.vim** — master, [`83b9859aaf`](https://github.com/metakirby5/codi.vim/tree/83b9859aaf8066d95892e01eb9c01571a4b325dd); updated.
- **Colorizer** — master, [`f5d69c0dea`](https://github.com/chrisbra/Colorizer/tree/f5d69c0dea9f36e2eb025c7d86cc62b5a0d8af62); updated.
- **committia.vim** — master, [`c8c0f255e8`](https://github.com/rhysd/committia.vim/tree/c8c0f255e8090ed90dd9d5dd2e8672994f8e3671); updated.
- **context_filetype.vim** — 1.0, [`e276626e44`](https://github.com/Shougo/context_filetype.vim/tree/e276626e441eee2c624b9192113f1484bc2bc0f3); unchanged.
- **csv.vim** — master, [`375c1a81a4`](https://github.com/chrisbra/csv.vim/tree/375c1a81a4f186ce8949824f3b87ddc6727a63af); updated.
- **dart-vim-plugin** — master, [`13fa42674f`](https://github.com/dart-lang/dart-vim-plugin/tree/13fa42674f1685a1c5a095c1dac74d94e43a9849); updated.
- **direnv.vim** — master, [`ab2a7e08dd`](https://github.com/direnv/direnv.vim/tree/ab2a7e08dd630060cd81d7946739ac7442a4f269); updated.
- **DoxygenToolkit.vim** — main, [`4c1e3380df`](https://github.com/babaybus/DoxygenToolkit.vim/tree/4c1e3380df7a8f5941ad20274615dcb8f31582aa); updated.
- **dracula** — master, [`e7817b4bac`](https://github.com/dracula/vim/tree/e7817b4baccfb3529f709ac048c621f35cdbc5b3); updated.
- **editorconfig-vim** — v1.2.1, [`3c2813f256`](https://github.com/editorconfig/editorconfig-vim/tree/3c2813f2566d9392ff3614248c5db43c3fda9d5f); updated.
- **emmet-vim** — master, [`92ef2f74f4`](https://github.com/mattn/emmet-vim/tree/92ef2f74f4093edc99db5e9e4cf7e40116a85bd6); updated.
- **fasm.vim** — master, [`6eabe66b85`](https://github.com/fedorenchik/fasm.vim/tree/6eabe66b8527cc8fae6671ec61056cbc81a5fa95); unchanged.
- **FastFold** — master, [`c1ddfa1a0e`](https://github.com/Konfekt/FastFold/tree/c1ddfa1a0e00316d1161ce11438ec980348b8cb9); updated.
- **fern-bookmark.vim** — master, [`34692709e0`](https://github.com/lambdalisue/fern-bookmark.vim/tree/34692709e034548c7be37ed417807c1d76a27600); unchanged.
- **fern-git-status.vim** — v0.4.0, [`151336335d`](https://github.com/lambdalisue/fern-git-status.vim/tree/151336335d3b6975153dad77e60049ca7111da8e); unchanged.
- **fern-hijack.vim** — v1.0.5, [`f655248992`](https://github.com/lambdalisue/fern-hijack.vim/tree/f65524899231b15528066744e714fb344abf0892); updated.
- **fern-mapping-git.vim** — master, [`df5e7466df`](https://github.com/lambdalisue/fern-mapping-git.vim/tree/df5e7466df8596c95dd355d49a72893018919cf1); unchanged.
- **fern-renderer-nerdfont.vim** — master, [`325629c68e`](https://github.com/lambdalisue/fern-renderer-nerdfont.vim/tree/325629c68eb543229715b68920fbcb92b206beb6); updated.
- **fern-ssh.vim** — master, [`87e563c820`](https://github.com/lambdalisue/fern-ssh/tree/87e563c8200e9dd4f85174c784028214cbfdd3e4); unchanged.
- **fern.vim** — v1.59.2, [`fd03997971`](https://github.com/lambdalisue/fern.vim/tree/fd039979718b608a7c5912f163a07b230da1b5f4); updated.
- **FoldText** — master, [`bb17060d33`](https://github.com/Konfekt/FoldText/tree/bb17060d3373b63fc5b127136c10b6d1616ebcd9); updated.
- **glyph-palette.vim** — v1.6.0, [`1ee16c232c`](https://github.com/lambdalisue/glyph-palette.vim/tree/1ee16c232c5538f34bb47c3dd0f6b369fdd7c555); updated.
- **goyo.vim** — master, [`9c72fdf2d2`](https://github.com/junegunn/goyo.vim/tree/9c72fdf2d202914318581f9f0dd09fd102f8504d); updated.
- **gruvbox** — master, [`5d15b2765f`](https://github.com/morhetz/gruvbox/tree/5d15b2765f59754d7ac263c88a0f6e3e58124951); updated.
- **Jenkinsfile-vim-syntax** — master, [`0d05729168`](https://github.com/martinda/Jenkinsfile-vim-syntax/tree/0d05729168ea44d60862f17cffa80024ab30bcc9); unchanged.
- **libview.vim** — master, [`5c56a2071c`](https://github.com/fedorenchik/libview.vim/tree/5c56a2071c30648a6b5dd60669df7a547f0bc9f3); unchanged.
- **molokai** — master, [`c67bdfcdb3`](https://github.com/tomasr/molokai/tree/c67bdfcdb31415aa0ade7f8c003261700a885476); unchanged.
- **neco-syntax** — master, [`f8d7b748b0`](https://github.com/Shougo/neco-syntax/tree/f8d7b748b022aac8ce73458574da5616f1c5fb65); unchanged.
- **neco-vim** — master, [`7b722cd13a`](https://github.com/Shougo/neco-vim/tree/7b722cd13a44645e4ed9b1e4fe6ff8ad64f947f6); updated.
- **neoinclude.vim** — master, [`954cfc9dfd`](https://github.com/Shougo/neoinclude.vim/tree/954cfc9dfdb303f2c2fa867b9cf949dd74512628); unchanged.
- **nerdfont.vim** — v1.13.1, [`83cec2786e`](https://github.com/lambdalisue/nerdfont.vim/tree/83cec2786e00c0c132a19c2e181fe810a3f99802); updated.
- **papercolor-theme** — master, [`0cfe64ffb2`](https://github.com/NLKNguyen/papercolor-theme/tree/0cfe64ffb24c21a6101b5f994ca342a74c977aef); updated.
- **presenting.vim** — master, [`b5f2447771`](https://github.com/sotte/presenting.vim/tree/b5f24477718ee6fb6ae0fa888270c83baa81c9aa); updated.
- **python-syntax** — master, [`2cc00ba729`](https://github.com/vim-python/python-syntax/tree/2cc00ba72929ea5f9456a26782db57fb4cc56a65); unchanged.
- **QFEnter** — 2.4.3, [`fd5d378f97`](https://github.com/yssl/QFEnter/tree/fd5d378f97ee4847ce4fcb58b3719864228607da); updated.
- **qt-support.vim** — master, [`c353804b35`](https://github.com/fedorenchik/qt-support.vim/tree/c353804b35a006531990191ae975b793d2836092); unchanged.
- **spelunker.vim** — master, [`a0bc530f62`](https://github.com/kamykn/spelunker.vim/tree/a0bc530f62798bbe053905555a4aa9ed713485eb); unchanged.
- **tabman.vim** — master, [`8f2ca9268a`](https://github.com/kien/tabman.vim/tree/8f2ca9268a2ec1bcb29231b5b3f872101d169901); unchanged.
- **typescript-vim** — master, [`4740441db1`](https://github.com/leafgarland/typescript-vim/tree/4740441db1e070ef8366c888c658000dd032e4cb); updated.
- **undotree** — master, [`6fa6b57cda`](https://github.com/mbbill/undotree/tree/6fa6b57cda8459e1e4b2ca34df702f55242f4e4d); updated.
- **vim-abolish** — v1.2, [`880a562ff9`](https://github.com/tpope/vim-abolish/tree/880a562ff9176773897930b5a26a496f68e5a985); updated.
- **vim-arduino** — master, [`2ded67cdf0`](https://github.com/stevearc/vim-arduino/tree/2ded67cdf09bb07c4805d9e93d478095ed3d8606); updated.
- **vim-autocorrect** — master, [`28ef54d5cd`](https://github.com/panozzaj/vim-autocorrect/tree/28ef54d5cdd2d1021d54c90d80eb1a7d02fb58bc); unchanged.
- **vim-bitbake** — master, [`e75f8ea12b`](https://github.com/kergoth/vim-bitbake/tree/e75f8ea12b4a0bcfe46c564a3a78ff7361b0a1c6); updated.
- **vim-buffest** — master, [`6ed80444d6`](https://github.com/rbong/vim-buffest/tree/6ed80444d687cbcb11dcbe83dd94ec9888329f1b); updated.
- **vim-c-posix-syntax** — master, [`4a09bafaf0`](https://github.com/t6tn4k/vim-c-posix-syntax/tree/4a09bafaf0453d267424ee1a213474519d5b08ac); unchanged.
- **vim-capslock** — master, [`2bd1d47d35`](https://github.com/tpope/vim-capslock/tree/2bd1d47d35ac489b150d284141b6dce743a307f5); updated.
- **vim-choosewin** — master, [`839da609d9`](https://github.com/t9md/vim-choosewin/tree/839da609d9b811370216bdd9d4512ec2d0ac8644); unchanged.
- **vim-clap** — v0.55, [`8d5ed041c8`](https://github.com/liuchengxu/vim-clap/tree/8d5ed041c8f583193c5268ee2fd5b46e3694b2fc); updated.
- **vim-cmake-help** — master, [`db706c61ea`](https://github.com/bfrg/vim-cmake-help/tree/db706c61eac8a073feea2469a3de1619da27b8f3); updated.
- **vim-colors-solarized** — master, [`528a59f26d`](https://github.com/altercation/vim-colors-solarized/tree/528a59f26d12278698bb946f8fb82a63711eec21); unchanged.
- **vim-cpp-modern** — master, [`b194a25209`](https://github.com/bfrg/vim-cpp-modern/tree/b194a25209ed99ae73175cc5cbc94b2d5684f657); updated.
- **vim-crystalline** — 1.1.4, [`44f4340d27`](https://github.com/rbong/vim-crystalline/tree/44f4340d274accbea2bd31a91d55554089dddab0); updated.
- **vim-dirdiff** — master, [`84bc8999fd`](https://github.com/will133/vim-dirdiff/tree/84bc8999fde4b3c2d8b228b560278ab30c7ea4c9); unchanged.
- **vim-dotenv** — master, [`5c51cfcf8d`](https://github.com/tpope/vim-dotenv/tree/5c51cfcf8d87280d6414e03cd6b253eb70ecb800); unchanged.
- **vim-eunuch** — master, [`9294909377`](https://github.com/tpope/vim-eunuch/tree/929490937745cd96130d3e7948f762f0aa403314); updated.
- **vim-flog** — v3.0.0, [`e7a0e9f6f2`](https://github.com/rbong/vim-flog/tree/e7a0e9f6f26d154b1e550de94414ea71e354c563); updated.
- **vim-flutter** — master, [`2c528672b0`](https://github.com/thosakwe/vim-flutter/tree/2c528672b0b8a21875689389bc3eb22678e8d983); updated.
- **vim-fugitive** — master, [`3b753cf8c6`](https://github.com/tpope/vim-fugitive/tree/3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0); updated.
- **vim-gitgutter** — main, [`90b75207bd`](https://github.com/airblade/vim-gitgutter/tree/90b75207bd9b55d8ac4af15f72b4e935462014d0); updated.
- **vim-glsl** — master, [`40dd0b143e`](https://github.com/tikhomirov/vim-glsl/tree/40dd0b143ef93f3930a8a409f60c1bb85e28b727); updated.
- **vim-go** — v1.29, [`afdc935356`](https://github.com/fatih/vim-go/tree/afdc93535605efaa4624b4dde296961add89750f); updated.
- **vim-godot** — master, [`2cecd0c83a`](https://github.com/habamax/vim-godot/tree/2cecd0c83a7b3f012142a584d53a3a51be246c8e); updated.
- **vim-grammarous** — master, [`db46357465`](https://github.com/rhysd/vim-grammarous/tree/db46357465ce587d5325e816235b5e92415f8c05); unchanged.
- **vim-grepper** — master, [`74284df0ab`](https://github.com/mhinz/vim-grepper/tree/74284df0abf7c3f9d57e3416129dbeeba36dc86b); updated.
- **vim-ingo-library** — 1.048, [`8b1cbb1d56`](https://github.com/inkarkat/vim-ingo-library/tree/8b1cbb1d5620a65c129ddcf1854b26999a5ad06f); updated.
- **vim-json** — master, [`3727f08941`](https://github.com/elzr/vim-json/tree/3727f089410e23ae113be6222e8a08dd2613ecf2); unchanged.
- **vim-log-highlighting** — master, [`1037e26f31`](https://github.com/MTDL9/vim-log-highlighting/tree/1037e26f3120e6a6a2c0c33b14a84336dee2a78f); unchanged.
- **vim-lsp** — master, [`bbffa60cb0`](https://github.com/prabirshrestha/vim-lsp/tree/bbffa60cb08a6a2d67e2086a89699ab00a084fe9); updated.
- **vim-lsp-settings** — master, [`c61a46e4cc`](https://github.com/mattn/vim-lsp-settings/tree/c61a46e4cc31ec58159d3908e5b1f1003923990b); updated.
- **vim-mark** — 3.4.0, [`9a5d6c403d`](https://github.com/inkarkat/vim-mark/tree/9a5d6c403d6eb7b842de27a158418740cef364ec); updated.
- **vim-markdown-preview** — master, [`9b3ec41fb6`](https://github.com/JamshedVesuna/vim-markdown-preview/tree/9b3ec41fb6f0f49d9bb7ca81fa1c62a8a54b1214); unchanged.
- **vim-one** — master, [`187f5c85b6`](https://github.com/rakr/vim-one/tree/187f5c85b682c1933f8780d4d419c55d26a82e24); unchanged.
- **vim-qf** — master, [`7cafff6a9e`](https://github.com/romainl/vim-qf/tree/7cafff6a9e0a1b54364b26a87f1efe749f8fb96b); updated.
- **vim-qf-preview** — master, [`4e6a43ddba`](https://github.com/bfrg/vim-qf-preview/tree/4e6a43ddbab7ebf3c586734727b1ef75155d4c3b); updated.
- **vim-quickui** — 1.5.6, [`0726a99a76`](https://github.com/skywind3000/vim-quickui/tree/0726a99a76fbfec6fe1f78891cc616eb27540bd9); updated.
- **vim-repeat** — master, [`65846025c1`](https://github.com/tpope/vim-repeat/tree/65846025c15494983dafe5e3b46c8f88ab2e9635); updated.
- **vim-scriptease** — v1.1, [`18511d3896`](https://github.com/tpope/vim-scriptease/tree/18511d389675d773994215ddb572ccdc2b72f52b); unchanged.
- **vim-signature** — master, [`6bc3dd1294`](https://github.com/kshenoy/vim-signature/tree/6bc3dd1294a22e897f0dcf8dd72b85f350e306bc); unchanged.
- **vim-sleuth** — v2.0, [`1d25e8e5dc`](https://github.com/tpope/vim-sleuth/tree/1d25e8e5dc4062e38cab1a461934ee5e9d59e5a8); unchanged.
- **vim-SpellCheck** — 2.01, [`c479d16c66`](https://github.com/inkarkat/vim-SpellCheck/tree/c479d16c6682110237304796a8095c5eab0def12); updated.
- **vim-startify** — master, [`4e089dffda`](https://github.com/mhinz/vim-startify/tree/4e089dffdad46f3f5593f34362d530e8fe823dcf); updated.
- **vim-surround** — master, [`3d188ed211`](https://github.com/tpope/vim-surround/tree/3d188ed2113431cf8dac77be61b842acb64433d9); updated.
- **vim-test** — v3.3.1, [`2676d84c69`](https://github.com/janko/vim-test/tree/2676d84c6901e484df00b5d728bd6a345d47ee12); updated.
- **vim-translator** — master, [`67457d5ab9`](https://github.com/voldikss/vim-translator/tree/67457d5ab92a9d022f466df7e4a578a129207aa2); updated.
- **vim-twiggy** — master, [`32a2b9a022`](https://github.com/sodapopcan/vim-twiggy/tree/32a2b9a0222fa6afd374c8345f7cfa305f3b1655); updated.
- **vim-unimpaired** — v2.1, [`efdc6475f7`](https://github.com/tpope/vim-unimpaired/tree/efdc6475f7ea789346716dabf9900ac04ee8604a); unchanged.
- **vim-unityengine** — master, [`074c80b0dc`](https://github.com/idbrii/vim-unityengine/tree/074c80b0dc8ede7a5e98446ca8f83a17d020f3ce); unchanged.
- **vim-unreal** — main, [`0885fa2e87`](https://github.com/drichardson/vim-unreal/tree/0885fa2e87aa3b3d70aa20e903acf57c2ed5802d); unchanged.
- **vim-verbosity** — master, [`7993c12a7f`](https://github.com/MTDL9/vim-verbosity/tree/7993c12a7fe36cb60e1d89872d895273485b2626); unchanged.
- **vim-visualrepeat** — 1.33, [`e8d632229b`](https://github.com/inkarkat/vim-visualrepeat/tree/e8d632229bf581cad58ff5f832ef900307d099ef); updated.
- **vim-window-mode** — master, [`dd621d166b`](https://github.com/MTDL9/vim-window-mode/tree/dd621d166bc726d22014696f54ba3f6e3230b851); unchanged.
- **vim-wordy** — master, [`590927f572`](https://github.com/reedes/vim-wordy/tree/590927f57277666e032702b26e4e0c82717cc3cb); unchanged.
- **vimspector** — master, [`34099d18d8`](https://github.com/puremourning/vimspector/tree/34099d18d8957bb3db5f396c8ca993ffb246a437); updated.
- **vimtex** — v2.18, [`cb1374f1f3`](https://github.com/lervag/vimtex/tree/cb1374f1f3f9717ea91787c54dc11031d673aea5); updated.
- **vinarise.vim** — master, [`84dd647932`](https://github.com/Shougo/vinarise.vim/tree/84dd647932fbd029310cca31f417c42f56d60547); unchanged.
- **vista.vim** — master, [`1e90efad6e`](https://github.com/liuchengxu/vista.vim/tree/1e90efad6e32c4f7d16b1ca8f49bf63d0693802e); updated.
- **w3m.vim** — master, [`228a852b18`](https://github.com/yuratomo/w3m.vim/tree/228a852b188f1a62ecea55fa48b0ec892fa6bad7); unchanged.
- **yoctolog.vim** — master, [`614be65c1c`](https://github.com/arnstein/yoctolog.vim/tree/614be65c1c0bc93643e618da6aa26961cad0fe00); unchanged.
