# PlanetVim guide

Start with `:PlanetDoctor`, `:PlanetLspStatus`, and `:PlanetVersion`. Doctor reports prerequisites without launching SDKs or adapters. An executable being present does not prove its version, credentials, or target configuration is usable. The [acceptance record](ACCEPTANCE.md) separates those checks from real workflow tests.

Git is optional for basic editing. Git menu actions remain available and report missing prerequisites; gutter change indicators start automatically when Git is available. You can set `g:gitgutter_git_executable` to a custom Git executable or explicitly set `g:gitgutter_enabled`. Restart PlanetVim after installing Git or changing its executable path.

## Menu styles

Choose **Menu Style: Emoji**, **Menu Style: Plain**, or **Menu Style:
Descriptive** directly from the **PlanetVim** menu. Emoji is the default compact
style, Plain uses compact keyboard letters, and Descriptive uses File, Edit, and
so on.
Descriptive mode shows one group at a time. Choose Basic, Editing, Development,
Tools, Navigation, or Settings from PlanetVim to switch groups. PlanetVim is
always visible, and both your style and selected group survive a restart.
In compact styles the same group entries toggle groups independently.

Option menus show **☑ / ☐** for enabled/disabled toggles and **● / ○** for
selected/unselected choices. Indicators follow the actual setting, including
changes made with `:set` and the current buffer/window. Custom option values can
leave all presets unselected. Actions without a readable setting have no marker.
These are text indicators drawn by Vimscript; shortcuts and bottom tips remain
available. Find Menu Action uses plain labels to avoid retaining stale markers.

**PlanetVim → Find Menu Action** (also in View) searches actions in every group.
Type words to filter, use the arrow keys to choose, Enter to run, F1 for the
selected action's help and mapping, or Esc to cancel.
The picker keeps your insertion point or current selection and opens a hidden
group when needed. The existing Clap providers and command picker remain available.

## Right-click menus

Right-click in the editor to act on the clicked text or window. Clicking inside
a selection keeps that selection; clicking outside it selects the new position.
The menu adapts to the buffer and editing mode:

- Ordinary files offer editing, word search, comments when the filetype supplies
  a comment format, file paths, file-tree reveal, a terminal in the file's
  directory, and window splits. Links, file references, spelling errors and diff
  windows add their relevant actions.
- Selections offer copy/cut/paste, literal search, export, indentation, comments
  and text transformations. Read-only buffers retain copying and navigation.
- Running language servers add supported definition/reference navigation,
  hover, rename, code actions and document or selection formatting.
- The file tree offers opening, preview, expansion and file operations. Help
  offers tag navigation; quickfix and location lists offer entry navigation,
  independent list histories and filtering. The welcome screen offers opening
  entries, files and sessions.
- Terminals offer paste, output browsing/copying, hiding and confirmed job
  stopping. Shift-right-click passes the click through to the terminal
  application. Command-line mode offers copying, pasting and clearing input.

Hints and bottom tips teach the keys and commands for the current mode. The
context builder loads on the first right-click and does not start tools merely
by opening the menu.

On Linux GTK3 GVim, right-click a native tab label for close,
move, duplicate, recovery and layout actions, plus file actions for that tab.
Copying its path leaves the active tab unchanged. `make install` builds and
enables the helper by default; `NATIVE_TABS=0` omits it. `:PlanetNativeTabs off`
restores Vim's stock tab menu for this instance; `g:PV_native_tabs = false` in
your private configuration persists that choice. See [native tab menus](NATIVE_TABS.md).

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

Private state includes recent-session history, project build/run choices, debugger logs, and editor recovery files when no session is active. Active sessions keep their own editor recovery files under their session directory. Automatic session directories live in `~/.local/share/planetvim/.vim/sessions` (under `$XDG_DATA_HOME` when set). Cache contains disposable preview/build intermediates and GUI-transfer snapshots. Personal spelling remains outside the installation: ordinary buffers use config `spell/`; writing buffers use state `spell/`, or your `g:PV_personal_spell_file`. Updates do not erase these directories.

