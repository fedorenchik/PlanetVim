# Menu coverage and discoverability review

Reviewed 2026-09-10 against PlanetVim commit `192d9f81955a755de860a458817969c37dafb1e2`.
Scope: **Linux GVim only for this implementation pass** (owner update).
Windows work is deferred. MD-03 is superseded by the requested emoji/plain/
descriptive selector; descriptive mode shows one group plus PlanetVim.
Implementation progress and validation are recorded beside completed tasks.

## Assessment

PlanetVim already exposes a large part of Vim. The most valuable next additions
are completion choices, modern diff controls, text objects, recovery, inlay hints,
and a searchable index of the actual menu actions. Several older commands are
missing even though much more specialized development tools have menus.

A clean Linux GVim startup produced **42 menu-bar roots**, plus the context menu,
and roughly **1,750 Normal-mode action entries**. This is an inventory, not a count
of unique features: repeated actions and dynamic entries contribute to it. With
this much content, names, grouping, explanations and search matter as much as
adding commands.

The review covers all seven first-party menu modules, relevant adapters, `.vimrc`,
settings, and selected bundled-plugin capabilities. Runtime inspection used
`/usr/bin/gvim` 9.2.0849, GTK3, under Xvfb with isolated config/state/cache and
scratch buffers. It used the real `scripts/planetvim.vim` startup sequence;
sourcing the configuration after `gvim -u NONE` can leave default Vim menus in
place and give a misleading inventory. Windows and Wayland GUI behavior were not
exercised. This is not an execution test of every menu or external SDK action.

### Version boundaries

