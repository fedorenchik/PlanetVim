# Integrated project workflows

Linux GVim is the target of this work. Existing tool-specific menus and upstream
plugins remain available.

## Project settings

A tab's working directory remains its project identity. Optional `.planetvim.json`
contains declarative shared settings; **Run → Project → Edit Private Settings**
opens a private override under PlanetVim's config directory. Both files use the
same structure and merge recursively; arrays replace arrays. No command runs
merely because a settings file is read. Run, build and debug actions remain explicit.

```json
{
  "version": 1,
  "default": "debug",
  "defaults": {
    "source_dir": ".",
    "cwd": ".",
    "args": ["argument with spaces"],
    "environment": {"APP_MODE": "development"}
  },
  "configurations": {
    "debug": {"build_dir": "out/debug", "build_type": "Debug"},
    "release": {"build_dir": "out/release", "build_type": "Release"}
  }
}
```

Use `:PlanetProjectSelect` to choose a configuration and `:PlanetProjectInfo` to
inspect it. `:PlanetProjectEdit` opens shared settings and `:PlanetProjectLocal`
opens private settings. The menu exposes all four commands. Environment values
are Strings; `null` removes an inherited variable. Keep secrets in private
configuration. Project Info displays environment variable names only.

Relative directories resolve from the tab's project root. A selected build
directory overrides that configuration's `build_dir` and is saved in private
state. Previous build directories and run profiles remain supported for projects
without these settings. A window-local `:lcd` does not change project identity.

## Implementation milestones

## Tasks

Run → Tasks exposes configure/build/run/test/debug chains, task selection, last
task rerun, cancellation and results. `:PlanetTask build-run`, `build-test` and
`build-debug` stop immediately after an unsuccessful prerequisite. A task captures
project settings and environment; changing tabs cannot redirect later steps.
Tasks save modified source buffers within the project before starting (`save:
false` opts out). One chain per project runs at a time, with at most two project
chains by default (`g:PV_task_concurrency`). `jobs` sets CMake build parallelism
(default 2). `timeout` is seconds per step; zero means no time limit. Cancellation
signals the child process group on Linux and escalates to KILL after two seconds.

Define or replace named tasks in a configuration's `tasks` object:

```json
{
  "defaults": {
    "tasks": {
      "generate": {"argv": ["python3", "tools/generate.py"]},
      "check": {"depends": ["generate"], "argv": ["python3", "-m", "unittest"], "timeout": 120}
    }
  }
}
```

Dependencies are checked for cycles before any process starts; shared dependencies
run once. `cwd` defaults to the project root. In native `argv` and `cwd`, `${root}`,
`${build}`, `${program}` and `${file}` expand as literal values. A deliberate shell
task may use `command` instead of `argv`; its text is passed unchanged to the
configured shell. Built-in Run/Debug use `program`, `args`, `cwd`, `python` and
`language` (`cpp` or `python`) from the selected project configuration.

Tool jobs and GUI launches receive a captured project environment. SDK activation
and compiler selection save overrides for the originating project/configuration,
even if another tab is active when activation finishes. Deactivation restores the
previous activation in that configuration during this GVim session. Manual process
environment editing remains available separately. `${root}` and `${env:NAME}` in
environment values expand the project root and inherited process value. They are
literal substitutions, not shell expressions. For example,
`"PATH": "${root}/.venv/bin:${env:PATH}"` selects a Linux virtual environment.

Use `tools` to map tool names to executable paths or argv arrays, `python` for the
project interpreter argv, and `lsp` to override `clangd`/`pylsp` argv (an empty
array disables a server). Configured projects receive separate first-party LSP
registrations and environments; switching buffers selects the applicable pair.

- IDE-01: shared settings, private overrides and selected configuration.
- IDE-02: project environments for tool jobs and language servers.
- IDE-03: named tasks, dependency workflows and cancellation.
- IDE-04: diagnostic adapters and retained per-invocation quickfix results.
- IDE-05: CMake presets, target discovery and build/run/debug context.

Acceptance results are recorded after validating the complete implementation.
