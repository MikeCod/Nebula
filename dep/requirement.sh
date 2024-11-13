
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
