if changed_files_by_merge | grep -E '(^|/)composer\.json$' >/dev/null 2>&1; then
  info 'composer.json に変更があります。composer install を実行して下さい'
fi
