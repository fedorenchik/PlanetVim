# Bundled plugin maintenance

PlanetVim uses Vim packages under `.vim/pack/<group>/{start,opt}/<name>`.
The machine-readable [plugins.json](plugins.json) records every package, loading
mode, source URL/branch/commit from `.gitrepo`, license/notice evidence, and a
SHA256 fingerprint of each upstream snapshot. Local packages are versioned with
PlanetVim itself. The installer copies these sources; it does not upgrade plugins
or download their optional native components.

## Inventory checks

```sh
python3 scripts/plugins.py inventory --check
python3 scripts/plugins.py inventory --write
python3 scripts/plugins.py update-check vim-test
```

`inventory` runs offline. `--check` fails if the recorded source metadata or an
upstream package's files differ. `--write` regenerates the record after reviewing
a deliberate change. Snapshot hashes exclude `.git`, Python bytecode and
`__pycache__`. Local package code changes do not require a new upstream snapshot
hash, but changes to their package identity/license pointers do require refresh.

`update-check` explicitly queries selected upstream branches using `git ls-remote`
and prints JSON lines. It does not fetch, merge, install, or modify packages.
`different` means the branch tip differs from the recorded commit; it does not
establish ancestry, compatibility, or that the newest revision is desirable.
Use `--all` only when a full network check is wanted. Failed or absent upstream
refs produce a nonzero exit status. No scheduled update or notification is enabled.

License entries are paths to evidence. `documentation_mentions` and
`source_header_mentions` are not proof of a package-wide license; a header may
apply only to one file. `project_license` links a known first-party package to the
project license when it has no package-specific notice; missing `.gitrepo`
metadata alone does not qualify. `not_found` is an unresolved
documentation/attribution item. The [local evidence review](LICENSE_REVIEW.md)
records the remaining upstream follow-ups, including ambiguous documentation.
The root project license does not replace upstream notices. Preserve notices,
headers, and attribution when copying, packaging, or updating each plugin.

## Updating one package

1. Select the concrete compatibility issue or capability that justifies an
   update. Inspect that upstream project's changelog, dependencies and license.
2. Start from a clean, reviewable branch. Record the current `.gitrepo` pin and
   any distribution adaptations. The inventory's `local_patches` field says
   `not_compared_with_upstream` until someone actually compares that snapshot;
   a recorded pin alone does not prove that no local edits exist.
3. Use the repository's `git-subrepo` workflow for the selected package. Review
   the imported diff and refreshed `.gitrepo` metadata. Do not edit generated
   `.gitrepo` commit values to simulate an update. Keep local fixes outside
   upstream code where possible; document unavoidable patches with a linked issue.
4. Run `make test`, GUI checks, and the integration's own acceptance fixture.
   Check enabled commands, mappings, feature requirements, startup errors, and
   failure behavior. An upstream test suite alone does not cover PlanetVim glue.
5. Run `python3 scripts/plugins.py inventory --write` and `--check`. Commit the
   reviewed upstream snapshot, metadata, adaptations, tests, and inventory together.

Tool and adapter installation is a separate operation. Vim-clap's optional `maple`
accelerator, language servers, Vimspector gadgets, fonts, and project toolchains
have their own prerequisites. Keep their setup versioned/documented and make
missing optional components actionable; do not download them during startup.

## Startup measurement

```sh
python3 scripts/benchmark.py --runs 5
python3 scripts/benchmark.py --runs 5 --xvfb /path/to/Xvfb --output /tmp/planetvim-startup.json
```

The benchmark starts real GVim with the full distribution and fresh isolated
config/state/cache directories. Each startup sample measures elapsed time from
an early pre-vimrc hook through the first event-loop callback after `VimEnter`.
Process launch-through-exit wall time is recorded separately. Startup includes
GUI initialization and plugins, but does not wait for language
servers or remote work. One warmup is excluded. A display is required; `--xvfb`
creates a private Linux virtual display. Results include sample values, median,
range, GVim version, host information, and the precise measurement definition.
The last `v:errmsg` is retained per sample for diagnosis; intentionally suppressed
Vim commands can leave that value set even after a successful startup. Reported
Vim errors or a nonzero process exit fail the benchmark.

Record a baseline on documented hardware before setting a numerical regression
budget. Compare the same OS, display setup, GVim build, plugin snapshot and sample
count. Investigate a repeatable regression before changing loading behavior.
Package counts alone are not evidence that a plugin is slow.

## CI version pins

The workflow tests Linux GVim **9.1.0000** and **9.2.1046** from pinned official
source commits, and Windows x64 GUI archives **9.1.0** and **9.2.1046**. These are
fixed test baselines; the current 9.2 pin was verified on 2026-09-08. Update the
current-release entry deliberately and rerun the complete matrix. The Windows
minimum archive uses the upstream release label `v9.1.0`, not `v9.1.0000`.

Source tags and commits were verified against [vim/vim tags](https://github.com/vim/vim/tags)
and `git ls-remote` from that official repository. Windows asset names and layout
were verified from the official [9.1.0 release](https://github.com/vim/vim-win32-installer/releases/tag/v9.1.0)
and [9.2.1046 release](https://github.com/vim/vim-win32-installer/releases/tag/v9.2.1046).
Both downloaded archives were hashed locally; the current archive's digest also
matches GitHub's release metadata. The workflow verifies those recorded hashes
before extraction. Action revisions are pinned to the official
[checkout](https://github.com/actions/checkout) and
[setup-python](https://github.com/actions/setup-python) repositories.

Both platforms install [debugpy 1.8.21](https://github.com/microsoft/debugpy/releases/tag/v1.8.21).
Linux also installs GDB and requires the real C++ and Python debugger GUI tests
to run. Windows requires the Python debugger GUI tests; C++ debugger tests report
an explicit skip when a DAP-capable GDB and compiler are absent. Both official
Windows GVim packages use Python's stable ABI (`python3.dll`), paired with the
workflow's Python 3.12 installation. The archive registration step uses
`gvim -silent -register` to avoid the first-start type-library dialog.

A checked-in workflow is not a claim that hosted CI has passed. Windows runtime
behavior must be confirmed by a successful Windows job and a recorded GUI run.
