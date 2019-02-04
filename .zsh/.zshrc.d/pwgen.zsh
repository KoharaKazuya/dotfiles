if echo "$OSTYPE" | grep -E '^darwin' >/dev/null && builtin command -v pwgen >/dev/null; then
  pwgen16() {
    pwgen --ambiguous --capitalize 16 1 | tr -d '\n' | pbcopy
  }
fi
