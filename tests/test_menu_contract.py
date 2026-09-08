"""Static checks prevent enabled menu placeholders and missing first-party APIs."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / '.vim/pack/planet/start/planet.vim'


class MenuContracts(unittest.TestCase):
    def test_callbacks_and_placeholders(self):
        definitions = set()
        for path in PLUGIN.rglob('*.vim'):
            definitions.update(re.findall(r'(?mi)^\s*fu[a-z]*!?\s+(planet#[\w#]+)\(', path.read_text()))
        for path in [*(PLUGIN / 'autoload/planet/menu').glob('*.vim'), ROOT / '.vimrc']:
            for number, line in enumerate(path.read_text().splitlines(), 1):
                if not re.match(r'\s*(?:an|am|[a-z]*menu)\s+(?:<[^>]+>\s+)*\d', line):
                    continue
                location = f'{path.name}:{number}'
                self.assertNotRegex(line, r'(?i)(?:<Cmd>|:)TODO(?:\b|<)', location)
                self.assertNotRegex(line, r"(?i)echo\s+['\"]TODO['\"]", location)
                for callback in re.findall(r'(planet#[\w#]+)\(', line):
                    self.assertTrue(callback in definitions, location + ': missing ' + callback)
                self.assertNotIn('SenEnvVar', line, location)
                self.assertNotIn('<SID>Xxd', line, location)


if __name__ == '__main__':
    unittest.main()
