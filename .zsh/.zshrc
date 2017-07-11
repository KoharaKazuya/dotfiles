# Zim
if [[ -s ${ZDOTDIR:-${HOME}}/.zim/init.zsh ]]; then
  source ${ZDOTDIR:-${HOME}}/.zim/init.zsh
fi
## Zim Customize
### ヒストリファイルのディレクトリを変更する
HISTFILE="$HOME/.zsh_history"
### git aliases の削除
unalias $(alias | grep '^g.*='\''*git' | cut -d'=' -f1)


# zsh オプション設定
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
## Esc, e でコマンドラインをテキストエディタで編集できるように
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line
## 自作補完設定
fpath=($ZDOTDIR/completion $fpath)
# 自作コマンドの補完設定を読み込む
# autoload -Uz git-_my-compinit && git-_my-compinit
# ↑ 重い……


# アプリケーション依存設定
for f in $ZDOTDIR/.zshrc.d/*.zsh; do
  source "$f"
done


# less コマンドのデフォルト引数
#
# -F -- 最初の画面でファイル全体が表示できる場合、 less を自動的に終了させる
# -N -- 行番号を表示する
# -R -- 端末制御文字を解釈する (色をつけるなど)
# -S -- 画面幅に合わせて自動改行しない
# -X -- コマンド終了時に画面クリアを防ぐ
# -g -- 検索ヒットハイライト時、現在アクティブのものだけハイライトする
# -j -- 検索ヒットへの移動時、指定数だけ下に繰り下げてスクロールする
export LESS="-F -R -X -g -j3"

# man を見やすくする
export MANPAGER='less'
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

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

# cd したときに自動で ls を表示する
## ディレクトリ移動時に ls を実行する
chpwd() {
    cat_readme
    ls_abbrev
}
## カレントディレクトリに README ファイルがあれば表示する
cat_readme() {
  (IFS='\n'; for f in $(ls | grep -i 'readme'); do
    if file "$f" | grep text >/dev/null 2>&1; then
      printf '\e[38;5;008m%s\e[0m\n' "$f"
      cat "$f" | head -n 20
      printf '\e[38;5;008m%s\e[0m\n' "${(r:COLUMNS::-:)}"
    fi
  done)
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

# cd ショートカット
cdl() {
  cd -P "$HOME/links/$1"
}

# zsh の再読込用関数
alias reload='exec zsh -l'


# 環境依存の設定ファイルを読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
## PROMPT_COLOR が設定されていなければ警告
[ -z "$PROMPT_COLOR" ] && notice 'PROMPT_COLOR is not defined.\nRun `echo "export PROMPT_COLOR=..." >> ~/.zshrc.local`'

# 右プロンプトにホスト名を表示する
RPROMPT="%{$reset_color%}<%n@%{$fg_bold[$PROMPT_COLOR]%}%m%{$reset_color%}>"

# ホスト名をでっかく表示
if ! [ -f "$HOME/.motd" ] && builtin command -v convert >/dev/null && convert -version | grep 'ImageMagick' >/dev/null; then
  echo 'generating ~/.motd' >&2
  convert \
    +antialias -pointsize 32 label:"$(hostname -s)" \
    -filter point -resize 100%x50% \
    -compress none pbm:- \
  | tail -n +3 \
  | sed -E "s/(0 )+/$(printf '\e[0m')&/g; s/(1 )+/$(printf '%s' "$bg[${PROMPT_COLOR:-white}]")&/g" \
  | sed -E 's/0 / /g; s/1 / /g' \
  > "$HOME/.motd"
fi
if [ -f "$HOME/.motd" ]; then
  # ターミナルの幅が足りないときは右端をカットしつつ出力
  cat "$HOME/.motd" \
  | sed -E "s/^(((\[[^m]*m)?.){$COLUMNS}).*$/\1/"
fi

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

## zsh から Mac の通知センターを利用する
export SYS_NOTIFIER="$(builtin command -v terminal-notifier)"
if [ $SYS_NOTIFIER ]; then
  export NOTIFY_COMMAND_COMPLETE_TIMEOUT=10
  source $ZDOTDIR/zsh-notify/notify.plugin.zsh
fi

# $fpath から補完関数を読み込む
compinit


# zsh プロファイラが読み込まれていたら、ロード完了時に
# プロファイリング結果を less で表示する
if type zprof >/dev/null 2>&1; then
  zprof | less
fi
