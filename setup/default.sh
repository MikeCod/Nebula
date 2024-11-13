
# Terminal
dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf
cp -v .zshrc ~/ && sudo cp -v .zshrc /root/
sudo cp -v vimrc /etc/vim/
git config --global init.defaultBranch main