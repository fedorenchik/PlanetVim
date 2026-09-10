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

    def test_first_party_definitions_use_teaching_metadata(self):
        creation = r'(?:an|am|(?:[anvxsoic]|tl)?(?:nore)?menu)'
        for path in [*PLUGIN.rglob('*.vim'), ROOT / '.vimrc']:
            for number, line in enumerate(path.read_text().splitlines(), 1):
                self.assertNotRegex(
                    line, r'^\s*' + creation + r'\s+(?!enable\b|disable\b)',
                    f'{path.name}:{number}: use PlanetMenu for teaching metadata')

    def test_first_party_runtime_uses_vim9(self):
        own = ROOT / '.vim/pack/planet/start'
        paths = [*own.rglob('*.vim'), ROOT / '.vimrc',
                 ROOT / '.vim/after/unmap.vim', ROOT / '.vim/keymap/russian-dvp.vim']
        for path in paths:
            if not path.is_file():
                continue
            source = path.read_text()
            code = [line.strip() for line in source.splitlines()
                    if line.strip() and not line.lstrip().startswith(('"', '#'))]
            self.assertTrue(code[0].startswith('vim9script'), str(path))
            # Keymap entries after loadkeymap are data, not Vim statements.
            source = source.split('\nloadkeymap', 1)[0]
            if path == PLUGIN / 'plugin/planet.vim':
                # Sole legacy bridge: Vim 9.1 tag-file addresses need its context.
                bridge = "function LocalPreviewTag(word) abort\n  execute 'ptag ' .. a:word\nendfunction"
                self.assertEqual(1, source.count(bridge))
                source = source.replace(bridge, '')
            self.assertNotRegex(source, r'(?m)^\s*fu(?:nction|nc|n)?!?\s', str(path))

    def test_callbacks_and_placeholders(self):
        definitions = set()
        # Legacy global names and vendor autoload callbacks are just as callable
        # as planet# APIs. Include vimrc's window-bar helpers in the definitions.
        callback_pattern = r'(?:[A-Z]\w*|[a-z]\w*(?:#\w+)+)'
        for path in [*(ROOT / '.vim').rglob('*.vim'), ROOT / '.vimrc']:
            if not path.is_file():
                continue
            source = path.read_text(errors='replace')
            definitions.update(re.findall(
                r'(?mi)^\s*(?:legacy\s+)?(?:fu[a-z]*!?|def!?)\s+(?:g:)?('
                + callback_pattern + r')\s*\(', source))
            if 'autoload' in path.parts:
                relative = Path(*path.parts[path.parts.index('autoload') + 1:])
                prefix = '#'.join(relative.with_suffix('').parts) + '#'
                definitions.update(prefix + name for name in re.findall(
                    r'(?m)^\s*export\s+def\s+(\w+)\s*\(', source))
        for path in [*(PLUGIN / 'autoload/planet/menu').glob('*.vim'), ROOT / '.vimrc']:
            for number, line in enumerate(path.read_text().splitlines(), 1):
                if not (re.match(r'\s*(?:PlanetMenu\s+)?(?:an|am|[a-z]*menu)\s+(?:<[^>]+>\s+)*\d', line)
                        or 'execute planet#menu_help#Entry(' in line):
                    continue
                location = f'{path.name}:{number}'
                self.assertNotRegex(line, r'(?i)(?:<Cmd>|:)TODO(?:\b|<)', location)
                self.assertNotRegex(line, r"(?i)echo\s+['\"]TODO['\"]", location)
                for callback in re.findall(r'\b(' + callback_pattern + r')\s*\(', line):
                    self.assertTrue(callback in definitions, location + ': missing ' + callback)
                self.assertNotIn('SenEnvVar', line, location)
                self.assertNotIn('<SID>Xxd', line, location)


if __name__ == '__main__':
    unittest.main()
