# General Settings
export EDITOR="vim"
export HISTSIZE=200000
export PACKAGER="Matthew Valentine-House <matt@eightbitraptor.com>"

git_push_set_upstream(){
  git push --set-upstream origin `parse_git_branch_no_brackets`
}
parse_git_branch_no_brackets() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
dockerfiles() {
  if [ "$1" == "ls" ]; then
    ls $HOME/dockerfiles
  else
    cd "$HOME/dockerfiles/$1/"
  fi
}
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1] /'
}

# Prompt

PROMPT_DIRTRIM=2

P_USERNAME=$(whoami)
P_HOSTNAME=$(hostname -s)
CURRENT_DATE="\D{%T}"

BOLD_BLUE="\\[\033[01;34m\]"
BLUE="\\[\033[00;34m\]"
YELLOW="\\[\033[00;33m\]"
BOLD_CYAN="\\[\033[01;36m\]"
CYAN="\\[\033[00;36m\]"
LIGHT_RED="\\[\033[01;31m\]"
RESET="\\[\033[0m\]"

export PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007"'
export PS1="$YELLOW$CURRENT_DATE $LIGHT_RED\$(parse_git_branch)$RESET$BLUE($P_USERNAME@$P_HOSTNAME)$BOLD_BLUE \w $YELLOW% $RESET"
export CLICOLOR=1
export LSCOLORS=gxFxCxDxBxegedabagacad

export PATH=/snap/bin:/Users/mattvh/bin:/Users/mattvh/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin


umask 0022
shopt -s histappend

if [[ $- == *i* ]]; then
  stty stop ''
  stty start ''
  stty -ixon
  stty -ixoff
fi

_dockerfiles_comp() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "`ls $HOME/dockerfiles`") $cur)
}
complete -F _dockerfiles_comp dockerfiles

# Aliases

alias d=docker
alias dc=docker-compose

alias emacs='emacsclient -n'

alias tra='transmission-remote'

alias ls='ls -G'
alias ll="ls -lah"
alias lt="ls -lahtr"
alias lls="ls -laShr"
alias lsd='ls -l | grep ^d'

alias t=tmux
alias ta='tmux attach'

alias gpsu='git_push_set_upstream'
alias grm='git fetch && git rebase origin/master'
alias grim='git fetch && git rebase --interactive origin/master'
alias gpf='git push --force-with-lease'
alias gco='git checkout'

alias be='bundle exec'
alias bi='bundle check || bundle install'

alias j=jobs

for project in ~/code/{futurelearn,projects}/*; do
  alias `basename $project`="cd $project"
done

# External Libraries

if [[ -f ~/.secret_env ]]; then
   . ~/.secret_env
fi

# load dev, but only if present and the shell is interactive
if [[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]]; then
  source /opt/dev/dev.sh
fi

eval "$(direnv hook bash)"

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

[[ -f /opt/dev/dev.sh ]] && . /opt/dev/dev.sh
