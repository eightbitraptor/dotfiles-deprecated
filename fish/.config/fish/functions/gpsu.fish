# Defined via `source`
function gpsu --wraps='git push -u origin HEAD' --description 'alias gpsu=git push -u origin HEAD'
  git push -u origin HEAD $argv; 
end
