# GLFW / GLEW OpenGL example

Requires a C/C++ toolchain, Make, pkg-config and development packages exposing
glfw3, glew, gl to pkg-config. Run `make` from this project directory,
then launch the resulting binary from that directory. `make clean` removes build output.

Compiler/linker overrides use the standard CC/CXX, CPPFLAGS, CFLAGS/CXXFLAGS,
LDFLAGS and LDLIBS Make variables. Link libraries follow source/object files,
including when the linker uses `--as-needed`.
