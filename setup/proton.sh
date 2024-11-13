#!/bin/bash


# Mail
cd /tmp
wget https://proton.me/download/mail/linux/ProtonMail-desktop-beta.deb
sudo dpkg -i ./ProtonMail-desktop-beta.deb

# VPN
wget https://repo.protonvpn.com/debian/dists/unstable/main/binary-all/protonvpn-beta-release_1.0.3-3_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.3-3_all.deb && sudo apt update
echo "de7ef83a663049b5244736d3eabaacec003eb294a4d6024a8fbe0394f22cc4e5  protonvpn-stable-release_1.0.3-3_all.deb" | sha256sum --check -
