# PlanetVim

Vim for the Planet.

Easy and powerful Vim Distribution.

Release version v0.0.1 (not ready for testing)

# What is PlanetVim

Vim that helps you to develop.

A picture is worth 1000 words, here is recording of what PlanetVim will be able to do in v1.0 release:

![recording-menu-gif](https://user-images.githubusercontent.com/391735/119239792-f293a300-bb7d-11eb-9ac0-1e7e8c3d86f7.gif)

As you can see it is GUI oriented and tries to help you accomplish your tasks in most efficient way.

At least it can build CMake projects, Vim, Linux Kernel, Godot Engine now:

## How to build CMake projects:

1. Clone source code:

   🔀g- > New -> Clone, and then type URL (and other parameters) for git clone

2. `:cd` into cloned project

3. Create build directory:

   🔨u -> CMake -> Create In-Tree Build Dir or

   🔨u -> CMake -> Create OOT Build Dir (OOT stands for Out Of Tree) or

   🔨u -> CMake -> Select Build Dir and then choose which build dir to use

4. Configure CMake:

   🔨u -> CMake -> Configure

5. Build Project:

   🔨u -> CMake -> Build

### How to build KiCad (based on CMake):

1. Clone source code:

   🔀g -> New -> Clone

   Type: https://gitlab.com/kicad/code/kicad.git

   `:cd kicad`

2. Create build directory:

   🔨u -> CMake -> Create In-Tree Build Dir

3. Configure:

   🔨u -> CMake -> Configure

4. Make sure all build dependencies are installed.

   If there's any issue, you can set custom settings in PlanetVim:

   🔨u -> CMake -> Configure Tui

   Or run cmake-gui:

   🔨u -> CMake -> Configure Gui

4. Build:

   🔨u -> CMake -> Build

5. Run built KiCad:

   💻t -> New

   In the terminal:

   ```
   cd build
   ./kicad/kicad
   ```

6. Generate compile_commands.json for development:

   🔨u -> CMake -> Generate compile_commands.json

## How to build Vim:

## How to build Linux Kernel:

## How to build Godot Engine:

## If you want please consider joining PlanetVim chat at:

<A-?> -> Join PlanetVim Chat

## Guidelines

* Make Vim Discoverable
* User-Friendly
* Easy to Use
* Solve Real-World Problems
* Tested with real projects (Linux Kernel, Vim, etc.)

* Supports only recent Vim version (this makes code **MUCH** simpler, faster and
robust)
* Will not clutter your dirs with *~ .*.sw[p-z] and other files

## Which version to use

Branches:
* dev - main development branch (unstable)

PlanetVim does not hide tools that it uses, just makes them easy to use and
discoverable, e.g. generally it will show which command it runs and print
command's output, working directory of process and exit status.
