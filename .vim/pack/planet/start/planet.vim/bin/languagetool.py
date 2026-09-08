#!/usr/bin/env python3
"""Adapt the local LanguageTool JSON CLI to the bundled Grammarous XML API."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET


def prefix(text, units):
    """LanguageTool offsets use Java UTF-16 units, including surrogate pairs."""
    if not isinstance(units, int) or units < 0:
        raise ValueError('Invalid LanguageTool text offset')
    encoded = text.encode('utf-16-le')
    if units * 2 > len(encoded):
        raise ValueError('LanguageTool text offset exceeds the source')
    return encoded[:units * 2].decode('utf-16-le')


def position(text, units):
    before = prefix(text, units)
    return before.count('\n'), len(before.rsplit('\n', 1)[-1].encode('utf-8'))


def as_xml(response, text):
    root = ET.Element('matches')
    for match in response['matches']:
        start, length = match['offset'], match['length']
        from_y, from_x = position(text, start)
        to_y, to_x = position(text, start + length)
        context = match.get('context', {})
        context_text = context.get('text', '')
        context_start = len(prefix(context_text, context.get('offset', 0)).encode('utf-8'))
        context_end = len(prefix(context_text, context.get('offset', 0) + context.get('length', 0)).encode('utf-8'))
        rule = match.get('rule', {})
        category = rule.get('category', {})
        values = {'fromy': from_y, 'fromx': from_x, 'toy': to_y, 'tox': to_x,
                  'msg': match['message'], 'ruleId': rule.get('id', ''),
                  'categoryid': category.get('id', ''), 'category': category.get('name', ''),
                  'context': context_text, 'contextoffset': context_start,
                  'errorlength': context_end - context_start,
                  'replacements': '#'.join(item['value'] for item in match.get('replacements', []))}
        ET.SubElement(root, 'error', {key: str(value) for key, value in values.items()})
    return ET.tostring(root, encoding='unicode')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', required=True)
    options, arguments = parser.parse_known_args()
    error_file = None
    try:
        config = json.loads(Path(options.config).read_text(encoding='utf-8'))
        if config.get('error_file'):
            error_file = Path(config['error_file'])
        command = config['argv']
        if not isinstance(command, list) or not command or not all(isinstance(arg, str) for arg in command):
            raise ValueError('LanguageTool command must be a nonempty argv list')
        if '--api' not in arguments or not arguments:
            raise ValueError('Expected the Grammarous --api request and source file')
        source = Path(arguments[-1])
        encoding = arguments[arguments.index('-c') + 1] if '-c' in arguments else 'utf-8'
        # LanguageTool counts the original CRLF bytes as two UTF-16 units.
        # Universal newline conversion would shift every later Windows line.
        with source.open(encoding=encoding, newline='') as stream:
            text = stream.read()
        arguments = ['--json' if argument == '--api' else argument for argument in arguments]
        process = subprocess.run(command + arguments, capture_output=True, text=True,
                                 encoding='utf-8', timeout=config.get('timeout', 60))
        if process.returncode:
            error = process.stderr or process.stdout or f'LanguageTool exited {process.returncode}'
            if error_file:
                error_file.write_text(error, encoding='utf-8')
            sys.stderr.write(error)
            return process.returncode if process.returncode > 0 else 1
        xml = as_xml(json.loads(process.stdout), text)
        if error_file:
            error_file.unlink(missing_ok=True)
        # Bypass redirected Windows console encodings; Grammarous expects UTF-8.
        sys.stdout.buffer.write(xml.encode('utf-8') + b'\n')
        return 0
    except Exception as error:
        if error_file:
            error_file.write_text(str(error), encoding='utf-8')
        sys.stderr.buffer.write(('PlanetVim LanguageTool: ' + str(error) + '\n').encode('utf-8'))
        return 1


if __name__ == '__main__':
    sys.exit(main())
