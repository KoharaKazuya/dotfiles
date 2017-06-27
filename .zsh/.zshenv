# 言語設定
export LANG=ja_JP.UTF-8

# Go
export GOPATH=~/go
export GOROOT=$(command -v go > /dev/null && go env GOROOT)

# パス設定
typeset -U path
path=(
    $path
    $HOME/bin
    ~/projects/dotfiles/bin
    $GOPATH/bin
)

# 関数設定
## 設定ファイル再読み込み
alias reload='exec zsh -l'
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


## cd ショートカット
cdl() {
  cd -P ~/links/"$1"
}
