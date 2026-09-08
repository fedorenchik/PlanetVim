# Release-candidate acceptance

This record covers PlanetVim **0.1.0-rc.1**, implemented on **2026-09-08** from baseline `f75c805a`. The source is a release candidate. Native Windows hosted CI and external SDK/target acceptance remain release gates; checked-in automation is not evidence that those jobs ran.

All original Linux/Windows menu actions remain in scope and enabled. Missing optional tools produce setup guidance. Third-party plugin source is unchanged; first-party adapters contain the compatibility fixes. The menu contract scan checks executable TODOs and unresolved first-party, legacy global, and vendor callbacks, including window bars in `.vimrc`.

## Platforms actually exercised

- **Linux, current local build:** Manjaro, kernel 6.18.45, x86_64, Intel Core 9 270H; GTK3 GVim 9.2.849, with jobs/terminal and Python support. Real GUI runs use a private Xvfb display.
- **Linux, minimum:** official Vim 9.1.0000 built with GTK3 and dynamic Python 3.12. The final complete GUI suite passed all 45 files with no skips, including real Python/C++ lifecycle tests and paused/running detach cases.
- **Windows compatibility:** official x64 GVim 9.2.1046 under Wine 11.15, with official portable Python 3.12.10. This is Windows executable compatibility evidence, not a native Windows desktop or hosted CI result. Startup, modes, font fallback, selection, filetypes, sessions, navigation, state/undo, command argv/status, menus, generation, writing, health, and SDK fixture actions were exercised. The disposable Wine wrapper unsets Linux `SHELL` and supplies Windows Python/GVim on WINEPATH.
- **Hosted CI configured:** Ubuntu 24.04 with pinned official GVim 9.1.0000 and 9.2.1046 sources; Windows 2022 with verified official 9.1.0 and 9.2.1046 GUI archives. Python uses the binaries' stable `python3.dll` ABI. See the exact source/action/archive pins in `.github/workflows/test.yml` and [PLUGINS.md](PLUGINS.md).

Windows Python completed a full durable installation under Wine, including its final manifest. After the path fixes, automatic Windows GUI startup passed against an installer-created payload copied using Linux filesystem I/O. This avoided repeating the slow Wine copy phase after the combined fixture exhausted its time limit; it is not reported as a passing single end-to-end Windows installer/startup run. The final copied-child checks cover plugin/after ordering, quoted/comma/Unicode paths, filetype hooks, theme, menus, Doctor, and installed help. Native Windows desktop and hosted CI remain release gates.

## Behavior verified

**Data preservation and installation:** cancelled/failed Save & Exit retains modified buffers; exact character/line/block selection export preserves unselected text; templates refuse nonempty destinations. Installer fixtures exercise clean/repeat install, update, failure rollback, dry-run, uninstall, and restore, including unrelated files, local modifications, spaces, apostrophes, and Unicode. Archive fixtures run the extracted installer's actual CLI through install → update → restore → uninstall.

Actual installed GVim startup also passes with spaces, commas, apostrophes, and Unicode in the installation and config/state/cache paths. It checks every bundled start package remains available, plugin loading happens once, package and root after hooks preserve order, filetype after hooks work, and built-in optional packages and installed help load. Windows retains its native filename rules; only Unix runtime lookup escapes apostrophes. Personal spelling tests use real `zg` writes and dictionary unload/reload through these paths, including writing-mode setup, cleanup, and an overridden dictionary.

Actual selection menu tests cover HTML export of character, line, block, Unicode, and Select-mode text, plus whole-document export without a selection. The HTML result is unnamed and saveable; source content, modified state, and registers remain unchanged. Range formatting uses current marks; Arduino baud setup validates input and cancellation. Select All is exercised from Normal and Insert menus into both Visual and Select modes. Automatic tag preview is toggled on/off/on through the actual menu with a real tags file; CursorHold updates the preview, disabling stops updates, and source focus/content and tag history remain intact.

**HEX editing:** real `xxd` round trips cover binary NUL/0xff, UTF-8, DOS/Mac line endings, UTF-16 with BOM, and empty files on Linux and Windows executables. Edited bytes, invalid/overlapping rows, conversion failures, stale source buffers, and size limits are checked without losing the original buffer.

Missing optional Git no longer triggers a blocking upstream startup warning. First-party defaults retain explicit GitGutter settings/custom executable paths, keep Git menu actions enabled, and leave dependency guidance in Doctor and the actions. Focused Linux/Windows checks cover unavailable Git, an available custom executable, and explicit on/off preferences.

**Configuration and recovery:** all three modes and override precedence, buffer-local mappings and cleanup, persistent preferences, independent closed-tab snapshots, session save variants, and GUI transfer acknowledgement were checked. Real disk writes create private backup/undo files; wiping/reopening the buffer restores undo history. Linux engine tests disable `lazyredraw` only for the undo assertion to avoid a Vim Ex-mode closed-stdin exit; real GUI tests retain the product setting.

