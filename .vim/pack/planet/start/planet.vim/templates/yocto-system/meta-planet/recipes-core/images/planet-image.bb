require recipes-core/images/core-image-minimal.bb
SUMMARY = "Planet example minimal image"
IMAGE_INSTALL:append = " strace"
