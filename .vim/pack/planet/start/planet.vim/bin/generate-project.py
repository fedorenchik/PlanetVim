#!/usr/bin/env python3
"""Copy bundled templates safely; install dependencies only with --install.

No shell, direnv authorization, repository clone, or application launch is
implicit in a template copy. Generated projects use the bundled template versions.
"""
import argparse
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tempfile
import uuid


class GenerationError(Exception):
    pass


def template_source(root, relative):
    name = PurePosixPath(relative)
    if (not relative or name.is_absolute() or '..' in name.parts
            or '\\' in relative or ':' in relative or name.as_posix() != relative):
        raise GenerationError('Template name must be a relative path inside the template directory.')
    source = root.joinpath(*name.parts)
    for path in [source] + list(source.parents):
        if path == root:
            break
        if path.is_symlink():
            raise GenerationError('Template symlinks are not supported: ' + str(path))
    if not source.exists():
        raise GenerationError('Template does not exist: ' + str(source))
    return source


def destination_path(value):
    if not value:
        raise GenerationError('No destination selected.')
    result = Path(value).expanduser().absolute()
    if result.is_symlink():
        raise GenerationError('Destination must not be a symlink: ' + str(result))
    if not result.parent.is_dir():
        raise GenerationError('Destination parent does not exist: ' + str(result.parent))
    return result.parent.resolve() / result.name


def check_empty_directory(destination):
    if destination.exists() and (not destination.is_dir() or any(destination.iterdir())):
        raise GenerationError('Destination already exists and is not an empty directory: ' + str(destination))


def reject_source_links(source):
    if source.is_symlink():
        raise GenerationError('Template symlinks are not supported: ' + str(source))
    if source.is_dir():
        for directory, directories, files in os.walk(source, followlinks=False):
            for name in directories + files:
                path = Path(directory) / name
                if path.is_symlink():
                    raise GenerationError('Template symlinks are not supported: ' + str(path))


