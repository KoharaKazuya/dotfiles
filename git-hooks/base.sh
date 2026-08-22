#!/bin/sh
#
# git hooks の共通ランナー。
#
# 各フック名 (pre-commit など) はこのファイルへのシンボリックリンクであり、
# 呼ばれたシンボリックリンクの名前から <フック名>.d/*.sh を読み込む。
# core.hooksPath 経由でグローバルに呼ばれることを想定している。
#
# 設計方針:
#   - グローバルに効くフックは「どこでも欲しい安全網」だけに絞る。
#     プロジェクト規約 (コミットメッセージ形式など) は CI に、
#     作業リマインダは linter やエディタに置く。
#   - チェックは互いに独立させる。1 つが落ちても残りは必ず実行する。
#   - POSIX sh (dash) で動くこと。bash/zsh 専用の構文は使わない。
#
# ここで定義するヘルパ関数は <フック名>.d/*.sh から呼ばれるため、
# 静的解析からは到達不能に見える
# shellcheck disable=SC2317

# 再帰的に呼び出されてループすることを防ぐ
# (以前の設定で ~/projects/git-hooks に向けてシンボリックリンクを
# 設定していたことがあり、その環境のままのリポジトリでは、
# このスクリプトを再帰的に呼び出す可能性があるため検知して停止する)
[ -n "${GIT_HOOKS_LOOP_DETECT:-}" ] && exit 0

# GIT_HOOKS_DEBUG 変数が定義されていればデバッグ出力
if [ -n "${GIT_HOOKS_DEBUG:-}" ]; then
  set -x
fi

set -u

# 各種変数
HOOK_NAME=$(basename "$0")
# $0 はシンボリックリンクのパス (例: ~/projects/dotfiles/git-hooks/pre-commit)。
# readlink -f は macOS の古い版に無いので使わず、リンク自体の位置から辿る
HOOKS_DIR=$(unset CDPATH; cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_DIR=$(unset CDPATH; cd -- "$HOOKS_DIR/.." && pwd)
# bin を PATH に足しておく (フックは GUI クライアントから PATH の通っていない
# 環境で呼ばれることがあるため、シェルの設定には依存できない)
PATH="$DOTFILES_DIR/bin:$PATH"
export PATH
# .git はワークツリーやサブモジュールではファイルなので、
# ディレクトリを直接組み立てず git に解決させる
GIT_COMMON_DIR=$(git rev-parse --git-common-dir)
LOCAL_HOOK="$GIT_COMMON_DIR/hooks/$HOOK_NAME"

# 基本関数を定義する
#
# 元ネタは hookin コマンド
# @see http://yosuke-furukawa.hatenablog.com/entry/2014/03/31/125131

changed_files_by_commit() {
  case "$HOOK_NAME" in
    pre-commit  ) git diff --cached --name-only;;
    post-commit ) git diff --name-only HEAD~;;
    *           ) return 1;;
  esac
}
changed_files_by_merge() {
  git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD
}
show_ignore_variable() {
  printf 'このチェックを無効化するには以下のように環境変数を設定してください\n\n  $ %s=1 git %s ...\n\n' \
    "$IGNORE_VARNAME" "$(echo "$HOOK_NAME" | sed 's/^pre-//;s/^post-//;s/-msg$//')"
}

# ログ出力関数を定義する
info() {
  rev=$(    tput rev     2>/dev/null || : )
  reset=$(  tput sgr0    2>/dev/null || : )
  printf "\n$rev INFO $reset %s\n\n" "$*" >&2
}
warn() {
  yellow=$( tput setaf 3 2>/dev/null || : )
  rev=$(    tput rev     2>/dev/null || : )
  reset=$(  tput sgr0    2>/dev/null || : )
  printf "\n$yellow$rev WARN $reset$yellow %s$reset\n\n" "$*" >&2
}
error() {
  red=$(    tput setaf 1 2>/dev/null || : )
  rev=$(    tput rev     2>/dev/null || : )
  reset=$(  tput sgr0    2>/dev/null || : )
  printf "\n$red$rev ERROR $reset$red %s$reset\n\n" "$*" >&2
}

# ファイル名と同名のディレクトリ (ローカル版も含め) の中身を全て読み込む。
#
# 各チェックはサブシェルで実行し、1 つが失敗しても残りを必ず実行する。
# (以前は同一シェルに source していたため、アルファベット順で先に来る
#  チェックが落ちると後続のチェックが丸ごと飛んでいた)
failed=0
for f in "$HOOKS_DIR/$HOOK_NAME.d"/*.sh "$HOME/.config/git/hooks/$HOOK_NAME.d"/*.sh; do
  # glob にマッチしなかった場合はスキップ
  [ -f "$f" ] || continue

  IGNORE_VARNAME=$(basename "$f" | sed -E 's/^/GIT_HOOKS_IGNORE_&/;s/\.sh$//;s/-/_/g' | tr '[:lower:]' '[:upper:]')
  # 無視のための変数が定義されていればスキップ
  if [ -n "$(eval "printf '%s' \"\${$IGNORE_VARNAME:-}\"")" ]; then continue; fi

  export IGNORE_VARNAME
  # shellcheck disable=SC1090
  if ! ( set -e; . "$f" ); then
    failed=1
  fi
done

# 同名のスクリプトがリポジトリ自体に存在するなら、そのファイルを実行する
# (このファイルは core.hooksPath の設定によりグローバルに呼ばれるため、
#  リポジトリ固有の .git/hooks は git から無視されてしまう。その代替)
if [ -x "$LOCAL_HOOK" ]; then
  if ! GIT_HOOKS_LOOP_DETECT=1 "$LOCAL_HOOK" "$@"; then
    failed=1
  fi
fi

exit "$failed"
