# PlanetVim guide

Start with `:PlanetDoctor`, `:PlanetLspStatus`, and `:PlanetVersion`. Doctor reports prerequisites without launching SDKs or adapters. An executable being present does not prove its version, credentials, or target configuration is usable. The [acceptance record](ACCEPTANCE.md) separates those checks from real workflow tests.

Git is optional for basic editing. Git menu actions remain available and report missing prerequisites; gutter change indicators start automatically when Git is available. You can set `g:gitgutter_git_executable` to a custom Git executable or explicitly set `g:gitgutter_enabled`. Restart PlanetVim after installing Git or changing its executable path.

## Menu styles

Use **PlanetVim → Menu Style** to choose **Emoji** (the default compact roots),
**Plain** (compact keyboard letters), or **Descriptive** (File, Edit, and so on).
Descriptive mode shows one group at a time. Choose Basic, Editing, Development,
Tools, Navigation, or Settings from PlanetVim to switch groups. PlanetVim is
always visible, and both your style and selected group survive a restart.
In compact styles the same group entries toggle groups independently.

## Home startup and recovery

`make install` (or `python3 scripts/install.py install`)
installs a managed `~/.vimrc` loader on Linux so plain `/usr/bin/gvim` loads
PlanetVim. Windows uses `$HOME/_vimrc`, with HOME taking precedence over the user
profile, and `py -3` instead of `python3`. If the alternate home `_vimrc` (Linux)
or `.vimrc` (Windows) is already in use, that file is managed instead.
The distribution stays in its private
prefix; your existing `.vim` or `vimfiles` directory is not replaced.

Run `make preview` first to inspect the exact paths. Use `PREFIX="/path"`
with Make, or `--prefix "/path"` with Python, consistently for a custom private
installation. The same installation can be switched from private launching to
home startup by running `install` again; future update/uninstall operations
remember the mode. Always run them under the same user/HOME. `install-home` and
`preview-home` remain explicit aliases. For separate launching only, use
`make install-private` / `make preview-private`, or add `--private` to the Python
install command. To switch an existing home installation to private launching,
uninstall first to restore the old configuration, then install privately.

The original startup file's bytes and permissions, or its symlink itself, are
backed up before replacement. A symlink's target is not modified. The original
backup remains available across updates. `make uninstall` restores the original
file/link or removes the generated loader when no original existed. `make restore`
undoes the latest transaction, including the home startup change. Payload and
home changes share one journal and rollback; backups remain under the private
prefix's `.planetvim/backups` directory.

Put PlanetVim customizations in its private `planetvimrc.vim`, not in the managed
home loader. Update refuses to replace an edited loader. Uninstall preserves an
edited/replaced loader and reports the original backup for manual recovery.
Restore also refuses conflicting edits to the home startup file. Keep that backup
directory until you have recovered any configuration you want to retain.

Repeated installation of an already managed PlanetVim updates its files and
retains the original pre-PlanetVim backup. A recognized older, unmanaged PlanetVim
vimrc is replaced as an update: its snapshot is kept for explicit rollback, but
uninstall does not restore that old PlanetVim vimrc as personal configuration.
No earlier personal configuration can be recovered unless it was backed up.
Legacy plugin files outside the private prefix remain untouched and are not
claimed by this installer. A managed loader from another prefix is reported;
use that prefix to update/uninstall it instead of taking over its backup history.

The loader selects PlanetVim only when GVim starts in GUI mode. Otherwise it
sources the previous configuration when available. A regular previous vimrc is
sourced from its backup location; configurations that derive relative paths from
`<sfile>` should use an explicit home/dotfiles path. Existing `.gvimrc`/`_gvimrc`
files still run afterward according to GVim's normal startup rules. `VIMINIT`
overrides home vimrc discovery, so installing this mode reports it and requires it
to be unset. Explicit `gvim -u ...` and `gvim --clean` still bypass the home loader.
Stock Vim/system startup must be able to read HOME before the loader runs;
comma-containing HOME paths can fail in that earlier runtimepath lookup on Linux.

## Editing modes

The PlanetVim menu selects and saves the mode:

