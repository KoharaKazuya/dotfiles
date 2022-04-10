# 想定しない Unicode 文字が含まれていないかチェックする
if ! changed_files_by_merge | detect-unexpected-chars; then
  info 'おそらく想定外の Unicode 文字を含むファイルが見つかりました'
  echo '  NFD/NFC やゼロ幅スペースなどの想定外の文字が含まれていないか確認してください'
  echo '  https://util.unicode.org/UnicodeJsps/character.jsp'
  echo ''
fi
