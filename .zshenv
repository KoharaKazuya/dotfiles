# ↓ コメントアウトで起動時にプロファイリング
# zmodload zsh/zprof

# 言語設定
export LANG=ja_JP.UTF-8

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

export ZDOTDIR=$HOME/.zsh

# 独自関数
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
## 画面幅に合わせて境界線を出力する
print_separator() {
    printf '\e[0;2m%s\e[0m\n' "${(r:COLUMNS::─:)}"
}
