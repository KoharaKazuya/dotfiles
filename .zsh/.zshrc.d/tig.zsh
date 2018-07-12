if builtin command -v tig >/dev/null; then
  alias t="tig --all"
  alias tig-me="tig --author=$(git config user.name) --no-merges"
fi
