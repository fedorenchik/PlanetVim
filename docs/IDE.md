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