## Projects, output, and tests

Each GVim instance has one active project. Launch GVim from its root or use global `:cd /path/to/project`. Tab-local `:tcd` and window-local `:lcd` are navigation only. All tabs share build selection, run profiles, test history, task results and language servers. Use separate GVim processes for unrelated projects.

Run → Project provides shared `.planetvim.vim` settings, private Vim9 overrides and named configurations. Review shared code before Trust and Load Shared Settings; Reload Settings applies saved edits. Native sessions restore the global project directory and editing layout; native local vimrc files can supply startup configuration. Run → Tasks connects Configure, Build, Run, Test and Debug with failure handling, cancellation and navigable diagnostics. See [Integrated project workflows](IDE.md) for examples and a CMake preset/target walkthrough.

The File menu creates a template only in a new or empty destination. Cancel creates nothing. Hidden files and binary files are copied; existing nonempty output is preserved. Electron/Vue dependency installation is explicit. Nuxt invokes an installed creator and reports its result. Generated README/build files describe the next steps.

Build → CMake can select a configure preset, build configuration and target, inspect actual executable artifacts, configure/build/rebuild, open GUI/TUI configuration, and generate a compilation database. Build prerequisites must succeed before dependent steps run. Run → Add Configuration accepts an object such as:

```json
{"name":"application","argv":["./build/hello","argument with spaces","a,b"],"cwd":"."}
```

`argv` executes directly. `command` is an alternative for a deliberately requested shell script; supply exactly one. On Windows, point to the native executable and its actual configuration directory.

Each output buffer shows the command, cwd, and real exit status. It remains open after failure. `:PlanetCommandResult` reports the current buffer's result; `:PlanetCommandCancel` stops its running child. The Terminal menu lists outputs. Its Previous/Next window-bar actions switch between terminal buffers.

`:PlanetTest nearest`, `file`, `class`, `suite`, `last`, and `visit` connect vim-test to PlanetVim's retained-output runner. Last/Visit use the current project's history. A Python `unittest` example is included in the Python template. CTest and other framework-specific entries run their own tools. Google Test, Boost.Test, Catch2, QtTest, kernel tests, and CDash require their selected binaries/source trees; CDash stages are explicitly selected.

## Language intelligence

C/C++ use clangd and Python uses pylsp by default, with asyncomplete's LSP, buffer, and file sources. A missing server leaves buffer/path completion available. Configure `g:PV_clangd_argv` or `g:PV_pylsp_argv` as an argv List; an empty List opts out of that server. Project `lsp` and `python` settings select separate server processes and environments; revisit a source buffer after changing them. Restart GVim after changing an unscoped global server command. `g:PV_pylsp_settings` supplies pylsp workspace settings. Install `python-lsp-server[all]` in a separate environment if its diagnostics and formatting plugins are needed.

CMake Configure requests `compile_commands.json` and automatically supplies the selected build directory to clangd when the generator produces it. An explicit `--compile-commands-dir` in clangd's argv takes priority. Configured project servers use the selected source directory; otherwise roots are detected from language/build markers and Git directories.

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

Start plain `gvim` from a project directory to resume its last session. On the first launch, open your files normally; PlanetVim saves the instance's tabs, splits, buffers, working directories and cursor positions every 30 seconds and on normal exit. Automatic sessions use the directory's plain name, preserving spaces and Unicode. If that name belongs to another project, PlanetVim leaves the instance unmanaged and asks you to choose a different name with **Save As…**. Tab/window-local directory changes do not select another session. A welcome screen alone is not saved as a workspace.

