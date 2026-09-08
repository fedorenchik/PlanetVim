# PlanetVim completion review

Reviewed on 2026-09-07 at commit `f75c805a1896c378f3c2d119efd9f9a1da5cb78d`
(2022-11-04, “Update PyInstaller Menus”).

## Assessment

PlanetVim has substantial implementation: GUI menus, three editing modes,
project/build helpers, terminal output, Git integration, sessions, and bundled
language and writing plugins. It is not ready for a public test release yet.
The immediate work is to protect user files and make existing workflows reliable.
Adding more plugins would not address the main gaps.

The review uses the README's GVim product description as the intended scope.
Terminal Vim and Neovim compatibility are not assumed requirements. The proposed
implementation order and completion criteria are in [TASKS.md](TASKS.md).

## Scope and verification

- Inspected the root installer/configuration/documentation, the Planet package
  group's runtime, command helpers/templates, and relevant bundled plugin APIs.
- Inventory: 122 package directories, including 121 `start` packages and one
  `opt` package; 118 `.gitrepo` files already record upstream commits. The Planet
  group contains 44 Vim files, including its Vim plugin template, with 4,316 lines;
  the root `.vimrc` adds 1,110 lines. There are 13 first-party command helpers.
- Ran isolated checks using Vim 9.2 (patches 1–849), compiled with GTK3 GUI support, in
  headless mode; used a terminal session for the Save & Exit confirmation test.
  Fixtures and generated output were confined to `/tmp`.
- The startup check sourced `.vimrc` and first-party plugin files in loading
  order, with bundled runtime paths available, a temporary custom config,
  `/bin/sh`, and autocommands suppressed. It found no source errors in that
  controlled setup, but did reproduce option overwrites. This was not a full
  GUI/all-plugin startup certification.
- Tested the install deletion behavior with `rsync --dry-run`; did not install
  over the user's Vim configuration. Project-generator tests used stub `git`
  and `npm` commands, with no downloads. Git tests intercepted command execution.
- Did not launch the GUI, install language servers/debug adapters, build every
  advertised framework, or perform a vulnerability audit of all vendored code.
  These remain explicit acceptance work rather than claimed passing tests.
- This review changes documentation only. The defects below remain open.

## Confirmed findings

### R1 — P1: Save & Exit can discard unsaved edits

Confidence: 10/10. Source:
`.vim/pack/planet/start/planet.vim/autoload/planet/planet.vim:319-321`.

```vim
confirm wall
qa!
```

Reproduction: edit a temporary file, mark the buffer read-only, invoke
`planet#planet#SaveExit()`, and answer No to writing the read-only file. Vim exits
with status 0 while the buffer is still modified; the file on disk retains the
old contents. The unconditional forced quit defeats the save refusal.

Fix direction: exit only after the intended saves succeed or after an explicit
discard decision. Refused/cancelled/failed saves must leave the editor open.
Task: **PV-001**.

### R2 — P1: installation deletes unrelated Vim files

Confidence: 10/10. Source: `Makefile:10-15,24-26`.

```make
RSYNC_OPTIONS := -aHAX --delete-missing-args --delete-after
```

The install recipe synchronizes directly into the user's `.vim` and replaces
`.vimrc`, without a backup or ownership manifest. With an existing fixture file
`.vim/plugin/user-owned.vim`, the exact rsync options produced:

```text
*deleting   plugin/user-owned.vim
*deleting   plugin/
```

The exclusions protect several PlanetVim state paths, but do not protect arbitrary
user plugins, snippets, dictionaries, or configuration. `uninstall` is a TODO.
Task: **PV-002**.

### R3 — P1: command arguments and working directories are unreliable

Confidence: 10/10. Sources:
`.vim/pack/planet/start/planet.vim/autoload/planet/term.vim:36-40` and
`.vim/pack/planet/start/planet.vim/bin/run-command:3-12`.

```vim
let l:cmd_cd = 'cd ' .. a:cd .. ' ; '
let l:ret = term_start(s:bin_dir .. 'run-command ' .. l:cmd_cd .. a:cmd, l:term_opts)
```

The wrapper then performs `cd "$1"` without checking success and runs `eval "$@"`.
Isolated execution confirmed:

- A command with argument `"two words"` receives two arguments, `two` and `words`.
- A build directory containing spaces fails to select the intended directory.
- A nonexistent build directory still executes the command in the old directory.

This affects build, run, Git, and template actions sharing the runner. Preserve
argument boundaries, use the job's working-directory option, and reject invalid
directories before starting work. Provide a distinct explicit-shell path for
commands that intentionally contain pipelines or shell syntax. Task: **PV-003**.

### R4 — P1: failed commands are reported to Vim as successful jobs

Confidence: 10/10. Source:
`.vim/pack/planet/start/planet.vim/bin/run-command:12-15`.

```bash
eval "$@"
exit_status=$?
echo "Exit status: $exit_status"
```