- **At PlanetVim's 9.1.0000 minimum:** traditional Vim editing, command-line popup
  completion, virtual text, smooth scrolling and built-in EditorConfig.
  [Vim 9.1 release](https://www.vim.org/vim-9.1-released.php)
- **By Vim 9.2.0000:** native automatic/fuzzy completion, register completion,
  improved diff alignment/highlighting, vertical tab panel and interactive tutor.
  Many arrived in intermediate 9.1 patches, so “Vim 9.1” alone is insufficient as
  a capability check. [Vim 9.2 release](https://www.vim.org/vim-9.2-released.php)
- **Later 9.2 patches:** GTK fullscreen, image popups and additional display
  controls need separate checks. Upstream groups these under a work-in-progress
  “9.3” heading; that does **not** mean 9.3 has been released. Vim still names 9.2
  as stable. GTK4 first appeared in 9.2.0501 and remains an optional backend.
  [Current changes](https://github.com/vim/vim/blob/master/runtime/doc/version9.txt),
  [release status](https://www.vim.org/download.php),
  [GTK4 announcement](https://www.vim.org/news/news.php)

## Existing coverage to retain

These should not be reported as missing or replaced merely because Vim has added
another implementation:

- Undo tree, repeat edit/command/macro, register editing, yank history.
- Character/line/block selection, selection export, comments, case conversion,
  formatting, sorting, filtering, snippets and Emmet.
- Extensive folds, marks, markers, jump/change navigation and tag previews.
- Quickfix/location-list searches, filters, history, navigation and batch commands.
- Buffers, argument lists, windows, tabs, saved views/layouts and sessions.
- LSP navigation, diagnostics, symbols, rename, code actions, hover and formatting.
- Asyncomplete automatic completion with buffer, filename and LSP sources.
- EditorConfig, HEX round trips, spelling, grammar, thesaurus, translation, HTML
  export, and command/search history windows under Tools.
- Colorscheme picker, font dialog, maximize/fullscreen and GVim servers.

Evidence: [basic](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim),
[editing](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/edit.vim),
[navigation](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/nav.vim),
[development](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/dev.vim),
[tools](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/tools.vim),
[completion setup](../.vim/pack/planet/start/planet.vim/autoload/planet/intelligence.vim#L114).

## Prioritized backlog

Here **P1** means highest-value next work, **P2** means the next completeness pass,
and **P3** means optional advanced coverage. These are review priorities, not a
claim that every new feature blocks the existing release candidate.

### MD-01 · P1 · Repair existing entries that mislead or fail

- [x] Complete these actions and correct their labels; keep the actions available.
  Implemented and verified by `tests/test_menu_repairs.vim` in Linux GUI mode.

Confirmed in the isolated GUI:

- **Navigation → Next Start of Function** runs `[m`, the previous-function motion.
  A two-function scratch-buffer probe remained at line 1. Use `]m` and show the
  matching shortcut. [basic.vim:401](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim#L401)
- **Diff/Patch → Set Context Lines** raises `E474` because it uses
  `diffopt+=context=12`. The suboption uses `context:12`; prompt for a value and
  replace an existing context setting.
  [tools.vim:325](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/tools.vim#L325)
- **CMarks → Add Match Regex / Add Match Position / Delete Match** raise `E121`
  for undefined `highlight_group` or `id`. Implement input and a match picker
  instead of calling built-ins with placeholder variables.
  [edit.vim:129](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/edit.vim#L129)
- **Go → Scroll Left/Right** each occurs twice under the same path. Runtime
  inspection retains `zh`/`zl`; the earlier `zH`/`zL` half-screen actions are
  overwritten. Give the two distances distinct names.
  [basic.vim:376](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim#L376)

Additional definite source-level discrepancies:

- **File → Advanced → VSplit Read Only / Tab Read Only** both use plain
  `browse view`, without the promised split/tab modifier.
  [basic.vim:86](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim#L86)
- **Search → Current \<word\>** runs `g*`, which omits word boundaries. Its
  backward counterpart has the same problem. Distinguish whole-word `*`/`#`
  from partial-word `g*`/`g#` search.
  [basic.vim:257](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim#L257)

Acceptance: named results on small fixtures, cancellation without text changes,
and checks comparing labels/shortcuts with callbacks. The existing two Python
menu-contract tests passed despite the reproduced failures: callback existence
does not establish valid built-in arguments or correct behavior.

### MD-02 · P1 · Search actual menu actions

- [x] Add **View → Find Menu Action…**, indexed by readable full path, synonyms,
  description and applicable mode; retain the existing Clap picker.

The current **Command Palette** calls bare `:Clap`, which opens providers.
`<Space>;` opens `:Clap command`, but that provider reads `:command`, so it lists
user commands rather than the complete menu hierarchy or Normal-mode operations.
[entry](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim#L298),
[Clap dispatch](../.vim/pack/basic/start/vim-clap/autoload/clap.vim#L363),
[command provider](../.vim/pack/basic/start/vim-clap/autoload/clap/provider/command.vim#L26)

Acceptance: “compare”, “inside quotes”, “recover” and “complete filename” find the
right actions; execution retains Visual selections. Index existing actions
without duplicating or modifying vendor implementations.

Implemented in both PlanetVim and View. The native popup indexes actual menu
leaves in all groups, filters readable paths and synonyms as you type, and runs
the selected mode's menu. `tests/test_menu_actions.vim` covers hidden-group
execution and preserving an active Visual selection. Existing Clap entries remain.

### MD-03 · Superseded by owner request · Compact menu styles

- [x] PlanetVim → Menu Style offers Emoji (default), Plain, and Descriptive.
  Descriptive mode shows exactly one of the six groups; PlanetVim always remains
  visible. Style and selected group are saved across restarts. Compact styles
  retain the independent group toggles. Dynamic buffer, session, GUI and run
  menus respect visibility and are rebuilt when their group is selected.

The original broader MD-03 proposal is skipped. Validation:
`tests/test_menu_styles.vim` and `tests/test_menus.vim` exercise switching,
all six groups, dynamic updates, preference persistence, and root restoration.

### MD-04 · P1 · Expose built-in completion sources

- [x] Add **Edit → Complete**: words, whole lines, filenames, dictionary, thesaurus,
  tags, included-file keywords/definitions, Vim commands, omnifunc, user completion,
  spelling and register contents; include accept/cancel.

Most are old features missing from menus. Register completion (`CTRL-X CTRL-R`)
is newer, available by 9.2. Reuse the Writing thesaurus action. Preserve the
insertion point with Insert-mode mappings instead of generic Normal-mode wrappers.
[Vim completion reference](https://github.com/vim/vim/blob/master/runtime/doc/insert.txt)

Acceptance: each source has a working example and shortcut; investigate the old
CapsLock-related whole-line completion FIXME in `.vimrc:701` as part of this work.

### MD-05 · P1 · Offer modern completion settings

- [x] Add **Settings → Completion**: automatic completion on/off, engine choice,
  fuzzy matching, documentation popup and supported ordering presets (`nearest`,
  `nosort`), plus a compatible `preinsert` preview choice.

This is a control/choice gap: asyncomplete already provides automatic suggestions.
The live startup had `autocomplete=0` and `completeopt=menuone,noinsert,noselect`.
Offer the newer native engine while retaining the minimum version's working
engine and LSP sources. [defaults](../.vim/pack/planet/start/planet.vim/plugin/settings.vim#L33)

Acceptance: one automatic engine owns a buffer; switching retains manual/LSP
completion. `preinsert` cannot be combined with `fuzzy`. Do not add a new control
for `completefuzzycollect`: current Vim documents it as deprecated and ineffective.
[completion option reference](https://github.com/vim/vim/blob/master/runtime/doc/options.txt)

### MD-06 · P1 · Expose command-line and search completion

- [x] Add **Settings → Command-line Completion → Popup / Fuzzy Matching** and
  **Search → Complete Search Pattern**, with examples for `/`, `?` and Ex searches.

PlanetVim sets `wildoptions=tagfile`, leaving popup/fuzzy completion undiscoverable.
Command-line popup completion predates the supported minimum; search-context
completion arrived in 9.1.1490. The existing `CTRL-S → :emenu` completion mapping
helps expert users but is not action search by purpose.
[settings:239](../.vim/pack/planet/start/planet.vim/plugin/settings.vim#L239),
[Vim change history](https://github.com/vim/vim/blob/master/runtime/doc/version9.txt)

Acceptance: preserve unrelated option flags and key choices; explain acceptance,
cancellation and literal input.

Implementation: native Insert mappings bypass CapsLock remapping; automatic
engine selection and completion preferences are saved. Unsupported option values
leave the old settings intact and explain the required feature. Tests:
`test_native_completion.vim`, `test_config.vim`; examples in
[completion guide](COMPLETION.md).

### MD-07 · P1 · Finish native diff and expose newer rendering

- [x] Extend **Diff/Patch** with Stop (window/tab), Refresh, source/target selection
  for three-way comparisons, whitespace/algorithm/context choices, inline
  character/word highlighting, similar-line alignment and anchors.

Compare/start/get/put already exist. `:diffoff`, `:diffoff!` and `:diffupdate` do
not have entries. Get/Put need a buffer choice with multiple peers. The newer
alignment/rendering options are useful for source comparisons.
[Vim diff reference](https://github.com/vim/vim/blob/master/runtime/doc/diff.txt)

PlanetVim replaces all of `diffopt`, includes `iwhite`, and omits newer inline
highlighting. A GVim upgrade alone therefore does not adopt the new default.
Expose the effective whitespace policy and preserve unrelated flags.
[defaults](../.vim/pack/planet/start/planet.vim/plugin/settings.vim#L46)

Acceptance: two-/three-buffer fixtures, ranged transfers, stop/refresh and
compatible rendering presets on 9.1.0000 and current GVim.

Implemented and validated in `test_diff_workflow.vim`: explicit three-way peers,
selected-line transfers, preserved option flags, unsupported-option rollback,
anchor validation, and window/tab stop actions.

### MD-08 · P1 · Teach text objects and block editing

- [x] Add **Selection → Inside / Around** for word/WORD, sentence, paragraph,
  quotes, parentheses, brackets, braces and tag blocks; include bundled fold
  objects. Add block insert/append/change and move-to-other-corner actions.

Selection exposes modes but not this essential Vim vocabulary; the operator-pending
context menu contains only “Word”. Make objects usable for select/delete/change/
yank/format and show examples such as `ci"`.
[selection menu](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim#L276),
[Vim text objects and blocks](https://github.com/vim/vim/blob/master/runtime/doc/visual.txt)

Acceptance: correct regions in Normal/Visual/Select/operator-pending modes; block
operations handle tabs, short lines and Unicode without stale marks.

Validation for text objects and number changes: `test_text_objects.vim` covers
operator-pending and Visual objects, Unicode block insertion, hexadecimal and
negative values, and counted sequences. Native Visual case/format/join actions
now consume the selection instead of dropping it.

### MD-09 · P1 · Make file recovery discoverable

- [x] Add **File → Recovery → Find Recoverable Files / Recover… / Compare with
  Disk / Save Recovered Copy**, plus **Reload from Disk**.

Recovery is documented but has no menu workflow. `DiffOrig` and undo history are
adjacent capabilities, not a swap-recovery picker.
[existing help](../.vim/pack/planet/start/planet.vim/doc/planetvim.txt#L237),
[Vim recovery reference](https://github.com/vim/vim/blob/master/runtime/doc/recover.txt)

Acceptance: find/recover an abandoned-swap fixture through menus, respect live
swap ownership and offer compare/save-copy before explicit cleanup. Reload uses
the existing save/cancel flow for unsaved edits.

Validation: `test_recovery.vim` creates a real swap checkpoint, refuses the live
owner, stops that fixture process, recovers in a separate tab, compares with disk,
and saves a new copy without overwriting the original or deleting the swap.

### MD-10 · P2 · Add number changes and sequences

- [x] Add **Modify → Numbers → Increment / Decrement / Increase Each Line /
  Decrease Each Line**, with count and number-format choices.

`CTRL-A`, `CTRL-X`, `g CTRL-A` and `g CTRL-X` have no menu entries. Show how a
selection of repeated numbers becomes a sequence.
[Vim number changes](https://github.com/vim/vim/blob/master/runtime/doc/change.txt)

Acceptance: decimal/hex, negatives, blocks, counts and predictable undo using
native operations where possible.

### MD-11 · P2 · Add encoding, filetype and whitespace controls

- [x] Add **File → Encoding → Reopen As… / Save As… / BOM**, and **Settings →
  Buffer → Filetype / End-of-file Newline / Show Whitespace / Indentation**.

Line-ending selection and HEX conversion exist. They do not expose decoding or
output encoding. Distinguish reopening with another decoder from selecting an
encoding for the next save. Include read-only state and practical indentation
controls beyond the three fixed tab presets.
[settings menu](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/settings.vim#L7),
[Vim file editing](https://github.com/vim/vim/blob/master/runtime/doc/editing.txt)

Acceptance: UTF-8/UTF-16/legacy fixtures retain intended bytes, cancellation
preserves text, and local options do not silently change other files.

### MD-12 · P2 · Expose special characters and input language

- [x] Add **Edit → Insert Special Character → Digraph / Unicode Code Point /
  Literal Character / Expression Result**, plus **Settings → Input Language**.

Character inspection exists; insertion does not. Startup hard-codes
`keymap=russian-dvp`; expose its choice and enable/disable state while retaining
the operating system's input-method integration. Spell Check currently offers
only an English language shortcut; add a spelling-language picker alongside it.
[startup keymap](../.vimrc#L73),
[Vim insertion reference](https://github.com/vim/vim/blob/master/runtime/doc/insert.txt)

Acceptance: original cursor/selection, cancellation, non-ASCII input, and accurate
Linux shortcuts (Windows is deferred).

Validation: `test_buffer_options.vim` checks exact Latin-1, UTF-16LE/BOM and
UTF-8 output bytes, local-option isolation, canceled/invalid values, Unicode,
digraph and expression insertion, and installed keymap/spell choices.

### MD-13 · P2 · Add scrolling and split-behavior choices

- [x] Add **View → Scrolling → Smooth Wrapped-line Scrolling**, vertical scroll/
  center/top/bottom actions, and **Windows → Split Behavior → Keep Cursor / Keep
  Screen / Keep Top Line**. Expose jump-list stack behavior under navigation.

`smoothscroll`, `splitkeep` and `jumpoptions` are available at the supported
minimum but have no dedicated controls. The first two live defaults were off and
`cursor`. Smooth scrolling means scrolling wrapped screen lines, not animation.
[scrolling reference](https://github.com/vim/vim/blob/master/runtime/doc/scroll.txt),
[Vim 9.1 changes](https://github.com/vim/vim/blob/master/runtime/doc/version9.txt)

Acceptance: long-line and split/close fixtures; appropriate window-local effects.
Also provide an undo for the existing fixed-window-size action.

### MD-14 · P2 · Expose pinning a buffer to its window

- [x] Add **Windows → Pin Buffer / Unpin Buffer** using `winfixbuf` where present.

“Set Fixed Size” controls dimensions, not buffer replacement. Pinning is useful
for a reference file beside quickfix navigation; it arrived in 9.1.0147, after
PlanetVim's minimum.
[window menu](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/nav.vim),
[upstream history](https://github.com/vim/vim/blob/master/runtime/doc/version9.txt)

Acceptance: navigation respects the pinned window, state is visible, and unpin
restores ordinary behavior.

### MD-15 · P2 · Expose the native vertical tab panel

- [x] Add **View → Tab Panel → Show / Hide / Left / Right / Width** on capable Vim.

Retain Tabman and ordinary tab workflows as alternatives. Use `showtabpanel`,
`tabpanel` and `tabpanelopt` appropriately; panel content alone is not its
visibility control. Later patches add panel scrolling.
[Vim tab-panel reference](https://github.com/vim/vim/blob/master/runtime/doc/tabpage.txt)

Acceptance: coherent create/rename/close/many-tab navigation, without unexpected
changes to the user's other sidebars.

### MD-16 · P1 · Expose inlay hints and diagnostic presentation

- [x] Add **LSP → Display → Inlay Hints / Inline Diagnostics / Signs / Underlines**
  with enable/disable, status and explanations of missing server capabilities.

Bundled vim-lsp already implements inlay hints using Vim text properties. Its
default is off; PlanetVim neither sets it nor offers a menu control. The existing
diagnostics master enable/disable pair is not a presentation selector.
[plugin setting](../.vim/pack/lsp/start/vim-lsp/plugin/lsp.vim#L75),
[implementation](../.vim/pack/lsp/start/vim-lsp/autoload/lsp/internal/inlay_hints.vim),
[Vim virtual text](https://www.vim.org/vim-9.1-released.php)

Acceptance: capable-server hints appear and disappear on request; unsupported
servers explain why. Use first-party adaptation or upstream updates, not vendor
source edits.

Implemented a first-party display adapter over vim-lsp's existing transport and
diagnostic cache. Its pinned inline renderer is Neovim-only, and its inlay
renderer treats protocol offsets as byte columns. The adapter provides GVim
text properties, UTF-16/UTF-8/UTF-32 hint positioning, stale-response rejection,
and complete disable cleanup without vendor edits. `test_lsp_display.vim` uses a
local protocol fixture to verify hints after emoji/non-ASCII text, inline
messages, signs, and presentation toggles on GVim 9.1 and 9.2.

### MD-17 · P1 · Add guided learning and “what is new” entries

- [x] Add **Help → Interactive Tutor / User Manual / Search Help / What's New in
  This Vim / PlanetVim Guide**, plus action-specific help in the action finder.

Help/index/quickref/plugin entries exist, but the new `:Tutor`, user manual and
release notes are not directly exposed. Offer the installed tutor when available
and a GUI tutor/help fallback on older builds. Standard exercises must not
silently use Supercharged remappings.
[help menu](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/settings.vim#L105),
[Vim tutor documentation](https://github.com/vim/vim/blob/master/runtime/doc/usr_01.txt)

Acceptance: scratch lessons preserve files and mode; release help matches the
installed version. An optional Vim9 submenu can link scripting/classes and
source/compile a scratch example, without a menu for each language keyword.

Implemented native/fallback tutoring in a separate clean GVim and an editable
Vim9 scratch lesson. F1 in Find Menu Action opens relevant help with the exact
menu path and mapping. The finder refreshes visible dynamic entries while
retaining its hidden-group catalog. `test_learning.vim` and
`test_menu_actions.vim` cover these flows without changing the source buffer.

### MD-18 · P2 · Modernize existing GUI controls

- [x] Extend **GUI / Settings → Appearance** with native fullscreen where supported,
  font size increase/decrease/reset, ligatures, and visible light/dark/system
  preferences where the backend implements them.

Fullscreen exists but always uses `wmctrl` on Linux or PowerShell on Windows.
Recent native support can remove that dependency for this action. Dark styling
is already requested in `guioptions`, and a font dialog exists; those are partial
coverage, not wholly missing features.
[adapter](../.vim/pack/planet/start/planet.vim/autoload/planet/gui.vim#L131),
[GUI reference](https://github.com/vim/vim/blob/master/runtime/doc/gui.txt),
[GTK reference](https://github.com/vim/vim/blob/master/runtime/doc/gui_x11.txt)

Validation scope: Linux GTK3/X11; native Wayland and Windows remain deferred; obvious fullscreen exit
and correct font/backend checks. Clipboard support does not imply every desktop
integration works on Wayland. Keep GTK4 an optional target rather than replacing
GTK3 without validation.

Implemented window-local scrolling/pinning, persisted split/panel controls, font
zoom/reset, ligatures and appearance choices. GTK native fullscreen is gated at
[Vim 9.2.0534](https://github.com/vim/vim/releases/tag/v9.2.0534); older GTK builds
retain the existing wmctrl path. `test_view_options.vim` passes on GVim 9.1 and
9.2 under Xvfb. These checks verify options and callbacks, not a real desktop
window manager's fullscreen transition or native Wayland rendering.

### MD-19 · P2 · Turn register/macro prefixes into guided actions

- [x] Enhance **Registers / Macros** with named-register preview, Record Into…,
  Stop Recording, Play…, Repeat Count… and Apply to Selected Lines….

Existing `q`, `@` and register-prefix entries expose keys but require knowledge of
the next keystroke. Keep the expert shortcuts and add prompts, recording state
and cancellation. Reuse the register editor and yank history.
[current menu](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/edit.vim#L5)

Acceptance: record/replay through menus alone; show register contents and count
before applying a macro to multiple lines.

Implemented guided prompts, recording status, preview and ranged playback using
native registers. `test_macros.vim` verifies recording, repeated playback,
selected-line scope and cancellation on GVim 9.1 and 9.2.

### MD-20 · P2 · Complete search and batch-edit discovery

- [x] Add **Search → Literal / Pattern / Selection / Clear Highlight / Case and
  Wrap Options**, guided matching/nonmatching-line commands, sorting choices and
  **Args → Remove Duplicates**.

Dialogs, selection substitute, `gn`, grep and list batch commands already exist.
Extend with visible scope/confirmation, regex help, numeric/case/key/unique sort,
and `:argdedupe` (available by 9.0). Avoid a second independent search engine.
[search menus](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/basic.vim#L226),
[argument menus](../.vim/pack/planet/start/planet.vim/autoload/planet/menu/nav.vim#L49),
[Vim change history](https://github.com/vim/vim/blob/master/runtime/doc/version9.txt)

Acceptance: explicit scope, optional confirmation per substitution, cancellation
without text/search changes, and predictable batch-operation undo.

Implemented native search, explicit replacement scope, confirmed matching and
nonmatching-line commands, seven sorting choices, and argument deduplication.
`test_search_workflow.vim` verifies literal matching, cancellation, selected-word
replacement, batch filtering and numeric/unique sorting on GVim 9.1 and 9.2.

### MD-21 · P3 · Fill remaining file-workflow gaps

- [x] Add **File → Print / Print Selection / Print Settings**, **Open Remote
  File…**, and optional **Encryption** inspect/set/remove-key actions.

PlanetVim suppresses the default Vim menus; its own menus lack printing. Remote
and archive editing may already be reached through file opening, but named
workflows/help improve discovery. Printing depends on the build/platform. Explain
encryption's file-format consequences and use Vim's protected key input; never
save keys in menu preferences.
[printing reference](https://github.com/vim/vim/blob/master/runtime/doc/print.txt),
[file/encryption reference](https://github.com/vim/vim/blob/master/runtime/doc/editing.txt)

Acceptance: explicit printing with correct scope, encrypted scratch-file round
trip, and reuse of existing remote integrations.

Implemented native printing and protected encryption input, plus SFTP/SCP/HTTP(S)
opening through the installed netrw transfer library while retaining Fern for
local browsing. `test_file_extras.vim` checks selected-line PostScript output,
an encrypted-file round trip, a local HTTP fixture, and whole-buffer write
dispatch on GVim 9.1 and 9.2. Physical printing and authenticated SSH transfers
were not exercised.

### MD-22 · P3 · Evaluate later 9.2 display features

- [ ] Prototype **View → Image Preview**, completion-popup appearance controls,
  and advanced cursor-padding/status-line settings.

Upstream now offers image popups, opacity, `scrolloffpad`, multiline status lines
and clickable status/tab elements. They are foundations, not proof PlanetVim has
an image viewer. Start with on-demand local image previews.
[popup reference](https://github.com/vim/vim/blob/master/runtime/doc/popup.txt),
[post-9.2 changes](https://github.com/vim/vim/blob/master/runtime/doc/version9.txt)

Acceptance: pin minimum patches/backends first; explain unsupported capabilities.
Check preview close/resize/memory behavior and retain a simple default status
line. Later GTK4/Pango printing can extend MD-21 after platform validation.

## Implementation rules and recommended order

1. **Repair and trust:** MD-01, then MD-02/03. Accurate labels, searchable actions
   and clear state make the existing investment useful immediately.
2. **Everyday editing:** MD-04 through MD-09, plus MD-16/17.
3. **Complete the controls:** MD-10 through MD-15 and MD-18 through MD-20.
4. **Optional advanced coverage:** MD-21/22.

Use small focused commits with Linux GVim checks first and Windows second. Prefer
first-party menus/adapters and configuration. Native EditorConfig, comment,
yank-highlight and help packages are possible consolidation candidates, but a
new native equivalent alone does not justify replacing a working plugin.
Vim9 classes/enums/generics, jobs/channels/DAP and text-property APIs mostly belong
in implementation or learning material, not one menu per API. XDG support belongs
in startup/install compatibility, which already has a managed-home workflow.

Use `exists('+option')`, runtime/command availability and verified patch checks.
Option existence alone does not prove support for a new suboption. Probe without
leaving changed values behind. Keep features discoverable on unsupported builds
with prerequisite/help actions rather than hiding unfinished work.

Each action should define its purpose, label, mode, native key, scope, requirement,
help topic and persistence policy. Test actual menu invocation in relevant editing
modes, not only the called function. Verify cancellation, undo, selection, local/
global effects and style/mode rebuilds. Share metadata between the action index
and menu tree where practical.

## Validation recorded

- Inspected all seven modules and relevant startup/adapters; checked current
  official Vim releases/reference documentation on 2026-09-10.
- Captured live menus/options with `getcompletion('', 'menu')` and `menu_info()`
  during isolated Linux GTK3 GVim 9.2.0849 startup.
- Reproduced MD-01 next-function, diff-context and match-variable issues; confirmed
  overwritten scroll entries from live callbacks.
- `python3 -m unittest discover -s tests -p test_menu_contract.py`: **2 passed**.
  These static checks do not cover the runtime findings above.
- No application or third-party source changed. This is a backlog, not an
  implementation or certification of Windows GUI behavior.
