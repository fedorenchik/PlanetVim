"""Default-GVim installation preservation and recovery in disposable homes."""
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

SPEC = importlib.util.spec_from_file_location("planetvim_home_install", Path(__file__).resolve().parents[1] / "scripts/install.py")
install = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(install)


class HomeInstallerTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="planetvim-home-test-")
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.source = self.directory / "source"
        self.prefix = self.directory / "installed, 'quoted' 工作"
        self.home = self.directory / "home, 'quoted' 工作"
        self.home.mkdir()
        self.rc = self.home / ".vimrc"
        self.source.mkdir()
        (self.source / ".vim/plugin").mkdir(parents=True)
        (self.source / "scripts").mkdir()
        (self.source / ".vimrc").write_text('let g:distribution = 1\n')
        (self.source / "scripts/planetvim.vim").write_text('" bootstrap\n')
        (self.source / ".vim/plugin/example.vim").write_text('" plugin\n')
        self.messages = []
        environment = mock.patch.dict(os.environ, {"VIMINIT": ""})
        environment.start()
        self.addCleanup(environment.stop)

    def installer(self, enabled=False, dry_run=False, platform="linux", prefix=None, home=None):
        return install.Installer(self.source, prefix or self.prefix, dry_run, platform,
                                 self.messages.append, default_gvim=enabled, home=home or self.home)

    def test_preview_is_read_only_and_shows_home_destination(self):
        self.rc.write_bytes(b'" personal\r\n')
        self.installer(enabled=True, dry_run=True).run("install")
        self.assertFalse(self.prefix.exists())
        self.assertEqual(self.rc.read_bytes(), b'" personal\r\n')
        self.assertIn("REPLACE " + str(self.rc), self.messages)

    def test_install_repeat_update_and_uninstall_restore_original_bytes_and_mode(self):
        original = b'" personal \xc3\xa9\r\nlet g:personal = 1\r\n'
        self.rc.write_bytes(original)
        self.rc.chmod(0o640)
        original_info = install.file_info(self.rc)
        (self.home / ".vim").mkdir()
        (self.home / ".vim/personal.vim").write_text("personal plugin")
        first = self.installer(enabled=True).run("install")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        backup = self.prefix / ".planetvim/backups" / first["startup"]["backup"] / "before" / install.STARTUP_KEY
        self.assertEqual(backup.read_bytes(), original)
        self.assertEqual(first, self.installer().run("install"))
        self.assertEqual(first, self.installer(enabled=True).run("install"))
        (self.source / ".vimrc").write_text('let g:distribution = 2\n')
        updated = self.installer().run("update")
        self.assertEqual(updated["startup"]["backup"], first["startup"]["backup"])
        self.installer().run("uninstall")
        self.assertEqual(self.rc.read_bytes(), original)
        self.assertEqual(install.file_info(self.rc), original_info)
        self.assertEqual((self.home / ".vim/personal.vim").read_text(), "personal plugin")
        self.assertEqual(backup.read_bytes(), original)

    def test_no_original_startup_is_removed_and_restorable(self):
        self.installer(enabled=True).run("install")
        self.installer().run("uninstall")
        self.assertFalse(self.rc.exists())
        self.installer().run("restore")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        self.installer().run("uninstall")
        self.assertFalse(self.rc.exists())

    def test_enabling_existing_private_install_can_be_undone(self):
        private = self.installer().run("install")
        self.rc.write_text('" personal\n')
        self.installer(enabled=True).run("update")
        reverted = self.installer().run("restore")
        self.assertEqual(reverted["files"], private["files"])
        self.assertNotIn("startup", reverted)
        self.assertEqual(self.rc.read_text(), '" personal\n')
        self.installer().run("uninstall")
        self.assertEqual(self.rc.read_text(), '" personal\n')

    def test_legacy_planetvim_is_updated_without_becoming_the_original_config(self):
        legacy = ('let g:loaded_home_vimrc = 1\n'
                  'augroup PlanetVim_AugroupWinBar\n'
                  'call planet#planet#SetPerSessionOptions()\n" custom legacy setting\n')
        self.rc.write_text(legacy)
        self.installer(enabled=True).run("install")
        self.installer(enabled=True).run("install")
        self.installer().run("uninstall")
        self.assertFalse(self.rc.exists(), "uninstall must not reactivate an older PlanetVim")
        self.installer().run("restore")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        self.installer().run("uninstall")
        self.assertFalse(self.rc.exists())
        self.assertTrue(any("Existing PlanetVim startup detected" in m for m in self.messages))

    def test_planetvim_mention_in_personal_config_is_still_backed_up(self):
        original = '" I may try PlanetVim someday\nlet g:personal = 1\n'
        self.rc.write_text(original)
        self.installer(enabled=True).run("install")
        self.installer().run("uninstall")
        self.assertEqual(self.rc.read_text(), original)

    def test_cli_defaults_to_home_install_and_private_is_explicit(self):
        for args, enabled, private in [([], True, False), (["--private"], False, True),
                                       (["--default-gvim"], True, False)]:
            with self.subTest(args=args), mock.patch.object(install, "Installer") as constructor, \
                    mock.patch("builtins.print"):
                constructor.return_value.prefix = self.prefix
                constructor.return_value.run.return_value = None
                self.assertEqual(0, install.main(["install", "--prefix", str(self.prefix)] + args))
                self.assertEqual(constructor.call_args.kwargs["default_gvim"], enabled)
                self.assertEqual(constructor.call_args.kwargs["private"], private)

    def test_private_request_cannot_silently_leave_home_mode_active(self):
        self.installer(enabled=True).run("install")
        private = install.Installer(self.source, self.prefix, platform="linux", home=self.home, private=True)
        with self.assertRaisesRegex(install.InstallError, "already manages home startup"):
            private.run("install")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        self.installer().run("uninstall")
        self.assertFalse(self.rc.exists())

    def test_restore_initial_install_and_restore_uninstall(self):
        self.rc.write_text('" original\n')
        self.installer(enabled=True).run("install")
        self.installer().run("restore")
        self.assertEqual(self.rc.read_text(), '" original\n')
        self.assertFalse((self.prefix / ".vimrc").exists())
        self.installer(enabled=True).run("install")
        self.installer().run("uninstall")
        self.installer().run("restore")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        self.installer().run("uninstall")
        self.assertEqual(self.rc.read_text(), '" original\n')

    def test_modified_loader_blocks_update_and_survives_uninstall(self):
        self.rc.write_text('" original\n')
        installed = self.installer(enabled=True).run("install")
        self.rc.write_text('" user replaced the loader\n')
        (self.source / ".vimrc").write_text('" newer payload\n')
        with self.assertRaisesRegex(install.InstallError, "Locally modified startup loader"):
            self.installer().run("update")
        self.assertEqual(self.installer().manifest(), installed)
        self.installer().run("uninstall")
        self.assertEqual(self.rc.read_text(), '" user replaced the loader\n')
        self.assertIn("KEEP locally modified " + str(self.rc), self.messages)

    def test_restore_preserves_edits_made_after_uninstall(self):
        self.rc.write_text('" original\n')
        self.installer(enabled=True).run("install")
        self.installer().run("uninstall")
        self.rc.write_text('" edited after uninstall\n')
        with self.assertRaisesRegex(install.InstallError, "Locally modified startup file"):
            self.installer().run("restore")
        self.assertEqual(self.rc.read_text(), '" edited after uninstall\n')
        self.assertFalse((self.prefix / ".vimrc").exists())

    def test_missing_loader_is_repaired_without_losing_original(self):
        self.rc.write_text('" original\n')
        self.installer(enabled=True).run("install")
        self.rc.unlink()
        self.installer().run("update")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        self.installer().run("uninstall")
        self.assertEqual(self.rc.read_text(), '" original\n')

    def test_another_prefix_cannot_replace_owned_loader(self):
        first = self.installer(enabled=True).run("install")
        with self.assertRaisesRegex(install.InstallError, "Another PlanetVim loader"):
            self.installer(enabled=True, prefix=self.directory / "other-prefix").run("install")
        self.assertEqual(install.file_info(self.rc), first["startup"]["installed"])
        self.assertFalse((self.directory / "other-prefix/.vimrc").exists())

    def test_changed_original_backup_blocks_uninstall(self):
        self.rc.write_text('" original\n')
        first = self.installer(enabled=True).run("install")
        backup = self.prefix / ".planetvim/backups" / first["startup"]["backup"] / "before" / install.STARTUP_KEY
        backup.write_text('" tampered\n')
        with self.assertRaisesRegex(install.InstallError, "Original startup backup has changed"):
            self.installer().run("uninstall")
        self.assertEqual(install.file_info(self.rc), first["startup"]["installed"])
        self.assertTrue((self.prefix / ".vimrc").exists())

    def test_failed_loader_write_rolls_back_installation_and_home(self):
        self.rc.write_text('" original\n')
        original_copy = install.atomic_copy

        def fail_loader(source, target):
            if target == self.rc:
                raise OSError("home write failed")
            return original_copy(source, target)

        with mock.patch.object(install, "atomic_copy", side_effect=fail_loader):
            with self.assertRaisesRegex(OSError, "home write failed"):
                self.installer(enabled=True).run("install")
        self.assertEqual(self.rc.read_text(), '" original\n')
        self.assertFalse((self.prefix / ".vimrc").exists())
        self.assertIsNone(self.installer().manifest())

    def test_failed_uninstall_restores_loader_and_owned_payload(self):
        self.rc.write_text('" original\n')
        before = self.installer(enabled=True).run("install")
        original_json = install.atomic_json
        failed = False

        def fail_commit(path, value):
            nonlocal failed
            if path == self.prefix / ".planetvim/manifest.json" and not failed:
                failed = True
                raise OSError("manifest write failed")
            return original_json(path, value)

        with mock.patch.object(install, "atomic_json", side_effect=fail_commit):
            with self.assertRaisesRegex(OSError, "manifest write failed"):
                self.installer().run("uninstall")
        self.assertEqual(self.installer().manifest(), before)
        self.assertEqual(install.file_info(self.rc), before["startup"]["installed"])
        self.assertTrue((self.prefix / "scripts/planetvim.vim").exists())
        self.installer().run("uninstall")
        self.assertEqual(self.rc.read_text(), '" original\n')

    def test_interrupted_home_write_recovers_before_next_operation(self):
        self.rc.write_text('" original\n')
        original_copy = install.atomic_copy

        def interrupt_after_write(source, target):
            original_copy(source, target)
            if target == self.rc:
                raise KeyboardInterrupt()

        with mock.patch.object(install, "atomic_copy", side_effect=interrupt_after_write), \
                mock.patch.object(install.Installer, "rollback"):
            with self.assertRaises(KeyboardInterrupt):
                self.installer(enabled=True).run("install")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        with self.installer().locked():
            self.installer().recover()
        self.assertEqual(self.rc.read_text(), '" original\n')
        self.assertFalse((self.prefix / ".vimrc").exists())

    def test_concurrent_home_edit_is_preserved_during_recovery(self):
        self.rc.write_text('" original\n')
        original_json = install.atomic_json

        def edit_home_after_prepare(path, value):
            original_json(path, value)
            if path == self.prefix / ".planetvim/pending.json":
                self.rc.write_text('" concurrent edit\n')

        with mock.patch.object(install, "atomic_json", side_effect=edit_home_after_prepare):
            with self.assertRaisesRegex(install.InstallError, "File changed during installation"):
                self.installer(enabled=True).run("install")
        self.assertEqual(self.rc.read_text(), '" concurrent edit\n')
        self.assertTrue((self.prefix / ".planetvim/pending.json").exists())

    @unittest.skipIf(os.name == "nt", "symlink privileges vary on Windows")
    def test_symlink_is_restored_without_modifying_its_target(self):
        dotfile = self.home / "dotfiles/vimrc"
        dotfile.parent.mkdir()
        dotfile.write_text('" linked original\n')
        self.rc.symlink_to("dotfiles/vimrc")
        self.installer(enabled=True).run("install")
        self.assertFalse(self.rc.is_symlink())
        self.installer().run("uninstall")
        self.assertEqual(os.readlink(self.rc), "dotfiles/vimrc")
        self.assertEqual(dotfile.read_text(), '" linked original\n')
        self.installer().run("restore")
        self.assertFalse(self.rc.is_symlink())
        self.installer().run("uninstall")
        self.assertEqual(os.readlink(self.rc), "dotfiles/vimrc")

    @unittest.skipIf(os.name == "nt", "symlink privileges vary on Windows")
    def test_broken_original_link_is_restored_as_a_link(self):
        self.rc.symlink_to("missing-original")
        self.installer(enabled=True).run("install")
        self.installer().run("uninstall")
        self.assertTrue(self.rc.is_symlink())
        self.assertEqual(os.readlink(self.rc), "missing-original")

    def test_windows_preserves_existing_dot_vimrc_and_defaults_to_underscore(self):
        self.rc.write_text('" Windows alternate vimrc\n')
        self.installer(enabled=True, platform="win32").run("install")
        loader = self.home / "_vimrc"
        self.assertFalse(loader.exists())
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))
        self.installer(platform="win32").run("uninstall")
        self.assertFalse(loader.exists())
        self.assertEqual(self.rc.read_text(), '" Windows alternate vimrc\n')
        self.rc.unlink()
        self.installer(enabled=True, platform="win32").run("install")
        self.assertTrue(loader.read_bytes().startswith(install.STARTUP_MARKER))
        self.installer(platform="win32").run("uninstall")
        self.assertFalse(loader.exists())

    def test_startup_environment_override_is_reported_without_home_writes(self):
        with mock.patch.dict(os.environ, {"VIMINIT": "source elsewhere.vim"}):
            with self.assertRaisesRegex(install.InstallError, "VIMINIT overrides"):
                self.installer(enabled=True).run("install")
        self.assertFalse(self.rc.exists())
        self.assertFalse((self.prefix / ".vimrc").exists())

    def test_different_home_cannot_uninstall_another_users_loader(self):
        self.installer(enabled=True).run("install")
        with self.assertRaisesRegex(install.InstallError, "another home startup file"):
            self.installer(home=self.directory / "other-home").run("uninstall")
        self.assertTrue(self.rc.read_bytes().startswith(install.STARTUP_MARKER))

    def test_schema_one_private_install_can_enable_home_mode(self):
        self.installer().run("install")
        for name in ("owner.json", "manifest.json"):
            path = self.prefix / ".planetvim" / name
            data = json.loads(path.read_text())
            data["schema"] = 1
            path.write_text(json.dumps(data))
        updated = self.installer(enabled=True).run("update")
        self.assertEqual(updated["schema"], 2)
        self.assertIn("startup", updated)
        self.installer().run("uninstall")
        self.assertFalse(self.rc.exists())

    def test_non_regular_home_file_and_newline_prefix_are_rejected(self):
        self.rc.mkdir()
        with self.assertRaisesRegex(install.InstallError, "non-regular file"):
            self.installer(enabled=True).run("install")
        self.rc.rmdir()
        with self.assertRaisesRegex(install.InstallError, "cannot contain newline"):
            self.installer(enabled=True, prefix=self.directory / "bad\nprefix").run("install")
        self.assertFalse(self.rc.exists())


if __name__ == "__main__":
    unittest.main()
