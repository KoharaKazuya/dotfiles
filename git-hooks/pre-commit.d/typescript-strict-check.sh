# 変更したファイルが所属するディレクトリを再起的に上からたどり、tsconfig.json があるディレクトリで tsc を実行する
root="$PWD"
(echo .; changed_files_by_commit | sed -En -e ':loop' -e 's%/[^/]+$%%p;t loop' | sort | uniq) | while read line; do
  if cd "$root" && cd "$line" >/dev/null 2>&1; then
    if [ -f tsconfig.json ]; then
      if ! npx --no-install tsc --help >/dev/null 2>&1; then
        warn 'TypeScript がインストールされておらず tsc が実行できません'
        show_ignore_variable
        false
      fi
      # 設定が strict: true でない場合のみ実行する (strict: true の場合は通常のビルド時にチェックされるため)
      if ! (npx --no-install tsc --showConfig | grep '"strict": true' >/dev/null); then
        if ! builtin command -v reviewdog >/dev/null 2>&1; then
          warn 'TypeScript の部分的な型チェックに必要な reviewdog がインストールされていません'
          show_ignore_variable
          false
        fi
        if ! (npx --no-install tsc --strict --noEmit | reviewdog -f=tsc -diff="git diff --cached" -fail-on-error); then
          warn 'TypeScript の厳密な型チェックで不正が発生します'
          show_ignore_variable
          false
        fi
      fi
    fi
  fi
done
