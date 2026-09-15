"""Minimal protocol peer recording real process env and project routing."""
import json
import os
from pathlib import Path
import sys

log = Path(os.environ['PV_LSP_LOG'])
root = ''
while True:
    headers = {}
    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            sys.exit(0)
        if line == b'\r\n':
            break
        key, value = line.decode().split(':', 1)
        headers[key.lower()] = value.strip()
    message = json.loads(sys.stdin.buffer.read(int(headers['content-length'])))
    method = message.get('method', '')
    params = message.get('params', {})
    if method == 'initialize':
        root = params['rootUri']
    with log.open('a', encoding='utf-8') as output:
        output.write(json.dumps({'method': method, 'root': root, 'env': os.environ['PV_PROJECT'],
                                 'uri': params.get('textDocument', {}).get('uri', '')}) + '\n')
    if method == 'exit':
        break
    if 'id' in message:
        result = {'capabilities': {'textDocumentSync': 1, 'hoverProvider': True}} if method == 'initialize' else None
        if method == 'textDocument/hover':
            result = {'contents': os.environ['PV_PROJECT']}
        body = json.dumps({'jsonrpc': '2.0', 'id': message['id'], 'result': result}).encode()
        sys.stdout.buffer.write(f'Content-Length: {len(body)}\r\n\r\n'.encode() + body)
        sys.stdout.buffer.flush()
