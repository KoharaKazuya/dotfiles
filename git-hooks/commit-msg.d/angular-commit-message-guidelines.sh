# オプションでチェックが無効化されている場合は終了
if [ "$(git config private.angular-commit-message-guidelines)" = "false" ]; then
  exit 0
fi

# Git コマンド自体が自動生成するコミットメッセージに関しては無視するように
if cat "$1" | head -n1 | grep -E '^(Merge|Revert|fixup!) ' >/dev/null 2>&1; then
  exit 0
fi

# 共通コミットメッセージフォーマットチェック
format_regexp='^(build|ci|docs|feat|fix|perf|refactor|style|test)(\(.*\))?: .*$'
if cat "$1" | head -n1 | grep -vE "$format_regexp" >/dev/null 2>&1; then
  exec >&2
  yellow="$(tput setaf 3)"
  rev="$(tput rev)"
  reset="$(tput sgr0)"
  echo ''
  echo "$yellow$rev WARN $reset$yellow コミットメッセージのフォーマットが不正です$reset"
  echo ''
  echo '  Angular Commit Message Guidelines に従ってコミットメッセージを作成してください'
  echo '  https://github.com/angular/angular/blob/master/CONTRIBUTING.md#commit'
  echo ''
  echo '  コミットメッセージのチェックを無効にする場合は `git config private.angular-commit-message-guidelines false` を実行してください'
  echo ''
  exit 1
fi
