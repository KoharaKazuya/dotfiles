# Zim
if [[ -s ${ZDOTDIR:-${HOME}}/.zim/init.zsh ]]; then
  source ${ZDOTDIR:-${HOME}}/.zim/init.zsh
fi
## Zim Customize
### ヒストリファイルのディレクトリを変更する
HISTFILE="$HOME/.zsh_history"
### git aliases の削除
unalias $(alias | grep '^g.*='\''*git' | cut -d'=' -f1)


# オプション設定
## 色変数を使えるように
autoload -Uz colors && colors
## 右プロンプトを最新行にしか表示しない
setopt transient_rprompt
## 補完時に濁点・半濁点を <3099> <309a> のように表示させない
setopt combining_chars
## フック
autoload -Uz add-zsh-hook
## パスのディレクトリ単位で ^w が行えるように
WORDCHARS=${WORDCHARS:s/\//}

# 補完設定
fpath=($ZDOTDIR/completion $fpath)
# 自作コマンドの補完設定を読み込む
# autoload -Uz git-_my-compinit && git-_my-compinit
# ↑ 重い……


# less コマンドのデフォルト引数
#
# -F -- 最初の画面でファイル全体が表示できる場合、 less を自動的に終了させる
# -N -- 行番号を表示する
# -R -- 端末制御文字を解釈する (色をつけるなど)
# -S -- 画面幅に合わせて自動改行しない
# -X -- コマンド終了時に画面クリアを防ぐ
# export LESS="-F -R -S -X"

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

# 絶対パスを記録する cd
function cd() {
  # 引数を2つとる cd (zsh の独自機能) の場合はフックしない
  if [ $# -eq 1 ]; then
    # 再帰を防ぐためにビルトインの cd を呼び出し
    builtin cd $1
    # cd に失敗したら終了
    if [ $? -ne 0 ]; then
      return 1
    fi
    # シェルからの直接呼び出しの場合のみ history を書き換え
    if [ ${#funcstack[*]} -eq 1 ]; then
      echo cd $PWD >> $HISTFILE
      fc -R
    fi
  else
    builtin cd $*
  fi
}

# 環境依存の設定ファイルを読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# 右プロンプトにホスト名を表示する
RPROMPT="%{$reset_color%}<%n@%{$fg_bold[$PROMPT_COLOR]%}%m%{$reset_color%}>"

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

## rm がゴミ箱行きではなければ、警告を出す
if builtin command -v rm-osx-trash > /dev/null; then
  alias rm=rm-osx-trash
else
  warning "rm is dangerous."
  if [ "$(uname)" = 'Darwin' ]; then
    echo 'see https://github.com/KoharaKazuya/rm-osx-trash'
  fi
fi

## colordiff がインストールされていれば diff を置き換え
if builtin command -v colordiff > /dev/null; then
  alias diff=colordiff
fi

## zsh から Mac の通知センターを利用する
export SYS_NOTIFIER="$(builtin command -v terminal-notifier)"
if [ $SYS_NOTIFIER ]; then
  export NOTIFY_COMMAND_COMPLETE_TIMEOUT=10
  source $ZDOTDIR/zsh-notify/notify.plugin.zsh
fi


# zsh プロファイラが読み込まれていたら、ロード完了時に
# プロファイリング結果を less で表示する
if type zprof >/dev/null 2>&1; then
  zprof | less
fi
