if ! (changed_files_by_commit | typescript-partial-strict-check); then
  exec >&2
  yellow="$(tput setaf 3)"
  rev="$(tput rev)"
  reset="$(tput sgr0)"
  printf "\n$yellow$rev WARN $reset$yellow %s$reset\n\n" 'TypeScript の厳密な型チェックで不正が発生します'
  show_ignore_variable
  exit 1
fi
