# 全コミットファイル中、想定しない Unicode 文字が含まれていないかチェックする
if ! added_text_by_commit | detect-unexpected-chars; then
  warn 'コミットにおそらく想定外の Unicode 文字が含まれます'
  echo '  NFD/NFC やゼロ幅スペースなどの想定外の文字が含まれていないか確認してください'
  echo '  https://util.unicode.org/UnicodeJsps/character.jsp'
  echo ''
  show_ignore_variable
  false
fi
