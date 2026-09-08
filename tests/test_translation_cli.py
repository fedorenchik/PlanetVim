import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / '.vim/pack/planet/start/planet.vim/bin/translate.py'


class TranslationCLI(unittest.TestCase):
    def test_preserves_text_and_strict_json(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            provider = base / 'provider with spaces.py'
            provider.write_text('class Engine:\n    def translate(self, source, target, text, options):\n        return {"engine":"fixture", "paraphrase":text, "explains":[]}\nENGINES={"fixture":Engine}\n')
            text = 'UPPER Case, apostrophe\'s; $(literal) 中文\nsecond line'
            request = base / 'request.json'
            request.write_text(json.dumps(dict(text=text, source='auto', target='zh', engines=['fixture'], provider=str(provider))))
            result = subprocess.run([sys.executable, str(HELPER), '--request', str(request)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout)['results'][0]['paraphrase'], text)
            self.assertFalse((base / '__pycache__').exists(), 'provider import must not write its installation directory')
            request.write_text(json.dumps(dict(text=text, source='auto', target='zh', engines=['invalid'], provider=str(ROOT / '.vim/pack/writing/start/vim-translator/script/translator.py'))))
            result = subprocess.run([sys.executable, str(HELPER), '--request', str(request)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 1)
            self.assertFalse(json.loads(result.stdout)['status'])


if __name__ == '__main__':
    unittest.main()
