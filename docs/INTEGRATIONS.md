# Development tool integrations

The development menus run optional SDK tools in the current PlanetVim project directory. Each action either operates directly, asks for the required files/targets, or explains which executable or SDK must be installed. Selecting an install, package, deployment, translation, or kernel-configuration action performs that operation; startup never installs these tools.

`autoload/planet/integrations.vim` implements the workflows. `data/integrations.json` records 118 specific command contracts, including their argument order, required inputs, and platform requirements. Arguments remain native argv values. Additional arguments use a JSON array, for example `["--target", "target with spaces"]`. Empty/cancelled input starts no process. Process output retains the executable, working directory, and actual exit status.

## Selecting tools

Tools are found on PATH. Project-local `node_modules/.bin` tools and Qt tools under `$QTDIR/bin` or `$QTDIR/libexec` are also supported. Linux Qt package locations are searched after PATH. Android command-line tools can be selected under `$ANDROID_HOME/cmdline-tools/latest/bin` or `$ANDROID_SDK_ROOT/cmdline-tools/latest/bin`.

Override a specific executable or interpreter in your private PlanetVim configuration:

```vim
let g:PV_integration_tools = {
      \ 'clang-tidy': '/opt/llvm/bin/clang-tidy',
      \ 'qvkgen': ['/opt/Qt/bin/qvkgen'],
      \ 'custom-tool': ['python3', '/path with spaces/tool.py']}
```

On Windows, Node `.cmd` shims resolve to their native Node entry points. Other batch-based SDK tools may require selecting their native executable/interpreter argv. SDK setup scripts explicitly execute in Bash on Linux or cmd.exe on Windows. Batch setup paths containing cmd expansion characters `%`, `!`, or quotes are rejected with guidance; use a normal SDK installation path. macOS and terminal-only Vim are not supported.

## Environment and compiler setup

Conda activation uses `conda run` to capture an environment, then applies it to this GVim and future child processes. ROS 2, Yocto, PlatformIO, and Emscripten activation executes the selected SDK setup script and applies its environment only when the script succeeds. Deactivate restores prior values while preserving variables changed manually after activation. User home and Codex settings variables are not changed by this handoff.

Compiler choices set `CC` and `CXX` after checking both executables. Cross-compiler choices ask for the installed target compiler prefix and also set `CROSS_COMPILE`. These affect new configure/build trees; an existing CMake cache retains its compiler selection. Autotools build/host/target/sysroot settings and configure arguments are saved for the current tab and consumed by its Configure action. Android CMake actions ask for an installed NDK and API level and configure the selected build directory with its real toolchain file.

Legacy ROS Kinetic/Melodic/Noetic entries explicitly launch their official ROS containers, mounting the selected project at `/workspace`; Docker pulls the image if absent. They do not install obsolete host packages. ROS workspace build, rosrun, and roslaunch require an activated ROS environment. Qt installation asks for version, architecture, and output prefix rather than assuming a host platform.

## Generation, packaging, and analysis

Qt and QML tools ask for the input and output their CLI needs. Required input files are checked before launch. Generated `qt.conf`, `autogen.sh`, tag syntax files, and exported Pipenv requirements refuse existing output files. External SDK tools retain their own overwrite semantics for explicitly selected output paths.

Deployment/package actions invoke windeployqt, linuxdeploy, androiddeployqt, fpm, CPack, appimagetool, Snapcraft, Flatpak Builder, PyUpdater, or Qt Installer Framework with their own required inputs. Linux-specific tools report their host requirement on Windows.

Address, thread, leak, and undefined-behavior sanitizer actions configure a separate CMake build directory, then build only after successful configuration. They do not run the application automatically. Clang-Tidy/Clazy use the selected compilation database directory; create `compile_commands.json` before selecting those actions. Valgrind, perf, ltrace, strace, Coverity, Coccinelle, and Sparse invoke their corresponding native tools.

Kernel sanitizer/coverage actions enable the actual Kconfig symbol in a selected source `.config`. They report the required next steps: resolve configuration dependencies, rebuild, and boot that kernel. Architecture support and the target kernel's dependency rules still apply. No action silently modifies or boots the running kernel. ftrace uses trace-cmd; tracefs and process views open the corresponding local filesystem directories.