Automatic sessions go in `~/.local/share/planetvim/.vim/sessions`, or `$XDG_DATA_HOME/planetvim/.vim/sessions`. Override this with `g:PV_sessions_dir` or `PLANETVIM_SESSIONS_DIR`. Each `<folder>.session/` contains `session.vim`, `viminfo`, a private `directory.vim` record identifying the project, and separate `undo/`, `swap/`, `backup/`, and `views/` directories. Closed-tab snapshots, task logs, test reports and grammar logs also use this directory when needed. Two sessions editing the same file use different recovery files. The recent-session index remains a global private Vim9 file, `sessions.vim`, under the state directory. Session directories and the index survive installation updates and uninstall.

Sessions → **Save As…** lets you choose a directory and name: choosing `/work/demo.vim` creates `/work/demo.session/session.vim` and its private state. Save As retains the current history and undo as independent copies and relocates open buffers' swaps. The new snapshot becomes the autosave destination, and the next plain launch from the same project directory resumes it. **Save** writes immediately; it also starts a managed session when none is active. **Open** selects `session.vim`, **Open Last Session** loads the latest available entry, and **Close** saves and ends management for this instance. Advanced Save variants retain their relative-path and option-capture policy during autosave.

Opening another session loads its own viminfo, including registers, histories and bookmarks, and reopens buffers against its undo files. Closing the session restores global storage and viminfo. Instances without a session continue to use the normal global state directory. User preferences, personal dictionaries, project configuration and the recent-session index remain shared. Delete removes the session snapshot; recovery files are retained in its directory.

Sessions also save **all lists in the quickfix history** and **all location lists for every saved window**, including lists whose panels are closed. Titles, entries, the selected list and entry, and ordinary context/user metadata are included in `session.vim` with the layout. Restoring a session reopens previously visible panels and attaches each location-list history to its original window, even when several windows show the same file. Previous/Next List (`:colder`/`:cnewer`, `:lolder`/`:lnewer`) keep working after a restart. Entries use file paths rather than buffer numbers; unnamed-buffer entries retain their text without a jump target. Process-specific plugin callbacks are not saved. List state follows normal autosave, Save and Save As; without an active session it is not saved or loaded automatically.

Existing flat session files are imported when opened or saved. PlanetVim preserves the original as `previous-session.vim` inside the new directory and leaves a forwarding script at the old path so existing launchers continue to work. Previously shared recovery files stay in their original locations; they are not imported into every session.

Existing sessions with generated suffixes keep their paths and still resume automatically. Use **Save As…** to select a plain or custom name for an existing session.

Launching from `$HOME` never automatically restores or creates a session, even if a home session was saved before. Use Save, Save As…, Open, or a recent-session entry to opt in for that instance. An explicit native `:mksession` or `gvim -S /path/to/session.vim` also opts in. The startup screen shows the ten most recent available sessions, including files saved outside the default directory; select an entry to restore it.

Explicit file arguments and special tool launches keep their requested layout and do not start directory autosave. An explicitly supplied `-S` session takes precedence. Set `g:PV_session_auto = 0` to disable automatic directory activation, or change `g:PV_session_interval` (milliseconds; default `30000`) to change the save interval. Manual sessions still autosave. Emergency Exit (`:cquit`) skips the final save.

Sessions record layout and file references, not unsaved text. Save edits before opening or closing a session; modified buffers block those actions. Autosave does not write your edited files. Closed-tab restoration has a separate per-process snapshot and restores the closing tab's layout/cwd rather than the tab switched into afterward.

For crash recovery, start GVim through PlanetVim in the same session and use `:recover /absolute/path/to/file` to select its private swap data. Without a session, recovery uses global swaps. Inspect recovered text and write it to a separate file first. Do not delete a swap file belonging to another running instance. Persistent undo is loaded when an unchanged saved file is reopened; backup files retain the previous saved content. Session files are Vim scripts: open sessions you created or trust.

GUI transfer copies the complete buffer, including unsaved text, to a new GVim process and waits for acknowledgement. Move closes the original view only after successful transfer; the original buffer remains hidden for recovery. A failed or timed-out transfer keeps the source.

