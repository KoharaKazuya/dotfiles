# 全コミットファイル中、見えない文字 (ゼロ幅スペースなど) が含まれていないかチェックする
if ! added_text_by_commit | detect-invisible-chars; then
  warn 'コミットに不可視文字 (ゼロ幅スペースなど) が含まれます'
  show_ignore_variable
  false
fi
