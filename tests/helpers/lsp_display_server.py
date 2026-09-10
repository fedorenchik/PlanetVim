"""Tiny deterministic LSP peer for display integration tests; no external tools."""
import json
import sys


def send(message):
    data = json.dumps(message).encode()
    sys.stdout.buffer.write(f"Content-Length: {len(data)}\r\n\r\n".encode() + data)
    sys.stdout.buffer.flush()


while True:
    length = None
    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            sys.exit(0)
        if line in (b"\r\n", b"\n"):
            break
        if line.lower().startswith(b"content-length:"):
            length = int(line.split(b":", 1)[1])
    if length is None:
        continue
    message = json.loads(sys.stdin.buffer.read(length))
    method = message.get("method")
    result = None
    if method == "initialize":
        result = {"capabilities": {"textDocumentSync": 1, "inlayHintProvider": True}}
    elif method == "textDocument/inlayHint":
        result = [{"position": {"line": 0, "character": 9}, "label": ": int", "kind": 1}]
    elif method == "textDocument/didOpen":
        uri = message["params"]["textDocument"]["uri"]
        send({"jsonrpc": "2.0", "method": "textDocument/publishDiagnostics", "params": {
            "uri": uri, "diagnostics": [{"range": {"start": {"line": 0, "character": 0}, "end": {"line": 0, "character": 3}},
                                        "message": "fixture diagnostic", "severity": 2}]}})
    elif method == "exit":
        sys.exit(0)
    if "id" in message:
        send({"jsonrpc": "2.0", "id": message["id"], "result": result})
