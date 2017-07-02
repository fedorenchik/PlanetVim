help:

SHELL := /bin/bash

.NOTPARALLEL:

FILES := \
	.bashrc \
	.config/terminator/config \
	.ctags \
	.cvsignore \
	.gdbinit \
	.gitconfig \
	.git-prompt.sh \
	.local/share/applications/gvim-local.desktop \
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

all: help

help:
	@echo sync      -- update now
	@echo push      -- push changes to remote
	@echo pull      -- pull changes from remote to local
	@echo install   -- set up cron automatically
	@echo uninstall -- remove cron script
	@echo help      -- this help

sync: sync-home

c_headers := assert complex ctype errno fenv float inttypes iso646 limits \
	locale math setjmp signal stdalign stdarg stdatomic stdbool stddef \
	stdint stdio stdlib stdnoreturn string tgmath threads time uchar \
	wchar wctype

c_headers :=

sync-home:
	cd .vim/pack/bundle/start/vimproc.vim && make
	cd .vim/pack/bundle/opt/gdbmgr.vim/gdbmgr/src && make
	for file in $(FILES); do $(RSYNC) $(RSYNC_OPTIONS) $$file $(HOME)/$$file; done
	vim -c 'helptags ALL' -c 'q'
	ctags -R -f ~/.vim/ctags /usr/include/assert.h
	ctags -R -f ~/.vim/cpptags /usr/include/c++
	ctags -R -f ~/.vim/linuxtags /usr/include/linux

commit:
	git submodule update --recursive --remote --init
	git add $(FILES) Makefile package-list
ifneq "$(DELETED_FILES)" ""
	git rm --ignore-unmatch -- $(DELETED_FILES)
endif
	git commit -a -m 'Automatic commit at $(shell LC_ALL=C date)' || echo "Nothing to commit"

push:
	-git push

pull:
	git pull --ff-only

install:
	{ crontab -l; echo "*/10 * * * * make -C $(PWD) cycle >/tmp/homerc.out 2>&1"; } | crontab -

uninstall:
	@echo "Run crontab -e and remove the rule manually."

cycle: commit pull push sync-home
	notify-send --urgency=low --icon=terminal "homerc" "Updated"