- **Standard (`s`)** uses normal Vim modal editing and is the default.
- **Easy (`e`)** starts in Insert mode, allows mouse/shifted-key selection, and replaces selected text while typing. Use `Ctrl-O` for one Normal command or `Ctrl-L` to leave Insert mode; see `:help 'insertmode'`.
- **Supercharged (`p`)** changes Normal navigation: `f/F` search one character forward/backward, `t/T` search a two-character sequence, `w/b` repeat the one-character search, and `l/h` repeat the sequence search. `j/k` navigate location-list files; `W/B` switch buffers, `e/E` follow changes, and `ge/gE` select the first/last tab. Other Vim commands remain available through menus.

Custom mappings are retained when leaving a mode unless they still contain that mode's own mapping. Explicitly selecting a mode applies its mode-specific options. Put desired persistent overrides in the custom config and call `planet#planet#SetMode()` there before those overrides if changing modes programmatically.

## Configuration and state

Linux defaults:

- Configuration: `$XDG_CONFIG_HOME/planetvim`, or `~/.config/planetvim`.
- State: `$XDG_STATE_HOME/planetvim`, or `~/.local/state/planetvim`.
- Cache: `$XDG_CACHE_HOME/planetvim`, or `~/.cache/planetvim`.

Windows defaults are `%LOCALAPPDATA%\PlanetVim\config`, `state`, and `cache`. Override with `PLANETVIM_CONFIG_DIR`, `PLANETVIM_STATE_DIR`, and `PLANETVIM_CACHE_DIR` before launch. Explicit early Vimscript globals `g:PV_config_dir`, `g:PV_state_dir`, and `g:PV_cache_dir` take priority.

The editable config is `planetvimrc.vim` in the config directory. The PlanetVim menu opens it. Initialization applies distribution defaults, saved mode/menu preferences, the selected mode, then your config. It runs the custom file once. Generated `preferences.json` is separate from your script. Preference writes merge the current file and atomically replace it; simultaneous writes to the same preference use the last completed writer, and are not a cross-process settings transaction.

Example customization:

```vim
set expandtab shiftwidth=4 softtabstop=4
if has('win32')
  set guifont=Consolas:h11
else
  set guifont=Monospace\ 11
endif
nnoremap <leader>w <Cmd>write<CR>
let g:PV_clangd_argv = ['clangd', '--background-index']
let g:PV_pylsp_argv = ['/path/to/venv/bin/pylsp']
let g:PV_writing_auto_open = 0
```

Use a font installed on the current machine. The Windows default tries Consolas, Liberation Mono, then Courier New; it retains GVim's default if all fail. `:PlanetPlainMenus` translates emoji roots to readable labels. Fern uses its plain renderer by default.

Private state includes backups, swap, undo, views, sessions, project build/run choices, and debugger logs. Cache contains disposable preview/build intermediates and GUI-transfer snapshots. Personal spelling remains outside the installation: ordinary buffers use config `spell/`; writing buffers use state `spell/`, or your `g:PV_personal_spell_file`. Updates do not erase these directories.

## Projects, output, and tests

A tab's working directory identifies its project. Select it with `:tcd /path/to/project`. A window-local `:lcd` does not switch the tab's build/run profile. CMake build directories and run profiles are stored per project, so switching tabs/projects does not reuse another project's output tree.

The File menu creates a template only in a new or empty destination. Cancel creates nothing. Hidden files and binary files are copied; existing nonempty output is preserved. Electron/Vue dependency installation is explicit. Nuxt invokes an installed creator and reports its result. Generated README/build files describe the next steps.

Build → CMake can create/select a directory, configure, build/rebuild, open GUI/TUI configuration, and generate a compilation database. Build prerequisites must succeed before dependent steps run. Run → Add Configuration accepts an object such as:

```json
{"name":"application","argv":["./build/hello","argument with spaces","a,b"],"cwd":"."}
```

`argv` executes directly. `command` is an alternative for a deliberately requested shell script; supply exactly one. On Windows, point to the native executable and its actual configuration directory.

Each output buffer shows the command, cwd, and real exit status. It remains open after failure. `:PlanetCommandResult` reports the current buffer's result; `:PlanetCommandCancel` stops its running child. The Terminal menu lists outputs. Its Previous/Next window-bar actions switch between terminal buffers.

