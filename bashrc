# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Defining a function to dynamically check whether the URA mode is set or not.
function check_ura {
    local URA="$(cat ~/.is_ura_on)"

    if [[ "$URA" == "yes" ]] ; then
        local URA="\001\033[1;38;5;160m\002(URA)\001\033[00m\002"
    else
        local URA="\001\033[1;38;5;240m\002(no URA)\001\033[00m\002"
    fi

    echo -e "$URA"
}

# Defining a function to dynamically check whether the global variables related
# to the HTTP proxy are defined or not.
function check_proxy {

    if [[ ! -z "$http_proxy" ]] ; then
        local proxy="\001\033[1;38;5;34m\002(proxy)\001\033[00m\002"
    else
        local proxy="\001\033[1;38;5;240m\002(no proxy)\001\033[00m\002"
    fi

    echo -e "$proxy"
}

### Alternative prompt for remote servers (pseudo-random colors for user and
### host names, so as to differentiate the terminals).
#HOSTNAME_PROMPT="$(print-color "$(hostname)")"
#USERNAME_PROMPT="$(print-color "$(whoami)")"
if [ "$color_prompt" = yes ]; then
    #PS1="\[\n\]\[\r\]${USERNAME_PROMPT}@${HOSTNAME_PROMPT}: \t | \[\033[0;38;5;117m\]\w\[\033[00m\]\[\n\]\[\r\]        |\[\n\]\[\r\]        \[↳\] "
    PS1="\[\n\]\[\r\]\[\033[0;38;5;99m\]\u\[\033[00m\]@\[\033[1;38;5;69m\]\h\[\033[00m\]: \t | \$(check_ura) | \$(check_proxy) | \[\033[0;38;5;117m\]\w\[\033[00m\]\[\n\]\[\r\]        |\[\n\]\[\r\]        \[↳\] "
else
    PS1='${debian_chroot:+(debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.ls_colors && eval "$(dircolors -b ~/.ls_colors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Vim edition mode in Bash! With the AltGr+J key combination remapped to 
# Escape to navigate between normal and insertion modes.
set -o vi
xmodmap -e "keycode  44 = j J j J Escape"
# To revert the mapping, uncomment the below line.
#xmodmap -e "keycode  44 = j J j J dead_hook dead_horn"

# Remapping the keyboard in order to assign œ to AltGr+o and Œ to Shift+AltGr+o.
xmodmap -e "keycode  32 = o O o O oe OE"
# To revert the mapping, uncomment the below line.
#xmodmap -e "keycode  32 = o O o O oslash Oslash"

# Defining the path to the laboratory notebook.
export LAB_NOTEBOOK="${HOME}/.lab_notebook"

# Functions related to the use of the "script" command.
function print_manuscript {
    echo -e "\n##############################################################\n"

    while IFS='' read line || [[ -n "$line" ]] ; do
        echo -e "\t\t#\t${line}"  
    done < "$1"

    echo -e "\n##############################################################\n"
}
