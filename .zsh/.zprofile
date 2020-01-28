# パス設定
typeset -U path manpath
path=(
    $HOME/bin(N-/)
    $HOME/projects/dotfiles/bin
    $path
)
manpath=(
    $HOME/man(N-/)
    $HOME/projects/dotfiles/man
    $manpath
)

# 強調 echo
notice() {
    echo -e "${fg_bold[white]}$*${reset_color}" >&2
}
success() {
    echo -e "${fg_bold[green]}$*${reset_color}" >&2
}
warning() {
    echo -e "${fg_bold[yellow]}$*${reset_color}" >&2
}
error() {
    echo -e "${fg_bold[red]}$*${reset_color}" >&2
    return 1
}


# 環境依存の設定ファイルを読み込む
[ -f ~/.zprofile.local ] && source ~/.zprofile.local
if [ -f ~/.zprofile.local ]; then
  echo '[DEPRECATED] *.local 系の設定ファイルの読み込みは廃止予定です。$HOME/.config/zsh を使用してください: '"~/.zprofile.local" >&2
  source ~/.zprofile.local
fi
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zprofile" ]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zprofile"
fi
