#!/bin/bash

source dep/requirement.sh

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
	pdfid pdf-parser poppler-utils \
	tesseract-ocr \
	libreoffice libreoffice-gnome \
	qbittorrent \
	vlc

if ! [ -x "$(command -v node)" ]; then
	cd /tmp && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	nvm install 20
	node -v && npm -v
fi

cd "$conf"

/bin/bash "$SCRIPTPATH/setup/default.sh"
/bin/bash "$SCRIPTPATH/setup/docker.sh"

options=$(git help -a | grep credential- | cut -d- -f2)
git_credential=$(question "$options" "Pick an option" "Choose 'store' if you're a beginner, or if your disk is encrypted\nYou'll always have the possibility to change this running:\n\tgit config --global -e")
git_credential=$(echo $git_credential | tail -n 1)
echo

case $git_credential in
	"store")
		echo "Credentials will be stored on disk"
		git config --global credential.helper store
		;;
	"cache")
		timeout=$(bash -c "read -p $'How much time (in second) do you want your credential to be kept in memory (Leave blank for default)\n\tdefault  900 (15min)\n\t0        no timeout (until session log out)\n? ' c; echo \$c")
		if [[ $timeout == "" ]]; then
			echo "Left blank, default is 900"
			git config --global credential.helper cache
		elif [[ $timeout == "0" ]]; then
			echo "No timeout: Until session log out"
			git config --global credential.helper "cache --no-timeout"
		else
			echo "Timeout set to $timeout"
			git config --global credential.helper "cache --timeout $timeout"
		fi
		;;
esac

sed -Ei '/export ENHANCED_PATH\=/d' ~/.zshrc
echo "export ENHANCED_PATH='$SCRIPTPATH'" >> ~/.zshrc

# Snap package manager
sudo systemctl enable --now snapd && sudo systemctl enable --now snapd.apparmor
# Bluetooth
sudo systemctl enable --now blueman-mechanism

# App settings
unpack vscode ~/.config/Code/User/
sed -E "s/\/home\/user1000/\/home\/${USER}/g" vscode.extensions.json > ~/.vscode/extensions/extensions.json

unpack libreoffice ~/.config/libreoffice/4/user/
unpack fonts "/usr/local/share/fonts/" true

# Gnome Settings
## Volume
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-mute "['F1']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down "['F2']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up "['F3']"

## Screenshot / Screenrecord
if [[ -z "$PRINT" ]]; then
	print=$(question_close "Does your keyboard have the key 'Print Screen'")
	echo
	if [[ $print == "y" ]]; then
		gsettings reset org.gnome.shell.keybindings screenshot
		gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Super>s']"
		gsettings set org.gnome.shell.keybindings screenshot-window "['<Shift><Alt><Super>s']"
		gsettings set org.gnome.shell.keybindings show-screen-recording-ui "['<Shift><Control><Super>s']"

	else
		gsettings set org.gnome.shell.keybindings screenshot "['F9']"
		gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift>F9']"
		gsettings set org.gnome.shell.keybindings screenshot-window "['<Control>F9']"
		gsettings set org.gnome.shell.keybindings show-screen-recording-ui "['<Shift><Control>F9']"
	fi
	sed -Ei '/export PRINT\=/d' ~/.zshrc
	echo "export PRINT='$print'" >> ~/.zshrc
fi

## System sounds
gsettings set org.gnome.desktop.sound event-sounds false
gsettings set org.gnome.desktop.sound input-feedback-sounds false

# https://github.com/fthx/dock-from-dash

sudo snap install \
	core \
	discord \
	whatsdesk \
	telegram-desktop \
	spotify

sudo cp -v ./whatsdesk.desktop /opt/
sudo desktop-file-install /opt/whatsdesk.desktop
