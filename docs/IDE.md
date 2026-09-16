# Integrated project workflows

Linux GVim is the target of this work. Existing tool-specific menus and upstream
plugins remain available.

## Project settings

Each GVim instance has one active project, identified by Vim's global working
directory (`:pwd` after a global `:cd`). Optional `.planetvim.vim`
exports a Vim9 `config` Dictionary; **Run → Project → Edit Private Settings**
opens a `.vim` override under PlanetVim's personal config directory. Both files
use the same structure and merge recursively; Lists replace Lists.

```vim
vim9script

export var config: dict<any> = {
  default: 'debug',
  defaults: {
    source_dir: '.',
    cwd: '.',
    args: ['argument with spaces'],
    environment: {APP_MODE: 'development'},
  },
  configurations: {
    debug: {build_dir: 'out/debug', build_type: 'Debug'},
    release: {build_dir: 'out/release', build_type: 'Release'},
  },
}
```

Use `:PlanetProjectSelect` to choose a configuration and `:PlanetProjectInfo` to
inspect it. `:PlanetProjectEdit` opens shared settings and `:PlanetProjectLocal`
opens private settings. Save the shared file, review its code, then use
**Run → Project → Trust and Load Shared Settings** (`:PlanetProjectReload!`).
This explicitly allows execution of that file's current contents for this
project, including subsequent GVim launches. A changed shared file requires
fresh approval. Private overrides load as normal personal Vim configuration.
Scripts have normal Vim permissions; approve only code you trust.

Settings execute once per loaded file, and subsequent requests receive copies
of the cached Dictionary. After editing, **Reload Settings**
(`:PlanetProjectReload`) reloads the current project's shared and private files
and refreshes its language-server selection. A changed shared script needs the
Trust and Load action again. Loading errors are reported and cached until reload;
they do not silently select default settings or repeatedly execute broken code.
Use script-local variables and compiled `def` helpers to compute `config`.
All tabs share this configuration. Native local vimrc files can set editor
options for the whole instance; the exported Dictionary describes tool and task
settings.

Environment values are Strings; `null` removes an inherited variable. Keep
secrets in private configuration. Project Info displays environment variable
names only. Defining a task does not run it; Run, Build and Debug actions remain
explicit.

Relative directories resolve from the instance's project root. A selected build
directory overrides that configuration's `build_dir` and is saved in private
state. Previous build directories and run profiles remain supported for projects
without these settings. Tab-local `:tcd` and window-local `:lcd` do not change project identity.

## Tabs, sessions and views

Start a separate GVim process from each unrelated project's root directory.
Use tabs and splits freely for files and views within that project. Native
`:tcd` and `:lcd` provide local navigation; all tabs retain the same build
configuration, run profiles, test history, tool environment and language servers.
A global `:cd` changes the active root for the entire instance. New Project
adopts its generated directory for the whole instance too; create a new GVim
window first when keeping the current project open.

