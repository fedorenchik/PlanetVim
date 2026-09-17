# Native GTK tab menus

On Linux GTK3 GVim, right-click a native tab label for actions on that tab:
activate, create/open/duplicate, reopen closed tabs, close others or tabs to
either side, move, and save/open tab layouts. File tabs also offer save/save-as,
path copying, file-tree reveal and a terminal in the file's directory.
The menu opens after releasing the right mouse button and stays open for
selection, whether the click is brief or the button is held before release.

Right-clicking does not select the tab. Copying paths and saving its file retain
the active window. Move/close/layout-save operations restore the original window
when it still exists; opening, activating and duplicating select their result.
Duplicate Tab Layout shares the original buffers, including unsaved text.

Close actions use Vim's normal confirmation and hidden-buffer rules. They never
force-discard edits or force-stop terminal jobs. Cancelling a close stops the
batch. Closed tabs use PlanetVim's existing layout recovery. A Vim tab is a set
of windows: closing a tab is not the same operation as deleting a file/buffer.

## Build and install

Install a C compiler, `make`, `pkg-config`, and GTK3 development headers. Typical
packages are `build-essential pkg-config libgtk-3-dev` on Debian/Ubuntu, or
`base-devel gtk3` on Arch. The helper requires GTK 3.14 or newer and GVim with
`+gui_gtk3`, `+libcall` and `+channel`.

```sh
make install                    # builds and enables the helper by default
make install NATIVE_TABS=0       # install with Vim's stock tab menu
make native-tabs                # build only, also works for checkout launches
```

Default installation fails with setup guidance if build prerequisites are
missing. `NATIVE_TABS=0` explicitly installs with the stock menu; disabling the
helper at runtime does not require reinstalling.

The compiled library is `build/native/planetvim-tabmenu.so`; installation copies
it to `lib/planetvim-tabmenu.so` inside the PlanetVim installation. It participates
in the installer's normal ownership, backup, update, uninstall and restore rules.
Direct `python3 scripts/install.py install` includes an already built helper but
does not compile it. Source releases contain the C source, not a machine-specific
binary. The GVim executable and third-party plugins are unchanged.

Restart GVim after updating the helper. Each GVim process retains the loaded
library until exit. Compilation and installation replace the file atomically,
so already running processes retain their original mapped code.

## Configuration and fallback

Native tab menus are enabled by default. The helper starts after GUI
initialization when its library is available. It needs PlanetVim's
`guitabtooltip` expression to associate persistent
tab IDs with native GTK widgets. Custom `guitablabel` expressions are supported.
A custom tooltip or disabled native tab strip uses Vim's stock behavior.

Use **Tabs → Enable Rich Tab Menu / Use Stock Tab Menu / Tab Menu Status**, or:

```vim
:PlanetNativeTabs on
:PlanetNativeTabs off
:PlanetNativeTabs status
```

Persist an opt-out in your private Vim9 configuration:

```vim
g:PV_native_tabs = false
```

An optional `g:PV_native_tabs_library` can specify an absolute library path.
`:PlanetDoctor` reports availability and setup guidance. Missing or incompatible
helpers leave the stock menu available; editing does not depend on a compiler.

Menus support Normal, Insert, Visual, Select, Terminal input and Terminal Normal
mode. Command-line editing, operator-pending input, completion popups, Vim popup
windows and the command-line window keep Vim's existing mouse behavior. Native
tab selection, dragging, scrolling and middle clicks remain with GTK/Vim. Clicks
on tab padding or overflow controls outside a label also retain stock behavior.

## Implementation and validation

The small C bridge in `native/tabmenu.c` uses GTK's capture phase, remembers the
clicked tab on button press and sends its numeric notification on release over
a private Unix socket. Vim's channel callback builds the menu on demand in
compiled Vim9script. There is no background helper process,
polling timer or call into Vim's private C functions/structs.

PlanetVim tags each notebook page with its persistent tab ID during the actual
tooltip redraw, after Vim updates that page's label. This follows both widget
reordering and Vim's reuse of widgets by index. Callbacks and actions resolve
that ID again; closed tabs cannot redirect stale actions to replacement tabs.
Notifications older than two seconds are ignored. File actions also validate
the clicked window and buffer before running.

The library uses ELF `NODELETE` because `libcallnr()` releases its dynamic-library
handle after each call. Stop removes the gesture, closes the socket and clears
widget IDs. Ineligible presses or an unavailable connection explicitly deny the
GTK gesture to allow the stock handler to process the click. A failed send closes
the connection; subsequent clicks fall back to the stock handler. This still
depends on Vim's GTK notebook layout and tooltip redraw behavior; it is not an
upstream Vim extension API.

Focused tests cover action identity after reordering/closing, inactive-tab
operations, shared-buffer duplication, close cancellation, recovery, and installer
ownership. Real mouse tests run against a private Xvfb display:

```sh
make test-native-tabs
GVIM=/path/to/gvim PLANETVIM_XVFB=/path/to/Xvfb make test-native-tabs
python3 scripts/test.py --gui --xvfb /path/to/Xvfb tests/test_tab_menu.vim tests/test_sessions.vim
```

The mouse test additionally requires `xdotool`. Native Wayland and HiDPI/overflow
layouts need separate desktop acceptance; Xvfb validation does not establish
their behavior.

References: [GTK event handling](https://docs.gtk.org/gtk3/input-handling.html),
[Vim's GTK tab redraw](https://github.com/vim/vim/blob/master/src/gui_gtk_x11.c),
[Vim library calls](https://vimhelp.org/builtin.txt.html#libcallnr%28%29).
