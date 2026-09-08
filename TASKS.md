# PlanetVim completion tasks

Based on the [2026-09-07 code review](REVIEW.md), commit `f75c805a`.
Implementation started on 2026-09-08. Checkboxes record implemented work;
acceptance limitations are recorded beside the relevant task.

## Agreed platform and dependency policy

- GVim only. Terminal Vim and Neovim are outside the product scope.
- Linux is the primary platform; Windows GVim is the secondary platform.
- macOS is excluded because its GUI implementation differs.
- Third-party plugin source is not patched locally. Upstream updates or
  replacement plugins are allowed when justified and verified.
- Implement and verify changes in small, focused commits.

## Definition of complete

A new user on a documented supported GVim platform can safely install PlanetVim,
choose any advertised editing mode, customize it, edit/navigate/build/run/test/debug
a supported project, use the supported writing workflows, save/reopen their work,
and update or uninstall without losing their previous configuration. Enabled
menus do what their labels say. Missing optional tools produce useful guidance.
These behaviors are covered by automated checks and a recorded GUI acceptance run.

The README's full ecosystem list remains the product scope to reconcile. Suggested
first acceptance fixtures are C++/CMake, Python, Markdown, and LaTeX; testing those
first does not establish that the other advertised integrations work. For a full
release, implement and test every feature retained as supported. Deferring a
feature requires an explicit status change in the menus and documentation.

P1 means a safety, core workflow, or public-release blocker. P2 means required
completion/polish for a feature retained in the supported release. The milestones
below give implementation order; independent tasks can proceed in parallel.
Keep changes in focused commits and include a regression check with each bug fix.

## Milestone 1 — Protect data and stabilize the core

### PV-001 · P1 · Preserve edits when Save & Exit cannot save

- [ ] Replace unconditional forced exit after `confirm wall` with a flow that
  respects refusal, cancellation, and write errors. See review **R1**.

Done when: successful saves exit normally; read-only refusal, cancelled unnamed
file saves, unavailable destination, and one failing buffer among several keep
all unsaved edits available. Tests assert both disk and buffer contents.

### PV-002 · P1 · Make install, update, and uninstall preserve user files

- [ ] Replace unrestricted mirroring into the user's `.vim` with explicit
  ownership of installed paths. Back up replaced configuration, support a
  selectable destination and preview, implement uninstall/restore, and propagate
  every failed copy/setup step. Separate user installation from the maintainer
  `all: commit pull push install` target. See **R2** and `Makefile`.

Done when: clean install, repeat install, upgrade, and uninstall work in disposable
destinations. Existing `.vimrc`, plugins, snippets, state, and custom config remain
recoverable. Paths with spaces work. An interrupted/failed update reports failure
without pretending installation succeeded. No user install performs Git commits
or pushes. Preview proves exactly which files change.

### PV-003 · P1 · Preserve command arguments and use an explicit working directory

- [ ] Refactor the common runner and its build/Git/helper callers to preserve
  argument boundaries, distinguish argv commands from intentional shell scripts,
  and use a validated job working directory. See **R3**.

Done when: quoted arguments, spaces, apostrophes, Unicode, and leading-dash
filenames reach the intended program unchanged. Missing/cancelled directories
execute nothing. Project and installation paths containing spaces work. Existing
intentional pipelines still work through the explicit shell interface.

### PV-004 · P1 · Preserve process failure and cancellation results

- [ ] Return the child exit code from `run-command`; propagate results to output
  handling and dependent steps. Define stop/cancel and output-retention behavior.
  See **R4**. Coordinate the runner interface with **PV-003**.

Done when: a command exiting 7 gives Vim a job status of 7, a missing executable
reports failure, cancellation is distinguishable from success, and a failed
configure/install step cannot trigger a success-only build/run step. The visible
output retains the command, working directory, and actual status.

### PV-005 · P1 · Make defaults, editing modes, and user overrides deterministic

