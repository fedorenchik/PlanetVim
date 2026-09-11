# Contributing to PlanetVim

The supported product is Linux GVim first and Windows GVim second, version 9.1.0016 or newer. Do not introduce macOS, terminal Vim, or Neovim branches without a separate scope decision. Keep menu actions enabled and implement the operation their labels describe. Missing optional tools need useful setup guidance.

## Code layout

- `scripts/planetvim.vim` is the checkout/installed entry point; `.vimrc` configures bundled plugins.
- `.vim/pack/planet/start/planet.vim` contains first-party `autoload/planet/`, `plugin/`, `bin/`, `data/`, `templates/`, and `doc/` files.
- The title, tab-label, and tab-tooltip packages under `.vim/pack/planet/start/` are also first-party.
- Other packages are upstream snapshots. Retain their notices; update or replace them through the workflow in [docs/PLUGINS.md](docs/PLUGINS.md). Do not patch vendored source locally.
- `tests/` contains isolated Vimscript/Python fixtures and opt-in real-tool acceptance checks.

## Vim9 runtime code

Use `vim9script` and compiled `def` functions for first-party Vim code. An
`export def Open()` in `autoload/planet/example.vim` remains callable as
`planet#example#Open()` from legacy mappings, plugins, and personal configuration.
Keep stable public names. Use concrete types where the contract is fixed;
`any` is appropriate at validated JSON, optional argument, and plugin boundaries.
Prefer compiled lambdas to string expressions in `map()` and `filter()`.

The entry point keeps a small legacy feature/version guard so unsupported Vim
builds receive the existing error before parsing Vim9 code; its setup function
is compiled. Lowercase compatibility APIs use `legacy def! planet#planet#f()`:
`legacy` permits the existing name, while the body is still compiled Vim9.
Native mappings, commands, menus, and autocmds retain their native syntax.
The sole legacy function, `LocalPreviewTag`, supplies legacy context to native
`:ptag` because Vim 9.1 otherwise parses numeric tag-file addresses as Vim9
ranges (even through `:legacy ptag`). Its surrounding helper is compiled.
Borrowed syntax definitions and all upstream plugin sources remain unchanged.

Vim9 checks all branches when compiling a function. Read optional post-9.1
options with guarded `eval()` and invoke optional commands with `execute` so
compilation also succeeds on GVim 9.1.0016. Preserve explicit buffer/window-local
option scopes. Compare numeric counts and IDs with zero rather than treating
arbitrary integers as booleans. Use `<script>` for the defining source path,
and explicit arguments when crossing into Python or executing a ranged command;
compiled local variables are not legacy `l:` dictionary entries.

`tests/test_vim9.vim` compiles the loaded first-party functions, including
optional actions, and exercises a script-local popup callback through a legacy
caller. Run it and the full GUI suite on both the minimum and current GVim.
The fixtures intentionally retain legacy syntax to check interoperability.

## Adding an action

1. Define the requested operation, required files/SDKs, output, cancellation, and failure behavior. Use an existing public plugin API when it matches.
2. Add first-party glue under `autoload/planet/`. For a standard external tool, add its contract to `data/integrations.json`; specialized workflows belong in a focused helper module.
3. Pass a List of executable/arguments to `planet#term#RunArgv`. Set an explicit validated cwd. Use `RunShell` only for an intentional shell script. Do not join argv into shell text, evaluate project configuration, or run a command after a failed prerequisite.
4. Store config/state/cache through `planet#paths#Config/State/Cache`. Personal data belongs outside the installation and project. Do not write generated state to a vendored package.
5. Connect the existing enabled menu entry. Update help and prerequisite guidance. Keep global mappings out of filetype hooks; provide undo for buffer-local changes.
6. Test literal arguments, success/failure, cancellation, and preservation of prior data. Use disposable recorders for network, hardware, deployment, or privileged workflows; include a separate real-tool recipe and state what was executed.

JSON argv input uses arrays such as `["--flag", "value with spaces"]`. A blank cancelled prompt must not execute. Tests should assert behavior rather than mirror a dispatch dictionary alone.

## Menu teaching metadata

Define fixed first-party actions with a direct compiled call:

```vim
execute planet#menu_help#Entry('an 110.20 ', 'File.New', '<Cmd>enew<CR>')
```

Its three fields are the native command/flags/priority (with trailing space),
escaped menu path, and unchanged RHS. This avoids reparsing fixed declarations
at startup. For dynamic definitions, `PlanetMenu` accepts the original native
menu command syntax. Both paths add native `:tmenu` tips and compact accelerator
text while preserving remapping, mode overrides, and `<SID>` context. Execute
the returned definition in the defining script. Use ordinary `aunmenu` and
enable/disable commands.
Third-party menu definitions stay in their upstream sources.

Use `<Tab>` before a hint and escape spaces/periods in menu paths. Keep at most
two short shortcuts; put the primary one last. The shared helper prefers keys,
then short Ex commands, with a combined 36-column limit. Long commands and
function calls remain in tips. Add a precise description in
`autoload/planet/menu_descriptions.vim` for native key actions with no Ex
equivalent. Do not invent shortcuts, execute expression mappings to inspect
them, or manufacture `:normal!` wrappers just to give every tip a colon.

The helper follows global Normal-mode mappings after plugins load. A shared
menubar tip teaches the Normal action; popup tips follow the editing mode.
Buffer-local mappings are not advertised
as universal shortcuts. Run `test_menu_help.vim` and `test_menu_teaching.vim`
after adding or changing entries, including dynamic menu builders. Also run
`test_menu_cache.vim` when changing hint resolution: persistent entries are
presentation data, never cached menu actions or executable scripts.
Vim's `menu_info(path, 't')` reads tooltip metadata; use `'tl'` for terminal
actions. Tooltip text must never enter the executable action index.

## Running checks

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
python3 scripts/test.py
python3 scripts/test.py --gui --xvfb /path/to/Xvfb
python3 scripts/plugins.py inventory --check
```

Engine checks use GVim's console mode with Normal/Visual mapping semantics; they do not establish terminal-Vim support. Ex mode cannot preserve the live selection context these fixtures need. Actual GUI checks must also pass. The workflow pins official Linux and Windows minimum/current GVim builds. Optional compiler/SDK checks report skips when tools are absent; record those limits.

For language-server acceptance, set `PLANETVIM_TEST_PYLSP` to an installed pylsp and run `tests/integration/lsp.vim` with the GUI runner. The debugger, writing, transfer, and capture acceptance recipes are in [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md). Never use a developer's private repositories or live hardware as a test fixture.

Run focused checks while implementing, then the full relevant suite. Review `git diff --check` and commit small coherent changes. Do not combine unrelated plugin upgrades with first-party fixes. Preserve the source snapshot and exact validation evidence in the release record.

## Release candidates

`VERSION` is the single first-party version string. Use semantic versions, with `-rc.N` for candidates; tags are `v` followed by that version. Add the changelog and acceptance evidence before packaging. `python3 scripts/release.py --output /tmp/planetvim-release` packages a clean committed checkout and records hashes and the source commit. Install, update, restore, and uninstall the extracted candidate in a disposable prefix before publishing. A candidate with pending native-platform or external-target acceptance must remain labelled as such.
