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

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
	source /etc/profile.d/vte-2.91.sh
fi

[[ -f /usr/share/bash-completion/completions/git ]] && . /usr/share/bash-completion/completions/git

source ~/.git-prompt.sh

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

ATTR_PREFIX='\[\e['
ATTR_SUFFIX='m\]'
ATTR_SEPARATOR=';'

ATTR_RESET='0'
ATTR_BOLD='1'
ATTR_UNDERLINED='4'

ATTR_DEFAULT='39'
ATTR_BLACK='30'
ATTR_RED='31'
ATTR_GREEN='32'
ATTR_YELLOW='33'
ATTR_BLUE='34'
ATTR_MAGENTA='35'
ATTR_CYAN='36'
ATTR_LIGHT_GRAY='37'
ATTR_DARK_GRAY='90'
ATTR_LIGHT_RED='91'
ATTR_LIGHT_GREEN='92'
ATTR_LIGHT_YELLOW='93'
ATTR_LIGHT_BLUE='94'
ATTR_LIGHT_MAGENTA='95'
ATTR_LIGHT_CYAN='96'
ATTR_WHITE='97'

ATTR_BG_DEFAULT='49'
ATTR_BG_BLACK='40'
ATTR_BG_RED='41'
ATTR_BG_GREEN='42'
ATTR_BG_YELLOW='43'
ATTR_BG_BLUE='44'
ATTR_BG_MAGENTA='45'
ATTR_BG_CYAN='46'
ATTR_BG_LIGHT_GRAY='47'
ATTR_BG_DARK_GRAY='100'
ATTR_BG_LIGHT_RED='101'
ATTR_BG_LIGHT_GREEN='102'
ATTR_BG_LIGHT_YELLOW='103'
ATTR_BG_LIGHT_BLUE='104'
ATTR_BG_LIGHT_MAGENTA='105'
ATTR_BG_LIGHT_CYAN='106'
ATTR_BG_WHITE='107'

COLOR_RESET=${ATTR_PREFIX}${ATTR_RESET}${ATTR_SUFFIX}
C_R=$COLOR_RESET
COLOR_YELLOW=${ATTR_PREFIX}${ATTR_YELLOW}${ATTR_SUFFIX}
C_Y=$COLOR_YELLOW
COLOR_MAGENTA=${ATTR_PREFIX}${ATTR_MAGENTA}${ATTR_SUFFIX}
C_M=$COLOR_MAGENTA
COLOR_BOLD_GREEN=${ATTR_PREFIX}${ATTR_BOLD}${ATTR_SEPARATOR}${ATTR_GREEN}${ATTR_SUFFIX}
C_B_G=$COLOR_BOLD_GREEN
COLOR_BOLD_BLUE=${ATTR_PREFIX}${ATTR_BOLD}${ATTR_SEPARATOR}${ATTR_BLUE}${ATTR_SUFFIX}
C_B_B=$COLOR_BOLD_BLUE
COLOR_BOLD_LIGHT_YELLOW=${ATTR_PREFIX}${ATTR_BOLD}${ATTR_SEPARATOR}${ATTR_LIGHT_YELLOW}${ATTR_SUFFIX}
C_B_L_Y=$COLOR_BOLD_LIGHT_YELLOW

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWUPSTREAM="verbose name git"
GIT_PS1_DESCRIBE_STYLE="branch"
GIT_PS1_SHOWCOLORHINTS=1

function prompt_command()
{
	__git_ps1 "${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+(${VIRTUAL_ENV##*/})}$C_B_G\u@\h!\l$C_R:$C_B_B\w$C_R " " \n $C_Y{\j}$C_R $C_M\t$C_R [\$?] \\\$ " "<%s>"
}

function prompt_command_vte()
{
	__git_ps1 "${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+(${VIRTUAL_ENV##*/})}$C_B_G\u@\h!\l$C_R:$C_B_B\w$C_R " " \n $C_Y{\j}$C_R $C_M\t$C_R [\$?] \\\$ " "<%s>"
	VTE_PWD_THING="\[$(__vte_prompt_command)\\\]"
	PS1="$PS1$VTE_PWD_THING"
}

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
	PROMPT_COMMAND=prompt_command_vte
else
	PROMPT_COMMAND=prompt_command
fi

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

# argument can be 'c' or 'c++'
gcc_include_search()
{
	echo $(gcc -E -v -x "$1" /dev/null 2>&1 | sed -e '1,/#include </d' -e '/^End/,$d')
}

if [ -d ~/.local/bin ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

# python virtualenv
export VIRTUAL_ENV_DISABLE_PROMPT=1
export WORKON_HOME=~/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh
