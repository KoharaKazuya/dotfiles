# Git コマンド自体が自動生成するコミットメッセージに関しては無視するように
if ! (cat "$1" | head -n1 | grep -E '^(Merge|Revert|fixup!|squash!) ' >/dev/null 2>&1); then
  # リリースのためのコミットは無視するように
  if ! (cat "$1" | head -n1 | grep -E '^v[0-9]+(.[0-9]+)*' >/dev/null 2>&1); then
    # 共通コミットメッセージフォーマットチェック
    format_regexp='^(build|ci|docs|feat|fix|perf|refactor|style|test)(\(.*\))?!?: .*$'
    if cat "$1" | head -n1 | grep -vE "$format_regexp" >/dev/null 2>&1; then
      exec >&2
      warn 'コミットメッセージのフォーマットが不正です'
      echo '  Conventional Commits に従ってコミットメッセージを作成してください'
      echo '  https://www.conventionalcommits.org/ja/v1.0.0/'
      echo ''
      show_ignore_variable
      info 'コミットメッセージガイド'
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
      false
    fi
  fi
fi
