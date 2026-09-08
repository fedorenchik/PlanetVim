import argparse
import json
from pathlib import Path
import time

parser = argparse.ArgumentParser()
parser.add_argument('--request', required=True)
request = json.loads(Path(parser.parse_args().request).read_text(encoding='utf-8'))
if request['text'].startswith('DELAY'):
    time.sleep(0.2)
if request['text'].startswith('HANG'):
    time.sleep(10)
if request['text'] == 'INVALID':
    print('execute("let g:PV_translation_injected = 1")')
else:
    print(json.dumps({'status': request['text'] != 'FAIL', 'text': request['text'],
                      'results': [{'engine': 'fixture', 'paraphrase': '译文 ' + request['text'], 'explains': []}],
                      'errors': []}, ensure_ascii=True))
