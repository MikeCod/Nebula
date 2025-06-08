#!/bin/bash

if [ "$EUID" -eq 0 ]; then
	echo "Please do NOT run as root" >&2
	exit 1
fi

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1
	pwd -P
)"
out="$SCRIPTPATH/conf/"

mkdir -p "$out" && cd "$out"

# App settings
pack() {
	cd "$1" &&
		tar cJf "$out$2.tar.xz" ${3:-.} &&
		cd "$out"
}

term=false
code=false
office=false
soft=false

# Terminal
export_terminal() {
	if [ $term = false ]; then
		cp -v ~/.zshrc .
		cp -v /etc/vim/vimrc .
		if type "dconf" &> /dev/null; then
			echo "GNOME detected"
			dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome-terminal-profiles.dconf
		elif [ -d "$HOME/.local/share/konsole/" ]; then
			echo "KDE detected"
			pack "$HOME/.local/share/konsole/" kde-term
			cp -v ~/.config/konsolerc .
		else
			echo "Unsupported Desktop environment" >&2
		fi
		term=true
	fi
}

# VSCode
export_vscode() {
	if [ $code = false ]; then
		pack ~/.config/Code/User/ vscode "*.json"
		sed -E 's/\/home\/([a-z0-9_.]+)/\/home\/user1000/g' ~/.vscode/extensions/extensions.json > vscode.extensions.json
		code=true
	fi
}

# LibreOffice
export_office() {
	if [ $office = false ]; then
		pack ~/.config/libreoffice/4/user libreoffice
		pack /usr/local/share/fonts fonts
		office=true
	fi
}

# Other software
export_others() {
	if [ $soft = false ]; then
		cp -v /opt/whatsdesk.desktop .
		soft=true
	fi
}

PARSED=$(getopt --options="tacos" --longoptions="term,all,code,office,soft" --name "$0" -- "$@") || exit 2

# read getopt’s output this way to handle the quoting right
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
	case "$1" in
	-a | --all)
		export_terminal
		export_vscode
		export_office
		export_others
		exit 0
		;;
	-t | --term)
		export_terminal
		;;
	-c | --code)
		export_vscode
		;;
	-o | --office)
		export_office
		;;
	-s | --soft)
		export_others
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
