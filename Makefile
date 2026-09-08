PYTHON ?= python3
PREFIX ?=
export PLANETVIM_PREFIX = $(PREFIX)

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

.PHONY: all help install install-home install-private update preview preview-home preview-private uninstall restore test test-gui