- [ ] Move defaults before mode selection and user overrides; define what happens
  to custom mappings during a mode change. Avoid resetting user preferences on
  restart or repeated initialization. See **R5**.

Done when: Easy, Standard, and Supercharged modes each work immediately and after
restart. Easy Mode retains its selection/backspace behavior. Custom indentation,
font, and mappings survive as documented. Test all mode transitions and custom
config enabled/absent/error cases.

### PV-006 · P1 · Add distribution-level tests and continuous integration

- [ ] Establish isolated Vimscript/shell fixtures and one repeatable test command;
  add root CI. Start with **PV-001–005** reproductions and add regression coverage
  as the following tasks land. Use a private fixture environment/state tree.

Done when: CI checks installer preservation, startup, settings precedence,
command argv/cwd/status, mapping scope, menu targets, and session persistence.
Test the declared minimum and current supported GVim versions, including a GUI
smoke job with a virtual display. Tests never depend on personal plugins or
change real user configuration, repositories, or network accounts.

## Milestone 2 — Make a supported development workflow usable

### PV-007 · P1 · Connect test menus to an available runner

- [ ] Select vim-test's supported built-in terminal strategy or deliberately
  bundle/configure Dispatch. Wire Nearest/File/Suite/Last/Visit to their intended
  behavior. See **R6**; validate against **PV-004** result handling.

Done when: a clean installation executes a passing and a failing sample test,
shows usable output, reruns the last test, and visits the correct source file
without E492 or an undeclared plugin dependency.

### PV-008 · P1 · Complete debugger setup and core actions

- [ ] Load Vimspector deliberately, provide adapter setup, and connect Start,
  Stop, Detach, Continue, Breakpoint, and Step actions to the bundled APIs.
  Include sample configurations for initially supported languages. See **R7**.

Done when: the documented Python and C++ fixtures can launch, stop at a breakpoint,
inspect variables, step, stop, and launch again. Missing Python support/adapters
give setup guidance. Debugger availability is checked by **PV-010**.

### PV-009 · P1 · Audit every advertised menu action and feature claim

- [ ] Inventory actions and label them implemented, incomplete, or planned.
  Replace wrong-command placeholders with the named tool's workflow; disable and
  explain unimplemented actions until they are complete. Reconcile the README's
  ecosystem list with actual supported workflows. See **R7**.

Done when: no enabled action calls `TODO`, an empty helper, or an unrelated command
such as `make` for deployment or `TestVisit` for CTest. Every retained supported
integration has a fixture/manual acceptance recipe covering prerequisites,
normal operation, failure, and cancellation. Deferred features have visible
status and are excluded from supported-feature claims.

### PV-010 · P1 · Define support requirements and add a first-run health check

- [ ] Declare supported OS/GUI builds and an exact tested minimum Vim version and
  feature set. Implement a health command for core tools, optional integrations,
  fonts, language servers, adapters, and writable state paths. Surface setup
  guidance at first run and when an unavailable action is invoked.

Done when: a fresh supported machine can identify every missing prerequisite.
Optional missing tools do not break startup. The font/rendering setup displays
menus and Fern icons correctly or supplies a readable fallback. The doctor checks
actual enabled workflows, not merely the current short `detect.vim` list.

## Milestone 3 — Complete everyday editing and project behavior

### PV-011 · P2 · Preserve the exact selection during export and move

- [ ] Support characterwise, linewise, and blockwise selection export/move;
  preserve unselected text and only remove source text after a successful write.
  Make append/overwrite behavior explicit. See **R15**.

Done when: selecting `selected` within `prefix selected suffix` moves only that
word, not the full line. Block selections preserve surrounding columns. Cancelling
or failing the destination write leaves the source unchanged; overwriting an
existing destination follows the user's explicit choice.

### PV-012 · P2 · Keep filetype behavior local to its buffer

- [ ] Add buffer scope to Markdown outline mappings and C/C++ mappings and
  abbreviations; audit all FileType hooks for similar leaks. See **R8**.

