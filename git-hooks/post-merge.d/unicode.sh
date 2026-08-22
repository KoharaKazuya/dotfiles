# 取り込んだコードに対する Trojan Source 検査。
#
# Trojan Source の主たる経路は「自分が書く」ことではなく
# 「他人のコードを取り込む・レビューする」ことなので、こちら側の検査が本命。
# ただし merge は既に完了しているため、止めずに警告のみ行う。
# 強制力を持たせられるのは対象のリポジトリ側だけなので、ここは警告に留める。

scan_rc=0
if command -v git-scan-unicode >/dev/null 2>&1 &&
   git rev-parse --verify --quiet ORIG_HEAD >/dev/null; then
  git-scan-unicode --warn-only ORIG_HEAD..HEAD || scan_rc=$?
fi

# 検査を実行できなかった場合 (rc >= 3) は post-merge では黙る。
# 事後の警告でしかないため、ここで騒いでも打つ手がない
if [ "$scan_rc" -eq 1 ] || [ "$scan_rc" -eq 2 ]; then
  warn '取り込んだ差分におそらく想定外の Unicode 文字が含まれます'
  echo '  マージは既に完了しています。内容を確認してください' >&2
  echo '  再確認: git scan-unicode ORIG_HEAD..HEAD' >&2
  echo '  https://trojansource.codes/' >&2
  echo '' >&2
fi
