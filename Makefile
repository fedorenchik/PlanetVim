help:

SHELL := /bin/bash

.NOTPARALLEL:

FILES := \
	.bashrc \
	.ctags \
	.cvsignore \
	.gdbinit \
	.gitconfig \
	.git-prompt.sh \
	.inputrc \
	.local/share/applications/GVim-homerc.desktop \
	.profile \
	.signature \
	tpl/ \
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

# workaround for bugs
c_headers := $(filter-out float iso646 stdalign stdarg stdatomic stdbool stddef stdnoreturn threads,$(c_headers))

c_headers := $(addprefix /usr/include/,$(addsuffix .h,$(c_headers)))

~/.vim/ctags: $(c_headers)
	-ctags --language-force=c -R -f $@ $^

~/.vim/linuxtags: /usr/include/linux
	-ctags --language-force=c -R -f $@ $^

~/.vim/cxxtags: $(firstword $(shell echo $$(gcc -E -v -x c++ /dev/null 2>&1 | sed -e '1,/#include </d' -e '/^End/,$$d')))
	@echo $(firstword $(shell echo $$(gcc -E -v -x c++ /dev/null 2>&1 | sed -e '1,/#include </d' -e '/^End/,$$d')))
	-ctags --language-force=c++ -R -f $@ $^

gen-all-ctags: ~/.vim/ctags  ~/.vim/linuxtags ~/.vim/cxxtags

sync-home: sync-files gen-all-ctags

sync-files:
	for file in $(FILES); do $(RSYNC) $(RSYNC_OPTIONS) $$file $(HOME)/$$file; done
	vim -c 'helptags ALL' -c 'q'
	#vim -c 'runtime spell/cleanadd.vim' -c 'q'

commit:
	git submodule sync --recursive
	git submodule update --recursive --remote --init
	git add $(FILES) Makefile package-list README.md
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
.PHONY: gen-all-ctags sync-files