def copy_template(source, destination, directory=True):
    if directory != source.is_dir():
        raise GenerationError('Template has the wrong file/directory type: ' + str(source))
    reject_source_links(source)
    if source == destination or source in destination.parents:
        raise GenerationError('Destination must be outside the source template.')
    if directory:
        check_empty_directory(destination)
    elif destination.exists():
        raise GenerationError('Destination file already exists: ' + str(destination))
    # Stage beside the destination, ensuring rename stays on the same filesystem.
    with tempfile.TemporaryDirectory(prefix='.planetvim-generate-', dir=destination.parent) as temporary:
        workspace = Path(temporary)
        staged = workspace / 'payload'
        if directory:
            shutil.copytree(source, staged)
        else:
            shutil.copy2(source, staged)
        # Qt model identifiers must be distinct in every generated document.
        models = list(staged.rglob('*.qmodel')) if staged.is_dir() else ([staged] if source.suffix == '.qmodel' else [])
        for model in models:
            text = model.read_text(encoding='utf-8')
            for token in ('%{UUID1}', '%{UUID2}', '%{UUID3}'):
                text = text.replace(token, '{' + str(uuid.uuid4()) + '}')
            model.write_text(text, encoding='utf-8')

        # Keep an existing destination outside the disposable staging tree so
        # even a concurrent writer cannot make cleanup remove original data.
        previous = destination.parent / ('.planetvim-previous-' + uuid.uuid4().hex)
        moved_previous = False
        reserved_file = False
        try:
            if directory:
                check_empty_directory(destination)
                if destination.exists():
                    destination.rename(previous)
                    moved_previous = True
                    if any(previous.iterdir()):
                        raise GenerationError('Destination changed during generation; original contents preserved.')
                if destination.exists():
                    raise GenerationError('Destination appeared during generation; refusing to overwrite it.')
                staged.rename(destination)
            else:
                # Exclusive creation prevents overwriting a file that appeared
                # while staging. The reserved file is owned by this operation.
                descriptor = os.open(str(destination), os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
                os.close(descriptor)
                reserved_file = True
                os.replace(staged, destination)
                reserved_file = False
        except BaseException:
            if reserved_file and destination.exists():
                destination.unlink()
            if moved_previous and not destination.exists():
                previous.rename(destination)
            elif moved_previous:
                print('Previous destination retained at ' + str(previous), file=sys.stderr)
            raise
        if moved_previous:
            previous.rmdir()
    print('Created ' + str(destination), flush=True)


def executable_argv(value, package):
    command = json.loads(value) if value.startswith('[') else [value]
    if not isinstance(command, list) or not command or any(not isinstance(arg, str) for arg in command):
        raise GenerationError('Tool configuration must be an executable or JSON argv List.')
    found = shutil.which(command[0])
    if not found:
        raise GenerationError("Required tool '" + value + "' is missing; install it before selecting this action.")
    executable = Path(found)
    if os.name != 'nt' or executable.suffix.lower() not in ('.cmd', '.bat'):
        return [str(executable)] + command[1:]
    # Invoke npm's JavaScript entry directly on Windows, avoiding batch/shell
    # reinterpretation of project paths containing &, %, !, or parentheses.
    package_dir = executable.parent / 'node_modules' / package
    manifest = package_dir / 'package.json'
    if manifest.is_file():
        metadata = json.loads(manifest.read_text(encoding='utf-8'))
        entry = metadata.get('bin', {})
        entry = entry.get(package) if isinstance(entry, dict) else entry
        node = shutil.which('node')
        if not node and (executable.parent / 'node.exe').is_file():
            node = str(executable.parent / 'node.exe')
        if node and isinstance(entry, str) and (package_dir / entry).is_file():
            return [node, str(package_dir / entry)] + command[1:]
    raise GenerationError('Cannot resolve the Node entry point for ' + str(executable)
                          + '; install Node and ' + package + ' together or configure a native executable.')


def run(argv, cwd):
    print('Command: ' + json.dumps(argv, ensure_ascii=False), flush=True)
    print('Working directory: ' + str(cwd), flush=True)
    result = subprocess.run(argv, cwd=cwd, check=False)
    print('Exit status: ' + str(result.returncode), flush=True)
    return result.returncode if result.returncode >= 0 else 128 - result.returncode


def generate(operation, name, destination, templates, install=False, npm='npm', nuxt='create-nuxt-app'):
    destination = destination_path(destination)
    templates = Path(templates).resolve()
    if operation == 'framework':
        if name == 'nuxt':
            if install:
                raise GenerationError('Nuxt dependency choices belong to its interactive creator; omit --install.')
            check_empty_directory(destination)
            command = executable_argv(nuxt, 'create-nuxt-app')
            status = run(command + [str(destination)], destination.parent)
            if status == 0 and not (destination / 'package.json').is_file():
                raise GenerationError('The Nuxt creator exited successfully but produced no package.json.')
            return status
        variants = {'electron': 'electron-app', 'vue3': 'vue-3-app'}
        if name not in variants:
            raise GenerationError('Unknown framework: ' + name)
        # Check prerequisites before creating files; installation is opt-in.
        command = executable_argv(npm, 'npm') if install else None
        copy_template(template_source(templates, variants[name]), destination)
        return run(command + ['install'], destination) if command else 0
    if install:
        raise GenerationError('--install is valid only for explicit framework generation.')
    source = template_source(templates, name)
    copy_template(source, destination, directory=operation == 'template')
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation', choices=('template', 'file', 'framework'))
    parser.add_argument('name')
    parser.add_argument('destination')
    parser.add_argument('--templates', type=Path, default=Path(__file__).resolve().parent.parent / 'templates')
    parser.add_argument('--install', action='store_true', help='explicitly run npm install for Electron/Vue')
    parser.add_argument('--npm', default='npm', help='npm executable name/path or JSON argv List')
    parser.add_argument('--nuxt', default='create-nuxt-app', help='installed Nuxt creator executable or JSON argv List')
    args = parser.parse_args(argv)
    try:
        return generate(args.operation, args.name, args.destination, args.templates, args.install, args.npm, args.nuxt)
    except (GenerationError, OSError, ValueError) as error:
        print('PlanetVim generation failed: ' + str(error), file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print('PlanetVim generation cancelled; any generated project is retained for inspection.', file=sys.stderr)
        return 130


if __name__ == '__main__':
    sys.exit(main())
