# Defined via `source`
function grim --wraps='git rebase -i master' --description 'alias grim=git rebase -i master'
  git rebase -i master $argv; 
end
