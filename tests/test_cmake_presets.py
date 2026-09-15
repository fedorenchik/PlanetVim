import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

PATH = Path(__file__).resolve().parents[1] / '.vim/pack/planet/start/planet.vim/bin/cmake-presets.py'
spec = importlib.util.spec_from_file_location('cmake_presets', PATH)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class PresetTests(unittest.TestCase):
    def test_inheritance_environment_and_file_directory_versions(self):
        for version in (6, 12):
            with self.subTest(version=version), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                (root / 'nested').mkdir()
                (root / 'nested/base.json').write_text(json.dumps({
                    'version': version, 'configurePresets': [
                        {'name': 'first', 'hidden': True, 'binaryDir': '${fileDir}/../${presetName}',
                         'environment': {'MODE': 'first', 'PATH': '/tool:$penv{PATH}',
                                         'REMOVE': None, 'CHAIN': '$env{MODE}'}},
                        {'name': 'second', 'environment': {'MODE': 'second', 'SECOND': 'kept'}}]}))
                (root / 'CMakePresets.json').write_text(json.dumps({
                    'version': version, 'include': ['nested/base.json', 'nested/base.json'],
                    'configurePresets': [{'name': 'chosen', 'inherits': ['first', 'second']}]}))
                result = module.Presets(root, {'PATH': '/base', 'REMOVE': 'yes'}).resolve('chosen')
                self.assertEqual({'PATH': '/tool:/base', 'MODE': 'first', 'SECOND': 'kept', 'CHAIN': 'first'}, result['environment'])
                self.assertEqual(str(root / 'chosen' if version == 12 else root.parent / 'chosen'), result['build_dir'])

    def test_cycles_fail_without_evaluation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / 'CMakePresets.json'
            path.write_text(json.dumps({'version': 6, 'configurePresets': [
                {'name': 'cycle', 'inherits': 'cycle'}]}))
            with self.assertRaisesRegex(ValueError, 'inheritance cycle'):
                module.Presets(root).resolve('cycle')
            path.write_text(json.dumps({'version': 6, 'configurePresets': [
                {'name': 'cycle', 'environment': {'A': '$env{B}', 'B': '$env{A}'}}]}))
            with self.assertRaisesRegex(ValueError, 'environment cycle'):
                module.Presets(root).resolve('cycle')
            path.write_text(json.dumps({'version': 6, 'include': ['CMakePresets.json']}))
            with self.assertRaisesRegex(ValueError, 'include cycle'):
                module.Presets(root)


if __name__ == '__main__':
    unittest.main()
