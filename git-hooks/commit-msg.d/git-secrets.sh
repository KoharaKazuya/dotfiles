if builtin command -v git-secrets >/dev/null 2>&1; then
  git secrets --commit_msg_hook -- "$@"
fi
