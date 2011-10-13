#!/bin/zsh

cd "$(dirname "$0")"

xcodebuild -workspace SIMBL.xcodeproj/project.xcworkspace -scheme SIMBL SYMROOT=$(pwd)/build || exit -1

fr="build/Development/SIMBL.bundle"

execpath="$fr/Contents/Resources/SIMBL Agent.app/Contents/MacOS/"

for execname in "SIMBL Agent" "inject_helper_32" "inject_helper_64"; do
install_name_tool -add_rpath \
	"/System/Library/Services/SIMBL.bundle/Contents/Resources/SIMBL Agent.app/Contents" \
	"$execpath/$execname"
done

echo "fixing permissions. setting SUID, etc. .."
sudo chown root $execpath/inject_helper_*
sudo chgrp procmod $execpath/inject_helper_*
sudo chmod ug+s $execpath/inject_helper_*

D="/System/Library/Services/"
echo "copying .."
sudo rm -rf "$D/SIMBL.bundle"
sudo cp -a ${fr} $D

# reinstall SIMBL Agent
launchctl remove net.culater.SIMBL.Agent
"$D/SIMBL.bundle/Contents/Resources/SIMBL Agent.app/Contents/MacOS/SIMBL Agent" -psn
