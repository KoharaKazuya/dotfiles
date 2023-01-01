#!/bin/sh

set -e

# Development Containers, GitHub Codespaces 環境のみのセットアップ
if [ "${REMOTE_CONTAINERS:-}" = true ] || [ "${CODESPACES:-}" = true ]; then
  if cat /etc/os-release | grep PRETTY_NAME= | grep -i debian >/dev/null && type apt-get >/dev/null; then
    # 日本語化
    sudo sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && sudo locale-gen && sudo update-locale LANG=ja_JP.UTF-8 # 日本語化
    # よく使うコマンドをインストールする
    curl -sSLf -o /tmp/git-delta-musl_0.15.1_amd64.deb https://github.com/dandavison/delta/releases/download/0.15.1/git-delta-musl_0.15.1_amd64.deb
    sudo apt-get update && sudo apt-get install -y \
      tig \
      ripgrep \
      /tmp/git-delta-musl_0.15.1_amd64.deb
  fi
fi

CONTAINER=~/projects

mkdir -p $CONTAINER
if [ ! -d $CONTAINER/dotfiles ]; then
  cd $CONTAINER
  git clone --recursive https://github.com/KoharaKazuya/dotfiles.git
fi
cd $CONTAINER/dotfiles

for dotfile in $(git ls-files | grep '^\.' | sed -e 's/\/.*//' | uniq)
do
  if [ -e ~/$dotfile ]; then
    if [ "$(readlink ~/$dotfile)" != "$CONTAINER/dotfiles/$dotfile" ]; then
      echo "Already exists: $dotfile"
    fi
  else
    ln -s $CONTAINER/dotfiles/$dotfile ~/
  fi
done

zsh $CONTAINER/dotfiles/.zsh/.zim/zimfw.zsh install

if type /bin/zsh > /dev/null 2>&1; then
  if [ "$SHELL" = /bin/zsh ]; then
    exec zsh -l
  else
    echo 'change your login shell: `chsh -s /bin/zsh`'
  fi
else

  echo 'install zsh'
fi
