# Trojan Source 攻撃 (CVE-2021-42574 / CVE-2021-42694) 対策。
#
# 「人間が読む見た目」と「コンパイラが読む内容」がずれる文字の混入を検出する。
# 自分がコミットする側の検査。取り込む側の検査は post-merge.d/unicode.sh にある。

scan_rc=0
if command -v git-scan-unicode >/dev/null 2>&1; then
  git-scan-unicode --staged || scan_rc=$?
else
  scan_rc=127
fi

# 検査そのものが実行できなかった場合 (perl が無い、など) と
# 危険な文字を検出した場合を取り違えないよう、別のメッセージを出す
if [ "$scan_rc" -ge 3 ]; then
  error 'Unicode 検査を実行できませんでした'
  echo '  これは危険な文字が見つかったという意味ではありません' >&2
  echo '  git-scan-unicode と perl が使えるか確認してください' >&2
  echo '' >&2
  show_ignore_variable
  false
elif [ "$scan_rc" -ge 2 ]; then
  warn 'コミットに危険な Unicode 文字が含まれます'
  echo '  上記の文字は表示と実際の内容を食い違わせ、レビューを欺くために使われます' >&2
  echo '  意図しない混入でないか必ず確認してください' >&2
  echo '  https://trojansource.codes/' >&2
  echo '' >&2
  show_ignore_variable
  false
fi
