"""Release tests build and install disposable Git sources, never the checkout."""
import hashlib
import importlib.util
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest import mock
import zipfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('planetvim_release', ROOT / 'scripts/release.py')
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='planetvim-release-test-')
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.source = self.root / 'source with spaces'
        self.source.mkdir()
        self.git('init', '-q')
        self.git('config', 'user.name', 'PlanetVim Test')
        self.git('config', 'user.email', 'test@example.invalid')
        self.git('config', 'core.autocrlf', 'false')
        self.git('config', 'commit.gpgsign', 'false')
        for name, content in {
            'VERSION': '0.1.0-rc.1\n', 'LICENSE': 'Original license notice\n',
            'README.md': '# Distribution\n', 'CHANGELOG.md': 'Changes\n',
            '.vimrc': 'let g:example = 1\n', 'scripts/planetvim.vim': '" bootstrap\n',
            '.vim/plugin/example.vim': 'let g:loaded_example = 1\n',
            '.vim/pack/vendor/start/plugin/LICENSE': 'Vendored license notice\n',
            '.vim/pack/vendor/start/plugin/data.bin': b'\x00\xff\x01\r\n',
            'docs/guide.md': '# Guide\n', '.gitignore': '/dist/\n',
        }.items():
            path = self.source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content.encode() if isinstance(content, str) else content)
        shutil.copy2(ROOT / 'scripts/install.py', self.source / 'scripts/install.py')
        self.git('add', '.')
        self.commit('initial')

    def git(self, *arguments):
        result = subprocess.run(['git', '-c', 'core.fsmonitor=false', '-C', str(self.source), *arguments],
                                capture_output=True, check=True)
        return result.stdout

    def commit(self, message):
        self.git('commit', '-qm', message)

    def build(self, name='artifacts'):
        directory = self.root / name
        manifest = release.build(self.source, directory)
        return directory, manifest

    def test_deterministic_archives_and_checksums(self):
        first, metadata = self.build('first')
        second, repeated = self.build('second')
        self.assertEqual(metadata, repeated)
        self.assertEqual(metadata['excluded_submodules'], [])
        self.assertEqual(metadata['source_commit'], self.git('rev-parse', 'HEAD').decode().strip())
        for artifact in metadata['artifacts']:
            content = (first / artifact['filename']).read_bytes()
            self.assertEqual(content, (second / artifact['filename']).read_bytes())
            self.assertEqual(artifact['sha256'], hashlib.sha256(content).hexdigest())
        with zipfile.ZipFile(first / metadata['artifacts'][1]['filename']) as archive:
            names = archive.namelist()
            prefix = metadata['archive_root'] + '/'
            self.assertTrue(all(name.startswith(prefix) for name in names))
            self.assertEqual(archive.read(prefix + '.vim/pack/vendor/start/plugin/LICENSE'), b'Vendored license notice\n')
            self.assertEqual(archive.read(prefix + '.vim/pack/vendor/start/plugin/data.bin'), b'\x00\xff\x01\r\n')
            self.assertFalse(any('/.git/' in name for name in names))

    def test_modified_and_untracked_files_are_rejected(self):
        (self.source / '.vimrc').write_text('dirty')
        with self.assertRaisesRegex(release.ReleaseError, 'dirty'):
            self.build()
        self.git('restore', '.vimrc')
        (self.source / 'untracked').write_text('untracked')
        with self.assertRaisesRegex(release.ReleaseError, 'dirty'):
            self.build()

    def test_bytecode_build_and_runtime_state_are_excluded(self):
        for name in ['__pycache__/cache.pyc', 'build/object.o', '.vim/undo/session', '.vim/plugin/cache.pyo']:
            path = self.source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b'state')
        self.git('add', '-f', '.')
        self.commit('tracked state fixture')
        output, metadata = self.build()
        with zipfile.ZipFile(output / metadata['artifacts'][1]['filename']) as archive:
            self.assertFalse(any(name.endswith(('cache.pyc', 'object.o', '/session', 'cache.pyo')) for name in archive.namelist()))

    def test_existing_artifact_is_not_overwritten(self):
        output, metadata = self.build()
        archive = output / metadata['artifacts'][0]['filename']
        content = archive.read_bytes()
        with self.assertRaisesRegex(release.ReleaseError, 'overwrite'):
            release.build(self.source, output)
        self.assertEqual(content, archive.read_bytes())

    def test_invalid_committed_version_is_rejected(self):
        (self.source / 'VERSION').write_text('../unsafe\n')
        self.git('add', 'VERSION')
        self.commit('invalid version')
        with self.assertRaisesRegex(release.ReleaseError, 'semantic version'):
            self.build()

    def test_export_attributes_cannot_drop_or_rewrite_vendored_notices(self):
        (self.source / '.gitattributes').write_text('**/LICENSE export-ignore\n.gitattributes export-ignore\nNOTICE export-subst\n')
        (self.source / 'NOTICE').write_text('Literal upstream notice: $Format:%H$\n')
        self.git('add', '.gitattributes', 'NOTICE')
        self.commit('upstream export attributes')
        output, metadata = self.build()
        with zipfile.ZipFile(output / metadata['artifacts'][1]['filename']) as archive:
            prefix = metadata['archive_root'] + '/'
            self.assertEqual(archive.read(prefix + '.vim/pack/vendor/start/plugin/LICENSE'), b'Vendored license notice\n')
            self.assertEqual(archive.read(prefix + 'NOTICE'), b'Literal upstream notice: $Format:%H$\n')
            self.assertEqual(archive.read(prefix + '.gitattributes'), (self.source / '.gitattributes').read_bytes())

    def add_gitlink(self, path, commit):
        (self.source / path).mkdir(parents=True, exist_ok=True)
        self.git('update-index', '--add', '--cacheinfo', '160000', commit, path)
        self.commit('gitlink fixture')

    def test_known_optional_gitlinks_are_recorded_without_dropping_runtime_help(self):
        for path, exclusion in release.OPTIONAL_SUBMODULES.items():
            self.add_gitlink(path, exclusion['commit'])
        for name in ['.vim/pack/web/start/emmet-vim/doc/emmet.txt',
                     '.vim/pack/web/start/emmet-vim/LICENSE']:
            target = self.source / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text('Retained runtime help or license\n')
        self.git('add', '.')
        self.commit('retained runtime documentation')
        output, metadata = self.build()
        expected = [dict(path=path, **details) for path, details in sorted(release.OPTIONAL_SUBMODULES.items())]
        self.assertEqual(metadata['excluded_submodules'], expected)
        with zipfile.ZipFile(output / metadata['artifacts'][1]['filename']) as archive:
            prefix = metadata['archive_root'] + '/'
            names = archive.namelist()
            for excluded in expected:
                self.assertFalse(any(name == prefix + excluded['path'] or
                                     name.startswith(prefix + excluded['path'] + '/') for name in names))
            self.assertIn(prefix + '.vim/pack/web/start/emmet-vim/doc/emmet.txt', names)
            self.assertIn(prefix + '.vim/pack/web/start/emmet-vim/LICENSE', names)

    def test_unknown_submodules_are_rejected_even_in_generated_directories(self):
        commit = next(iter(release.OPTIONAL_SUBMODULES.values()))['commit']
        for path in ['.vim/pack/vendor/start/runtime', 'build/unknown-submodule']:
            with self.subTest(path=path):
                self.add_gitlink(path, commit)
                with self.assertRaisesRegex(release.ReleaseError, 'Submodule contents are not vendored'):
                    self.build()
                self.assertFalse((self.root / 'artifacts').exists())
                self.git('update-index', '--force-remove', path)
                self.commit('remove gitlink fixture')

    def test_known_optional_submodule_with_changed_pin_is_rejected(self):
        path = next(iter(release.OPTIONAL_SUBMODULES))
        self.add_gitlink(path, '1' * 40)
        with self.assertRaisesRegex(release.ReleaseError, 'Optional submodule pin changed'):
            self.build()
        self.assertFalse((self.root / 'artifacts').exists())

    def test_committed_symlink_is_rejected_without_following_checkout_files(self):
        # Construct the Git tree directly so this test also runs on Windows
        # hosts where creating filesystem symlinks requires extra privileges.
        object_id = self.git('hash-object', '-w', 'README.md').decode().strip()
        self.git('update-index', '--add', '--cacheinfo', '120000', object_id, 'unsafe-link')
        self.commit('symlink fixture')
        commit = self.git('rev-parse', 'HEAD').decode().strip()
        with self.assertRaisesRegex(release.ReleaseError, 'symlinks are unsupported'):
            release.snapshot(self.source, commit)

    def test_executable_modes_come_from_committed_tree(self):
        self.git('config', 'core.filemode', 'false')
        self.git('update-index', '--chmod=+x', 'scripts/install.py')
        self.commit('executable installer fixture')
        output, metadata = self.build()
        name = metadata['archive_root'] + '/scripts/install.py'
        with zipfile.ZipFile(output / metadata['artifacts'][1]['filename']) as archive:
            self.assertEqual((archive.getinfo(name).external_attr >> 16) & 0o777, 0o755)
        with tarfile.open(output / metadata['artifacts'][0]['filename']) as archive:
            self.assertEqual(archive.getmember(name).mode, 0o755)

    def test_failed_output_copy_removes_partial_artifacts(self):
        original = release.shutil.copyfileobj
        count = 0
        def fail_second(source, destination, *arguments):
            nonlocal count
            count += 1
            if count == 2:
                raise OSError('injected output failure')
            return original(source, destination, *arguments)
        with mock.patch.object(release.shutil, 'copyfileobj', fail_second):
            with self.assertRaisesRegex(OSError, 'injected'):
                self.build()
        self.assertEqual(list((self.root / 'artifacts').iterdir()), [])

    def test_default_output_does_not_dirty_source(self):
        metadata = release.build(self.source)
        self.assertTrue((self.source / 'dist' / metadata['artifacts'][0]['filename']).is_file())
        self.assertEqual(self.git('status', '--porcelain'), b'')

    def test_archive_install_update_restore_and_uninstall(self):
        output, metadata = self.build('version-one')
        extraction = self.root / 'extracted'
        with tarfile.open(output / metadata['artifacts'][0]['filename']) as archive:
            archive.extractall(extraction, filter='data')
        source_one = extraction / metadata['archive_root']
        prefix = self.root / 'installation'
        def invoke(source, command):
            result = subprocess.run([sys.executable, str(source / 'scripts/install.py'), command,
                                     '--prefix', str(prefix)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        invoke(source_one, 'install')
        self.assertEqual((prefix / 'LICENSE').read_text(), 'Original license notice\n')
        self.assertTrue((prefix / 'docs/guide.md').is_file())
        (self.source / '.vimrc').write_text('let g:example = 2\n')
        (self.source / 'VERSION').write_text('0.1.0-rc.2\n')
        self.git('add', '.vimrc', 'VERSION')
        self.commit('second version')
        output_two, metadata_two = self.build('version-two')
        with tarfile.open(output_two / metadata_two['artifacts'][0]['filename']) as archive:
            archive.extractall(extraction, filter='data')
        source_two = extraction / metadata_two['archive_root']
        invoke(source_two, 'update')
        self.assertEqual((prefix / 'VERSION').read_text(), '0.1.0-rc.2\n')
        self.assertEqual((prefix / '.vimrc').read_text(), 'let g:example = 2\n')
        invoke(source_two, 'restore')
        self.assertEqual((prefix / 'VERSION').read_text(), '0.1.0-rc.1\n')
        self.assertEqual((prefix / '.vimrc').read_text(), 'let g:example = 1\n')
        (prefix / 'personal.txt').write_text('preserve me')
        invoke(source_two, 'uninstall')
        self.assertFalse((prefix / '.vimrc').exists())
        self.assertFalse((prefix / 'LICENSE').exists())
        self.assertEqual((prefix / 'personal.txt').read_text(), 'preserve me')


if __name__ == '__main__':
    unittest.main()
