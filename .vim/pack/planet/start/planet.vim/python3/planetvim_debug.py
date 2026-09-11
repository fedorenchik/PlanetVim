"""Small compatibility bridge for the pinned Vimspector disconnect API.

Vimspector's public Stop cannot request a deterministic non-terminating
disconnect. Use its existing DAP connection and adapter cleanup, without
replacing upstream methods. A rejected/timed-out detach never kills the adapter.
"""
from weakref import WeakKeyDictionary
from pathlib import PurePath, PureWindowsPath

_pending = WeakKeyDictionary()


def detach(session, stop_adapter, report):
    connection = getattr(session, '_connection', None)
    if connection is None:
        raise RuntimeError('No active debugging session to detach.')
    connection_type = getattr(session, '_connection_type', None)
    if connection_type not in ('job', 'channel') or not callable(getattr(connection, 'DoRequest', None)):
        raise RuntimeError('This Vimspector connection does not support the pinned detach bridge.')
    capabilities = getattr(session, '_server_capabilities', {})
    request = (getattr(session, '_launch_config', None) or {}).get('request', 'launch')
    if request != 'attach' and not any(capabilities.get(key) for key in ('supportTerminateDebuggee', 'supportsTerminateDebuggee')):
        raise RuntimeError('The adapter does not advertise non-terminating disconnect support.')
    if connection in _pending:
        return False
    _pending[connection] = True
    report({'status': 'pending', 'error': ''})

    def failed(reason, message=None):
        _pending.pop(connection, None)
        report({'status': 'failed', 'error': str(reason)})

    def detached(message):
        _pending.pop(connection, None)
        if getattr(session, '_connection', None) is not connection:
            report({'status': 'superseded', 'error': 'The active debug session changed.'})
            return
        try:
            stop_adapter(connection_type, session.session_id)
            report({'status': 'success', 'error': ''})
        except Exception as error:
            report({'status': 'failed', 'error': str(error)})

    def send_request(callback, request):
        if getattr(session, '_connection', None) is not connection:
            failed('The active debug session changed.')
            return
        connection.DoRequest(callback, request, failure_handler=failed,
                             timeout=connection.sync_timeout)

    def disconnect(message=None):
        send_request(detached, {'command': 'disconnect',
                               'arguments': {'terminateDebuggee': False}})

    def detach_gdb(message=None):
        # GDB DAP's disconnect(false) exits through `quit`, which kills a
        # launched inferior in supported GDB versions. Its documented REPL
        # evaluate context executes `detach`, releasing it before shutdown.
        send_request(disconnect, {'command': 'evaluate',
                                  'arguments': {'context': 'repl', 'expression': 'detach'}})

    command = (getattr(session, '_adapter', None) or {}).get('command', [])
    direct_gdb = (isinstance(command, list) and command and
                  PureWindowsPath(PurePath(command[0]).name).name.lower() in ('gdb', 'gdb.exe') and
                  '--interpreter=dap' in command)
    try:
        if direct_gdb:
            view = getattr(session, '_stackTraceView', None)
            # Vimspector retains the old frame after Continue. Thread state,
            # not a stale frame, determines whether GDB needs to be paused.
            threads = [thread for state in getattr(view, '_sessions', [])
                       if state.session is session for thread in state.threads]
            if any(thread.CanExpand() for thread in threads):
                detach_gdb()
            else:
                # GDB accepts pause for all threads and evaluates REPL commands
                # only when stopped. Never stop the adapter if this step fails.
                send_request(detach_gdb, {'command': 'pause', 'arguments': {}})
        else:
            disconnect()
    except Exception:
        _pending.pop(connection, None)
        raise
    return True
