export LFS=/mnt/lfs

case $- in
	*i*) ;;
	*) return;;
esac

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[[ -f /usr/share/bash-completion/completions/git ]] && . /usr/share/bash-completion/completions/git
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

ulimit -c unlimited

HISTTIMEFORMAT="%F %T "
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
shopt -s globstar
shopt -s expand_aliases

source ~/.git-prompt.sh

complete -cf sudo

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

PROMPT_COMMAND=prompt_command

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less
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

# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# argument can be 'c' or 'c++'
gcc_include_search()
{
	echo $(gcc -E -v -x "$1" /dev/null 2>&1 | sed -e '1,/#include </d' -e '/^End/,$d')
}

if [ -d ~/.local/bin ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

VAGRANT_DEFAULT_PROVIDER=libvirt

# python virtualenv
export VIRTUAL_ENV_DISABLE_PROMPT=1
export WORKON_HOME=~/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh

# direnv
eval "$(direnv hook bash)"

export PIP_REQUIRE_VIRTUALENV=true
gpip() {
	PIP_REQUIRE_VIRTUALENV="" pip "$@"
}
