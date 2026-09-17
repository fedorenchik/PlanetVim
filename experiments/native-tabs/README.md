# Native GTK tab-menu experiment

The helper approach is feasible on Linux GTK3 GVim. This opt-in experiment
intercepts a right-click on a native tab label and displays a Vim-defined GTK
popup. It keeps the installed GVim executable and the native tab strip.
It is not loaded by PlanetVim startup or installed by `make install`.

The demo has two actions: activate the clicked tab, and copy its current
window's file path without activating the tab. It deliberately does not
implement destructive tab actions; target identity still needs hardening.

## How it works

`libcallnr()` loads a small C shared library into the GVim process. The library
finds the notebook under `vim-main-window` using GTK widget traversal, then adds
a right-button gesture in GTK's capture phase. This sees the click before
Vim's existing notebook button handler. Label allocations identify the clicked
tab. Clicks outside a label continue to use Vim's existing behavior.

The callback writes a short numeric event (sequence, tab number, tab count) to
a nonblocking Unix socket. A Vim `ch_open()` callback receives it and builds a
hidden `:menu` root, displayed with `:popup!`. Menu actions run in Vim9script.
The C callback does not call the Vim interpreter, inject keystrokes, or access
Vim's private structs or exported C functions. There is no helper process,
polling timer, Python dependency, or `LD_PRELOAD` requirement.

The socket lives under Vim's temporary directory, has mode 0600, and is removed
on stop. The gesture claims a click only after a complete nonblocking send;
an absent client or failed send leaves Vim's original handler available.
This requires explicitly denying the gesture on failure; simply returning from
the capture callback still swallows the event.
Stopping disconnects the gesture and restores the original menu.

The build **must retain `-Wl,-z,nodelete`**: Vim closes the library handle after
each `libcallnr()` call, but GTK still needs to execute its callbacks. Stopping
removes callbacks and closes sockets; the library stays mapped until GVim exits.
Use a fresh GVim process after rebuilding it.

## Try it

Build from the repository root with a C compiler, `pkg-config`, and GTK3
development headers installed:

```sh
mkdir -p build
cc -std=c11 -Wall -Wextra -Werror -O2 -fPIC -shared \
  -Wl,-z,nodelete -Wl,--as-needed \
  $(pkg-config --cflags gtk+-3.0) experiments/native-tabs/bridge.c \
  -o build/planetvim-native-tabs.so $(pkg-config --libs gtk+-3.0)
```

Open a separate GVim instance, create two or more tabs, then source the demo
**after the GUI is open**:

```vim
:source /absolute/path/to/PlanetVim/experiments/native-tabs/demo.vim
```

Right-click an inactive tab's label. Copy File Path should leave the active
tab unchanged. Activate Clicked Tab should select the clicked tab. These
variables expose the most recent event/action for inspection:

```vim
:echo g:PV_native_tabs_event
:echo g:PV_native_tabs_action
:call PVNativeTabsStop()
:call PVNativeTabsStart()
```

Sourcing the demo again is a no-op; use the start/stop functions to toggle it.
To load a library built elsewhere, set `g:PV_native_tabs_library` to its absolute
path before first sourcing the demo. The required GVim features are `+gui_gtk3`,
`+libcall`, and `+channel`; the gesture API requires GTK 3.14 or newer.

## Investigation results — 2026-09-17

Isolated Xvfb testing used real mouse events and the PlanetVim runtime, with
private configuration, session, state and cache directories. Both installed
GVim 9.2.1011 and the minimum supported GVim 9.1.0016 displayed the custom popup,
correctly identified an inactive clicked tab, and copied its path without
changing the active tab. Both restored Vim's stock menu when stopped.
Start/stop/restart and repeated sourcing were also checked. A 9.2 test with
the listener running but no Vim client verified fallback to the stock menu.

The 9.2 run also verified native left-click selection, drag reordering, new
tabs, popup display in Insert and Visual modes, and activation through the
menu. These checks establish feasibility, not complete mode/platform coverage.

The helper uses only GTK/GLib and libc symbols; the same binary worked with
both GVim builds. Startup overhead has not been benchmarked.

## Work needed before normal integration

- **Stable identity before callback delivery.** A tab number and count cannot
  detect a same-count reorder between the GTK event and the Vim callback. The
  demo retains a window ID after delivery, which protects against later
  renumbering and detects a closed window, but not this earlier interval.
  Production should attach a generation and stable tab identity to events and
  validate them against a Vim-side layout snapshot before offering actions.
  Native notebook pages are reused by index when Vim updates its tab strip;
  a GTK page pointer alone is not a persistent Vim-tab identity.
- **All input contexts.** Opening a popup in Normal/Insert/Visual mode works,
  and a command-line callback was observed without changing its text. Action
  behavior still needs coverage for command-line editing, completion menus,
  terminal jobs, prompts, and dialogs. The demo ignores command-window events.
  Production should disable interception in unsupported contexts before claiming
  the click and avoid opening a stale popup after a long-running Vim command.
- **Hit testing and lifecycle.** Tab padding currently falls back to the stock
  menu. Overflow arrows, scrolled tabs, HiDPI themes, GUI teardown, channel
  failure, and rapid layout changes need dedicated acceptance checks. Middle
  click was exercised but not conclusively validated.
- **Packaging and support.** Compile for the user's architecture and GTK3
  environment, load after GUI initialization, and retain a stock-menu fallback
  when the helper is unavailable. The notebook lookup still depends on Vim's
  GUI widget layout and name, although it avoids private C ABI dependencies.
  Wayland has not been tested; the helper itself contains no X11 calls.
- **Actual tab actions.** Once identity is reliable, connect Vim9 actions to
  PlanetVim's existing tab recovery and modified-buffer protections, including
  Close Others, Close Left/Right, Move, and Reopen Closed Tab.

Recommendation: pursue this as an optional small native bridge, with action
logic kept in Vim9script. An upstream Vim hook would remove the widget-layout
dependency, but is not required to demonstrate a working menu today.

## References

- [Vim's native GTK tab-menu implementation](https://github.com/vim/vim/blob/master/src/gui_gtk_x11.c)
- [GTK event propagation and gesture capture](https://docs.gtk.org/gtk3/input-handling.html)
- [GTK multi-press gesture API](https://docs.gtk.org/gtk3/class.GestureMultiPress.html)
- [Vim library calls](https://vimhelp.org/builtin.txt.html#libcallnr%28%29)
- [Vim channels](https://vimhelp.org/channel.txt.html#channel-open)
- [GNU linker options](https://sourceware.org/binutils/docs/ld/Options.html)
