# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

set -o vi

ulimit -c unlimited

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
shopt -s globstar

[[ -f /usr/share/bash-completion/completions/git ]] && . /usr/share/bash-completion/completions/git

source ~/.git-prompt.sh

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\$ '

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWUPSTREAM="verbose name git"
GIT_PS1_DESCRIBE_STYLE="branch"
GIT_PS1_SHOWCOLORHINTS=1

PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h!\l\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]" "\n\[\e[33m\]{\j}\[\em\] \[\e[35m\]\t\[\e[m\] [\$?] \\\$ " " (%s)"'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias ll='ls -lh'
alias la='ls -A'
alias l='ls'
complete -F _longopt l
alias b=exit
alias f='nautilus .'
alias g=git
complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

lh()
{
	if [ "$*" == "" ]; then
		ls -d .*
	else
		for i in "$@"; do
			if [ -d "$i" ]; then
				ls -d "$i"/.*
			elif [ -f "$i" ]; then
				ls "$i"
			else
				ls "$i"
			fi
		done
	fi
}

e()
{
	gvim "$@" 2>>/tmp/gvim.out
}

r()
{
	gvim -M -R -i NONE "$@" 2>>/tmp/gvim.out
}

S()
{
	gvim --cmd 'let g:vimrc_auto_session=1' "$@" 2>>/tmp/gvim.out
}

gitv()
{
	if [ ! -e '.git' ]; then
		echo "Not a git repository."
		return 1
	fi
	if [ -d '.git' ]; then
		gvim -c "Gitv $@" .git/index 2>>/tmp/gvim.out
	elif [ -f '.git' ]; then
		gvim -c "Gitv $@" .git 2>>/tmp/gvim.out
	else
		echo "Not a git repository."
	fi
}

magit()
{
	gvim -c MagitOnly "$@"
}

gk()
(
	if [ "$*" == "" ]; then
		command gitk --all &
	else
		command gitk "$@" &
	fi
)
complete -o bashdefault -o default -o nospace -F __git_wrap__gitk_main gk

dirdiffv()
{
	gvim -c "DirDiff $@" 2>>/tmp/gvim.out
}

vess()
{
	declare cmd=$(dirname $(dirname $(which vim)))/share/vim/vim80/macros/less.sh
	$cmd "$@"
}

export GTAGSFORCECPP=
if [ -d ~/.local/bin ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

export PATH="/home/leonid/.local/opt/anaconda3/bin:$PATH"
