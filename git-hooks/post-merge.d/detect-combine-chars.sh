if builtin command -v ruby                 >/dev/null 2>&1 && \
   builtin command -v detect-combine-chars >/dev/null 2>&1; then
  # Unicode 合字, NFC/NFD 混在 (Mac 濁点ファイル名問題) がないか調べる
  if ! changed_files_by_merge | detect-combine-chars; then
    printf '\e[33;1m%s\e[0m\n' 'Unicode 合字を含むファイルが見つかりました' >&2
  fi
fi
