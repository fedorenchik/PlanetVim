"""Build copied native templates; never install SDKs or start desktop apps."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

TEMPLATES = Path(__file__).resolve().parents[1] / '.vim/pack/planet/start/planet.vim/templates'


class NativeTemplateTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix='planetvim-native-template-')
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        if os.name == 'nt':
            self.skipTest('Native Makefile acceptance uses Linux development libraries')

    def require(self, *commands):
        missing = [command for command in commands if not shutil.which(command)]
        if missing:
            self.skipTest('Missing build tools: ' + ', '.join(missing))

    def build_make(self, name, packages, output):
        self.require('make', 'pkg-config', 'cc', 'c++')
        probe = subprocess.run(['pkg-config', '--exists', *packages], capture_output=True)
        if probe.returncode:
            self.skipTest('Missing development packages: ' + ', '.join(packages))
        project = self.root / ('project with spaces ' + name)
        shutil.copytree(TEMPLATES / name, project)
        environment = dict(os.environ, LDFLAGS='-Wl,--as-needed')
        result = subprocess.run(['make', '-j2'], cwd=project, env=environment,
                                capture_output=True, text=True, timeout=60)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue((project / output).is_file())
        result = subprocess.run(['make', 'clean'], cwd=project, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((project / output).exists())

    def test_gtk_builder_links_and_cleans(self):
        self.build_make('Gtk3BuilderApp', ['gtk+-3.0'], 'app')

    def test_glfw_links_with_as_needed(self):
        self.build_make('glfw-app', ['glfw3', 'glew', 'gl'], 'glfw-app')

    def test_sdl_links_with_as_needed(self):
        self.build_make('sdl-app', ['sdl2', 'glew', 'gl'], 'sdl-app')

    def test_sfml_links_with_as_needed(self):
        self.build_make('sfml-app', ['sfml-window', 'sfml-system', 'glew', 'gl'], 'sfml-app')

    def test_vulkan_cmake_build(self):
        self.require('cmake', 'c++', 'pkg-config')
        if subprocess.run(['pkg-config', '--exists', 'vulkan']).returncode:
            self.skipTest('Missing Vulkan development headers/loader')
        project = self.root / 'Vulkan project with spaces'
        shutil.copytree(TEMPLATES / 'vulkan-app', project)
        for arguments in (['cmake', '-S', str(project), '-B', str(project / 'build')],
                          ['cmake', '--build', str(project / 'build')]):
            result = subprocess.run(arguments, capture_output=True, text=True, timeout=60)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue((project / 'build/planet_vulkan').is_file())


class JavaScriptTemplateTests(unittest.TestCase):
    def test_locked_direct_dependencies_and_menu_scripts(self):
        for name in ('electron-app', 'vue-3-app'):
            with self.subTest(template=name):
                project = TEMPLATES / name
                package = json.loads((project / 'package.json').read_text())
                lock = json.loads((project / 'package-lock.json').read_text())
                self.assertEqual(package['name'], lock['packages']['']['name'])
                for kind in ('dependencies', 'devDependencies'):
                    self.assertEqual(package.get(kind, {}), lock['packages'][''].get(kind, {}))
                    for dependency, version in package.get(kind, {}).items():
                        self.assertRegex(version, r'^\d+\.\d+\.\d+$', dependency)
                        self.assertEqual(version, lock['packages']['node_modules/' + dependency]['version'])
                for script in ('dev', 'serve', 'build', 'lint'):
                    self.assertTrue(package['scripts'][script])
                self.assertFalse((project / 'node_modules').exists())
                self.assertFalse((project / 'dist').exists())


if __name__ == '__main__':
    unittest.main()
