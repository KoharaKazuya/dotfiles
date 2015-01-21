#!/bin/sh

set -e

CONTAINER=~/projects

mkdir -p $CONTAINER
if [ ! -d $CONTAINER/dotfiles ]; then
  cd $CONTAINER
  git clone https://github.com/KoharaKazuya/dotfiles.git
fi

cd $CONTAINER/dotfiles
git submodule update --init --recursive

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
