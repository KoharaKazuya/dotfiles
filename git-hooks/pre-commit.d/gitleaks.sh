# 秘匿情報の混入検出。
#
# gitleaks は既定のルールセットを内蔵しているので追加設定が要らない。

if command -v gitleaks >/dev/null 2>&1; then
  rc=0
  out=$(gitleaks git --staged --no-banner --redact 2>&1) || rc=$?

  # v8.19 未満には git サブコマンドが無いので protect に切り替える。
  # 先にバージョンを調べる方式だと gitleaks の起動 (約 0.3 秒) が
  # コミットのたびに二重にかかるため、失敗したときだけ切り替える
  if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q 'unknown command'; then
    rc=0
    out=$(gitleaks protect --staged --no-banner --redact 2>&1) || rc=$?
  fi

  # 検出がなければ黙る
  if [ "$rc" -ne 0 ]; then
    [ -z "$out" ] || printf '%s\n' "$out" >&2
    warn 'コミットに秘匿情報が含まれる可能性があります'
    show_ignore_variable
    false
  fi
fi
