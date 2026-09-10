"""Decode one bounded local thumbnail for a GVim image popup (optional Pillow)."""

import json
import os
from pathlib import Path
import sys
import warnings

MAX_FILE = 32 * 1024 * 1024
MAX_PIXELS = 16_000_000


def decode(source, destination, width, height):
    import resource

    resource.setrlimit(resource.RLIMIT_AS, (384 * 1024 * 1024,) * 2)
    resource.setrlimit(resource.RLIMIT_CPU, (10, 10))
    try:
        from PIL import Image, ImageOps
    except ImportError as error:
        raise ValueError("Install Python Pillow to preview images") from error
    Image.MAX_IMAGE_PIXELS = MAX_PIXELS
    warnings.simplefilter("error", Image.DecompressionBombWarning)
    width, height = max(1, min(1024, width)), max(1, min(768, height))
    with open(source, "rb") as stream:
        if os.fstat(stream.fileno()).st_size > MAX_FILE:
            raise ValueError("Image exceeds the 32 MiB input limit")
        with Image.open(stream) as original:
            if original.width * original.height > MAX_PIXELS:
                raise ValueError("Image exceeds the 16 million pixel limit")
            orientation = original.getexif().get(274, 1)
            bounds = (height, width) if orientation in (5, 6, 7, 8) else (width, height)
            original.thumbnail(bounds)
            thumbnail = ImageOps.exif_transpose(original).convert("RGBA")
            (destination / "pixels.rgba").write_bytes(thumbnail.tobytes())
            return {"width": thumbnail.width, "height": thumbnail.height}


def main():
    source, output, width, height = sys.argv[1:]
    destination = Path(output)
    try:
        result = decode(source, destination, int(width), int(height))
    except Exception as error:
        result = {"error": str(error) or type(error).__name__}
    (destination / "result.json").write_text(json.dumps(result), encoding="utf-8")


if __name__ == "__main__":
    main()
