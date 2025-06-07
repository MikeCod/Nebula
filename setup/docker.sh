if ! [ -x "$(command -v docker)" ]; then
	source /etc/os-release

	id=$ID
	version=$VERSION_CODENAME
	case $ID in
	"kali")
		id="debian"
		version="bookworm"
		;;
	"debian" | "ubuntu" | "raspbian") ;;
	*)
		# TODO: Check ID_LIKE
		echo "Error: Unknown OS $NAME with ID $ID" >&2
		exit 1
		;;
	esac

	# Add Docker's official GPG key:
	sudo apt-get update
	sudo apt-get install ca-certificates curl \
		dbus-user-session slirp4netns uidmap
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$id $version stable" |
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# Rootless
	sudo systemctl disable --now docker.service docker.socket
	sudo rm /var/run/docker.sock

	dockerd-rootless-setuptool.sh install

	systemctl enable --user --now docker.service
	systemctl enable --user --now containerd.service
fi
