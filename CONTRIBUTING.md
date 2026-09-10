# Contributing to PlanetVim

The supported product is Linux GVim first and Windows GVim second, version 9.1 or newer. Do not introduce macOS, terminal Vim, or Neovim branches without a separate scope decision. Keep menu actions enabled and implement the operation their labels describe. Missing optional tools need useful setup guidance.

## Code layout

- `scripts/planetvim.vim` is the checkout/installed entry point; `.vimrc` configures bundled plugins.
- `.vim/pack/planet/start/planet.vim` contains first-party `autoload/planet/`, `plugin/`, `bin/`, `data/`, `templates/`, and `doc/` files.
- The title, tab-label, and tab-tooltip packages under `.vim/pack/planet/start/` are also first-party.
- Other packages are upstream snapshots. Retain their notices; update or replace them through the workflow in [docs/PLUGINS.md](docs/PLUGINS.md). Do not patch vendored source locally.
- `tests/` contains isolated Vimscript/Python fixtures and opt-in real-tool acceptance checks.

## Adding an action

1. Define the requested operation, required files/SDKs, output, cancellation, and failure behavior. Use an existing public plugin API when it matches.
2. Add first-party glue under `autoload/planet/`. For a standard external tool, add its contract to `data/integrations.json`; specialized workflows belong in a focused helper module.
3. Pass a List of executable/arguments to `planet#term#RunArgv`. Set an explicit validated cwd. Use `RunShell` only for an intentional shell script. Do not join argv into shell text, evaluate project configuration, or run a command after a failed prerequisite.
4. Store config/state/cache through `planet#paths#Config/State/Cache`. Personal data belongs outside the installation and project. Do not write generated state to a vendored package.
5. Connect the existing enabled menu entry. Update help and prerequisite guidance. Keep global mappings out of filetype hooks; provide undo for buffer-local changes.
6. Test literal arguments, success/failure, cancellation, and preservation of prior data. Use disposable recorders for network, hardware, deployment, or privileged workflows; include a separate real-tool recipe and state what was executed.

JSON argv input uses arrays such as `["--flag", "value with spaces"]`. A blank cancelled prompt must not execute. Tests should assert behavior rather than mirror a dispatch dictionary alone.

## Menu teaching metadata

Define first-party actions with `PlanetMenu` followed by the native menu
command, flags, priority, path, and unchanged RHS. This adds native `:tmenu`
tips and compact accelerator text while preserving remapping, mode overrides,
and `<SID>` context. Use ordinary `aunmenu` and enable/disable commands.
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
after adding or changing entries, including dynamic menu builders.
Vim's `menu_info(path, 't')` reads tooltip metadata; use `'tl'` for terminal
actions. Tooltip text must never enter the executable action index.

## Running checks

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
python3 scripts/test.py
python3 scripts/test.py --gui --xvfb /path/to/Xvfb
python3 scripts/plugins.py inventory --check
```

Engine checks use GVim's Ex mode for speed; they do not establish terminal-Vim support. Actual GUI checks must also pass. The workflow pins official Linux and Windows minimum/current GVim builds. Optional compiler/SDK checks report skips when tools are absent; record those limits.

For language-server acceptance, set `PLANETVIM_TEST_PYLSP` to an installed pylsp and run `tests/integration/lsp.vim` with the GUI runner. The debugger, writing, transfer, and capture acceptance recipes are in [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md). Never use a developer's private repositories or live hardware as a test fixture.

Run focused checks while implementing, then the full relevant suite. Review `git diff --check` and commit small coherent changes. Do not combine unrelated plugin upgrades with first-party fixes. Preserve the source snapshot and exact validation evidence in the release record.

## Release candidates

`VERSION` is the single first-party version string. Use semantic versions, with `-rc.N` for candidates; tags are `v` followed by that version. Add the changelog and acceptance evidence before packaging. `python3 scripts/release.py --output /tmp/planetvim-release` packages a clean committed checkout and records hashes and the source commit. Install, update, restore, and uninstall the extracted candidate in a disposable prefix before publishing. A candidate with pending native-platform or external-target acceptance must remain labelled as such.
