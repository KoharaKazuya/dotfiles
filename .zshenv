# ↓ コメントアウトで起動時にプロファイリング
# zmodload zsh/zprof

export ZDOTDIR=$HOME/.zsh
source $ZDOTDIR/.zshenv

# Start configuration added by Zim install {{{
#
# User configuration sourced by all invocations of the shell
#

# Define Zim location
: ${ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim}
# }}} End configuration added by Zim install
