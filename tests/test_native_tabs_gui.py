"""Real GTK mouse acceptance, opt in with make test-native-tabs.

Each run uses a private Xvfb display and disposable PlanetVim state. Set GVIM
and PLANETVIM_XVFB to test a particular supported build/display executable.
"""
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


@unittest.skipUnless(os.environ.get("PLANETVIM_NATIVE_GUI") == "1", "use make test-native-tabs")
class NativeTabMouseTests(unittest.TestCase):
    def setUp(self):
        self.gvim = shutil.which(os.environ.get("GVIM", "gvim"))
        xvfb = shutil.which(os.environ.get("PLANETVIM_XVFB", "Xvfb"))
        self.assertTrue(self.gvim and xvfb and shutil.which("xdotool"), "GVim, Xvfb and xdotool are required")
        temporary = tempfile.TemporaryDirectory(prefix="planetvim-native-tabs-test-")
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        display_context = virtual_display(xvfb)
        display = display_context.__enter__()
        self.addCleanup(display_context.__exit__, None, None, None)
        self.env = dict(os.environ, DISPLAY=display, GTK_THEME="Adwaita:dark")
        for kind in ("CONFIG", "STATE", "CACHE", "SESSIONS"):
            self.env["PLANETVIM_" + kind + "_DIR"] = str(self.directory / kind.lower())
        for name in ("one.py", "two.txt", "three.txt"):
            (self.directory / name).write_text("first line\nsecond line\n")
        setup = self.directory / "setup.vim"
        setup.write_text("\n".join([
            "set noinsertmode nomore nospell columns=100 lines=35 guifont=Monospace\\ 12",
            "edit " + str(self.directory / "one.py"),
            "tabedit " + str(self.directory / "two.txt"),
            "tabedit " + str(self.directory / "three.txt"),
            "tabfirst",
        ]) + "\n")
        self.process = subprocess.Popen([
            self.gvim, "-f", "--servername", "PVNATIVE", "-U", "NONE", "-i", "NONE", "-n",
            "--cmd", "let g:PV_clangd_argv=[] | let g:PV_pylsp_argv=[]",
            "-u", str(ROOT / "scripts/planetvim.vim"), "-S", str(setup),
        ], cwd=self.directory, env=self.env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self.addCleanup(self.shutdown)
        deadline = time.monotonic() + 15
        while time.monotonic() < deadline:
            if self.expr("v:servername", check=False) == "PVNATIVE":
                break
            time.sleep(.1)
        else:
            self.fail("GVim server did not become ready")
        # The server becomes reachable before -S/VimEnter/first GUI redraw.
        deadline = time.monotonic() + 10
        while self.expr("v:vim_did_enter && tabpagenr('$') == 3 ? 1 : 0") != "1":
            self.assertLess(time.monotonic(), deadline, "startup did not finish")
            time.sleep(.1)
        self.key("Escape", "Return")
        self.assertEqual("enabled", self.expr("g:PV_native_tabs_status"))
        # Xvfb has no window manager to deliver the final configure event.
        # Give GTK one resize, and use predictable label widths for mouse input.
        self.ex("let &guitablabel = \"%{printf('PlanetVim Tab %d', v:lnum)}\" | set lines=34")
        self.ex('let v:errmsg = ""')

    def shutdown(self):
        if self.process.poll() is None:
            self.process.terminate()
            self.process.wait(timeout=10)

    def expr(self, value, check=True):
        result = subprocess.run([self.gvim, "--servername", "PVNATIVE", "--remote-expr", value],
                                env=self.env, text=True, capture_output=True, timeout=8)
        if check:
            self.assertEqual(0, result.returncode, result.stderr)
            self.assertNotIn("Send expression failed", result.stderr)
        return result.stdout.strip()

    def ex(self, command):
        result = self.expr("execute(" + vim_string(command) + ")")
        self.assertNotIn("Error detected", result, result)
        return result

    def key(self, *keys):
        subprocess.run(["xdotool", "key", *keys], env=self.env, check=True)
        time.sleep(.15)

    def send(self, keys):
        subprocess.run([self.gvim, "--servername", "PVNATIVE", "--remote-send", keys], env=self.env, check=True)
        time.sleep(.15)

    def click(self, x, button=3):
        if button == 3:
            self.ex("if !empty(menu_info(']PVTab')) | execute (get(menu_info(']PVTab'), 'modes', '') ==# 'tl' ? 'tlunmenu' : 'aunmenu') .. ' ]PVTab' | endif")
        subprocess.run(["xdotool", "mousemove", str(x), "44", "click", str(button)], env=self.env, check=True)
        time.sleep(.2)

    def menu(self, label, mode="n"):
        deadline = time.monotonic() + 2
        while True:
            entry = json.loads(self.expr("json_encode(menu_info(" + vim_string("]PVTab." + label) + ", " + vim_string(mode) + "))"))
            if entry:
                return entry
            if time.monotonic() >= deadline:
                self.fail("Missing menu " + label + ": " + self.expr("string([mode(1), g:PV_native_tabs_status, v:errmsg, execute('messages'), map(getscriptinfo({'sid': filter(getscriptinfo(), {_,s -> s.name =~ 'autoload/planet/native_tabs.vim$'})[0].sid}), {_,s -> get(s.variables, 'armed', -1)})])"))
            time.sleep(.05)

    def test_native_identity_modes_and_lifecycle(self):
        self.assertEqual("0", self.expr("exists('*planet#tab_menu#Show')"))
        self.click(180)
        self.assertIn("Action('2', 'close'", self.menu("Close Tab")["rhs"])
        self.assertEqual("1", self.expr("tabpagenr()"))
        # Select Copy File Path through GTK, not :emenu or a direct action call.
        self.key("End", "Up", "Up", "Up", "Return")
        self.assertEqual(str(self.directory / "two.txt"), self.expr("getreg('+')"))
        self.assertEqual("1", self.expr("tabpagenr()"))

        # Move the native tab using an ordinary Vim command, retaining its ID.
        self.ex("tabnext 2 | tabmove 0 | tabnext 2")
        self.click(60)
        self.assertIn("Action('2', 'close'", self.menu("Close Tab")["rhs"])
        self.key("Escape")

        # Native GTK left-click and drag must keep working with the helper.
        self.click(60, 1)
        self.key("Escape")
        self.assertEqual("2", self.expr("planet#tab#Id(tabpagenr())"))
        subprocess.run(["xdotool", "mousemove", "60", "44", "mousedown", "1"], env=self.env, check=True)
        for x in range(80, 361, 20):
            subprocess.run(["xdotool", "mousemove", str(x), "44"], env=self.env, check=True)
            time.sleep(.1)
        subprocess.run(["xdotool", "mouseup", "1"], env=self.env, check=True)
        self.key("Escape")
        self.assertEqual("3", self.expr("planet#tab#Find('2')"))
        self.click(300)
        self.assertIn("Action('2', 'close'", self.menu("Close Tab")["rhs"])
        self.key("Escape")

        for keys, mode in [("i", "i"), ("<Esc>v", "x"), ("<Esc>v<C-G>", "s")]:
            self.send(keys)
            before = self.expr("string([mode(), getpos('.'), getpos('v')])")
            self.click(60)
            self.assertIn("'path'", self.menu("Copy File Path", mode)["rhs"])
            self.key("End", "Up", "Up", "Up", "Return")
            self.assertEqual(before, self.expr("string([mode(), getpos('.'), getpos('v')])"))
        self.send("<Esc>:echo 'retain command'")
        self.click(60)
        self.assertEqual("echo 'retain command'", self.expr("getcmdline()"))
        self.key("Escape")
        self.send("<Esc>")

        # Terminal mode uses its own <Cmd> mapping; no text reaches the shell.
        self.ex("tabnew | call term_start(['/bin/sh'], {'curwin': 1})")
        self.send("i")
        self.assertEqual("t", self.expr("mode()"))
        self.click(60)
        self.assertIn("'path'", self.menu("Copy File Path", "tl")["rhs"])
        self.key("End", "Up", "Up", "Up", "Return")
        self.assertEqual("t", self.expr("mode()"))
        self.send("<C-W>N")
        self.ex("call job_stop(term_getjob(bufnr()))")
        self.send("<Esc>")

        self.ex("PlanetNativeTabs off")
        self.assertEqual("0", self.expr("get(g:, 'PV_native_tabs_active', 0) ? 1 : 0"))
        self.ex("PlanetNativeTabs on")
        self.assertEqual("enabled", self.expr("g:PV_native_tabs_status"))
        self.click(60)
        self.assertTrue(self.menu("Close Tab"))
        self.key("Escape")
        self.assertEqual("", self.expr("v:errmsg"))


if __name__ == "__main__":
    unittest.main()
