"""Offline checks for inventory drift and read-only upstream lookup behavior."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

SPEC = importlib.util.spec_from_file_location('planetvim_plugins', Path(__file__).resolve().parents[1] / 'scripts/plugins.py')
plugins = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(plugins)


class PluginInventoryTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix='planetvim-plugin-test-')
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.package = self.root / '.vim/pack/example/start/demo'
        self.package.mkdir(parents=True)
        (self.package / '.gitrepo').write_text('[subrepo]\nremote = https://github.com/example/demo.git\nbranch = main\ncommit = ' + 'a' * 40 + '\n')
        (self.package / 'LICENSE').write_text('fixture notice')
        (self.package / 'plugin.vim').write_text('let g:example = 1\n')
        self.patch = mock.patch.object(plugins, 'ROOT', self.root)
        self.patch.start()
        self.addCleanup(self.patch.stop)

    def test_inventory_reports_pin_and_notice_paths(self):
        record = plugins.inventory()['plugins'][0]
        self.assertEqual(record['provenance']['commit'], 'a' * 40)
        self.assertEqual(record['license_evidence'], {'status': 'notice_files_found', 'paths': ['.vim/pack/example/start/demo/LICENSE']})
        self.assertEqual(record['local_patches'], 'not_compared_with_upstream')

    def test_source_drift_changes_snapshot_but_python_cache_does_not(self):
        original = plugins.inventory()
        cache = self.package / '__pycache__'
        cache.mkdir()
        (cache / 'generated.pyc').write_bytes(b'cache')
        self.assertEqual(original, plugins.inventory())
        (self.package / 'plugin.vim').write_text('let g:example = 2\n')
        self.assertNotEqual(original['plugins'][0]['snapshot_sha256'], plugins.inventory()['plugins'][0]['snapshot_sha256'])

    def test_missing_pin_is_rejected(self):
        (self.package / '.gitrepo').write_text('[subrepo]\nremote=https://github.com/example/demo.git\n')
        with self.assertRaisesRegex(ValueError, 'upstream commit'):
            plugins.inventory()

    def test_update_check_queries_refs_without_mutating_packages(self):
        inventory = plugins.inventory()['plugins']
        output = io.StringIO()
        response = subprocess.CompletedProcess([], 0, 'b' * 40 + '\trefs/heads/main\n', '')
        with mock.patch.object(plugins.subprocess, 'run', return_value=response) as process, redirect_stdout(output):
            self.assertEqual(plugins.update_check(inventory, ['demo']), 0)
        self.assertEqual(process.call_args.args[0], ['git', 'ls-remote', '--exit-code', 'https://github.com/example/demo.git', 'refs/heads/main'])
        self.assertEqual(json.loads(output.getvalue())['status'], 'different')
        self.assertEqual(inventory, plugins.inventory()['plugins'])

    def test_failed_remote_lookup_has_nonzero_status(self):
        response = subprocess.CompletedProcess([], 2, '', 'network unavailable')
        with mock.patch.object(plugins.subprocess, 'run', return_value=response), redirect_stdout(io.StringIO()):
            self.assertEqual(plugins.update_check(plugins.inventory()['plugins'], ['demo']), 1)


if __name__ == '__main__':
    unittest.main()
