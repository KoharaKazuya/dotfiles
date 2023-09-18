#!/bin/sh

set -e

# Development Containers, GitHub Codespaces 環境のみのセットアップ
if [ "${REMOTE_CONTAINERS:-}" = true ] || [ "${CODESPACES:-}" = true ]; then
  if cat /etc/os-release | grep PRETTY_NAME= | grep -i debian >/dev/null && type apt-get >/dev/null; then
    # 日本語化
    if [ "$LANG" != ja_JP.UTF-8 ]; then
      sudo sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && sudo locale-gen && sudo update-locale LANG=ja_JP.UTF-8
    fi
    # よく使うコマンドをインストールする
    sudo apt-get update && sudo apt-get install -y \
      vim \
      tig \
      ripgrep \
      file \
      bat
    mkdir -p "$HOME/bin" && ln -s /usr/bin/batcat "$HOME/bin/bat"
    if ! dpkg --status git-delta >/dev/null 2>&1; then
      ARCH=
      if [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x86_64" ]; then ARCH=amd64; fi
      if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi
      if [ -n "$ARCH" ]; then
        curl -sSLf -o /tmp/git-delta.deb https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_$ARCH.deb
        sudo apt-get install -y /tmp/git-delta.deb
      fi
    fi
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

if type /bin/zsh > /dev/null 2>&1; then
  if [ "$SHELL" = /bin/zsh ]; then
    exec zsh -l
  else
    echo 'change your login shell: `chsh -s /bin/zsh`'
  fi
else

  echo 'install zsh'
fi
