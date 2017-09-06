if changed_files_by_merge | grep -E '(^|/)package\.json$' >/dev/null 2>&1; then
  printf '\e[33m%s\e[0m\n' 'package.json に変更があります。npm install を実行して下さい' >&2
fi
