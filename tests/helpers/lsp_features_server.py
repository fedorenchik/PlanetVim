"""Deterministic pull-diagnostics/document-link peer for the bundled LSP client."""
import json
from pathlib import Path
import sys


def send(message):
    data = json.dumps(message).encode()
    sys.stdout.buffer.write(f"Content-Length: {len(data)}\r\n\r\n".encode() + data)
    sys.stdout.buffer.flush()


target, trace = map(Path, sys.argv[1:])
span = {"start": {"line": 0, "character": 0}, "end": {"line": 0, "character": 4}}
while True:
    length = 0
    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            sys.exit(0)
        if line in (b"\r\n", b"\n"):
            break
        if line.lower().startswith(b"content-length:"):
            length = int(line.split(b":", 1)[1])
    message = json.loads(sys.stdin.buffer.read(length))
    method = message.get("method")
    with trace.open("a") as stream:
        stream.write(json.dumps(message) + "\n")
    result = None
    if method == "initialize":
        result = {"capabilities": {"textDocumentSync": 1,
                  "documentLinkProvider": {},
                  "diagnosticProvider": {"interFileDependencies": False, "workspaceDiagnostics": False}}}
    elif method == "textDocument/diagnostic":
        result = {"kind": "full", "resultId": "1", "items": [
            {"range": span, "severity": 2, "message": "pulled fixture warning"}]}
    elif method == "textDocument/documentLink":
        result = [{"range": span, "target": target.as_uri()}]
    elif method == "exit":
        sys.exit(0)
    if "id" in message:
        send({"jsonrpc": "2.0", "id": message["id"], "result": result})
