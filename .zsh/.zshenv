# 言語設定
export LANG=ja_JP.UTF-8

# DevkitPro
export DEVKITPRO=~/devkitPro
export DEVKITPPC=$DEVKITPRO/devkitPPC

# Go
export GOPATH=~/go
export GOROOT=$(command -v go > /dev/null && go env GOROOT)

# パス設定
path=(
    $path
    $HOME/bin
    $GOPATH/bin
)

# 関数設定
## 設定ファイル再読み込み
alias reload='exec zsh -l'
## 強調 echo
success() {
    echo -e "$GREEN$BOLD$*$NORMAL"
}
warning() {
    echo -e "$YELLOW$BOLD$*$NORMAL" >&2
}
error() {
    echo -e "$RED$BOLD$*$NORMAL" >&2
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
            if type gls > /dev/null 2>&1; then
                cmd_ls='gls'
            else
                # -G : Enable colorized output.
                opt_ls=('-aCFG')
            fi
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 10 ]; then
        echo "$ls_result" | head -n 5
        echo '...'
        echo "$ls_result" | tail -n 5
        echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}
## 空エンターで ls を実行する
function do_enter() {
    if [ -n "$BUFFER" ]; then
        zle accept-line
        return 0
    fi
    echo
    ls_abbrev
    zle reset-prompt
    return 0
}
zle -N do_enter
bindkey '^m' do_enter
## mkdir + cd
function mkcd() {
  if [[ -d $1 ]]; then
    echo "It already exsits! Cd to the directory."
    cd $1
  else
    echo "Created the directory and cd to it."
    mkdir -p $1 && cd $1
  fi
}
## zsh の man から調べる
function zman() {
    PAGER="less -g -s '+/^       "$1"'" man zshall
}

# お遊び
## command not found を楽しくする
function command_not_found_handler() {
    echo "(▽▽) '$YELLOW$BOLD$0$NORMAL'？　そのようなコマンドない！"
}