Environment → Edit Environment uses the current process environment, and applies edited `NAME=value` lines when its scratch buffer closes. Removing a line does not unset a variable; set an empty value explicitly if desired. SDK activation and compiler selection save environment overrides for the selected project/configuration; other projects and GVim's own environment retain their values. See [INTEGRATIONS.md](INTEGRATIONS.md) for compiler, SDK, kernel, deployment, and analyzer workflows.

## Startup and plugin loading

To run plain GVim with no plugins, personal vimrc/gvimrc, or saved Vim state:

```sh
/usr/bin/gvim -u NONE -U NONE -i NONE
```

PlanetVim still loads most plugin entry scripts at startup. It is not a general
lazy-loading plugin manager. The expensive integrations now start when needed:

- The action finder builds its search index on first use. All selected menubar
  groups and their hints are available immediately; hidden groups remain searchable.
- Fixed menu declarations use direct compiled calls. Derived shortcuts and tips
  are cached as JSON in the PlanetVim cache directory (`menu-hints.json`). They
  are recomputed when mappings, leaders, relevant display settings or hint code
  change. The cache is saved on exit, so the first launch after an update costs
  more. Missing or damaged caches fall back to live computation.
- LSP initialization waits for the first normal buffer with a filetype. The
  client commands remain available, including `:LspEnable`. An explicit
  `g:lsp_auto_enable` setting is respected.
- Vista's automatic nearest-symbol check waits for an idle pause in a named
  buffer with a filetype and an available provider. `:Vista` remains available.
- The older Markdown preview plugin loads on its first public preview function
  call. PlanetVim's Markdown Preview menu uses the existing Pandoc integration.

On Linux, an inherited Fish shell with default `-c` flags uses
`--no-config -c` for noninteractive shell commands. Interactive `:terminal`
sessions still load Fish configuration. This means Fish functions and aliases
defined only in your configuration are unavailable to `:!` and shell-string
tasks unless you opt out. Put `let g:PV_fast_shell = 0` in `planetvimrc.vim` to
retain the original behavior; explicit nondefault shell flags are preserved.
Use `let g:PV_menu_cache = 0` there to disable the hint cache.

Measure startup with `python3 scripts/benchmark.py --runs 5 --xvfb /path/to/Xvfb`.
Each sample starts a fresh GVim process, with a cache populated by one excluded
warmup, an empty buffer and the Startify dashboard suppressed. `--cold-cache`
measures with an empty PlanetVim cache each time; it does
not flush the operating system's filesystem cache. The report includes both
the historical pre-vimrc-to-event-loop interval and GVim's first-screen time
from `--startuptime`. The current optimization target is a **1.0-second median
to the first screen** on the Linux reference setup, with all default menus.

## Troubleshooting

- Startup: run `:messages` and `:PlanetDoctor`. Verify the launcher uses the intended GVim, not a console-only build. A missing optional tool should affect its action, not startup.
- Fonts: choose an installed font with `:set guifont=*`, or use `:PlanetPlainMenus`.
- Completion: run `:PlanetLspStatus`, check the configured executable, project root, and compilation database, then inspect `:LspLog`/the bundled LSP help when needed.
- Command failure: inspect retained output and `:PlanetCommandResult`; check cwd and individual argv values. Do not reinterpret a failed command as success because the terminal closed.
- Debugger: verify GVim's Python provider separately from debugpy/GDB. Review the adapter command and program in `.vimspector.json`.
- State writes: check Doctor's resolved paths and directory permissions. Preserve the last valid state/backup files before retrying an update.
- Git SSH: the HTTPS clone URL in the README avoids SSH setup. If using SSH, verify the client actually offers the fingerprint registered in GitHub. A connection closing before authentication and `Permission denied (publickey)` are different failures.

