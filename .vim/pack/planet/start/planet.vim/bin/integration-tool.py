#!/usr/bin/env python3
"""Process/environment handoff for optional SDKs. All tool arguments are literal."""
import argparse
import json
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import time


def native(command):
    found = shutil.which(command[0])
    if not found:
        raise ValueError('Required executable not found: ' + command[0])
    path = Path(found)
    if os.name != 'nt' or path.suffix.lower() not in ('.cmd', '.bat'):
        return [found] + command[1:]
    # Node tool shims have a native node.exe entry point. Avoid cmd parsing
    # project paths and arguments containing %, &, ! or parentheses.
    package_names = {'npm': 'npm', 'npx': 'npm', 'vue': '@vue/cli',
                     'electron': 'electron', 'electron-builder': 'electron-builder',
                     'electron-rebuild': '@electron/rebuild', 'nodemon': 'nodemon',
                     'gitbook': 'gitbook-cli', 'create-nuxt': 'create-nuxt'}
    name = path.stem
    for location in [path.parent / 'node_modules', path.parent.parent]:
        package = location / package_names.get(name, name)
        metadata = package / 'package.json'
        if metadata.is_file():
            bins = json.loads(metadata.read_text(encoding='utf-8')).get('bin')
            entry = bins.get(name) if isinstance(bins, dict) else bins
            node = shutil.which('node') or str(path.parent / 'node.exe')
            if isinstance(entry, str) and (package / entry).is_file() and Path(node).is_file():
                return [node, str(package / entry)] + command[1:]
    raise ValueError('Cannot invoke batch tool safely as native argv: ' + found
                     + '. Configure its native executable/interpreter argv in g:PV_integration_tools.')


def capture(command, target):
    target = Path(target)
    if target.exists():
        raise ValueError('Output already exists: ' + str(target))
    # Failed tools never install partial output under the requested filename.
    with tempfile.TemporaryDirectory(prefix='.planetvim-capture-', dir=target.parent) as directory:
        staged = Path(directory) / 'output'
        with staged.open('wb') as output:
            result = subprocess.run(native(command), stdout=output).returncode
        if result:
            return result
        with target.open('xb') as output, staged.open('rb') as data:
            shutil.copyfileobj(data, output)
    print('Wrote ' + str(target))
    return 0


def source_environment(script, target, arguments):
    script = Path(script).resolve(strict=True)
    helper = str(Path(__file__).resolve())
    if os.name == 'nt':
        # This operation explicitly sources a user-selected batch script.
        # Restrict syntax that cmd expands even inside quoted batch arguments.
        words = [str(script), sys.executable, helper, str(target)] + arguments
        if any(any(c in value for c in '\r\n"%!') for value in words):
            raise ValueError('Batch setup paths/arguments cannot contain quotes, %, ! or newlines.')
        command = 'call "' + str(script) + '"'
        command += ''.join(' "' + item + '"' for item in arguments)
        command += ' >nul && "' + sys.executable + '" "' + helper + '" dump-env "' + str(target) + '"'
        return subprocess.run(['cmd.exe', '/d', '/v:off', '/s', '/c', command]).returncode
    bash = shutil.which('bash')
    if not bash:
        raise ValueError('Install Bash to source this SDK setup script.')
    # User-selected setup script receives argv; no filename is interpolated
    # into shell code. stdout remains visible in the PlanetVim output window.
    return subprocess.run([bash, '-c',
        'pv_script=$1; pv_python=$2; pv_helper=$3; pv_result=$4; shift 4; source "$pv_script" "$@" && "$pv_python" "$pv_helper" dump-env "$pv_result"',
        'planetvim-sdk', str(script), sys.executable, helper, str(target)] + arguments).returncode


def view_display(display, password, port, viewer_display):
    server_command = native(['x11vnc', '-display', display, '-localhost',
                             '-rfbauth', password, '-rfbport', port, '-forever'])
    viewer_command = native(['vncviewer', '-passwd', password, 'localhost::' + port])
    # Refuse a port already in use so this action cannot accidentally connect
    # the viewer to an unrelated VNC server.
    with socket.socket() as probe:
        if probe.connect_ex(('127.0.0.1', int(port))) == 0:
            raise ValueError('VNC port is already in use: ' + port)
    server = subprocess.Popen(server_command)
    try:
        for _ in range(50):
            if server.poll() is not None:
                return server.returncode or 1
            with socket.socket() as probe:
                if probe.connect_ex(('127.0.0.1', int(port))) == 0:
                    break
            time.sleep(0.1)
        else:
            raise ValueError('VNC server did not become ready')
        environment = dict(os.environ, DISPLAY=viewer_display)
        return subprocess.run(viewer_command, env=environment).returncode
    finally:
        if server.poll() is None:
            server.terminate()
            try:
                server.wait(timeout=5)
            except subprocess.TimeoutExpired:
                server.kill()
                server.wait()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation', choices=['capture', 'source-env', 'dump-env', 'conda-env', 'native', 'view-display'])
    parser.add_argument('target')
    parser.add_argument('arguments', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.operation == 'view-display':
        # Run the finally cleanup when the owning PlanetVim output is stopped.
        signal.signal(signal.SIGTERM, lambda signum, frame: sys.exit(128 + signum))
    try:
        if args.operation == 'view-display':
            return view_display(args.target, *args.arguments)
        if args.operation == 'dump-env':
            Path(args.target).write_text(json.dumps(dict(os.environ)), encoding='utf-8')
            return 0
        if args.operation == 'source-env':
            return source_environment(args.arguments[0], args.target, args.arguments[1:])
        if args.operation == 'conda-env':
            command = [args.arguments[0], 'run', '--no-capture-output', '-n', args.arguments[1],
                       sys.executable, str(Path(__file__).resolve()), 'dump-env', args.target]
            return subprocess.run(native(command)).returncode
        if args.operation == 'native':
            return subprocess.run(native([args.target] + args.arguments)).returncode
        return capture(args.arguments, args.target)
    except (OSError, ValueError, IndexError, OverflowError, TypeError) as error:
        print('PlanetVim: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
