#!/bin/zsh

cd "$(dirname "$0")"

# for some reason, this fails...
#xcodebuild

fr=""
for f in ~/Library/Developer/Xcode/DerivedData/SIMBL-*/Build/Products/Development/SIMBL.osax; do
	echo "found SIMBL: $f"
	[ "$fr" != "" ] && echo "had already another copy, FAIL" && exit 1
	fr="$f"
done

[ "$fr" = "" ] && echo "FAIL" && exit 1

#install_name_tool -change  ...

D="/System/Library/ScriptingAdditions/"
echo "copying .."
sudo rm -rf "$D/SIMBL.osax"
sudo cp -a ${fr} $D

# reinstall SIMBL Agent
launchctl remove net.culater.SIMBL.Agent
open "$D/SIMBL.osax/Contents/Resources/SIMBL Agent.app"
