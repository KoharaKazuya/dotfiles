# 変数設定
## フォント
local NORMAL='\e[0m'
### 文字色
local BLACK='\e[30m'
local RED='\e[31m'
local GREEN='\e[32m'
local YELLOW='\e[33m'
local BLUE='\e[34m'
local MAGENTA='\e[35m'
local CYAN='\e[35m'
local WHITE='\e[36m'
### 装飾
local BOLD='\e[1m'

# オプション設定
setopt auto_pushd
setopt pushd_ignore_dups
## 履歴設定
HISTFILE="$HOME/.zsh_history"
HISTSIZE=32768
SAVEHIST=32768
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt share_history
##
setopt transient_rprompt
## プロンプト変数内で変数参照を有効にする
setopt prompt_subst
## フック
autoload -Uz add-zsh-hook
## パスのディレクトリ単位で ^w が行えるように
WORDCHARS=${WORDCHARS:s/\//}

# キーバインド
bindkey '^w' beginning-of-line
bindkey '^e' end-of-line
bindkey '^r' backward-kill-word
bindkey '^s' push-line
bindkey '^y' redo
bindkey '^z' undo
stty start undef
stty stop undef
stty eof ^Q

# 補完設定
fpath=($ZDOTDIR/completion $ZDOTDIR/zsh-completions/src $fpath)
autoload -U compinit
compinit -u -d $HOME/.zcompdump
## 大文字小文字を無視
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
## 補完候補をハイライトする
zstyle ':completion:*:default' menu select=2

# rm を無効化
alias rm="error \"Don't use rm command, too dangerous!\""

# zsh highlight
source $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# zsh-autosuggestions (like fish)
# source ~/.zsh/zsh-autosuggestions/autosuggestions.zsh
# zle-line-init() {
#     zle autosuggest-start
# }
# zle -N zle-line-init

# peco hitory
if builtin command -v peco > /dev/null ; then
    function peco-select-history() {
        local tac
        if which tac > /dev/null; then
            tac="tac"
        else
            tac="tail -r"
        fi
        BUFFER=$(history -n 1 | \
            eval $tac | \
            peco --query "$LBUFFER")
        CURSOR=$#BUFFER
        zle clear-screen
    }
    zle -N peco-select-history
    bindkey '^f' peco-select-history
fi

# zmv (一括 mv)
autoload -Uz zmv
alias ren='noglob zmv -W'

# 環境依存の設定ファイルを読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# プロンプト設定
## 基本設定
PROMPT="%F{$PROMPT_COLOR}%n@%m%f %(?,,%F{9})$%f "
RPROMPT="%F{$PROMPT_COLOR}[%`expr $COLUMNS / 3`<...<%~]%f"
## VCS 情報を右プロンプトに表示する
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
### リポジトリの変更を検知
autoload -Uz is-at-least
if is-at-least 4.3.10; then
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "%F{red}"
  zstyle ':vcs_info:git:*' unstagedstr "%F{red}"
  zstyle ':vcs_info:git:*' formats '%c%u(%s)-[%b]%f'
  zstyle ':vcs_info:git:*' actionformats '%c%u(%s)-[%b|%a]'
fi
### 右プロンプトに git 情報を追加
add-zsh-hook precmd vcs_info
RPROMPT="%F{green}\${vcs_info_msg_0_}%f $RPROMPT"

# ターミナルのタイトルを変更する
case "${TERM}" in
    kterm*|xterm*)
    function _change_terminal_title() {
        # タイトルをカレントディレクトリに
        if [ ${#PWD} -gt 16 ]; then
            index=$((${#PWD} - 15))
            title=...$PWD[$index,${#PWD}]
        else
            title=$PWD
        fi
        echo -ne "\033]0;$title\007"
    }
    add-zsh-hook precmd _change_terminal_title
    ## 起動時に一度だけ実行
    _change_terminal_title
    ;;
esac

# crontab -r が危険なので必ず確認メッセージを表示するようにする
crontab() {
  if [[ $1 = -r ]]; then
    echo -n "crontab: really delete $USER's crontab? (y/N) "
    typeset answer
    while :; do
      read answer
      [[ $answer = (y|Y) ]] && break
      return 0
    done
  fi
  command crontab ${1+"$@"}
}

## zsh から Mac の通知センターを利用する
export SYS_NOTIFIER="$(builtin command -v terminal-notifier)"
if [ $SYS_NOTIFIER ]; then
  export NOTIFY_COMMAND_COMPLETE_TIMEOUT=10
  source $ZDOTDIR/zsh-notify/notify.plugin.zsh
fi

# 矢印キーで「上へ」「戻る」を実現
cdup() {
    cd ..
    zle reset-prompt
}
cdback() {
    popd
    zle reset-prompt
}
## M-↑でcdup
zle -N cdup
bindkey '^[[1;5A' cdup
## M-←でpopd
zle -N cdback
bindkey '^[[1;5D' cdback
