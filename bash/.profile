export EDITOR="vim"
export HISTSIZE=200000
export PACKAGER="Matthew Valentine-House <matt@eightbitraptor.com>"

# Prompt

PROMPT_DIRTRIM=2
BOLD_BLUE="\\[\033[01;34m\]"
BLUE="\\[\033[00;34m\]"
YELLOW="\\[\033[00;33m\]"
BOLD_CYAN="\\[\033[01;36m\]"
CYAN="\\[\033[00;36m\]"
LIGHT_RED="\\[\033[01;31m\]"
RESET="\\[\033[0m\]"


export PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007"'
export PS1="$LIGHT_RED\$(parse_git_branch)$RESET$CYAN[`whoami`@`hostname -s`]$BOLD_BLUE \w $YELLOW% $RESET"
export CLICOLOR=1
export LSCOLORS=gxFxCxDxBxegedabagacad

export PATH=/Users/mattvh/bin:/Users/mattvh/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin


[[ -s ~/.bashrc ]] && source ~/.bashrc

if [[ -f /opt/dev/dev.sh ]]; then source /opt/dev/dev.sh; fi
