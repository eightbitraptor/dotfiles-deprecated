export EDITOR="vim"
export HISTSIZE=200000
export PACKAGER="Matthew Valentine-House <matt@eightbitraptor.com>"

# Prompt

PROMPT_DIRTRIM=2
P_USERNAME=whoami
P_HOSTNAME=$(hostname -s)
P_GIT_BRANCH=$(parse_git_branch)
BOLD_BLUE="\\[\033[01;34m\]"
BLUE="\\[\033[00;34m\]"
YELLOW="\\[\033[00;33m\]"
BOLD_CYAN="\\[\033[01;36m\]"
CYAN="\\[\033[00;36m\]"
LIGHT_RED="\\[\033[01;31m\]"
RESET="\\[\033[0m\]"

export PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007"'
export PS1="$LIGHT_RED\$P_GIT_BRANCH$RESET$BLUE($P_USERNAME@$P_HOSTNAME)$BOLD_BLUE \w $YELLOW% $RESET"
export CLICOLOR=1
export LSCOLORS=gxFxCxDxBxegedabagacad

export PATH=/Users/mattvh/bin:/Users/mattvh/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

[[ -s ~/.bashrc ]] && . ~/.bashrc

[[ -f /opt/dev/dev.sh ]] && . /opt/dev/dev.sh