Plain GVim launches from a project directory automatically resume its last
session and save every 30 seconds and on normal exit. Sessions → Save As… chooses
a named file to use for future autosaves and launches from that directory.
The startup screen lists recent sessions; `$HOME` launches stay unmanaged until
you explicitly save or open one. See [session management](GUIDE.md#sessions-recovery-and-environment).

The Sessions menu uses Vim's `:mksession` and `:source`. With the default
`sessionoptions` (`curdir` and `tabpages` included),
a session restores the global project directory, tabs, splits, files and editing
positions. Tab/window-local navigation directories are preserved independently.
Native `:mkview` and `:loadview` save individual windows' cursor positions, folds
and other `viewoptions`. Use a separate process when reopening an unrelated
project's session, so global editor and plugin settings start fresh.

Vim can load project-local `.vimrc` and `.gvimrc` files once at startup. For a
trusted project, opt into that native behavior before vimrc processing:

```sh
cd /path/to/project
gvim --cmd 'set exrc secure'
```

PlanetVim preserves this explicit `exrc` setting. `.vimrc` can configure plugin
globals before plugins load; `.gvimrc` can apply GUI/editor options afterwards.
Local vimrc files are executable configuration: enable them only for trusted
projects. Launch from the project root even when passing `-S Session.vim`, since
native local vimrc loading precedes session restoration. `:cd` and tab switches
do not source local vimrc files again. Optional `.planetvim.vim` remains the
Vim9 tool/task configuration described above, with its own explicit load action.

Language-server setup and run-menu rebuilding do not run on tab or buffer entry.
Configuration changes and global directory/session changes refresh the instance
as needed. Closed-tab recovery captures on close when Vim provides
`TabClosedPre`; the minimum supported version retains its `TabLeave` fallback
for native tab-close recovery. Projects per tab are a deferred idea in
[TASKS.md](../TASKS.md), awaiting further owner consideration.

## Tasks

Run → Tasks exposes configure/build/run/test/debug chains, task selection, last
task rerun, cancellation and results. `:PlanetTask build-run`, `build-test` and
`build-debug` stop immediately after an unsuccessful prerequisite. A task captures
project settings and environment; changing tabs cannot redirect later steps.
Tasks save modified source buffers within the project before starting (`save:
false` opts out). One task chain runs at a time in the GVim instance; its history, rerun and
cancellation actions are shared by all tabs. `jobs` sets CMake build parallelism
(default 2). `timeout` is seconds per step; zero means no time limit. Cancellation
signals the child process group on Linux and escalates to KILL after two seconds.
The project remains occupied until the cancelled command finishes.

Define or replace named tasks in a configuration's `tasks` Dictionary:

```vim
vim9script

export var config: dict<any> = {
  defaults: {
    tasks: {
      generate: {argv: ['python3', 'tools/generate.py']},
      check: {
        depends: ['generate'],
        argv: ['python3', '-m', 'unittest'],
        timeout: 120,
      },
    },
  },
}
```

Dependencies are checked for cycles before any process starts; shared dependencies
run once. `cwd` defaults to the project root. In native `argv` and `cwd`, `${root}`,
`${build}`, `${program}` and `${file}` expand as literal values. A deliberate shell
task may use `command` instead of `argv`; its text is passed unchanged to the
configured shell. Built-in Run/Debug use `program`, `args`, `cwd`, `python` and
`language` (`cpp` or `python`) from the selected project configuration.

## Command diagnostics

Compiler/build commands and Python commands capture raw output before terminal
wrapping. Each invocation retains a private log under state `task-logs/` and a
separate quickfix list tagged with its project, configuration and output buffer.
Run → Tasks → Show Diagnostics opens the latest project result, or the selected
output buffer's result. Open Raw Log retains the full original output even after
terminal scrollback has been discarded. Parsing examines the last 50,000 log
lines to bound memory; the raw log is complete.

The initial adapters handle GCC/Clang-style diagnostics (including tools such as
Clang-Tidy), source-located linker errors, CMake source errors, recursive Make
directories and Python traceback frames. Commands with other output formats keep
their raw output and exit status. Custom tasks can set `parser` to `compiler` or
`python`; an empty String disables parsing. No successful build inherits the
previous build's error list.

## Environments

Tool jobs and GUI launches receive a captured project environment. SDK activation
and compiler selection save overrides for the originating project/configuration,
even if another tab is active when activation finishes. Deactivation restores the
previous activation in that configuration during this GVim session. Manual process
environment editing remains available separately. `${root}` and `${env:NAME}` in
environment values expand the project root and inherited process value. They are
literal substitutions, not shell expressions. For example,
`PATH: '${root}/.venv/bin:${env:PATH}'` selects a Linux virtual environment.

Use `tools` to map tool names to executable paths or argv Lists, `python` for the
project interpreter argv, and `lsp` to override `clangd`/`pylsp` argv (an empty
List disables a server). The instance uses one `planet-clangd` registration and
one `planet-pylsp` registration, rooted at `source_dir` (the project root by
default). The native upstream event queue remains enabled. Tab switching does
not register or restart servers. Configuration selection, settings reload and
SDK/build-directory changes update the same registrations and restart their
processes only when needed. Use `:PlanetLspSetup` after manually changing server
command globals or an external environment.

## CMake presets and targets

Build → CMake offers Choose Preset, Choose Target, Choose Build Configuration
and Show Targets and Artifacts. `:PlanetCmakePreset`, `:PlanetCmakeTarget`,
`:PlanetCmakeConfiguration` and `:PlanetCmakeInfo` expose the same actions.
Configuration, preset, build directory and target selections persist privately.
A project configuration can also declare `preset`, `target` and `build_type`.

Use CMake 3.20+ for these workflows and Python 3 for preset discovery. CMake
validates and lists available configure presets from `CMakePresets.json`,
`CMakeUserPresets.json` and their includes. Preset inheritance, environment
references and path macros determine the build directory. Configure passes the
selected preset to CMake; explicit selected build directories override its
`binaryDir`. Preset environments apply to the following build/run/test/debug
steps. Build/test preset objects and CMake workflow presets are not imported as
PlanetVim tasks; define custom tasks when those additional preset options matter.

Configure places a File API query in the build tree. Target selection and
Run/Debug read CMake's returned artifact paths, including multi-configuration
and custom runtime-output directories. If several executables exist, select
one; a library target cannot run. An explicit `program` overrides discovery.
Build and Test builds all targets before CTest, since test executables may be
separate from the selected application. Build and Run/Debug build the selected
target. A failed prerequisite prevents launching an old executable.

Configure requests `compile_commands.json`; generators supporting it provide
clangd with the selected build directory automatically. No database is copied
into the source tree. Successful configuration refreshes the
instance's language-server command when its compilation database changes. The selected-target debugger launch
uses an ephemeral Vimspector configuration; existing manual `.vimspector.json`
actions remain available and the file is never overwritten.

## Implementation milestones

- IDE-01: shared settings, private overrides and selected configuration.
- IDE-02: project environments for tool jobs and language servers.
- IDE-03: named tasks, dependency workflows and cancellation.
- IDE-04: diagnostic adapters and retained per-invocation quickfix results.
- IDE-05: CMake presets, target discovery and build/run/debug context.

See [the acceptance record](ACCEPTANCE.md) for tested GVim/tool versions,
real workflows and remaining external/platform limits.
