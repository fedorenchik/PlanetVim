PYTHON ?= python3
PREFIX ?=
export PLANETVIM_PREFIX = $(PREFIX)

.DEFAULT_GOAL := help
.NOTPARALLEL:

help:
	@echo 'install    Install in a private directory (PREFIX=path optional)'
	@echo 'update     Update the private installation, retaining backups'
	@echo 'preview    Show installation changes without writing destination files'
	@echo 'uninstall  Remove owned files; preserve local modifications'
	@echo 'restore    Undo the most recent install, update, or uninstall'
	@echo 'test       Run the distribution tests'
	@echo 'test-gui   Run Vimscript checks in GVim (requires a display)'

install update uninstall restore:
	$(PYTHON) scripts/install.py $@

preview:
	$(PYTHON) scripts/install.py install --dry-run

test:
	$(PYTHON) -m unittest discover -s tests -p 'test_*.py'
	$(PYTHON) scripts/test.py

test-gui:
	$(PYTHON) scripts/test.py --gui

all: install

.PHONY: all help install update preview uninstall restore test test-gui
