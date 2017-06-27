if command -v go >/dev/null; then
  export GOPATH="$HOME/go"
  export GOROOT="$(go env GOROOT)"
  export PATH="$GOPATH/bin:$PATH"
fi