Done when: opening Markdown, C++, Python, and text in any order does not change
another buffer's typing or outline behavior. Closing a buffer leaves no global
mapping residue. Tests inspect mappings and exercise actual keystrokes.

### PV-013 · P2 · Repair core menu wiring and output navigation

- [ ] Fix HEX function scope, VimServerStart parentheses, Settings toggle target,
  menu names used for removal, output-buffer selection, and `SenEnvVar` typos.
  Audit remaining core menu callbacks and buffer-list updates. See **R9**.

Done when: enabling/disabling each menu group round-trips without leftovers;
HEX conversion works; output entries open the intended terminal; environment
dialogs invoke the correct helper; buffer rename/delete/list refresh works.
Also fix or remove the unused `AddBuffers()` helper's undefined `num` variable
before wiring it into refresh behavior.

### PV-014 · P2 · Store preferences without rewriting arbitrary shell text

- [ ] Separate generated preferences from hand-authored customization, serialize
  values safely, and use native file I/O with atomic replacement and visible
  errors. Preserve existing user content and define concurrent-instance behavior.
  See **R14**; depends on the configuration order from **PV-005**.

Done when: settings round-trip across restarts, indented valid configuration and
paths with spaces work, unrelated settings/comments survive, and read-only/full
storage errors do not destroy the last valid configuration.

### PV-015 · P2 · Correct session and closed-tab restoration

- [ ] Capture the actual closing tab and prevent restoration events from
  overwriting its snapshot. Isolate state between GVim processes, preserve
  session options with cleanup on errors/cancellation, and escape session names.
  See **R10**; coordinate state locations with **PV-021**.

Done when: close/reopen restores the correct buffers, windows, cursor, and view;
two running instances do not overwrite each other; session names with spaces
work; cancelling save/open leaves the prior session and options intact.

### PV-016 · P1 · Make build directories and run configurations dependable

- [ ] Use structured run profiles with command/arguments/cwd instead of comma
  splitting and embedded Vim expressions. Validate build-directory selection,
  cancellation, and project switching; persist profiles at the documented scope.
  See **R11**, `autoload/planet/build.vim`, and **PV-003–005**.

Done when: a small CMake fixture configures in-tree and out-of-tree, builds,
generates `compile_commands.json`, and runs with quoted/comma-containing arguments.
Selecting an invalid index or cancelling directory creation changes nothing.
Switching projects cannot accidentally run in the previous project's build tree.
Errors are navigable from output or quickfix.

### PV-017 · P2 · Finish and test project creation helpers

- [ ] Correct Electron success/fallback flow, make cp/rsync layouts equivalent,
  and implement advertised CopyFile/CopyDir operations. Validate destinations and
  propagate clone/install/copy failures. Audit the other template helpers using
  the same checks. See **R7, R12**.

Done when: each exposed template produces exactly one project at the selected
destination, including when paths contain spaces. Existing nonempty destinations
are handled deliberately, cancellation creates nothing, dependency failures stop
the flow, and the result can build/start according to its own instructions.
Stub external installers in unit tests; perform separate supported-tool smoke tests.

### PV-018 · P2 · Correct Git event handling and command semantics

- [ ] Use the correct write event for opt-in auto-commit, bind commands to the
  actual file/repository, preserve filenames/messages, and separate commit,
  status, and optional push results. Respect cancelled prompts and failed writes.
  See **R13** and the shared runner tasks.

Done when: normal save commits once only when enabled; partial writes and non-file
buffers do not commit another file; commit failures stay visible; push occurs
only through an explicitly selected push behavior. Verify in disposable local
repositories with network operations stubbed.

### PV-019 · P1 · Complete language intelligence and completion defaults

- [ ] Choose and register the intended completion sources; preserve the existing
  LSP source-registration bridge and verify it end to end; provide reproducible
  language-server setup and project-root detection.
  Integrate definition, references, hover, diagnostics, rename, and formatting
  for supported development fixtures. Treat snippets as a separate scoped feature.

