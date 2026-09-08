"""Deterministic process fixtures; they never invoke a compiler or desktop app."""
import json
from pathlib import Path
import sys

mode, record, *args = sys.argv[1:]
Path(record).write_text(json.dumps(args), encoding="utf-8")
if mode == "viewer":
    raise SystemExit(0)
source = Path(args[-1])
if mode == "pandoc":
    output = Path(next(arg.split("=", 1)[1] for arg in args if arg.startswith("--output=")))
    output.write_text("<!doctype html><title>Fixture</title><p>" + source.read_text(encoding="utf-8") + "</p>", encoding="utf-8")
elif mode in ("latexmk", "failure"):
    directory = Path(next(arg.split("=", 1)[1] for arg in args if arg.startswith("-outdir=")))
    if mode == "failure":
        error = f"{source}:3: Undefined control sequence."
        (directory / (source.stem + ".log")).write_text(error + "\n", encoding="utf-8")
        print(error)
        raise SystemExit(7)
    (directory / (source.stem + ".pdf")).write_bytes(b"%PDF-1.4\n% isolated test fixture\n")
