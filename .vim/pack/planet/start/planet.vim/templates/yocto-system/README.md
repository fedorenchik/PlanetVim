Yocto Scarthgap layer and image starter. Use a Linux host supported by Yocto.
1. Clone Poky Scarthgap separately: git clone -b scarthgap https://git.yoctoproject.org/poky
2. Source poky/oe-init-build-env with your build directory.
3. Run bitbake-layers add-layer /absolute/path/to/this/meta-planet.
4. Set MACHINE = "qemux86-64" in conf/local.conf (or the chosen board).
5. Run bitbake planet-image, then runqemu qemux86-64.
See https://docs.yoctoproject.org/scarthgap/dev-manual/layers.html .
