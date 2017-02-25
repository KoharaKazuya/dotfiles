if [ -d "$HOME/.nodebrew" ]; then
  export PATH="$HOME/.nodebrew/current/bin:$PATH"
  fpath=(~/.nodebrew/completions/zsh $fpath)
fi
