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
success() {
    echo -e "${fg_bold[green]}$*${reset_color}"
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

## 実行ファイル（シェルスクリプト）作成コマンド
## (http://qiita.com/blackenedgold/items/c9e60e089974392878c8)
mksh() {
    cat <<'SHELLSCRIPT' > "$1"
#!/bin/sh
usage() {
    cat <<HELP
NAME:
   $0 -- {one sentence description}

SYNOPSIS:
  $0 [-h|--help]
  $0 [--verbose]

DESCRIPTION:
   {description here}

  -h  --help      Print this help.
      --verbose   Enables verbose mode.

EXAMPLE:
  {examples if any}

HELP
}

main() {
    SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"

    for ARG; do
        case "$ARG" in
            --help) usage; exit 0;;
            --verbose) set -x;;
            --) break;;
            -*)
                OPTIND=1
                while getopts h OPT "$ARG"; do
                    case "$OPT" in
                        h) usage; exit 0;;
                    esac
                done
                ;;
        esac
    done

    # do something
}

main "$@"

SHELLSCRIPT
    chmod +x "$1"
}
