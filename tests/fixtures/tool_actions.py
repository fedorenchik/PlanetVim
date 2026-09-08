"""Harmless process fixture for optional debugger/SDK menu actions."""
import json
import pathlib
import sys

record, status, *arguments = sys.argv[1:]
pathlib.Path(record).write_text(json.dumps(arguments), encoding="utf-8")
print("fixture action completed")
sys.exit(int(status))
