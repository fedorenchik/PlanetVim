#!/usr/bin/env python3
"""Run first-party Vimscript checks in isolated GVim processes.

Use --gui under a real/virtual display to exercise the actual supported GUI.
Without --gui, GVim's Ex mode provides quick engine checks, not terminal support.
"""
import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import shutil
import select
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def vim_string(value):
    return "'" + str(value).replace("'", "''") + "'"


@contextmanager
def virtual_display(executable):
    if not executable:
        yield None
        return
    read_fd, write_fd = os.pipe()
    server = subprocess.Popen([executable, '-displayfd', str(write_fd),
                               '-screen', '0', '1280x900x24', '-nolisten', 'tcp',
                               '-ac', '-noreset'], pass_fds=(write_fd,),
                              stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    os.close(write_fd)
    try:
        if not select.select([read_fd], [], [], 10)[0]:
            raise RuntimeError('Xvfb did not start within 10 seconds')
        number = os.read(read_fd, 64).decode().strip()
        if not number.isdigit():
            raise RuntimeError('Xvfb failed: ' + server.stderr.read().decode()[-2000:])
        yield ':' + number
    finally:
        os.close(read_fd)
        server.terminate()
        server.wait(timeout=10)


def run(path, executable, gui, display=None):
    with tempfile.TemporaryDirectory(prefix="planetvim-test-") as directory:
        temp = Path(directory)
        for child in ("config", "state", "cache"):
            (temp / child).mkdir()
        result = temp / "result.json"
        runtime = ROOT / ".vim/pack/planet/start/planet.vim"
        script = temp / "run.vim"
        lines = [
            "set nocompatible nomore nomodeline noswapfile noundofile",
            "set viminfofile=NONE",
            "set guioptions+=c",
            "if !has('win32') | set shell=/bin/sh | endif",
            f"let g:PV_root = {vim_string(ROOT)}",
            f"let g:PV_test_dir = {vim_string(temp)}",
            f"let g:PV_config_dir = {vim_string(temp / 'config')}",
            f"let g:PV_state_dir = {vim_string(temp / 'state')}",
            f"let g:PV_cache_dir = {vim_string(temp / 'cache')}",
            "let g:PV_config = g:PV_config_dir .. '/planetvimrc.vim'",
            f"let &runtimepath = {vim_string(runtime)} .. ',' .. $VIMRUNTIME",
            "let &packpath = $VIMRUNTIME",
            f"execute 'cd ' .. fnameescape({vim_string(temp)})",
            "try",
            "  call assert_true(has('gui_running'))" if gui else '  " Engine-only check',
            f"  execute 'source ' .. fnameescape({vim_string(path)})",
            "catch",
            "  call add(v:errors, v:exception .. ' at ' .. v:throwpoint)",
            "endtry",
            f"call writefile([json_encode(v:errors)], {vim_string(result)})",
            "execute 'cquit ' .. (empty(v:errors) ? 0 : 1)",
        ]
        script.write_text("\n".join(lines) + "\n", encoding="utf-8")
        command = [executable, "-f", "-Nu", "NONE", "-U", "NONE", "-i", "NONE", "-n"]
        if not gui:
            command += ["-v", "-es"]
        command += ["-S", str(script)]
        environment = dict(os.environ)
        if display:
            environment['DISPLAY'] = display
        for kind in ("CONFIG", "STATE", "CACHE"):
            environment[f"PLANETVIM_{kind}_DIR"] = str(temp / kind.lower())
        try:
            process = subprocess.run(command, cwd=temp, env=environment,
                                     capture_output=True, text=True, timeout=60)
        except subprocess.TimeoutExpired:
            return ["GVim timed out after 60 seconds"]
        if not result.exists():
            return [f"GVim exited {process.returncode} without a result: "
                    + process.stderr[-2000:]]
        errors = json.loads(result.read_text(encoding="utf-8"))
        if process.returncode and not errors:
            errors.append(f"GVim exited {process.returncode}: {process.stderr[-2000:]}")
        return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tests", nargs="*", type=Path)
    parser.add_argument("--gui", action="store_true")
    parser.add_argument("--gvim", default=os.environ.get("GVIM", "gvim"))
    parser.add_argument("--xvfb", help="Xvfb executable for an isolated GUI display (Linux)")
    args = parser.parse_args()
    executable = shutil.which(args.gvim)
    if not executable:
        parser.error("GVim was not found; install GVim or pass --gvim PATH")
    tests = [p.resolve() for p in args.tests] or sorted((ROOT / "tests").glob("test_*.vim"))
    if not tests:
        parser.error("No Vimscript tests found")
    failed = 0
    with virtual_display(args.xvfb) as display:
        for test in tests:
            errors = run(test, executable, args.gui, display)
            print(f"{'FAIL' if errors else 'PASS'} {test.name}", flush=True)
            for error in errors:
                print("  " + error, flush=True)
            failed += bool(errors)
    print(f"{len(tests) - failed}/{len(tests)} files passed ({'GUI' if args.gui else 'GVim engine'} checks)")
    return bool(failed)


if __name__ == "__main__":
    sys.exit(main())
