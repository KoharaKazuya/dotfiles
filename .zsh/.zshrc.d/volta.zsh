if [ -d "$HOME/.volta" ] >/dev/null; then
  export VOLTA_HOME="$HOME/.volta"
  path=(
    $VOLTA_HOME/bin(N-/)
    $path
  )
fi
