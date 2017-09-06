# 全コミットファイル中、Unicode 合字 (濁点文字など) が含まれていないかチェックする
if ! changed_files_by_commit | grep -E '^' >/dev/null 2>&1; then
  changed_files_by_commit | xargs -I{} sh -c 'if file "{}" | grep -i text >/dev/null 2>&1; then cat "{}" | detect-combine-chars || printf "\e[33m%s\e[0m\n" "Unicode 合字が見つかりました: {}" >&2; fi'
fi
