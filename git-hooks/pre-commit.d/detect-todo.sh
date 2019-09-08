if added_text_by_commit | grep -iE 'todo|fixme'; then
  exec >&2
  yellow="$(tput setaf 3)"
  rev="$(tput rev)"
  reset="$(tput sgr0)"
  printf "\n$yellow$rev WARN $reset$yellow %s$reset\n\n" 'コミットに TODO もしくは FIXME が含まれます'
  show_ignore_variable
  exit 1
fi
