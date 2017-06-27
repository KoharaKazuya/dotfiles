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

## ディレクトリ移動時に ls を実行する
chpwd() {
    ls_abbrev
}
## 候補数が多すぎる時に省略される ls
ls_abbrev() {
    # -a : Do not ignore entries starting with ..
    # -C : Force multi-column output.
    # -F : Append indicator (one of */=>@|) to entries.
    local cmd_ls='ls'
    local -a opt_ls
    opt_ls=('-aCF' '--color=always')
    case "${OSTYPE}" in
        freebsd*|darwin*)
              # -G : Enable colorized output.
              opt_ls=('-aCFG')
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 5 ]; then
        echo "$ls_result" | head -n 3
        echo '...'
        echo "$ls_result" | tail -n 2
        echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}

## cd ショートカット
cdl() {
  cd -P ~/links/"$1"
}