Running `false` prints `Exit status: 1`, but the wrapper ends with the successful
`echo`, so `job_info(...).exitval` is 0. The output text is accurate; the process
result is not. Return the command status and expose failure/cancellation to the
UI and any dependent action. Task: **PV-004**.

### R5 — P1: startup overwrites user settings and part of Easy Mode

Confidence: 10/10. Sources:
`.vim/pack/planet/start/planet.vim/plugin/planet.vim:47-65`,
`plugin/settings.vim:5,71,91,148,181`, and
`autoload/planet/planet.vim:127-154` within the same package.

`plugin/planet.vim` sources the user's config and applies the chosen mode.
`plugin/settings.vim` runs afterwards and unconditionally applies defaults.
With a custom config selecting Easy Mode and setting tab/shift widths to 3, the
final values were:

```text
PV_mode=e; insertmode=1; keymodel=""; backspace=start
tabstop=8; shiftwidth=8
```

Easy Mode initially sets `keymodel=startsel,stopsel` and
`backspace=indent,eol,nostop`; those settings do not survive startup. Standard
Mode also erases custom mappings for keys such as `b`.
Define and test defaults → mode → user overrides, including mode changes and
restarts. Task: **PV-005**.

### R6 — P1: the configured test backend is absent

Confidence: 10/10. Sources: `.vimrc:1095` and
`.vim/pack/basic/start/vim-test/autoload/test/strategy.vim:64-65`.

```vim
let test#strategy = "dispatch"
```

The selected strategy executes `Dispatch`, but vim-dispatch is not bundled and
PlanetVim defines no substitute. A clean isolated invocation produced
`E492: Not an editor command: Dispatch true`. Nearest/file/suite menu entries
therefore depend on an undeclared plugin. Task: **PV-007**.

### R7 — P1: advertised development actions are placeholders

Confidence: 9/10, established by tracing menu definitions and bundled APIs.
Source: `.vim/pack/planet/start/planet.vim/autoload/planet/menu/dev.vim`.

- Debug Start/Detach/Stop at lines 582-584 all call `:Vimspector`. Vimspector is
  in `apps/opt`, there is no first-party `packadd vimspector`, and that bare
  command is not the bundled plugin's launch/stop API even when loaded.
- Analysis actions at lines 630-663, including Clang-Tidy and Cppcheck, also call
  `:Vimspector` rather than their named tools.
- Deployment/package actions at lines 547-565 call `:!make`, regardless of label.
- Framework test actions at lines 612-620 call `:TestVisit`, which is navigation,
  rather than executing the named test tool. Kernel test entries use `:TODO`.
- Generate configure.ac at line 393 uses `planet#project#CopyFile`, whose body
  is empty in `autoload/planet/project.vim:5-6`.

Implement each supported action and make its behavior match its label. Planned
features must be visibly unavailable until implemented. Tasks: **PV-008, PV-009,
PV-017**.

### R8 — P2: filetype mappings leak into other buffers

Confidence: 10/10. Sources: `.vimrc:283-294,1106-1107`.

```vim
autocmd FileType markdown nnoremap <silent> <A-t> :Vista!! toc<CR>
```

After opening Markdown and then a fresh C++ buffer, Alt-T still calls the Markdown
TOC backend instead of `vim_lsp`. C/C++ abbreviations and the `;;` insert mapping
are similarly created globally. Use buffer-local definitions and test different
file-opening orders. Task: **PV-012**.

### R9 — P2: several core menus invoke the wrong or missing target

Confidence: 9-10/10. Under
`.vim/pack/planet/start/planet.vim/autoload/planet/`:

- `menu/tools.vim:430` calls `<SID>XxdToHex()` from the menu script, but the
  script-local function lives in `tools.vim:3`. Clicking the action raises E117.
- `menu/nav.vim:243` omits `()` from `call planet#gui#VimServerStart`, raising E107.
- `menu/planet.vim:25` wires Settings Menus to `NavigationToggle()`.
- `menu/nav.vim:265` removes a different buffer-menu name from the one created;
  the Buffers menu remains when Navigation is disabled.
- `term.vim:167` generates `e {buffer-number}` for saved output. A fixture with
  output buffer 2 opens an ordinary file named `2`, not the terminal buffer.
- `menu/dev.vim:400-406` calls `planet#env#SenEnvVar`; the implementation is named
  `planet#env#SetEnvVar`.

A callable-target check should be supplemented with behavior checks: a command
can exist yet still do the wrong thing. Task: **PV-013**.

### R10 — P2: restoring a closed tab can restore the wrong tab

Confidence: 9/10. Sources:
`.vim/pack/planet/start/planet.vim/plugin/autocmds.vim:28` and
`autoload/planet/tab.vim:30-46`.