**Commands and Git:** real console fixtures record exact argv, including quotes, Unicode, leading dashes, empty arguments, cwd, stdin, nonzero status, cancellation, and output retention. Windows empty-argument preservation has a native CreateProcess command-line workaround. Installer console-reporting fixtures cover Unicode paths under cp1252 on both stdout and stderr; reporting preserves success/failure status instead of aborting a valid transaction with an encoding error. Disposable Git repositories cover file commits, failed writes, opt-in auto-commit, special-character names/messages, notes/tags, rename/restore, stdin plumbing, and detached worktree creation/removal. Network operations and optional Git extensions use recorders, not live account writes.

**Projects and SDKs:** real CMake configure/build/CTest, Python unittest pass/fail, Qt Designer form/uic compilation, a UBSan build/run fixture, all six GLSL shader stages, and device-tree compilation passed. Every catalog scaffold is copied and checked for its expected files/formats; Qt model UUIDs differ between generated documents. SDK contracts additionally test native arguments, cancellation, missing prerequisites, failed environment activation, preserved output files, and sysroot propagation. The SDK recorder suite does not establish that every external SDK's installed version matches the contract.

Legacy project templates also compile with GCC 16.2.1/CMake 4.4.2: GTK 3.24.52, GLFW 3.5.1, SDL 2.32.70, SFML 3.1.0, GLEW 2.3.1, and Vulkan 1.4.357. These are compilation checks, not interactive GPU-rendering acceptance. Vue 3.5.42/Vite 8.2.2 and Electron 44.2.0/electron-builder 26.15.3 pass real build and lint with Node 26.7/npm 12.0.2 in disposable projects; Electron's Linux unpacked package was built. Direct dependencies and generated locks are checked in. The create-nuxt 3.37.0 positional-directory CLI contract was verified; full remote Nuxt generation and Windows Electron packaging were not run.

**Language intelligence:** real clangd 22.1.8 and pylsp 1.15.0 fixtures pass definitions, rename, formatting, diagnostics, and actual Insert-mode completion popup results. Real clangd also populates semantic scope locations through the actual menu action, and Analyze → Check opens source diagnostics. Semantic-token decoding covers UTF-8/16/32 positions and stale-buffer guards. Buffer/path completion and duplicate-source guards are checked independently. Server setup is separate from GVim startup.

**Debugging:** real debugpy 1.8.21 and GDB DAP fixtures launch, reach breakpoints, step, restart, stop, relaunch, and exit. Non-terminating detach is checked by observing the resumed target create a marker file. Missing providers/adapters are reported explicitly; skipped optional tests are labelled SKIP, never PASS. Linux CI requires the debugger fixtures rather than silently skipping them. Debugger logs remain private, including when lazy import fails. Quoted installation paths are covered by real Python detach acceptance; both plugin initialization and the first-party detach bridge restore Python import paths and bytecode settings after successful or failed imports.

**Writing and GUI:** Pandoc 3.11 builds a real Markdown HTML preview with tables, task lists, and an embedded local SVG. Real latexmk 4.88/pdfTeX 1.40.29 from TinyTeX 2026.09 builds both the article fixture and shipped multi-file book template. Tests verify PDF contents, exact viewer arguments, source navigation to an intentional line-4 error, stale-PDF rejection after failure, clean rebuild, and auxiliary files remaining in private cache. Translation fixtures test exact text, valid JSON, cancellation/timeouts, failure, private history, and refusing stale asynchronous replacement. Prose tests cover swaps, thesaurus, sample text, focus-mode restoration after asynchronous GUI resizing, and buffer safety. Real FFmpeg screenshot/GIF/H.264 capture and two-process GUI transfer/session launcher checks passed. Network translation engines, commercial recorders, and live kernel targets were not contacted.

LanguageTool 6.6 with Java 26.0.2.1 passes a real local grammar check, highlighting/location navigation, the public Grammarous replacement API, and repeated clean checks that clear old diagnostics. The first-party adapter converts the current JSON CLI to the bundled plugin's XML API, including UTF-16 offsets after emoji/accented text to Vim's UTF-8 byte columns. The upstream plugin is unchanged and does not download a JAR.

