if builtin command -v git-secrets >/dev/null 2>&1; then
  git secrets --pre_commit_hook -- "$@"
fi
