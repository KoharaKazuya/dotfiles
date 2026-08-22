#!/bin/sh
#
# git-hooks と git-scan-unicode の回帰テスト。
#
# フックの不具合は「壊れていることに気づけない」形で起きるため、
# 挙動をテストで固定する。
#
#   $ sh git-hooks/test.sh
#
# 危険な文字はテストファイル自身に直接書かず、8 進エスケープで生成する
# (このリポジトリ自身も CI で走査されるため)。

set -u

HOOKS_DIR=$(unset CDPATH; cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_DIR=$(unset CDPATH; cd -- "$HOOKS_DIR/.." && pwd)
SCAN="$DOTFILES_DIR/bin/git-scan-unicode"
PATH="$DOTFILES_DIR/bin:$PATH"
export PATH

TMPROOT=$(mktemp -d "${TMPDIR:-/tmp}/git-hooks-test.XXXXXX")
trap 'rm -rf "$TMPROOT"' EXIT INT TERM

PASSED=0
FAILED=0

ok()  { PASSED=$((PASSED + 1)); printf '  ok   %s\n' "$1"; }
ng()  { FAILED=$((FAILED + 1)); printf '  FAIL %s\n' "$1"; }
chk() { # chk <説明> <期待終了コード> <実終了コード>
  if [ "$2" = "$3" ]; then ok "$1"; else ng "$1 (expected rc=$2, got rc=$3)"; fi
}

# 危険な文字を 8 進エスケープで生成する
RLO=$(printf '\342\200\256')    # U+202E RIGHT-TO-LEFT OVERRIDE
LRI=$(printf '\342\201\246')    # U+2066 LEFT-TO-RIGHT ISOLATE
PDI=$(printf '\342\201\251')    # U+2069 POP DIRECTIONAL ISOLATE
ZWSP=$(printf '\342\200\213')   # U+200B ZERO WIDTH SPACE
CYRA=$(printf '\320\260')       # U+0430 CYRILLIC SMALL LETTER A
HEART=$(printf '\342\235\244')  # U+2764
VS16=$(printf '\357\270\217')   # U+FE0F VARIATION SELECTOR-16
ROCKET=$(printf '\360\237\232\200')  # U+1F680
KA=$(printf '\343\201\213')     # U+304B HIRAGANA KA
DAKUTEN=$(printf '\343\202\231')     # U+3099 COMBINING VOICED SOUND MARK
JP=$(printf '\346\227\245\346\234\254\350\252\236')  # 日本語
EACUTE=$(printf '\303\251')       # U+00E9 (NFC)
EACUTE_NFD=$(printf 'e\314\201')  # e + U+0301 (NFD)

new_repo() {
  d="$TMPROOT/$1"
  mkdir -p "$d"
  git init -q -b main "$d"
  git -C "$d" config user.email test@example.com
  git -C "$d" config user.name  test
  git -C "$d" config core.hooksPath "$HOOKS_DIR"
  echo "$d"
}

# ---------------------------------------------------------------------------
echo "== git-scan-unicode: 検出 (rc=2 が期待値) =="
# ---------------------------------------------------------------------------
R=$(new_repo scan)
scan_line() { # scan_line <行内容>
  printf '%s\n' "$1" > "$R/f.txt"
  git -C "$R" add f.txt >/dev/null 2>&1
  ( cd "$R" && "$SCAN" --staged --no-color >/dev/null 2>&1 )
  echo $?
}

chk "BiDi RLO U+202E (CVE-2021-42574)"  2 "$(scan_line "access = $RLO // safe")"
chk "BiDi LRI/PDI U+2066/2069"          2 "$(scan_line "if (l != $LRI admin $PDI) {")"
chk "zero width space U+200B"           2 "$(scan_line "let a${ZWSP}b = 1;")"
chk "DEL U+007F"                        2 "$(scan_line "$(printf 'const x = 1;\177')")"

# ---------------------------------------------------------------------------
echo "== git-scan-unicode: 警告のみ (rc=1 が期待値) =="
# ---------------------------------------------------------------------------
chk "homoglyph キリル文字 (CVE-2021-42694)" 1 "$(scan_line "const ${CYRA}dmin = false;")"
chk "NFD 日本語"                            1 "$(scan_line "// ${KA}${DAKUTEN}test")"

# ---------------------------------------------------------------------------
echo "== git-scan-unicode: 誤検知しないこと (rc=0 が期待値) =="
# ---------------------------------------------------------------------------
chk "ASCII のみ"           0 "$(scan_line 'const x = 1; // ok')"
chk "日本語 NFC"           0 "$(scan_line "// $JP のコメント")"
chk "絵文字 + VS16"        0 "$(scan_line "// done ${HEART}${VS16}")"
chk "絵文字"               0 "$(scan_line "// ship it $ROCKET")"
chk "アクセント付き Latin (NFC)" 0 "$(scan_line "// caf${EACUTE} resume")"
chk "アクセント付き Latin (NFD)" 1 "$(scan_line "// caf${EACUTE_NFD} resume")"
chk "CRLF"                 0 "$(scan_line "$(printf 'const x = 1;\r')")"
chk "日本語 + Latin 混在"  0 "$(scan_line "// TODO${JP}")"

# ---------------------------------------------------------------------------
echo "== pre-commit: 実際にコミットを止めること =="
# ---------------------------------------------------------------------------
R=$(new_repo precommit)
printf 'if (l != %s admin %s) {\n' "$LRI" "$PDI" > "$R/evil.c"
git -C "$R" add evil.c
( cd "$R" && git commit -q -m "feat: evil" >/dev/null 2>&1 )
chk "Trojan Source を含むコミットが失敗する" 1 "$?"

printf 'const x = 1;\n' > "$R/good.c"
git -C "$R" rm -q --cached evil.c >/dev/null 2>&1
rm -f "$R/evil.c"
git -C "$R" add good.c
( cd "$R" && git commit -q -m "feat: good" >/dev/null 2>&1 )
chk "健全なコミットは通る" 0 "$?"

# 無効化用の環境変数が効くこと
R=$(new_repo ignorevar)
printf 'if (l != %s admin %s) {\n' "$LRI" "$PDI" > "$R/evil.c"
git -C "$R" add evil.c
( cd "$R" && GIT_HOOKS_IGNORE_UNICODE=1 git commit -q -m "feat: evil" >/dev/null 2>&1 )
chk "GIT_HOOKS_IGNORE_UNICODE で無効化できる" 0 "$?"

# ---------------------------------------------------------------------------
echo "== pre-commit: gitleaks =="
# ---------------------------------------------------------------------------
# gitleaks には git-secrets の --pre_commit_hook のような専用の
# エントリポイントが無く、サブコマンドが v8.19 で変わっている。
# 双方の呼び出しが実際に効くことを固定する。
if command -v gitleaks >/dev/null 2>&1; then
  # 検出されることが確認できている形式 (実在しないダミー)
  AWSKEY=AKIAIOSFODNN7EXAMPLF

  R=$(new_repo gitleaks_secret)
  printf '%s\n' "$AWSKEY" > "$R/cfg.txt"
  git -C "$R" add cfg.txt
  ( cd "$R" && git commit -q -m "feat: cfg" >/dev/null 2>&1 )
  chk "秘匿情報を含むコミットが失敗する" 1 "$?"

  R=$(new_repo gitleaks_clean)
  echo 'int main(void) { return 0; }' > "$R/ok.c"
  git -C "$R" add ok.c
  out=$( cd "$R" && git commit -m "feat: ok" 2>&1 )
  chk "秘匿情報が無ければ通る" 0 "$?"
  # 通常のコミットで gitleaks の情報ログが漏れないこと
  case "$out" in
    *"no leaks found"*) ng "検出が無いときは黙る" ;;
    *)                  ok "検出が無いときは黙る" ;;
  esac
