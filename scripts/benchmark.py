#!/usr/bin/env python3
"""Measure real GVim startup with isolated per-run configuration and state."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import statistics
import subprocess
import sys
import tempfile
import time

from test import virtual_display, vim_string

ROOT = Path(__file__).resolve().parents[1]


def sample(executable, display):
    with tempfile.TemporaryDirectory(prefix='planetvim-benchmark-') as temporary:
        directory = Path(temporary)
        result_path = directory / 'result.json'
        preamble = directory / 'before.vim'
        for name in ('config', 'state', 'cache'):
            (directory / name).mkdir()
        preamble.write_text('\n'.join([
            'set encoding=utf-8 nomore nomodeline',
            'set viminfofile=NONE',
            'let g:PV_config_dir = ' + vim_string(directory / 'config'),
            'let g:PV_state_dir = ' + vim_string(directory / 'state'),
            'let g:PV_cache_dir = ' + vim_string(directory / 'cache'),
            'let g:startify_disable_at_vimenter = 1',
            'let g:PV_benchmark_start = reltime()',
            'function! PlanetVimBenchmarkDone(timer) abort',
            "  let result = {'startup_seconds': reltimefloat(reltime(g:PV_benchmark_start)), 'error': v:errmsg, 'messages': execute('messages')}",
            '  call writefile([json_encode(result)], ' + vim_string(result_path) + ')',
            '  qall!',
            'endfunction',
            "autocmd VimEnter * call timer_start(0, function('PlanetVimBenchmarkDone'))",
        ]) + '\n', encoding='utf-8')
        environment = os.environ.copy()
        # An installed launcher may have supplied a different runtime root.
        environment['PLANETVIM_ROOT'] = str(ROOT)
        if display:
            environment['DISPLAY'] = display
        command = [executable, '-f', '-N', '-n', '-i', 'NONE', '-U', 'NONE',
                   '--cmd', "execute 'source ' .. fnameescape(" + vim_string(preamble) + ')',
                   '-u', str(ROOT / 'scripts/planetvim.vim')]
        started = time.perf_counter()
        process = subprocess.run(command, cwd=directory, env=environment,
                                 capture_output=True, text=True, timeout=30)
        wall = time.perf_counter() - started
        if not result_path.is_file():
            raise RuntimeError('GVim did not complete startup: ' + process.stderr[-2000:])
        result = json.loads(result_path.read_text(encoding='utf-8'))
        if process.returncode or re.search(r'\bE\d{2,}:', result['messages']):
            raise RuntimeError('Startup reported an error: ' + result['error'] + '\n' + result['messages'][-3000:])
        return {'startup_seconds': result['startup_seconds'], 'process_seconds': wall,
                'last_vim_error': result['error']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runs', type=int, default=5, help='measured samples, after one excluded warmup')
    parser.add_argument('--gvim', default=os.environ.get('GVIM', 'gvim'))
    parser.add_argument('--xvfb', help='Xvfb executable for a private Linux display')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    if not 1 <= args.runs <= 100:
        parser.error('--runs must be between 1 and 100')
    executable = shutil.which(args.gvim)
    if not executable:
        parser.error('GVim is not available; use --gvim PATH')
    if os.name != 'nt' and not args.xvfb and not os.environ.get('DISPLAY'):
        parser.error('A GUI display is required; use --xvfb /path/to/Xvfb')
    try:
        with virtual_display(args.xvfb) as display:
            sample(executable, display)
            samples = [sample(executable, display) for _ in range(args.runs)]
        durations = [record['startup_seconds'] for record in samples]
        version = subprocess.run([executable, '--version'], capture_output=True, text=True, check=True).stdout.splitlines()[:2]
        revision = subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=ROOT, capture_output=True, text=True, check=True).stdout.strip()
        dirty = subprocess.run(['git', '-c', 'core.fsmonitor=false', 'status', '--porcelain'], cwd=ROOT, capture_output=True, text=True, check=True).stdout != ''
        inventory = ROOT / 'docs/plugins.json'
        result = {'measurement': 'GVim pre-vimrc initialization through first event-loop callback after VimEnter; one warmup excluded',
                  'revision': revision, 'working_tree_modified': dirty,
                  'inventory_sha256': hashlib.sha256(inventory.read_bytes()).hexdigest() if inventory.exists() else None,
                  'platform': platform.platform(), 'machine': platform.machine(), 'processor': platform.processor(),
                  'gvim': version, 'display': 'private Xvfb' if args.xvfb else 'host GUI display',
                  'runs': args.runs, 'median_seconds': statistics.median(durations),
                  'minimum_seconds': min(durations), 'maximum_seconds': max(durations), 'samples': samples}
        encoded = json.dumps(result, indent=2, sort_keys=True) + '\n'
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(encoded, encoding='utf-8')
        print(encoded, end='')
        return 0
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        print('PlanetVim benchmark: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
