"""Static checks prevent enabled menu placeholders and missing first-party APIs."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / '.vim/pack/planet/start/planet.vim'


class MenuContracts(unittest.TestCase):
    def test_named_commands_have_an_implementation(self):
        # Include filetype-local commands without activating external SDKs.
        # TOhtml is supplied by GVim's own runtime, outside the repository.
        definitions = {'TOhtml'}
        for path in (ROOT / '.vim').rglob('*.vim'):
            if not path.is_file():
                continue
            source = re.sub(r'\n\s*\\', ' ', path.read_text(errors='replace'))
            for line in source.splitlines():
                match = re.search(r'^\s*com(?:mand)?!?\s+(?:-\S+\s+)*([A-Z]\w*)\b', line)
                if match:
                    definitions.add(match[1])
        for path in (PLUGIN / 'autoload/planet/menu').glob('*.vim'):
            for number, line in enumerate(path.read_text().splitlines(), 1):
                if line.lstrip().startswith('"'):
                    continue
                for command in re.findall(r'<Cmd>([A-Z]\w*)', line):
                    self.assertTrue(command in definitions, f'{path.name}:{number}: undefined command {command}')

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
