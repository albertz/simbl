#!/bin/zsh

cd "$(dirname "$0")"

# This fails for some reason...
#xcodebuild || exit -1
#fr="build/Deployment/SIMBL.bundle"

fr=~"/Library/Developer/Xcode/DerivedData/SIMBL-bywjapbgwjkqudffllmvcchuzrhl/Build/Products/Development/SIMBL.bundle"

appbin="$fr/Contents/Resources/SIMBL Agent.app/Contents/MacOS/SIMBL Agent"

install_name_tool -add_rpath \
	"/System/Library/Services/SIMBL.bundle/Contents/Resources/SIMBL Agent.app/Contents" \
	$appbin

#sudo chgrp procmod $appbin
#sudo chmod g+s $appbin

D="/System/Library/Services/"
echo "copying .."
sudo rm -rf "$D/SIMBL.bundle"
sudo cp -a ${fr} $D

sudo chown root $D/SIMBL.bundle

# reinstall SIMBL Agent
sudo launchctl remove net.culater.SIMBL.Agent
sudo "$D/SIMBL.bundle/Contents/Resources/SIMBL Agent.app/Contents/MacOS/SIMBL Agent" -psn
