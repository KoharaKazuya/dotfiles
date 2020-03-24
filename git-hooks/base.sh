#!/bin/sh

# 再起的に呼び出されてループすることを防ぐ
# (以前の設定で ~/projects/git-hooks に向けてシンボリックリンクを
# 設定していたことがあり、その環境のままのリポジトリでは、
# このスクリプトを再起的に呼び出す可能性があるため検知して停止する)
[ -n "$GIT_HOOKS_LOOP_DETECT" ] && exit 0

# GIT_HOOKS_DEBUG 変数が定義されていればデバッグ出力
if [ -n "$GIT_HOOKS_DEBUG" ]; then
  set -x
fi

set -eu

# このスクリプトは git hooks スクリプトからシンボリックリンクで参照され、
# シンボリックリンクのファイル名によって、xxx.d をロードする

# 各種変数
# @see https://qiita.com/ik-fib/items/55edad2e5f5f06b3ddd1
GIT_ROOT=$(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)
HOOK_NAME=$(basename "$0")
LOCAL_HOOK="$GIT_ROOT/.git/hooks/$HOOK_NAME"

# 基本関数を定義する
#
# 元ネタは hookin コマンド
# @see http://yosuke-furukawa.hatenablog.com/entry/2014/03/31/125131

changed_files_by_commit() {
  case "$0" in
    *pre-commit  ) git diff --cached --name-only;;
    *post-commit ) git diff --name-only HEAD~;;
    *            ) exit 1;;
  esac
}
added_text_by_commit() {
  case "$0" in
    *pre-commit  ) git diff --cached -U0 | sed -n '/^\+\+\+/d;/^\+/s/^\+//p';;
    *            ) exit 1;;
  esac
}
changed_files_by_merge() {
  git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD
}
show_ignore_variable() {
  varname="$(basename "$f" | sed -E 's/^/GIT_HOOKS_IGNORE_&/;s/\.sh//;s/-/_/g' | tr '[a-z]' '[A-Z]')"
  printf 'このチェックを無効化するには以下のように環境変数を設定してください\n\n  $ %s=1 git commit ...\n\n' "$varname"
}

# ファイル名と同名のディレクトリ (ローカル版も含め) 中身を全て読み込む
for f in "$0.d"/*.sh "$HOME/.config/git/hooks/$HOOK_NAME.d"/*.sh; do
  varname="$(basename "$f" | sed -E 's/^/GIT_HOOKS_IGNORE_&/;s/\.sh//;s/-/_/g' | tr '[a-z]' '[A-Z]')"
  # glob にマッチしなかった場合はスキップ
  if [ "$varname" = 'GIT_HOOKS_IGNORE_*' ]; then continue; fi
  # 無視のための変数が定義されていればスキップ
  if eval echo '${'$varname':-}' | grep . >/dev/null 2>&1; then continue; fi
  # ファイルでなければスキップ
  if ! test -f "$f"; then continue; fi
  source "$f"
done

# 同名のスクリプトがリポジトリ自体に存在するなら、そのファイルを読み込む
# (このファイルは core.hooksPath の設定によりグローバルに呼ばれる想定)
if [ -x "$LOCAL_HOOK" ]; then
  GIT_HOOKS_LOOP_DETECT=1 "$LOCAL_HOOK" "$@"
fi
