# 言語設定
export LANG=ja_JP.UTF-8

# パス設定
typeset -U path
path=(
    $path
    $HOME/bin
    ~/projects/dotfiles/bin
    $GOPATH/bin
)

# 関数設定
## 強調 echo
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
