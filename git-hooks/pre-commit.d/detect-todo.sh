if [ "${GIT_HOOKS_IGNORE_TODO-}" = "" ] && git diff --cached --unified=0 | grep '^\+' | grep -iE 'todo|fixme' >/dev/null 2>&1; then
  exec >&2
  yellow="$(tput setaf 3)"
  rev="$(tput rev)"
  reset="$(tput sgr0)"
  echo ''
  echo "$yellow$rev WARN $reset$yellow コミットに TODO もしくは FIXME が含まれます$reset"
  echo ''
  git grep --cached -iE 'todo|fixme' | sed -E 's/^/  &/'
  echo ''
  exit 1
fi