Done when: supported C++ and Python fixtures have usable completion/navigation
and diagnostics; missing servers produce guidance; intended buffer/path fallback
completion works without a server; sources do not produce duplicate results.
External/cloud-backed completion is a documented optional choice.

### PV-020 · P2 · Verify the advertised writing workflows

- [ ] Complete Markdown and LaTeX edit/preview/build/error-navigation flows;
  configure spell/grammar tools and dictionaries portably; document their optional
  prerequisites and chosen defaults. Coordinate with **PV-010, PV-021**.

Done when: a sample Markdown document previews and a sample LaTeX document builds
and opens output; errors lead to the relevant source; missing converters/viewers
or LanguageTool give actionable messages; personal spelling survives updates.

### PV-021 · P2 · Centralize state paths and define recovery behavior

- [ ] Replace personal paths such as `$HOME/src/homerc` with configurable
  configuration/state/cache directories. Create required directories safely and
  define private backup/swap/undo/session storage plus crash-recovery behavior.
  Preserve the README promise not to clutter project directories.

Done when: a new account, spaces in paths, two editor instances, and unwritable
state storage are handled predictably. Undo/spelling/session data survive restarts
and updates; a documented crash recovery test succeeds for the chosen policy.
Project trees receive no unexpected editor-state files.

## Milestone 4 — Make the distribution maintainable and releasable

### PV-022 · P2 · Establish plugin maintenance and measure startup

- [ ] Build a documented inventory from the existing `.gitrepo` pins, including
  source, revision, license, local patches, and optional native dependencies.
  Define an update/retest process. Profile startup/file-open behavior before
  selecting candidates for optional/lazy loading.

Done when: a checkout reproduces the supported plugin set, one plugin can be
updated with its integration checks, upstream notices remain intact, and native
build steps are repeatable. Record a startup budget and comparable measurements
on documented hardware; optimization must preserve menu availability and behavior.

### PV-023 · P1 · Finish onboarding, built-in help, and contributor guidance

- [ ] Write installation/update/uninstall/recovery instructions, quickstart,
  editing-mode/keybinding guide, customization precedence, prerequisites, and
  troubleshooting. Add `:help planetvim`, current screenshots, and working project
  walkthroughs. Document tests, architecture, and how to add an integration.

Done when: a new user can complete the definition-of-complete journey using only
the docs. README menu names match the actual UI. Empty Vim/Kernel/Godot sections
are completed or clearly identified as pending scope under **PV-009**. Bug reports
can include a sanitized health report and exact distribution version.

### PV-024 · P1 · Validate and publish a defined release

- [ ] Have the project owner choose the first-party license; retain third-party
  attribution. Establish version/tag/changelog conventions and release packaging.
  Run the supported-workflow acceptance matrix after preceding tasks are complete.

Done when: a release candidate installs from its published artifact, passes CI and
a recorded real-GVim GUI run, supports every feature it claims, and has no open
P1 defects. Installation, upgrade from the previous candidate, and uninstall are
verified. Release notes list tested platforms, dependencies, known limitations,
and changes; the tagged version matches the artifact and visible version.

## Scope to decide before expanding the release

Do not automatically turn every historical TODO into a launch requirement.
Decide which advanced kernel analyzers, deployment/packaging targets, desktop
automation tools, cloud completion sources, and snippets belong in the supported
release. Preserve their planned status explicitly until they pass **PV-009**.
Linux GVim comes first, then Windows GVim. macOS, terminal Vim, and Neovim are
excluded. Linux-only tools must be identified and unavailable actions explained
on Windows rather than silently invoking Linux commands.

Suggested first implementation sequence: **PV-001 → PV-002 → PV-003 → PV-004 →
PV-005**, with **PV-006** capturing their regressions and **PV-010** defining the
environment. Then complete one C++/CMake and one Python workflow through
**PV-007, PV-008, PV-016, PV-019** before expanding the acceptance matrix.