elif [ -n "${REQUIRE_GITLEAKS:-}" ]; then
  # CI ではカバレッジが黙って落ちないよう、スキップを失敗として扱う
  ng "gitleaks がインストールされていない (REQUIRE_GITLEAKS 指定時は必須)"
else
  echo "  skip (gitleaks 未インストール)"
fi

# ---------------------------------------------------------------------------
echo "== post-merge: 取り込んだ差分の「中身」を検査すること =="
# ---------------------------------------------------------------------------
R=$(new_repo postmerge)
echo ok > "$R/base.txt"
git -C "$R" add base.txt
git -C "$R" -c core.hooksPath= commit -q -m "feat: init"
git -C "$R" checkout -q -b attacker
printf 'if (l != %s admin %s) {\n' "$LRI" "$PDI" > "$R/evil.c"
git -C "$R" add evil.c
git -C "$R" -c core.hooksPath= commit -q -m "feat: add"
git -C "$R" checkout -q main
out=$( cd "$R" && git merge --no-ff --no-edit attacker 2>&1 )
case "$out" in
  *Unicode*) ok "マージで入った Trojan Source を検知する" ;;
  *)         ng "マージで入った Trojan Source を検知する (出力: $out)" ;;
esac
# 事後なのでマージ自体は成功していること
if git -C "$R" rev-parse --verify --quiet HEAD >/dev/null; then
  ok "マージ自体は成功する"