For a bug report, include `:PlanetVersion`, GVim's `:version`, OS, the selected action, minimal reproduction, and relevant Doctor/output lines. Remove usernames, private paths, repository URLs, tokens, and environment values before sharing a report.

## File recovery and buffer settings

File → Recovery finds swap files in Vim's `directory` setting. Recover opens a
separate tab and refuses swaps owned by a running local Vim. Compare with Disk
shows the saved file beside the recovered text. Save Recovered Copy requires a
new filename. Recovery retains the swap; remove it yourself only after checking
and saving the recovered text. Reload from Disk uses Vim's save/discard/cancel
prompt for unsaved changes.

File → Encoding separates **Reopen As** (decode the existing file again) from
**Encoding for Next Save** (encode the current text on the next explicit write).
BOM and Settings → Buffer newline/indentation/filetype controls affect the current
buffer. Show Whitespace and scrolling controls affect the current window.

Edit → Insert Special Character offers digraphs, Unicode code points, literal
keys, and expression results. In Insert mode it retains the insertion point;
in Visual/Select mode it replaces the selection. Canceling inserts nothing.
Settings → Input Language chooses an installed Vim keymap or the operating
system keyboard. Spelling → Choose Spelling Language lists installed dictionaries.
See the [completion guide](COMPLETION.md) for native completion examples.

## Learning from menu entries

Hints favor shortcuts and show at most two, with the primary shortcut at the far
right. A second short shortcut takes the middle position; otherwise a short
command can go there. Examples: **Undo — :undo — u**, **Next Tab — <C-PgDown> —
gt**, and **Minimize — :suspend — <C-z>**. Long commands and function calls stay
in the tip to keep menus compact.

Hover over an entry to see its command or function, beginning with `:`, in GVim's
bottom command area. Actions with no Ex command have a fuller explanation
beginning with `"`. Menubar tips teach the Normal-mode action when the same item also has
Insert/Visual variants. Right-click tips follow the current editing mode. Vim does not show menu tips while editing a command line.
The displayed hints document existing keys; they do not create key bindings.

Edit → Undo/Redo and Earlier/Later Change are separate: `u` and `<C-r>` follow
the undo tree, while `g-` and `g+` follow the chronological change history.
Modify → Toggle Comment uses the filetype's `commentstring`; `gcc` toggles the
current line. `:PlanetToggleComment` also accepts an Ex line range.

## Editing and comparison menus

Selection → Inside / Around exposes Vim text objects, including words, quotes,
brackets, tags and folds. Selection → Text Objects combines these with delete,
change, yank and format. Visual block actions insert/append/change across the
block; use the block-selection mode first. Number actions support counts and
sequences, and the number-format menu controls the current buffer's `nrformats`.

Search → Find Literal Text treats punctuation literally; Find Pattern uses Vim
regular expressions. Find Selection uses the exact selected text. Replace with
Scope distinguishes the whole buffer from the selected region and offers
confirmation for each match. Modify → Run on Lines shows the matching or
nonmatching line scope before running the Ex command. Sort Options uses the
selected lines when a selection is active, otherwise the whole buffer. Native
undo applies to these operations.

Registers → Guided Macros prompts for a register, records, stops, previews and
replays it. Apply to Selected Lines shows the register contents, repeat count
and line range before running. Original register and macro shortcuts remain.

