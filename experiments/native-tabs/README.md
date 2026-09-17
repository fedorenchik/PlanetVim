# Native tab-menu experiment

The prototype has been integrated into PlanetVim. See the
[native tab-menu guide](../../docs/NATIVE_TABS.md) for build instructions,
configuration, behavior and validation.

The maintained bridge is [`native/tabmenu.c`](../../native/tabmenu.c), with
compiled Vim9 integration in `autoload/planet/native_tabs.vim` and
`autoload/planet/tab_menu.vim`. The original experiment remains in Git at
commit `41551ec71`.
