#!/usr/bin/env python3
"""Install into a private prefix without changing ~/.vim or ~/.vimrc.

Payload replacements are staged, backed up, then atomically replaced per file.
A journal permits rollback after failure/interruption. This is not a simultaneous
snapshot switch for running editors: restart PlanetVim after updating. The
PLANETVIM_PREFIX environment variable supplies the prefix used by Makefile.
"""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shlex
import shutil
import stat
import sys
import tempfile
import uuid

METADATA = ".planetvim"
SCHEMA = 1
STATE_NAMES = {"session", "undo", "view", "viminfo", "tab"}
USER_FILES = {"planetvimrc.vim", "fern-bookmark.json", "clap_yanks.history"}


class InstallError(Exception):
    pass


def default_prefix(platform=None, environ=None):
    platform = sys.platform if platform is None else platform
    environ = os.environ if environ is None else environ
    if platform == "win32":
        if not environ.get("LOCALAPPDATA"):
            raise InstallError("LOCALAPPDATA is not set; specify --prefix.")
        return Path(environ["LOCALAPPDATA"]) / "PlanetVim"
    if platform.startswith("linux"):
        return Path.home() / ".local/share/planetvim"
    raise InstallError("Supported hosts are Linux and Windows; macOS is unsupported.")


def file_info(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(block)
    return {"sha256": result.hexdigest(), "mode": stat.S_IMODE(path.stat().st_mode) & 0o777}


def checked_relative(value):
    path = PurePosixPath(value)
    if (not value or path.is_absolute() or ".." in path.parts or "\\" in value
            or ":" in value or path.parts[0] == METADATA or path.as_posix() != value):
        raise InstallError("Unsafe payload path: " + repr(value))
    return path


def regular_or_absent(path):
    if path.is_symlink() or (path.exists() and not path.is_file()):
        raise InstallError("Refusing to replace a non-regular file: " + str(path))
    return path.is_file()


def sync_directory(path):
    if os.name != "nt":
        descriptor = os.open(str(path), os.O_RDONLY)
        try:
            os.fsync(descriptor)
        finally:
            os.close(descriptor)


def atomic_copy(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".planetvim-", dir=str(target.parent))
    try:
        with os.fdopen(descriptor, "wb") as output, source.open("rb") as incoming:
            shutil.copyfileobj(incoming, output)
            output.flush()
            os.fsync(output.fileno())
        os.chmod(temporary, stat.S_IMODE(source.stat().st_mode) & 0o777)
        os.replace(temporary, target)
        sync_directory(target.parent)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def atomic_json(target, value):
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".planetvim-", dir=str(target.parent))
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as output:
            json.dump(value, output, indent=2, sort_keys=True)
            output.write("\n")
            output.flush()
            os.fsync(output.fileno())
        os.replace(temporary, target)
        sync_directory(target.parent)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def read_json(path):
    regular_or_absent(path)
    try:
        with path.open(encoding="utf-8") as stream:
            return json.load(stream)
    except (OSError, ValueError) as error:
        raise InstallError("Cannot read " + str(path) + ": " + str(error)) from error