else
  ng "マージ自体は成功する"
fi

# ---------------------------------------------------------------------------
echo "== base.sh: リポジトリ固有フックへのフォールバック =="
# ---------------------------------------------------------------------------
R=$(new_repo localhook)
mkdir -p "$R/.git/hooks"
printf '#!/bin/sh\necho LOCAL_HOOK_RAN >&2\n' > "$R/.git/hooks/pre-commit"
chmod +x "$R/.git/hooks/pre-commit"
echo ok > "$R/a.txt"
git -C "$R" add a.txt
out=$( cd "$R" && git commit -m "feat: a" 2>&1 )
case "$out" in
  *LOCAL_HOOK_RAN*) ok "メインワークツリーでローカルフックが動く" ;;
  *)                ng "メインワークツリーでローカルフックが動く" ;;
esac

git -C "$R" worktree add -q "$TMPROOT/localhook-wt" -b wt >/dev/null 2>&1
echo ok2 > "$TMPROOT/localhook-wt/b.txt"
git -C "$TMPROOT/localhook-wt" add b.txt
out=$( cd "$TMPROOT/localhook-wt" && git commit -m "feat: b" 2>&1 )
case "$out" in
  *LOCAL_HOOK_RAN*) ok "リンクされたワークツリーでもローカルフックが動く" ;;
  *)                ng "リンクされたワークツリーでもローカルフックが動く" ;;
esac

# ---------------------------------------------------------------------------
echo "== base.sh: .d を持たないフックもリポジトリ固有フックへ転送すること =="
# ---------------------------------------------------------------------------
# core.hooksPath を設定すると git は .git/hooks を完全に無視する。
# グローバル側にフック名が存在しないと、リポジトリ固有のフックが
# 実行される機会そのものが消える (git lfs install が入れる pre-push など)。
R=$(new_repo forward)
mkdir -p "$TMPROOT/forward-bare" "$R/.git/hooks"
git init -q --bare "$TMPROOT/forward-bare/r.git"
git -C "$R" remote add origin "$TMPROOT/forward-bare/r.git"
for h in pre-push post-checkout post-commit commit-msg; do
  printf '#!/bin/sh\necho FORWARDED_%s >&2\nexit 0\n' "$h" > "$R/.git/hooks/$h"
  chmod +x "$R/.git/hooks/$h"
done
echo ok > "$R/a.txt"
git -C "$R" add a.txt
out=$( cd "$R" && git commit -m "feat: a" 2>&1 )
case "$out" in
  *FORWARDED_commit-msg*) ok "commit-msg が転送される" ;;
  *)                      ng "commit-msg が転送される" ;;
esac
case "$out" in
  *FORWARDED_post-commit*) ok "post-commit が転送される" ;;
  *)                       ng "post-commit が転送される" ;;
esac
out=$( cd "$R" && git push origin main 2>&1 )
case "$out" in
  *FORWARDED_pre-push*) ok "pre-push が転送される (git lfs install 相当)" ;;
  *)                    ng "pre-push が転送される (git lfs install 相当)" ;;
esac
out=$( cd "$R" && git checkout -b another 2>&1 )
case "$out" in
  *FORWARDED_post-checkout*) ok "post-checkout が転送される" ;;
  *)                         ng "post-checkout が転送される" ;;
esac

# ---------------------------------------------------------------------------
echo "== base.sh: 1 つのチェックが落ちても後続が実行されること =="
# ---------------------------------------------------------------------------
R=$(new_repo isolation)
mkdir -p "$HOME/.config/git/hooks/pre-commit.d"
LOCALD="$HOME/.config/git/hooks/pre-commit.d"
printf 'echo FIRST_RAN >&2\nfalse\n'  > "$LOCALD/zz-test-a-fails.sh"
printf 'echo SECOND_RAN >&2\n'        > "$LOCALD/zz-test-b-runs.sh"
echo ok > "$R/a.txt"
git -C "$R" add a.txt
out=$( cd "$R" && git commit -m "feat: a" 2>&1 )
rc=$?
rm -f "$LOCALD/zz-test-a-fails.sh" "$LOCALD/zz-test-b-runs.sh"
case "$out" in
  *SECOND_RAN*) ok "先行チェックの失敗が後続チェックを飛ばさない" ;;
  *)            ng "先行チェックの失敗が後続チェックを飛ばさない" ;;
esac
chk "失敗したチェックがあればコミットは止まる" 1 "$rc"

# ---------------------------------------------------------------------------
printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