Every `TabLeave` overwrites one shared `tmp.tab.vim`. Reopen performs `tabnew`
before reading it, triggering another `TabLeave`. In a two-tab fixture, closing
`b.txt` and reopening it produced two `a.txt` tabs. The reproduction used the
original code with only its two hardcoded storage paths redirected to `/tmp`.
Multiple GVim processes also share that same snapshot path.
Capture the correct snapshot and isolate restoration from snapshot-writing
events. Task: **PV-015**.

### R11 — P2: run profiles cannot preserve ordinary quoted arguments

Confidence: 10/10. Source:
`.vim/pack/planet/start/planet.vim/autoload/planet/run.vim:11-13,22-23`.

Profiles are comma-separated strings, then inserted directly into quoted Vim
expressions in menu commands. A profile `./app "two words"` raises E116 when
executed. Commas also cannot be represented reliably as part of an argument.
Use structured profile data and callbacks/identifiers that do not embed raw user
input in executable Vim expressions. Task: **PV-016**.

### R12 — P2: project generators produce inconsistent layouts

Confidence: 10/10 for the isolated stubbed scenarios. Sources:
`.vim/pack/planet/start/planet.vim/bin/create-electron-project:6-15` and
`bin/copy-template:10-13`.

The Electron helper falls through into the template-copy fallback after a
successful clone/install/start branch, from inside the new directory. The test
created `myapp/myapp/package.json`. When rsync is absent, copying into a
preexisting destination with `cp -r` nests the template directory, unlike the
rsync path. Separate success/fallback paths and define one output layout.
Task: **PV-017**.

### R13 — P2: automatic commit uses the wrong write event

Confidence: 10/10. Source:
`.vim/pack/planet/start/planet.vim/autoload/planet/git.vim:37-40`.

The feature registers `FileWritePost`. A normal `:write` triggered no commit;
a partial-range write triggered a commit of the original buffer path. Use the
appropriate buffer-write event and resolve the actual written file/repository.
Tests must intercept Git before any real commit or push. Task: **PV-018**.

### R14 — P2: settings persistence depends on fragile shell edits

Confidence: 10/10. Source:
`.vim/pack/planet/start/planet.vim/autoload/planet/planet.vim:3-17`.

The `grep` check accepts an indented `let` statement while the replacement only
matches `^let`, so a valid indented setting silently stays unchanged. A configured
filename containing a space remained unchanged while an unintended truncated
filename was created. Use structured serialization and native file I/O with
failure handling. Avoid rewriting arbitrary hand-authored config. Task: **PV-014**.

### R15 — P2: moving a character selection removes entire lines

Confidence: 10/10. Sources:
`.vim/pack/planet/start/planet.vim/autoload/planet/selection.vim:3-9,24-25`
and `autoload/planet/menu/basic.vim:281-284` in the same package.

The helper acknowledges that it only works linewise, but the exposed Write,
Append, and Move Selection menu actions do not state that restriction. It yanks
and deletes the Ex range `"'<,'>"`. Selecting only `selected` in
`prefix selected suffix` and invoking Move exported and removed the entire line,
including the unselected prefix and suffix. Preserve the exact selection shape,
or make the limitation explicit until that is supported. Task: **PV-011**.

## Completion gaps beyond the reproduced defects

- **Prerequisites and support policy:** `.vimrc:31-43` contains an approximate
  version requirement and a dependency-check TODO. `detect.vim` only checks a
  short list; there is no documented complete first-run health/setup flow.
  Font, desktop utilities, language servers, debug adapters, and writing tools
  need explicit treatment. See **PV-010**.
- **Completion setup:** non-LSP asyncomplete adapters are bundled without
  first-party registration. The LSP bridge does register its sources, so this
  is not a claim that all completion is broken. See **PV-019**.
- **State and recovery:** settings hardcode a personal spellfile under
  `$HOME/src/homerc` and disable swap/write-backup; session/tab paths are shared
  and home-relative. Define configurable private state paths and deliberate
  crash-recovery behavior without cluttering project directories. See **PV-021**.
- **Verification:** no root CI workflows or distribution-level tests were found.
  Bundled upstream tests do not verify PlanetVim integration. See **PV-006**.
- **Maintenance:** existing `.gitrepo` pins are useful. What is missing is a
  documented update/retest/provenance process and measured startup budget for
  the 121 automatic packages. No performance regression is asserted here.
  See **PV-022**.
- **Release readiness:** README has no install quickstart and several empty
  guides; CHANGELOG is empty; there is no top-level project license. The owner
  must choose the license for first-party work while retaining upstream notices.
  See **PV-023, PV-024**.

## Reference checks

The installed source and isolated reproductions are the primary evidence.
[Vim's startup reference](https://vimhelp.org/starting.txt.html#load-plugins)
documents plugin initialization order, and the
[rsync manual](https://download.samba.org/pub/rsync/rsync.1) documents destination
deletion semantics. Plugin contracts were checked against the bundled versions,
not assumed from the latest upstream APIs.
