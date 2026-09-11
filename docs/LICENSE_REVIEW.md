# Plugin license evidence review

Unresolved inventory entries reviewed on 2026-09-08, refreshed on 2026-09-11 against the bundled snapshots
in [plugins.json](plugins.json).
This records source evidence and the remaining publication work. It does not
relicense upstream code or treat a detected keyword as package-wide permission.
The September 11 refresh imports unchanged upstream snapshots; no local third-party source patches were made.

## Inventory corrections

- Three local packages without their own notice now point to the owner-selected
  [first-party MIT license](../LICENSE): `guitablabel.vim`, `guitabtooltip.vim`,
  and `planet.vim`. `title.vim` retains its existing package-specific notice.
- Colorizer includes `doc/license.txt`; the inventory now recognizes that notice.
- FastFold includes a French license text in `plugin/fastfold.vim`.
- QFEnter names MIT in the headers of `plugin/QFEnter.vim` and
  `autoload/QFEnter.vim`; the full notice is not included there.
- vim-twiggy explicitly refers to Vim terms in its plugin and autoload headers.
- asyncomplete-emoji includes an MIT notice for its emoji data source. That
  file-specific notice does not establish terms for the surrounding adapter.

The corrected inventory has 73 notice-file records, 27 documentation pointers,
4 source-header pointers, 3 first-party license pointers, and 15 records with
no detected statement. The tool ignores syntax keywords as license evidence and
does not substitute licenses from test fixtures for the plugin itself.

## Notices supplied by the September 11 upstream updates

- DoxygenToolkit.vim now includes its own MIT notice, attributed to Aidas Klimas.
- undotree now includes a BSD 3-Clause notice attributed to its authors.
- asyncomplete-lsp.vim now includes the full MIT notice attributed to Prabir Shrestha.
- csv.vim and vim-test also gained dedicated notice files, replacing documentation-only evidence.

These imports resolve three previously ambiguous entries. The 15 snapshots below
still have no detected statement; the four ambiguous entries still need follow-up.
All exact pins and the file-by-file comparison are recorded in the
[upgrade ledger](PLUGIN_UPDATES_2026-09-11.md).

## Snapshots with no detected statement

The local source, README/help, and metadata were inspected for these 15 packages.
No licensing statement was found. The links identify the recorded upstream
snapshot; current upstream terms have not been substituted for those of a pin.
Record an applicable upstream notice or review an updated/replacement snapshot
before treating these as cleared for publication.

