"""Live menu-state events; opt in with PLANETVIM_MENU_GUI=1 and a private Xvfb."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from test import virtual_display, vim_string


@unittest.skipUnless(os.environ.get("PLANETVIM_MENU_GUI") == "1", "set PLANETVIM_MENU_GUI=1")
class MenuStateEvents(unittest.TestCase):
    def test_options_context_and_idle_updates(self):
        gvim = shutil.which(os.environ.get("GVIM", "gvim"))
        xvfb = shutil.which(os.environ.get("PLANETVIM_XVFB", "Xvfb"))
        self.assertTrue(gvim and xvfb, "GVim with clientserver and Xvfb are required")
        with tempfile.TemporaryDirectory(prefix="planetvim-menu-state-") as temporary, virtual_display(xvfb) as display:
            directory = Path(temporary)
            env = dict(os.environ, DISPLAY=display, PLANETVIM_ROOT=str(ROOT))
            for kind in ("CONFIG", "STATE", "CACHE", "SESSIONS"):
                env["PLANETVIM_" + kind + "_DIR"] = str(directory / kind.lower())
            file = directory / "example.txt"
            file.write_text("menu indicators\n")
            process = subprocess.Popen([
                gvim, "-f", "--servername", "PVMENUSTATE", "-U", "NONE", "-i", "NONE", "-n",
                "--cmd", "let g:PV_native_tabs=v:false | let g:PV_clangd_argv=[] | let g:PV_pylsp_argv=[]",
                "-u", str(ROOT / "scripts/planetvim.vim"), str(file),
            ], cwd=directory, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            try:
                def expr(value):
                    result = subprocess.run([gvim, "--servername", "PVMENUSTATE", "--remote-expr", value],
                                            env=env, text=True, capture_output=True, timeout=8)
                    return result.stdout.strip() if result.returncode == 0 else ""

                deadline = time.monotonic() + 20
                while expr("v:vim_did_enter") != "1":
                    self.assertIsNone(process.poll(), "GVim exited during startup")
                    self.assertLess(time.monotonic(), deadline, "GVim did not become ready")
                    time.sleep(.1)

                def ex(command):
                    # execute() also captures expected silent! errors when a
                    # menu group is removed. Fail on actual exceptions.
                    wrapped = "let g:PV_state_error = ''\ntry\n" + command + "\ncatch\nlet g:PV_state_error = v:exception\nendtry"
                    expr("execute(" + vim_string(wrapped) + ")")
                    self.assertEqual("", expr("g:PV_state_error"))
                    self.assertEqual("0", expr("planet#menu_state#Stats().errors"))

                def label(path):
                    return expr("get(menu_info(" + vim_string(path) + "), 'display', '')")

                self.assertNotRegex(expr("execute('messages')"), r"\bE\d{2,}:")
                ex("set noinsertmode | call planet#menu#Style('descriptive') | call planet#menu#Group('settings')")
                wrap = "Settings.Toggle 'wrap'"
                ex("setlocal nowrap")
                self.assertTrue(label(wrap).startswith("☐ "))
                ex("setlocal wrap")
                self.assertTrue(label(wrap).startswith("☑ "))
                ex("split | setlocal nowrap")
                self.assertTrue(label(wrap).startswith("☐ "))
                ex("wincmd p")
                self.assertTrue(label(wrap).startswith("☑ "))
                ex("set wildoptions+=pum")
                self.assertTrue(label("Settings.Command-line Completion.Toggle Popup").startswith("☑ "))
                ex("set wildoptions-=pum")
                self.assertTrue(label("Settings.Command-line Completion.Toggle Popup").startswith("☐ "))

                # Direct variable writes have no OptionSet; SafeState catches
                # them without polling or a manual menu-state refresh.
                ex("call planet#menu#Group('basic')")
                def send(command):
                    subprocess.run([gvim, "--servername", "PVMENUSTATE", "--remote-send", "<Esc>:" + command + "<CR>"],
                                   env=env, check=True, timeout=8, capture_output=True)

                send("let g:PV_autosave = 1")
                deadline = time.monotonic() + 3
                while not label("File.Toggle AutoSave").startswith("☑ "):
                    self.assertLess(time.monotonic(), deadline, "idle update did not mark AutoSave")
                    time.sleep(.05)
                send("let g:PV_autosave = 0")
                deadline = time.monotonic() + 3
                while not label("File.Toggle AutoSave").startswith("☐ "):
                    self.assertLess(time.monotonic(), deadline, "idle update did not clear AutoSave")
                    time.sleep(.05)
                # No further changed setting means no menu recreation.
                before = expr("json_encode(planet#menu_state#Stats())")
                self.assertEqual(0, json.loads(before)["errors"])
                time.sleep(.2)
                self.assertEqual(json.loads(before), json.loads(expr("json_encode(planet#menu_state#Stats())")))
                self.assertNotRegex(expr("execute('messages')"), r"\bE\d{2,}:")
            finally:
                if process.poll() is None:
                    process.terminate()
                process.wait(timeout=10)


if __name__ == "__main__":
    unittest.main()
