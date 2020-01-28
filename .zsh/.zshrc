# fpath は Zim の初期化の前に設定しておく必要があるため、最初に読み込む
## 自作補完設定
fpath=($ZDOTDIR/completion $fpath)
## 環境依存の fpath 設定ファイルを読み込む
if [ -d "$HOME/.zsh.local/completion" ]; then
  echo '[DEPRECATED] *.local 系の設定ファイルの読み込みは廃止予定です。$HOME/.config/zsh を使用してください: ~/.zsh.local/completion' >&2
  fpath+=($HOME/.zsh.local/completion)
fi
if [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completion" ]; then
  fpath+=(${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completion)
fi


# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}


# --------------------
# Module configuration
# --------------------

#
# completion
#

# Set a custom path for the completion dump file.
# If none is provided, the default ${ZDOTDIR:-${HOME}}/.zcompdump is used.
#zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=10'

# ------------------
# Initialize modules
# ------------------

if [[ ${ZIM_HOME}/init.zsh -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  # Update static initialization script if it's outdated, before sourcing it
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}} End configuration added by Zim install

## Zim Customize
### (プロンプト表示などで使われる) git status の確認時、untracked なファイルも確認するように
zstyle ':zim:git-info' verbose 'yes'
### ヒストリファイルのディレクトリを変更する
if [ -f "$HOME/.zsh_history" ]; then
  echo '[DEPRECATED] zsh history ファイルの位置が変更になりました' >&2
  if [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/history" ]; then
    echo '${XDG_CONFIG_HOME:-$HOME/.config}/zsh/history が既に存在するため、ファイル $HOME/.zsh_history を移動できません' >&2
  else
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
    mv "$HOME/.zsh_history" "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/history"
    echo "$HOME/.zsh_history を ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/history に移動しました" >&2
  fi
fi
HISTFILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/history"


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
## Esc, c でクリップボードをテキストエディタで編集できるように
_edit-clipboard() { exec < /dev/tty; edit-clipboard; }
zle -N edit-clipboard _edit-clipboard
bindkey '^[c' edit-clipboard
## Esc, m で入力中コマンドの man page を表示する
_manpage-for-current-buffer() {
  exec < /dev/tty
  clear
  echo "$BUFFER" | head -n1 | sed -E 's/^.*\|//;s/^ *[^ ]*=[^ ]*//' | awk '{print $1}' | xargs man
  print -z "$PREBUFFER$BUFFER"
  zle send-break
}
zle -N manpage-for-current-buffer _manpage-for-current-buffer
bindkey '^[m' manpage-for-current-buffer
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

# 自作コマンド群を読み込む
for f in "$ZDOTDIR/functions/"*; do
  source "$f"
done

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
            peco --query "$LBUFFER" --initial-filter Fuzzy)
        CURSOR=$#BUFFER
        zle clear-screen
    }
    zle -N peco-select-history
    bindkey '^r' peco-select-history
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
  if [ -t 1 ]; then
    cat_readme
    ls_abbrev
  fi
}
## カレントディレクトリに README ファイルがあれば表示する
cat_readme() {
  (IFS=$'\n'; for f in $(ls | grep -i 'readme'); do
    if file "$f" | grep text >/dev/null 2>&1; then
      printf '[0;2m%s[0m\n' "$f"
      # Markdown ファイルは mdcat コマンドで表示する
      if echo "$f" | grep -E '\.md$' >/dev/null 2>&1 && builtin command -v mdcat >/dev/null 2>&1; then
        mdcat --local "$f" 2>/dev/null | head -n 10
      else
        cat "$f" | awk '{print}' | head -n 10
      fi
      printf '[0;2;4m%s[0m\n\n' "${(r:COLUMNS:: :)}"
    fi
  done)
}
## 候補数が多すぎる時に省略される ls
ls_abbrev() {
    # -t : Sort by time modified.
    # -A : Do not ignore entries starting with . except for . and ..
    # -C : Force multi-column output.
    # -F : Append indicator (one of */=>@|) to entries.
    local cmd_ls='ls'
    local -a opt_ls
    opt_ls=('-tACF' '--color=always')
    case "${OSTYPE}" in
        freebsd*|darwin*)
              # -G : Enable colorized output.
              opt_ls=('-tACFG')
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 3 ]; then
        echo "$ls_result" | head -n 3
        echo '...'
        echo "$(command ls -1 -A | wc -l | tr -d ' ') entries exist"
    else
        echo "$ls_result"
    fi
}


# zsh の再読込用関数
alias reload='exec zsh -l'


# 環境依存の設定ファイルを読み込む
if [ -f ~/.zshrc.local ]; then
  echo '[DEPRECATED] *.local 系の設定ファイルの読み込みは廃止予定です。$HOME/.config/zsh を使用してください: ~/.zshrc.local' >&2
  source ~/.zshrc.local
fi
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshrc" ]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshrc"
fi
## PROMPT_COLOR が設定されていなければ警告
[ -z "$PROMPT_COLOR" ] && notice 'PROMPT_COLOR is not defined.\nRun `mkdir -p ~/.config/zsh && echo "export PROMPT_COLOR=..." >> ~/.config/zsh/zshrc`'

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
