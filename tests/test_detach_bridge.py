import importlib.util
from pathlib import Path
from types import SimpleNamespace
import unittest

MODULE = Path(__file__).resolve().parents[1] / '.vim/pack/planet/start/planet.vim/python3/planetvim_debug.py'
spec = importlib.util.spec_from_file_location('planetvim_debug', MODULE)
bridge = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)


class Connection:
    sync_timeout = 1000

    def DoRequest(self, callback, request, failure_handler, timeout):
        self.callback, self.request, self.failed, self.timeout = callback, request, failure_handler, timeout


class DetachBridge(unittest.TestCase):
    def session(self, support=True):
        return SimpleNamespace(_connection=Connection(), _connection_type='job',
                               _server_capabilities={'supportsTerminateDebuggee': support},
                               _launch_config={'request': 'launch'})

    def test_success_requires_ack_and_false_termination(self):
        session, stopped, results = self.session(), [], []
        self.assertTrue(bridge.detach(session, stopped.append, results.append))
        self.assertEqual(stopped, [])
        self.assertEqual(session._connection.request, {'command': 'disconnect', 'arguments': {'terminateDebuggee': False}})
        self.assertFalse(bridge.detach(session, stopped.append, results.append))
        session._connection.callback({})
        self.assertEqual(stopped, ['job'])
        self.assertEqual(results[-1]['status'], 'success')

    def test_failure_and_new_session_never_kill_adapter(self):
        session, stopped, results = self.session(), [], []
        bridge.detach(session, stopped.append, results.append)
        session._connection.failed('rejected', {})
        self.assertEqual(stopped, [])
        self.assertEqual(results[-1]['status'], 'failed')
        bridge.detach(session, stopped.append, results.append)
        old = session._connection
        session._connection = Connection()
        old.callback({})
        self.assertEqual(stopped, [])
        self.assertEqual(results[-1]['status'], 'superseded')

    def test_unsupported_adapter_is_not_disconnected(self):
        session = self.session(False)
        with self.assertRaises(RuntimeError):
            bridge.detach(session, lambda kind: self.fail('stopped'), lambda result: None)
        self.assertFalse(hasattr(session._connection, 'request'))

    def test_gdb_releases_inferior_before_disconnect(self):
        session, stopped, results = self.session(), [], []
        session._adapter = {'command': ['gdb', '--quiet', '--nx', '--interpreter=dap']}
        session._stackTraceView = SimpleNamespace(_threads=[SimpleNamespace(CanExpand=lambda: True)])
        bridge.detach(session, stopped.append, results.append)
        self.assertEqual(session._connection.request, {'command': 'evaluate', 'arguments': {'context': 'repl', 'expression': 'detach'}})
        session._connection.callback({})
        self.assertEqual(session._connection.request['command'], 'disconnect')
        self.assertIs(session._connection.request['arguments']['terminateDebuggee'], False)
        self.assertEqual(stopped, [])
        session._connection.callback({})
        self.assertEqual(stopped, ['job'])

    def test_running_gdb_pauses_before_detach_and_preserves_failed_session(self):
        session, stopped, results = self.session(), [], []
        session._adapter = {'command': ['gdb', '--interpreter=dap']}
        session._stackTraceView = SimpleNamespace(_threads=[SimpleNamespace(CanExpand=lambda: False)])
        bridge.detach(session, stopped.append, results.append)
        self.assertEqual(session._connection.request['command'], 'pause')
        session._connection.callback({})
        self.assertEqual(session._connection.request['command'], 'evaluate')
        session._connection.failed('cannot detach', {})
        self.assertEqual(stopped, [])
        self.assertEqual(results[-1]['status'], 'failed')


if __name__ == '__main__':
    unittest.main()
