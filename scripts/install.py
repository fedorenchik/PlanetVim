#!/usr/bin/env python3
"""Install PlanetVim for plain GVim, backing up the previous home startup file.

Payload replacements are staged, backed up, then atomically replaced per file.
A journal permits rollback after failure/interruption. This is not a simultaneous
snapshot switch for running editors: restart PlanetVim after updating. The
PLANETVIM_PREFIX environment variable supplies the prefix used by Makefile.
Use --private to install only the separate launcher without changing home startup.
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
SCHEMA = 2
READABLE_SCHEMAS = (1, SCHEMA)
STARTUP_KEY = "__home_vimrc__"  # Journal key, never a path in the payload.
STARTUP_MARKER = b'" PlanetVim managed GVim startup\n'
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


def startup_info(path):
    """Record the startup link itself, never the file it points to."""
    if path.is_symlink():
        return {"symlink": os.readlink(path)}
    return file_info(path) if regular_or_absent(path) else None


def copy_startup(source, target):
    if not source.is_symlink():
        return atomic_copy(source, target)
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".planetvim-", dir=str(target.parent))
    os.close(descriptor)
    os.unlink(temporary)
    try:
        os.symlink(os.readlink(source), temporary)
        os.replace(temporary, target)
        sync_directory(target.parent)
    finally:
        if os.path.lexists(temporary):
            os.unlink(temporary)


def vim_string(value):
    if any(character in str(value) for character in "\r\n\0"):
        raise InstallError("Home startup paths cannot contain newline or NUL characters.")
    return "'" + str(value).replace("'", "''") + "'"


def read_json(path):
    regular_or_absent(path)
    try:
        with path.open(encoding="utf-8") as stream:
            return json.load(stream)
    except (OSError, ValueError) as error:
        raise InstallError("Cannot read " + str(path) + ": " + str(error)) from error


class Installer:
    def __init__(self, source, prefix, dry_run=False, platform=None, report=print,
                 default_gvim=False, home=None, private=False):
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
        self.default_gvim = default_gvim
        self.private = private
        # Windows Vim honors HOME ahead of USERPROFILE (Path.home()).
        selected_home = home if home is not None else (
            os.environ.get("HOME") if self.platform == "win32" else None)
        self.home = Path(selected_home or Path.home()).expanduser().resolve()
        self.startup_path = self.home / ("_vimrc" if self.platform == "win32" else ".vimrc")
        alternate = self.home / (".vimrc" if self.platform == "win32" else "_vimrc")
        if not os.path.lexists(self.startup_path) and os.path.lexists(alternate):
            self.startup_path = alternate

    def target(self, relative):
        if relative == STARTUP_KEY:
            if self.startup_path.is_relative_to(self.prefix) or self.startup_path.is_relative_to(self.source):
                raise InstallError("The home startup file must be outside the installation and source.")
            for parent in self.startup_path.parents:
                if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
                    raise InstallError("Unsafe home directory: " + str(parent))
            startup_info(self.startup_path)
            return self.startup_path
        path = self.prefix.joinpath(*checked_relative(relative).parts)
        for parent in path.parents:
            if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
                raise InstallError("Unsafe installation directory: " + str(parent))
            if parent == self.prefix:
                break
        regular_or_absent(path)
        return path

    def info(self, relative, path=None):
        path = self.target(relative) if path is None else path
        if relative == STARTUP_KEY:
            return startup_info(path)
        return file_info(path) if regular_or_absent(path) else None

    def copy(self, relative, source, target):
        if relative == STARTUP_KEY:
            return copy_startup(source, target)
        return atomic_copy(source, target)

    def validate_metadata(self, create=False):
        if self.metadata.is_symlink() or (self.metadata.exists() and not self.metadata.is_dir()):
            raise InstallError("Unsafe metadata path: " + str(self.metadata))
        owner = self.metadata / "owner.json"
        if self.metadata.exists():
            if not owner.is_file() or read_json(owner) not in [
                    {"tool": "planetvim", "schema": version} for version in READABLE_SCHEMAS]:
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
        if not isinstance(result, dict) or result.get("schema") not in READABLE_SCHEMAS or not isinstance(result.get("files"), dict):
            raise InstallError("Unsupported or invalid installation manifest.")
        for relative, info in result["files"].items():
            checked_relative(relative)
            if relative == STARTUP_KEY:
                raise InstallError("Startup journal key cannot be a payload file.")
            if not isinstance(info, dict) or not isinstance(info.get("sha256"), str):
                raise InstallError("Invalid file entry in installation manifest.")
        self.validate_startup(result.get("startup"))
        return result

    def validate_startup(self, record):
        if record is None:
            return
        if (not isinstance(record, dict) or not isinstance(record.get("path"), str)
                or Path(record["path"]) not in {self.home / ".vimrc", self.home / "_vimrc"}):
            raise InstallError("This installation manages another home startup file; use the original HOME.")
        self.startup_path = Path(record["path"])
        self.transaction_directory(record.get("backup"))
        if not isinstance(record.get("installed"), dict) or "sha256" not in record["installed"]:
            raise InstallError("Invalid startup loader entry in installation manifest.")
        if "original" not in record or not isinstance(record.get("fallback"), str):
            raise InstallError("Invalid original startup entry in installation manifest.")

    def prior_startup(self):
        if self.platform == "win32":
            candidates = [self.home / ".vimrc", self.home / "vimfiles/vimrc"]
        else:
            candidates = [self.home / "_vimrc", self.home / ".vim/vimrc",
                          Path(os.environ.get("XDG_CONFIG_HOME") or self.home / ".config") / "vim/vimrc"]
        return next((str(path) for path in candidates if path != self.startup_path and path.is_file()), "")

    def startup_loader(self, fallback):
        entry = self.prefix / "scripts/planetvim.vim"
        lines = [STARTUP_MARKER.decode().rstrip(), "scriptencoding utf-8",
                 '" Managed by install.py; customize PlanetVim in its private config.',
                 "if has('gui_running') && filereadable(" + vim_string(entry) + ")",
                 "  let $PLANETVIM_ROOT = " + vim_string(self.prefix),
                 "  execute 'source ' . fnameescape(" + vim_string(entry) + ")",
                 "  finish", "endif"]
        if fallback:
            lines += ["if filereadable(" + vim_string(fallback) + ")",
                      "  execute 'source ' . fnameescape(" + vim_string(fallback) + ")",
                      "else", "  runtime defaults.vim", "endif"]
        else:
            lines += ["runtime defaults.vim"]
        return ("\n".join(lines) + "\n").encode("utf-8")

    def is_legacy_planetvim(self, target):
        if not target.is_file():
            return False
        content = target.read_bytes()
        for entry in (self.source / ".vimrc", self.source / "scripts/planetvim.vim"):
            if entry.is_file() and content == entry.read_bytes():
                return True
        # Recognize the historical first-party vimrc even after local edits.
        # A mention of PlanetVim alone is not enough to discard a personal rc.
        return all(marker in content for marker in (
            b'let g:loaded_home_vimrc = 1', b'PlanetVim_AugroupWinBar', b'planet#planet#'))

    def startup_plan(self, before, staging, command, transaction):
        previous = before.get("startup") if before else None
        if previous is None and (not self.default_gvim or command == "uninstall"):
            return None, [], []
        if command != "uninstall" and os.environ.get("VIMINIT"):
            raise InstallError("VIMINIT overrides the home vimrc. Unset it before enabling default GVim.")
        target = self.target(STARTUP_KEY)
        actual = self.info(STARTUP_KEY)
        if previous:
            record = dict(previous)
            original = record["original"]
            original_path = self.backup_file(self.transaction_directory(record["backup"]), "before", STARTUP_KEY)
            if original and self.info(STARTUP_KEY, original_path) != original:
                raise InstallError("Original startup backup has changed: " + str(original_path))
            if actual is not None and actual != record["installed"]:
                if command == "uninstall":
                    if original:
                        self.report("Original startup backup retained at " + str(original_path))
                    else:
                        self.report("No earlier personal startup file was recorded; the edited loader is retained.")
                    return None, [], [STARTUP_KEY]
                raise InstallError("Locally modified startup loader preserved: " + str(target)
                                   + "; reconcile it with the backup before updating.")
        else:
            if actual and not target.is_symlink() and target.read_bytes().startswith(STARTUP_MARKER):
                raise InstallError("Another PlanetVim loader already owns " + str(target)
                                   + "; uninstall its installation first.")
            legacy = self.is_legacy_planetvim(target)
            fallback = self.prior_startup()
            if actual and not legacy:
                fallback = str(target.resolve()) if target.is_symlink() else str(
                    self.transaction_directory(transaction) / "before" / STARTUP_KEY)
            if legacy:
                self.report("Existing PlanetVim startup detected; updating it. Its snapshot is retained for rollback;")
                self.report("no earlier personal configuration is known, so uninstall will remove this loader.")
            record = {"path": str(target), "backup": transaction, "original": None if legacy else actual,
                      "fallback": fallback}
        output = staging / STARTUP_KEY
        if command == "uninstall":
            wanted = record["original"]
            if wanted:
                self.copy(STARTUP_KEY, original_path, output)
            record = None
        else:
            output.write_bytes(self.startup_loader(record["fallback"]))
            output.chmod(0o600)
            wanted = file_info(output)
            record["installed"] = wanted
        changes = [] if actual == wanted else [{"path": STARTUP_KEY, "before": actual, "after": wanted}]
        return record, changes, []

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
        if relative == STARTUP_KEY:
            startup_info(path)
        else:
            regular_or_absent(path)
        return path

    def describe(self, changes, preserved):
        self.report("Preview only; no destination files will be written." if self.dry_run else "Installation directory: " + str(self.prefix))
        counts = {"CREATE": 0, "REPLACE": 0, "REMOVE": 0}
        for change in changes:
            action = "REMOVE" if change["after"] is None else "REPLACE" if change["before"] else "CREATE"
            counts[action] += 1
            if self.dry_run:
                self.report(action + " " + str(self.target(change["path"])))
        if changes:
            self.report("Planned files: " + ", ".join(str(counts[key]) + " " + key.lower() for key in counts))
        for relative in preserved:
            self.report("KEEP locally modified " + str(self.target(relative)))
        self.report("Backups/rollback metadata: " + str(self.metadata / "backups") if changes else "No payload changes.")

    def rollback(self, receipt, directory):
        # Do not mistake files created/edited by another process for our writes.
        # Check the whole rollback before changing anything; leave the journal in
        # place if an unexpected edit needs manual reconciliation with backups.
        applicable = []
        for change in reversed(receipt["changes"]):
            relative = change["path"]
            target = self.target(relative)
            actual = self.info(relative)
            if actual == change["before"]:
                continue
            if actual != change["after"]:
                raise InstallError("Concurrent edit preserved; reconcile before recovery: " + str(target))
            if change["before"]:
                source = self.backup_file(directory, "before", relative)
                if self.info(relative, source) != change["before"]:
                    raise InstallError("Rollback backup has changed: " + str(source))
            applicable.append(change)
        for change in applicable:
            target = self.target(change["path"])
            if change["before"]:
                source = self.backup_file(directory, "before", change["path"])
                self.copy(change["path"], source, target)
            elif target.exists() or target.is_symlink():
                target.unlink()
                sync_directory(target.parent)
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
        for manifest in (receipt["before_manifest"], receipt["after_manifest"]):
            if manifest:
                self.validate_startup(manifest.get("startup"))
        current = self.manifest()
        if current and current.get("transaction") == pending["transaction"]:
            receipt["status"] = "committed"
            atomic_json(directory / "transaction.json", receipt)
            self.pending_path.unlink()
        else:
            self.rollback(receipt, directory)
            self.report("Recovered interrupted transaction from " + str(directory))

    def transact(self, command, before, after, changes, staging, startup=None, transaction=None):
        transaction = transaction or uuid.uuid4().hex
        directory = self.transaction_directory(transaction)
        directory.mkdir(parents=True)
        updated = {"schema": SCHEMA, "transaction": transaction, "files": after}
        if startup:
            updated["startup"] = startup
        receipt = {"schema": SCHEMA, "command": command, "status": "preparing",
                   "before_manifest": before, "after_manifest": updated, "changes": changes}
        for change in changes:
            relative = change["path"]
            if change["before"]:
                backup = self.backup_file(directory, "before", relative)
                self.copy(relative, self.target(relative), backup)
                if self.info(relative, backup) != change["before"]:
                    raise InstallError("File changed while preparing backup: " + relative)
            if change["after"]:
                backup = self.backup_file(directory, "after", relative)
                self.copy(relative, staging / relative, backup)
                if self.info(relative, backup) != change["after"]:
                    raise InstallError("Staged payload changed: " + relative)
        receipt["status"] = "prepared"
        atomic_json(directory / "transaction.json", receipt)
        atomic_json(self.pending_path, {"transaction": transaction})
        try:
            for change in changes:
                target = self.target(change["path"])
                actual = self.info(change["path"])
                if actual != change["before"]:
                    raise InstallError("File changed during installation: " + str(target))
                if change["after"]:
                    self.copy(change["path"], self.backup_file(directory, "after", change["path"]), target)
                elif target.exists() or target.is_symlink():
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
        self.validate_startup(previous.get("startup") if previous else None)
        after = previous["files"] if previous else {}
        changes = []
        for change in receipt["changes"]:
            relative = change["path"]
            target = self.target(relative)
            actual = self.info(relative)
            if relative == STARTUP_KEY and actual not in (change["after"], change["before"]):
                raise InstallError("Locally modified startup file preserved during restore: " + str(target))
            if change["after"] is None and actual is not None:
                raise InstallError("An unmanaged file occupies the restore destination: " + str(target))
            wanted = change["before"]
            if wanted:
                source = self.backup_file(directory, "before", relative)
                if self.info(relative, source) != wanted:
                    raise InstallError("Restore backup has changed: " + str(source))
                output = staging / relative
                output.parent.mkdir(parents=True, exist_ok=True)
                self.copy(relative, source, output)
            if actual != wanted:
                changes.append({"path": relative, "before": actual, "after": wanted})
        return after, changes, previous.get("startup") if previous else None

    def run(self, command, backup=None):
        if self.default_gvim and command not in ("install", "update"):
            raise InstallError("--default-gvim applies only to install or update; later operations remember the mode.")
        if self.default_gvim:
            # Validate before creating metadata (Windows rejects these names at
            # mkdir, while a Unix newline could otherwise enter generated code).
            vim_string(self.prefix)
            vim_string(self.home)
        self.validate_metadata()
        if self.dry_run:
            return self.run_locked(command, backup)
        with self.locked():
            return self.run_locked(command, backup)

    def run_locked(self, command, backup):
        self.recover()
        before = self.manifest()
        if self.private and command in ("install", "update") and before and before.get("startup"):
            raise InstallError("This installation already manages home startup. Uninstall it to restore"
                               " the previous configuration before installing with --private.")
        if command in ("update", "uninstall") and not before:
            raise InstallError("No PlanetVim installation found at " + str(self.prefix))
        with tempfile.TemporaryDirectory(prefix="planetvim-stage-") as temporary:
            staging = Path(temporary)
            transaction = uuid.uuid4().hex
            preserved = []
            if command in ("install", "update"):
                after = self.payload(staging)
                changes, preserved = self.plan(before, after, command)
            elif command == "uninstall":
                after = {}
                changes, preserved = self.plan(before, after, command)
            elif command == "restore":
                after, changes, startup = self.restore_plan(before, staging, backup)
            else:
                raise InstallError("Unknown operation: " + command)
            if command != "restore":
                startup, startup_changes, startup_preserved = self.startup_plan(before, staging, command, transaction)
                # Install the loader last, after its source is available. Remove
                # it first on uninstall, before removing the source it loads.
                changes = startup_changes + changes if command == "uninstall" else changes + startup_changes
                preserved += startup_preserved
            if startup:
                self.report("Default GVim startup: " + str(self.startup_path))
            self.describe(changes, preserved)
            if self.dry_run:
                return before
            if changes or (before and (before["files"] != after or before.get("startup") != startup)):
                return self.transact(command, before, after, changes, staging, startup, transaction)
            return before


def main(argv=None):
    # Redirected Windows consoles may use cp1252 even for a valid Unicode
    # destination. Retain the chosen encoding, but never abort a transaction or
    # mask its original error just because its path cannot be printed there.
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(errors="backslashreplace")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("install", "update", "uninstall", "restore"))
    parser.add_argument("--prefix", type=Path, help="private installation directory")
    parser.add_argument("--dry-run", action="store_true", help="report changes without writing destination files")
    parser.add_argument("--backup", help="restore this backup (must be the most recent transaction)")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--default-gvim", action="store_true", default=None,
                      help="enable home startup explicitly (the default for install)")
    mode.add_argument("--private", dest="default_gvim", action="store_false",
                      help="install only the private launcher; keep home startup unchanged")
    arguments = parser.parse_args(argv)
    if arguments.backup and arguments.operation != "restore":
        parser.error("--backup is only valid with restore")
    try:
        prefix = arguments.prefix if arguments.prefix is not None else (os.environ.get("PLANETVIM_PREFIX") or default_prefix())
        default_gvim = arguments.default_gvim if arguments.default_gvim is not None else arguments.operation == "install"
        installer = Installer(Path(__file__).resolve().parents[1], prefix, arguments.dry_run,
                              default_gvim=default_gvim, private=arguments.default_gvim is False)
        result = installer.run(arguments.operation, arguments.backup)
        if arguments.operation in ("install", "update") and not arguments.dry_run:
            executable = "planetvim.cmd" if sys.platform == "win32" else "planetvim"
            print("Launch: " + str(installer.prefix / "bin" / executable))
            if isinstance(result, dict) and result.get("startup"):
                print("Plain GVim now loads PlanetVim. Original startup configuration is backed up.")
            else:
                print("Existing home Vim startup files were not changed.")
            print("Restart PlanetVim after updating. Your existing Vim plugin directory was not changed.")
        return 0
    except (InstallError, OSError) as error:
        print("PlanetVim installer: " + str(error), file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("PlanetVim installer: interrupted; backups retained for recovery.", file=sys.stderr)
        return 130


if __name__ == "__main__":
    sys.exit(main())
