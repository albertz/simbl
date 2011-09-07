#!/bin/zsh

cd "$(dirname "$0")"

# This fails for some reason...
#xcodebuild || exit -1
#fr="build/Deployment/SIMBL.bundle"

fr=~"/Library/Developer/Xcode/DerivedData/SIMBL-bywjapbgwjkqudffllmvcchuzrhl/Build/Products/Development/SIMBL.bundle"

execpath="$fr/Contents/Resources/SIMBL Agent.app/Contents/MacOS/"

for execname in "SIMBL Agent" "inject_helper_32" "inject_helper_64"; do
install_name_tool -add_rpath \
	"/System/Library/Services/SIMBL.bundle/Contents/Resources/SIMBL Agent.app/Contents" \
	"$execpath/$execname"
done

D="/System/Library/Services/"
echo "copying .."
sudo rm -rf "$D/SIMBL.bundle"
sudo cp -a ${fr} $D

sudo chown root $execpath/inject_helper_*
sudo chgrp procmod $execpath/inject_helper_*
sudo chmod ug+s $execpath/inject_helper_*
#sudo chown root $D/SIMBL.bundle

# reinstall SIMBL Agent
launchctl remove net.culater.SIMBL.Agent
"$D/SIMBL.bundle/Contents/Resources/SIMBL Agent.app/Contents/MacOS/SIMBL Agent" -psn