Chrome Trace visualization opens Perfetto, where **Open trace file** imports a local trace. Weblate auto-translation invokes the configured server's `weblate auto_translate` command; it requires that server's environment and changes the specified translation. Read the displayed action and selected destination before starting any external deployment or update.

Virtual-display actions start and stop only Xvfb jobs started by this GVim. The viewer action uses a localhost-only authenticated VNC server, starts the viewer on the original GUI display, and stops its server when the viewer exits. A free port and an existing VNC password file are required.

## Building GVim, Linux, and Godot

For **GVim on Linux**, select a Vim source checkout with `:tcd /path/to/vim`. Install the compiler, GTK3/X11 development libraries, ncurses, and Python development library appropriate to that checkout. In **Build → Autotools → Set ./configure Options**, enter `["--enable-gui=gtk3", "--with-features=huge", "--enable-python3interp=dynamic", "--enable-fail-if-missing", "--prefix=/path/to/private/vim"]`. Run Configure, then **Build → Make → Make** and **Make Test**. Inspect `src/vim --version` and launch `src/vim -g`; use Make Install only when ready to write the selected prefix. PlanetVim's minimum Linux acceptance build follows this approach. Consult [Vim's source installation guide](https://github.com/vim/vim/blob/master/src/INSTALL) for dependencies and [Windows build instructions](https://github.com/vim/vim/blob/master/src/INSTALLpc.txt) for its native compiler setup.

For **Linux kernel sources**, select the checkout with `:tcd`. Install the toolchain and build prerequisites for that kernel. In **Build → KBuild**, start with the intended existing `.config` or choose **make defconfig**, adjust it with **make menuconfig**, and run **make**. The Kernel preparation menu provides patch checks, maintainers, tags, and the compilation database. Debug/test/analyzer menus require the selected build, target, and kernel options. Building does not install or boot a kernel; Install is a separate action. Use [the kernel build guide](https://docs.kernel.org/admin-guide/README.html) and [Kbuild reference](https://docs.kernel.org/kbuild/kbuild.html), especially for cross compilation and separate output directories. Full kernel compilation/boot acceptance was not run for this candidate.

For **Godot 4**, select its source checkout with `:tcd` and install SCons, Python, the native compiler, and the platform libraries in the [Linux build guide](https://docs.godotengine.org/en/stable/engine_details/development/compiling/compiling_for_linuxbsd.html). Choose **Build → Other → Scons → Run Target** and enter `["platform=linuxbsd", "target=editor", "-j4"]`. Successful output is under `bin/`; add a Run configuration using the actual executable path. On Windows, follow [Godot's native compiler setup](https://docs.godotengine.org/en/stable/engine_details/development/compiling/compiling_for_windows.html) before launching GVim and use `platform=windows`. The shared native command runner retains build errors and supports cancellation. A full Godot build/editor acceptance was not run for this candidate.

## Verification and limits

`tests/test_integrations.vim` validates every command contract using injected native argv fixtures. It also checks literal paths with quotes/Unicode, cancellation, missing prerequisites, status 7 propagation, successful and failed environment activation, and configuration-file preservation. When Qt uic is installed, it actually compiles a small UI file. `tests/test_integration_tool.py` checks byte-preserving output capture, failure cleanup, existing-output preservation, native exit status, and setup-script argument handling.

The suite was exercised with Linux GVim engine checks and an actual private Xvfb GUI. Full Qt/Android/ROS/Yocto deployments, proprietary analyzers, external translation servers, hardware uploads, and kernel boot workflows require their SDKs, credentials, or target hardware and were not executed by these tests.

Command references checked against primary sources include [Qt's Android test runner](https://doc.qt.io/qt-6/android-test-runner.html), [Qt's Android deployment tool](https://doc.qt.io/qt-6/android-deploy-qt-tool.html), [Qt's qvkgen source](https://github.com/qt/qtbase/blob/dev/src/tools/qvkgen/qvkgen.cpp), [Weblate's management commands](https://docs.weblate.org/en/latest/admin/management.html#auto-translate), and [Linux kernel test instrumentation](https://docs.kernel.org/dev-tools/testing-overview.html). Available local Qt tools were also checked using their own usage output.
