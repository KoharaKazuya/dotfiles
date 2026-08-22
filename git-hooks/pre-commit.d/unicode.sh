# Trojan Source 攻撃 (CVE-2021-42574 / CVE-2021-42694) 対策。
#
# 「人間が読む見た目」と「コンパイラが読む内容」がずれる文字の混入を検出する。
# 自分がコミットする側の検査。取り込む側の検査は post-merge.d/unicode.sh にある。

if ! command -v git-scan-unicode >/dev/null 2>&1; then
  # 「検査器が無い」ことを「危険な文字を検出した」と取り違えないよう、
  # ここは明確に別のメッセージを出す
  error 'git-scan-unicode が見つからないため Unicode 検査を実行できませんでした'
  echo '  これは危険な文字が見つかったという意味ではありません' >&2
  echo '  dotfiles の bin/ が壊れていないか確認してください' >&2
  echo '' >&2
  show_ignore_variable
  false
fi

scan_rc=0
git-scan-unicode --staged || scan_rc=$?

if [ "$scan_rc" -ge 2 ]; then
  warn 'コミットに危険な Unicode 文字が含まれます'
  echo '  上記の文字は表示と実際の内容を食い違わせ、レビューを欺くために使われます' >&2
  echo '  意図しない混入でないか必ず確認してください' >&2
  echo '  https://trojansource.codes/' >&2
  echo '' >&2
  show_ignore_variable
  false
fi
