# GTK 3 Builder example

Requires a C/C++ toolchain, Make, pkg-config and development packages exposing
gtk+-3.0 to pkg-config. Run `make` from this project directory,
then launch the resulting binary from that directory. `make clean` removes build output.

Compiler/linker overrides use the standard CC/CXX, CPPFLAGS, CFLAGS/CXXFLAGS,
LDFLAGS and LDLIBS Make variables. Link libraries follow source/object files,
including when the linker uses `--as-needed`.

The GTK template loads `glade/window_main.glade` relative to the project directory.
Its signal callback symbols are exported for GtkBuilder.
