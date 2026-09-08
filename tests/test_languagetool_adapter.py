import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET

HELPER = Path(__file__).resolve().parents[1] / '.vim/pack/planet/start/planet.vim/bin/languagetool.py'
spec = importlib.util.spec_from_file_location('planet_languagetool', HELPER)
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)


class LanguageToolAdapter(unittest.TestCase):
    def test_utf16_offsets_become_vim_utf8_columns_and_xml_is_escaped(self):
        text = '😀 Café is is a test.\nSecond word word.'
        start = len('😀 Café '.encode('utf-16-le')) // 2
        response = {'matches': [{'offset': start, 'length': 5, 'message': '<bad & "quotes">',
                                'replacements': [{'value': 'is'}],
                                'context': {'text': text, 'offset': start, 'length': 5},
                                'rule': {'id': 'REPEAT', 'category': {'id': 'MISC', 'name': 'Grammar'}}}]}
        error = ET.fromstring(adapter.as_xml(response, text))[0].attrib
        self.assertEqual(int(error['fromx']), len('😀 Café '.encode('utf-8')))
        self.assertEqual(int(error['tox']), len('😀 Café is is'.encode('utf-8')))
        self.assertEqual(error['fromy'], '0')
        self.assertEqual(error['msg'], '<bad & "quotes">')
        self.assertEqual(error['contextoffset'], error['fromx'])
        self.assertEqual(error['errorlength'], '5')
        self.assertEqual(adapter.position(text, len('😀 Café is is a test.\n'.encode('utf-16-le')) // 2), (1, 0))
        with self.assertRaises(ValueError):
            adapter.position(text, -1)

    def test_native_argv_and_real_exit_status(self):
        with tempfile.TemporaryDirectory(prefix='planet grammar ') as directory:
            root = Path(directory)
            source, config, script, record = [root / name for name in ['input.txt', 'config.json', 'fake cli.py', 'argv.json']]
            source.write_text('Text with literal $(text).', encoding='utf-8')
            script.write_text('import json,pathlib,sys\npathlib.Path(sys.argv[1]).write_text(json.dumps(sys.argv[2:]),encoding="utf-8")\nprint(json.dumps({"matches":[]}))\n', encoding='utf-8')
            literal = 'two words; "quoted" \\ trailing'
            error_file = root / 'last-error.log'
            config.write_text(json.dumps({'argv': [sys.executable, str(script), str(record), literal], 'error_file': str(error_file)}), encoding='utf-8')
            result = subprocess.run([sys.executable, str(HELPER), '--config', str(config), '-c', 'utf-8', '-l', 'en-US', '--api', str(source)], capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(ET.fromstring(result.stdout).tag, 'matches')
            self.assertEqual(json.loads(record.read_text(encoding='utf-8')), [literal, '-c', 'utf-8', '-l', 'en-US', '--json', str(source)])
            source.write_bytes(b'First sentence.\r\nThis is is a mistake.\r\n')
            response = {'matches': [{'offset': 22, 'length': 5, 'message': 'Repeated word',
                                    'context': {'text': 'This is is a mistake.', 'offset': 5, 'length': 5},
                                    'replacements': [{'value': 'is'}], 'rule': {'id': 'REPEAT'}}]}
            script.write_text('print(' + repr(json.dumps(response)) + ')\n', encoding='utf-8')
            result = subprocess.run([sys.executable, str(HELPER), '--config', str(config), '--api', str(source)], capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            error = ET.fromstring(result.stdout)[0].attrib
            self.assertEqual((error['fromy'], error['fromx']), ('1', '5'), 'CRLF must not shift Windows source columns')
            script.write_text('import sys\nprint("intentional failure",file=sys.stderr)\nsys.exit(7)\n', encoding='utf-8')
            result = subprocess.run([sys.executable, str(HELPER), '--config', str(config), '--api', str(source)], capture_output=True)
            self.assertEqual(result.returncode, 7)
            self.assertIn(b'intentional failure', result.stderr)
            self.assertEqual(result.stdout, b'')
            self.assertIn('intentional failure', error_file.read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