- [w3m.vim](https://github.com/yuratomo/w3m.vim/tree/228a852b188f1a62ecea55fa48b0ec892fa6bad7) — `228a852b188f1a62ecea55fa48b0ec892fa6bad7`.
- [fasm.vim](https://github.com/fedorenchik/fasm.vim/tree/6eabe66b8527cc8fae6671ec61056cbc81a5fa95) — `6eabe66b8527cc8fae6671ec61056cbc81a5fa95`.
- [FoldText](https://github.com/Konfekt/FoldText/tree/bb17060d3373b63fc5b127136c10b6d1616ebcd9) — `bb17060d3373b63fc5b127136c10b6d1616ebcd9`.
- [tabman.vim](https://github.com/kien/tabman.vim/tree/8f2ca9268a2ec1bcb29231b5b3f872101d169901) — `8f2ca9268a2ec1bcb29231b5b3f872101d169901`.
- [vim-buffest](https://github.com/rbong/vim-buffest/tree/6ed80444d687cbcb11dcbe83dd94ec9888329f1b) — `6ed80444d687cbcb11dcbe83dd94ec9888329f1b`.
- [vim-choosewin](https://github.com/t9md/vim-choosewin/tree/839da609d9b811370216bdd9d4512ec2d0ac8644) — `839da609d9b811370216bdd9d4512ec2d0ac8644`.
- [asyncomplete-buffer.vim](https://github.com/prabirshrestha/asyncomplete-buffer.vim/tree/a7afcf4f1f0ee8beaec4b3a20d814160ab097d8d) — `a7afcf4f1f0ee8beaec4b3a20d814160ab097d8d`.
- [asyncomplete-necosyntax.vim](https://github.com/prabirshrestha/asyncomplete-necosyntax.vim/tree/1bd7345ec5408b2c7d926b85148dc96e207eaf8c) — `1bd7345ec5408b2c7d926b85148dc96e207eaf8c`.
- [asyncomplete-necovim.vim](https://github.com/prabirshrestha/asyncomplete-necovim.vim/tree/e45d58673100b5653d9c2dc823f914190c64aaa0) — `e45d58673100b5653d9c2dc823f914190c64aaa0`.
- [asyncomplete-neoinclude.vim](https://github.com/kyouryuukunn/asyncomplete-neoinclude.vim/tree/26c676711087e3bd80e398a49f9cb6692b2799e8) — `26c676711087e3bd80e398a49f9cb6692b2799e8`.
- [asyncomplete-tabnine.vim](https://github.com/kitagry/asyncomplete-tabnine.vim/tree/a2c09959f9f9fd23a3475cd4756c68cd7a29ae80) — `a2c09959f9f9fd23a3475cd4756c68cd7a29ae80`.
- [asyncomplete-tags.vim](https://github.com/prabirshrestha/asyncomplete-tags.vim/tree/e458dc448b40d69eb1d4722fa30ce848521bd3d0) — `e458dc448b40d69eb1d4722fa30ce848521bd3d0`.
- [qt-support.vim](https://github.com/fedorenchik/qt-support.vim/tree/c353804b35a006531990191ae975b793d2836092) — `c353804b35a006531990191ae975b793d2836092`.
- [typescript-vim](https://github.com/leafgarland/typescript-vim/tree/4740441db1e070ef8366c888c658000dd032e4cb) — `4740441db1e070ef8366c888c658000dd032e4cb`.
- [vim-markdown-preview](https://github.com/JamshedVesuna/vim-markdown-preview/tree/9b3ec41fb6f0f49d9bb7ca81fa1c62a8a54b1214) — `9b3ec41fb6f0f49d9bb7ca81fa1c62a8a54b1214`.

## Evidence that still needs clarification

The documentation pointers were also reviewed. Most name Vim terms or include
a complete notice. These four packages still need the stated follow-up:

- [asyncomplete-emoji.vim](https://github.com/prabirshrestha/asyncomplete-emoji.vim/tree/a2856274cc719c61f09884ab1eeafffb487c67ea): The MIT header in `autoload/asyncomplete/sources/emoji/data.vim` attributes the data to Junegunn Choi. Confirm terms for the adapter outside that file.
- [QFEnter](https://github.com/yssl/QFEnter/tree/fd5d378f97ee4847ce4fcb58b3719864228607da): The plugin and autoload headers name MIT, but the bundled snapshot does not include the full notice. Record the applicable full notice and attribution.
- [gruvbox](https://github.com/morhetz/gruvbox/tree/5d15b2765f59754d7ac263c88a0f6e3e58124951): The README names MIT/X11 and package.json names MIT, but a full license notice was not found in this snapshot. Record the applicable notice and attribution.
- [vim-autocorrect](https://github.com/panozzaj/vim-autocorrect/tree/28ef54d5cdd2d1021d54c90d80eb1a7d02fb58bc): The README says GPL without a version or full notice. Record the exact applicable terms, including the bundled correction data.

These findings complete the local evidence review, while the 19 listed upstream
items remain publication follow-ups. A missing statement is not resolved by
applying PlanetVim's MIT license. Any upstream update or replacement must preserve
the enabled feature and pass its integration checks. Obtaining statements from
maintainers requires contacting them; no messages were sent during this review.

## Preservation and verification

All existing bundled notices and headers remain in the source archives. The
inventory retains each upstream pin and snapshot hash. This review does not audit
licenses of separately installed SDKs, language servers, debugger adapters, or
other external tools.

The inventory regressions cover nested Vim-help notices, source comment headers,
syntax-keyword false positives, test-fixture license scope, and first-party
license fallback without overriding an existing package notice. Run:

```sh
python3 -m unittest discover -s tests -p test_plugins.py
python3 scripts/plugins.py inventory --check
```
