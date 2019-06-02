# オプションでチェックが無効化されている場合は終了
if [ "$(git config private.angular-commit-message-guidelines)" = "false" ]; then
  exit 0
fi

# Git コマンド自体が自動生成するコミットメッセージに関しては無視するように
if cat "$1" | head -n1 | grep -E '^(Merge|Revert|fixup!|squash!) ' >/dev/null 2>&1; then
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
  echo "$rev INFO $reset コミットメッセージガイド"
  echo ''
  echo '  ユーザーに提供する機能に影響のあるもの'
  echo '    [Header]  feat:               新機能'
  echo '    [Header]  fix:                不具合修正'
  echo '    [Footter] BREAKING CHANGE:    互換性のない変更'
  echo ''
  echo '  ユーザーに影響のないアプリケーションコードの変更'
  echo '    [Header]  perf:               パフォーマンス改善'
  echo '    [Header]  refactor:           機能追加やバグ修正のないコードの変更'
  echo '    [Header]  style:              コードの意味に影響のない変更'
  echo '    [Header]  test:               不足テスト追加もしくは既存テストの修正'
  echo ''
  echo '  アプリケーションコードに関係しない変更'
  echo '    [Header]  build:              ビルドシステムか外部依存に影響する変更'
  echo '    [Header]  ci:                 CI 設定の変更'
  echo '    [Header]  docs:               ドキュメントのみの変更'
  echo ''
  exit 1
fi
