PYTHON ?= python3
PREFIX ?=
NATIVE_TABS ?= auto
export PLANETVIM_PREFIX = $(PREFIX)
export PLANETVIM_NATIVE_TABS = $(NATIVE_TABS)
NATIVE_TAB_LIBRARY = build/native/planetvim-tabmenu.so

.DEFAULT_GOAL := help
.NOTPARALLEL:

help:
	@echo 'install    Install for plain GVim; back up the previous home vimrc (PREFIX=path optional)'
	@echo 'install-home  Install and make plain GVim load PlanetVim via your home vimrc'
	@echo 'install-private  Install only the separate launcher; leave home startup unchanged'
	@echo 'update     Update the private installation, retaining backups'
	@echo 'preview    Show installation changes without writing destination files'
	@echo 'preview-home  Preview private installation and home vimrc changes'
	@echo 'preview-private  Preview installation of only the separate launcher'
	@echo 'uninstall  Remove owned files; preserve local modifications'
	@echo 'restore    Undo the most recent install, update, or uninstall'
	@echo 'test       Run the distribution tests'
	@echo 'test-gui   Run Vimscript checks in GVim (requires a display)'
	@echo 'native-tabs  Build the optional Linux GTK3 tab-menu helper (requires cc, pkg-config, GTK3 headers)'
	@echo 'test-native-tabs  Exercise native GTK mouse events in private Xvfb (also requires xdotool)'
	@echo 'NATIVE_TABS=0 skips native helper installation; =1 requires it; default auto builds when available'

$(NATIVE_TAB_LIBRARY): native/tabmenu.c
	mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -std=c11 -Wall -Wextra -Werror -O2 -fPIC -shared \
	  -Wl,-z,nodelete -Wl,--as-needed $$(pkg-config --cflags gtk+-3.0) $< \
	  -o $@.tmp $(LDFLAGS) $$(pkg-config --libs gtk+-3.0)
	mv -f $@.tmp $@

native-tabs: $(NATIVE_TAB_LIBRARY)

test-native-tabs: native-tabs
	PLANETVIM_NATIVE_GUI=1 $(PYTHON) -m unittest discover -s tests -p test_native_tabs_gui.py

native-tabs-auto:
	@if [ "$(NATIVE_TABS)" = 0 ]; then :; \
	elif [ "$$(uname -s)" = Linux ] && command -v $(CC) >/dev/null 2>&1 && pkg-config --atleast-version=3.14 gtk+-3.0 2>/dev/null; then \
	  $(MAKE) native-tabs; \
	elif [ "$(NATIVE_TABS)" = 1 ]; then \
	  echo 'Native tab menus require Linux, a C compiler, pkg-config and GTK3 development headers.' >&2; exit 1; \
	else echo 'Optional GTK tab-menu helper not built; install GTK3 development headers to enable it.'; fi

install update install-home install-private: native-tabs-auto

install update uninstall restore:
	$(PYTHON) scripts/install.py $@

preview:
	$(PYTHON) scripts/install.py install --dry-run

install-home:
	$(PYTHON) scripts/install.py install --default-gvim

preview-home:
	$(PYTHON) scripts/install.py install --default-gvim --dry-run

install-private:
	$(PYTHON) scripts/install.py install --private

preview-private:
	$(PYTHON) scripts/install.py install --private --dry-run

test:
	$(PYTHON) -m unittest discover -s tests -p 'test_*.py'
	$(PYTHON) scripts/test.py

test-gui:
	$(PYTHON) scripts/test.py --gui

all: install

.PHONY: all help install install-home install-private update preview preview-home preview-private uninstall restore test test-gui native-tabs native-tabs-auto test-native-tabs
