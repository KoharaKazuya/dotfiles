if builtin command -v git-lfs >/dev/null 2>&1; then
  git lfs pre-push "$@"
fi
