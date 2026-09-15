#!/usr/bin/env python3
"""Resolve configure-preset paths/env; CMake validates and applies the preset.

Only explicit CMake actions invoke this helper. No project code is evaluated.
"""
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys

MACRO = re.compile(r'\$(\w*)\{([^}]*)\}')


class Presets:
    def __init__(self, source, environ=None):
        self.source = Path(source).resolve()
        self.parent = dict(os.environ if environ is None else environ)
        self.presets = {}
        self.loaded = set()
        for filename in ('CMakePresets.json', 'CMakeUserPresets.json'):
            path = self.source / filename
            if path.exists():
                self.load(path, [])

    def macros(self, path, name='', generator=''):
        return dict(sourceDir=str(self.source), sourceParentDir=str(self.source.parent),
                    sourceDirName=self.source.name, fileDir=str(path.parent),
                    presetName=name, generator=generator, hostSystemName=platform.system(),
                    dollar='$', pathListSep=os.pathsep)

    @staticmethod
    def expand(text, macros, env, parent):
        def replace(match):
            namespace, key = match.groups()
            if namespace == 'penv':
                return parent.get(key, '')
            if namespace == 'env':
                return env(key)
            if namespace == '' and key in macros:
                return macros[key]
            raise ValueError('unsupported CMake macro: ' + match[0])
        return MACRO.sub(replace, text)

    def load(self, path, stack):
        path = path.resolve()
        if path in stack:
            raise ValueError('CMake preset include cycle: ' + str(path))
        if path in self.loaded:
            return
        data = json.loads(path.read_text(encoding='utf-8'))
        for included in data.get('include', []):
            included = self.expand(included, self.macros(path), self.parent.get, self.parent)
            self.load(path.parent / included, stack + [path])
        for preset in data.get('configurePresets', []):
            name = preset['name']
            if name in self.presets:
                raise ValueError('duplicate CMake preset: ' + name)
            # v12 fileDir is expanded at its definition, before inheritance.
            def local(value):
                if isinstance(value, str) and data['version'] >= 12:
                    return value.replace('${fileDir}', str(path.parent))
                if isinstance(value, dict):
                    return {k: local(v) for k, v in value.items()}
                return value
            self.presets[name] = (local(preset), path)
        self.loaded.add(path)

    def inherit(self, name, stack=()):
        if name in stack:
            raise ValueError('CMake preset inheritance cycle: ' + name)
        if name not in self.presets:
            raise ValueError('unknown CMake preset: ' + name)
        preset, _ = self.presets[name]
        parents = preset.get('inherits', [])
        if isinstance(parents, str):
            parents = [parents]
        result = {}
        for parent in reversed(parents):
            inherited = self.inherit(parent, stack + (name,))
            for key in ('name', 'hidden', 'inherits', 'description', 'displayName'):
                inherited.pop(key, None)
            result = self.merge(result, inherited)
        return self.merge(result, preset)

    @staticmethod
    def merge(base, extra):
        result = dict(base)
        for key, value in extra.items():
            if key == 'environment':
                result[key] = dict(result.get(key, {}), **value)
            else:
                result[key] = value
        return result

    def resolve(self, name):
        preset = self.inherit(name)
        macros = self.macros(self.presets[name][1], name, preset.get('generator', ''))
        raw = preset.get('environment', {})
        resolved = {}
        active = set()

        def env(key):
            if key in active:
                raise ValueError('CMake preset environment cycle: ' + key)
            if key not in raw:
                return self.parent.get(key, '')
            if key not in resolved:
                active.add(key)
                resolved[key] = (self.expand(raw[key], macros, env, self.parent)
                                 if raw[key] is not None else '')
                active.remove(key)
            return resolved[key]

        environment = dict(self.parent)
        for key in raw:
            value = env(key)
            if raw[key] is None:
                environment.pop(key, None)
            else:
                environment[key] = value
        binary = preset.get('binaryDir', '')
        binary = self.expand(binary, macros, env, self.parent) if binary else ''
        return {'name': name, 'build_dir': str((self.source / binary).resolve()) if binary else '',
                'environment': environment}


def main():
    request = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
    source = request['source_dir']
    # CMake owns schema/condition validation, including private presets and includes.
    result = subprocess.run(request['cmake'] + ['--list-presets=configure'], cwd=source,
                            capture_output=True, text=True, timeout=10)
    if result.returncode:
        raise ValueError(result.stderr.strip() or result.stdout.strip())
    names = re.findall(r'^  "([^"]+)"', result.stdout, re.MULTILINE)
    selected = request.get('preset', '')
    if not selected:
        return {'names': names}
    if selected not in names:
        raise ValueError('CMake configure preset is unavailable: ' + selected)
    return Presets(source).resolve(selected)


if __name__ == '__main__':
    try:
        print(json.dumps(main(), ensure_ascii=False))
    except (ValueError, KeyError, TypeError, OSError, subprocess.SubprocessError) as error:
        print(json.dumps({'error': str(error)}, ensure_ascii=False))
        sys.exit(1)
