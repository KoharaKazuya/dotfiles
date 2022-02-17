if builtin command -v tig >/dev/null; then
  alias t='f() { local c=$(git config private.t-override); if [ -z "$c" ]; then c="tig --all"; fi; eval "$c" }; f'
  alias tig-me="tig --author=$(git config user.email) --no-merges"
fi
