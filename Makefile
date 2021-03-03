help:

SHELL := /bin/bash

.NOTPARALLEL:

FILES := .vim/ .vimrc
RSYNC := rsync

RSYNC_OPTIONS := -aHAX --delete-missing-args --delete-after \
	--exclude='/session/*' \
	--exclude='/undo/*' \
	--exclude='/view/*' \
	--exclude='/viminfo/*' \
	--exclude='/planetvimrc.vim'

all: help

help:
	@echo sync      -- update now
	@echo push      -- push changes to remote
	@echo pull      -- pull changes from remote to local
	@echo install   -- set up cron automatically
	@echo uninstall -- remove cron script
	@echo help      -- this help

sync: sync-home

sync-home: sync-files

sync-files:
	for file in $(FILES); do $(RSYNC) $(RSYNC_OPTIONS) $$file $(HOME)/$$file; done
	vim -c 'helptags ALL' -c 'q'
	#vim -c 'runtime spell/cleanadd.vim' -c 'q'
	#cd $(HOME)/.vim/pack/basic/start/vim-clap && cargo build --release

commit:
	git add $(FILES) Makefile README.md
	git add .vim/pack/
ifneq "$(DELETED_FILES)" ""
	git rm --ignore-unmatch -- $(DELETED_FILES)
endif
	git commit -a -m 'Automatic commit at $(shell LC_ALL=C date)' || echo "Nothing to commit"

push:
	-git push

pull:
	git pull --ff-only

install:
	{ crontab -l; echo "0 */2 * * * make -C $(PWD) cycle >/tmp/homerc.out 2>&1"; } | crontab -

uninstall:
	@echo "Run crontab -e and remove the rule manually."

cycle: commit pull push sync-home
	notify-send --urgency=low --icon=terminal "homerc" "Updated"

.PHONY: all help sync sync-home commit push pull install uninstall cycle
.PHONY: sync-files
