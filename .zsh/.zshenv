# 言語設定
export LANG=ja_JP.UTF-8

# DevkitPro
export DEVKITPRO=~/devkitPro
export DEVKITPPC=$DEVKITPRO/devkitPPC

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

## 実行ファイル（シェルスクリプト）作成コマンド
## (http://qiita.com/blackenedgold/items/c9e60e089974392878c8)
mksh() {
    min=false

    if [ "$1" = "-m" ]; then
        min=true
        shift
    fi

    [ $# = 1 ]

    cat <<'SHELLSCRIPT' > "$1"
#!/bin/sh

set -eu

SHELLSCRIPT

    if ! $min; then
        cat <<'SHELLSCRIPT' >> "$1"
usage() {
    cat <<HELP
NAME:
  $(basename $0) -- {one sentence description}

SYNOPSIS:
  $(basename $0) [-h|--help]
  $(basename $0) [--verbose]

DESCRIPTION:
  {description here}

  -h  --help      Print this help.
      --verbose   Enables verbose mode.

EXAMPLE:
  {examples if any}

HELP
}

# 割り込みや正常終了時に実行する処理
graceful_exit() {
  :
}
trap graceful_exit 0

opt_arg=""
parse_opt_arg() {
    # 引数が必要なオプションに引数がなければエラー終了させる
    if [ $# -lt 2 ] || !(case "$2" in -*) false;; esac); then
        printf "Option requires an argument: $1\n" >&2
        exit 1
    fi

    opt_arg="$2"
}


script_dir="$(cd $(dirname "$0"); pwd)"

while [ $# -gt 0 ]; do
    case "$1" in
        -t | --test    ) parse_opt_arg "$@"
                         printf "test: $opt_arg\n"
                         shift;;
        -h | --help    ) usage; exit 0;;
             --verbose ) set -x;;
        --             ) shift; break;;
        -*             ) printf "Illegal option: $1\n" >&2; exit 1;;
        *              ) break;;
    esac
    shift
done

# do something
printf "$*\n"
SHELLSCRIPT
    fi

    chmod +x "$1"
}
