import importlib.util
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest
import zlib

DECODER = Path(__file__).resolve().parents[1] / ".vim/pack/planet/start/planet.vim/bin/image_preview.py"


@unittest.skipUnless(sys.platform.startswith("linux") and importlib.util.find_spec("PIL"), "Linux and optional Pillow decoder dependency")
class ImagePreviewTests(unittest.TestCase):
    def run_decoder(self, data):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.png"
            source.write_bytes(data)
            subprocess.run([sys.executable, str(DECODER), str(source), str(root), "20000", "20000"], check=True, timeout=15)
            result = json.loads((root / "result.json").read_text())
            return result, (root / "pixels.rgba").exists()

    def test_rejects_large_input(self):
        result, pixels = self.run_decoder(bytes(32 * 1024 * 1024 + 1))
        self.assertIn("32 MiB", result["error"])
        self.assertFalse(pixels)

    def test_rejects_huge_dimensions_before_decoding(self):
        def chunk(kind, payload):
            return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", zlib.crc32(kind + payload))
        data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 100000, 100000, 8, 2, 0, 0, 0)) + chunk(b"IDAT", b"") + chunk(b"IEND", b"")
        result, pixels = self.run_decoder(data)
        self.assertIn("error", result)
        self.assertFalse(pixels)

    def test_invalid_image(self):
        result, pixels = self.run_decoder(b"invalid")
        self.assertIn("error", result)
        self.assertFalse(pixels)
