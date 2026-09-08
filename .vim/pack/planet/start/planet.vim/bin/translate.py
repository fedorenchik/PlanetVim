#!/usr/bin/env python3
"""Run bundled translation engines without shell evaluation or text rewriting."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import urllib.request

# The provider lives in a read-only bundled plugin. Never write its __pycache__.
sys.dont_write_bytecode = True


def translate(request):
    text = request['text']
    source, target = request['source'], request['target']
    proxy = request.get('proxy', '')
    if proxy:
        if not proxy.startswith(('http://', 'https://')):
            raise ValueError('Use an HTTP(S) proxy URL; TLS verification remains enabled.')
        urllib.request.install_opener(urllib.request.build_opener(
            urllib.request.ProxyHandler({'http': proxy, 'https': proxy})))
    spec = importlib.util.spec_from_file_location('planetvim_translation_provider', request['provider'])
    provider = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(provider)

    def run(engine):
        try:
            if engine in ('trans', 'sdcv'):
                if not shutil.which(engine):
                    raise ValueError(f'Install {engine} and put it on PATH.')
                if engine == 'trans':
                    argv = ['trans', '-brief', '-no-ansi'] + request.get('options', [])
                    argv += [f'{"" if source == "auto" else source}:{target}', '--', text]
                else:
                    argv = ['sdcv', '--non-interactive', '--', text]
                process = subprocess.run(argv, capture_output=True, text=True, timeout=20)
                if process.returncode:
                    raise ValueError(process.stderr.strip() or f'{engine} exited {process.returncode}')
                result = {'engine': engine, 'paraphrase': process.stdout.strip(), 'explains': []}
            else:
                if engine not in provider.ENGINES:
                    raise ValueError(f'Unknown translation engine: {engine}')
                result = provider.ENGINES[engine]().translate(source, target, text, [])
            if not result or not (result.get('paraphrase') or result.get('explains')):
                raise ValueError(f'{engine} returned no translation')
            return result, None
        except Exception as error:
            return None, f'{engine}: {error}'

    with ThreadPoolExecutor(max_workers=min(8, len(request['engines']))) as pool:
        outcomes = list(pool.map(run, request['engines']))
    results = [result for result, error in outcomes if result]
    return {'text': text, 'status': bool(results), 'results': results,
            'errors': [error for result, error in outcomes if error]}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--request', required=True)
    args = parser.parse_args()
    try:
        request = json.loads(Path(args.request).read_text(encoding='utf-8'))
        result = translate(request)
    except Exception as error:
        result = {'status': False, 'results': [], 'errors': [str(error)]}
    # ASCII JSON transports every Unicode string without relying on Windows'
    # redirected-console code page; Vim json_decode restores the exact text.
    print(json.dumps(result, ensure_ascii=True))
    return 0 if result['status'] else 1


if __name__ == '__main__':
    sys.exit(main())
