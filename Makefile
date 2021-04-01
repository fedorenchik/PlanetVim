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

help:
	@echo push      -- push changes to remote
	@echo pull      -- pull changes from remote to local
	@echo install   -- update files now
	@echo uninstall -- TODO
	@echo help      -- this help

install:
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

uninstall:
	@echo "TODO: Not implemented."

all: commit pull push install
	notify-send --urgency=low --icon=terminal "homerc" "Updated"

.PHONY: all help commit push pull install uninstall