`:PlanetTest nearest`, `file`, `class`, `suite`, `last`, and `visit` connect vim-test to PlanetVim's retained-output runner. Last/Visit use the current project's history. A Python `unittest` example is included in the Python template. CTest and other framework-specific entries run their own tools. Google Test, Boost.Test, Catch2, QtTest, kernel tests, and CDash require their selected binaries/source trees; CDash stages are explicitly selected.

## Language intelligence

C/C++ use clangd and Python uses pylsp by default, with asyncomplete's LSP, buffer, and file sources. A missing server leaves buffer/path completion available. Configure `g:PV_clangd_argv` or `g:PV_pylsp_argv` as an argv List; an empty List opts out of that server. Restart GVim after changing a registered server command. `g:PV_pylsp_settings` supplies pylsp workspace settings. Install `python-lsp-server[all]` in a separate environment if its diagnostics and formatting plugins are needed.

Create `compile_commands.json` for C++ projects and make it discoverable by clangd. For an out-of-tree database, configure clangd's `--compile-commands-dir=/absolute/build/path` in its argv. Project roots are detected from language/build markers and Git directories.

Supported actions are `:PlanetDefinition`, `:PlanetReferences`, `:PlanetHover`, `:PlanetRename`, `:PlanetFormat`, and `:PlanetDiagnostics`. C/C++/Python buffers also get local `gd`, `gr`, `gi`, `gy`, `K`, `<leader>rn`, `<leader>f`, `[d`, and `]d` mappings. Their cleanup restores previous buffer-local mappings. Other bundled language plugins retain their own setup and commands.

LSP → Document Semantic Scopes (`:PlanetSemanticScopes`) requests semantic tokens and opens their types, modifiers, and source locations. It needs a server with full semantic-token support, such as clangd; pylsp normally does not provide this capability. Analyze → Check shows the current document's language-server diagnostics. Both actions report missing server support when unavailable.

Modify → Snippets inserts a filetype-specific snippet and prompts for its fields before changing the buffer. Edit Custom Snippets opens a private JSON object mapping names to arrays of lines. `${field}` prompts once per field; `${cursor}` sets the final cursor. Example:

```json
{"greeting":["Hello ${name}!${cursor}"]}
```

Custom names override built-ins for that filetype. Emmet expands the abbreviation at the cursor through the bundled plugin.

Modify → HEX Mode uses the native `xxd` tool. Entering and leaving HEX preserves the original encoding, line endings, BOM, and bytes, including binary NULs. Edit the hexadecimal byte columns; the readable ASCII column is informational. Invalid or overlapping rows and failed conversions keep the HEX buffer available. The decoded size limit is 64 MiB by default; set `g:PV_hex_max_bytes` explicitly for larger files.

File → Export (Selected) as HTML exports the active character, line, or block selection into a new unnamed HTML buffer. Save that buffer to choose its destination; the source stays unchanged. With no selection, it exports the document. LSP → Format Document Selection uses the current selection's range.

## Debugging

Vimspector loads on demand. GVim needs a working `+python3` provider with a compatible Python library. `:py3 print('provider ready')` checks that provider; the debug adapter may use a different Python executable.

For Python, install debugpy into your chosen adapter environment. Set `g:PV_debugpy_command = ['/path/to/python', '-m', 'debugpy.adapter']` if needed. Run `:PlanetDebugSetup python`, inspect the generated `.vimspector.json`, reopen your source, set a breakpoint, then use `:PlanetDebug launch`. Existing configurations are preserved.

For C++, build with debug symbols and use `:PlanetDebugSetup cpp`. Edit the generated program path to your actual executable. The default adapter is GDB with native DAP support (`gdb --quiet --nx --interpreter=dap`); configure `g:PV_gdb_command` for another installed command. A custom Vimspector adapter may be used on Windows if that GDB build does not supply DAP.

The Debug menu exposes launch, stop, detach, continue, breakpoints, steps, restart, and reset. The debugger displays stack/variables through Vimspector. Setup and action errors retain guidance; repeated launch/stop is supported. Optional GDB extensions, LLDB, rr, LiveRecorder, radare2, Cutter, and kernel debug actions have separate setup/target selection. They do not silently download or attach to a target during startup.

