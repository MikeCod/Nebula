#!/bin/bash


version="2024.1.1.11"

pwd=$(pwd)
cd /tmp
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${version}/android-studio-${version}-linux.tar.gz
cd /opt
tar xzvf /tmp/android-studio-${version}-linux.tar.gz
rm -rf ./android-studio-${version}-linux.tar.gz
cp -v $pwd/setup/android-studio.desktop /opt/android-studio/
desktop-file-install /opt/android-studio/android-studio.desktop

echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
