# Plugin license evidence review

Unresolved inventory entries reviewed on 2026-09-08 against the bundled snapshots
in [plugins.json](plugins.json).
This records source evidence and the remaining publication work. It does not
relicense upstream code or treat a detected keyword as package-wide permission.
No third-party source was changed during this review.

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

The corrected inventory has 68 notice-file records, 32 documentation pointers,
4 source-header pointers, 3 first-party license pointers, and 15 records with
no detected statement. The tool ignores syntax keywords as license evidence and
does not substitute licenses from test fixtures for the plugin itself.

## Snapshots with no detected statement

The local source, README/help, and metadata were inspected for these 15 packages.
No licensing statement was found. The links identify the recorded upstream
snapshot; current upstream terms have not been substituted for those of a pin.
Record an applicable upstream notice or review an updated/replacement snapshot
before treating these as cleared for publication.

- [w3m.vim](https://github.com/yuratomo/w3m.vim/tree/228a852b188f1a62ecea55fa48b0ec892fa6bad7) — `228a852b188f1a62ecea55fa48b0ec892fa6bad7`.
- [fasm.vim](https://github.com/fedorenchik/fasm.vim/tree/6eabe66b8527cc8fae6671ec61056cbc81a5fa95) — `6eabe66b8527cc8fae6671ec61056cbc81a5fa95`.
- [FoldText](https://github.com/Konfekt/FoldText/tree/d5aca5af6eae07ed825504ac2943d5d40c349c5f) — `d5aca5af6eae07ed825504ac2943d5d40c349c5f`.
- [tabman.vim](https://github.com/kien/tabman.vim/tree/8f2ca9268a2ec1bcb29231b5b3f872101d169901) — `8f2ca9268a2ec1bcb29231b5b3f872101d169901`.
- [vim-buffest](https://github.com/rbong/vim-buffest/tree/900b1aadb6bc3e33e7cb1fd230c47f0134a28b4f) — `900b1aadb6bc3e33e7cb1fd230c47f0134a28b4f`.
- [vim-choosewin](https://github.com/t9md/vim-choosewin/tree/839da609d9b811370216bdd9d4512ec2d0ac8644) — `839da609d9b811370216bdd9d4512ec2d0ac8644`.
- [asyncomplete-buffer.vim](https://github.com/prabirshrestha/asyncomplete-buffer.vim/tree/018bcf0f712ce0fde3f1f2eaabd7004fccb2d34a) — `018bcf0f712ce0fde3f1f2eaabd7004fccb2d34a`.
- [asyncomplete-necosyntax.vim](https://github.com/prabirshrestha/asyncomplete-necosyntax.vim/tree/1bd7345ec5408b2c7d926b85148dc96e207eaf8c) — `1bd7345ec5408b2c7d926b85148dc96e207eaf8c`.
- [asyncomplete-necovim.vim](https://github.com/prabirshrestha/asyncomplete-necovim.vim/tree/e45d58673100b5653d9c2dc823f914190c64aaa0) — `e45d58673100b5653d9c2dc823f914190c64aaa0`.
- [asyncomplete-neoinclude.vim](https://github.com/kyouryuukunn/asyncomplete-neoinclude.vim/tree/26c676711087e3bd80e398a49f9cb6692b2799e8) — `26c676711087e3bd80e398a49f9cb6692b2799e8`.
- [asyncomplete-tabnine.vim](https://github.com/kitagry/asyncomplete-tabnine.vim/tree/a2c09959f9f9fd23a3475cd4756c68cd7a29ae80) — `a2c09959f9f9fd23a3475cd4756c68cd7a29ae80`.
- [asyncomplete-tags.vim](https://github.com/prabirshrestha/asyncomplete-tags.vim/tree/041af0565f2c16634277cd29d2429c573af1dac4) — `041af0565f2c16634277cd29d2429c573af1dac4`.
- [qt-support.vim](https://github.com/fedorenchik/qt-support.vim/tree/c353804b35a006531990191ae975b793d2836092) — `c353804b35a006531990191ae975b793d2836092`.
- [typescript-vim](https://github.com/leafgarland/typescript-vim/tree/52f3ca3474d51f5021696ffb7297d989e49121ac) — `52f3ca3474d51f5021696ffb7297d989e49121ac`.
- [vim-markdown-preview](https://github.com/JamshedVesuna/vim-markdown-preview/tree/9b3ec41fb6f0f49d9bb7ca81fa1c62a8a54b1214) — `9b3ec41fb6f0f49d9bb7ca81fa1c62a8a54b1214`.

## Evidence that still needs clarification

The documentation pointers were also reviewed. Most name Vim terms or include
a complete notice. These seven packages still need the stated follow-up:

- [DoxygenToolkit.vim](https://github.com/babaybus/DoxygenToolkit.vim/tree/db70eb843f26e210f1854505fecb36a8f60d674c): The README describes its license-comment generator. The GPL text in `plugin/DoxygenToolkit.vim` is generated output, not a statement of the plugin's own terms. Obtain the plugin's applicable notice.
- [asyncomplete-emoji.vim](https://github.com/prabirshrestha/asyncomplete-emoji.vim/tree/a2856274cc719c61f09884ab1eeafffb487c67ea): The MIT header in `autoload/asyncomplete/sources/emoji/data.vim` attributes the data to Junegunn Choi. Confirm terms for the adapter outside that file.
- [QFEnter](https://github.com/yssl/QFEnter/tree/df0a75b287c210f98ae353a12bbfdaf73d858beb): The plugin and autoload headers name MIT, but the bundled snapshot does not include the full notice. Record the applicable full notice and attribution.
- [undotree](https://github.com/mbbill/undotree/tree/bf76bf2d1a097cda024699738286fa81fb6529ac): The README, help, and source headers say BSD without specifying a variant or reproducing its conditions. Record the exact applicable notice.
- [gruvbox](https://github.com/morhetz/gruvbox/tree/bf2885a95efdad7bd5e4794dd0213917770d79b7): The README names MIT/X11 and package.json names MIT, but a full license notice was not found in this snapshot. Record the applicable notice and attribution.
- [asyncomplete-lsp.vim](https://github.com/prabirshrestha/asyncomplete-lsp.vim/tree/f6d6a6354ff279ba707c20292aef0dfaadc436a3): The README says MIT without a full notice. Record the applicable notice and attribution.
- [vim-autocorrect](https://github.com/panozzaj/vim-autocorrect/tree/28ef54d5cdd2d1021d54c90d80eb1a7d02fb58bc): The README says GPL without a version or full notice. Record the exact applicable terms, including the bundled correction data.

These findings complete the local evidence review, while the 22 listed upstream
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