class Installer:
    def __init__(self, source, prefix, dry_run=False, platform=None, report=print):
        self.source = Path(source).resolve()
        original = Path(prefix).expanduser().absolute()
        if original.is_symlink():
            raise InstallError("The installation prefix must not be a symlink.")
        self.prefix = original.resolve()
        if self.prefix == self.source or self.prefix in self.source.parents or self.source in self.prefix.parents:
            raise InstallError("The prefix and source checkout must not overlap.")
        self.metadata = self.prefix / METADATA
        self.manifest_path = self.metadata / "manifest.json"
        self.pending_path = self.metadata / "pending.json"
        self.dry_run, self.report = dry_run, report
        self.platform = sys.platform if platform is None else platform
        if self.platform != "win32" and not self.platform.startswith("linux"):
            raise InstallError("Supported hosts are Linux and Windows; macOS is unsupported.")

    def target(self, relative):
        path = self.prefix.joinpath(*checked_relative(relative).parts)
        for parent in path.parents:
            if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
                raise InstallError("Unsafe installation directory: " + str(parent))
            if parent == self.prefix:
                break
        regular_or_absent(path)
        return path

    def validate_metadata(self, create=False):
        if self.metadata.is_symlink() or (self.metadata.exists() and not self.metadata.is_dir()):
            raise InstallError("Unsafe metadata path: " + str(self.metadata))
        owner = self.metadata / "owner.json"
        if self.metadata.exists():
            if not owner.is_file() or read_json(owner) != {"tool": "planetvim", "schema": SCHEMA}:
                raise InstallError("Refusing unrecognized metadata: " + str(self.metadata))
            backups = self.metadata / "backups"
            if backups.is_symlink() or (backups.exists() and not backups.is_dir()):
                raise InstallError("Unsafe backup directory: " + str(backups))
        elif create:
            self.metadata.mkdir(parents=True)
            atomic_json(owner, {"tool": "planetvim", "schema": SCHEMA})

    @contextmanager
    def locked(self):
        self.validate_metadata(create=True)
        lock_path = self.metadata / "lock"
        regular_or_absent(lock_path)
        with lock_path.open("a+b") as lock:
            if os.name == "nt":
                import msvcrt
                lock.seek(0, os.SEEK_END)
                if lock.tell() == 0:
                    lock.write(b"0")
                    lock.flush()
                lock.seek(0)
                try:
                    msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 1)
                except OSError as error:
                    raise InstallError("Another PlanetVim installer is running.") from error
                try:
                    yield
                finally:
                    lock.seek(0)
                    msvcrt.locking(lock.fileno(), msvcrt.LK_UNLCK, 1)
            else:
                import fcntl
                try:
                    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                except OSError as error:
                    raise InstallError("Another PlanetVim installer is running.") from error
                try:
                    yield
                finally:
                    fcntl.flock(lock, fcntl.LOCK_UN)

    def manifest(self):
        if not regular_or_absent(self.manifest_path):
            return None
        result = read_json(self.manifest_path)
        if not isinstance(result, dict) or result.get("schema") != SCHEMA or not isinstance(result.get("files"), dict):
            raise InstallError("Unsupported or invalid installation manifest.")
        for relative, info in result["files"].items():
            checked_relative(relative)
            if not isinstance(info, dict) or not isinstance(info.get("sha256"), str):
                raise InstallError("Invalid file entry in installation manifest.")
        return result

    def launcher(self):
        if self.platform == "win32":
            return "bin/planetvim.cmd", (
                '@echo off\r\nsetlocal\r\nset "PLANETVIM_ROOT=%~dp0.."\r\n'
                'if defined PLANETVIM_GVIM (\r\n'
                '  "%PLANETVIM_GVIM%" -u "%PLANETVIM_ROOT%\\scripts\\planetvim.vim" %*\r\n'
                ') else (\r\n'
                '  gvim -u "%PLANETVIM_ROOT%\\scripts\\planetvim.vim" %*\r\n'
                ')\r\nexit /b %errorlevel%\r\n').encode("utf-8")
        return "bin/planetvim", (
            "#!/bin/sh\nPLANETVIM_ROOT=" + shlex.quote(str(self.prefix)) + "\n"
            'export PLANETVIM_ROOT\nexec "${PLANETVIM_GVIM:-gvim}" '
            '-u "$PLANETVIM_ROOT/scripts/planetvim.vim" "$@"\n').encode("utf-8")

    def payload(self, staging):
        incoming = {}
        for relative in (".vimrc", "scripts/planetvim.vim"):
            source = self.source / relative
            if not regular_or_absent(source):
                raise InstallError("Distribution source is missing " + relative)
            incoming[relative] = source
        for relative in ("LICENSE", "VERSION", "CHANGELOG.md", "README.md", "CONTRIBUTING.md"):
            source = self.source / relative
            if regular_or_absent(source):
                incoming[relative] = source
        runtime = self.source / ".vim"
        if runtime.is_symlink() or not runtime.is_dir():
            raise InstallError("Distribution source is missing an ordinary .vim directory.")
        for directory, dirs, files in os.walk(runtime, followlinks=False):
            directory = Path(directory)
            for name in list(dirs):
                child = directory / name
                if child.is_symlink():
                    raise InstallError("Symlink in distribution source: " + str(child))
                if name in (".git", "__pycache__") or (directory == runtime and name in STATE_NAMES):
                    dirs.remove(name)
            for name in files:
                if name.endswith((".pyc", ".pyo")):
                    continue
                if directory == runtime and name in USER_FILES:
                    continue
                path = directory / name
                regular_or_absent(path)
                incoming[path.relative_to(self.source).as_posix()] = path
        documentation = self.source / "docs"
        if documentation.is_symlink():
            raise InstallError("Symlink in distribution source: " + str(documentation))
        if documentation.exists() and not documentation.is_dir():
            raise InstallError("Documentation path is not a directory: " + str(documentation))
        for directory, dirs, files in os.walk(documentation, followlinks=False):
            directory = Path(directory)
            for name in list(dirs):
                child = directory / name
                if child.is_symlink():
                    raise InstallError("Symlink in distribution source: " + str(child))
                if name in (".git", "__pycache__"):
                    dirs.remove(name)
            for name in files:
                if name.endswith((".pyc", ".pyo")):
                    continue
                path = directory / name
                regular_or_absent(path)
                incoming[path.relative_to(self.source).as_posix()] = path
        for relative, source in incoming.items():
            checked_relative(relative)
            target = staging / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
        relative, content = self.launcher()
        launcher = staging / relative
        launcher.parent.mkdir(parents=True, exist_ok=True)
        launcher.write_bytes(content)
        launcher.chmod(0o755)
        incoming[relative] = launcher
        return {relative: file_info(staging / relative) for relative in sorted(incoming)}

    def plan(self, before, after, command):
        old = before["files"] if before else {}
        changes, preserved = [], []
        for relative in sorted(set(old) | set(after)):
            target = self.target(relative)
            actual = file_info(target) if target.exists() else None
            wanted = after.get(relative)
            if relative not in old and actual:
                raise InstallError("Unmanaged file collision; move it or choose another prefix: " + str(target))
            if command == "uninstall" and actual and actual != old[relative]:
                preserved.append(relative)
                continue
            if actual != wanted:
                changes.append({"path": relative, "before": actual, "after": wanted})
        return changes, preserved

    def transaction_directory(self, transaction):
        if not isinstance(transaction, str) or len(transaction) != 32 or any(c not in "0123456789abcdef" for c in transaction):
            raise InstallError("Invalid backup identifier.")
        result = self.metadata / "backups" / transaction
        if result.is_symlink() or (result.exists() and not result.is_dir()):
            raise InstallError("Unsafe backup directory: " + str(result))
        return result

    def backup_file(self, directory, kind, relative):
        checked_relative(relative)
        path = directory / kind / relative
        for parent in path.parents:
            if parent == directory:
                break
            if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
                raise InstallError("Unsafe backup directory: " + str(parent))
        regular_or_absent(path)
        return path

    def describe(self, changes, preserved):
        self.report("Preview only; no destination files will be written." if self.dry_run else "Installation directory: " + str(self.prefix))
        counts = {"CREATE": 0, "REPLACE": 0, "REMOVE": 0}
        for change in changes:
            action = "REMOVE" if change["after"] is None else "REPLACE" if change["before"] else "CREATE"
            counts[action] += 1
            if self.dry_run:
                self.report(action + " " + str(self.prefix / change["path"]))
        if changes:
            self.report("Planned files: " + ", ".join(str(counts[key]) + " " + key.lower() for key in counts))
        for relative in preserved:
            self.report("KEEP locally modified " + str(self.prefix / relative))
        self.report("Backups/rollback metadata: " + str(self.metadata / "backups") if changes else "No payload changes.")

    def rollback(self, receipt, directory):
        # Do not mistake files created/edited by another process for our writes.
        # Check the whole rollback before changing anything; leave the journal in
        # place if an unexpected edit needs manual reconciliation with backups.
        applicable = []
        for change in reversed(receipt["changes"]):
            relative = change["path"]
            target = self.target(relative)
            actual = file_info(target) if target.exists() else None
            if actual == change["before"]:
                continue
            if actual != change["after"]:
                raise InstallError("Concurrent edit preserved; reconcile before recovery: " + str(target))
            if change["before"]:
                source = self.backup_file(directory, "before", relative)
                if file_info(source) != change["before"]:
                    raise InstallError("Rollback backup has changed: " + str(source))
            applicable.append(change)
        for change in applicable:
            target = self.target(change["path"])
            if change["before"]:
                source = self.backup_file(directory, "before", change["path"])
                atomic_copy(source, target)
            elif target.exists():
                target.unlink()
        if receipt["before_manifest"] is None:
            if self.manifest_path.exists():
                self.manifest_path.unlink()
        else:
            atomic_json(self.manifest_path, receipt["before_manifest"])
        receipt["status"] = "rolled-back"
        atomic_json(directory / "transaction.json", receipt)
        self.pending_path.unlink()

    def recover(self):
        if not regular_or_absent(self.pending_path):
            return
        if self.dry_run:
            raise InstallError("Interrupted transaction needs recovery; rerun without --dry-run.")
        pending = read_json(self.pending_path)
        directory = self.transaction_directory(pending.get("transaction"))
        receipt = read_json(directory / "transaction.json")
        current = self.manifest()
        if current and current.get("transaction") == pending["transaction"]:
            receipt["status"] = "committed"
            atomic_json(directory / "transaction.json", receipt)
            self.pending_path.unlink()
        else:
            self.rollback(receipt, directory)
            self.report("Recovered interrupted transaction from " + str(directory))

    def transact(self, command, before, after, changes, staging):
        transaction = uuid.uuid4().hex
        directory = self.transaction_directory(transaction)
        directory.mkdir(parents=True)
        updated = {"schema": SCHEMA, "transaction": transaction, "files": after}
        receipt = {"schema": SCHEMA, "command": command, "status": "preparing",
                   "before_manifest": before, "after_manifest": updated, "changes": changes}
        for change in changes:
            relative = change["path"]
            if change["before"]:
                backup = self.backup_file(directory, "before", relative)
                atomic_copy(self.target(relative), backup)
                if file_info(backup) != change["before"]:
                    raise InstallError("File changed while preparing backup: " + relative)
            if change["after"]:
                backup = self.backup_file(directory, "after", relative)
                atomic_copy(staging / relative, backup)
                if file_info(backup) != change["after"]:
                    raise InstallError("Staged payload changed: " + relative)
        receipt["status"] = "prepared"
        atomic_json(directory / "transaction.json", receipt)
        atomic_json(self.pending_path, {"transaction": transaction})
        try:
            for change in changes:
                target = self.target(change["path"])
                actual = file_info(target) if target.exists() else None
                if actual != change["before"]:
                    raise InstallError("File changed during installation: " + str(target))
                if change["after"]:
                    atomic_copy(self.backup_file(directory, "after", change["path"]), target)
                elif target.exists():
                    target.unlink()
                    sync_directory(target.parent)
            atomic_json(self.manifest_path, updated)
            receipt["status"] = "committed"
            atomic_json(directory / "transaction.json", receipt)
            self.pending_path.unlink()
        except BaseException:
            try:
                self.rollback(receipt, directory)
            except Exception as rollback_error:
                self.report("Rollback incomplete; retain backups at " + str(directory) + ": " + str(rollback_error))
            raise
        self.report("Backup: " + transaction + "; use 'restore' to undo this operation.")
        return updated

    def restore_plan(self, before, staging, backup):
        if not before:
            raise InstallError("No installed transaction to restore.")
        transaction = backup or before.get("transaction")
        if transaction != before.get("transaction"):
            raise InstallError("Only the most recent transaction can be restored.")
        directory = self.transaction_directory(transaction)
        receipt = read_json(directory / "transaction.json")
        if receipt.get("status") != "committed":
            raise InstallError("This backup is not a committed transaction.")
        previous = receipt["before_manifest"]
        after = previous["files"] if previous else {}
        changes = []
        for change in receipt["changes"]:
            relative = change["path"]
            target = self.target(relative)
            actual = file_info(target) if target.exists() else None
            if change["after"] is None and actual is not None:
                raise InstallError("An unmanaged file occupies the restore destination: " + str(target))
            wanted = change["before"]
            if wanted:
                source = self.backup_file(directory, "before", relative)
                if file_info(source) != wanted:
                    raise InstallError("Restore backup has changed: " + str(source))
                output = staging / relative
                output.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, output)
            if actual != wanted:
                changes.append({"path": relative, "before": actual, "after": wanted})
        return after, changes

    def run(self, command, backup=None):
        self.validate_metadata()
        if self.dry_run:
            return self.run_locked(command, backup)
        with self.locked():
            return self.run_locked(command, backup)

    def run_locked(self, command, backup):
        self.recover()
        before = self.manifest()
        if command in ("update", "uninstall") and not before:
            raise InstallError("No PlanetVim installation found at " + str(self.prefix))
        with tempfile.TemporaryDirectory(prefix="planetvim-stage-") as temporary:
            staging = Path(temporary)
            preserved = []
            if command in ("install", "update"):
                after = self.payload(staging)
                changes, preserved = self.plan(before, after, command)
            elif command == "uninstall":
                after = {}
                changes, preserved = self.plan(before, after, command)
            elif command == "restore":
                after, changes = self.restore_plan(before, staging, backup)
            else:
                raise InstallError("Unknown operation: " + command)
            self.describe(changes, preserved)
            if self.dry_run:
                return before
            if changes or (before and before["files"] != after):
                return self.transact(command, before, after, changes, staging)
            return before


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("install", "update", "uninstall", "restore"))
    parser.add_argument("--prefix", type=Path, help="private installation directory")
    parser.add_argument("--dry-run", action="store_true", help="report changes without writing destination files")
    parser.add_argument("--backup", help="restore this backup (must be the most recent transaction)")
    arguments = parser.parse_args(argv)
    if arguments.backup and arguments.operation != "restore":
        parser.error("--backup is only valid with restore")
    try:
        prefix = arguments.prefix if arguments.prefix is not None else (os.environ.get("PLANETVIM_PREFIX") or default_prefix())
        installer = Installer(Path(__file__).resolve().parents[1], prefix, arguments.dry_run)
        installer.run(arguments.operation, arguments.backup)
        if arguments.operation in ("install", "update") and not arguments.dry_run:
            executable = "planetvim.cmd" if sys.platform == "win32" else "planetvim"
            print("Launch: " + str(installer.prefix / "bin" / executable))
            print("Restart PlanetVim after updating. Existing ~/.vim and ~/.vimrc were not changed.")
        return 0
    except (InstallError, OSError) as error:
        print("PlanetVim installer: " + str(error), file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("PlanetVim installer: interrupted; backups retained for recovery.", file=sys.stderr)
        return 130


if __name__ == "__main__":
    sys.exit(main())