## Repeat the checks

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
python3 scripts/test.py
python3 scripts/test.py --gui --xvfb /path/to/Xvfb
python3 scripts/plugins.py inventory --check
```

The default per-file timeout is 60 seconds. `--timeout SECONDS` explicitly increases it for slow environments; the installed-startup fixture shares that overall deadline with its installer and child GVim. Wine performs considerably slower durable filesystem copies than the Linux host.

For real debugger acceptance, install a matching GVim Python provider, debugpy, a DAP-capable GDB, and g++. `PLANETVIM_REQUIRE_DEBUG_TESTS=1` turns absent prerequisites into failures. An existing debugpy adapter directory can be selected with `PLANETVIM_TEST_DEBUGPY_ADAPTER`.

Additional real-tool fixtures:

```sh
PLANETVIM_TEST_PYLSP=/path/to/pylsp python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/integration/lsp.vim
python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/integration/semantic.vim
PLANETVIM_REQUIRE_DEBUG_TESTS=1 python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/integration/debug_detach_quoted.vim
PLANETVIM_TEST_PANDOC=/path/to/pandoc python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/integration/markdown_preview.vim
PLANETVIM_TEST_LATEXMK=/path/to/latexmk python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/integration/latex_build.vim
PLANETVIM_TEST_LANGUAGETOOL_JAR=/path/to/languagetool-commandline.jar python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/integration/grammar_check.vim
python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/integration/gui_transfer.vim tests/integration/session_launcher.vim tests/integration/debug_test_tools.vim tests/integration/report_capture.vim
```

Use disposable projects and the documented fixtures. Kernel boot/debug, serial hardware, firmware upload, Docker/ROS/Yocto/Android deployments, commercial analyzers, remote CDash submissions, and cloud/network translation require their actual environments and explicit target selection. They have native command/preflight fixtures here, but no live-target acceptance claim.

## Performance

Full startup from a pre-vimrc hook through the first event-loop callback after VimEnter measured **1.187 seconds median** over five warm samples, range 1.176–1.289, on the Linux machine above with private Xvfb and all implemented menu groups. Process launch-through-exit was 1.398–1.520 seconds. This measured runtime commit `bbf7c307`; only this acceptance document was modified in the checkout. The local `dist/startup-linux-current.json` retains the exact samples and environment. An earlier work-in-progress baseline around `9192022f` was 1.254 seconds median. These host measurements remain below the 2-second budget and do not establish a portable speed claim.

The baseline regression budget is **2.0 seconds median on this machine and display setup**. Investigate a reproducible 25% slowdown even below that budget. Compare identical GVim/tool/plugin versions, one warmup plus five samples, and no concurrent compiler/test load. Measure with `python3 scripts/benchmark.py --runs 5 --xvfb /path/to/Xvfb`; store the JSON with the tested source commit. No plugin was hidden or removed to meet the budget.

## Final candidate record and release gates

Final verification on 2026-09-08 passed **45/45 GUI files on both Linux GVim 9.2.849 and 9.1.0000**, with zero skips, and **72 Python tests** with no skips (including 14 release tests and the available native template builds). Engine coverage passed 39 files, with five real-debugger files and the installed-startup file explicitly skipped because they require GUI mode. These results include selection, Arduino, semantic-scope, LanguageTool, quoted-path startup/detach/spelling, tag-preview, and Select All fixes. All 122 plugin inventory records match the checkout; the only changed package directory since the review baseline is the first-party `planet.vim` package.

The local `dist/PlanetVim-0.1.0-rc.1.manifest.json` records the exact clean source commit, version, file count, archive sizes, and SHA256 digests. The adjacent archive smoke record reports installation, installed GUI help/Doctor, generated CMake configure/build/CTest/run, update, restore, and uninstall results against that exact artifact. Packaging refuses a dirty checkout and does not upload or tag anything.

Three pinned upstream test/documentation submodules are not present in the vendored checkout and are explicitly excluded: EditorConfig's `tests/core/tests` and `tests/plugin/spec/plugin_tests`, and Emmet's `docs` website. Their full paths, exact commits, and reasons appear in `excluded_submodules` in the manifest. The plugin runtime, bundled Vim help, and available license notices are retained. Unknown submodules or changed pins fail packaging rather than disappearing silently.

The remaining local license evidence review was completed; the inventory now recognizes source-header and Vim-help notices and the owner-selected first-party license. The eight plugin-inventory tests passed. This maintenance-only change does not alter the previously tested GUI runtime or third-party snapshots.

The subsequent home-installation follow-up makes `make install` configure plain
GVim by default and keeps `make install-private` for separate launching. All 50
Linux installer tests passed, including 25 home-installation cases, plus the 14
release tests. Windows Python 3.12 under Wine passed 23 of the 25 home cases; two
symlink-privilege cases were explicitly skipped. Actual plain-GVim startup with
no `-u` option, package/after ordering, help, and restoration of the old vimrc
after uninstall passed on Linux GVim 9.2.849 and 9.1.0000. Private-launcher startup
also passed on both versions; help/configuration/menu checks passed on current
GVim. The GUI fixtures use an ordinary temporary HOME with a quoted, comma and
Unicode installation/config/state/cache path. Stock Vim can fail to parse a
comma-containing HOME in its system initialization before the home loader runs.
These focused checks extend the earlier full-suite record; a new full native
Windows GUI acceptance run is still required.

Before a public release, require successful hosted minimum/current Linux and native Windows jobs, a native Windows GUI acceptance run, resolution of the 22 upstream evidence items in [LICENSE_REVIEW.md](LICENSE_REVIEW.md), and live acceptance for any external SDK/target workflow advertised as fully validated. Keep those limitations visible in release notes. No public tag, push, or release publication is claimed by this local record.
