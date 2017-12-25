# 全コミットファイル中、Unicode 合字 (濁点文字など) が含まれていないかチェックする
if changed_files_by_commit | grep -E '.' >/dev/null 2>&1; then
  changed_files_by_commit | xargs -I{} sh -c 'f="{}"; if file "$f" | grep -i text >/dev/null 2>&1; then cat "$f" | detect-combine-chars || (printf "\e[33;1m%s\e[0m\n" "Unicode 合字が見つかりました: $f" >&2; false); fi'
fi
