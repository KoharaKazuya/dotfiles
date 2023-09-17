# 環境依存の設定ファイルを読み込む
[ -f ~/.zprofile.local ] && source ~/.zprofile.local
if [ -f ~/.zprofile.local ]; then
  echo '[DEPRECATED] *.local 系の設定ファイルの読み込みは廃止予定です。$HOME/.config/zsh を使用してください: '"~/.zprofile.local" >&2
  source ~/.zprofile.local
fi
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zprofile" ]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zprofile"
fi
