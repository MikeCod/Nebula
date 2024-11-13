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
	snapd \
	bluez \
	bluez-tools \
	blueman \
	hexedit \
	csvtool \
	csvkit \
	pdfid pdf-parser

cd /tmp && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && nvm install 20 && node -v && npm -v

cd $conf

# Terminal
dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf
cp -v .zshrc ~/ && sudo cp -v .zshrc /root/
sudo cp -v vimrc /etc/vim/
git config --global init.defaultBranch main

sed -Ei '/export ENHANCED_PATH\=/d' ~/.zshrc
echo "export ENHANCED_PATH='$SCRIPTPATH'" >> ~/.zshrc

# Snap package manager
sudo systemctl enable --now snapd && sudo systemctl enable --now snapd.apparmor
# Bluetooth
sudo systemctl enable --now blueman-mechanism

# App settings
unpack() {
	if [[ $3 == "true" ]]; then
		sudo tar xJvf "$1.tar.xz" --directory "$2"
	else
		tar xJvf "$1.tar.xz" --directory "$2"
	fi
}

unpack fonts "/usr/local/share/fonts/" true

# https://github.com/fthx/dock-from-dash
