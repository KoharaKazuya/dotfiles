#!/bin/sh

# GIT_HOOKS_DEBUG 変数が定義されていればデバッグ出力
if [ -n "$GIT_HOOKS_DEBUG" ]; then
  set -x
fi

set -eu

# このスクリプトは git hooks スクリプトからシンボリックリンクで参照され、
# シンボリックリンクのファイル名によって、xxx.d をロードする

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
changed_files_by_merge() {
  git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD
}

# ファイル名と同名のディレクトリ (ローカル版も含め) 中身を全て読み込む
for f in "$0.d"/*.sh "$HOME/.config/git/hooks/$(basename "$0").d"/*.sh; do
  varname="$(basename "$f" | sed -E 's/^/GIT_HOOKS_IGNORE_&/;s/\.sh//;s/-/_/g' | tr '[a-z]' '[A-Z]')"
  # glob にマッチしなかった場合はスキップ
  if [ "$varname" = 'GIT_HOOKS_IGNORE_*' ]; then continue; fi
  # 無視のための変数が定義されていればスキップ
  if eval echo '${'$varname':-}' | grep . >/dev/null 2>&1; then continue; fi
  # ファイルでなければスキップ
  if ! test -f "$f"; then continue; fi
  source "$f"
done
