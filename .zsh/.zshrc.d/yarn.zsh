# npm をラップ
if builtin command -v yarn >/dev/null; then
  alias npm=yarn-npm-wrapper
fi
