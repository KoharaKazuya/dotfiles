# パス設定
typeset -U path
path=(
    $HOME/bin
    $HOME/projects/dotfiles/bin
    $path
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
