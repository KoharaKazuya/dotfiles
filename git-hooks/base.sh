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
  git diff --cached --name-only
}
changed_files_by_merge() {
  git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD
}

# ファイル名と同名のディレクトリの中身を全て読み込む
for f in "$0.d"/*.sh; do
  if test -f "$f"; then
    source "$f"
  fi
done
# ローカル依存の git-hooks を読み込み
for f in "$HOME/.git-templates/hooks.local/$(basename "$0").d"/*.sh; do
  if test -f "$f"; then
    source "$f"
  fi
done
