import importlib.util
from pathlib import Path
import os
import subprocess
import sys
import tempfile
import unittest

HELPER = Path(__file__).resolve().parents[1] / '.vim/pack/planet/start/planet.vim/bin/integration-tool.py'
spec = importlib.util.spec_from_file_location('planetvim_integration_tool', HELPER)
tool = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tool)


class IntegrationToolTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='planetvim-integration-')
        self.root = Path(self.temp.name)
        self.addCleanup(self.temp.cleanup)

    def test_capture_preserves_bytes_and_literal_argument(self):
        output = self.root / "output 'quoted' & value.txt"
        value = 'spaces & $() % !'
        result = tool.capture([sys.executable, '-c',
                               'import sys;sys.stdout.buffer.write(sys.argv[1].encode()+bytes([0,255]))', value], output)
        self.assertEqual(result, 0)
        self.assertEqual(output.read_bytes(), value.encode() + bytes([0, 255]))

    def test_failure_does_not_install_partial_output(self):
        output = self.root / 'output.txt'
        result = tool.capture([sys.executable, '-c', 'print("partial");raise SystemExit(9)'], output)
        self.assertEqual(result, 9)
        self.assertFalse(output.exists())
        self.assertEqual(list(self.root.iterdir()), [])

    def test_existing_output_is_preserved(self):
        output = self.root / 'output.txt'
        output.write_text('original')
        with self.assertRaisesRegex(ValueError, 'already exists'):
            tool.capture([sys.executable, '-c', 'print("replacement")'], output)
        self.assertEqual(output.read_text(), 'original')

    @unittest.skipIf(os.name == 'nt', 'POSIX SDK fixture')
    def test_source_receives_literal_arguments_and_dumps_environment(self):
        import json
        setup = self.root / "setup 'quote' & work.sh"
        setup.write_text('export PLANETVIM_FIXTURE="$1"\n')
        output = self.root / 'environment.json'
        self.assertEqual(tool.source_environment(setup, output, ['value with $() & symbols']), 0)
        self.assertEqual(json.loads(output.read_text())['PLANETVIM_FIXTURE'], 'value with $() & symbols')

    @unittest.skipIf(os.name == 'nt', 'POSIX SDK fixture')
    def test_failed_source_never_produces_environment_snapshot(self):
        setup = self.root / 'setup.sh'
        setup.write_text('export PLANETVIM_FIXTURE=partial\nreturn 7\n')
        output = self.root / 'environment.json'
        self.assertEqual(tool.source_environment(setup, output, []), 7)
        self.assertFalse(output.exists())

    def test_native_execution_reports_original_status(self):
        result = subprocess.run([sys.executable, str(HELPER), 'native', sys.executable,
                                 '-c', 'raise SystemExit(11)'], capture_output=True)
        self.assertEqual(result.returncode, 11)

    def test_missing_executable_is_actionable(self):
        with self.assertRaisesRegex(ValueError, 'Required executable not found'):
            tool.native(['planetvim-missing-sdk-tool'])


if __name__ == '__main__':
    unittest.main()
