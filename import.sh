#!/bin/bash


if [[ $1 == "-h" || $1 == "--help" ]]; then
	printf "\e[4mUsage:\e[0m $0 { --setup | --setup-no-gui }\n"
	echo
	printf "\e[4mFull install:\e[0m\n"
	echo "    --setup          Setup environment"
	echo "    --setup-no-gui   Setup environment without graphical UI"
	echo
	printf "\e[4mUpdate:\e[0m\n"
	echo "  -a  --all          Import everything"
	echo "  -u  --update       Alias for -a"
	echo
	printf "\e[4mUnique:\e[0m\n"
	echo "  -c  --code         Setup VSCode"
	echo "  -d  --docker       Setup rootless Docker"
	echo "  -g  --git          Setup git"
	echo "  -n  --node         Setup Node.js"
	echo "  -o  --office       Setup LibreOffice"
	echo "  -s  --soft         Setup entertainment and convenient softwares"
	echo "                       (Spotify, Telegram, WhatsDesk, Discord, Gnome settings)"
	echo
	echo "Note: Setup means install and configure"
	echo

	exit 0
fi

if [ "$EUID" -eq 0 ]; then
	echo "Please do NOT run as root" >&2
	exit 1
fi

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1
	pwd -P
)"

conf="$SCRIPTPATH/conf/"

unpack() {
	if [[ $3 == "true" ]]; then
		sudo tar xJf "$1.tar.xz" --directory "$2"
	else
		tar xJf "$1.tar.xz" --directory "$2"
	fi
}

question() {
	echo >&2
	printf "$1" | cat -n >&2
	printf "\n\n$3\n\n" >&2
	answer=$(bash -c "read -p \"$2 [1-$(echo "$1" | wc -l)] \" c; echo \$c")
	echo "$options" | sed "${answer}q;d" | cut '-d ' -f1
}

question_close() {
	echo
	bash -c "read -p \"$1 ? [y/n] \" -n 1 c; echo \$c"
}


cd "$conf"


sed -Ei '/export ENHANCED_PATH\=/d' ~/.zshrc
echo "export ENHANCED_PATH='$SCRIPTPATH'" >> ~/.zshrc

_git=false
term=false
code=false
office=false
soft=false


setup_base() {
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
		csvkit \
		pdfid pdf-parser poppler-utils \
		tesseract-ocr
}

# Terminal
setup_git() {
	if [ $_git = false ]; then
		git config --global pull.ff only

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
		_git=true
	fi
}

# Terminal
import_terminal() {
	if [ $term = false ]; then
		if [ -d "/org/gnome" ]; then
			echo "GNOME detected"
			dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf
		elif [ -d "$HOME/.local/share/konsole" ]; then
			echo "KDE detected"
			unpack kde-term "$HOME/.local/share/konsole/"
			cp -v konsolerc "$HOME/.config/"
		else
			echo "Unsupported Desktop environment" >&2
		fi
		cp -v .zshrc ~/ && sudo cp -v .zshrc /root/
		sudo cp -v vimrc /etc/vim/
		git config --global init.defaultBranch main
		term=true
	fi
}

# Node
setup_node() {
	if ! [ -x "$(command -v node)" ]; then
		cd /tmp && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
		export NVM_DIR="$HOME/.nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
		nvm install 20
		node -v && npm -v
	fi
}

# Docker
setup_docker() {
	/bin/bash "$SCRIPTPATH/setup/docker.sh"
}

# VSCode
import_vscode() {
	if [ $code = false ]; then
		# App settings
		unpack vscode ~/.config/Code/User/
		sed -E "s/\/home\/user1000/\/home\/${USER}/g" vscode.extensions.json > ~/.vscode/extensions/extensions.json
		code=true
	fi
}

# LibreOffice
import_office() {
	if [ $office = false ]; then
		unpack libreoffice ~/.config/libreoffice/4/user/
		unpack fonts "/usr/local/share/fonts/" true

		office=true
	fi
}

# Other software
setup_others() {
	if [ $soft = false ]; then
		sudo apt install -y \
			highlight \
			vim \
			dialog \
			libreoffice libreoffice-gnome \
			qbittorrent \
			vlc
		# Snap package manager
		sudo systemctl enable --now snapd && sudo systemctl enable --now snapd.apparmor
		# Bluetooth
		sudo systemctl enable --now blueman-mechanism

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
				gsettings set org.gnome.shell.keybindings screenshot-window "['<Control><Super>s']"
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

		soft=true
	fi
}

PARSED=$(getopt --options="gudntacos" --longoptions="git,update,docker,node,term,all,code,office,soft,setup,setup-no-gui" --name "$0" -- "$@") || exit 2

# read getopt’s output this way to handle the quoting right
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
	case "$1" in
	-a | --all | -u | --update)
		import_terminal
		import_vscode
		import_office
		setup_others
		exit 0
		;;
	-d | --docker)
		setup_docker
		;;
	-n | --node)
		setup_node
		;;
	-t | --term)
		import_terminal
		;;
	-c | --code)
		import_vscode
		;;
	-o | --office)
		import_office
		;;
	-s | --soft)
		setup_others
		;;
	--setup)
		setup_base
		import_terminal
		setup_git
		setup_node
		setup_docker
		import_vscode
		import_office
		setup_others
		exit 0
		;;
	--setup-no-gui)
		setup_base
		import_terminal
		setup_git
		setup_node
		setup_docker
		exit 0
		;;
	--)
		break
		;;
	*)
		echo "Programming error"
		exit 3
		;;
	esac
	shift
done
