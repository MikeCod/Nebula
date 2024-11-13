#!/bin/bash

source dep/requirement.sh

cd "$conf"

# Terminal
/bin/bash "$SCRIPTPATH/setup/default.sh"

sed -Ei '/export ENHANCED_PATH\=/d' ~/.zshrc
echo "export ENHANCED_PATH='$SCRIPTPATH'" >> ~/.zshrc