## Writing

`:PlanetMarkdownPreview` saves the document, invokes Pandoc, and opens a local self-contained HTML preview after success. Pandoc 2.19+ is required for the selected flags. Relative resource paths use the source directory. Set `g:PV_pandoc_argv` for a selected executable.

`:PlanetLatexBuild` invokes latexmk with noninteractive error reporting and writes output to private cache. Install latexmk and a TeX distribution, or set `g:PV_latexmk_argv`. `:PlanetWritingOpen` reopens successful output; `:PlanetWritingErrors` shows source diagnostics. `g:PV_document_viewer_argv` overrides the desktop viewer command, and `g:PV_writing_auto_open = 0` leaves opening explicit.

Writing buffers enable spelling with `g:PV_spell_language` (default `en_us`). `zg` adds a personal word and `z=` selects a correction. `:PlanetGrammarCheck` uses the local LanguageTool JSON CLI and Java. Select a launcher with `g:PV_languagetool_command`, or use `let g:PV_languagetool_argv = ['java', '-jar', '/path/to/languagetool-commandline.jar']`. The first-party adapter connects current LanguageTool output to the bundled Grammarous highlighting, navigation, and fixes. LanguageTool 6.6 was verified locally; no cloud grammar service is required.

The Writing menu provides word swapping, thesaurus completion, sample text, focus mode, and translation. Source/target language and engine selection are configurable. Translation sends only the selected text/current word to the selected engine when requested; choose local `sdcv` or `trans` according to your installed setup. History/log files use private state. An asynchronous replacement refuses to overwrite text changed while the request was running.

## Sessions, recovery, and environment

Save a named session from Sessions, then reopen it from the generated list or Load Last. A session records layout and file references; save edits before loading another session. Modified buffers block session loading. Save variants control relative paths and local/global option capture. Closed-tab restoration has a separate per-process snapshot and restores the closing tab's layout/cwd rather than the tab switched into afterward.

For crash recovery, start GVim through PlanetVim and use `:recover /absolute/path/to/file` to select its private swap data. Inspect recovered text and write it to a separate file first. Do not delete a swap file belonging to another running instance. Persistent undo is loaded when an unchanged saved file is reopened; backup files retain the previous saved content. Session files are Vim scripts: open sessions you created or trust.

GUI transfer copies the complete buffer, including unsaved text, to a new GVim process and waits for acknowledgement. Move closes the original view only after successful transfer; the original buffer remains hidden for recovery. A failed or timed-out transfer keeps the source.

Environment → Edit Environment uses the current process environment, and applies edited `NAME=value` lines when its scratch buffer closes. Removing a line does not unset a variable; set an empty value explicitly if desired. SDK activation affects only this GVim and its future children. See [INTEGRATIONS.md](INTEGRATIONS.md) for compiler, SDK, kernel, deployment, and analyzer workflows.

## Troubleshooting

- Startup: run `:messages` and `:PlanetDoctor`. Verify the launcher uses the intended GVim, not a console-only build. A missing optional tool should affect its action, not startup.
- Fonts: choose an installed font with `:set guifont=*`, or use `:PlanetPlainMenus`.
- Completion: run `:PlanetLspStatus`, check the configured executable, project root, and compilation database, then inspect `:LspLog`/the bundled LSP help when needed.
- Command failure: inspect retained output and `:PlanetCommandResult`; check cwd and individual argv values. Do not reinterpret a failed command as success because the terminal closed.
- Debugger: verify GVim's Python provider separately from debugpy/GDB. Review the adapter command and program in `.vimspector.json`.
- State writes: check Doctor's resolved paths and directory permissions. Preserve the last valid state/backup files before retrying an update.
- Git SSH: the HTTPS clone URL in the README avoids SSH setup. If using SSH, verify the client actually offers the fingerprint registered in GitHub. A connection closing before authentication and `Permission denied (publickey)` are different failures.

For a bug report, include `:PlanetVersion`, GVim's `:version`, OS, the selected action, minimal reproduction, and relevant Doctor/output lines. Remove usernames, private paths, repository URLs, tokens, and environment values before sharing a report.
