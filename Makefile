help:

SHELL := /bin/bash

.NOTPARALLEL:

FILES := \
	.bashrc \
	.cvsignore \
	.gdbinit \
	.gitconfig \
	.gvimrc \
	.signature \
	.signature-work \
	templ/ \
	.vim/ \
	.vimrc

DELETED_FILES :=

RSYNC := rsync

# TODO: add --delete-after to RSYNC_OPTIONS;
# TODO: current problem is: delete git-ignored files is error
# TODO: rsync git metadata files is error
RSYNC_OPTIONS := -a --delete-missing-args

local-files := $(foreach file,$(FILES) $(DELETED_FILES),$(HOME)/$(file))

all: help

help:
	@echo sync       -- update now
	@echo push      -- push changes to remote
	@echo pull      -- pull changes from remote to local
	@echo install   -- set up cron automatically
	@echo uninstall -- remove cron script
	@echo help      -- this help

sync: sync-home

sync-home:
	for file in $(FILES); do $(RSYNC) $(RSYNC_OPTIONS) $$file $(HOME)/$$file; done

push:
	git add $(FILES) Makefile package-list
ifneq "$(DELETED_FILES)" ""
	git rm --ignore-unmatch -- $(DELETED_FILES)
endif
	git commit -a -m 'Automatic commit at $(shell LC_ALL=C date)' || echo "Nothing to commit"
	git push

pull:
	git pull --ff-only

install:
	{ crontab -l; echo "*/10 * * * * make -C $(PWD) cycle > /tmp/homerc.out"; } | crontab -

uninstall:
	@echo "Run crontab -e and remove the rule manually."

cycle: push pull sync-home
	notify-send --urgency=low --icon=terminal "homerc" "Updated"
