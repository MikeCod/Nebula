#!/bin/bash

if [ "$EUID" -eq 0 ]; then
	echo "Please do NOT run as root" >&2
	exit 1
fi

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1
	pwd -P
)"

conf="$SCRIPTPATH/conf/"

sudo apt update
if [[ $? -ne 0 ]]; then
	exit 1
fi
sudo apt install -y \
	highlight \
	vim \
	dialog \
	hexedit \
	csvtool \
	csvkit

cd /tmp && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && nvm install 20 && node -v && npm -v

cd $conf

# Terminal
cp -v .zshrc ~/ && sudo cp -v .zshrc /root/
sudo cp -v vimrc /etc/vim/
git config --global init.defaultBranch main

sed -Ei '/export ENHANCED_PATH\=/d' ~/.zshrc
echo "export ENHANCED_PATH='$SCRIPTPATH'" >> ~/.zshrc