if builtin command -v code >/dev/null 2>&1; then
  # カレントディレクトリを含む VSCode のワークスペースなどを開く
  code-open-project() {
    # カレントディレクトリの絶対パスを取得する
    local curr="$PWD"
    if ! echo "$curr" | grep -E '^/' >/dev/null 2>&1; then
      echo "failed c command for VSCode: $curr is not absolute path" >&2
      return 1
    fi
    # カレントディレクトリから上のパスに向かって検索していく
    while [ "$curr" != "" ]; do
      # VSCode ワークスペース設定が見つかればそれを開く
      for f in "$curr"/*.code-workspace(N); do
        code "$f"
        return 0
      done
      # VSCode ディレクトリ個別設定が見つかればそのディレクトリを開く
      if [ -d "$curr/.vscode" ]; then
        code "$curr"
        return 0
      fi
      # Git リポジトリが見つかればそのディレクトリを開く
      if [ -d "$curr/.git" ]; then
        code "$curr"
        return 0
      fi
      # 探索ディレクトリを上に上がる
      curr="${curr%/*}"
    done
    # ルートパスまで探索して見つからなければ、カレントディレクトリを開く
    code "$PWD"
  }
fi
