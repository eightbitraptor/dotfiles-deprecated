# General Settings

umask 0022
shopt -s histappend

stty stop ''
stty start ''
stty -ixon
stty -ixoff

_dockerfiles_comp() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "`ls $HOME/dockerfiles`") $cur)
}
complete -F _dockerfiles_comp dockerfiles

function my_emacs {
  local emacs_bin=/usr/local/bin/emacs

  emacsclient "$@" --no-wait || \
    ($emacs_bin --bg-daemon --no-wait && emacsclient "$@" --no-wait)
}

# Aliases

alias d=docker
alias dc=docker-compose

alias emacs=my_emacs

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