Bookmarks manages Vim's uppercase **A–Z file marks**. Set / Replace remembers
the cursor position (`mA` through `mZ`); Add Next Free chooses an unused letter
and leaves existing bookmarks alone when all 26 slots are occupied. Choose Exact
Position jumps to the saved column (`` `A ``); Choose Line jumps to the first
nonblank character (`'A`). Open LocList shows bookmarks across files, including
files that are not open. Delete removes a chosen bookmark; Delete All runs
`:delmarks A-Z`, preserving lowercase and numbered marks. Vim's normal viminfo
file-mark settings control persistence. The Marks menu remains available for
local marks and the existing signature-plugin actions.

The Highlights menu's TextProp section adds manual highlights at the cursor,
over a line or over selected characters, lines or a block. In Normal mode,
Add Property to Selection uses the current word. Create a named buffer-local
type and choose its highlight group, then reuse it for highlights or virtual
text: inline, after, right-aligned, above or below a line. Change Property Type
Highlight updates existing annotations
of that type. List, Next/Previous and Remove operate on manual properties;
Clear Manual Properties leaves plugin properties, including LSP displays,
intact. Inspect All Properties and Inspect All Property Types include
plugin-created properties/types. Deleting a manual type also removes its
properties.

Text properties follow native `prop_add()`/`prop_add_list()` behavior: positions
move with edits, but the annotations are not file contents and disappear when
the buffer is unloaded. They are not saved in sessions. Block highlights use
whole characters if a selection cuts through a tab or wide character. These
menus use the native `prop_*()` APIs; Help opens Vim's text-properties reference.

Diff/Patch offers source/target selection when more than two diff buffers are
open, transfers for selected lines, refresh and stop controls. Rendering choices
preserve unrelated settings: choose whitespace policy, algorithm, context,
inline granularity, similar-line alignment or anchors. Unsupported options keep
the previous value and explain the required Vim feature.

LSP → Display controls inlay hints, inline diagnostics, signs and underlines.
Hints need an attached server with inlay-hint support. The display choices are
saved. Turning off one presentation keeps the other presentations available;
the existing diagnostic master switch still controls diagnostic collection.

## Linux GUI and learning

The Windows menu provides native scroll/split choices, fixed-size release and buffer
pinning. View → Tab Panel exposes the installed Vim's native vertical panel;
Tabman remains available. Settings → Appearance offers font zoom/reset,
ligatures, colors/widget preferences and fullscreen exit. Native GTK fullscreen
requires Vim 9.2.0534; older builds use `wmctrl`.

Help → Interactive Tutor opens a separate clean GVim with standard Vim keys.
It uses the installed interactive tutor when available, otherwise a scratch
copy of the traditional lesson. Help also exposes the User Manual, searchable
help, the installed Vim's release notes and this guide. The Vim9 scratch example
runs only when Compile/Run Scratch Example is explicitly selected.

File → Print prints the buffer; Selected Lines prints the selected line range.
Print Settings configures Vim's printer, font and layout options. The print
action uses the printer/device you configured. File → Encryption uses Vim's
protected key input; the method/key affects the next explicit save. Removing
the key means the next save writes plaintext. Keys are never saved in PlanetVim
preferences; encrypted files use Vim's file format rather than ordinary text.

File → Open Remote File accepts `sftp://`, `scp://`, `http://` and `https://`
URLs. It uses the installed netrw transfer library and its SSH/HTTP tools;
configure SSH authentication normally. SFTP/SCP buffers write through netrw,
while HTTP(S) buffers are read-only. Fern remains the local directory browser.

## Optional newer display features

View → Image Preview opens one local image on demand. It requires GTK GVim with
`+image` and `+image_cairo` or `+image_gdk`, plus Python 3 and Pillow. Install
Pillow for the interpreter selected by `g:PV_python` (or `python3` by default).
Esc, Enter, `q`, the close button or the Close menu closes the preview. Resizing
the GUI rebuilds the thumbnail. Previewing never replaces the editing buffer.
The decoder rejects files over 32 MiB or 16 million pixels, limits its process
address space to 384 MiB, and returns at most 1024×768 pixels. These limits are
fixed to keep previews bounded; animated images show their first frame.

Settings → Advanced Display offers supported completion-popup borders and
opacity, cursor padding at file boundaries, and optional two-line or clickable
status lines. Status-line presets affect the current window and Restore returns
its previous settings. The simple existing status line remains the default.
These later 9.2 features use runtime capability checks; an older GVim still
shows their menu entries and explains the missing prerequisite when selected.
