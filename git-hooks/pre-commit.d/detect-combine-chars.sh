# 全コミットファイル中、Unicode 合字 (濁点文字など) が含まれていないかチェックする
if ! added_text_by_commit | detect-combine-chars; then
  exec >&2
  yellow="$(tput setaf 3)"
  rev="$(tput rev)"
  reset="$(tput sgr0)"
  printf "\n$yellow$rev WARN $reset$yellow %s$reset\n\n" 'コミットに Unicode 合字が含まれます'
  show_ignore_variable
  exit 1
fi
