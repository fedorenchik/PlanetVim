"""JSON-only local process fixture; no network or real language service."""
import json
from pathlib import Path
import sys

record, literal, *arguments = sys.argv[1:]
Path(record).write_text(json.dumps([literal] + arguments), encoding='utf-8')
with Path(arguments[-1]).open(encoding='utf-8', newline='') as stream:
    text = stream.read()
if text.startswith('FAIL'):
    print('isolated grammar failure', file=sys.stderr)
    raise SystemExit(7)
start = text.find('is is')
matches = []
if start >= 0:
    offset = len(text[:start].encode('utf-16-le')) // 2
    matches = [{'offset': offset, 'length': 5, 'message': 'Repeated word.',
                'context': {'text': text.rstrip('\n'), 'offset': offset, 'length': 5},
                'replacements': [{'value': 'is'}],
                'rule': {'id': 'WORD_REPEAT', 'category': {'id': 'GRAMMAR', 'name': 'Grammar'}}}]
print(json.dumps({'matches': matches}, ensure_ascii=True))
