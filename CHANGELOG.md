# Changelog

## Unreleased — Linux GVim menu coverage

- Add persistent Emoji, compact Plain, and single-group Descriptive menu styles;
  keep PlanetVim visible in every style.
- Search actual menu actions across groups, preserve editing context, and open
  action help with F1. Add clean GVim tutoring and a Vim9 scratch lesson.
- Complete native completion, diff, text-object, block, number, recovery,
  encoding, input-language, macro, search and batch-editing workflows.
- Expose GVim inlay hints and diagnostic presentation without vendor changes.
- Add window pinning, tab-panel, font, appearance, printing, encryption and
  remote-file controls, with capability guidance on older builds.
- Add bounded local image previews and optional newer display controls.

This pass targets Linux GVim; Windows work remains deferred. See
[the completed menu checklist](docs/MENU_REVIEW.md) for validation boundaries.

## 0.1.0-rc.1 — 2026-09-08

First GVim-only release candidate, with Linux as the primary platform and Windows as the secondary platform.

- Preserve unsaved edits on cancelled or failed Save & Exit; export exactly the selected characters, lines, or block.
- Install privately with previews, ownership manifests, backups, rollback, and uninstall.
- Make home startup the default (`make install`) for plain GVim, with transactional backup/restoration of the previous vimrc or symlink. Reinstalls preserve the original backup; `make install-private` retains the separate-launcher option.
- Run native argv commands with explicit working directories, status, cancellation, retained output, and stdin support.
- Apply defaults, modes, and user overrides deterministically; retain preferences, sessions, undo, backup, and spelling outside projects.
- Complete project generation, build/run profiles, Git actions, test runners, Python/C++ debugging, and language intelligence.
- Implement the remaining SDK, deployment, analyzer, system, writing, and GUI menu actions. Missing tools provide setup guidance.
- Add template projects/files, snippets, window-bar controls, health checks, user help, plugin inventory, CI, and release packaging.

Third-party plugin source remains unchanged. This candidate is not a claim that every external SDK, commercial analyzer, deployment target, or physical device has been exercised. See [ACCEPTANCE.md](docs/ACCEPTANCE.md) for validation and release gates.
