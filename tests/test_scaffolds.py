"""Generate every menu scaffold; validate formats and available native toolchains."""
import ast
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import uuid
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / '.vim/pack/planet/start/planet.vim'
TEMPLATES = PLUGIN / 'templates'
spec = importlib.util.spec_from_file_location('generator', PLUGIN / 'bin/generate-project.py')
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)


class Scaffolds(unittest.TestCase):
    def run_tool(self, command, cwd=None):
        result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, timeout=90)
        self.assertEqual(result.returncode, 0, str(command) + '\n' + result.stdout + result.stderr)
        return result.stdout

    def test_every_catalog_entry_generates_without_overwriting(self):
        catalog = json.loads((TEMPLATES / 'catalog.json').read_text())
        menu = (PLUGIN / 'autoload/planet/menu/basic.vim').read_text()
        with tempfile.TemporaryDirectory(prefix="planetvim scaffolds ' 工作 ") as temporary:
            parent = Path(temporary)
            for name, entry in catalog.items():
                with self.subTest(name=name), contextlib.redirect_stdout(io.StringIO()):
                    self.assertIn("planet#scaffold#New(''" + name + "'')", menu)
                    source = TEMPLATES / entry['path']
                    destination = parent / (name + source.suffix if source.is_file() else name)
                    operation = 'file' if entry['kind'] == 'file' else 'template'
                    self.assertEqual(generator.generate(operation, entry['path'], str(destination), TEMPLATES), 0)
                    self.assertTrue(destination.exists())
                    files = list(destination.rglob('*')) if destination.is_dir() else [destination]
                    for path in files:
                        if path.suffix == '.py':
                            ast.parse(path.read_text(), filename=str(path))
                        elif path.suffix in ('.ui', '.qrc', '.qmodel', '.scxml', '.xml'):
                            ET.parse(path)
                        elif path.suffix == '.json':
                            json.loads(path.read_text())
                    with self.assertRaises(generator.GenerationError):
                        generator.generate(operation, entry['path'], str(destination), TEMPLATES)
                    if name == 'qt-model':
                        ids = [element.text for element in ET.parse(destination).iter('uid')]
                        self.assertEqual(len(ids), 2)
                        self.assertEqual(len(set(ids)), 2)
                        for identifier in ids:
                            uuid.UUID(identifier)
                        second = parent / 'second.qmodel'
                        generator.generate('file', entry['path'], str(second), TEMPLATES)
                        other = [element.text for element in ET.parse(second).iter('uid')]
                        self.assertFalse(set(ids) & set(other))
            self.assertFalse(list(parent.glob('.planetvim-*')), 'no abandoned staging directories')

    @unittest.skipUnless(shutil.which('glslangValidator'), 'GLSL compiler not installed')
    def test_all_shader_stages_compile(self):
        with tempfile.TemporaryDirectory() as temporary:
            for path in (TEMPLATES / 'files').glob('glsl-*/*'):
                with self.subTest(stage=path.suffix):
                    self.run_tool(['glslangValidator', '-V', str(path), '-o', str(Path(temporary) / 'shader.spv')])

    @unittest.skipUnless(shutil.which('dtc'), 'Device tree compiler not installed')
    def test_device_tree_compiles(self):
        with tempfile.TemporaryDirectory() as temporary:
            self.run_tool(['dtc', '-I', 'dts', '-O', 'dtb', '-o', str(Path(temporary) / 'example.dtb'), str(TEMPLATES / 'linux-device-tree/example.dts')])

    @unittest.skipUnless(shutil.which('cmake') and shutil.which('c++'), 'CMake/C++ not installed')
    def test_cpp_projects_build_and_test(self):
        with tempfile.TemporaryDirectory(prefix='planetvim C++ build ') as temporary:
            for name in ('cmake', 'cpp-dsl'):
                with self.subTest(project=name):
                    build = Path(temporary) / name
                    self.run_tool(['cmake', '-S', str(TEMPLATES / name), '-B', str(build)])
                    self.run_tool(['cmake', '--build', str(build)])
                    self.run_tool(['ctest', '--test-dir', str(build), '--output-on-failure'])
            executable = Path(temporary) / 'cpp-dsl/planet_dsl'
            if not executable.exists():
                executable = executable.with_suffix('.exe')
            invalid = subprocess.run([str(executable), '9223372036854775807 + 1'], capture_output=True)
            self.assertNotEqual(invalid.returncode, 0, 'overflow must be rejected')

    @unittest.skipUnless(shutil.which('cmake') and (shutil.which('qmake6') or shutil.which('qmake')), 'Qt SDK not installed')
    def test_qt_designer_form_builds(self):
        with tempfile.TemporaryDirectory(prefix='planetvim Qt form ') as temporary:
            self.run_tool(['cmake', '-S', str(TEMPLATES / 'qt-form-class'), '-B', temporary])
            self.run_tool(['cmake', '--build', temporary])


if __name__ == '__main__':
    unittest.main()
