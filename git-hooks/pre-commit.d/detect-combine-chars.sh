# 全コミットファイル中、Unicode 合字 (濁点文字など) が含まれていないかチェックする
if ! added_text_by_commit | detect-combine-chars; then
  warn 'コミットに Unicode 合字が含まれます'
  show_ignore_variable
  false
fi
