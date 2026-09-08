"""Installer tests use disposable sources and destinations only."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

SPEC = importlib.util.spec_from_file_location("planetvim_install", Path(__file__).resolve().parents[1] / "scripts/install.py")
install = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(install)


class InstallerTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="planetvim-install-test-")
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.source = self.directory / "source"
        self.prefix = self.directory / "destination with spaces and 'quotes'"
        self.write(self.source / ".vimrc", 'let g:distribution = 1\n')
        self.write(self.source / ".vim/plugin/example.vim", 'let g:example = 1\n')
        self.write(self.source / "scripts/planetvim.vim", '" bootstrap fixture\n')
        self.messages = []

    def write(self, path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def installer(self, dry_run=False, platform="linux"):
        return install.Installer(self.source, self.prefix, dry_run, platform, self.messages.append)

    def test_clean_repeat_and_uninstall_preserve_unmanaged_files(self):
        self.write(self.prefix / "notes.txt", "keep me")
        self.write(self.prefix / ".vim/plugin/personal.vim", "personal plugin")
        first = self.installer().run("install")
        self.assertEqual((self.prefix / ".vimrc").read_text(), 'let g:distribution = 1\n')
        self.assertEqual(first, self.installer().run("install"))
        self.installer().run("uninstall")
        self.assertFalse((self.prefix / ".vimrc").exists())
        self.assertEqual((self.prefix / "notes.txt").read_text(), "keep me")
        self.assertEqual((self.prefix / ".vim/plugin/personal.vim").read_text(), "personal plugin")
        self.assertTrue((self.prefix / ".planetvim/backups").is_dir())

    def test_dry_run_does_not_create_destination(self):
        self.installer(dry_run=True).run("install")
        self.assertFalse(self.prefix.exists())
        self.assertTrue(any(message.startswith("CREATE ") for message in self.messages))

    def test_optional_metadata_and_documentation_exclude_bytecode(self):
        for name in ("LICENSE", "VERSION", "CHANGELOG.md", "README.md", "CONTRIBUTING.md", "docs/guide.md"):
            self.write(self.source / name, "document " + name)
        for name in (".vim/plugin/__pycache__/cache.pyc", "docs/__pycache__/cache.pyc", ".vim/plugin/cache.pyo"):
            self.write(self.source / name, "bytecode")
        self.installer().run("install")
        for name in ("LICENSE", "VERSION", "CHANGELOG.md", "README.md", "CONTRIBUTING.md", "docs/guide.md"):
            self.assertEqual((self.prefix / name).read_text(), "document " + name)
        self.assertFalse((self.prefix / ".vim/plugin/__pycache__").exists())
        self.assertFalse((self.prefix / "docs/__pycache__").exists())
        self.assertFalse((self.prefix / ".vim/plugin/cache.pyo").exists())

    def test_collision_refuses_overwrite_even_when_contents_match(self):
        self.write(self.prefix / ".vimrc", 'let g:distribution = 1\n')
        with self.assertRaisesRegex(install.InstallError, "Unmanaged file collision"):
            self.installer().run("install")
        self.assertEqual((self.prefix / ".vimrc").read_text(), 'let g:distribution = 1\n')
        self.assertFalse((self.prefix / "bin/planetvim").exists())

    def test_update_archives_modified_file_and_restore_recovers_it(self):
        self.installer().run("install")
        self.write(self.prefix / ".vimrc", '" local modification\n')
        self.write(self.source / ".vimrc", 'let g:distribution = 2\n')
        updated = self.installer().run("update")
        backup = self.prefix / ".planetvim/backups" / updated["transaction"] / "before/.vimrc"
        self.assertEqual(backup.read_text(), '" local modification\n')
        self.assertEqual((self.prefix / ".vimrc").read_text(), 'let g:distribution = 2\n')
        self.installer().run("restore")
        self.assertEqual((self.prefix / ".vimrc").read_text(), '" local modification\n')

    def test_uninstall_retains_modified_owned_files(self):
        self.installer().run("install")
        self.write(self.prefix / ".vimrc", "keep modified config")
        self.installer().run("uninstall")
        self.assertEqual((self.prefix / ".vimrc").read_text(), "keep modified config")
        self.assertTrue(any("KEEP locally modified" in message for message in self.messages))

    def test_removed_payload_is_backed_up_and_restored(self):
        self.installer().run("install")
        (self.source / ".vim/plugin/example.vim").unlink()
        self.installer().run("update")
        self.assertFalse((self.prefix / ".vim/plugin/example.vim").exists())
        self.installer().run("restore")
        self.assertEqual((self.prefix / ".vim/plugin/example.vim").read_text(), 'let g:example = 1\n')

    def test_restore_initial_install_removes_only_owned_payload(self):
        self.write(self.prefix / "notes.txt", "unmanaged")
        self.installer().run("install")
        self.installer().run("restore")
        self.assertFalse((self.prefix / ".vimrc").exists())
        self.assertEqual((self.prefix / "notes.txt").read_text(), "unmanaged")
        self.assertEqual(self.installer().manifest()["files"], {})

    def test_update_repairs_a_missing_owned_file(self):
        self.installer().run("install")
        (self.prefix / ".vimrc").unlink()
        self.installer().run("update")
        self.assertEqual((self.prefix / ".vimrc").read_text(), 'let g:distribution = 1\n')

    def test_failed_update_rolls_back_files_and_manifest(self):
        before = self.installer().run("install")
        self.write(self.source / ".vimrc", "updated rc")
        self.write(self.source / ".vim/plugin/example.vim", "updated plugin")
        original_copy = install.atomic_copy
        failed = False

        def fail_one_replacement(source, target):
            nonlocal failed
            if target == self.prefix / ".vimrc" and not failed:
                failed = True
                raise OSError("simulated disk failure")
            return original_copy(source, target)

        with mock.patch.object(install, "atomic_copy", side_effect=fail_one_replacement):
            with self.assertRaisesRegex(OSError, "simulated disk failure"):
                self.installer().run("update")
        self.assertEqual(self.installer().manifest(), before)
        self.assertEqual((self.prefix / ".vimrc").read_text(), 'let g:distribution = 1\n')
        self.assertEqual((self.prefix / ".vim/plugin/example.vim").read_text(), 'let g:example = 1\n')
        self.assertFalse((self.prefix / ".planetvim/pending.json").exists())

    def test_failed_backup_never_replaces_live_files(self):
        before = self.installer().run("install")
        self.write(self.source / ".vimrc", "updated rc")
        with mock.patch.object(install, "atomic_copy", side_effect=OSError("cannot back up")):
            with self.assertRaisesRegex(OSError, "cannot back up"):
                self.installer().run("update")
        self.assertEqual(self.installer().manifest(), before)
        self.assertEqual((self.prefix / ".vimrc").read_text(), 'let g:distribution = 1\n')

    def test_concurrent_unmanaged_file_is_never_removed_by_rollback(self):
        self.installer().run("install")
        self.write(self.source / ".vim/plugin/new.vim", "new payload")
        original_json = install.atomic_json

        def create_competing_file(target, value):
            original_json(target, value)
            if target == self.prefix / ".planetvim/pending.json":
                self.write(self.prefix / ".vim/plugin/new.vim", "concurrent user content")

        with mock.patch.object(install, "atomic_json", side_effect=create_competing_file):
            with self.assertRaisesRegex(install.InstallError, "File changed during installation"):
                self.installer().run("update")
        self.assertEqual((self.prefix / ".vim/plugin/new.vim").read_text(), "concurrent user content")
        self.assertTrue((self.prefix / ".planetvim/pending.json").exists())
        self.assertTrue(any("Concurrent edit preserved" in message for message in self.messages))

    def test_interrupted_update_is_recovered_before_next_operation(self):
        before = self.installer().run("install")
        self.write(self.source / ".vimrc", "updated rc")
        original_copy = install.atomic_copy
        failed = False

        def interrupted(source, target):
            nonlocal failed
            if target == self.prefix / ".vimrc" and not failed:
                failed = True
                original_copy(source, target)
                raise KeyboardInterrupt()
            return original_copy(source, target)

        # Suppress in-process rollback to model process termination after a replacement.
        with mock.patch.object(install, "atomic_copy", side_effect=interrupted), mock.patch.object(install.Installer, "rollback"):
            with self.assertRaises(KeyboardInterrupt):
                self.installer().run("update")
        self.assertTrue((self.prefix / ".planetvim/pending.json").exists())
        with self.assertRaisesRegex(install.InstallError, "needs recovery"):
            self.installer(dry_run=True).run("update")
        installer = self.installer()
        with installer.locked():
            installer.recover()
        self.assertEqual(installer.manifest(), before)
        self.assertEqual((self.prefix / ".vimrc").read_text(), 'let g:distribution = 1\n')
        self.assertFalse((self.prefix / ".planetvim/pending.json").exists())

    def test_restore_refuses_new_unmanaged_collision(self):
        self.installer().run("install")
        self.installer().run("uninstall")
        self.write(self.prefix / ".vimrc", "new user config")
        with self.assertRaisesRegex(install.InstallError, "unmanaged file"):
            self.installer().run("restore")
        self.assertEqual((self.prefix / ".vimrc").read_text(), "new user config")

    def test_backup_tampering_refuses_restore(self):
        self.installer().run("install")
        self.write(self.source / ".vimrc", "updated rc")
        updated = self.installer().run("update")
        self.write(self.prefix / ".planetvim/backups" / updated["transaction"] / "before/.vimrc", "tampered")
        with self.assertRaisesRegex(install.InstallError, "backup has changed"):
            self.installer().run("restore")
        self.assertEqual((self.prefix / ".vimrc").read_text(), "updated rc")

    def test_checkout_state_is_not_distributed(self):
        for relative in (".vim/planetvimrc.vim", ".vim/session/private.vim", ".vim/fern-bookmark.json"):
            self.write(self.source / relative, "private")
        self.installer().run("install")
        for relative in (".vim/planetvimrc.vim", ".vim/session/private.vim", ".vim/fern-bookmark.json"):
            self.assertFalse((self.prefix / relative).exists())

    @unittest.skipIf(os.name == "nt", "POSIX executable launcher")
    def test_launcher_sets_root_and_preserves_arguments(self):
        self.installer().run("install")
        fake_gvim = self.directory / "fake gvim"
        result_path = self.directory / "launched.json"
        self.write(fake_gvim, "#!/usr/bin/env python3\nimport json, os, sys\nfrom pathlib import Path\nPath(os.environ['PV_TEST_RESULT']).write_text(json.dumps([os.environ['PLANETVIM_ROOT'], sys.argv[1:]]))\n")
        fake_gvim.chmod(0o755)
        environment = os.environ.copy()
        environment["PLANETVIM_GVIM"] = str(fake_gvim)
        environment["PV_TEST_RESULT"] = str(result_path)
        subprocess.run([str(self.prefix / "bin/planetvim"), "two words", "it's.txt"], env=environment, check=True)
        root, arguments = json.loads(result_path.read_text())
        self.assertEqual(root, str(self.prefix))
        self.assertEqual(arguments, ["-u", str(self.prefix / "scripts/planetvim.vim"), "two words", "it's.txt"])

    @unittest.skipIf(os.name == "nt", "symlink privileges vary on Windows")
    def test_symlink_destination_is_rejected(self):
        outside = self.directory / "outside"
        outside.mkdir()
        self.prefix.mkdir()
        (self.prefix / ".vim").symlink_to(outside, target_is_directory=True)
        with self.assertRaisesRegex(install.InstallError, "Unsafe installation directory"):
            self.installer().run("install")
        self.assertFalse(list(outside.iterdir()))

    def test_unrecognized_metadata_is_not_claimed(self):
        self.write(self.prefix / ".planetvim/user.txt", "unmanaged")
        with self.assertRaisesRegex(install.InstallError, "unrecognized"):
            self.installer().run("install")
        self.assertEqual((self.prefix / ".planetvim/user.txt").read_text(), "unmanaged")

    def test_source_overlap_is_rejected(self):
        for prefix in (self.source, self.source / "installed", self.directory):
            with self.assertRaisesRegex(install.InstallError, "must not overlap"):
                install.Installer(self.source, prefix, platform="linux")

    @unittest.skipIf(os.name == "nt", "flock concurrency regression runs on Linux")
    def test_simultaneous_installer_is_rejected(self):
        with self.installer().locked():
            with self.assertRaisesRegex(install.InstallError, "Another PlanetVim installer"):
                self.installer().run("install")

    def test_missing_bootstrap_aborts_without_installing_payload(self):
        (self.source / "scripts/planetvim.vim").unlink()
        with self.assertRaisesRegex(install.InstallError, "missing scripts/planetvim.vim"):
            self.installer().run("install")
        self.assertFalse((self.prefix / ".vimrc").exists())

    def test_platform_defaults_and_windows_launcher(self):
        self.assertEqual(install.default_prefix("win32", {"LOCALAPPDATA": "C:/Users/Example/AppData/Local"}), Path("C:/Users/Example/AppData/Local/PlanetVim"))
        with self.assertRaisesRegex(install.InstallError, "macOS is unsupported"):
            install.default_prefix("darwin", {})
        self.installer(platform="win32").run("install")
        self.assertIn('set "PLANETVIM_ROOT=%~dp0.."', (self.prefix / "bin/planetvim.cmd").read_text())
        self.assertFalse((self.prefix / "bin/planetvim").exists())

    def test_main_returns_failure_status(self):
        with mock.patch.object(install.Installer, "run", side_effect=OSError("copy failed")):
            self.assertEqual(install.main(["install", "--prefix", str(self.prefix)]), 1)


if __name__ == "__main__":
    unittest.main()
