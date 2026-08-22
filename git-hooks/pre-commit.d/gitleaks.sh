# 秘匿情報の混入検出。
#
# gitleaks は既定のルールセットを内蔵しているので追加設定が要らない。

if command -v gitleaks >/dev/null 2>&1; then
  # v8.19 以降は `gitleaks git`、それ以前は `gitleaks protect`
  if gitleaks git --help >/dev/null 2>&1; then
    gitleaks git --staged --no-banner --redact
  else
    gitleaks protect --staged --no-banner --redact
  fi
fi
