# SFML / GLEW OpenGL example

Requires a C/C++ toolchain, Make, pkg-config and development packages exposing
sfml-window, sfml-system, glew, gl to pkg-config. Run `make` from this project directory,
then launch the resulting binary from that directory. `make clean` removes build output.

Compiler/linker overrides use the standard CC/CXX, CPPFLAGS, CFLAGS/CXXFLAGS,
LDFLAGS and LDLIBS Make variables. Link libraries follow source/object files,
including when the linker uses `--as-needed`.

The source handles SFML 2 and 3 window/event APIs and requires C++17. See the
[SFML migration guide](https://www.sfml-dev.org/tutorials/3.0/getting-started/migrate/).
