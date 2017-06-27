if command -v go >/dev/null; then
  GOPATH="$HOME/go"
  GOROOT="$(go env GOROOT)"
fi
