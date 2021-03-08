if changed_files_by_merge | grep -E '(^|/)package\.json$' >/dev/null 2>&1; then
  info 'package.json に変更があります。npm install を実行して下さい'
fi
